/**
 * \author Vladimir Dobrelya
 * \date Nov 21, 2014
 * \brief The validation trigger handler
 * \see https://silverline.jira.com/browse/HL-53
 */
public with sharing class SL_handler_OpportunityApprovalProperty {

	public void OnBeforeInsert( List<Opportunity_Approval_Properties__c> records ) {
    	this.validate( records );
    }

    public void OnBeforeUpdate( Map<ID, Opportunity_Approval_Properties__c> recordsOld, Map<ID, Opportunity_Approval_Properties__c> recordsNew ) {
    	this.validate( recordsNew.values() );
    }


    // --- VALIDATION --- //

    private void validate( List<Opportunity_Approval_Properties__c> records ) {
    	this.validate( this.getObjectName( records.get( 0 ) ), records );
    }

    private void validate( String sObjectName, List<Opportunity_Approval_Properties__c> records ) {
    	Schema.DescribeFieldResult fieldDescribe;

    	for ( Opportunity_Approval_Properties__c record : records ) {
            if ( String.isNotBlank( record.Field_API_Name__c ) ) {
                fieldDescribe = SL_Describe.getDescribe( sObjectName, record.Field_API_Name__c );
                if ( fieldDescribe == null ) {
                    record.Field_API_Name__c.addError( getFieldError( sObjectName, record.Field_API_Name__c ) );
                }/* else if ( !fieldDescribe.isAccessible() ) {
                    record.Field_API_Name__c.addError( getFieldNotAccessibleError( sObjectName, record.Field_API_Name__c ) );
                }*/
            }
    	}
    }

    private String getObjectName( Opportunity_Approval_Properties__c record ) {
    	return [ SELECT Object_API_Name__c FROM Opportunity_Approval_Section__c WHERE Id = :record.Section__c limit 1 ].Object_API_Name__c;
    }

    public static String getFieldError( String sObjectName, String fieldName ) {
    	return 'The ' + sObjectName + ' object has no ' + fieldName + ' field';
    }

    /*public static String getFieldNotAccessibleError( String sObjectName, String fieldName ) {
    	return 'The ' + sObjectName + '.' + fieldName + ' field is not accessible';
    }*/
}