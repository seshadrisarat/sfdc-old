/**  
* \arg ClassName        : SL_OpportunityContactRoleCtrl
* \arg JIRATicket       : NPD-120
* \arg CreatedOn        : 14/Sep/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sanath
* \arg ModifiedBy       : 
* \arg Description      : 
*/
@isTest
private class SL_Test_OpportunityContactRoleCtrl 
{
	private static testMethod void test() 
	{
	    Practice__c objPractice = new Practice__c(Name = 'Test Practice');
        insert objPractice;
        
	    RecordType objRecordType = [SELECT Id FROM RecordType WHERE SObjectType =: 'Account' AND DeveloperName =: 'Practice_Account' LIMIT 1];
	    RecordType objRecordType1 = [SELECT Id FROM RecordType WHERE SObjectType =: 'Account' AND DeveloperName =: 'Parent_Account' LIMIT 1];
	    
        Account objAccount = new Account(Name = 'Test Account', RecordTypeId = objRecordType.Id, BillingCity = 'London');
        insert objAccount;
        Account objAccount1 = new Account(Name = 'Test Account1', Practice__c = objPractice.Id, ParentId = objAccount.Id, RecordTypeId = objRecordType1.Id, BillingCity = 'London');
        insert objAccount1;
        
        Contact objContact = new Contact(LastName = 'Test Contact', AccountId = objAccount1.Id);
        insert objContact;
        
        Opportunity objOpportunity = new Opportunity(Name = 'Test Opp1', AccountId = objAccount1.Id, StageName = 'No Contact',
                                                            Amount = 3000, Billing_Details__c = 'London', Billing_Contact_Info_Address__c = 'London',
                                                            CloseDate = System.today());
        insert objOpportunity;
        PageReference pageRef = Page.SL_OpportunityContactRole;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppId', objOpportunity.Id);
        
        SL_OpportunityContactRoleCtrl objCtrl = new SL_OpportunityContactRoleCtrl();
        objCtrl.lstOppContactRole.add(new OpportunityContactRole(ContactId = objContact.Id, OpportunityId = objOpportunity.Id, IsPrimary = true, Role = 'Billing and Shipping Contact'));
        system.assertEquals(objCtrl.lstOppContactRole.size(),11);
        objCtrl.save();
        objCtrl.cancel();
	}
}