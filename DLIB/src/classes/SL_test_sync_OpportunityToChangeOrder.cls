/**
 * \author Vladimir Dobrelya
 * \date Feb 19, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
@isTest
public class SL_test_sync_OpportunityToChangeOrder {

	@isTest static void test_insert() {
		createData();
		doAsserts( pOpportunity, getChangeOrder() );
	}

	@isTest static void test_update() {
		createData();

		Test.startTest();
			pOpportunity.Name += '-CHANGED';
			pOpportunity.AccountId = pAnotherAccount.Id;
			pOpportunity.Billing_Notes__c += '-CHANGED';
			pOpportunity.Billing_Type__c = 'Fixed Fee';
			pOpportunity.StageName = 'Proposal Requested';
			pOpportunity.CloseDate = Date.today().addDays( 2 );
			pOpportunity.Projected_Start_Date__c = date.today().addDays(20);
			pOpportunity.Changes_to_Scope_Deliverables__c += '-CHANGED';
			update pOpportunity;
		Test.stopTest();

		doAsserts( pOpportunity, getChangeOrder() );
	}

	@isTest static void test_delete() {
		createData();

		Test.startTest();
			delete pOpportunity;
		Test.stopTest();

		system.assertEquals( null, getChangeOrder() );
	}

	@isTest static void test_undelete() {
		createData();
		delete pOpportunity;

		system.assertEquals( null, getChangeOrder() );

		Test.startTest();
			undelete pOpportunity;
		Test.stopTest();

		system.assertNotEquals( null, getChangeOrder() );
	}


	public static void doAsserts( Opportunity oOpp, Change_Order__c oChangeOrder ) {
		system.assertNotEquals( null, oChangeOrder );

		system.assertEquals( oOpp.Id, oChangeOrder.Change_Order_Opportunity__c );
		system.assertEquals( oOpp.Project_Change_Order__c, oChangeOrder.Id );

		system.assertEquals( oOpp.Name, oChangeOrder.Name );
		system.assertEquals( oOpp.AccountId, oChangeOrder.Account__c );
		system.assertEquals( oOpp.Billing_Notes__c, oChangeOrder.Billing_Notes__c );
		system.assertEquals( oOpp.Billing_Type__c, oChangeOrder.Billing_Type__c );
		system.assertEquals( oOpp.StageName, oChangeOrder.Stage__c );
		system.assertEquals( oOpp.CloseDate, oChangeOrder.Close_Date__c );
		system.assertEquals( oOpp.Changes_to_Scope_Deliverables__c, oChangeOrder.Changes_to_Scope_Deliverables__c );
	}

	public static void createData() {
		insert pProject;
		insert pOpportunity;
		refreshData();
	}

	private static void refreshData() {
		pOpportunity = [
			SELECT Id, Name, AccountId, Billing_Notes__c, Billing_Type__c, StageName, CloseDate,
				Project_Change_Order__c, Changes_to_Scope_Deliverables__c
			FROM Opportunity
			WHERE Id = :pOpportunity.Id
		];
	}

	public static Change_Order__c getChangeOrder() {
		Change_Order__c aResult;

		for ( Change_Order__c oItem : [
			SELECT Id, Name, Account__c, Billing_Notes__c, Billing_Type__c, Project__c,
				Stage__c, Close_Date__c, Changes_to_Scope_Deliverables__c, PSA_Project__c, Change_Order_Opportunity__c
			FROM Change_Order__c
			WHERE Change_Order_Opportunity__c = :pOpportunity.Id ]
		) {
			aResult = oItem;
		}

		return aResult;
	}

	public static Opportunity pOpportunity {
		get {
			if ( pOpportunity == null ) {
				pOpportunity = new Opportunity(
					Name = 'Test_pOpportunity',
					AccountId = pAccount.Id,
					Billing_Notes__c = 'BillingNotes',
					Billing_Type__c = 'T&M',
					StageName = 'Needs Analysis',
					Type = 'Existing Business',
					CurrencyIsoCode = 'USD',
					SOW_or_CO__c = 'CO',
					Original_Opportunity__c = pOriginalOpportunity.Id,
					CloseDate = Date.today().addDays( 1 ),
					Projected_Start_Date__c = date.today().addDays(20),
					Changes_to_Scope_Deliverables__c = 'abc',
					RecordTypeId = psaUtils.idRTOpportunityChangeOrders
				);
			}
			return pOpportunity;
		} private set;
	}

	private static Opportunity pOriginalOpportunity {
		get {
			if ( pOriginalOpportunity == null ) {
				pOriginalOpportunity = new Opportunity(
					Name = 'Test_pOriginalOpportunity',
					AccountId = pAccount.Id,
					Billing_Notes__c = 'BillingNotes',
					Billing_Type__c = 'T&M',
					StageName = 'Needs Analysis',
					Type = 'Existing Business',
					CurrencyIsoCode = 'USD',
					SOW_or_CO__c = 'CO',
					Project_Level__c = 'L1',
					CloseDate = Date.today().addDays( 1 ),
					Projected_Start_Date__c = date.today().addDays(20),
					Changes_to_Scope_Deliverables__c = 'abc',
					RecordTypeId = psaUtils.idRTOpportunityServices
				);
				insert pOriginalOpportunity;
			}
			return pOriginalOpportunity;
		} private set;
	}

	private static Account pAccount {
		get {
			if ( pAccount == null ) {
				pAccount = new Account(
					Name = 'Test_pAccount'
				);
				insert pAccount;
			}
			return pAccount;
		} private set;
	}

	private static Account pAnotherAccount {
		get {
			if ( pAnotherAccount == null ) {
				pAnotherAccount = new Account(
					Name = 'Test_pAnotherAccount'
				);
				insert pAnotherAccount;
			}
			return pAnotherAccount;
		} private set;
	}

	public static pse__Proj__c pProject {
		get {
			if ( pProject == null ) {
				pProject = new pse__Proj__c(
					Name = 'Test_pProject',
					CurrencyIsoCode = 'USD',
					pse__Opportunity__c = pOriginalOpportunity.Id
				);
			}
			return pProject;
		} private set;
	}
}