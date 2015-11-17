/**
* \arg ClassName      : SL_Test_ViewAllActivitySubjectLineCtrl
* \arg JIRATicket     : PWP-16
* \arg CreatedOn      : 4/FEB/2015
* \arg LastModifiedOn : 4/FEB/2015
* \arg CreatededBy    : Pradeep 
* \arg ModifiedBy     : Pradeep
* \arg Description    : This class is the controller for SL_ViewAllActivitySubjectLine. 
*/
@isTest()
private  class SL_Test_ViewAllActivitySubjectLineCtrl 
{
	static Account objAccount ;
	static Coverage_Team_Members__c objCTMember ;
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
		
		Apexpages.currentPage().getParameters().put('Id', objAccount.Id);
		objCTMember = new Coverage_Team_Members__c(Company__c = objAccount.Id, PWP_Employee__c = objUser.Id);
		insert objCTMember;
	}
	private static testMethod void viewAllActivitySubjectLine()
	{
		createData();
		System.runAs(objUser) 
		{	
			SL_ViewAllActivitySubjectLineController objViewAllActivity = new SL_ViewAllActivitySubjectLineController();
			objViewAllActivity.cancel();
			system.assertEquals(objViewAllActivity.isNativeSubject, true);
		}
	}
}