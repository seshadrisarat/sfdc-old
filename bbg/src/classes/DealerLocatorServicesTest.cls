@isTest
public with sharing class DealerLocatorServicesTest {
    
    
    
    
    /*
    
    Matching Criteria: postalcode, state, country, etc. 
    
    Dealer Accounts: 10 matching accounts, 10 mis-matched accounts 
    
    Dealer Brands: for each account: 1 Dealer Brands with active status and matching brand, 
                                    1 Dealer Brands with inactive status and matching brand,
                                    1 Dealer Brands with active status and mismatching brand,
                                    
    Territories: 
        for each matching Account and Dealer Brand combo: 
            create 1 territory with matching criteria
        for each mis-matched Account and Dealer Brand combo: 
            create 1 territory with mis-matching criteria
    */
    
    
    
    public static Set<Id> getDealerFoundIds(Set<DealerLocatorServices.DealerFound> dealersFound){
        Set<Id> actualDealerIds = new Set<Id>();
        for (DealerLocatorServices.DealerFound dFound : dealersFound){
            actualDealerIds.add(dFound.account.id);
        }
        return actualDealerIds;
    }
    
    public static Set<Id> getDealerFoundIds(List<DealerLocatorServices.DealerFound> dealersFound){
        return getDealerFoundIds(new Set<DealerLocatorServices.DealerFound>(dealersFound));
    }
    
    
    public static testMethod void testSearchAssignedDealersByPostalCode(){
        
        final String testValidPostalCode = '31232';
        final String testValidBrandCode = 'BL';
        final String testValidCountryName = 'United States';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
        
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
            dealerAcc.ShippingCountry = testValidCountryName;
        }
        UnitTest.get('Accounts').insertAll();
        
        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
        UnitTest.get('All Dealer Brands').insertAll();
        
        List<Territory__c> testTerritories = new List<Territory__c>();
        for (Dealer_Brand__c dealerBrand : (List<Dealer_Brand__c>) UnitTest.get('All Dealer Brands').getList()){
            Territory__c testTerr = TestUtilities.createTerritories(dealerBrand, 1, false)[0];
            testTerr.Dealer_Brand__r = dealerBrand;
            testTerr.Brand__c = testValidBrandCode;
            testTerritories.add(testTerr);
        }
        UnitTest.addData(testTerritories)
            .tag('Territories')
            .property('Zipcode_Postal_Code__c').assign(testValidPostalCode);
        UnitTest.get('Territories').insertAll();
        
        
        Test.startTest();
            Set<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.searchAssignedDealersByPostalCode(testValidBrandCode, testValidPostalCode, testValidCountryName, null);
        Test.stopTest();
        
       System.assertEquals(UnitTest.getIds('Matching Accounts'), getDealerFoundIds(actualDealers), 
            'We expect to get back only the dealer ids of the matching dealer accounts');
        
        
    }
    
    public static testMethod void testSearchAssignedDealersByPostalCode_applyLimit(){
        
        final String testValidPostalCode = '31232';
        final String testValidBrandCode = 'BL';
        final String testValidCountryName = 'United States';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
            dealerAcc.ShippingCountry = testValidCountryName;
        }
        UnitTest.get('Accounts').insertAll();
        
        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
        UnitTest.get('All Dealer Brands').insertAll();
        
        List<Territory__c> testTerritories = new List<Territory__c>();
        for (Dealer_Brand__c dealerBrand : (List<Dealer_Brand__c>) UnitTest.get('All Dealer Brands').getList()){
            Territory__c testTerr = TestUtilities.createTerritories(dealerBrand, 1, false)[0];
            testTerr.Dealer_Brand__r = dealerBrand;
            testTerr.Brand__c = testValidBrandCode;
            testTerritories.add(testTerr);
        }
        UnitTest.addData(testTerritories)
            .tag('Territories')
            .property('Zipcode_Postal_Code__c').assign(testValidPostalCode);
        UnitTest.get('Territories').insertAll();
        
        
        Test.startTest();
            Set<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.searchAssignedDealersByPostalCode(testValidBrandCode, testValidPostalCode, testValidCountryName, 3);
        Test.stopTest();
        
       System.assertEquals(3 , actualDealers.size(), 
            'We expect to get back only 3 dealer ids of the matching dealer accounts');
        
        
    }
    
    public static testMethod void testSearchAssignedDealersByFSACode(){
        
        final String testValidFSACode = '30363';
        final String testValidBrandCode = 'BL';
        final String testValidCountryName = 'United States';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
            dealerAcc.ShippingCountry = testValidCountryName;
        }
        UnitTest.get('Accounts').insertAll();
        
        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
        UnitTest.get('All Dealer Brands').insertAll();
        
        List<Territory__c> testTerritories = new List<Territory__c>();
        for (Dealer_Brand__c dealerBrand : (List<Dealer_Brand__c>) UnitTest.get('All Dealer Brands').getList()){
            Territory__c testTerr = TestUtilities.createTerritories(dealerBrand, 1, false)[0];
            testTerr.Dealer_Brand__r = dealerBrand;
            testTerr.Brand__c = testValidBrandCode;
            testTerritories.add(testTerr);
        }
        
        UnitTest.addData(testTerritories)
            .tag('Territories')
            .property('Zipcode_Postal_Code__c').assign(testValidFSACode);
        UnitTest.get('Territories').insertAll();
        
        
        Test.startTest();
            Set<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.searchAssignedDealersByFSACode(testValidBrandCode, testValidFSACode, testValidCountryName, null);
        Test.stopTest();
        
       System.assertEquals(UnitTest.getIds('Matching Accounts'), getDealerFoundIds(actualDealers), 
            'We expect to get back only the dealer ids of the matching dealer accounts');
        
    }
    
    public static testMethod void testSearchAssignedDealersByCountryCode(){
        // finish changes here!!
        final String testValidCountryCode = 'United States';
        final String testValidBrandCode = 'BL';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
        UnitTest.get('Matching Accounts')
            .property('ShippingCountry').assign(testValidCountryCode);
            
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
        }
        UnitTest.get('Accounts').insertAll();
        
        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
        UnitTest.get('All Dealer Brands').insertAll();
        
        List<Territory__c> testTerritories = new List<Territory__c>();
        for (Dealer_Brand__c dealerBrand : (List<Dealer_Brand__c>) UnitTest.get('All Dealer Brands').getList()){
            Territory__c testTerr = TestUtilities.createTerritories(dealerBrand, 1, false)[0];
            testTerr.Dealer_Brand__r = dealerBrand;
            testTerr.Brand__c = testValidBrandCode;
            testTerritories.add(testTerr);
        }
        UnitTest.addData(testTerritories).tag('Territories');
        UnitTest.get('Territories').insertAll();
        
        
        Test.startTest();
            Set<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.searchAssignedDealersByCountryCode(testValidBrandCode, testValidCountryCode, null);
        Test.stopTest();
        
       System.assertEquals(UnitTest.getIds('Matching Accounts'), getDealerFoundIds(actualDealers), 
            'We expect to get back only the dealer ids of the matching dealer accounts');       
    }

    public static testMethod void testSearchAssignedDealersByState(){
        
        final String testValidState = 'Georgia';
        final String testValidBrandCode = 'BL';
        final String testValidCountryName = 'United States';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
            dealerAcc.ShippingCountry = testValidCountryName;
        }
        UnitTest.get('Accounts').insertAll();
        
        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
        UnitTest.get('All Dealer Brands').insertAll();
        
        List<Territory__c> testTerritories = new List<Territory__c>();
        for (Dealer_Brand__c dealerBrand : (List<Dealer_Brand__c>) UnitTest.get('All Dealer Brands').getList()){
            Territory__c testTerr = TestUtilities.createTerritories(dealerBrand, 1, false)[0];
            testTerr.Dealer_Brand__r = dealerBrand;
            testTerr.Brand__c = testValidBrandCode;
            testTerritories.add(testTerr);
        }
        UnitTest.addData(testTerritories)
            .tag('Territories')
            .property('State_Province__c').assign(testValidState);
        UnitTest.get('Territories').insertAll();
        
        
        Test.startTest();
            Set<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.searchAssignedDealersByState(testValidBrandCode, testValidState, testValidCountryName, null);
        Test.stopTest();
        
       System.assertEquals(UnitTest.getIds('Matching Accounts'), getDealerFoundIds(actualDealers), 
            'We expect to get back only the dealer ids of the matching dealer accounts');
    }
    
    public static testMethod void testSearchAssignedDealersByCounty(){
        
        final String testValidCounty = 'Fulton';
        final String testValidBrandCode = 'BL';
        final String testValidStateCode = 'GA';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
        }
        UnitTest.get('Accounts').insertAll();
        
        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
        UnitTest.get('All Dealer Brands').insertAll();
        
        List<Territory__c> testTerritories = new List<Territory__c>();
        for (Dealer_Brand__c dealerBrand : (List<Dealer_Brand__c>) UnitTest.get('All Dealer Brands').getList()){
            Territory__c testTerr = TestUtilities.createTerritories(dealerBrand, 1, false)[0];
            testTerr.Dealer_Brand__r = dealerBrand;
            testTerr.Brand__c = testValidBrandCode;
            testTerr.State_Province__c = testValidStateCode;
            testTerritories.add(testTerr);
        }
        UnitTest.addData(testTerritories)
            .tag('Territories')
            .property('County__c').assign(testValidCounty);
        UnitTest.get('Territories').insertAll();
        
        
        Test.startTest();
            Set<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.searchAssignedDealersByCounty(testValidBrandCode, testValidCounty, testValidStateCode, null);
        Test.stopTest();
        
        System.assertEquals(UnitTest.getIds('Matching Accounts'), getDealerFoundIds(actualDealers), 
            'We expect to get back only the dealer ids of the matching dealer accounts');
        
    }
    
   
   
    // Non-Assigned test
   
    
    public static testMethod void testSearchNonAssignedDealersByClosestPostalCode(){
        
        final String testValidCountry = 'United States';
        final String testValidBrandCode = 'BL';
        final Decimal testLatitude = 23.222;
        final Decimal testLongitude =  -103.444;
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
            
        UnitTest.get('Matching Accounts')
            .property('ShippingCountry').assign(testValidCountry);
        
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
            dealerAcc.GeoLocation__Latitude__s = testLatitude + (Math.random() * 10)  - i;
            dealerAcc.GeoLocation__Longitude__s = testLongitude - (Math.random() * 10) + i;
        }
        
        UnitTest.get('Accounts').insertAll();
        
        
        String dealersOrderQuery = 'Select Id From Account ' + 
                            'WHERE Id in ' + 
                            BluewolfDevUtils.flattenListForQuery(new List<Id>(UnitTest.getIds('Matching Accounts'))) + 
                            ' ORDER BY ' + 
                            ' DISTANCE(GeoLocation__c, '  + 
                            ' GEOLOCATION(' + testLatitude+ ', ' + 
                                            testLongitude + '), \'mi\')';
        List<Account> dealersInOrder = (List<Account>) Database.query( dealersOrderQuery );
        System.assert(!dealersInOrder.isEmpty(), 
            'We expect to get back the Accounts in order of their GeoLocation__c field ');
        


        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
        UnitTest.get('All Dealer Brands').insertAll();
        
        Test.startTest();
            List<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.searchClosestNonAssignedDealersByDistance(
                testValidBrandCode, testValidCountry, testLatitude, testLongitude, null);
        Test.stopTest();
        
       System.assertEquals(UnitTest.getIds('Matching Accounts'), getDealerFoundIds(actualDealers), 
            'We expect to get back only the dealer ids of the matching dealer accounts');
       
       for (Integer x = 0; x < actualDealers.size(); x++ ){
            System.assertEquals(dealersInOrder[x].Id, actualDealers[x].Account.Id, 
                'We expect to get back the Dealers Found in order of GeoLocation from the input postal code');
       }
    }
    
    public static testMethod void testSearchNonAssignedDealersByCountryCode(){
        
        final String testValidCountry = 'United States';
        final String testValidBrandCode = 'BL';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
            
        UnitTest.get('Matching Accounts')
            .property('ShippingCountry').assign(testValidCountry);
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
        }
        UnitTest.get('Accounts').insertAll();
        
        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
        UnitTest.get('All Dealer Brands').insertAll();
        
        Test.startTest();
            Set<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.searchNonAssignedDealersByCountryCode(testValidBrandCode, testValidCountry, null);
        Test.stopTest();
        
       System.assertEquals(UnitTest.getIds('Matching Accounts'), getDealerFoundIds(actualDealers), 
            'We expect to get back only the dealer ids of the matching dealer accounts');
    }
    
    // Final No-Dealers Found test
    
    public static testMethod void test_NoDealersFound_ReturnRegionalOffices(){
        
        final List<String> testValidCountryCodes = new List<String>{'US', 'CA', 'MX'};
        final List<String> testValidCountryCodesDealer2 = new List<String>{'TX', 'SD'};
        final String testValidBrandCode = 'BL';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
            
        UnitTest.get('Accounts')
            .property('Dealer_Type__c').assign(DealerLocatorServices.REGIONAL_OFFICE_DEALER_TYPE);
            
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
            
        UnitTest.get('Matching Accounts')
            .divide(2)
            .part('Matching Accounts with Dealer 1')
            .part('Matching Accounts with Dealer 2');
            
        UnitTest.get('Matching Accounts with Dealer 1')
            .property('ShippingCountry').assignFrom(testValidCountryCodes);
            
        UnitTest.get('Matching Accounts with Dealer 2')
            .property('ShippingCountry').assignFrom(testValidCountryCodesDealer2);
            
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
        }
        UnitTest.get('Accounts').insertAll();
        
        List<Dealer_Brand__c> testDealerBrands = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testValidDealerBrands = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Matching Accounts').getList()){
            Dealer_Brand__c matchingDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            matchingDealerBrand.Brand__c = testValidBrandCode;
            testValidDealerBrands.add(matchingDealerBrand);
            testDealerBrands.add(matchingDealerBrand);
        }
        
        for (Account acc : (List<Account>)UnitTest.get('NonMatching Accounts').getList()){
            Dealer_Brand__c mismatchDealerBrand = TestUtilities.createDealerBrand(acc, i++);
            mismatchDealerBrand.Brand__c = 'SR';
            testDealerBrands.add(mismatchDealerBrand);
        }
        
        UnitTest.addData(testValidDealerBrands)
            .tag('Valid Dealer Brands');
        UnitTest.addData(testDealerBrands)
            .tag('All Dealer Brands');
            
        UnitTest.get('All Dealer Brands').insertAll();
        
        List<Territory__c> testTerritories = new List<Territory__c>();
        for (Dealer_Brand__c dealerBrand : (List<Dealer_Brand__c>) UnitTest.get('All Dealer Brands').getList()){
            Territory__c testTerr = TestUtilities.createTerritories(dealerBrand, 1, false)[0];
            testTerr.Dealer_Brand__r = dealerBrand;
            testTerr.Brand__c = testValidBrandCode;
            testTerritories.add(testTerr);
        }
        UnitTest.addData(testTerritories).tag('Territories');
        
        Set<Id> validDealerAccountIds = new Set<Id>();
        List<Territory__c> testRegionalTerritories = new List<Territory__c>();
        for (Dealer_Brand__c dealerBrand : (List<Dealer_Brand__c>) UnitTest.get('Valid Dealer Brands').getList()){
            Territory__c testTerr = TestUtilities.createTerritories(dealerBrand, 1, false)[0];
            testTerr.Dealer_Brand__r = dealerBrand;
            testTerr.Brand__c = testValidBrandCode;
            validDealerAccountIds.add(dealerBrand.Dealer__c);
            testRegionalTerritories.add(testTerr);
        }
        
        UnitTest.addData(testRegionalTerritories).tag('Valid Territories');
        
        UnitTest.get('Valid Territories')
            .property('Regional_Office_Country__c').assignFrom(testValidCountryCodes);
        
        UnitTest.get('Valid Territories').tag('Territories');
        UnitTest.get('Territories').insertAll();
        
        Test.startTest();
            Set<DealerLocatorServices.DealerFound> actualDealers = DealerLocatorServices.getRegionalOfficeByCountryCode(testValidBrandCode, testValidCountryCodes[0]);
        Test.stopTest();
        
       System.assert(validDealerAccountIds.containsAll(getDealerFoundIds(actualDealers)), 
            'We expect to get back only the dealer ids of the matching dealer accounts');   
        
    }
    
    public static testMethod void testCountryISOLookup_CustomSetting(){
        
        
        Map<String, String> testISOCodes = new Map<String, String>{
            'United States' => 'US',
            'Canada' => 'CA'
        };
        
        TestUtilities.createCountryISOCodeCS(testISOCodes, true);
        
        Test.startTest();
            Map<String, String> actualISOLookup = DealerLocatorServices.countryISOLookup;
        Test.stopTest();
        
        System.assert(testISOCodes.keySet().containsAll(actualISOLookup.keySet()), 
            'We expect all Country Code ISO Lookup Custom Settings to be loaded ');
        
        
        
    }
    public static testMethod void testGetDealerFoundIds(){
        
        final String testValidCountry = 'United States';
        final String testValidBrandCode = 'BL';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
            
        UnitTest.get('Matching Accounts')
            .property('ShippingCountry').assign(testValidCountry);
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
        }
        UnitTest.get('Accounts').insertAll();
        
        List<DealerLocatorServices.DealerFound> dFoundList = new List<DealerLocatorServices.DealerFound>();
        Set<Id> expectedDealerIds = new Set<Id>();
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            DealerLocatorServices.DealerFound dealerMatch = new DealerLocatorServices.DealerFound(dealerAcc, null);
            dFoundList.add( dealerMatch );
            expectedDealerIds.add(dealerAcc.Id);
        }
        
        Test.startTest();
            Set<Id> actualDealerIDs = getDealerFoundIds(dFoundList);
        Test.stopTest();
        
        System.assertEquals(expectedDealerIds , actualDealerIDs, 
            'We expect to get back the correct dealer ids');
        
    }
    
    public static testMethod void testDealerLocatorServices_DealerFoundClass(){
        
        final String testValidCountry = 'United States';
        final String testValidBrandCode = 'BL';
        
        Integer i = 0;
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('Matching Accounts')
            .part('NonMatching Accounts');
            
        UnitTest.get('Matching Accounts')
            .property('ShippingCountry').assign(testValidCountry);
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
        }
        UnitTest.get('Accounts').insertAll();
        
        final List<Account> allAccounts = (List<Account>) UnitTest.get('Accounts').getList();
        Account testAccount1 = allAccounts[0];
        Account testAccount1_Copy = allAccounts[0];
        Account testAccount2 = allAccounts[1];
        Account testAccount2_Copy = allAccounts[1];
        Account testAccountNoMatch = allAccounts[2];
        
        Set<DealerLocatorServices.DealerFound> uniqueSet = new Set<DealerLocatorServices.DealerFound>();
        for (Integer x = 0; x < 10; x++){
            DealerLocatorServices.DealerFound dFound = new DealerLocatorServices.DealerFound(testAccount1, null);
            uniqueSet.add(dFound);
        }
        
        DealerLocatorServices.DealerFound dealerMatch = new DealerLocatorServices.DealerFound(testAccount1, null);
        DealerLocatorServices.DealerFound dealerMatch_copy = new DealerLocatorServices.DealerFound(testAccount1, null);
        DealerLocatorServices.DealerFound dealerMatch2 = new DealerLocatorServices.DealerFound(testAccount2, null);
        DealerLocatorServices.DealerFound dealerMatch2_copy = new DealerLocatorServices.DealerFound(testAccount2, null);
        DealerLocatorServices.DealerFound dealerMatch3 = new DealerLocatorServices.DealerFound(testAccount2, null);
        dealerMatch3.otherDealerInfo.put('product', 'test_product');
        DealerLocatorServices.DealerFound dealerNoMatch = new DealerLocatorServices.DealerFound(testAccountNoMatch, null);
        
        System.assert(dealerMatch == dealerMatch_copy, 'We expect the compare to function to return equal');
        System.assert(dealerMatch2 == dealerMatch2_copy, 'We expect the compare to function to return equal');
        System.assert(dealerMatch2 != dealerMatch3, 'We do not expect the compare to function to return equal');
        System.assert(dealerMatch != dealerNoMatch, 'We do not expect the compare to function to return equal');
        System.assertEquals(1, uniqueSet.size(), 'We expect to get back a Set of unique DealerFound objects');   
    }
}