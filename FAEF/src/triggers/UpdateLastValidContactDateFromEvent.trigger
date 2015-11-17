//Copy the "Last Valid Contact Date" field from an event to an Account
//Author: Mike Petrillo (BlackTab Group)
//Date: 6/14/12
//Updated: 11/14/12

trigger UpdateLastValidContactDateFromEvent on Event (before insert, before update) {
        
    //Event e = trigger.new[0];
    
    for(Event e : Trigger.new){
        //If the last valid contact date field is not blank and the event is associated to an account continue.
        if(e.New_Last_Valid_Contact_Date__c != null && e.Account_ID__c != null){
            Account a = [SELECT id, Last_Valid_Contact_Date__c FROM Account WHERE id = :e.Account_ID__c LIMIT 1];       
            if(a.Last_Valid_Contact_Date__c < e.New_Last_Valid_Contact_Date__c || a.Last_Valid_Contact_Date__c == null){
                a.Last_Valid_Contact_Date__c = e.New_Last_Valid_Contact_Date__c;
                update a;
            }
        }
        
         if(e.New_Last_Valid_Contact_Date__c != null && e.Contact_ID__c != null){
            
            //Update associated contacts with the Last Valid Contact date from the Event.
            List<Contact> contacts = [SELECT id, New_Last_Valid_Contact_Date__c FROM Contact WHERE Id = :e.Contact_ID__c];
            if(contacts.size() > 0){
                for(Contact c : contacts){
                    if(c.New_Last_Valid_Contact_Date__c < e.New_Last_Valid_Contact_Date__c || c.New_Last_Valid_Contact_Date__c == null){
                        c.New_Last_Valid_Contact_Date__c = e.New_Last_Valid_Contact_Date__c;
                    }
                }
                update contacts;
            }
            
        }
    }
    
}