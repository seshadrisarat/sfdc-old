@isTest
private class SL_Test_TimeTrackerHandler {

    private static testMethod void test_updateEmployee() 
    {
       Profile objStdUsrProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
       List<User> lstUsers = new List<User>{new User(Alias = 'standt1', Email='test1@segal.com', 
                                                    EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                                    LocaleSidKey='en_US', ProfileId = objStdUsrProfile.Id, 
                                                    TimeZoneSidKey='America/Los_Angeles', UserName='testSegalUse1r@segal.com'),
                                            new User(Alias = 'standt2', Email='test2@segal.com',
                                                    EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                                                    LocaleSidKey='en_US', ProfileId = objStdUsrProfile.Id, 
                                                    TimeZoneSidKey='America/Los_Angeles', UserName='testSegalUse2r@segal.com', isActive=true)
       };
       
        insert lstUsers;

        Account objAccount = new Account(Name='Test Company 1');
        insert objAccount;
        
        List<Contact> lstContact = new List<Contact>{ new Contact(AccountId=objAccount.Id , Email='test1@segal.com' , FirstName='Test' ,LastName='Contact 1'),
                                                      new Contact(AccountId=objAccount.Id , Email='test2@segal.com' , FirstName='Test' ,LastName='Contact 2'),
                                                      new Contact(AccountId=objAccount.Id , Email='cain@silverlinecrm.com' , FirstName='Test' ,LastName='Contact 3')
            
        };
        insert lstContact;
        
        Test.startTest();
            
            Time_Tracking__c objTimeTracking_Employee1 = new Time_Tracking__c(OwnerId=lstUsers[0].Id);
            insert objTimeTracking_Employee1;
            
            system.assertEquals(lstContact[0].Id , [Select Id,Employee__c from Time_Tracking__c where Id=:objTimeTracking_Employee1.Id].Employee__c);
            
            objTimeTracking_Employee1.OwnerId= UserInfo.getUserId();
            update objTimeTracking_Employee1;
            
            system.assertEquals(lstContact[2].Id , [Select Id,Employee__c from Time_Tracking__c where Id=:objTimeTracking_Employee1.Id].Employee__c);
            
        Test.stopTest();
    }

}