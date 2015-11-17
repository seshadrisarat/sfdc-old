//Copy the "Last Valid Contact Date" field from a task to an Account
//Author: Mike Petrillo (BlackTab Group)
//Date: 6/14/12
//Updated: 11/14/12

trigger UpdateLastValidContactDateFromTask on Task (before insert, before update) {
        
    //Task t = trigger.new[0];
    
    for(Task t : Trigger.new){
        //If the last valid contact date field is not blank and the task is associated to an account continue.
        if(t.New_Last_Valid_Contact_Date__c != null && t.Account_ID__c != null){
            
            //Update associated account with the Last Valid Contact date from the task.
            Account a = [SELECT id, Last_Valid_Contact_Date__c FROM Account WHERE id = :t.Account_ID__c LIMIT 1];
            if(a.Last_Valid_Contact_Date__c < t.New_Last_Valid_Contact_Date__c || a.Last_Valid_Contact_Date__c == null){
                a.Last_Valid_Contact_Date__c = t.New_Last_Valid_Contact_Date__c;
                update a;
            }
            
            System.debug('Account ' + a.id + ' Last Valid Contact Date: ' + a.Last_Valid_Contact_Date__c); 
        }
        
        if(t.New_Last_Valid_Contact_Date__c != null && t.Contact_ID__c != null){
            
            //Update associated contacts with the Last Valid Contact date from the task.
            List<Contact> contacts = [SELECT id, New_Last_Valid_Contact_Date__c FROM Contact WHERE Id = :t.Contact_ID__c];
            if(contacts.size() > 0){
                for(Contact c : contacts){
                    if(c.New_Last_Valid_Contact_Date__c < t.New_Last_Valid_Contact_Date__c || c.New_Last_Valid_Contact_Date__c == null){
                        c.New_Last_Valid_Contact_Date__c = t.New_Last_Valid_Contact_Date__c;
                    }
                }
                update contacts;
            }
            
        }
    }
    
}