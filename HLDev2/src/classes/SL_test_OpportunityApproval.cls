/**
 * \author Vladimir Dobrelya
 * \date Oct 1, 2014
 * \brief The test class for SL_OpportunityApproval class
 */
@isTest
public class SL_test_OpportunityApproval {
	
	@isTest static void test_PageStandard() {
		createData();

		SL_OpportunityApproval controller;
		SL_OpportunityApproval.OpportunityApprovalNotFoundException exc;
		controller = new SL_OpportunityApproval();
		/*try {
			controller = new SL_OpportunityApproval();
		} catch ( SL_OpportunityApproval.OpportunityApprovalNotFoundException e ) {
			exc = e;
		}*/
		system.assertEquals( null, controller.initialOAData ); 

		ApexPages.currentPage().getParameters().put( 'id', pOpportunityApproval.Id );
		controller = new SL_OpportunityApproval();
		system.assertEquals( 1, controller.pagination.getPage() );
		system.assert( !controller.sections.isEmpty() );

		system.assertEquals( null, controller.opportunityApproval.Proposed_Fee_Range__c );
		controller.opportunityApproval.Proposed_Fee_Range__c = '111';

		system.assertEquals( SL_test_OpportunityApprovalValidation.pOpportunityApprovalPage.Name, controller.pagination.getPageName() );

		controller.Next();
		system.assertEquals( 2, controller.pagination.getPage() );
		controller.Previous();
		system.assertEquals( 1, controller.pagination.getPage() );
		system.assertEquals( '111', controller.opportunityApproval.Proposed_Fee_Range__c );
		controller.ChangePage();
		controller.Cancel();
		controller.getDependentPropertiesJSON();
	}

	@isTest static void test_PageRelatedList() {
		createData();

		ApexPages.currentPage().getParameters().put( 'id', pOpportunityApproval.Id );
		ApexPages.currentPage().getParameters().put( 'p', '2' );
		SL_OpportunityApproval controller = new SL_OpportunityApproval();

		system.assertEquals( 2, controller.pagination.getPage() );
		system.assert( !controller.relatedLists.isEmpty() );

		system.assertEquals( null, controller.relatedLists[0].wrappers[0].obj.get( 'EBIT_MM__c' ) );

		controller.relatedLists[0].wrappers[0].obj.put( 'EBIT_MM__c', 1.1 );
		controller.relatedLists[0].Save();
		system.assertEquals( 1.1, controller.relatedLists[0].wrappers[0].obj.get( 'EBIT_MM__c' ) );
		controller.relatedLists[0].Next();
		controller.relatedLists[0].Previous();
		controller.relatedLists[0].AddRow();
		controller.relatedLists[0].wrappers[1].obj.put( 'EBIT_MM__c', 2.1 );
		controller.relatedLists[0].wrappers[1].obj.put( 'EBITDA__c', 2.2 );
		controller.relatedLists[0].wrappers[1].obj.put( 'Related_Account__c', pAccount.Id );
		controller.Save();
		controller.relatedLists[0].selected = true;
		controller.relatedLists[0].selectAllRecords();
		system.assert( !controller.relatedLists[0].wrappers.isEmpty() );
		controller.relatedLists[0].RemoveRows();
		system.assert( controller.relatedLists[0].wrappers.isEmpty() );
		controller.relatedLists[0].Cancel();
		controller.relatedLists[0].sortBy = 'EBITDA__c';
		controller.relatedLists[0].refreshRecordsAndPage();
	}

	@isTest static void test_DependentProperties_unit() {
		createData();

		SL_OpportunityApproval.DependentProperties dependentProperties = new SL_OpportunityApproval.DependentProperties( SL_test_OpportunityApprovalValidation.pOpportunityApprovalPage.Id );
		
		SL_test_OpportunityApprovalValidation.pStandardProperty.Parent_Property__r = pDependentProperty;
		SL_test_OpportunityApprovalValidation.pStandardProperty.Parent_Property__r.Section__r = pDependentSection;
		dependentProperties.add( new List<Opportunity_Approval_Properties__c>{ pDependentProperty } );
		dependentProperties.add( new List<Opportunity_Approval_Properties__c>{ SL_test_OpportunityApprovalValidation.pStandardProperty } );

		SL_test_OpportunityApprovalValidation.pStandardProperty.Hidden__c = false;

		// show
		pOpportunityApproval.Capital_Markets_Consulted__c = 'Yes';
		dependentProperties.hideDependentProperties( pOpportunityApproval );
		system.assertEquals( false, SL_test_OpportunityApprovalValidation.pStandardProperty.Hidden__c );

		// hide
		pOpportunityApproval.Capital_Markets_Consulted__c = 'No';
		dependentProperties.hideDependentProperties( pOpportunityApproval );
		system.assert( SL_test_OpportunityApprovalValidation.pStandardProperty.Hidden__c );

		Map<ID, List<Opportunity_Approval_Properties__c>> dependentPropertyMap = dependentProperties.getDependentProperties();

		system.assert( dependentPropertyMap.containsKey( pDependentProperty.Id ) );
		system.assert( dependentProperties.getParentFields().contains( pDependentProperty.Field_API_Name__c.toLowerCase() ) );
		
		Boolean childPropertyTest = false;
		for ( Opportunity_Approval_Properties__c property : dependentPropertyMap.get( pDependentProperty.Id ) ) {
			if ( property.Id == SL_test_OpportunityApprovalValidation.pStandardProperty.Id ) {
				childPropertyTest = true;
			}
		}
		system.assert( childPropertyTest );		
	}


	/*@isTest static void test_SubmitForApproval() {
		createData();

		ApexPages.currentPage().getParameters().put( 'id', pOpportunityApproval.Id );
		ApexPages.currentPage().getParameters().put( 'p', '2' );
		SL_OpportunityApproval controller = new SL_OpportunityApproval();

		system.assert( controller.isSubmitForApprovalButtonVisible );
		controller.SubmitForApproval();
		system.assertEquals( 'Submitted for Approval', [ SELECT Status__c FROM Opportunity_Approval__c WHERE Id = :pOpportunityApproval.Id ].Status__c );
	}*/

	static void createData() {
		SL_test_OpportunityApprovalValidation.pStandardSection.Object_API_Name__c = 'Opportunity_Approval__c';
		insert SL_test_OpportunityApprovalValidation.pStandardSection;

		insert pDependentProperty;

		SL_test_OpportunityApprovalValidation.pStandardProperty.Line_of_Business__c = 'CF;FRG;FAS';
		SL_test_OpportunityApprovalValidation.pStandardProperty.Field_API_Name__c = 'Proposed_Fee_Range__c';
		SL_test_OpportunityApprovalValidation.pStandardProperty.Parent_Property__c = pDependentProperty.Id;
		SL_test_OpportunityApprovalValidation.pStandardProperty.Parent_Property_Values__c = 'Yes';
		insert SL_test_OpportunityApprovalValidation.pStandardProperty;

		SL_test_OpportunityApprovalValidation.pRelatedListSection.Opportunity_Approval_Page__c = pOpportunityApprovalPage2.Id;
		SL_test_OpportunityApprovalValidation.pRelatedListSection.Object_API_Name__c = 'Financials__c';
		SL_test_OpportunityApprovalValidation.pRelatedListSection.Relationship_Field__c = 'Related_Approval__c';
		insert SL_test_OpportunityApprovalValidation.pRelatedListSection;

		SL_test_OpportunityApprovalValidation.pRelatedListProperty.Line_of_Business__c = 'CF;FRG;FAS';
		SL_test_OpportunityApprovalValidation.pRelatedListProperty.Field_API_Name__c = 'EBIT_MM__c';

		insert new Opportunity_Approval_Properties__c( // additional property to fill in master-detail
			Name = 'Related_Account__c',
			Field_API_Name__c = 'Related_Account__c',
			Line_of_Business__c = 'CF;FRG;FAS',
			Order__c = 5,
			Section__c = SL_test_OpportunityApprovalValidation.pRelatedListProperty.Section__c
		);

		insert SL_test_OpportunityApprovalValidation.pRelatedListProperty;
		insert pRelatedListProperty;

		insert pOpportunity;
		insert pOpportunityApproval;
		insert pFinancials;
	}

	public static Opportunity_Approval_Page__c pOpportunityApprovalPage2 {
		get {
			if ( pOpportunityApprovalPage2 == null ) {
				pOpportunityApprovalPage2 = new Opportunity_Approval_Page__c(
					Name = 'TestOAPage2',
					Order__c = 2
				);
				insert pOpportunityApprovalPage2;
			}
			return pOpportunityApprovalPage2;
		} set;
	}

	// dependent property gets hidden when child and parent properties are on the different pages
	public static Opportunity_Approval_Section__c pDependentSection {
		get {
			if ( pDependentSection == null ) {
				pDependentSection = new Opportunity_Approval_Section__c(
					Name = 'TestDependentSection2',
					Order__c = 2,
					Object_API_Name__c = 'Opportunity_Approval__c',
					Opportunity_Approval_Page__c = pOpportunityApprovalPage2.Id
				);
				insert pDependentSection;
			}
			return pDependentSection;
		} set;
	}
	
	public static Opportunity_Approval_Properties__c pDependentProperty {
		get {
			if ( pDependentProperty == null ) {
				pDependentProperty = new Opportunity_Approval_Properties__c(
					Name = 'TestDependentProperty',
					Order__c = 4,
					Line_of_Business__c = 'CF;FRG;FAS',
					Field_API_Name__c = 'Capital_Markets_Consulted__c',
					Section__c = pDependentSection.Id
				);
			}
			return pDependentProperty;
		} set;
	}
	
	public static Opportunity_Approval_Properties__c pRelatedListProperty {
		get {
			if ( pRelatedListProperty == null ) {
				pRelatedListProperty = new Opportunity_Approval_Properties__c(
					Name = 'TestEBITDA',
					Order__c = 3,
					Line_of_Business__c = 'CF;FRG;FAS',
					Field_API_Name__c = 'EBITDA__c',
					Parent_Property__c = pDependentProperty.Id,
					Parent_Property_Values__c = 'No',
					Section__c = SL_test_OpportunityApprovalValidation.pRelatedListProperty.Section__c
				);
			}
			return pRelatedListProperty;
		} set;
	}

	public static Opportunity_Approval__c pOpportunityApproval {
		get {
			if ( pOpportunityApproval == null ) {
				pOpportunityApproval = new Opportunity_Approval__c(
					Related_Opportunity__c = pOpportunity.Id,
					Is_Client_Public__c = 'Yes',
					Is_Majority_Sale__c = 'Yes',
					Who_will_be_at_the_pitch__c = 'Feinstein',
					Capital_Markets_Consulted__c = 'Yes' // dependent propety test
				);
			}
			return pOpportunityApproval;
		} set;
	}

	public static Financials__c pFinancials {
		get {
			if ( pFinancials == null ) {
				pFinancials = new Financials__c(
					Related_Account__c = pAccount.Id,
					Related_Approval__c = pOpportunityApproval.Id
				);
			}
			return pFinancials;
		} set;
	}

	public static Opportunity__c pOpportunity {
		get {
			if ( pOpportunity == null ) {
				pOpportunity = new Opportunity__c(
					Client__c = pAccount.Id,
					Subject__c = pAccount.Id,
					Primary_Office__c = 'AT',
					Line_of_Business__c = 'FAS',
					Job_Type__c = 'Consulting',
					Industry_Group__c = 'CFR',
					Sector__c = 'Apparel',
					Stage__c = 'Engaged',
					Referral_Type__c = 'Accountant',
					RecordTypeId = pRTOpportunityFairnessId
				);
			}
			return pOpportunity;
		} set;
	}

	public static ID pRTOpportunityFairnessId {
		get {
			if ( pRTOpportunityFairnessId == null ) {
				for ( RecordType record : [ SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity__c' AND DeveloperName = 'Fairness' limit 1 ] ) {
					pRTOpportunityFairnessId = record.Id;
				}
				system.assertNotEquals( null, pRTOpportunityFairnessId, 'Could not find "Fairness" RecordType for the Opportunity object.' );
			}
			return pRTOpportunityFairnessId;
		} private set;
	}

	/*static Other_Working_Group__c pOtherWorkingGroup {
		get {
			if ( pOtherWorkingGroup == null ) {
				pOtherWorkingGroup = new Other_Working_Group__c(
					Opportunity_Approval__c = pOpportunityApproval.Id,
					Project__c = pProject.Id,
					EBITDA__c = pAccount.Id
				);
			}
			return pOtherWorkingGroup;
		} set;
	}*/

	/*static Other_Working_Group_Service_Provider__c pServiceProvider {
		get {
			if ( pServiceProvider == null ) {
				pServiceProvider = new Other_Working_Group_Service_Provider__c(
					Service_Provider__c = pAccount.Id,
					Project__c = pProject.Id
				);
			}
			return pServiceProvider;
		} set;
	}*/

	static Account pAccount {
		get {
			if ( pAccount == null ) {
				pAccount = new Account(
					Name = 'TestAccount'
				);
				insert pAccount;
			}
			return pAccount;
		} set;
	}

	/*public static Project__c pProject {
		get {
			if ( pProject == null ) {
				pProject = new Project__c(
					Name = 'TestProject',
					Type__c = 'Buy-Side'
				);
			}
			return pProject;
		} set;
	}*/
}