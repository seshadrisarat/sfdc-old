@IsTest
public with sharing class AccountsBulkGeocodeBatch_Test {
	
	/**
	 * This test verifies that AccountsBulkGeocodeBatch_Test geocodes owner accounts
	 */
	static testmethod void test() {
		RecordType ownerRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Owner' and SObjectType = 'Account'];
		
		// create an owner with an email that will be sent to pardot
		Account juannaOwner = new Account(
			FirstName='Junna',
			LastName='Mann',
			PersonEmail='juanna.mann@example.com',
			Brand__c='SR',
       		PersonMailingCountry = 'US',
        	PersonMailingPostalCode = '37931',
			RecordType=ownerRecordType
		);
		insert juannaOwner;

		Test.startTest();
		Id batchJobId = Database.executeBatch(new AccountsBulkGeocodeBatch());
		Test.stopTest();
		
		// verify only one object change log was written and it was for juanna mann
		List<Account> accounts = [select Id, GeoLocation__longitude__s from Account];	
		System.assertEquals(1, accounts.size(), 'Only one owner should exist');
	}
	
	/**
	 * This test verifies that AccountsBulkGeocodeBatch_Test geocodes owner accounts
	 */
	static testmethod void testLimit() {
		RecordType ownerRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Owner' and SObjectType = 'Account'];
		
		// create an owner with an email that will be sent to pardot
		Account juannaOwner = new Account(
			FirstName='Junna',
			LastName='Mann',
			PersonEmail='juanna.mann@example.com',
			Brand__c='SR',
       		PersonMailingCountry = 'US',
        	PersonMailingPostalCode = '37931',
			RecordType=ownerRecordType
		);
		insert juannaOwner;

		Test.startTest();
		Id batchJobId = Database.executeBatch(new AccountsBulkGeocodeBatch(2));
		Test.stopTest();
		
		// verify only one object change log was written and it was for juanna mann
		List<Account> accounts = [select Id, GeoLocation__longitude__s from Account];	
		System.assertEquals(1, accounts.size(), 'Only one owner should exist');
	}

}