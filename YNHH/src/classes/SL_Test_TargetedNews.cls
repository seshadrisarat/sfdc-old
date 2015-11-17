@isTest
private class SL_Test_TargetedNews {

	private static testMethod void test_NewsNotifications() 
	{
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        system.runAs(new User(Id=UserInfo.getUserId()))
        {
            List<ProcessLevelMapping__c> lstPremissionSetMapping = new List<ProcessLevelMapping__c>{
                new ProcessLevelMapping__c(Name='1_900' , Permission_Set_Name__c = 'X900'),
                new ProcessLevelMapping__c(Name='1_100' , Permission_Set_Name__c = 'X100'),
                new ProcessLevelMapping__c(Name='1_810' , Permission_Set_Name__c = 'X810'),
                new ProcessLevelMapping__c(Name='1_570' , Permission_Set_Name__c = 'X570')
            };
            insert lstPremissionSetMapping;
        }
        User objUser = new User(Alias = 'standt', Email='standarduser_TargetedNews@testorg.com',
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = p.Id,
                                    Job_Code__c = '1_900',
                                    Process_Level_1__c = '1_810',
                                    Process_Level_2__c = '1_100',
                                    TimeZoneSidKey='America/Los_Angeles', Employee_ID__c = '1234111',
                                    UserName=System.now().millisecond() + 'test12345@test.com',isActive = true);
        insert objUser;
        
        system.runAs(objUser)
        {
            insert new Notification__c(Job_Codes__c = 'All;' , Process_Levels__c='All;' , Notification__c='Test Notification' , Status__c='Approved' , Start_Date__c = date.today().addDays(-2) , End_Date__c = date.today().addDays(2));
            SL_TargetedNews objTargetedNews = new SL_TargetedNews();
            Test.startTest();
            objTargetedNews.getNewsMessages();
            Test.stopTest();
        }
        
	}

}