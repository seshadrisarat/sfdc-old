/**
 * \author Vladimir Dobrelya
 * \date Nov 26, 2014
 * \brief The test class for SL_handler_CDDSection and SL_handler_CDDProperty trigger handlers
 */
@isTest
public class SL_test_OpportunityApprovalValidation {
	
	static String incorrectName = '!##$#(&(YAS';
	static Boolean hasError = false;

	@isTest static void test_validate_Standard() {
		pStandardSection.Object_API_Name__c = incorrectName; // incorrect object name
		system.assertEquals( false, upsertObject( pStandardSection ) );

		pStandardSection.Object_API_Name__c = 'Opportunity_Approval__c'; // correct object name
		system.assertEquals( true, upsertObject( pStandardSection ) );

		pStandardProperty.Field_API_Name__c = incorrectName; // incorrect field name
		system.assertEquals( false, upsertObject( pStandardProperty ) );

		pStandardProperty.Field_API_Name__c = 'Background__c'; // correct field name
		system.assertEquals( true, upsertObject( pStandardProperty ) );

		pStandardSection.Object_API_Name__c = 'Financials__c'; // correct object name, but incorrect for pStandardProperty.Field_API_Name__c
		system.assertEquals( false, upsertObject( pStandardSection ) );
	}
	
	@isTest static void test_validate_RelatedList() {
		pRelatedListSection.Object_API_Name__c = incorrectName; // incorrect object name
		pRelatedListSection.Relationship_Field__c = incorrectName;
		system.assertEquals( false, upsertObject( pRelatedListSection ) );

		pRelatedListSection.Relationship_Field__c = null; // https://silverline.jira.com/browse/HL-61
		pRelatedListSection.Object_API_Name__c = 'Financials__c';
		system.assertEquals( false, upsertObject( pRelatedListSection ) );

		pRelatedListSection.Relationship_Field__c = 'Related_Account__c'; // correct object name
		pRelatedListSection.Object_API_Name__c = 'Financials__c';
		system.assertEquals( true, upsertObject( pRelatedListSection ) );

		pRelatedListProperty.Field_API_Name__c = incorrectName; // incorrect field name
		system.assertEquals( false, upsertObject( pRelatedListProperty ) );

		pRelatedListProperty.Field_API_Name__c = 'Name'; // correct field name
		system.assertEquals( true, upsertObject( pRelatedListProperty ) );

		pRelatedListProperty.Field_API_Name__c = incorrectName; // incorrect field name, just for update coverage
		system.assertEquals( false, upsertObject( pRelatedListProperty ) );

		// https://silverline.jira.com/browse/HL-61
		pRelatedListSection.Relationship_Field__c = 'Related_Account__c'; // correct field name
		pRelatedListSection.Parent_Relationship_Field__c = incorrectName; // incorrect field name
		system.assertEquals( false, upsertObject( pRelatedListSection ) );

		pRelatedListSection.Relationship_Field__c = 'Related_Account__c'; // correct field name
		pRelatedListSection.Parent_Relationship_Field__c = 'Related_Opportunity__r.Client_c'; // incorrect field name
		system.assertEquals( false, upsertObject( pRelatedListSection ) );

		pRelatedListSection.Parent_Relationship_Field__c = 'Related_Opportunity__r.Client__c'; // correct field name
		system.assertEquals( true, upsertObject( pRelatedListSection ) );
	}

	static Boolean upsertObject( SObject obj ) {
		try {
			upsert obj;
		} catch ( Exception e ) {
			return false;
		}
		return true;
	}

	public static Opportunity_Approval_Page__c pOpportunityApprovalPage {
		get {
			if ( pOpportunityApprovalPage == null ) {
				pOpportunityApprovalPage = new Opportunity_Approval_Page__c(
					Name = 'TestOAPage',
					Order__c = 1
				);
				insert pOpportunityApprovalPage;
			}
			return pOpportunityApprovalPage;
		} set;
	}

	// STANDARD 
	public static Opportunity_Approval_Section__c pStandardSection {
		get {
			if ( pStandardSection == null ) {
				pStandardSection = new Opportunity_Approval_Section__c(
					Name = 'TestOpportunityApprovalSection',
					Opportunity_Approval_Page__c = pOpportunityApprovalPage.Id,
					Order__c = 1,
					RecordTypeId = idStandardSectionRT
				);
			}
			return pStandardSection;
		} set;
	}

	public static Opportunity_Approval_Properties__c pStandardProperty {
		get {
			if ( pStandardProperty == null ) {
				pStandardProperty = new Opportunity_Approval_Properties__c(
					Name = 'TestOpportunityApprovalSection',
					Order__c = 1,
					Section__c = pStandardSection.Id
				);
			}
			return pStandardProperty;
		} set;
	}

	public static ID idStandardSectionRT {
		get {
			if ( idStandardSectionRT == null ) {
				for ( RecordType record : [ SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity_Approval_Section__c' AND DeveloperName = 'Standard_Fields' limit 1 ] ) {
					idStandardSectionRT = record.Id;
				}
				system.assertNotEquals( null, idStandardSectionRT, 'Could not find "Standard_Fields" RecordType for the Opportunity Approval Section object.' );
			}
			return idStandardSectionRT;
		}
	}


	// RELATED LIST
	public static Opportunity_Approval_Section__c pRelatedListSection {
		get {
			if ( pRelatedListSection == null ) {
				pRelatedListSection = new Opportunity_Approval_Section__c(
					Name = 'TestOpportunityApprovalSection',
					Opportunity_Approval_Page__c = pOpportunityApprovalPage.Id,
					Order__c = 2,
					RecordTypeId = idRelatedListSectionRT
				);
			}
			return pRelatedListSection;
		} set;
	}

	public static Opportunity_Approval_Properties__c pRelatedListProperty {
		get {
			if ( pRelatedListProperty == null ) {
				pRelatedListProperty = new Opportunity_Approval_Properties__c(
					Name = 'TestOpportunityApprovalSection',
					Order__c = 2,
					Section__c = pRelatedListSection.Id
				);
			}
			return pRelatedListProperty;
		} set;
	}

	public static ID idRelatedListSectionRT {
		get {
			if ( idRelatedListSectionRT == null ) {
				for ( RecordType record : [ SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity_Approval_Section__c' AND DeveloperName = 'Related_List' limit 1 ] ) {
					idRelatedListSectionRT = record.Id;
				}
				system.assertNotEquals( null, idStandardSectionRT, 'Could not find "Related_List" RecordType for the Opportunity Approval Section object.' );
			}
			return idRelatedListSectionRT;
		}
	}	
}