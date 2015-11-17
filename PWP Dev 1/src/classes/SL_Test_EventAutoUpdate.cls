@isTest
private class SL_Test_EventAutoUpdate {

	private static testMethod void test_EventAutoUpdate_Notification() 
	{
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'PWP Standard User']; 
        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = p.Id,
                                    TimeZoneSidKey='America/Los_Angeles', 
                                    UserName=System.now().millisecond() + 'test12345@test.com',isActive = true , Send_Call_Report_Reminder__c=true);
        insert objUser;
        
        Account objAccount = new Account(Name='Test Company PWP122 1', Send_Call_Report_Reminder__c = true);
        insert objAccount;
        
        AccountTeamMember objTeamMember = new AccountTeamMember(UserId=UserInfo.getUserId() , AccountId=objAccount.Id);
        insert objTeamMember;
        
        Event objEvent = new Event(Subject='Test Sbj 1' , OwnerId = objUser.Id , StartDateTime = DateTime.now().addDays(-10) , EndDateTime = DateTime.now().addDays(-10) , WhatId=objAccount.Id);
        insert objEvent;
        
        PageReference testPageRef = Page.SL_EventAutoUpdater;
        Test.setCurrentPage(testPageRef);
        ApexPages.currentPage().getParameters().put('EventId' , objEvent.Id);
        
        Test.startTest();
        
        SL_EventAutoUpdater objController = new SL_EventAutoUpdater();
        //First Load 
        objController.saveRecord();
        
        //Running Update second time
        objController.saveRecord();
        
        //Revoke current logged in user's Access to Event 
        delete objTeamMember;
        
        //Running Update Third Time for checking access revokecation
        objController.saveRecord();
        
        Test.stopTest();
	}
	
	private static testMethod void test_EventAutoUpdate_Notification_IncorrectEvent() 
	{
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'PWP Standard User']; 
        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = p.Id,
                                    TimeZoneSidKey='America/Los_Angeles', 
                                    UserName=System.now().millisecond() + 'test12345@test.com',isActive = true , Send_Call_Report_Reminder__c=true);
        insert objUser;
        
        Account objAccount = new Account(Name='Test Company PWP122 1', Send_Call_Report_Reminder__c = true);
        insert objAccount;
        
        PageReference testPageRef = Page.SL_EventAutoUpdater;
        Test.setCurrentPage(testPageRef);
        ApexPages.currentPage().getParameters().put('EventId' , objAccount.Id);
        
        Test.startTest();
        SL_EventAutoUpdater objController = new SL_EventAutoUpdater();
        //First Load 
        objController.saveRecord();
        Test.stopTest();
	}

}