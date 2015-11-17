/**
	@ClassName    : SL_Test_ContactHandler
	@JIRATicket   : YNHH-109
	@CreatedOn    : 7/17/2015
	@CreatedBy    : Sandeep
	@ModifiedBy   : 
	@Description  : This is the test class for SL_User_Handler
*/
@isTest
private class SL_Test_ContactHandler 
{
	private static testMethod void test_contacthandler() 
	{
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = p.Id,
                                    TimeZoneSidKey='America/Los_Angeles', Employee_ID__c = '123456111',
                                    UserName=System.now().millisecond() + 'test12345@test.com',isActive = true);
        insert objUser;
        system.runAs(new User(Id = UserInfo.getUserId()))
        {
            Contact objContact = new contact(FirstName = 'Test', LastName = 'User', Email='standarduser@testorg.com', Employee_Number__c = '12345611');
            insert objContact;
            objContact.Employee_Number__c = '12345611222';
            update objContact ; 
        }
	}
}