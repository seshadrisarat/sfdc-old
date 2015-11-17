/*
Developer   : Poundarik, Shruti
Company 	: Bluewolf LLC
*/

@isTest
private class TestDealerLocator {
	static Account dealerAcc1, dealerAcc2, dealerAcc3, dealerAcc4;
	static Dealer_Brand__c dealerBrand1, dealerBrand2, dealerBrand3;
	static map<String,Id> selectedRecordTypes = new map<String, Id>();
	final static String dealerRecordType;
	
	@isTest static void testExcludeCertainDealers(){
		
		Dealer_Types_to_Exclude_from_Locator__c cs1 = new Dealer_Types_to_Exclude_from_Locator__c(Name='type1', Dealer_Type__c='Non-Selling Location');
		Dealer_Types_to_Exclude_from_Locator__c cs2 = new Dealer_Types_to_Exclude_from_Locator__c(Name='type2', Dealer_Type__c='Previous Dealer');
		Dealer_Types_to_Exclude_from_Locator__c cs3 = new Dealer_Types_to_Exclude_from_Locator__c(Name='type3', Dealer_Type__c='Prospect');
		insert new list<Dealer_Types_to_Exclude_from_Locator__c>{cs1, cs2, cs3};
		
    	Integer expectedDealerInfoSize = 1;
		
		selectedRecordTypes = TestUtilities.getRecordTypesMap();
	    list<Account> dealerLists = TestUtilities.createTestAccount(4,'test',selectedRecordTypes.get('Dealer'),'112 E. HIGH STREET', 'Santa Clara','CA','95035','Canada','CA', '111 555 2222','bluewolf.com', 'SR');
	    Integer x = 0;
	    for( Account dealer : dealerLists )
	    {
	    	dealer.latitude__c = 37.4352 ;
	    	dealer.longitude__c = -121.895;
	    	dealer.Dealer_Number__c = 'test '+ x++;
	    }
	    
	    dealerAcc1 = dealerLists[0];
	    dealerAcc1.Dealer_Type__c = 'Non-Selling Location';
	    
	    dealerAcc2 = dealerLists[1];
	    dealerAcc2.Dealer_Type__c = 'Previous Dealer';
	    
	    dealerAcc3 = dealerLists[2];
	    dealerAcc3.Dealer_Type__c = 'Prospect';
	    
	    dealerAcc4 = dealerLists[3];
	    
	    insert dealerLists;
	    
	    
	    
	    
	    List<Dealer_Brand__c> dbrands = TestUtilities.createDealerBrand(dealerLists);
        
        for( integer i = 0; i < dbrands.size(); i++ )
        {
	        dbrands[i].Brand__c = 'BL';
        }
        
        insert dbrands;
       
	    
	    Map<Id, Account> accMap = new Map<Id, Account>(dealerLists);
	    
	    GeoNamesWebService.isApexTest = true;
	    
	    Test.startTest();
	    	list<DealerInfo> dealerInfoList = DealerLocator.getDealerInfo('95035','CA');
    	Test.stopTest();
	    System.assertEquals(expectedDealerInfoSize, dealerInfoList.size(), 'We expect to retrieve the correct number of dealer info items after filtering dealers with certain picklist values.');
		System.assertEquals(dealerAcc4.Id, dealerInfoList[0].dealerId, 'We expect to get back the Dealer account that was not excluded in the custom settings');
    }	

	@isTest static void dealerLocatorResponse(){
     	givenDealers();
     	thencheckInformationReturned();
     } 
     
    private static void  givenDealers(){
       selectedRecordTypes = TestUtilities.getRecordTypesMap();
       list<Account> dealerLists = TestUtilities.createTestAccount(3,'test',selectedRecordTypes.get('Dealer'),'112 E. HIGH STREET', 'HENNEPIN','IL','61327','United States','US', '111 555 2222','bluewolf.com', 'SR');
       insert dealerLists;
       dealerAcc1 = dealerLists[0];
       dealerAcc2 = dealerLists[1]; 
       dealerAcc3 = dealerLists[2];
       
       Dealer_Brand__c db1 = TestUtilities.createDealerBrand(dealerLists[0],1);
       insert db1;
       Dealer_Brand__c db2 = TestUtilities.createDealerBrand(dealerLists[1],1);
       insert db2;
                                    
    }
    
    private static void  thencheckInformationReturned(){
     GeoNamesWebService.isApexTest = true;
     list<DealerInfo> dealerInfoList = DealerLocator.getDealerInfo('61327','US');
     system.assertNotEquals(null,dealerInfoList[0].exceptionMessage,'Dealer 1 should not have an exception message since it has an ACTIVE dealer brand');
    }	
   
    @isTest static void dealerLocatorResponseWhenPostalCodeandCountryInfoPassed(){
     	givenOneDealerTiedTODealerBrand();
     	thenOnlyOneDealerMustBeReturned();
     }
     
          
    private static void  givenOneDealerTiedTODealerBrand(){
       selectedRecordTypes = TestUtilities.getRecordTypesMap();
       list<Account> dealerList1 = TestUtilities.createTestAccount(1,'test1',selectedRecordTypes.get('Dealer'),'112 E. HIGH STREET', 'HENNEPIN','IL','61327','United States','US', '111 555 2222','bluewolf.com', 'SR');
       insert dealerList1;
       
       list<Account> dealerList2 = TestUtilities.createTestAccount(1,'test2',selectedRecordTypes.get('Dealer'),'112 E. HIGH STREET', 'HENNEPIN','GA','30324','United States','US', '111 555 2222','bluewolf.com', 'SR');
       insert dealerList2;
       dealerAcc1 = dealerList1[0];
      // dealerAcc2 = dealerLists[1]; 
    //   dealerAcc3 = dealerLists[2];
       
       Dealer_Brand__c db1 = TestUtilities.createDealerBrand(dealerList1[0],1);
       insert db1;  
       
       DealerInfo di = new DealerInfo(dealerAcc1, dealerBrand1);
       System.assertNotEquals(null, di.dealerId);
       System.assertNotEquals(null, di.dealerName);
       System.assertNotEquals(null, di.dealerShippingStreet);
       System.assertNotEquals(null, di.dealerShippingCity);
       System.assertNotEquals(null, di.dealerShippingState);
       System.assertNotEquals(null, di.dealerShippingPostalCode);
       System.assertNotEquals(null, di.dealerShippingCountry);
       System.assertNotEquals(null, di.dealerPhone);
       System.assertNotEquals(null, di.dealerWebsite);    
       
       FilteredDealer fd0 = new FilteredDealer(dealerList1[0].Id, 0);
       FilteredDealer fd1 = new FilteredDealer(dealerList2[0].Id, 1);   
       List<FilteredDealer> fd = new List<FilteredDealer>{fd0,fd1};
       fd.sort();
       
       System.assertEquals(1, DealerLocator.getDealers(new List<DealerInfo>(), 'test').size());    
    } 
    
    private static void thenOnlyOneDealerMustBeReturned(){
       GeoNamesWebService.isApexTest = true;
       list<DealerInfo> dealerInfoList = DealerLocator.getDealerInfo('30324',null);
       system.assertNotEquals(null,dealerInfoList[0].exceptionMessage,'Dealer 1 should not have an exception message since it has an ACTIVE dealer brand');
    }
    
    @isTest(SeeAllData = true)
    static void matchedDealers() {
    	// testAccounts list<Account> = new TestUtilities.createDealerAccounts(1, true);
		TestUtilities.createTestDealerAccounts(1, true);
    	Account acc = [Select Id From Account Limit 1];
    	TerritoryServices.MatchedDealers md = new TerritoryServices.MatchedDealers(acc.Id,acc.Id,acc.Id);
        
        Set<Id> s = new Set<Id>();
        DealerLocator.collectDealers(s, md);
        System.assertEquals(1, s.size());
     }
     
     static testMethod void invalidDealerInfo() {
     	list<DealerInfo> dealerInfoList = DealerLocator.getDealerInfo(null,null);
     	System.assertEquals('Postal code and Country code are missing.', dealerInfoList[0].exceptionMessage);
     }
     
     static testMethod void invalidUSDealerInfo() {
     	list<DealerInfo> dealerInfoList = DealerLocator.getDealerInfo(null,'US');
     	System.assertEquals('Postal code for US and Canada is mandatory.', dealerInfoList[0].exceptionMessage);
     }
}