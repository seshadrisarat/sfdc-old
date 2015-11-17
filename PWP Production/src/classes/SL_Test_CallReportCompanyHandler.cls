/**
* \arg ClassName      : SL_Test_CallReportCompanyHandler
* \arg JIRATicket     : PWP-9,PWP-19
* \arg CreatedOn      : 7/JAN/2015
* \arg LastModifiedOn : 2/MAR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is the Test class for SL_CallReportHandler
*/
@isTest
private class SL_Test_CallReportCompanyHandler 
{
	static List<Coverage_Team_Members__c> lstCoverageTeamMembers;
	static List<Account> lstAccount;
	static List<Call_Report_Company__c> lstCRC;
	static List<Call_Report__c> lstCR;
	static List<User> lstUser;
    //calling method to prepare data
    private static void createData() 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		lstUser = new List<User> {
									new User(Alias = 'User111', Email='user1@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = p.Id, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='user1kj1kj.212@user.com'),
									new User(Alias = 'User211', Email='user2@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = p.Id, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='userj11kj.464.2@user.com'),
			                        new User(Alias = 'User211', Email='user2@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Tes11ting2', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='userj11kj.4641.2@user.com')
								};
    	insert lstUser;
    	
    	lstAccount = new List<Account>{
	    								new Account(Name = 'Account1'),
	    								new Account(Name = 'Account2')
    								  };
    	insert lstAccount;
    	
    	lstCR = new List<Call_Report__c>{
    										new Call_Report__c(Name = 'Test Call Report1', Reference_Account__c = lstAccount[0].Id),
    										new Call_Report__c(Name = 'Test Call Report2', Reference_Account__c = lstAccount[0].Id),
    										new Call_Report__c(Name = 'Test Call Report3', Reference_Account__c = lstAccount[1].Id),
    										new Call_Report__c(Name = 'Test Call Report4', Reference_Account__c = lstAccount[1].Id)		
    									};
    	insert lstCR;
    	
    	lstCRC = new List<Call_Report_Company__c>{
    												 new Call_Report_Company__c(Call_Report__c = lstCR[0].Id, Relevant_Company__c = lstAccount[0].Id),
    												 new Call_Report_Company__c(Call_Report__c = lstCR[1].Id, Relevant_Company__c = lstAccount[1].Id),
    												 new Call_Report_Company__c(Call_Report__c = lstCR[2].Id, Relevant_Company__c = lstAccount[0].Id),
    												 new Call_Report_Company__c(Call_Report__c = lstCR[3].Id, Relevant_Company__c = lstAccount[1].Id)
    											 };
    	insert lstCRC;
    	
    	lstCoverageTeamMembers = new List<Coverage_Team_Members__c>
    							{
	    								new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[0].Id),
	    								new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[1].Id),
	    								new Coverage_Team_Members__c(Company__c = lstAccount[1].Id, PWP_Employee__c = lstUser[0].Id),
	    								new Coverage_Team_Members__c(Company__c = lstAccount[1].Id, PWP_Employee__c = lstUser[1].Id)
    							};
    	insert lstCoverageTeamMembers;
    }
    
    static testmethod void checkForInsert()
    {
    	createData();
    }
    
    static testMethod void checkForUpdate()
    {
    	createData();
    	lstCRC[0].Relevant_Company__c = lstAccount[1].Id;
    	
    	Test.startTest();
    	update lstCRC[0];
    	Test.stopTest();
    }
    
    static testMethod void checkForDelete()
    {
    	createData();
    	
    	Test.startTest();
    	delete lstCRC[0];
    	Test.stopTest();
    }
    
    static testmethod void checkForUndelete()
    {
    	createData();
    	delete lstCRC[1];
    	
    	Test.startTest();
    	undelete lstCRC[1];
    	Test.stopTest();
    }
    
    static testMethod void checkForOwnerChange()
    {
    	createData();
    	lstCR[1].OwnerId = lstUser[2].Id;
    	
    	Test.startTest();
    	update lstCR[1];
    	Test.stopTest();
    	
    	System.assertEquals(2,[select count() from Call_Report__Share where ParentId =:lstCR[1].Id AND RowCause =:'Manual']);
    }
}