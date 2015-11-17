@isTest
private class SL_Test_SearchAccountHierarchy 
{
	private static testMethod void testSearchAccountHierarchy() 
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
        SL_SearchAccountHierarchyCtrl objHomePage1 = new SL_SearchAccountHierarchyCtrl();
        objHomePage1.changedAccountSearchType();
        objHomePage1.strSelectedOption = 'Search by Practice Account';
        objHomePage1.changedAccountSearchType();
        objHomePage1.dummy();
        list<Sobject>  lstSobject = SL_AutoComplete_Controller.findSObjects('Account', objPractice.Id, 'Test');
        
        system.assertEquals(lstSobject.size(), 1);
        
        SL_AccountHierarchy objAccHierarchy = new SL_AccountHierarchy();
        objAccHierarchy.idAccountId = lstSobject[0].Id;
        SL_AccountRecordType__c objCustomSetting = new SL_AccountRecordType__c(Name = 'Parent_Account', Color__c = '#00CC66');
        insert objCustomSetting;
        SL_AccountRecordType__c objCustomSetting1 = new SL_AccountRecordType__c(Name = 'Practice_Account', Color__c = '#CC6600');
        insert objCustomSetting1;
        objAccHierarchy.fetchAccountHierarchy();
        
	}
}