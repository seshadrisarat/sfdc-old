@isTest
private class SL_Test_EmploymentHistoryHandler {

    private static testMethod void expenditureHistory() 
    {
        Account objAccount = new Account(Name='Test Account');
        insert objAccount;
        
        Contact objContact = new Contact(FirstName='Test' , LastName='Contact');
        insert objContact;
        
        List<ts2__Employment_History__c> lstEmploymentHistory = new List<ts2__Employment_History__c>{ new ts2__Employment_History__c(ts2__Employer__c=objAccount.Id , ts2__Contact__c = objContact.Id , ts2__Name__c = objAccount.Name,
                                                                                                                                    ts2__Job_Title__c='Test Title' , ts2__Employment_End_Date__c = date.today().addMonths(-20)),
                                                                                                     new ts2__Employment_History__c(ts2__Employer__c=objAccount.Id , ts2__Contact__c = objContact.Id , ts2__Name__c = objAccount.Name,
                                                                                                                                    ts2__Job_Title__c='Test Title2' , ts2__Employment_End_Date__c = date.today().addMonths(-10))};
        insert lstEmploymentHistory;
        Contact objContact1 = [Select Id , Previous_Employer__c , Previous_Employer_End_Date__c , Previous_Title__c, Previous_Employers__c from Contact LIMIT 1];
        system.assertEquals('Test Account', objContact1.Previous_Employer__c);
        system.assertEquals(date.today().addMonths(-10) , objContact1.Previous_Employer_End_Date__c);
        system.assertEquals('Test Title2', objContact1.Previous_Title__c);
        system.assertEquals('Test Account\nTest Account', objContact1.Previous_Employers__c);
        
        lstEmploymentHistory[0].ts2__Job_Title__c = 'Test Update 1';
        update lstEmploymentHistory[0];
        
        objContact1 = [Select Id , Previous_Employer__c , Previous_Employer_End_Date__c , Previous_Title__c from Contact LIMIT 1];
        system.assertEquals('Test Account', objContact1.Previous_Employer__c);
        system.assertEquals(date.today().addMonths(-10) , objContact1.Previous_Employer_End_Date__c);
        system.assertEquals('Test Title2', objContact1.Previous_Title__c);
        
        delete lstEmploymentHistory[1];
        
        objContact1 = [Select Id , Previous_Employer__c , Previous_Employer_End_Date__c , Previous_Title__c from Contact LIMIT 1];
        system.assertEquals('Test Account', objContact1.Previous_Employer__c);
        system.assertEquals(date.today().addMonths(-20) , objContact1.Previous_Employer_End_Date__c);
        system.assertEquals('Test Update 1', objContact1.Previous_Title__c);
        
        delete lstEmploymentHistory[0];
        
        objContact1 = [Select Id , Previous_Employer__c , Previous_Employer_End_Date__c , Previous_Title__c from Contact LIMIT 1];
        system.assertEquals(null, objContact1.Previous_Employer__c);
        system.assertEquals(null , objContact1.Previous_Employer_End_Date__c);
        system.assertEquals(null, objContact1.Previous_Title__c);
    }

}