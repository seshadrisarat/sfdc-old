/**
* \arg ClassName      : SL_Test_ViewAllActivitySubjectLineCtrl
* \arg JIRATicket     : PWP-16
* \arg CreatedOn      : 4/FEB/2015
* \arg LastModifiedOn : 4/FEB/2015
* \arg CreatededBy    : Pradeep 
* \arg ModifiedBy     : Pradeep
* \arg Description    : This class is the controller for SL_ViewAllActivitySubjectLine. 
*/
@isTest(seeAllData = true)
private  class SL_Test_ViewAllActivitySubjectLineCtrl 
{
	static Account objAccount ;
	static AccountTeamMember objAccMember ;
	static User objUser ;
	private static void createData()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        objUser = new User(Alias = 'User1', Email='user1@user.com', 
                                   EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US', ProfileId = p.Id, 
                                   TimeZoneSidKey='America/Los_Angeles', UserName='user123213234423.212@user.com');
        insert objUser;
		objAccount = new Account(Name = 'TestAccount1');
		insert objAccount;
		
		Task tsk1 = new Task(WhatId = objAccount.Id, Subject = 'Email: apex test', ActivityDate = date.today().addDays(2), Status = 'Open');
		Task tsk2 = new Task(WhatId = objAccount.Id, Subject = 'Call: apex test', ActivityDate = date.today(), Status = 'Completed');
		Task tsk3 = new Task(WhatId = objAccount.Id, Subject = 'Email: apex test', ActivityDate = date.today().addYears(-2), Status = 'Completed');
		List<Task> tskList = new List<Task>{ tsk1, tsk2, tsk3 };
		insert tskList;
		
		
		Apexpages.currentPage().getParameters().put('Id', objAccount.Id);
		objAccMember = new AccountTeamMember(AccountId = objAccount.Id, UserId = objUser.Id);
		insert objAccMember;
	}
	private static testMethod void viewAllActivitySubjectLine()
	{
		createData();
		System.runAs(objUser) 
		{	
			SL_ViewAllActivitySubjectLineController objViewAllActivity = new SL_ViewAllActivitySubjectLineController();
			system.assertEquals(objViewAllActivity.isNativeSubject, true);
			// only one open Activity is there
			system.assertEquals(objViewAllActivity.lstOpenActivity.size(), 1);
			system.assertEquals(objViewAllActivity.lstOpenActivity[0].isNativeSubject, true);
			system.assertEquals(objViewAllActivity.lstOpenActivity[0].activity.subject, 'Email: apex test');
			
			// Two Activity Histories are there...
			system.assertEquals(objViewAllActivity.lstActivityHistory.size(), 2);
			system.assertEquals(objViewAllActivity.lstActivityHistory[0].isNativeSubject, true);
			system.assertEquals(objViewAllActivity.lstActivityHistory[0].activity.subject, 'Call: apex test');
			system.assertEquals(objViewAllActivity.lstActivityHistory[1].isNativeSubject, true);
			system.assertEquals(objViewAllActivity.lstActivityHistory[1].activity.subject, 'Email: apex test');
			
			objViewAllActivity.cancel();
		}
	}
}