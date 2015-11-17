@isTest
private class TestUpdateContactAdditionalAccountNotes {

    static testmethod void TestUpdateContactAdditionalAccountNotes (){
        List<ID> contactList = new List<Id>();
        
        Account acct = new Account(Name = 'acc',BD_Specific_Info__c = '123');
        insert acct;
        
        Contact con = new Contact(AccountID = acct.id, FirstName= 'Test', LastName = 'Con',Additional_Account_Notes__c = '1');
        Insert con;  
        
        Contact con1 = new Contact(AccountID = acct.id, FirstName= 'Test' ,LastName = 'Con1',Additional_Account_Notes__c = '1');
        Insert con1;
        
        acct.BD_Specific_Info__c = '456';
        update acct;
         
        Account acc = [SELECT Id,BD_Specific_Info__c,
                      (SELECT Id,Additional_Account_Notes__c FROM Contacts)  
                      FROM Account WHERE Id =: acct.Id];
           
        for(Contact co : acc.Contacts)
        {
            contactList.add(co.id);
        } 
       
        Test.startTest();
      
        Database.executeBatch(new updateContactsBatchable(contactList),2000); 
      
        Test.stopTest();       
    }
}