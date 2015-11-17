@isTest
private class psaBillingAdjustmentControllerTest {
	@isTest(seeAllData=true) static void test_method_one() {
		createData();
		ApexPages.currentPage().getParameters().put( 'beID', pBillingEvent.Id );

		psaBillingAdjustmentController oController = new psaBillingAdjustmentController();

		system.assertEquals( null, getMiscellaneousAdjustment() );
		system.assertEquals( null, getBillingEventItem() );

		Test.startTest();
			oController.ma.pse__Effective_Date__c = Date.today();
			oController.ma.pse__Amount__c = 100;
			oController.ma.pse__Description__c = 'Credit Adjustment';
			oController.ma.pse__Status__c = 'Approved';
			oController.ma.pse__Approved__c = true;
			oController.ma.pse__Include_In_Financials__c = true;
			oController.ma.pse__Billed__c = true;
			oController.ma.pse__Project__c = pProject.Id;
			//oController.save();
			psaBillingAdjustmentController.recalcBillingEventSummaryAmount( pBillingEvent.Id );
		Test.stopTest();

		doAsserts( getBillingEventItem(), getMiscellaneousAdjustment() );
	}
	
	static void createData() {
		//insert usdCurrency;
		//insert currencyRate;
		insert pAccount;
		insert pProject;
		insert pProjectPermissionControl;
		insert pBillingEventBatch;
		insert pBillingEvent;
	}

	static void doAsserts( pse__Billing_Event_Item__c oBillingEventItem, pse__Miscellaneous_Adjustment__c oMilestoneAdjustment ) {
		
		/*system.assertNotEquals( null, oBillingEventItem );
		system.assertNotEquals( null, oMilestoneAdjustment );
		system.assertEquals( oBillingEventItem.pse__Miscellaneous_Adjustment__c, oMilestoneAdjustment.Id );
		system.assertEquals( oBillingEventItem.pse__Billing_Event_Batch__c, pBillingEvent.pse__Billing_Event_Batch__c );
		system.assertEquals( oBillingEventItem.pse__Category__c, 'Miscellaneous Adjustment' );
		system.assertEquals( oBillingEventItem.pse__Description__c, oMilestoneAdjustment.pse__Description__c );
		system.assertEquals( oBillingEventItem.pse__Amount__c, oMilestoneAdjustment.pse__Amount__c );
		system.assertEquals( oBillingEventItem.pse__Unit_Price__c, oMilestoneAdjustment.pse__Amount__c );
		system.assertEquals( oBillingEventItem.pse__Quantity__c, 1 );
		system.assertEquals( oBillingEventItem.pse__Project__c, pProject.Id );
		system.assertEquals( oBillingEventItem.pse__Date__c, oMilestoneAdjustment.pse__Effective_Date__c );*/
	}


	static pse__Miscellaneous_Adjustment__c getMiscellaneousAdjustment() {
		pse__Miscellaneous_Adjustment__c oResult;
		
		for ( pse__Miscellaneous_Adjustment__c oItem : [ SELECT Id, pse__Description__c , pse__Amount__c, pse__Effective_Date__c
						FROM pse__Miscellaneous_Adjustment__c WHERE pse__Project__c = :pProject.Id limit 1 ] ) {
			oResult = oItem;
		}

		return oResult;
	}

	static pse__Billing_Event_Item__c getBillingEventItem() {
		pse__Billing_Event_Item__c oResult;

		for ( pse__Billing_Event_Item__c oItem : [
			SELECT pse__Object_Id__c, pse__Miscellaneous_Adjustment__c, pse__Billing_Event_Batch__c, pse__Category__c,
				 pse__Description__c, pse__Amount__c, pse__Unit_Price__c, pse__Quantity__c, pse__Project__c, pse__Date__c
			FROM pse__Billing_Event_Item__c
			WHERE pse__Billing_Event__c = :pBillingEvent.Id limit 1
		] ) {
			oResult = oItem;
		}

		return oResult;
	}
	/*pse__Object_Id__c = saveResult.getId(); 
        bEventItem.pse__Miscellaneous_Adjustment__c = saveResult.getId(); 
        bEventItem.pse__Billing_Event__c = bEvent.Id; 
        bEventItem.pse__Billing_Event_Batch__c = bEvent.pse__Billing_Event_Batch__c; 
        bEventItem.pse__Category__c = 'Miscellaneous Adjustment'; 
        bEventItem.pse__Description__c = ma.pse__Description__c; 
        bEventItem.pse__Amount__c = ma.pse__Amount__c; 
        bEventItem.pse__Unit_Price__c = ma.pse__Amount__c; 
        bEventItem.pse__Quantity__c = 1; 
        bEventItem.pse__Project__c = bEvent.pse__Project__c; 
        bEventItem.pse__Date__c*/

	static ID pRTBillingAdjustmentId {
		get {
			if ( pRTBillingAdjustmentId == null ) {
				for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'pse__Miscellaneous_Adjustment__c' AND DeveloperName = 'Billing_Adjustment' limit 1 ] ) {
					pRTBillingAdjustmentId = oItem.Id;
				}
				system.assertNotEquals( null, pRTBillingAdjustmentId, 'Couldn\'t find Billing_Adjustment record type.' );
			}
			return pRTBillingAdjustmentId;
		}
	}

	static pse__Proj__c pProject {
        get {
            if ( pProject == null ) {
                pProject = new pse__Proj__c(
                    Name = 'Test_pProject',
                    pse__Region__c = SL_Settings.idRegionAllSilveline,
                    CurrencyIsoCode = 'USD',
                    pse__Is_Active__c = true
                );
            }
            return pProject;
        } set;
    }

	static pse__Billing_Event__c pBillingEvent {
		get {
			if ( pBillingEvent == null ) {
				pBillingEvent = new pse__Billing_Event__c(
					pse__Project__c = pProject.Id,
					pse__Date__c = Date.today(),
					pse__Billing_Event_Batch__c = pBillingEventBatch.Id,
					CurrencyIsoCode = 'USD',
					pse__Is_Released__c = true
				);
			}
			return pBillingEvent;
		} private set;
	}

	static pse__Billing_Event_Batch__c pBillingEventBatch {
		get {
			if ( pBillingEventBatch == null ) {
				pBillingEventBatch = new pse__Billing_Event_Batch__c(
					pse__Account__c = pAccount.Id
				);
			}
			return pBillingEventBatch;
		} private set;
	}

	static Account pAccount {
		get {
			if ( pAccount == null ) {
				pAccount = new Account(
					Name = 'TEST_pAccount'
				);
			}
			return pAccount;
		} private set;
	}

	private static Contact pContact {
        get {
            if ( pContact == null ) {
                pContact = new Contact(
                    LastName = 'TEST_pContact',
                    pse__Is_Resource_Active__c = true,
                    pse__Is_Resource__c = true,
                    pse__Resource_Role__c = 'Developer',
                    AccountId = pAccount.Id
                );
                insert pContact;
            }
            return pContact;
        }
    }

    private static pse__Permission_Control__c pContactPermissionControl {
        get {
            if ( pContactPermissionControl == null ) {
                pContactPermissionControl = new pse__Permission_Control__c(
                    pse__User__c = UserInfo.getUserId(),
                    pse__Resource__c = pContact.Id,
                    pse__Billing__c = true,
                    pse__Timecard_Entry__c = true,
                    pse__Timecard_Ops_Edit__c = true,
                    pse__Staffing__c = true,
                    pse__Resource_Request_Entry__c = true,
                    pse__Skills_And_Certifications_View__c = true,
                    pse__Skills_And_Certifications_Entry__c = true,
                    pse__Forecast_View__c = true,
                    pse__Forecast_Edit__c = true,
                    pse__View_Task_Manager__c = true,
                    pse__Expense_Entry__c = true,
                    pse__Expense_Ops_Edit__c = true,
                    pse__Invoicing__c = true,
                    pse__Cascading_Permission__c = true
                );
            }
            return pContactPermissionControl;
        } set;
    }

	private static pse__Permission_Control__c pProjectPermissionControl {
        get {
            if ( pProjectPermissionControl == null ) {
                pProjectPermissionControl = new pse__Permission_Control__c(
                    pse__User__c = UserInfo.getUserId(),
                    pse__Project__c = pProject.Id,
                    pse__Billing__c = true,
                    pse__Timecard_Entry__c = true,
                    pse__Timecard_Ops_Edit__c = true,
                    pse__Staffing__c = true,
                    pse__Resource_Request_Entry__c = true,
                    pse__Skills_And_Certifications_View__c = true,
                    pse__Skills_And_Certifications_Entry__c = true,
                    pse__Forecast_View__c = true,
                    pse__Forecast_Edit__c = true,
                    pse__View_Task_Manager__c = true,
                    pse__Expense_Entry__c = true,
                    pse__Expense_Ops_Edit__c = true,
                    pse__Invoicing__c = true,
                    pse__Cascading_Permission__c = true
                );
            }
            return pProjectPermissionControl;
        } set;
    }
    
    /*private static appirio_core__Currency__c usdCurrency {
        get {
            if ( usdCurrency == null ) {
                usdCurrency = new appirio_core__Currency__c(
                    appirio_core__Currency_Code__c = 'USD',
                    appirio_core__Is_Corporate_Currency__c = true
                );
            }
            return usdCurrency;
        }
    }
    
    private static appirio_core__Currency_Exchange_Rate__c currencyRate {
        get {
            if ( currencyRate == null ) {
                currencyRate = new appirio_core__Currency_Exchange_Rate__c(
                    appirio_core__Currency__c = usdCurrency.Id,
                    appirio_core__Effective_Date__c = date.today().adddays(-100),
                    appirio_core__Rate__c = 1
                );
            }
            return currencyRate;
        }
    }*/
}