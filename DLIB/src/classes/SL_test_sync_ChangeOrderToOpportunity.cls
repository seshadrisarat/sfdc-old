/**
 * \author Vladimir Dobrelya
 * \date Feb 19, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
@isTest
public class SL_test_sync_ChangeOrderToOpportunity {

	@isTest static void test_insert() {
		createData();
		doAsserts( pChangeOrder, getOpportunity() );
	}

	@isTest static void test_update() {
		createData();

		Test.startTest();
			pChangeOrder.Name += '-CHANGED';
			pChangeOrder.Account__c = pAnotherAccount.Id;
			pChangeOrder.Billing_Notes__c += '-CHANGED';
			pChangeOrder.Billing_Type__c = 'Fixed Fee';
			pChangeOrder.Stage__c = 'Proposal Requested';
			pChangeOrder.Close_Date__c = Date.today().addDays( 2 );
			pChangeOrder.Changes_to_Scope_Deliverables__c += '-CHANGED';
			update pChangeOrder;
		Test.stopTest();

		doAsserts( pChangeOrder, getOpportunity() );
	}

	@isTest static void test_delete() {
		createData();

		Test.startTest();
			delete pChangeOrder;
		Test.stopTest();

		system.assertEquals( null, getOpportunity() );
	}

	@isTest static void test_undelete() {
		createData();
		delete pChangeOrder;

		system.assertEquals( null, getOpportunity() );

		Test.startTest();
			undelete pChangeOrder;
		Test.stopTest();

		system.assertNotEquals( null, getOpportunity() );
	}


	public static void doAsserts( Change_Order__c oChangeOrder, Opportunity oOpp ) {
		system.assertNotEquals( null, oOpp );

		system.assertEquals( oChangeOrder.Id, oOpp.Project_Change_Order__c );
		system.assertEquals( oChangeOrder.Change_Order_Opportunity__c, oOpp.Id );

		system.assertEquals( oChangeOrder.Name, oOpp.Name );
		system.assertEquals( oChangeOrder.Account__c, oOpp.AccountId );
		system.assertEquals( oChangeOrder.Billing_Notes__c, oOpp.Billing_Notes__c );
		system.assertEquals( oChangeOrder.Billing_Type__c, oOpp.Billing_Type__c );
		system.assertEquals( oChangeOrder.Stage__c, oOpp.StageName );
		system.assertEquals( oChangeOrder.Close_Date__c, oOpp.CloseDate );
		system.assertEquals( oChangeOrder.Changes_to_Scope_Deliverables__c, oOpp.Changes_to_Scope_Deliverables__c );

		system.assertEquals( pOriginalOpportunity.Id, oOpp.Original_Opportunity__c );
	}

	public static void createData() {
		insert pChangeOrder;
		refreshData();
	}

	private static void refreshData() {
		pChangeOrder = [
			SELECT Id, Name, Account__c, Billing_Notes__c, Billing_Type__c, Project__c, Stage__c, Close_Date__c,
				Changes_to_Scope_Deliverables__c, PSA_Project__c, Change_Order_Opportunity__c
			FROM Change_Order__c
			WHERE Id = :pChangeOrder.Id 
		];
	}

	public static Opportunity getOpportunity() {
		Opportunity oResult;

		for ( Opportunity oItem : [
			SELECT Id, Name, AccountId, Billing_Notes__c, Billing_Type__c, StageName, CloseDate,
				Project_Change_Order__c, Changes_to_Scope_Deliverables__c, Original_Opportunity__c
			FROM Opportunity
			WHERE Project_Change_Order__c = :pChangeOrder.Id ]
		) {
			oResult = oItem;
		}

		return oResult;
	}

	public static Change_Order__c pChangeOrder {
		get {
			if ( pChangeOrder == null ) {
				pChangeOrder = new Change_Order__c(
					Name = 'Test_pChangeOrder',
					Account__c = pAccount.Id,
					Billing_Notes__c = 'BillingNotes',
					Billing_Type__c = 'T&M',
					Stage__c = 'Needs Analysis',
					CurrencyIsoCode = 'USD',
					Close_Date__c = Date.today().addDays( 1 ),
					Changes_to_Scope_Deliverables__c = 'abc',
					PSA_Project__c = pProject.Id
				);
			}
			return pChangeOrder;
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

	private static pse__Proj__c pProject {
		get {
			if ( pProject == null ) {
				pProject = new pse__Proj__c(
					Name = 'Test_pProject',
					CurrencyIsoCode = 'USD',
					pse__Opportunity__c = pOriginalOpportunity.Id
				);
				insert pProject;
			}
			return pProject;
		} private set;
	}
}