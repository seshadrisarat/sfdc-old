@isTest
public class TestLeadRouter {
    
    public static list<Account> dealers{get;set;}
    public static list<Dealer_Brand__c> dbrands{get;set;}
    public static list<Territory__c> territories{get;set;}
    public static list<Lead_Routing_Rule__c> routingRules{get;set;}
    static final String TEST_STREET = '112 E. HIGH STREET';
    static final String TEST_CITY = 'HENNEPIN';
    static final String TEST_STATE = 'IL';
    static final String TEST_POSTAL_CODE = '61327';
    static final String TEST_COUNTRY = 'United States';
    static final String TEST_COUNTY = 'Cook';
    static final String TEST_ISO_CODE = 'US';
    static final String TEST_INTERNATIONAL_ISO_CODE = 'IN';
    static final String TEST_PHONE = '111 555 2222';
    static final String TEST_WEBSITE = 'bluewolf.com';
    static final String TEST_BRAND = 'SR';
    static final String TEST_BRAND_OF_INTEREST_FOR_LEAD = 'Sea Ray';
    static final String TEST_DIFF_BRAND_OF_INTEREST_FOR_LEAD = 'Bayliner';
    static final Decimal TEST_LONGITUDE_FOR_LEAD = -121.895;
    static final Decimal TEST_LATITUDE_FOR_LEAD = 37.4352;
    
    /* Increment the longitude by .01 for each dealer so we can test the proximity search results
     * and be sure to know the order in which the dealers should be returned*/
    /////////////////////////////////////////////////////////////////////////
    static final Decimal TEST_LONGITUDE_FOR_DEALER_1 = -121.894;
    static final Decimal TEST_LATITUDE_FOR_DEALER_1 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_2 = -121.893;
    static final Decimal TEST_LATITUDE_FOR_DEALER_2 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_3 = -121.892;
    static final Decimal TEST_LATITUDE_FOR_DEALER_3 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_4 = -121.891;
    static final Decimal TEST_LATITUDE_FOR_DEALER_4 = 37.4352;
    /////////////////////////////////////////////////////////////////////////
    
    static final String DEALER_BRAND_PRIMARY_EMAIL = 'testemail@test.com';
    static final String TEST_BOAT_CLASS = 'Test Boat Class';
    static final String TEST_BOAT_CLASS_YACHT = 'Test Yacht Class';
    static final String TEST_BOAT_CLASS_Cruiser = 'Test Cruiser Class';
    static final String TEST_BOAT_BRAND = 'SR';
    static Account dealerAcc1, dealerAcc2, dealerAcc3, dealerAcc4;
    static RecordType allowedLeadRecordType;
    
    private static list<Account> makeDealers(){
        AccountServices.ranPopulateAccountGeoFields = TRUE; // this disables the geolocation trigger since we're not testing that.
        dealers = TestUtilities.createTestAccount(4,
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
                                                                    TEST_BOAT_BRAND);
        
        Integer x = 1;
        
        for( Account dealer : dealers )
        {
            dealer.Dealer_Number__c = 'test '+ x++;
            dealer.County__c = TEST_COUNTY;
        }
        
        dealers[0].GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealers[0].GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
        dealers[1].GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealers[1].GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
        dealers[2].GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_3;
        dealers[2].GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_3;
        dealers[3].GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_4;
        dealers[3].GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_4;
        
        return dealers;
    }

    private static list<Dealer_Brand__c> makeDealerBrands(){
        system.debug('the dealers created in setup look like: ' + dealers);
        
        dbrands = TestUtilities.createDealerBrand(dealers);
        
        for( integer i = 0; i < dbrands.size(); i++ )
        {
            dbrands[i].Brand__c = TEST_BRAND;
            dbrands[i].Dealer_Primary_Email__c = DEALER_BRAND_PRIMARY_EMAIL;
        }
                system.debug('the dealer brands created in setup look like: ' + dbrands);
        return dbrands;        
    }    
    
    private static list<Territory__c> makeTerritories(){
        territories = new List<Territory__c>();
        
        for(Dealer_Brand__c dBrand : dbrands )
        {
            Territory__c testTerr = TestUtilities.createTerritories(dBrand, 1, false )[0];
            testTerr.County__c = TEST_COUNTY;
            testTerr.State_Province__c = TEST_STATE;
            testTerr.Zipcode_Postal_Code__c = TEST_POSTAL_CODE;
            testTerr.Boat_Class__c = TEST_BOAT_CLASS;
            territories.add( testTerr );
        }
        system.debug('the testTerritories created in setup look like: ' + territories);
        return territories; 
    }
    
    private static void insertDisableRoutingSetting(){
        List<DisableLeadRoutingTrigger__c> dlrtList= DisableLeadRoutingTrigger__c.getall().values();
        if(dlrtList.size()>0)
            delete dlrtList;
        
        DisableLeadRoutingTrigger__c dlrt= new DisableLeadRoutingTrigger__c();	
        dlrt.Name='LeadRouting';
        insert dlrt;
    }
    
    private static void insertAllowedLeadRecordTypeCS(){
        
        List<RecordType> recTypes= [SELECT Id, developerName from RecordType where SObjectType='Lead' and isActive=true LIMIT 2];
        List<LeadRoutingAllowedRecordTypes__c> csAllowedRecordTypes= new List<LeadRoutingAllowedRecordTypes__c>();
        allowedLeadRecordType = recTypes[0];
        csAllowedRecordTypes.add(new LeadRoutingAllowedRecordTypes__c(Name=allowedLeadRecordType.developerName));
        insert csAllowedRecordTypes;
    }
    
    /*
    public static testMethod void TestLeadRoutingByZipAndProduct(){
    	disableTriggers();
        makeDealers();
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        makeTerritories();
        insert territories;
        
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.zipAndProductRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertEquals(l.Assigned_Dealer_1__c,dealerAcc1.Id,'The closest dealer should be '+dealerAcc1.Id);
        system.assertEquals(l.Assigned_Dealer_2__c,dealerAcc2.Id,'The closest dealer should be '+dealerAcc2.Id);
        system.assertEquals(l.Assigned_Dealer_3__c,dealerAcc3.Id,'The closest dealer should be '+dealerAcc3.Id);
        system.assertEquals(l.Assigned_Dealer_4__c,dealerAcc4.Id,'The closest dealer should be '+dealerAcc4.Id);
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(4,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }*/
 
    public static testMethod void TestLeadRoutingByZipOnly(){
    	disableTriggers();
        makeDealers();
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        // these territories should NOT match the Boat_Class - so no product specified.
        makeTerritories();
        for(Territory__c t:territories){
            t.Boat_Class__c = 'None'; // this makes the boat class on territory different than that of the lead.
        }
        insert territories;
        
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.zipOnlyRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, Country_ISO_Code__c, County__c, LeadSource, Lead_Form_Name__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, State, County__c, LeadSource, Lead_Form_Name__c, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertEquals(l.Assigned_Dealer_1__c,dealerAcc1.Id,'The closest dealer should be '+dealerAcc1.Id);
        system.assertEquals(l.Assigned_Dealer_2__c,dealerAcc2.Id,'The closest dealer should be '+dealerAcc2.Id);
        system.assertEquals(l.Assigned_Dealer_3__c,dealerAcc3.Id,'The closest dealer should be '+dealerAcc3.Id);
        system.assertEquals(l.Assigned_Dealer_4__c,dealerAcc4.Id,'The closest dealer should be '+dealerAcc4.Id);
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(4,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }
    
    
    public static testMethod void TestLeadRoutingByLatLon(){
    	disableTriggers();
        makeDealers();
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        // no need to make territories when searching by lat/lon
        
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.latLonRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertEquals(l.Assigned_Dealer_1__c,dealerAcc1.Id,'The closest dealer should be '+dealerAcc1.Id);
        system.assertEquals(l.Assigned_Dealer_2__c,dealerAcc2.Id,'The closest dealer should be '+dealerAcc2.Id);
        system.assertEquals(l.Assigned_Dealer_3__c,dealerAcc3.Id,'The closest dealer should be '+dealerAcc3.Id);
        system.assertEquals(l.Assigned_Dealer_4__c,dealerAcc4.Id,'The closest dealer should be '+dealerAcc4.Id);
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(4,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }
   
   /*
    public static testMethod void TestLeadRoutingByStateAndProduct(){
    	disableTriggers();
        makeDealers();
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        // these territories should NOT match the Boat_Class - so no product specified.
        makeTerritories();
        territories[3].State_Province__c = 'PA';
         // make the last territory state not match, to confirm we're filtering out states.
        insert territories;
        system.debug('territories in State test looks like: '+ territories);
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.stateRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.State = TEST_STATE;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertNotEquals(null,l.Assigned_Dealer_1__c,'A dealer should have been added to Assigned_Dealer_1__c.');
        system.assertNotEquals(null,l.Assigned_Dealer_2__c,'A dealer should have been added to Assigned_Dealer_2__c.');
        system.assertNotEquals(null,l.Assigned_Dealer_3__c,'A dealer should have been added to Assigned_Dealer_3__c.');
        system.assertEquals(null, l.Assigned_Dealer_4__c,'A dealer should NOT have been added to this field since we only set 3 territories with the same state.');
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(3,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }*/
    
    /*
    public static testMethod void TestLeadRoutingByCountryAndProduct(){
    	disableTriggers();
        makeDealers();
        // place one of the dealers in a different country than the lead
        dealers[3].Country_ISO_Code__c = null;
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        makeTerritories();
        insert territories;
        
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.countryWithProductRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.State = TEST_STATE;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertNotEquals(null,l.Assigned_Dealer_1__c,'A dealer should have been added to Assigned_Dealer_1__c.');
        system.assertNotEquals(null,l.Assigned_Dealer_2__c,'A dealer should have been added to Assigned_Dealer_2__c.');
        system.assertNotEquals(null,l.Assigned_Dealer_3__c,'A dealer should have been added to Assigned_Dealer_3__c.');
        system.assertEquals(null, l.Assigned_Dealer_4__c,'A dealer should NOT have been added to this field since we only set 3 territories with the same state.');
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(3,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }*/
    
    public static testMethod void TestLeadRoutingByCountyAndCountryAndProduct(){
    	disableTriggers();
        makeDealers();
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1]; 
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        makeTerritories();
        // This is the one we want to match on
        territories[0].Zipcode_Postal_Code__c = null;
        
        // Disable all the others in ways that will not cause a match
        territories[1].Zipcode_Postal_Code__c = null;
        territories[1].County__c = null;
        
        territories[2].Zipcode_Postal_Code__c = null;
        territories[2].Boat_Class__c = null;
        
        territories[3].Zipcode_Postal_Code__c = null;
        territories[3].Boat_Class__c = null;
        territories[3].County__c = null;
        
        insert territories;
       
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.countyWithCountryWithProductRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = null;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.State = TEST_STATE;
        testLead.County__c = TEST_COUNTY;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
       
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertNotEquals(null,l.Assigned_Dealer_1__c,'A dealer should have been added to Assigned_Dealer_1__c.');
        system.assertEquals(null,l.Assigned_Dealer_2__c,'A dealer should NOT have been added to Assigned_Dealer_2__c.');
        system.assertEquals(null,l.Assigned_Dealer_3__c,'A dealer should NOT have been added to Assigned_Dealer_3__c.');
        system.assertEquals(null, l.Assigned_Dealer_4__c,'A dealer should NOT have been added to this field since we only set 3 territories with the same state.');
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(1,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }
 
    public static testMethod void TestLeadRoutingByCountryOnly(){
    	disableTriggers();
        makeDealers();
        // place one of the dealers in a different country than the lead
        dealers[3].Country_ISO_Code__c = null;
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        // these territories should NOT match the Boat_Class - so no product specified.
        makeTerritories();
        for(Territory__c t:territories){
            // make all of the products so they don't match the lead.
            t.Boat_Class__c = null;
        }
        insert territories;
        
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.countryWithoutProductRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.State = TEST_STATE;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertNotEquals(null,l.Assigned_Dealer_1__c,'A dealer should have been added to Assigned_Dealer_1__c.');
        system.assertNotEquals(null,l.Assigned_Dealer_2__c,'A dealer should have been added to Assigned_Dealer_2__c.');
        system.assertNotEquals(null,l.Assigned_Dealer_3__c,'A dealer should have been added to Assigned_Dealer_3__c.');
        system.assertEquals(null, l.Assigned_Dealer_4__c,'A dealer should NOT have been added to this field since we only set 3 territories with the same country.');
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(3,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }
    
    
    
    //Test Custom Routing Exception , where boat class has a Yacht
    public static testMethod void TestCustomRoutingExceptions_Yacht(){
        makeDealers();
        disableTriggers();
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        // no need to make territories when searching by lat/lon
        
        // make lead routing rules specific to new functionality
    //    Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.latLonRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
  //      testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS_YACHT;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.pi__Score__c = 0;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertEquals(l.Assigned_Dealer_1__c,dealerAcc1.Id,'The closest dealer should be '+dealerAcc1.Id);
    //    system.assertEquals(l.Assigned_Dealer_2__c,dealerAcc2.Id,'The closest dealer should be '+dealerAcc2.Id);
    //    system.assertEquals(l.Assigned_Dealer_3__c,dealerAcc3.Id,'The closest dealer should be '+dealerAcc3.Id);
    //    system.assertEquals(l.Assigned_Dealer_4__c,dealerAcc4.Id,'The closest dealer should be '+dealerAcc4.Id);
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(1,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }
    
    //Test Custom Routing Exceptions where Boat Class has a Cruiser
    /*
    public static testMethod void TestCustomRoutingExceptions_Cruiser(){
    	disableTriggers();
        makeDealers();
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        // no need to make territories when searching by lat/lon
        
        // make lead routing rules specific to new functionality
    //    Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.latLonRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
  //      testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS_Cruiser;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.pi__Score__c = 0;
        insert leads;
        list<Lead> newLeads = [SELECT Id, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, State, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertEquals(l.Assigned_Dealer_1__c,dealerAcc1.Id,'The closest dealer should be '+dealerAcc1.Id);
        system.assertEquals(l.Assigned_Dealer_2__c,dealerAcc2.Id,'The closest dealer should be '+dealerAcc2.Id);
        system.assertEquals(l.Assigned_Dealer_3__c,dealerAcc3.Id,'The closest dealer should be '+dealerAcc3.Id);
    //    system.assertEquals(l.Assigned_Dealer_4__c,dealerAcc4.Id,'The closest dealer should be '+dealerAcc4.Id);
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(3,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }*/
    
    //
    public static testMethod void TestLeadRoutingByRegionalOfficeCountry(){
    	disableTriggers();
        makeDealers();
        // place one of the dealers in a different country than the lead
        dealers[0].Country_ISO_Code__c = 'IN';
        dealers[1].Country_ISO_Code__c = 'IN';
        dealers[2].Country_ISO_Code__c = 'IN';
        dealers[3].Country_ISO_Code__c = 'IN';
        dealers[0].Dealer_Type__c = 'Regional Office';
        dealers[1].Dealer_Type__c = 'Regional Office';
        dealers[2].Dealer_Type__c = 'Regional Office';
        dealers[3].Dealer_Type__c = 'Regional Office';
        insert dealers;
        
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        // these territories should NOT match the Boat_Class - so no product specified.
        makeTerritories();
        for(Territory__c t:territories){
            // make all of the products so they don't match the lead.
            t.Regional_Office_Country__c = 'IN';
        }
        insert territories;
        
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', ' ', 5, LeadRoutingConstants.regionalOfficeRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_INTERNATIONAL_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.State = TEST_STATE;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c,GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertEquals(l.Assigned_Dealer_1__c,dealerAcc1.Id,'The closest dealer should be '+dealerAcc1.Id);
        system.assertEquals(l.Assigned_Dealer_2__c,dealerAcc2.Id,'The closest dealer should be '+dealerAcc2.Id);
        system.assertEquals(l.Assigned_Dealer_3__c,dealerAcc3.Id,'The closest dealer should be '+dealerAcc3.Id);
        system.assertEquals(l.Assigned_Dealer_4__c,dealerAcc4.Id,'The closest dealer should be '+dealerAcc4.Id);
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(4,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }
  
    public static testMethod void TestLeadRoutingWithMultipleRoutingAttempts(){
    	disableTriggers();
        makeDealers();
        insert dealers;
        dealerAcc1 = dealers[0];
        dealerAcc2 = dealers[1];
        dealerAcc3 = dealers[2];
        dealerAcc4 = dealers[3];
        
        makeDealerBrands();
        insert dbrands;
        
        makeTerritories();
        insert territories;
        
        // make lead routing rules specific to new functionality
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createMultipleLeadRoutingRule('Sea Ray', 'SR', 'US', 5, LeadRoutingConstants.zipAndProductRuleName, LeadRoutingConstants.zipOnlyRuleName, true);
        
        LeadServices.isBatch=true; // this disables the trigger as we're not testing that right now.
        
        insertAllowedLeadRecordTypeCS();
        
        insertDisableRoutingSetting();
        
        List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
     //   testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.pi__Score__c = 1;
        insert leads;
        list<Lead> newLeads = [SELECT Id, State, pi__score__c, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        LeadRouter lr = new LeadRouter();
        test.startTest();
        lr.routeToDealers(newLeads);
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, State, Brand_Code__c, county__c, LeadSource, Lead_Form_Name__c, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :leads[0].Id];
        system.debug('the lead looks like: ' + l);
        system.assertEquals(l.Assigned_Dealer_1__c,dealerAcc1.Id,'The closest dealer should be '+dealerAcc1.Id);
        system.assertEquals(l.Assigned_Dealer_2__c,dealerAcc2.Id,'The closest dealer should be '+dealerAcc2.Id);
        system.assertEquals(l.Assigned_Dealer_3__c,dealerAcc3.Id,'The closest dealer should be '+dealerAcc3.Id);
        system.assertEquals(l.Assigned_Dealer_4__c,dealerAcc4.Id,'The closest dealer should be '+dealerAcc4.Id);
        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
        system.assertEquals(4,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
    }
    private static void disableTriggers() {
		OwnerServices.isApexTest = true;
		DealerRouter.doNotSendEmail = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		TerritoryServices.disableTriggerProcessing = true;
		OwnerServices.populateOwnerGeoFieldsIsRunning = true;
	}
/*
public static testMethod void TestLeadRoutingByRegionalOffice(){

}
*/
}