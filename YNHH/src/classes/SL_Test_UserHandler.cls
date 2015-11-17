/**
	@ClassName    		: SL_Test_UserHandler
	@JIRATicket   		: YNHH-109 , YNHH-138, YNHH-160
	@CreatedOn    		: 7/17/2015
	@LastModifiedOn     : 8/27/2015
	@CreatedBy    		: Sandeep
	@ModifiedBy  		: Pankaj Ganwani
	@Description  		: This is the test class for SL_User_Handler
*/
@isTest
private class SL_Test_UserHandler 
{
	static Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
    static User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    
    //Method for insert case
	private static testMethod void test_UserhandlerForInsert() 
	{	    
        createProcessLevelMappings();
        system.runAs(thisUser){
        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = p.Id,
                                    Job_Code__c = '1_900',
                                    Process_Level_1__c = '1_810',
                                    Process_Level_2__c = '1_100',
                                    TimeZoneSidKey='America/Los_Angeles', Employee_ID__c = '1234111',
                                    UserName=System.now().millisecond() + 'test12345@test.com',isActive = true);
        
        Test.startTest();
        insert objUser;
        Test.stopTest();
        }
	}
	
	//Method for update case
	private static testMethod void test_UserhandlerForUpdate()
	{
		createProcessLevelMappings();
        system.runAs(thisUser){
        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = p.Id,
                                    Job_Code__c = '1_900',
                                    Process_Level_1__c = '1_810',
                                    Process_Level_2__c = '1_100',
                                    TimeZoneSidKey='America/Los_Angeles', Employee_ID__c = '1234111',
                                    UserName=System.now().millisecond() + 'test1332345@test.com',isActive = true);
        insert objUser;
        Test.startTest();
        objUser.Employee_ID__c = '1234511';
        objUser.Job_Code__c = '1_570';
        objUser.Process_Level_2__c = '1_900';
        objUser.Process_Level_1__c = null;
        update objUser;
        Test.stopTest();        
        }
	}
	
	//Method for creating ProcessLevelMappings
	private static void createProcessLevelMappings()
	{
		system.runAs(thisUser)
        {
            List<ProcessLevelMapping__c> lstPremissionSetMapping = new List<ProcessLevelMapping__c>{
                new ProcessLevelMapping__c(Name='1_900' , Permission_Set_Name__c = 'X900'),
                new ProcessLevelMapping__c(Name='1_100' , Permission_Set_Name__c = 'X100'),
                new ProcessLevelMapping__c(Name='1_810' , Permission_Set_Name__c = 'X810'),
                new ProcessLevelMapping__c(Name='1_570' , Permission_Set_Name__c = 'X570')
            };
            insert lstPremissionSetMapping;
        }
	}
}