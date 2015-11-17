/****************************************************************************************
Name            : SL_Test_PropBuilderFeeViewContoller
Author          : Julia Kolesnik
Created Date    : March 12, 2014
See				: https://silverline.jira.com/browse/SLFF-33
Description     : Test for SL_PropBuilderFeeViewContoller.cls
******************************************************************************************/
@isTest(SeeAllData=true)
private class SL_Test_PropBuilderFeeViewContoller {

    static testMethod void myUnitTest() {
        createData();
        
        Test.startTest();
        PageReference pageRef = Page.SL_PropBuilderFeeView;
		PageRef.getParameters().put('oppty',pOpportunity.id);
		Test.setCurrentPage(pageRef);
		SL_PropBuilderFeeViewContoller controller = new SL_PropBuilderFeeViewContoller();
		controller.init();
		SL_PropBuilderFeeViewContoller.updateOliDesc(oProduct2.Id,'test val',pOpportunity.id);
		SL_PropBuilderFeeViewContoller.updateDiscountAmnt(pOpportunityLineItem.Id,pOpportunity.id,20.5);
        Test.stopTest();
        
    }
    
    private static void createData() {
		if (region.Id==null) {
			insert region;
			insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Region__c=region.Id, pse__Resource_Request_Entry__c=true, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c = true);
		}
		insert pOpportunity;
		insert pOpportunityLineItem;
	}
    
    private static Opportunity pOpportunity {
		get {
			if ( pOpportunity == null ) {
				pOpportunity = new Opportunity(
					Name = 'Test Opportunity',
					StageName = 'Qualified Suspect',
					pse__Region__c = region.Id,
					CloseDate = Date.today(),
					Projected_Start_Date__c = Date.today().addDays( 20 ),
					RecordTypeId = psaUtils.idRTOpportunityServices
				);
			}
			return pOpportunity;
		} set;
	}

	private static OpportunityLineItem pOpportunityLineItem {
		get {
			if ( pOpportunityLineItem == null ) {

				PricebookEntry oPricebookEntry = new PricebookEntry (
					Product2Id = oProduct2.id,
					Pricebook2Id = Test.getStandardPricebookId(),
					UnitPrice = 3,
					isActive = true
				);
				insert oPricebookEntry;

				pOpportunityLineItem = new OpportunityLineItem(
					OpportunityId = pOpportunity.Id,
					UnitPrice = 1,
					Quantity = 2,
					ServiceDate = Date.today(),
					PricebookEntryId = oPricebookEntry.Id
				);
			}
			return pOpportunityLineItem;
		} set;
	}
	
	private static Product2 oProduct2 {
		get {
			if ( oProduct2 == null ) {
				oProduct2 = new Product2(
					Name = 'Discount',
					Description = 'Test Product Entry',
					isActive = true
				);
				insert oProduct2;
			}
			return oProduct2;
		} set;
	}
	
	private static pse__Region__c region {
		get {
			if ( region == null ) {
				for (pse__Region__c item:[SELECT Id FROM pse__Region__c WHERE Name = 'All Silverline']) {
					region = item;
				}
				if (region==null) {
					region = new pse__Region__c(Name = 'All Silverline', pse__Action_Update_Current_Time_Period__c=false, pse__Current_Time_Period__c = null);
				}
			}
			return region;
		} set;
	}
}