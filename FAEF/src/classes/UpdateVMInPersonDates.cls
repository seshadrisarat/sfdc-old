public class UpdateVMInPersonDates{
    //Copies Dates from Event to Contact
    public static void CopyDatesFromEventToContact(List<event> events){
        List<Contact> ContactsToUpdate = new List<Contact>();
        Set<Id> contactIDs = new Set<Id>();
        
        for(Event e : events){
            if(e.Whoid != null && (e.Type == 'In-Person Meeting' || e.Type == 'Virtual Meeting') && e.ActivityDate != null){
                contactIDs.add(e.Whoid);
            }
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Last_Virtual_Meeting_Date__c, Last_In_Person_Date__c FROM Contact WHERE ID IN :contactIDs]);
        
        for(Event e : events){
            if(e.Whoid != null && e.ActivityDate != null){
                if(e.Type == 'In-Person Meeting'){
                    Contact c = contactMap.get(e.WhoId);
                    if(c.Last_In_Person_Date__c == null || c.Last_In_Person_Date__c < e.ActivityDate){
                        c.Last_In_Person_Date__c = e.ActivityDate;
                        ContactsToUpdate.add(c);
                    }
                }else if(e.Type == 'Virtual Meeting'){
                    Contact c = contactMap.get(e.WhoId);
                    if(c.Last_Virtual_Meeting_Date__c == null || c.Last_Virtual_Meeting_Date__c < e.ActivityDate){
                        c.Last_Virtual_Meeting_Date__c = e.ActivityDate;
                        ContactsToUpdate.add(c);
                    }
                }
            }
        }
        
        update contactsToUpdate;
    }
    
    //Copies Last contact dates from Contact to Account (Only if going from a blank value, or the new date is greater then
    //the previous value. 
    public static void copyDateFromContactToAccount(List<Contact> contacts, Map<Id,Contact> oldContacts){
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        
        for(Contact c : contacts){
         if((oldContacts.get(c.id).Last_Virtual_Meeting_Date__c == null && c.Last_Virtual_Meeting_Date__c != null) ||
            (oldContacts.get(c.id).Last_Virtual_Meeting_Date__c < c.Last_Virtual_Meeting_Date__c) ||
            (oldContacts.get(c.id).Last_In_Person_Date__c == null && c.Last_In_Person_Date__c != null) ||
            (oldContacts.get(c.id).Last_In_Person_Date__c < c.Last_In_Person_Date__c) && 
            (c.Last_VM_In_Person_Date__c != null)){
                accountIds.add(c.AccountId);
            }
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT ID, Last_VM_In_Person_Date__c FROM Account WHERE ID In :accountIds]);
        
        for(Contact c : contacts){
         	if((oldContacts.get(c.id).Last_Virtual_Meeting_Date__c == null && c.Last_Virtual_Meeting_Date__c != null) ||
            	(oldContacts.get(c.id).Last_Virtual_Meeting_Date__c < c.Last_Virtual_Meeting_Date__c) ||
            	(oldContacts.get(c.id).Last_In_Person_Date__c == null && c.Last_In_Person_Date__c != null) ||
            	(oldContacts.get(c.id).Last_In_Person_Date__c < c.Last_In_Person_Date__c) && 
            	(c.Last_VM_In_Person_Date__c != null)){
                	Account a = accountMap.get(c.AccountId);
					a.Last_VM_In_Person_Date__c = c.Last_VM_In_Person_Date__c;
					accountsToUpdate.add(a);  
            }
         }
            
        update accountsToUpdate;
    }
}