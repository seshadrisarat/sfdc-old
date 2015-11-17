/**  
* \arg ClassName        : SL_AccountTriggerHandler
* \arg JIRATicket       : NPD-84, NPD-88
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Test class for Account trigger.
*/
@isTest
private class SL_TestAccountHandler 
{
	private static testMethod void testAccountShareAndGroupCreate() 
	{
	    List<RecordType> lstRecordTypeParentAccount = [SELECT Id FROM RecordType WHERE SobjectType =:'Account' AND DeveloperName =:'Parent_Account'];
	    List<RecordType> lstRecordTypePracticeAccount = [SELECT Id FROM RecordType WHERE SobjectType =:'Account' AND DeveloperName =:'Practice_Account'];
        Account objAccount = new Account(Name = 'Test Account 0', RecordTypeId = lstRecordTypeParentAccount[0].Id, BillingCountry = 'INDIA');
        insert objAccount;
        
        List<Account> lstAccount = new List<Account>{
            new Account( Name = 'Test Account 1', RecordTypeId = lstRecordTypeParentAccount[0].Id, BillingCountry = 'INDIA'),
            new Account( Name = 'Test Account 2', RecordTypeId = lstRecordTypePracticeAccount[0].Id, ParentId = objAccount.Id, BillingCountry = 'INDIA')
        };
        insert lstAccount;
        system.assertEquals([SELECT Id, Name FROM GROUP WHERE Name =: 'Test Account 1'].Name, 'Test Account 1');
        system.assertEquals([SELECT Id, Name FROM GROUP WHERE Name =: 'Test Account 0'].Name, 'Test Account 0');
        System.assertEquals([SELECT Id FROM AccountShare where RowCause =: 'Manual'].size(), 3);
        system.assertEquals([SELECT Id, Name FROM CollaborationGroup WHERE Name =: 'Test Account 0'+' NPD Team'].Name, 'Test Account 0 NPD Team');
	}
}