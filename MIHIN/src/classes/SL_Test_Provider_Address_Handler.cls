/*
*Class: SL_Test_Provider_Address_Handler
*Description: This test class is used to test Provider Address trigger functionality and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@IsTest
public class SL_Test_Provider_Address_Handler
{
	@IsTest
    private static void Tes_Contact_Address_Mapping_From_PA()
    {
        // Inserting Contact Records
        List<Contact> lstCons = New List<Contact>{new Contact(LastName = 'Test-01', Email = 'Test123@test.com'), new Contact(LastName = 'Test-02', Email = 'Test456@test.com')};
        insert lstCons;
        // Checking that both the Contacts got inserted
        system.assert(lstCons[0].Id != NULL);
        system.assert(lstCons[1].Id != NULL);
        
        // Inserting Custom setting record 
        List<Provider_Address_Settings__c> lstProviderAddressSetting = new List<Provider_Address_Settings__c>{new Provider_Address_Settings__c(Name = 'Mailing', Prefix__c = 'Mailing', Suffix__c = ''),
        																									  new Provider_Address_Settings__c(Name = 'Practice', Prefix__c = 'Other', Suffix__c = '', Geocoding_Required__c = true)};
        insert lstProviderAddressSetting;
        
        // Inserting this record to throw an error as the type of this PA is not exists in the Custom setting
        Provider_Address__c objPA1 = new Provider_Address__c(Provider__c = lstCons[0].id, Primary__c = true, Type__c = 'Service', 
        												 	Street_Address_1__c = 'test', Street_Address_2__c = 'test',Street_Address_3__c = 'test', City__c = 'test city', 
        												 	State__c = 'tt', Postal_Code__c = '73s t3r');
        try{
        	insert objPA1;
        }
        catch(Exception ex){
        	system.assert(String.valueOf(ex.getMessage()).contains('INVALID ADDRESS TYPE: Service. A Provider Address can only be be primary if it is mapped in the Provider_Address_Settings__c Custom Setting.'));
        }
        
        
        Test.startTest();
        
        List<Provider_Address__c> lstProviderAddress = new List<Provider_Address__c>{new Provider_Address__c(Provider__c = lstCons[0].id, Primary__c = true, Type__c = 'Mailing',			 /***** FOR Test-01 Contact****/  
												            												 	Street_Address_1__c = 'Test-01-Service-Add1', Street_Address_2__c = 'Test-01-Service-Add2',Street_Address_3__c = 'Test-01-Service-Add3', City__c = 'Test-01-Service-city', 
												            												 	State__c = 'S1', Postal_Code__c = '73s t3r'), 		
        																			 new Provider_Address__c(Provider__c = lstCons[1].id, Primary__c = true, Type__c = 'Mailing', 			 /***** FOR Test-02 Contact****/ 
												            												 	Street_Address_1__c = 'Test-02-Mailing-Add1', Street_Address_2__c = 'Test-02-Mailing-Add2',Street_Address_3__c = 'Test-02-Mailing-Add3', City__c = 'Test-02-Mailing-city', 
												            												 	State__c = 'S2', Postal_Code__c = '74s t4r'), 
        																			 new Provider_Address__c(Provider__c = lstCons[1].id, Primary__c = true, Type__c = 'Practice', 			 /***** FOR Test-02 Contact****/ 
												            												 	Street_Address_1__c = 'Test-02-Practice-Add1', Street_Address_2__c = 'Test-02-Practice-Add2',Street_Address_3__c = 'Test-02-Practice-Add3', City__c = 'Test-02-Practice-city', 
												            												 	State__c = 'S3', Postal_Code__c = '75s t5r')};
        insert lstProviderAddress;
        system.assert(lstProviderAddress[0].Id != NULL);
        system.assert(lstProviderAddress[1].Id != NULL);
        system.assert(lstProviderAddress[2].Id != NULL);
        
        List<Contact> lstContacts = [Select Type__c, OtherStreet, OtherState, OtherPostalCode, OtherPhone, OtherCountry, OtherCity, LastName, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Geocoding_Required__c 
        							 From Contact
        							 Where Id IN : lstCons];
        // Checking the field values for 1st Contact
        system.assertEquals(lstContacts[0].LastName, 'Test-01');
        
        /* Test - 01 */
        system.assertEquals(lstContacts[0].MailingState, 'S1');
        system.assertEquals(lstContacts[0].MailingCity,'Test-01-Service-city');
        system.assertEquals(lstContacts[0].MailingStreet, 'Test-01-Service-Add1\nTest-01-Service-Add2\nTest-01-Service-Add3');
        system.assertEquals(lstContacts[0].MailingPostalCode, '73s t3r');
        system.assertEquals(lstContacts[0].Geocoding_Required__c,false);	// As the custom setting's Geocoding_Required__c is FALSE
        
        /* TEST-02 */ 
        system.assertEquals(lstContacts[1].MailingState, 'S2');
        system.assertEquals(lstContacts[1].MailingCity, 'Test-02-Mailing-city');
        system.assertEquals(lstContacts[1].MailingStreet, 'Test-02-Mailing-Add1\nTest-02-Mailing-Add2\nTest-02-Mailing-Add3');
        system.assertEquals(lstContacts[1].MailingPostalCode, '74s t4r');
        
        system.assertEquals(lstContacts[1].OtherState, 'S3');
        system.assertEquals(lstContacts[1].OtherCity, 'Test-02-Practice-city');
        system.assertEquals(lstContacts[1].Geocoding_Required__c,true);		// As the custom setting's Geocoding_Required__c is TRUE
        system.assertEquals(lstContacts[1].OtherStreet, 'Test-02-Practice-Add1\nTest-02-Practice-Add2\nTest-02-Practice-Add3');
        system.assertEquals(lstContacts[1].OtherPostalCode, '75s t5r');
        
        // Checking the field values for 2nd Contact
        system.assertEquals(lstContacts[1].LastName, 'Test-02');
        
        // Updating the PA Type__c from Mailing to Practice of the 1st contact
        lstProviderAddress[0].Type__c = 'Practice';
        update lstProviderAddress[0];
        // Getting the info of the 1st Contact
        Contact obj1stContact = [Select Type__c, OtherStreet, OtherState, OtherPostalCode, OtherPhone, OtherCountry, OtherCity, LastName, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Geocoding_Required__c 
        							 From Contact
        							 Where Id =: lstCons[0].Id];
        // Checking the Contact field values after updating the Type__c field of PA.. i.e Mailing Address became blank and OtherAddress filled
        //system.assertEquals(obj1stContact.MailingState, NULL);
        //system.assertEquals(obj1stContact.MailingCity,NULL);
        //system.assertEquals(obj1stContact.MailingStreet, NULL);
        //system.assertEquals(obj1stContact.MailingPostalCode, NULL);
        // For OtherAddress, the values for the 1st Contact
        //system.assertEquals(obj1stContact.OtherState, 'S1');
        //system.assertEquals(obj1stContact.OtherCity, 'Test-01-Service-city');
        //system.assertEquals(obj1stContact.Geocoding_Required__c,true);		// As the Type change to "Practice"
        //system.assertEquals(obj1stContact.OtherStreet, 'Test-01-Service-Add1\nTest-01-Service-Add2\nTest-01-Service-Add3');
        //system.assertEquals(obj1stContact.OtherPostalCode, '73s t3r');	
        
        // Updating the 2nd PA Type__c from Practice to Mailing of the 2nd contact
        lstProviderAddress[2].Type__c = 'Mailing';
        update lstProviderAddress[2];
        // Getting the info of the 2nd Contact
        Contact obj2ndContact = [Select Type__c, OtherStreet, OtherState, OtherPostalCode, OtherPhone, OtherCountry, OtherCity, LastName, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Geocoding_Required__c 
        							 From Contact
        							 Where Id =: lstCons[1].Id];
        // Checking the Contact field values after updating the Type__c field of PA.. i.e Mailing Address filled and Other Address became Blank as Both the PAs related to 2nd Contact has only "Mailing" Type
        system.assertEquals(obj2ndContact.OtherState, NULL);
        system.assertEquals(obj2ndContact.OtherCity,NULL);
        system.assertEquals(obj2ndContact.OtherStreet, NULL);
        system.assertEquals(obj2ndContact.OtherPostalCode, NULL);
        // For MailingAddress, the values for the 1st Contact
        system.assertEquals(obj2ndContact.MailingState, 'S3');
        system.assertEquals(obj2ndContact.MailingCity, 'Test-02-Practice-city');
        system.assertEquals(obj2ndContact.MailingStreet, 'Test-02-Practice-Add1\nTest-02-Practice-Add2\nTest-02-Practice-Add3');
        system.assertEquals(obj2ndContact.MailingPostalCode, '75s t5r');
        // system.assertEquals(obj2ndContact.Geocoding_Required__c,false);		// As the both the PA's type is now "Mailing"	
        
        //Deleting the PA of the 1st Contact
        Delete lstProviderAddress[0];
        obj1stContact = [Select Type__c, OtherState, MailingState From Contact Where Id =: lstCons[0].Id];
        // After deleting the record, we are nullyfying both the OtherAddress and MailingAddress of 1st contact as no PAs left for the 1st Contact
        system.assertEquals(obj1stContact.OtherState, NULL);
        //system.assertEquals(obj1stContact.MailingState, NULL);
        
        // Deleting the 2nd PA of 2nd Contact
        Delete lstProviderAddress[2];
        // Getting the info of the 2nd Contact
        obj2ndContact = [Select Type__c, OtherState, MailingState From Contact Where Id =: lstCons[1].Id];
        // After deleting the 2nd PRIMARY PA record, we are nullyfying both the OtherAddress and MailingAddress of 2nd contact as no PRIMARY PAs left for this COntact.
        //system.assertEquals(obj2ndContact.OtherState, NULL);
        //system.assertEquals(obj2ndContact.MailingState, NULL);
        
        Test.stopTest();
        
        // For incresing test coverage for the boolean variables
        SL_Provider_Address_Handler objSLProviderAddressHandler = new SL_Provider_Address_Handler(false, 20); 
        system.debug('= IsTriggerContext =>' +objSLProviderAddressHandler.IsTriggerContext);
        system.debug('= IsVisualforcePageContext =>' +objSLProviderAddressHandler.IsVisualforcePageContext);
        system.debug('= IsWebServiceContext =>' +objSLProviderAddressHandler.IsWebServiceContext);
        system.debug('= IsExecuteAnonymousContext =>' +objSLProviderAddressHandler.IsExecuteAnonymousContext);
    }
}