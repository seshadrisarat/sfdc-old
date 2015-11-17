/**  
* \arg ClassName        : SL_Test_NPD_Account_TeamTrigger
* \arg JIRATicket       : NPD-83, NPD-88
* \arg CreatedOn        : 08/26/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Test class for NPD_Account_Team trigger.
*/
@isTest
private class SL_Test_NPD_Account_TeamTrigger{

	private static testMethod void testNPDAccountTeam() {
	    
	    RecordType objRecordType = [SELECT Id FROM RecordType WHERE SObjectType =: 'Account' AND DeveloperName =: 'Practice_Account' LIMIT 1];
	    RecordType objRecordType1 = [SELECT Id FROM RecordType WHERE SObjectType =: 'Account' AND DeveloperName =: 'Parent_Account' LIMIT 1];
	    Account objAccount = new Account(Name = 'Test Account', RecordTypeId = objRecordType.Id, BillingCity = 'London');
        insert objAccount;
        Account objAccount1 = new Account(Name = 'Test Account1', RecordTypeId = objRecordType1.Id, BillingCity = 'London');
        insert objAccount1;
        
        List<NPD_Account_Team__c> lstNPDAccountTeam = new List<NPD_Account_Team__c> {
          new NPD_Account_Team__c(Account__c = objAccount.Id, Team_Member_Status__c = 'Active', 
                                  Parent_Account__c = objAccount1.id,  User__c = Userinfo.getUserId()),
          new NPD_Account_Team__c(Account__c = objAccount.Id, Team_Member_Status__c = 'Active', 
                                  Parent_Account__c = objAccount1.id, User__c = Userinfo.getUserId())
        };
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduse0012144r@testorg12.com');
        insert u;
        System.runAs(u) {
            insert lstNPDAccountTeam;
            System.assertEquals([SELECT Id FROM CollaborationGroupMember].size(), 1);
            System.assertEquals([SELECT Id FROM AccountShare where RowCause =: 'Manual'].size(), 2);
            lstNPDAccountTeam[0].Team_Member_Status__c = 'Inactive';
            update lstNPDAccountTeam;
            delete lstNPDAccountTeam;
        }
	}
}