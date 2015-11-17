@isTest
private class TestTerritoryDeletionService
{
    static testMethod void testTerritoryDeletion()
    {
        final Integer NUM_RECORDS = 5;
        final String TERRITORY_BRAND = 'SR';
        final String OTHER_TERRITORY_BRAND = 'BW';

        TerritoryDeletionSettings__c newSetting = new TerritoryDeletionSettings__c();
        newSetting.Name = TERRITORY_BRAND;
        newSetting.Columns_To_Use__c = String.join( new List<String>{ 'productCategory' }, ';' );
        System.runAs( TestUtilities.ADMIN_USER )
        {
            insert newSetting;
        }

		AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disablePardotLogCheck = true;
		AccountServices.disableTriggerProcessing = true;
		TerritoryServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		
        List<Account> testAccounts = TestUtilities.createTestDealerAccounts( NUM_RECORDS, true );
        List<Dealer_Brand__c> testBrands = TestUtilities.createDealerBrand( testAccounts );
        
        for( Dealer_Brand__c aBrand : testBrands )
        {
            aBrand.Unique_ID__c = aBrand.Dealer__c;
        }
        insert testBrands;
        
        TerritoryDeletionService.TerritoryDeletionPackage incomingRequest = new TerritoryDeletionService.TerritoryDeletionPackage();
        incomingRequest.values = new List<TerritoryDeletionService.TerritoryDeletionRecord>();
        
        
        testBrands = [ SELECT Id, Unique_ID__c FROM Dealer_Brand__c ];
        for( Dealer_Brand__c aBrand : testBrands )
        {
        	List<Territory__c> testTerritories = new List<Territory__c>();
        	
            for (Territory__c newTerritory : TestUtilities.createTerritories( aBrand, 500, false )) { //[0];
	            newTerritory.Boat_Class__c = aBrand.Id;
	            newTerritory.Dealer_Brand__r = aBrand;
	            newTerritory.Brand__c = TERRITORY_BRAND;
	            testTerritories.add( newTerritory );
            }
            
            insert testTerritories;
            
	        for( Territory__c aTerritory : testTerritories )
	        {
	            TerritoryDeletionService.TerritoryDeletionRecord newRecord = new TerritoryDeletionService.TerritoryDeletionRecord();
	            newRecord.dealerBrandId = aTerritory.Dealer_Brand__r.Unique_ID__c;
	            newRecord.productCategory = aTerritory.Boat_Class__c;
	            newRecord.dealerBrand = TERRITORY_BRAND;
	            incomingRequest.values.add( newRecord );
	        }  
        }
       
        for( Dealer_Brand__c aBrand : testBrands )
        {
        	List<Territory__c> testTerritories = new List<Territory__c>();
        	
            Territory__c newTerritory = TestUtilities.createTerritories( aBrand, 1, false )[0];
            newTerritory.Boat_Class__c = aBrand.Id;
            newTerritory.Dealer_Brand__r = aBrand;
            newTerritory.Brand__c = OTHER_TERRITORY_BRAND;
            testTerritories.add( newTerritory );
            
            insert testTerritories;
        }
        

		TerritoryServices.disableTriggerProcessing = false;
		AccountServices.disableTriggerProcessing = false;
		DBMServices.disableTriggerProcessing = false;
        Test.startTest();

        TerritoryDeletionService.deleteTerritory( incomingRequest );

        Test.stopTest();

        List<Territory__c> remainingTerritories = [ SELECT Id FROM Territory__c Where Brand__c = :TERRITORY_BRAND];
        System.assert( remainingTerritories.isEmpty(), 'There should be no territories remaining because all territories should have been targeted for deletion' );
        
        remainingTerritories = [ SELECT Id FROM Territory__c Where Brand__c = :OTHER_TERRITORY_BRAND];
        System.assert( !remainingTerritories.isEmpty(), 'There should be territories remaining for OTHER_TERRITORY_BRAND' );
    }
   /* 
    static testMethod void testTerritoryDeletion_Selective()
    {
        final Integer NUM_RECORDS = 10;
        final String TERRITORY_BRAND = 'something';

        TerritoryDeletionSettings__c newSetting = new TerritoryDeletionSettings__c();
        newSetting.Name = TERRITORY_BRAND;
        newSetting.Columns_To_Use__c = String.join( new List<String>{ 'productCategory', 'county' }, ';' );
        System.runAs( TestUtilities.ADMIN_USER )
        {
            insert newSetting;
        }

        List<Account> testAccounts = TestUtilities.createTestDealerAccounts( NUM_RECORDS, true );
        List<Dealer_Brand__c> testBrands = TestUtilities.createDealerBrand( testAccounts );
        for( Dealer_Brand__c aBrand : testBrands )
        {
            aBrand.Unique_ID__c = aBrand.Dealer__c;
        }
        insert testBrands;
        testBrands = [ SELECT Id, Unique_ID__c FROM Dealer_Brand__c ];

        List<Territory__c> testTerritories = new List<Territory__c>();
        Integer i = 0;
        for( Dealer_Brand__c aBrand : testBrands )
        {
            Territory__c newTerritory = TestUtilities.createTerritories( aBrand, 1, false )[0];
            newTerritory.Boat_Class__c = aBrand.Id;
            newTerritory.Dealer_Brand__r = aBrand;
            newTerritory.Brand__c = TERRITORY_BRAND;
            if (Math.mod(i++, 2) == 0){
            	newTerritory.County__c = 'Fulton';
            }
            testTerritories.add( newTerritory );
        }
        insert testTerritories;

        TerritoryDeletionService.TerritoryDeletionPackage incomingRequest = new TerritoryDeletionService.TerritoryDeletionPackage();
        incomingRequest.values = new List<TerritoryDeletionService.TerritoryDeletionRecord>();
        for( Territory__c aTerritory : testTerritories )
        {
            TerritoryDeletionService.TerritoryDeletionRecord newRecord = new TerritoryDeletionService.TerritoryDeletionRecord();
            newRecord.dealerBrandId = aTerritory.Dealer_Brand__r.Unique_ID__c;
            newRecord.productCategory = aTerritory.Boat_Class__c;
            newRecord.dealerBrand = TERRITORY_BRAND;
            newRecord.county = 'Fulton';
            incomingRequest.values.add( newRecord );
        }

        Test.startTest();

            TerritoryDeletionService.deleteTerritory( incomingRequest );

        Test.stopTest();

        List<Territory__c> remainingTerritories = [ SELECT Id FROM Territory__c ];
        System.assertEquals(NUM_RECORDS/2,  remainingTerritories.size(), 
        	'There should be remaining half of the territories because only those with county set to \'Fulton\' should have been targeted for deletion' );
    }*/
}