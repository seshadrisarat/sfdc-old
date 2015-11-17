@isTest
private class TestTerritoryServices {
    static final String TEST_STREET = '112 E. HIGH STREET';
    static final String TEST_CITY = 'HENNEPIN';
    static final String TEST_STATE = 'IL';
    static final String TEST_POSTAL_CODE = '61327';
    static final String TEST_COUNTRY = 'United States';
    static final String TEST_COUNTY = 'Berkshire';
    static final String TEST_ISO_CODE = 'US';
    static final String TEST_PHONE = '111 555 2222';
    static final String TEST_WEBSITE = 'bluewolf.com';
    static final String TEST_BRAND = 'BL';
    static final Decimal TEST_LONGITUDE = -121.895;
    static final Decimal TEST_LATITUDE = 37.4352;
	static Account dealerAcc1, dealerAcc2, dealerAcc3, dealerAcc4;
	
    static void setup()
    {
    	Dealer_Types_to_Exclude_from_Locator__c cs1 = new Dealer_Types_to_Exclude_from_Locator__c(Name='type1', Dealer_Type__c='Non-Selling Location');
		Dealer_Types_to_Exclude_from_Locator__c cs2 = new Dealer_Types_to_Exclude_from_Locator__c(Name='type2', Dealer_Type__c='Previous Dealer');
		Dealer_Types_to_Exclude_from_Locator__c cs3 = new Dealer_Types_to_Exclude_from_Locator__c(Name='type3', Dealer_Type__c='Prospect');
		
		System.runAs( TestUtilities.ADMIN_USER )
		{
			insert new list<Dealer_Types_to_Exclude_from_Locator__c>{cs1, cs2, cs3};
		}
        
        list<Account> dealerLists = TestUtilities.createTestAccount(4,
        															'test', 
        															TestUtilities.getRecordTypesMap().get('Dealer'),
        															TEST_STREET, 
        															TEST_CITY, 
        															TEST_STATE,
        															TEST_POSTAL_CODE,
        															TEST_COUNTRY,
        															TEST_ISO_CODE, 
        															TEST_PHONE, 
        															TEST_WEBSITE,
        															TEST_BRAND);
       	
       	Integer x = 0;
	    
	    for( Account dealer : dealerLists )
	    {
	    	dealer.latitude__c = TEST_LATITUDE;
	    	dealer.longitude__c = TEST_LONGITUDE;
	    	dealer.Dealer_Number__c = 'test '+ x++;
	    	dealer.County__c = TEST_COUNTY;
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
	        dbrands[i].Brand__c = TEST_BRAND;
        }
        
        insert dbrands;
       
       	List<Territory__c> testTerritories = new List<Territory__c>();
       	 
        for(Dealer_Brand__c dBrand : dbrands )
        {
        	Territory__c testTerr = TestUtilities.createTerritories(dBrand, 1, false )[0];
        	testTerr.County__c = TEST_COUNTY;
        	testTerr.State_Province__c = TEST_STATE;
        	testTerr.Zipcode_Postal_Code__c = TEST_POSTAL_CODE.substring(0,3);
        	testTerritories.add( testTerr );
        }
        
        insert testTerritories; 
    }
    
    static testMethod void testGetCountiesToDealersMap() {
        
        setup();
		
		Test.startTest();
			map<String, list<Id>> resultingDealers = TerritoryServices.getCountiesToDealersMap( TEST_BRAND, TEST_STATE, TEST_COUNTY ); 
		Test.stopTest();
		
		System.assertEquals( 1, resultingDealers.size(), 'Only one County should have been found' );	    
		System.assert( resultingDealers.containsKey( TEST_COUNTY ), 'Only the test County should have been found' );	    
		System.assertEquals( 1, resultingDealers.get( TEST_COUNTY ).size(), 'Only the valid Accounts with types in the custom settings should have been found' );
		
		Set<Id> dealerSet = new Set<Id>( resultingDealers.get( TEST_COUNTY ) );
		
		Set<Id> expectedIds = new Set<Id>();
		expectedIds.add(dealerAcc4.Id);
		 
        System.assert( expectedIds.containsAll( dealerSet ), 'Only the exact valid Accounts created in the test should be found' );
    }

    static testMethod void testFindTerritoriesForCanada() {
        
        setup();
		
		Test.startTest();
			List<Territory__c> resultingTerrs = TerritoryServices.findTerritoriesForCanada( TEST_POSTAL_CODE, TEST_BRAND, TEST_ISO_CODE ); 
		Test.stopTest();
		
		System.assertEquals( 1, resultingTerrs.size(), 'Only one Territory should have been found' );	    
		System.assertEquals( dealerAcc4.Id, resultingTerrs[0].Dealer_Brand__r.Dealer__c, 'The Territory should be attached to the correct dealer' );	    
		
    }

    static testMethod void testFindTerritoriesByDistance() {
        
        setup();
		
		Test.startTest();
			TerritoryServices.MatchedDealers resultingDealers = TerritoryServices.findByDistance(TEST_LONGITUDE, TEST_LATITUDE, TEST_BRAND, TEST_ISO_CODE); 
		Test.stopTest();
		
		System.assertEquals( dealerAcc4.Id, resultingDealers.DealerOneId, 'The correct dealer should be found' );	    
		System.assertEquals( null, resultingDealers.DealerTwoId, 'Only one dealer should be found' );	    
		System.assertEquals( null, resultingDealers.DealerThreeId, 'Only one dealer should be found' );	    
		
    }
    
    
    static testMethod void findTerritoriesForCanada() {
        System.assertNotEquals(null, TerritoryServices.findTerritoriesForCanada('e1n4e4', 'BL', 'CA'));
    }
    
    static testMethod void getDealers() {
        System.assertNotEquals(null, TerritoryServices.getDealers('30328'));
    }
    
    static testMethod void getCountyForTerritory() {
        System.assertNotEquals(null, TerritoryServices.getCountyForTerritory(null));
    }
    
    @isTest(SeeAllData = true)
    static void matchedDealers() {
    	Account acc = [Select Id From Account Limit 1];
    	
        TerritoryServices.MatchedDealers md = new TerritoryServices.MatchedDealers(acc.Id,acc.Id,acc.Id);
        
        System.assertEquals(acc.Id, md.DealerOneId);
        System.assertEquals(acc.Id, md.DealerTwoId);
        System.assertEquals(acc.Id, md.DealerThreeId);
    }
}