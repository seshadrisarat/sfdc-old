/*
*   DealApproval_TestDealApprovalCtrl – This is the test class for DealApprovalLayoutCtrl
*   Author :  Don Koppel 4/15/2014  
*/

@isTest
private class DealApproval_TestDealApprovalCtrl {

    static testMethod void testDealApprovalOfficeLeasing() {
        
        DealApproval_TestDataFactory tdf = new DealApproval_TestDataFactory();
        
        Account tenant = tdf.createTestTenant('Tenant 1');
        insert tenant;
  
        RecordType recordTypeLeasingDeal = [SELECT Id, Name, SobjectType 
                                            FROM RecordType 
                                            WHERE SobjectType='Deal__c' 
                                            AND Name = 'Leasing Deal' LIMIT 1  ];   
  
        Deal__c dealOffice = tdf.createTestDeal('Office Test 001', 'New Deal', 'Office', tenant.Id, 0.02, 10000, 'Termsheet', recordTypeLeasingDeal.Id,system.today() );
        insert dealOffice;
        Deal__c dealRetail = tdf.createTestDeal('Office Test 001', 'New Deal', 'Mall', tenant.Id, 0.02, 10000, 'Termsheet', recordTypeLeasingDeal.Id,system.today() );
        insert dealRetail;
        Deal__c dealAmendment = tdf.createTestDeal('Office Test 001', 'Renewal', 'Mall', tenant.Id, 0.02, 10000, 'Termsheet', recordTypeLeasingDeal.Id ,system.today());
        insert dealAmendment;
        Deal__c dealMemo = tdf.createTestDeal('Office Test 001', 'Deal Memo', 'License Agreement', tenant.Id, 0.02, 10000, 'Termsheet', recordTypeLeasingDeal.Id ,system.today());
        insert dealMemo;
        
        Test.startTest();

        PageReference pageRef = Page.DealApproval;
        Test.setCurrentPageReference(pageRef);      
        DealApprovalCtrl controller = new DealApprovalCtrl();
        ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');
        
        controller.dealId = dealOffice.Id;
        controller.getIsOfficeDealSheet();

        //Create custom setting value
        Id userId = UserInfo.getUserId();
        insert new Deal_Approval_Last_Viewed__c(SetupOwnerId = userId, Deal_Id__c = dealOffice.Id);

        controller.getSelectedDeal();
        DealApprovalCtrl.getPreviouslyViewedId();
        DealApprovalCtrl.setPreviouslyViewedId(dealOffice.Id);

        //test conditions where dealId = null
        controller.dealId = null;
        controller.getIsLeasingDealSheet();
        controller.getIsOfficeDealSheet();
        controller.getisLeasingAmendmentDealSheet();
        controller.getisDealMemoSheet();

        controller.dealId = dealRetail.Id;
        controller.getIsLeasingDealSheet();

        controller.dealId = dealAmendment.Id;
        controller.getisLeasingAmendmentDealSheet();

        controller.dealId = dealMemo.Id;
        controller.getisDealMemoSheet();
        
        //test conditions where dealId is of a different type
        controller.getIsLeasingDealSheet();
        controller.getIsOfficeDealSheet();
        controller.getisLeasingAmendmentDealSheet();

        controller.dealId = dealAmendment.Id;
        controller.getisDealMemoSheet();

        // Create an approval request for the deal     
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(dealOffice.Id);
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Submit the approval request for the deal  
        Approval.ProcessResult result1 = Approval.process(req1);      

        // Verify the results  
        System.assert(result1.isSuccess());
        System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status'+result1.getInstanceStatus());

        DealApprovalCtrl.ApproveItems(dealOffice.Id, 'comments', 'Approve');
        
        DealApprovalCtrl.getApprovalPending('All');
        DealApprovalCtrl.getApprovalPending('Office');
        DealApprovalCtrl.getApprovalPending('Retail');
        DealApprovalCtrl.getApprovedRejected('All');
        DealApprovalCtrl.getApprovedRejected('Office');
        DealApprovalCtrl.getApprovedRejected('Retail');

        Test.stopTest();
    }
}