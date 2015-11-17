trigger UpdateContactAdditionalAccountNotes on Account (after update) {
    List<id> contactList = new List<id>();
    Boolean flag;
    for(Account acc: Trigger.new)
    {
        Account oldAcc = Trigger.oldMap.get(acc.Id);
        
        if(acc.BD_Specific_Info__c != oldAcc.BD_Specific_Info__c){
                   
            List<Contact> con = [SELECT Id, AccountId,Additional_Account_Notes__c from
                                Contact where AccountID= :acc.Id];
       
            for(Contact cont: con)
            {
                contactList.add(cont.id);
            }
        }
    }
    if(contactList.size() > 0)
        Database.executeBatch(new updateContactsBatchable(contactList),2000); 
}