@isTest
private class SL_Test_LeadConvertOverRide_Controller {

    private static final Id PARENT_ACCOUNT_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent Account').getRecordTypeId();

	private static testMethod void test_OverrideLeadConvert() 
	{
        PageReference pageRef = Page.SL_LeadConvertOverRide;
        Test.setCurrentPage(pageRef);
        
        Lead objLead = new Lead(LeadBU__c = 'Canada RBG' , Company='Test 1' , 
                                LastName='Lead 1' , Email='sanath.kumar@silverlinecrm.com' , 
                                Status='New Leads - Not yet working' , Lead_Type__c='Other' , 
                                LeadSource='Advertisement');
        insert objLead;
        
        Account objAccount = new Account(Name='Test Account' , AccountBU__c='Canada RBG' , 
                                        AccountClass__c='Other' , Industry='Finance' , 
                                        Type='Other', BillingCity='NY', RecordTypeId=PARENT_ACCOUNT_ID);
        insert objAccount;
        
        Test.startTest();
            
            ApexPages.StandardController objStdCont = new ApexPages.StandardController(objLead);
            SL_LeadConvertOverRide_Controller objController = new SL_LeadConvertOverRide_Controller(objStdCont);
            objController.idSelectedId = objAccount.Id;
            
            objController.reDirectToLeadConvertWithAccount();
            objController.reDirectToLeadConvertWithoutAccount();
            objController.navigateToAccount();
            
            system.assert(objController.idLeadId != null);
            system.assertEquals(URL.getSalesforceBaseUrl().toExternalForm() + '/' + objAccount.Id , objController.strURLtoRedirect);
            
        Test.stopTest();
	}

}