/*
*   DealApproval_TestDealApprovalLayoutCtrl – This is the test class for DealApprovalLayoutCtrl
*   Author :  Don Koppel 4/15/2014  
*/

@isTest
private class DealApproval_TestDealApprovalLayoutCtrl {

    static testMethod void testDealLayout() {

        DealApproval_TestDataFactory tdf = new DealApproval_TestDataFactory();
        
        Account tenant = tdf.createTestTenant('Tenant 1');
        insert tenant;
  
        RecordType recordTypeLeasingDeal = [SELECT Id, Name, SobjectType 
                                            FROM RecordType 
                                            WHERE SobjectType='Deal__c' 
                                            AND Name = 'Leasing Deal' LIMIT 1  ];   
  
        Deal__c dealOffice = tdf.createTestDeal('Office Test 001', 'New Deal', 'Office', tenant.Id, 0.02, 10000, 'Termsheet', recordTypeLeasingDeal.Id,System.today() );
        insert dealOffice;
  
        RecordType recordTypeRent = [SELECT Id, Name, SobjectType 
                                            FROM RecordType 
                                            WHERE SobjectType='Deal_Rent__c' 
                                            AND Name = 'Rent' LIMIT 1  ];   
  
        RecordType recordTypeRentInrease = [SELECT Id, Name, SobjectType 
                                            FROM RecordType 
                                            WHERE SobjectType='Deal_Rent__c' 
                                            AND Name = 'Rent Increase' LIMIT 1  ];      

        Test.startTest();

        PageReference pageRef = Page.DealApproval;
        Test.setCurrentPageReference(pageRef);      
        DealApprovalCtrl dealPageController = new DealApprovalCtrl();
        ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');
        
        dealPageController.dealId = dealOffice.Id;
        dealPageController.getIsOfficeDealSheet();

        //PageReference pageRef = Page.DealApproval;
        //Test.setCurrentPageReference(pageRef);        
        DealApprovalLayoutCtrl controller = new DealApprovalLayoutCtrl();
        controller.parentSObjectId = dealOffice.Id;

        controller.getdealForApproval();
        controller.getRentRecords();
        controller.getOptionRentRecords();
        controller.getdealContact();
        controller.getdealContactTen();
        controller.getdealContactBro();
        controller.getdealApproval();
        controller.GetDealProperty();

        List<Deal_Rent__c> rentRowList = new List<Deal_Rent__c>();
        Deal_Rent__c dealRentRow = tdf.createTestDealRent(dealOffice, false, 1000.0, '', recordTypeRent.Id);
        rentRowList.add(dealRentRow);
        dealRentRow = tdf.createTestDealRent(dealOffice, true, 1000.0, '', recordTypeRent.Id);
        rentRowList.add(dealRentRow);
        dealRentRow = tdf.createTestDealRent(dealOffice, false, 0.0, '% Increase', recordTypeRentInrease.Id);
        rentRowList.add(dealRentRow);
        dealRentRow = tdf.createTestDealRent(dealOffice, true, 0.0, '% Increase', recordTypeRentInrease.Id);
        rentRowList.add(dealRentRow);
        insert rentRowList;

        dealRentRow = controller.rentFirstRecord;
        dealRentRow = controller.rentIncreaseFirstRecord;
        dealRentRow = controller.optionRentFirstRecord;
        dealRentRow = controller.optionRentIncreaseFirstRecord;

        controller.getRentRecords();
        controller.getOptionRentRecords();
        controller.getdealForApproval();

        dealRentRow = controller.rentFirstRecord;
        dealRentRow = controller.rentIncreaseFirstRecord;
        dealRentRow = controller.optionRentFirstRecord;
        dealRentRow = controller.optionRentIncreaseFirstRecord;
        
        Integer initTerm = controller.initialTerm;
        Integer initOptionTerm = controller.initialTermOption;
        Decimal naturalBreak = controller.rentDetails[0].naturalbreak;
        Decimal psfAmt = controller.rentDetails[0].psfAmt;

        Test.stopTest();
    }
}