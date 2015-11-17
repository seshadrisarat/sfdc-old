/**
 * \author Vladimir Dobrelya
 * \date Aug 12, 2014
 * \see https://silverline.jira.com/browse/WP-124
 */
public with sharing class SL_handler_TickSheetValidation {

	public static ID idEmployeeRT {
		get {
			if ( idEmployeeRT == null ) {
				idEmployeeRT = getEmployeeRecordTypeId();
			}
			return idEmployeeRT;
		} set;
	}

	public void OnBeforeInsert( List<Contact> aRecords ) {
		this.validateTickSheet( aRecords );
	}

	public void OnBeforeUpdate( Map<ID, Contact> aOldRecords, Map<ID, Contact> aNewRecords ) {
		this.validateTickSheet( aNewRecords.values() );
	}

   	private void validateTickSheet( List<Contact> aRecords ) {
		for ( Contact oContact : aRecords ) {
			if ( oContact.Tick_Sheet__c != null && oContact.RecordTypeId == idEmployeeRT && !this.getAvailableTicksheets( oContact ).contains( oContact.Tick_Sheet__c ) ) {
				oContact.Tick_Sheet__c.addError( 'Validation Error: The Default Tick Sheet must be selected from the options in the Available Tick Sheets field.' );
			}
		}
   	}

	private Set<String> getAvailableTicksheets( Contact oContact ) {
    	Set<String> aResult = new Set<String>();

	    if ( oContact.Available_Ticksheets__c != null ) {
	      	aResult.addAll( oContact.Available_Ticksheets__c.split( ';' ) );
	    }

	    return aResult;
  	}

  	private static ID getEmployeeRecordTypeId() {
		for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Employee' limit 1 ] ) {
			return oItem.Id;
		}
		throw new TriggerException( 'Employee RecordType is not found.' );
		return null;
   	}

   	private class TriggerException extends Exception { }
}