/**
 * \author Vladimir Dobrelya
 * \date Aug 12, 2014
 * \see https://silverline.jira.com/browse/WP-124
 * \brief The unit test for SL_handler_TickSheetValidation class
 */
@isTest
private class SL_test_handler_TickSheetValidation {

	static testMethod void tickSheetValidation_insertFailure() {
		pContact.Tick_Sheet__c = 'New York';

		Boolean bIsValid = true;

		// validation failure
		Test.startTest();
			try {
				insert pContact;
			} catch ( DmlException e ) {
				bIsValid = false;
			}
		Test.stopTest();
		system.assert( !bIsValid );
	}

	static testMethod void tickSheetValidation_noneValue_insertSuccess() {
		Boolean bIsValid = true;

		// validation success
		Test.startTest();
			try {
				insert pContact;
			} catch ( DmlException e ) {
				bIsValid = false;
			}
		Test.stopTest();
		system.assert( bIsValid );
	}

	static testMethod void tickSheetValidation_insertSuccess_updateFailure() {
		Boolean bIsValid = true;

		// validation success
		pContact.Tick_Sheet__c = 'London';
		bIsValid = true;
		try {
			insert pContact;
		} catch ( DmlException e ) {
			bIsValid = false;
		}
		system.assert( bIsValid );

		pContact.Tick_Sheet__c = 'New York';
		// validation failure
		Test.startTest();
			try {
				update pContact;
			} catch ( DmlException e ) {
				bIsValid = false;
			}
		Test.stopTest();
		system.assert( !bIsValid );
	}

	static Contact pContact {
		get {
			if ( pContact == null ) {
				pContact = new Contact(
					RecordTypeId = SL_handler_TickSheetValidation.idEmployeeRT,
					LastName = 'TestContact',
					Email = 'TestContact@test.test',
					Available_Ticksheets__c	= 'London;Healthcare',
					Tick_Sheet__c = null
				);
			}
			return pContact;
		} set;
	}
}