/*
*Class: SL_Test_UpdateProviderAccountAddress
*Description: This test class is used to check the functionality of SL_Scheduler_UpdateProviderAccountAddres class and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_UpdateProviderAccountAddress 
{
    static testMethod void myUnitTest()
    {
      list<Provider_Address_Settings__c> pas = new list<Provider_Address_Settings__c>{
            new Provider_Address_Settings__c(Name='Practice',Prefix__c='Other',Geocoding_Required__c=TRUE),
            new Provider_Address_Settings__c(Name='Mailing',Prefix__c='Mailing')
      };
      insert pas;

       List<Account> lstAccount = new List<Account>{
       												 new Account(Name = 'Test Organization1'),
       												 new Account(Name = 'Test Organization2')
       												};
       insert lstAccount;
       
       List<Contact> lstContact = new List<Contact>{
       												 new Contact(LastName = 'Test Contact1'),
       												 new Contact(LastName = 'Test Contact2')
       												};
       insert lstContact;
       
       List<Provider_Address__c> lstProviderAddress = new List<Provider_Address__c>{ new Provider_Address__c(Provider__c = lstContact[0].Id, Type__c = 'Mailing',Street_Address_1__c = 'Test Street 1',
       																									 	 Street_Address_2__c = 'Test Street 2', Street_Address_3__c = 'Test Street 3',
       																									 	 City__c = 'New York',State__c = 'NY', Primary__c = true),
       																				 new Provider_Address__c(Provider__c = lstContact[1].Id, Type__c = 'Practice',Street_Address_1__c = 'Test Street 1',
       																									 	 Street_Address_2__c = 'Test Street 2', Street_Address_3__c = 'Test Street 3',
       																									 	 City__c = 'New York',State__c = 'NY', Primary__c=true)
       																				};
       insert lstProviderAddress;
       
       List<Organization_Address__c> lstOrganizationAddress = new List<Organization_Address__c>{ new Organization_Address__c(Organization__c = lstAccount[0].Id, Type__c = 'Billing',Street_Address_1__c = 'Test Street 1',
       																									 	 				 Street_Address_2__c = 'Test Street 2', Street_Address_3__c = 'Test Street 3',
       																									 	 				 City__c = 'New York',State__c = 'NY', Primary__c = true),
       																						     new Organization_Address__c(Organization__c = lstAccount[1].Id, Type__c = 'Practice',Street_Address_1__c = 'Test Street 1',
       																									 	 				 Street_Address_2__c = 'Test Street 2', Street_Address_3__c = 'Test Street 3',
       																									 	 				 City__c = 'New York',State__c = 'NY', Primary__c = true)
       																						   };
       insert lstOrganizationAddress;
       
       Test.startTest();
       System.schedule('Test Job', '0 0 * * * ?', new SL_Scheduler_UpdateProviderAccountAddres());
       Test.stopTest();
    }
}