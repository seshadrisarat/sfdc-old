/**
 * \author Vladimir Dobrelya
 * \date Mar 5, 2014
 * \see https://silverline.jira.com/browse/SLFF-33
 * \brief The test class for SL_OpptyComponentFeatureHandler
 */
@isTest
private class SL_test_OpptyComponentFeatureHandler {
	
	@isTest(seeAllData=true) static void test_insert() {
		createData();

		Test.startTest();
			//insert pOpportunityComponentFeature;
		Test.stopTest();
	}

	@isTest(seeAllData=true) static void test_delete() {
		createData();
		//insert pOpportunityComponentFeature;

		Test.startTest();
			//delete pOpportunityComponentFeature;
		Test.stopTest();
	}

	@isTest(seeAllData=true) static void test_update() {
		createData();
		//insert pOpportunityComponentFeature;

		Test.startTest();
			//update pOpportunityComponentFeature;
		Test.stopTest();
	}
	
	static void createData() {
		insert pProduct;
		insert pPricebookEntry;
		insert pAccount;
		insert pOpportunity;
		insert pOpportunityLineItem;
		insert pOpportunityComponent;
	}

	static Opportunity pOpportunity {
		get {
			if ( pOpportunity == null ) {
				pOpportunity = new Opportunity(
					Name = 'TEST_pOpportunity',
					StageName = 'Qualified Suspect',
					CloseDate = Date.today().addDays( 1 ),
					Projected_Start_Date__c = date.today().addDays(20),
					AccountId = pAccount.Id,
					Type = 'Existing Business',
					Project_Level__c = 'L0',
					CurrencyIsoCode = 'USD',
					Billing_Type__c = 'T&M',
					pse__Region__c = SL_Settings.idRegionAllSilveline
				);
			}
			return pOpportunity;
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

	static Opportunity_Component__c pOpportunityComponent {
		get {
			if ( pOpportunityComponent == null ) {
				pOpportunityComponent = new Opportunity_Component__c(
					Opportunity__c = pOpportunity.Id,
					Product__c = pProduct.Id
				);
			}
			return pOpportunityComponent;
		} private set;
	}

	static Opportunity_Component_Feature__c pOpportunityComponentFeature {
		get {
			if ( pOpportunityComponentFeature == null ) {
				pOpportunityComponentFeature = new Opportunity_Component_Feature__c(
					Product__c = pProduct.Id,
					Description__c = 'TEST_pOpportunityComponentFeature Description',
					Opportunity_Component__c = pOpportunityComponent.Id,
					EM__c = 1,
					TA__c = 1,
					SA__c = 1,
					SME__c = 1,
					BA__c = 1,
					DMS__c = 1,
					DIS__c = 1,
					Partner__c = 1,
					Dev__c = 1,
					DevMgmt__c = 1,
					Offshore_Dev__c = 1, 
					OLI__c = 'OLI'
				);
			}
			return pOpportunityComponentFeature;
		} private set;
	}

	static OpportunityLineItem pOpportunityLineItem {
		get {
			if ( pOpportunityLineItem == null ) {
				pOpportunityLineItem = new OpportunityLineItem(
					OpportunityId = pOpportunity.Id,
					PricebookEntryId = pPricebookEntry.Id,
					Quantity = 1,
					UnitPrice = 10
				);
			}
			return pOpportunityLineItem;
		}
	}

	static Product2 pProduct {
		get {
			if ( pProduct == null ) {
				pProduct = new Product2(
					Name = 'TEST_pProduct',
					ProductCode = 'TST_PC',
					CurrencyIsoCode = 'USD',
					Description = 'TEST_pProduct Description',
					Family = 'Testing',
					IsActive = true
				);
			}
			return pProduct;
		} private set;
	}

	static PricebookEntry pPricebookEntry {
		get {
			if ( pPricebookEntry == null ) {
				pPricebookEntry = new PricebookEntry(
					UnitPrice = 10,
					Product2Id = pProduct.Id,
					Pricebook2Id = [ SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' AND IsActive = true limit 1 ].Id,
					IsActive = true
				);
			}
			return pPricebookEntry;
		} private set;
	}
}