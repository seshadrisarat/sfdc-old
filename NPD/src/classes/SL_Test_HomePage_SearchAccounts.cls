/**
    * \arg ClassName      : SL_Test_HomePage_SearchAccounts
    * \arg JIRATicket     : NPD-86
    * \arg CreatedOn      : 3/August/2015
    * \arg LastModifiedOn : 
    * \arg CreatededBy    : Sandeep
    * \arg ModifiedBy     : 
    * \arg Description    : This is Test class for SL_HomePage_SearchAccounts_Ctrl controller.
*/
@isTest
private class SL_Test_HomePage_SearchAccounts 
{
	private static testMethod void test_HomePage_SearchAccounts() 
	{
        List<RecordType> lstRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Parent_Account'];
	    Practice__c objPractice = new Practice__c(Name = 'Test Practice');
	    insert objPractice;
	    Practice_Team_Members__c objTeamMember = new Practice_Team_Members__c(Practice__c = objPractice.Id, User__c = UserInfo.getUserId());
	    insert objTeamMember;
        Account objAccount = new Account (Practice__c = objPractice.Id, Name = 'Test Account 1', recordTypeId = lstRecordType[0].Id, BillingCountry = 'INDIA');
        insert objAccount;
        Contact objContact = new Contact (LastName = 'Test Contact', AccountId = objAccount.Id);
        insert objContact;
        
        SL_HomePage_SearchAccounts_Ctrl objHomePage = new SL_HomePage_SearchAccounts_Ctrl();
        objTeamMember.User__c = null;
        update objTeamMember;
        SL_HomePage_SearchAccounts_Ctrl objHomePage1 = new SL_HomePage_SearchAccounts_Ctrl();
        objHomePage1.changedAccountSearchType();
        objHomePage1.strSelectedOption = 'Search by Practice Account';
        objHomePage1.changedAccountSearchType();
        objHomePage1.dummy();
        list<Sobject>  lstSobject = SL_AutoComplete_Controller.findSObjects('Account', objPractice.Id, 'Test');
        system.assertEquals(lstSobject.size(), 1);
	}
}