/*
Author: Kyle Lawson
Created on: March 27, 2014
*/

@isTest
private class SL_Test_Account_Trigger_Handler {

	/* Causes after update trigger on Account to fire, creating four new Contact Info records and setting an old record
		to no longer be a primary contact  */
	static testMethod void testTrigger_SingleAccount(){
		Account acc = new Account(Name = 'Test Account');
		insert acc; 

		Contact_Info__c testContactInfo = new Contact_Info__c(Type__c = 'Email', 
															Is_Primary__c = true, 
															Email__c = 'changeme@test.com', 
															Account__c = acc.Id);
		insert testContactInfo;

		// Create data that will ensure four new Contact Info records are created
		acc.Primary_Email__c	= 'test@test.com'; 
		acc.Phone				= '(888) 888-8888';
		acc.ShippingStreet		= '999 tester street';
		acc.ShippingState		= 'AK';
		acc.ShippingPostalCode	= '99999';
		acc.ShippingCity		= 'testertonville';
		acc.BillingStreet		= '1111 testers boulevard';
		acc.BillingState		= 'VT';
		acc.BillingPostalCode	= '05555';
		acc.BillingCity			= 'testshire';
		acc.RecordTypeId 		= [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id;
		acc.Status__c			= 'Active';

	    update acc; // Should cause trigger to fire, creating four new Contact Info records, and updating one

		List<Contact_Info__c> contactInfos = [SELECT Type__c, Is_Primary__c, Account__c, Email__c, Phone__c, Street__c, State__c, Zip__c, City__c
    							   			  FROM Contact_Info__c
    							   			  WHERE Account__c = :acc.Id];

    	// There should be four new records plus the one originally inserted						   			  
    	System.assertEquals(5, contactInfos.size());

    	for(Contact_Info__c ci : contactInfos){
    		System.assertNotEquals('', ci.Type__c);
    		System.assertNotEquals(null, ci.Type__c);

    		if(ci.Type__c.equals('Email')){

    			if(ci.Email__c.contains('changeme')){
    				System.assertEquals('changeme@test.com', ci.Email__c);
    				System.assertEquals(false, ci.Is_Primary__c); // Should no longer be primary
    			}else{
    				System.assertEquals('test@test.com', ci.Email__c);
    				System.assertEquals(true, ci.Is_Primary__c);
    			}

    		}else if(ci.Type__c.equals('Phone-Home')){
    			System.assertEquals('(888) 888-8888', ci.Phone__c);
    			System.assertEquals(true, ci.Is_Primary__c);
    		
    		}else if(ci.Type__c.equals('Mailing')){
    			System.assertEquals('999 tester street', ci.Street__c);
    			System.assertEquals('AK', ci.State__c);
    			System.assertEquals('99999', ci.Zip__c);
    			System.assertEquals('testertonville', ci.City__c);
    			System.assertEquals(true, ci.Is_Primary__c);
    		
    		}else if(ci.Type__c.equals('Billing')){
    			System.assertEquals('1111 testers boulevard', ci.Street__c);
    			System.assertEquals('VT', ci.State__c);
    			System.assertEquals('05555', ci.Zip__c);
    			System.assertEquals('testshire', ci.City__c);
    			System.assertEquals(true, ci.Is_Primary__c);
    		}
    	}
	}

	// Test that the trigger doesn't fail when fields are blank on the Account and in a Contact Info
	static testMethod void testTrigger_SingleAccount_BlankFields(){
		Account acc = new Account(Name = 'Test Account');
		insert acc; 

		Contact_Info__c blankEmailInfo = new Contact_Info__c(Type__c = 'Email', 
															Is_Primary__c = false, 
															Email__c = '',
															Email_Old__c = '',
															Account__c = acc.Id);

		Contact_Info__c blankPhoneInfo = new Contact_Info__c(Type__c = 'Phone-Home',
																Is_Primary__c = false,
																Phone__c = '',
																Phone_Old__c = '',
																Account__c = acc.Id);

		Contact_Info__c blankMailingInfo = new Contact_Info__c(Type__c = 'Mailing',
															Is_Primary__c = false,
															Street__c = '',
															City__c = '',
															State__c = '',
															Zip__c = '',
															Street_Old__c = '',
															City_Old__c = '',
															State_Old__c = '',
															Zip_Old__c = '',
															Account__c = acc.Id);

		Contact_Info__c blankBillingInfo = new Contact_Info__c(Type__c = 'Billing',
															Is_Primary__c = false,
															Street__c = '',
															City__c = '',
															State__c = '',
															Zip__c = '',
															Street_Old__c = '',
															City_Old__c = '',
															State_Old__c = '',
															Zip_Old__c = '',
															Account__c = acc.Id);

		insert new List<Contact_Info__c>{blankEmailInfo, blankPhoneInfo, blankMailingInfo, blankBillingInfo};

		// Fill an account with blank info, except for Fax which isn't used but will update
		acc.Primary_Email__c	= ''; 
		acc.Phone				= '';
		acc.ShippingStreet		= '';
		acc.ShippingState		= '';
		acc.ShippingPostalCode	= '';
		acc.ShippingCity		= '';
		acc.BillingStreet		= '';
		acc.BillingState		= '';
		acc.BillingPostalCode	= '';
		acc.BillingCity			= '';
		acc.Fax 				= '2222222222';
		acc.RecordTypeId 		= [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id;
		acc.Status__c			= 'Active';

	    update acc; // Should cause trigger to fire, creating no new Contact Info records

		List<Contact_Info__c> contactInfos = [SELECT Type__c, Is_Primary__c, Account__c, Email__c, Phone__c, Street__c, State__c, Zip__c, City__c, Street_Old__c, State_Old__c, Zip_Old__c, City_Old__c
    							   			  FROM Contact_Info__c
    							   			  WHERE Account__c = :acc.Id];

    	// There should be four records, all with blank info and primary-ness unchanged					   			  
    	System.assertEquals(4, contactInfos.size());

    	for(Contact_Info__c ci : contactInfos){
    		System.assertNotEquals('', ci.Type__c);
    		System.assertNotEquals(null, ci.Type__c);

    		if(ci.Type__c.equals('Email')){
				System.assert(String.isBlank(ci.Email__c));
				System.assertEquals(false, ci.Is_Primary__c);
    		
    		}else if(ci.Type__c.equals('Phone-Home')){
    			System.assert(String.isBlank(ci.Phone__c));
    			System.assertEquals(false, ci.Is_Primary__c);
    		
    		}else if(ci.Type__c.equals('Mailing') || ci.Type__c.equals('Billing')){
    			System.assert(String.isBlank(ci.Street__c));
    			System.assert(String.isBlank(ci.City__c));
    			System.assert(String.isBlank(ci.State__c));
    			System.assert(String.isBlank(ci.Zip__c));
    			System.assert(String.isBlank(ci.Street_Old__c));
    			System.assert(String.isBlank(ci.City_Old__c));
    			System.assert(String.isBlank(ci.State_Old__c));
    			System.assert(String.isBlank(ci.Zip_Old__c));
    			System.assertEquals(false, ci.Is_Primary__c);
    		}
    	}
	}

	/* Tests when all of an account's info matches the new information fields in its Contact_Info records, and when all of an account's info matches the old information fields in its Contact_Info records. The result should be that no new Contact_Info records are created, and none of the fields on the existing Contact_Info records should be changed */
	static testMethod void testTrigger_NoNewInfoRecords(){
		Account acc1 = new Account(Name = 'Test Account', 
								   RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id,
								   Status__c = 'Active');
		Account acc2 = new Account(Name = 'Test Account 2',
								   RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id,
								   Status__c = 'Active');

		insert new List<Account>{acc1, acc2};

		// Should be unchanged, matches on regular fields
		Contact_Info__c testContactInfo1 = new Contact_Info__c(Type__c = 'Email', 
															Is_Primary__c = true, 
															Email__c = 'test@test.com',
															Email_Old__c = 'oldemail@test.com',
															Account__c = acc1.Id);

		// Should be unchanged, matches on regular fields
		Contact_Info__c testContactInfo2 = new Contact_Info__c(Type__c = 'Phone-Home',
															Is_Primary__c = true,
															Phone__c = '(888) 888-8888',
															Phone_Old__c = '(000) 000-0000',
															Account__c = acc1.Id);

		// Should be unchanged, matches on regular fields
		Contact_Info__c testContactInfo3 = new Contact_Info__c(Type__c = 'Mailing',
															Is_Primary__c = true,
															Street__c = '999 tester street',
															City__c = 'testertonville',
															State__c = 'AK',
															Zip__c = '99999',
															Street_Old__c = 'oldstreet',
															City_Old__c = 'oldcity',
															State_Old__c = 'oldstate',
															Zip_Old__c = '00000',
															Account__c = acc1.Id);

		// Should be unchanged, matches on regular fields
		Contact_Info__c testContactInfo4 = new Contact_Info__c(Type__c = 'Billing',
															Is_Primary__c = true,
															Street__c = '1111 testers boulevard',
															City__c = 'testshire',
															State__c = 'VT',
															Zip__c = '05555',
															Street_Old__c = 'bstreet',
															City_Old__c = 'bcity',
															State_Old__c = 'bstate',
															Zip_Old__c = '11111',
															Account__c = acc1.Id);

		// Should be unchanged, matches on Old fields
		Contact_Info__c testContactInfo5 = new Contact_Info__c(Type__c = 'Email', 
															Is_Primary__c = true, 
															Email__c = 'test@test.com',
															Email_Old__c = 'oldemail@test.com',
															Account__c = acc2.Id);

		// Should be unchanged, matches on Old fields
		Contact_Info__c testContactInfo6 = new Contact_Info__c(Type__c = 'Phone-Home',
															Is_Primary__c = true,
															Phone__c = '(888) 888-8888',
															Phone_Old__c = '(000) 000-0000',
															Account__c = acc2.Id);

		// Should be unchanged, matches on Old fields
		Contact_Info__c testContactInfo7 = new Contact_Info__c(Type__c = 'Mailing',
															Is_Primary__c = true,
															Street__c = '999 tester street',
															City__c = 'testertonville',
															State__c = 'AK',
															Zip__c = '99999',
															Street_Old__c = '2street',
															City_Old__c = '2city',
															State_Old__c = '2state',
															Zip_Old__c = '22222',
															Account__c = acc2.Id);

		// Should be unchanged, matches on Old fields
		Contact_Info__c testContactInfo8 = new Contact_Info__c(Type__c = 'Billing',
															Is_Primary__c = true,
															Street__c = 'bstreet',
															City__c = 'bcity',
															State__c = 'bstate',
															Zip__c = '11111',
															Street_Old__c = '3street',
															City_Old__c = '3city',
															State_Old__c = '3state',
															Zip_Old__c = '33333',
															Account__c = acc2.Id);

		insert new List<Contact_Info__c>{testContactInfo1, testContactInfo2, testContactInfo3, testContactInfo4, testContactInfo5, testContactInfo6, testContactInfo7, testContactInfo8};

		// Create data that will ensure no new Contact Info records are created
		acc1.Primary_Email__c	= 'test@test.com'; 
		acc1.Phone				= '(888) 888-8888';
		acc1.ShippingStreet		= '999 tester street';
		acc1.ShippingCity		= 'testertonville';
		acc1.ShippingState		= 'AK';
		acc1.ShippingPostalCode	= '99999';
		acc1.BillingStreet		= '1111 testers boulevard';
		acc1.BillingCity		= 'testshire';
		acc1.BillingState		= 'VT';
		acc1.BillingPostalCode	= '05555';
		acc1.RecordTypeId 		= [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id;
		acc1.Status__c			= 'Active';


	    // Create data that will ensure no new Contact Info records are created, and will match on 'old' fields
		acc2.Primary_Email__c	= 'oldemail@test.com';
		acc2.Phone				= '(000) 000-0000';
		acc2.ShippingStreet		= '2street';
		acc2.ShippingCity		= '2city';
		acc2.ShippingState		= '2state';
		acc2.ShippingPostalCode	= '22222';
		acc2.BillingStreet		= '3street';
		acc2.BillingCity		= '3city';
		acc2.BillingState		= '3state';
		acc2.BillingPostalCode	= '33333';
		acc2.RecordTypeId 		= [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id;
		acc2.Status__c			= 'Active';

	    update new List<Account> {acc1, acc2}; // Should cause trigger to fire, creating no new Contact Info records

	    List<ID> accountIds = new List<ID>{acc1.id, acc2.id};

		List<Contact_Info__c> contactInfos = [SELECT Type__c, Is_Primary__c, Account__c, Email__c, Phone__c, Street__c, State__c, Zip__c, City__c, Phone_Old__c, Email_Old__c, Street_Old__c, City_Old__c, State_Old__c, Zip_Old__c
    							   			  FROM Contact_Info__c
    							   			  WHERE Account__c in :accountIds];

    	// There should be 8 records which already existed before trigger					   			  
    	System.assertEquals(8, contactInfos.size());

    	for(Contact_Info__c ci : contactInfos){
    		System.assertNotEquals('', ci.Type__c);
    		System.assertNotEquals(null, ci.Type__c);

    		if(ci.Account__c == acc1.id){ // Make sure all non-'old' fields unchanged

    			if(ci.Type__c.equals('Email')){
    				System.assertEquals('test@test.com', ci.Email__c);
    				System.assertEquals(true, ci.Is_Primary__c);
    			}

    			if(ci.Type__c.equals('Phone-Home')) {
    				System.assertEquals('(888) 888-8888', ci.Phone__c);
    				System.assertEquals(true, ci.Is_Primary__c);
    			}

    			if(ci.Type__c.equals('Mailing')) {
    				System.assertEquals('999 tester street', ci.Street__c);
    				System.assertEquals('testertonville', ci.City__c);
					System.assertEquals('AK', ci.State__c);
					System.assertEquals('99999', ci.Zip__c);										
					System.assertEquals(true, ci.Is_Primary__c);										
    			}

    			if(ci.Type__c.equals('Billing')){
    				System.assertEquals('1111 testers boulevard', ci.Street__c);
    				System.assertEquals('testshire', ci.City__c);
					System.assertEquals('VT', ci.State__c);
					System.assertEquals('05555', ci.Zip__c);										
					System.assertEquals(true, ci.Is_Primary__c);
    			}
    		} else{ // Account ID == acc2.id, make sure all 'old' fields are unchanged

    			if(ci.Type__c.equals('Email')){
    				System.assertEquals('oldemail@test.com', ci.Email_Old__c);
    				System.assertEquals(true, ci.Is_Primary__c);
    			}

    			if(ci.Type__c.equals('Phone-Home')) {
    				System.assertEquals('(000) 000-0000', ci.Phone_Old__c);
    				System.assertEquals(true, ci.Is_Primary__c);
    			}

    			if(ci.Type__c.equals('Mailing')) {
    				System.assertEquals('2street', ci.Street_Old__c);
    				System.assertEquals('2city', ci.City_Old__c);
					System.assertEquals('2state', ci.State_Old__c);
					System.assertEquals('22222', ci.Zip_Old__c);										
					System.assertEquals(true, ci.Is_Primary__c);										
    			}

    			if(ci.Type__c.equals('Billing')){
    				System.assertEquals('3street', ci.Street_Old__c);
    				System.assertEquals('3city', ci.City_Old__c);
					System.assertEquals('3state', ci.State_Old__c);
					System.assertEquals('33333', ci.Zip_Old__c);										
					System.assertEquals(true, ci.Is_Primary__c);
    			}
    		}
    	}
	}

	/* Tests multiple cases all at once. 

	First case: We have an Account with four Contact Info records which don't have the same information as that on the Account but are set as Primary, and one record which doesn't match and isn't set as primary. 
	Result: be that the four existing primary records are no longer set as primary, the one non-primary record is left alone, and four new Contact Info records are created with the information from Account and set as primary.

	Second case: We have an Account with no Contact Info records. 
	Result: Four new Contact Info records are created with information from Account and set as primary

	Third case: We have an Account with one Contact Info record which has the same information as that on Account but isn't set as primary.
	Result: The existing Contact Info record should be set as primary and three new Contact Info records should be created with information from Account and set as primary. */
	static testMethod void testTrigger_MultipleAccountsAndContactInfo() {

		// Will have four of it's Contact Info records updated, one left alone and four new ones created, for a total of 9
		Account account = new Account(Name = 'test',
									  RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id,
								      Status__c = 'Active');

		// Will have four new Contact Info records added
		Account account_NoContactInfos = new Account(Name = 'test2',
													 RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id,
								   					 Status__c = 'Active');

		// Will have one record updated to primary and three new Contact Info records created
		Account account_OneContactInfos = new Account(Name = 'test3',
													  RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id,
								   					  Status__c = 'Active');

		insert new List<Account>{account, account_NoContactInfos, account_OneContactInfos};

		// Should no longer be primary after trigger
		Contact_Info__c testContactInfo1 = new Contact_Info__c(Type__c = 'Email', 
															Is_Primary__c = true, 
															Email__c = 'changeme@test.com',
															Email_Old__c = 'oldemail@test.com',
															Account__c = account.Id);
		// Should no longer be primary after trigger
		Contact_Info__c testContactInfo2 = new Contact_Info__c(Type__c = 'Phone-Home',
															Is_Primary__c = true,
															Phone__c = '(777) 777-7777',
															Phone_Old__c = '(000) 000-0000',
															Account__c = account.Id);
		// Should no longer by primary after trigger
		Contact_Info__c testContactInfo3 = new Contact_Info__c(Type__c = 'Mailing',
															Is_Primary__c = true,
															Street__c = 'mstreet',
															City__c = 'mcity',
															State__c = 'mstate',
															Zip__c = 'mzip',
															Street_Old__c = 'oldstreet',
															City_Old__c = 'oldcity',
															State_Old__c = 'oldstate',
															Zip_Old__c = 'oldzip',
															Account__c = account.Id);
		// Should no longer be primary after trigger
		Contact_Info__c testContactInfo4 = new Contact_Info__c(Type__c = 'Billing',
															Is_Primary__c = true,
															Street__c = 'bstreet',
															City__c = 'bcity',
															State__c = 'bstate',
															Zip__c = 'bzip',
															Street_Old__c = 'oldstreet',
															City_Old__c = 'oldcity',
															State_Old__c = 'oldstate',
															Zip_Old__c = 'oldzip',
															Account__c = account.Id);
		// Should be unchanged
		Contact_Info__c testContactInfo5 = new Contact_Info__c(Type__c = 'Email', 
															Is_Primary__c = false, 
															Email__c = 'email2@test.com',
															Email_Old__c = 'oldemail2@test.com',
															Account__c = account.Id);

		// Will be updated to Primary
		Contact_Info__c testContactInfo6 = new Contact_Info__c(Type__c = 'Phone-Home',
															Is_Primary__c = false,
															Phone__c = '(555) 555-5555',
															Phone_Old__c = '(000) 000-0000',
															Account__c = account_OneContactInfos.Id);


		insert new List<Contact_Info__c>{testContactInfo1, testContactInfo2, testContactInfo3, testContactInfo4, testContactInfo5, testContactInfo6};

		// Add fields to each account, this will cause trigger to fire
		account.Primary_Email__c	= 'test@test.com';
		account.Phone				= '(666) 666-6666';
		account.ShippingStreet		= '888 road';
		account.ShippingState		= 'NY';
		account.ShippingPostalCode	= '12345';
		account.ShippingCity		= 'big city';
		account.BillingStreet		= 'streettest';
		account.BillingState		= 'AL';
		account.BillingPostalCode	= '98765';
		account.BillingCity			= 'citytest';
		account.RecordTypeId 		= [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id;
		account.Status__c			= 'Active';

		account_OneContactInfos.Primary_Email__c	= 'test3@test.com';
		account_OneContactInfos.Phone				= '(555) 555-5555';
		account_OneContactInfos.ShippingStreet		= '111 long road';
		account_OneContactInfos.ShippingState		= 'NH';
		account_OneContactInfos.ShippingPostalCode	= '11111';
		account_OneContactInfos.ShippingCity		= 'testtown';
		account_OneContactInfos.BillingStreet		= '222 testers lane';
		account_OneContactInfos.BillingState		= 'OK';
		account_OneContactInfos.BillingPostalCode	= '22222';
		account_OneContactInfos.BillingCity			= 'testington';
		account_OneContactInfos.RecordTypeId 		= [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id;
		account_OneContactInfos.Status__c			= 'Active';

		account_NoContactInfos.Primary_Email__c		= 'test2@test.com';
		account_NoContactInfos.Phone				= '(888) 888-8888';
		account_NoContactInfos.ShippingStreet		= '999 tester street';
		account_NoContactInfos.ShippingState		= 'AK';
		account_NoContactInfos.ShippingPostalCode	= '99999';
		account_NoContactInfos.ShippingCity			= 'testertonville';
		account_NoContactInfos.BillingStreet		= '1111 testers boulevard';
		account_NoContactInfos.BillingState			= 'VT';
		account_NoContactInfos.BillingPostalCode	= '05555';
		account_NoContactInfos.BillingCity			= 'testshire';
		account_NoContactInfos.RecordTypeId 		= [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id;
		account_NoContactInfos.Status__c			= 'Active';

		update new List<Account>{account, account_OneContactInfos, account_NoContactInfos};

		List<ID> accountIds = new List<ID>{account.id, account_OneContactInfos.id, account_NoContactInfos.id};	
		List<Contact_Info__c> infoList = [SELECT Type__c, Is_Primary__c, Street__c, Phone__c, Email__c, Account__c
										  FROM Contact_Info__c
										  WHERE Account__r.id in :accountIds];

		// Account: 9 records + Account_NoContactInfos: 4 records + Account_OneContactInfos: 4 records = 17 records
		System.assertEquals(17, infoList.size());

		for(Contact_Info__c ci : infoList){

			// Test that Contact Info records were either updated or created correctly for account
			if(ci.Account__c == account.id){

				if(ci.Type__c == 'Email'){
					if(ci.Email__c == 'changeme@test.com') // Old record
						System.assertEquals(false, ci.Is_Primary__c);
					else if(ci.Email__c == 'email2@test.com'){ // Unchanged record
						System.assertEquals(false, ci.Is_Primary__c);
					}else{ // New Record
						System.assertEquals(true, ci.Is_Primary__c);
						System.assertEquals('test@test.com', ci.Email__c);
					}
				}

				if(ci.Type__c == 'Phone'){
					if(ci.Phone__c == '(777) 777-7777') // Old record
						System.assertEquals(false, ci.Is_Primary__c);
					else{ // New Record
						System.assertEquals(true, ci.Is_Primary__c);
						System.assertEquals('(666) 666-6666', ci.Phone__c);
					}
				}

				if(ci.Type__c == 'Mailing'){
					if(ci.Street__c == 'mstreet') // Old record
						System.assertEquals(false, ci.Is_Primary__c);
					else{ // New Record
						System.assertEquals(true, ci.Is_Primary__c);
						System.assertEquals('888 road', ci.Street__c);
					}
				}


				if(ci.Type__c == 'Billing'){
					if(ci.Street__c == 'bstreet') // Old record
						System.assertEquals(false, ci.Is_Primary__c);
					else{ // New Record
						System.assertEquals(true, ci.Is_Primary__c);
						System.assertEquals('streettest', ci.Street__c);
					}
				}

			// Testing that completely new records were created when none existed before
			}else if(ci.Account__c == account_NoContactInfos.id){

				if(ci.Type__c == 'Email'){
					System.assertEquals(true, ci.Is_Primary__c);
					System.assertEquals('test2@test.com', ci.Email__c);
				}

				if(ci.Type__c == 'Phone'){
					System.assertEquals(true, ci.Is_Primary__c);
					System.assertEquals('(888) 888-8888', ci.Phone__c);
				}

				if(ci.Type__c == 'Mailing'){
					System.assertEquals(true, ci.Is_Primary__c);
					System.assertEquals('999 tester street', ci.Street__c);
				}

				if(ci.Type__c == 'Billing'){
					System.assertEquals(true, ci.Is_Primary__c);
					System.assertEquals('1111 testers boulevard', ci.Street__c);
				}

			// Testing when a Contact_Info record exists it is updated to primary if it matches existing info and new records are created for the non-matching info
			}else if(ci.Account__c == account_OneContactInfos.id){

				if(ci.Type__c == 'Email'){ // New record
					System.assertEquals(true, ci.Is_Primary__c);
					System.assertEquals('test3@test.com', ci.Email__c);
				}

				if(ci.Type__c == 'Phone'){ // Existing record
					System.assertEquals(true, ci.Is_Primary__c);
					System.assertEquals('(555) 555-5555', ci.Phone__c);
				}

				if(ci.Type__c == 'Mailing'){ // New Record
					System.assertEquals(true, ci.Is_Primary__c);
					System.assertEquals('111 long road', ci.Street__c);
				}

				if(ci.Type__c == 'Billing'){ // New Record
					System.assertEquals(true, ci.Is_Primary__c);
					System.assertEquals('222 testers lane', ci.Street__c);
				}
			}
		}
	}

	/* Tests method FindRelatedContactInfo in trigger handler by creating and inserting one account, 
	and 6 contact infos. Then provides a map to the method containing the account and its id, and 
	checks the output for the correct number of entries */
	static testMethod void testFindRelatedContactInfo() {

		Account account = new Account(Name = 'test', 
									  RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Member' AND sObjectType = 'Account'].id,
								      Status__c = 'Active');
		insert account;

		Contact_Info__c testContactInfo1 = new Contact_Info__c(Type__c = 'Email', 
															Is_Primary__c = true, 
															Email__c = 'changeme@test.com', 
															Account__c = account.Id);

		Contact_Info__c testContactInfo2 = new Contact_Info__c(Type__c = 'Phone-Home',
															Is_Primary__c = true,
															Phone__c = '(999) 999-9999',
															Account__c = account.Id);

		Contact_Info__c testContactInfo3 = new Contact_Info__c(Type__c = 'Mailing',
															Is_Primary__c = true,
															Street__c = 'mstreet',
															City__c = 'mcity',
															State__c = 'mstate',
															Zip__c = 'mzip',
															Account__c = account.Id);

		Contact_Info__c testContactInfo4 = new Contact_Info__c(Type__c = 'Billing',
															Is_Primary__c = true,
															Street__c = 'bstreet',
															City__c = 'bcity',
															State__c = 'bstate',
															Zip__c = 'bzip',
															Account__c = account.Id);

		Contact_Info__c testContactInfo5 = new Contact_Info__c(Type__c = 'Email', 
															Is_Primary__c = false, 
															Email__c = 'email2@test.com', 
															Account__c = account.Id);

		Contact_Info__c testContactInfo6 = new Contact_Info__c(Type__c = 'Phone-Home',
															Is_Primary__c = false,
															Phone__c = '(555) 555-5555',
															Account__c = account.Id);

		insert new List<Contact_Info__c>{testContactInfo1, testContactInfo2, testContactInfo3, testContactInfo4, testContactInfo5, testContactInfo6};

		Map<Id, Account> newAccountMap = new Map<Id, Account>{account.Id => account};

		SL_Account_Trigger_Handler handler = new SL_Account_Trigger_Handler(false, 1);

		Map<Id, Map<String, List<Contact_Info__c>>> relatedContactInfo = handler.findRelatedContactInfo(newAccountMap);

		System.assertEquals(1, relatedContactInfo.size()); // Only one account
		System.assertEquals(4, relatedContactInfo.get(account.id).size()); // Four Contact_Info types
		System.assertEquals(2, relatedContactInfo.get(account.id).get('Email').size()); // 2 Contact_Info records of type Email
		System.assertEquals(2, relatedContactInfo.get(account.id).get('Phone').size()); // 2 Contact_Info records of type Phone
		System.assertEquals(1, relatedContactInfo.get(account.id).get('Mailing').size()); // 1 Contact_Info record of type Mailing
		System.assertEquals(1, relatedContactInfo.get(account.id).get('Billing').size()); // 1 Contact_Info record of type Billing
	}
}