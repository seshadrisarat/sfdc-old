@isTest(SeeAllData=true)
public with sharing class SL_Test_BidHandler {
	
	 static testMethod void test_SL_handler_Bid() 
    {
    	
    	Account objAccount = new Account(Name ='Test 201502 Account', Public_Private__c = 'public',Sector__c='CIS-Business Services',Geographies__c = 'Africa');
    	insert objAccount;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        Contact objContact = new Contact(LastName = 'Test 201502 Contact 24', RecordTypeId = ContRecTypeId.Id,  User_ID__c = UserInfo.getUserId() );
        insert objContact;
    	
//    	Deal__c objdeal = new Deal__c(Name = 'Test Deal',Company__c= objAccount.id,Description__c='test',WP_Groups_picklist__c='Energy',CurrencyIsoCode = 'EUR');
        Deal__c objdeal = new Deal__c(Name = 'Test 201502 Deal',Company__c= objAccount.id,Description__c='test',WP_Groups_picklist__c='Energy',CurrencyIsoCode = 'EUR', Is_Energy_Opportunity__c = 'No');
    	insert objdeal;
    	
    	Bid__c objBid = new Bid__c( Deal__c = objdeal.id ,CurrencyIsoCode = 'EUR');
    	insert objBid;
    	
    	objBid.Bid_Date__c = Date.newInstance(2013, 12, 1);
    	update objBid;
    	
    	delete objBid;
    	
    }
    

}