/**
 * \author Vladimir Dobrelya
 * \date Nov 21, 2014
 * \brief The validation trigger handler
 * \see https://silverline.jira.com/browse/HL-53
 */
public with sharing class SL_handler_OpportunityApprovalSection {
		
	public void OnBeforeInsert( List<Opportunity_Approval_Section__c> records ) {
    	this.validate( records );
    }

    public void OnBeforeUpdate( Map<ID, Opportunity_Approval_Section__c> recordsOld, Map<ID, Opportunity_Approval_Section__c> recordsNew ) {
    	this.validate( recordsNew.values(), recordsOld );
    }


    // --- VALIDATION --- //

    private void validate( List<Opportunity_Approval_Section__c> records ) {
    	this.validate( records, null );
    }

    private void validate( List<Opportunity_Approval_Section__c> records, Map<ID, Opportunity_Approval_Section__c> recordsOld ) {
    	Map<ID, List<Opportunity_Approval_Properties__c>> properties;
    	if ( recordsOld != null ) {
    		properties = this.getProperties( records );
    	}
    	String message;

    	for ( Opportunity_Approval_Section__c record : records ) {
    		if ( recordsOld != null && properties.containsKey( record.Id )  ) { // child properties check
                if ( ( message = this.validateProperties( record.Object_API_Name__c, properties.get( record.Id ) ) ) != null ) {
    				record.Object_API_Name__c.addError( message );
    			}
	    	}

    		if ( !SL_Describe.isExisting( record.Object_API_Name__c ) ) {
    			record.Object_API_Name__c.addError( this.getObjectError( record.Object_API_Name__c ) );
    		}

            if ( record.RecordTypeId == relatedListRecordTypeId ) {
                if ( String.isBlank( record.Relationship_Field__c ) ) {
                    record.Relationship_Field__c.addError( 'This field is required if the section is Related List' );
                } else {  
                    if ( !SL_Describe.isExisting( record.Object_API_Name__c, record.Relationship_Field__c ) ) {
                        record.Relationship_Field__c.addError( SL_handler_OpportunityApprovalProperty.getFieldError( record.Object_API_Name__c, record.Relationship_Field__c ) );
                    }
                }
            }            

            if ( String.isNotBlank( record.Parent_Relationship_Field__c ) ) {
                if ( !record.Parent_Relationship_Field__c.contains( '.' ) ) {
                    if ( !SL_Describe.isExisting( record.Object_API_Name__c, record.Parent_Relationship_Field__c ) ) {
                        record.Relationship_Field__c.addError( SL_handler_OpportunityApprovalProperty.getFieldError( 'Opportunity_Approval__c', record.Parent_Relationship_Field__c ) );
                    }
                } else {
                    String exceptionMessage = SL_Describe.validateFieldName( 'Opportunity_Approval__c', record.Parent_Relationship_Field__c );
                    if ( exceptionMessage != null ) {
                        record.Parent_Relationship_Field__c.addError( exceptionMessage );
                    }
                }
            }
    	}
    }

    private Map<ID, List<Opportunity_Approval_Properties__c>> getProperties( List<Opportunity_Approval_Section__c> sections ) {
    	Map<ID, List<Opportunity_Approval_Properties__c>> result = new Map<ID, List<Opportunity_Approval_Properties__c>>();
    	for ( Opportunity_Approval_Properties__c property : [ SELECT Name, Section__c, Field_API_Name__c FROM Opportunity_Approval_Properties__c WHERE Field_API_Name__c != null AND Section__c IN :sections ] ) {
    		if ( !result.containsKey( property.Section__c ) ) {
    			result.put( property.Section__c, new List<Opportunity_Approval_Properties__c>() );
    		}
    		result.get( property.Section__c ).add( property );
    	}
    	return result;
    }

    private String validateProperties( String sObjectName, List<Opportunity_Approval_Properties__c> properties ) {
    	for ( Opportunity_Approval_Properties__c property : properties ) {
    		if ( !SL_Describe.isExisting( sObjectName, property.Field_API_Name__c ) ) {
    			return property.Name + ' property has incorrect Field_API_Name__c(' + property.Field_API_Name__c + ') for the ' + sObjectName + ' object.';
    		}
    	}
    	return null;
    }

    private String getObjectError( String sObjectName ) {
    	return 'The ' + sObjectName + ' object does not exist.';
    }

    private ID relatedListRecordTypeId {
        get {
            if ( relatedListRecordTypeId == null ) {
                for ( RecordType record : [ SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity_Approval_Section__c' AND DeveloperName = 'Related_List' ] ) {
                    relatedListRecordTypeId = record.Id;
                }
            }
            return relatedListRecordTypeId;
        } set;
    }
}