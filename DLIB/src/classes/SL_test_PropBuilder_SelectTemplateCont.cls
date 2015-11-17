/**
 * \author Vladimir Dobrelya
 * \date Mar 14, 2014
 * \brief The test class for SL_ProposalBuilder_SelectTemplateCont
 */
@isTest(SeeAllData=true)
private class SL_test_PropBuilder_SelectTemplateCont {
	
	@isTest static void test_getTreeHeirarchy() {
		createData_templates();

		List<SL_ProposalBuilder_SelectTemplateCont.TreeNode> aResult;

		Test.startTest();
			aResult = SL_ProposalBuilder_SelectTemplateCont.getTreeHeirarchy( '{strSelectedOppTemplateId:' + pOppsTemplate.Id + '}' );
		Test.stopTest();
	
		system.assertNotEquals( null, aResult );
		system.assert( !aResult.isEmpty() );
		system.assertEquals( pOppsTemplateComponent.Id, aResult.get( 0 ).id );

		system.assert( !aResult.get( 0 ).children.isEmpty() );
		system.assertEquals( pOppsTemplateComponentFeature.Id, aResult.get( 0 ).children.get( 0 ).id );

		system.assert( !aResult.get( 0 ).children.get( 0 ).children.isEmpty() );
		system.assertEquals( pOppsTemplateComponentDetail.Id, aResult.get( 0 ).children.get( 0 ).children.get( 0 ).id );
	}
	
	@isTest static void test_createOpportunityComponent() {
		createData_components();

		SL_ProposalBuilder_SelectTemplateCont oController = new SL_ProposalBuilder_SelectTemplateCont( new ApexPages.StandardController( pOpportunity ) );

		oController.selectedOpportunityComponentIds = pOppsTemplateComponent2.Id;
		oController.selectedOpportunityComponentFeatureIds = pOppsTemplateComponentFeature2.Id;
		oController.selectedOpportunityComponentDetailIds = pOppsTemplateComponentDetail2.Id;

		Test.startTest();
			oController.createOpportunityComponent();
		Test.stopTest();

		// Opportunity_Component__c
		List<Opportunity_Component__c> aOpportunityComponents = new List<Opportunity_Component__c>( [
			SELECT Id FROM Opportunity_Component__c
			WHERE Opportunity__c = :pOpportunity.Id AND
				Opps_Template_Component__c = :pOppsTemplateComponent2.Id AND
				Description__c = :pOppsTemplateComponent2.Name ]
		);
		system.assert( !aOpportunityComponents.isEmpty() );

		// Opportunity_Component_Feature__c
		List<Opportunity_Component_Feature__c> aOpportunityComponentFeatures = new List<Opportunity_Component_Feature__c>( [
			SELECT Id FROM Opportunity_Component_Feature__c
			WHERE Opps_Template_Component_Feature_Id__c = :pOppsTemplateComponentFeature2.Id AND
				Opportunity_Component__c = :aOpportunityComponents.get( 0 ).Id AND
				Description__c = :pOppsTemplateComponentFeature2.Name ]
		);
		system.assert( !aOpportunityComponentFeatures.isEmpty() );

		// Opportunity_Component_Detail__c
		system.assert( !new List<Opportunity_Component_Detail__c>( [
			SELECT Id FROM Opportunity_Component_Detail__c
			WHERE Opps_Template_Component_Detail_Id__c = :pOppsTemplateComponentDetail2.Id AND
				Description__c = :pOppsTemplateComponentDetail2.Name AND
				Opportunity_Component_Feature__c = :aOpportunityComponentFeatures.get( 0 ).Id ]
		).isEmpty() );
	}

	@isTest static void test_redirectionControl() {
		createData_components();

		SL_ProposalBuilder_SelectTemplateCont oController = new SL_ProposalBuilder_SelectTemplateCont( new ApexPages.StandardController( pOpportunity ) );
		PageReference oResult;

		Test.startTest();
			oResult = oController.redirectionControl();
			system.assertNotEquals( null, oResult );

			ApexPages.currentPage().getParameters().put( 'ism', 'true' );
			oResult = oController.redirectionControl();
		Test.stopTest();

		system.assertEquals( null, oResult );
	}

	// ------------------------------------------------------------------------------------ //

	static void createData_opportunity() {
		insert pOpportunity;
	}

	static void createData_templates() {
		createData_opportunity();

		insert pOppsTemplate;
		insert pOppsTemplateComponent;
		insert pOppsTemplateComponentFeature;
		insert pOppsTemplateComponentDetail;
	}

	static void createData_templateClones() {
		insert pOppsTemplateComponent2;
		insert pOppsTemplateComponentFeature2;
		insert pOppsTemplateComponentDetail2;
	}

	static void createData_components() {
		createData_templates();
		createData_templateClones();

		insert pOpportunityComponent;
		insert pOpportunityComponentFeature;
		insert pOpportunityComponentDetail;
	}

	// ------------------------------------------------------------------------------------ //

	static Opportunity pOpportunity {
		get {
			if ( pOpportunity == null ) {
				pOpportunity = new Opportunity(
					Name = 'TEST_pOpportunity',
					StageName = 'Qualified Suspect',
					CloseDate = Date.today().addDays( 1 ),
					Projected_Start_Date__c = date.today().addDays(20)
				);
			}
			return pOpportunity;
		} private set;
	}

	// ------------------------------------------------------------------------------------ //

	static Opps_Template__c pOppsTemplate {
		get {
			if ( pOppsTemplate == null ) {
				pOppsTemplate = new Opps_Template__c(
					Name = 'TEST_pOppsTemplate',
					Description__c = 'TEST_pOppsTemplate_Description'
				);
			}
			return pOppsTemplate;
		} private set;
	}

	static Opps_Template_Component__c pOppsTemplateComponent {
		get {
			if ( pOppsTemplateComponent == null ) {
				pOppsTemplateComponent = new Opps_Template_Component__c(
					Name = 'TEST_pOppsTemplateComponent',
					Template__c = pOppsTemplate.Id
				);
			}
			return pOppsTemplateComponent;
		} private set;
	}

	static Opps_Template_Component_Feature__c pOppsTemplateComponentFeature {
		get {
			if ( pOppsTemplateComponentFeature == null ) {
				pOppsTemplateComponentFeature = new Opps_Template_Component_Feature__c(
					Name = 'TEST_pOppsTemplateComponentFeature',
					Opps_Template_Component__c = pOppsTemplateComponent.Id
				);
			}
			return pOppsTemplateComponentFeature;
		} private set;
	}

	static Opps_Template_Component_Detail__c pOppsTemplateComponentDetail {
		get {
			if ( pOppsTemplateComponentDetail == null ) {
				pOppsTemplateComponentDetail = new Opps_Template_Component_Detail__c(
					Name = 'TEST_pOppsTemplateComponentDetail',
					Opps_Template_Component_Feature__c = pOppsTemplateComponentFeature.Id
				);
			}
			return pOppsTemplateComponentDetail;
		} private set;
	}

	// -- clones --- //

	static Opps_Template_Component__c pOppsTemplateComponent2 {
		get {
			if ( pOppsTemplateComponent2 == null ) {
				pOppsTemplateComponent2 = new Opps_Template_Component__c(
					Name = 'TEST_pOppsTemplateComponent2',
					Template__c = pOppsTemplate.Id
				);
			}
			return pOppsTemplateComponent2;
		} private set;
	}

	static Opps_Template_Component_Feature__c pOppsTemplateComponentFeature2 {
		get {
			if ( pOppsTemplateComponentFeature2 == null ) {
				pOppsTemplateComponentFeature2 = new Opps_Template_Component_Feature__c(
					Name = 'TEST_pOppsTemplateComponentFeature2',
					Opps_Template_Component__c = pOppsTemplateComponent2.Id
				);
			}
			return pOppsTemplateComponentFeature2;
		} private set;
	}

	static Opps_Template_Component_Detail__c pOppsTemplateComponentDetail2 {
		get {
			if ( pOppsTemplateComponentDetail2 == null ) {
				pOppsTemplateComponentDetail2 = new Opps_Template_Component_Detail__c(
					Name = 'TEST_pOppsTemplateComponentDetail2',
					Opps_Template_Component_Feature__c = pOppsTemplateComponentFeature2.Id
				);
			}
			return pOppsTemplateComponentDetail2;
		} private set;
	}

	// ------------------------------------------------------------------------------------ //

	static Opportunity_Component__c pOpportunityComponent {
		get {
			if ( pOpportunityComponent == null ) {
				pOpportunityComponent = new Opportunity_Component__c(
					Opportunity__c = pOpportunity.Id,
					Opps_Template_Component__c = pOppsTemplateComponent.Id
				);
			}
			return pOpportunityComponent;
		} private set;
	}

	static Opportunity_Component_Feature__c pOpportunityComponentFeature {
		get {
			if ( pOpportunityComponentFeature == null ) {
				pOpportunityComponentFeature = new Opportunity_Component_Feature__c(
					Opportunity_Component__c = pOpportunityComponent.Id,
					Opps_Template_Component_Feature_Id__c = pOppsTemplateComponentFeature.Id
				);
			}
			return pOpportunityComponentFeature;
		} private set;
	}

	static Opportunity_Component_Detail__c pOpportunityComponentDetail {
		get {
			if ( pOpportunityComponentDetail == null ) {
				pOpportunityComponentDetail = new Opportunity_Component_Detail__c(
					Opportunity_Component_Feature__c = pOpportunityComponentFeature.Id,
					Opps_Template_Component_Detail_Id__c = pOppsTemplateComponentDetail.Id
				);
			}
			return pOpportunityComponentDetail;
		} private set;
	}

	// ------------------------------------------------------------------------------------ //

}