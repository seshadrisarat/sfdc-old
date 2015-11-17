@isTest
private class DealerLocatorTests {

    static String[] testUnitedStatesZipcodes = new String[]{'36340','93109'};
    static String[] testCanadaZipcodesParts = new String[]{'T2E','V5T','M4G','M4B'};
    static String[] testCountryCodes = new String[]{'US','CA','UK'};
    static map<String, String> testCountryCodeToCountryNameMap = new map<String, String>{'US'=>'United States','CA'=>'Canada','UK'=>'United Kingdom'};
    static list<Account> dealers = new list<Account>();
    static list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
    static list<Territory__c> territories = new list<Territory__c>();
    static Id dealerRecordTypeId = [Select Id from RecordType where sobjectType = 'Account' and developername = 'Dealer'].Id; 
    
    private static void givenCanadaDealers() {
        dealers = createDealers(2, false);
        
        // CA dealers
        dealers[0].ShippingStreet = '3000 KINGSWAY';
        dealers[0].ShippingCity = 'SUDBURY';
        dealers[0].ShippingState = 'ON';
        dealers[0].ShippingPostalCode = 'P3B 2G5';
        dealers[0].ShippingCountry = testCountryCodes[1];//testCountryCodeToCountryNameMap.get(testCountryCodes[1]);
        dealers[0].Phone = '902566-4450';
        dealers[0].Website = 'http://test.salesforce.com';
        dealers[0].Phone__c = '';
        dealers[0].Website__c = '';
        
        dealers[1].ShippingStreet = '16229 FRASER';
        dealers[1].ShippingCity = 'SURREY';
        dealers[1].ShippingState = 'BC';
        dealers[1].ShippingPostalCode = 'V4N0G2';
        dealers[1].ShippingCountry = testCountryCodes[1];//testCountryCodeToCountryNameMap.get(testCountryCodes[1]);
        dealers[1].Phone = '780875-0345';
        dealers[1].Website = 'http://test.salesforce.com';
        dealers[1].Phone__c = '';
        dealers[1].Website__c = '';
        
        insert dealers;
        
        for(Account acc: dealers){          
            dealerBrands.addAll(createDealerBrands(1, true, acc.Id));
        }
        
        for(Dealer_Brand__c dealerBrand : dealerBrands){
            territories.addAll(createTerritories(1, true, dealerBrand.Id, dealerBrand.Dealer__c, testCanadaZipcodesParts[0]));
        }
    }
    
    private static void givenUSDealers() {
        dealers = createDealers(2, false);  
        
        dealers[0].ShippingStreet = '3000 KINGSWAY';
        dealers[0].ShippingCity = 'TestTownAL';
        dealers[0].ShippingState = 'AL';
        dealers[0].ShippingPostalCode = testUnitedStatesZipcodes[0];
        dealers[0].ShippingCountry = testCountryCodes[0];//testCountryCodeToCountryNameMap.get(testCountryCodes[0]);
        dealers[0].Phone = '444-555-6666';
        dealers[0].Website = 'http://test.salesforce.com';
        dealers[0].Phone__c = '';
        dealers[0].Website__c = '';
        
        
        dealers[1].ShippingStreet = '16229 FRASER';
        dealers[1].ShippingCity = 'TestTownNY';
        dealers[1].ShippingState = 'NY';
        dealers[1].ShippingPostalCode = testUnitedStatesZipcodes[1];
        dealers[1].ShippingCountry = testCountryCodes[0];//testCountryCodeToCountryNameMap.get(testCountryCodes[0]);
        dealers[1].Phone = '333-444-5555';
        dealers[1].Website = 'http://test.salesforce.com';
        dealers[1].Phone__c = '';
        dealers[1].Website__c = '';
        
        insert dealers;
        
        for(Account acc: dealers){          
            dealerBrands.addAll(createDealerBrands(1, true, acc.Id));
        }
        
        for(Dealer_Brand__c dealerBrand : dealerBrands){
            territories.addAll(createTerritories(1, true, dealerBrand.Id, dealerBrand.Dealer__c, testUnitedStatesZipcodes[0]));
        }
    }
    
    private static void givenUKDealers() {
        dealers = createDealers(2, true);
        
        // UK dealers 
        dealers[4].ShippingStreet = '3000 KINGSWAY';
        dealers[4].ShippingCity = 'CUMBRIA';
        dealers[4].ShippingState = 'XX';
        dealers[4].ShippingPostalCode = 'LA233HE';
        dealers[4].ShippingCountry = testCountryCodeToCountryNameMap.get(testCountryCodes[2]);
        dealers[4].Phone = '000011441212121212';
        dealers[4].Website = 'http://test.salesforce.com';
        dealers[4].Phone__c = '';
        dealers[4].Website__c = '';
        
        dealers[5].ShippingStreet = '16229 FRASER';
        dealers[5].ShippingCity = 'DORSET';
        dealers[5].ShippingState = 'XX';
        dealers[5].ShippingPostalCode = 'BH14 8JR';
        dealers[5].ShippingCountry = testCountryCodeToCountryNameMap.get(testCountryCodes[2]);
        dealers[5].Phone = '000011442323232323';
        dealers[5].Website = 'http://test.salesforce.com';
        dealers[5].Phone__c = '';
        dealers[5].Website__c = '';
        
        update dealers; 
        
        //for(Account acc: dealers){            
            dealerBrands.addAll(createDealerBrands(1, true, dealers[0].Id));
        //}
        
        for(Dealer_Brand__c dealerBrand : dealerBrands){
            territories.addAll(createTerritories(1, true, dealerBrand.Id, dealerBrand.Dealer__c, testUnitedStatesZipcodes[0]));
        }
    }
       
     
   

  /*static testMethod void test_DealerLocator_UK()
    {
        // Ivy House, 71 Langham Road, Bowdon, Cheshire WA14 3NT - Manchester England?
        // Abersoch, Pwllheli, LL53 7AH, United Kingdom - Wales UK
        
        init();
        list<DealerInfo> di = DealerLocator.getDealerInfo(null,testCountryCodes[2]);

    }*/
    
    private static Integer recordCounter = 0;
    
    static list<Account> createDealers( Integer qtyToCreate, Boolean doInsert ){
        String unique = String.valueof(Datetime.now()).replace(' ','_').replace('-','_').replace(':','_') + String.valueOf(Math.random());
        list<Account> testSObjs = new list<Account>();
        for( Integer index = 0; index < qtyToCreate; index++ )
        {
            Account newSObj = new Account(Name = 'Dealer' + ' ' + index + unique
                                        , Dealer_Number__c = unique.substring(0,27) + String.valueOf(index)
                                        , RecordTypeId = dealerRecordTypeId);
            testSObjs.add( newSObj );
        }
        
        if(doInsert){
            insert testSObjs;
        }
        return testSObjs;
    }
    static list<Territory__c> createTerritories( Integer qtyToCreate, Boolean doInsert, Id dealerBrandId, Id accountId, String postalCode ){
        String unique = String.valueof(Datetime.now()).replace(' ','_').replace('-','_').replace(':','_') + String.valueOf(Math.random());
        list<Territory__c> testSObjs = new list<Territory__c>();
        for( Integer index = 0; index < qtyToCreate; index++ )
        {
            Territory__c newSObj = new Territory__c(Dealer__c = accountId
                                                    , Dealer_Brand__c = dealerBrandId
                                                    , Zipcode_Postal_Code__c = postalCode);
            testSObjs.add( newSObj );
        }
        if(doInsert){
            insert testSObjs;
        }
        return testSObjs;
    }
    static list<Dealer_Brand__c> createDealerBrands( Integer qtyToCreate, Boolean doInsert, Id accountId ){
        String unique = String.valueof(Datetime.now()).replace(' ','_').replace('-','_').replace(':','_') + String.valueOf(Math.random());
        list<Dealer_Brand__c> testSObjs = new list<Dealer_Brand__c>();
        for( Integer index = 0; index < qtyToCreate; index++ )
        {
            Dealer_Brand__c newSObj = new Dealer_Brand__c(Dealer__c = accountId
                                                        , Brand__c = 'BL'
                                                        , Status__c = 'Active'
                                                        , Name = 'Bayliner ' + unique);
            testSObjs.add( newSObj );
        }
        
        if(doInsert){
            insert testSObjs;
        }
        return testSObjs;
    }
     static testMethod void test_DealerLocator_US()
    {
        givenUSDealers();
        System.assertNotEquals(null,DealerLocator.getDealerInfo(testUnitedStatesZipcodes[0],testCountryCodes[0]));
    }
    
    static testMethod void test_DealerLocator_Canada()
    {       
        givenCanadaDealers();
        System.assertNotEquals(null, DealerLocator.getDealerInfo(testCanadaZipcodesParts[0],testCountryCodes[1]));
    }
    
    private static testMethod void testGetDealerInfoMessage(){
        
        String exceptionMessage = 'TestThisMessage';
        
        List<DealerInfo> dealerInfoList = new List<DealerInfo>();
        
        Test.startTest();
            DealerLocator.getDealerInfoMessage(dealerInfoList, exceptionMessage);
        Test.stopTest();
        
        System.assertEquals(1, dealerInfoList.size());
        System.assertEquals(exceptionMessage, dealerInfoList[0].exceptionMessage);
        
    }
    
     private static testMethod void testGetDealerInfoV2_NoLocatorRuleFound(){
        
        final String testValidCountryName = 'United States';
        final String testValidPostalCode = '31232';
        final String testValidBrandCode = 'BL';
        
        final String testDomestic = 'Domestic';
        final String testWebsite = 'http://www.bayliner.com';
        
        
        Test.startTest();
            
            List<DealerInfo> dealerInfoFound = DealerLocator.getDealerInfoV2(testValidPostalCode, 
                                                    testValidCountryName, 
                                                    testValidBrandCode, 
                                                    testDomestic, 
                                                    testWebsite); 
        Test.stopTest();
        
        System.assertEquals(1, dealerInfoFound.size(), 'We expect to get back just one DealerFound result');
        System.assertEquals(null, dealerInfoFound[0].dealerId, 'We do not expect to not have any actual results');
        System.assertNotEquals(null, dealerInfoFound[0].exceptionMessage, 
            'We expect to have an exception message stating that no locator rule was found.');
        
     }
     
     private static testMethod void testGetDealerInfoV2_NoPostalCodeOrCountryName(){
        
        final String testValidCountryName = 'United States';
        final String testValidPostalCode = '30318';
        final String testValidBrandCode = 'BL';
        
        final String testDomestic = 'Domestic';
        final String testWebsite = 'http://www.bayliner.com';
        
        Dealer_Locator_Rule__c testDealerLocatorRule = TestUtilities.createDealerLocatorRule(testValidBrandCode, testValidCountryName, testDomestic, testWebsite, false);
        insert testDealerLocatorRule;
        
        Test.startTest();
        
            List<DealerInfo> dealerInfoFound1 = DealerLocator.getDealerInfoV2(null, 
                                                                            testValidCountryName, 
                                                                            testValidBrandCode, 
                                                                            testDomestic, 
                                                                            testWebsite);
            List<DealerInfo> dealerInfoFound2 = DealerLocator.getDealerInfoV2(testValidBrandCode, 
                                                                            null, 
                                                                            testValidBrandCode, 
                                                                            testDomestic, 
                                                                            testWebsite);
            List<DealerInfo> dealerInfoFound3 = DealerLocator.getDealerInfoV2(null, 
                                                                            null, 
                                                                            testValidBrandCode, 
                                                                            testDomestic, 
                                                                            testWebsite);
        Test.stopTest();
        
        List<List<DealerInfo>> dealerInfoList = new List<List<DealerInfo>>{dealerInfoFound1, dealerInfoFound2, dealerInfoFound3};
        
        for (List<DealerInfo> dealerInfoFound : dealerInfoList ){
            System.assertEquals(1, dealerInfoFound.size(), 'We expect to get back just one DealerFound result');
            System.assertEquals(null, dealerInfoFound[0].dealerId, 'We do not expect to not have any actual results');
            System.assertNotEquals(null, dealerInfoFound[0].exceptionMessage, 
                'We expect to have an exception message requesting both postal code and country code');
        }
        
        
     }
     
     private static testMethod void testGetDealerInfoV2_LocatorRuleFound_NoISOCodeCustomSetting_NoAssignedDealers(){
     
        // No Custom Setting Set Up
        
        final String testValidCountryName = 'United States';
        final String testValidPostalCode = '30318';
        final String testValidPostalCode2 = '30322';
        final String testValidBrandCode = 'BL';
        
        final String testDomestic = 'Domestic';
        final String testWebsite = 'http://www.bayliner.com';
        
        Dealer_Locator_Rule__c testDealerLocatorRule = TestUtilities.createDealerLocatorRule(testValidBrandCode, testValidCountryName, testDomestic, testWebsite, false);
        testDealerLocatorRule.No_Assigned_Dealer_Functionality__c = DealerLocatorRuleServices.NON_ASSIGNED_DEALERS_BY_POSTAL_CODE;
        insert testDealerLocatorRule;
        
        Test.startTest();
        
            List<DealerInfo> dealerInfoFound = DealerLocator.getDealerInfoV2(testValidPostalCode2, 
                                                                            testValidCountryName, 
                                                                            testValidBrandCode, 
                                                                            testDomestic, 
                                                                            testWebsite);
        Test.stopTest();
        
        System.assertEquals(1, dealerInfoFound.size(), 'We expect to get back just one DealerFound result');
        System.assertEquals(null, dealerInfoFound[0].dealerId, 'We do not expect to not have any actual results');
        System.assertNotEquals(null, dealerInfoFound[0].exceptionMessage, 
            'We expect to have an exception message requesting admin setup ISO code custom setting');
        
     }
     
     
     private static testMethod void testGetDealerInfoV2_LocatorRuleFound_AssignedDealerFunctionality(){
        Map<String, String> testISOCodes = new Map<String, String>{
            'United States' => 'US',
            'Canada' => 'CA'
        };
        
        TestUtilities.createCountryISOCodeCS(testISOCodes, true);
        
        final String testValidCountryName = 'United States';
        final String testValidPostalCode = '31232';
        final String testValidBrandCode = 'BL';
        
        final String testDomestic = 'Domestic';
        final String testWebsite = 'http://www.bayliner.com';
        
        
        setupPostalCodeTerritories(testValidBrandCode, testValidPostalCode, testValidCountryName);
        
        Dealer_Locator_Rule__c testDealerLocatorRule = TestUtilities.createDealerLocatorRule(testValidBrandCode, testValidCountryName, testDomestic, testWebsite, false);
        testDealerLocatorRule.Assigned_Dealer_Functionality__c = DealerLocatorRuleServices.ASSIGNED_DEALERS_BY_POSTAL_CODE;
        insert testDealerLocatorRule;
        
        Test.startTest();
            
            List<DealerInfo> dealerInfoFound = DealerLocator.getDealerInfoV2(testValidPostalCode, 
                                                    testValidCountryName, 
                                                    testValidBrandCode, 
                                                    testDomestic, 
                                                    testWebsite); 
        Test.stopTest();
        
        Set<Id> dealerIdsFound = new Set<Id>();
        for (DealerInfo dInfo : dealerInfoFound){
            dealerIdsFound.add(dInfo.dealerId);
        }
                                            
        System.assertEquals(UnitTest.getIds('Matching Accounts'),
                            dealerIdsFound, 'We expect to find the matching accounts');
        
     }
     private static testMethod void testGetDealerInfoV2_LocatorRuleFound_NoAssignedDealersFunctionality(){
        
        Map<String, String> testISOCodes = new Map<String, String>{
            'United States' => 'US',
            'Canada' => 'CA'
        };
        
        TestUtilities.createCountryISOCodeCS(testISOCodes, true);
        
        final String testValidCountryName = 'United States';
        final String testValidPostalCode = '30318';
        final String testValidPostalCode2 = '30322';
        final String testValidBrandCode = 'BL';
        
        final String testDomestic = 'Domestic';
        final String testWebsite = 'http://www.bayliner.com';
        
        
        setupPostalCodeTerritories(testValidBrandCode, testValidPostalCode, testValidCountryName);
        
        Dealer_Locator_Rule__c testDealerLocatorRule = TestUtilities.createDealerLocatorRule(testValidBrandCode, testValidCountryName, testDomestic, testWebsite, false);
        testDealerLocatorRule.No_Assigned_Dealer_Functionality__c = DealerLocatorRuleServices.NON_ASSIGNED_DEALERS_BY_POSTAL_CODE;
        insert testDealerLocatorRule;
        
        Test.startTest();
        
            List<DealerInfo> dealerInfoFound = DealerLocator.getDealerInfoV2(testValidPostalCode2, 
                                                                            testValidCountryName, 
                                                                            testValidBrandCode, 
                                                                            testDomestic, 
                                                                            testWebsite);

        Test.stopTest();
        
        Set<Id> dealerIdsFound = new Set<Id>();
        for (DealerInfo dInfo : dealerInfoFound){
            System.assertNotEquals(null, dInfo.dealerId, 
                'We expect to not have any exception messages: ' + dInfo.exceptionMessage);
            dealerIdsFound.add(dInfo.dealerId);
        }
                                                
        System.assertEquals(UnitTest.getIds('Matching Accounts'),
                            dealerIdsFound, 'We expect to find the matching accounts');
        
        
     }
     
     private static testMethod void testGetDealerInfoV2_LocatorRuleFound_NoDealersFunctionality(){
        
        Map<String, String> testISOCodes = new Map<String, String>{
            'United States' => 'US',
            'Canada' => 'CA'
        };
        
        TestUtilities.createCountryISOCodeCS(testISOCodes, true);
        
        final String testValidCountryName = 'United States';
        final String testValidPostalCode = '30318';
        final String testValidBrandCode = 'BL';
        
        final String testDomestic = 'Domestic';
        final String testWebsite = 'http://www.bayliner.com';
        
        setupRegionalOfficeTerritories(testValidBrandCode, testISOCodes.values());
        
        
        Dealer_Locator_Rule__c testDealerLocatorRule = TestUtilities.createDealerLocatorRule(testValidBrandCode, testValidCountryName, testDomestic, testWebsite, false);
        testDealerLocatorRule.Final_No_Results_Functionality__c = DealerLocatorRuleServices.NO_DEALERS_COUNTRY_REGIONAL_OFFICE_LOOKUP;
        insert testDealerLocatorRule;
        
        Test.startTest();
        
            List<DealerInfo> dealerInfoFound = DealerLocator.getDealerInfoV2(testValidPostalCode, 
                                                                            testValidCountryName, 
                                                                            testValidBrandCode, 
                                                                            testDomestic, 
                                                                            testWebsite);

        Test.stopTest();
        
        System.assert(!dealerInfoFound.isEmpty(), 'We expect to get back at least one regional office');
        for (DealerInfo dInfo : dealerInfoFound){
            System.assertNotEquals(null, dInfo.dealerId, 
                'We do not expect to have any valid dealers found: ');
            System.assertNotEquals(null, dInfo.exceptionMessage, 
                'We do not expect to have any valid dealers with exception message: ' + dInfo.exceptionMessage);
        }
        
     }
     
     private static void setupPostalCodeTerritories(String testValidBrandCode, 
                                                    String testValidPostalCode, 
                                                    String testValidCountryName){
        
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
            dealerAcc.GeoLocation__Latitude__s = 1.0;
            dealerAcc.GeoLocation__Longitude__s = 2.0;
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
        
     }
     
     
     private static void setupRegionalOfficeTerritories(String testValidBrandCode, 
                                                    List<String> testValidCountryCodes){
        
        
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
            .property('ShippingCountry').assignFrom(testValidCountryCodes);
            
            
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
        
     }
     
     
}