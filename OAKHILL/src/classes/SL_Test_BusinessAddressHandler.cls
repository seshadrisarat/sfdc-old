/**
* \arg ClassName      : SL_Test_BusinessAddressHandler
* \arg JIRATicket     : OAKHILL-3
* \arg CreatedOn      : 01/SEP/2014
* \arg LastModifiedOn : 01/SEP/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_BusinessAddressHandler class.
*/
@isTest
private class SL_Test_BusinessAddressHandler 
{
    static testMethod void Test_BusinessAddressHandler() 
    {
    	List<Account> lstAccount = new List<Account>{
    												 new Account(Name = 'TestAccount-01'),
    												 new Account(Name = 'TestAccount-02'),
    												 new Account(Name = 'TestAccount-03')};
    	insert lstAccount;
    	
    	List<Business_Address__c> lstBusinessAddress = new List<Business_Address__c>{
																	 new Business_Address__c(Street__c = 'TestStreet-01', City__c = 'TestCity-01',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[0].Id, Primary_Address__c = false),
																	 new Business_Address__c(Street__c = 'TestStreet-02', City__c = 'TestCity-02',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[0].Id, Primary_Address__c = true),
																	 new Business_Address__c(Street__c = 'TestStreet-03', City__c = 'TestCity-03',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[0].Id, Primary_Address__c = true),
																	 new Business_Address__c(Street__c = 'TestStreet-04', City__c = 'TestCity-04',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[1].Id, Primary_Address__c = false),
																	 new Business_Address__c(Street__c = 'TestStreet-05', City__c = 'TestCity-05',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[1].Id, Primary_Address__c = true),
																	 new Business_Address__c(Street__c = 'TestStreet-06', City__c = 'TestCity-06',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[1].Id, Primary_Address__c = true),
																	 new Business_Address__c(Street__c = 'TestStreet-07', City__c = 'TestCity-07',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[2].Id, Primary_Address__c = false),
																	 new Business_Address__c(Street__c = 'TestStreet-08', City__c = 'TestCity-08',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[2].Id, Primary_Address__c = true),
																	 new Business_Address__c(Street__c = 'TestStreet-09', City__c = 'TestCity-09',
																	 						 Zip_Postal_Code__c = '4545454', State_Province__c = 'Florida',
																			 				 Country__c = 'United States', Organization__c = lstAccount[2].Id, Primary_Address__c = true)};		 				 		 				 
    	insert lstBusinessAddress;
    	Account objAcc1 = [SELECT BillingStreet FROM Account WHERE Id =: lstAccount[0].Id];
    	
    	// Commented temporarily for getting deployed in production as well as activating the Country/State Picklists feature in production
    	system.assertEquals(objAcc1.BillingStreet, 'TestStreet-03');
    	
    	lstBusinessAddress[0].Primary_Address__c = true;
    	lstBusinessAddress[1].City__c = 'TestUpdateCity-01';
    	update lstBusinessAddress[0];
    	update lstBusinessAddress[1];
    	
    	Account objAcc2 = [SELECT BillingCity FROM Account WHERE Id =: lstAccount[0].Id];
    	
    	// Commented temporarily for getting deployed in production as well as activating the Country/State Picklists feature in production
    	system.assertEquals(objAcc2.BillingCity, 'TestUpdateCity-01');

    	delete lstBusinessAddress[4];
    	
    	AggregateResult objAGR = [SELECT COUNT(Id) total FROM Business_Address__c WHERE Organization__c =: lstAccount[1].Id];
    	
    	// Commented temporarily for getting deployed in production as well as activating the Country/State Picklists feature in production
    	system.assertEquals(objAGR.get('total'), 2);
    	
    	
    }
}