/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TestLeadTriggerHandler {
    
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
    static final String TEST_ISO_CODE = 'CA';
    static final String TEST_INTERNATIONAL_ISO_CODE = 'IN';
    static final String TEST_PHONE = '111 555 2222';
    static final String TEST_WEBSITE = 'bluewolf.com';
    static final String TEST_BRAND = 'SR';
    static final String TEST_BRAND_OF_INTEREST_FOR_LEAD = 'Sea Ray';
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
    
    private static void removeDisableRoutingSetting(){
        DisableLeadRoutingTrigger__c dlrtList = DisableLeadRoutingTrigger__c.getInstance('LeadRouting');
        dlrtList.disabled__c = FALSE;
        update dlrtList;
    }
    
    private static void insertAllowedLeadRecordTypeCS(){
        
        List<RecordType> recTypes= [SELECT Id, developerName from RecordType where SObjectType='Lead' and isActive=true LIMIT 2];
        List<LeadRoutingAllowedRecordTypes__c> csAllowedRecordTypes= new List<LeadRoutingAllowedRecordTypes__c>();
        allowedLeadRecordType = recTypes[0];
        csAllowedRecordTypes.add(new LeadRoutingAllowedRecordTypes__c(Name=allowedLeadRecordType.developerName));
        insert csAllowedRecordTypes;
    }

    
    private static testMethod void TestLeadTriggerHandler_PIScoreGreaterThan50ReRoutesTheLeads() {
        // TO DO: implement unit test{
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
        Lead_Routing_Rule__c lRoutingRule = TestUtilities.createLeadRoutingRule('Sea Ray', 'SR', 'CA', 5, LeadRoutingConstants.zipAndProductRuleName, true);
        
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
        testLead.pi__Score__c = 20;
        insert leads;
        list<Lead> newLeads = [SELECT Id, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c, pi__Score__c,Brand_Code__c, Country_ISO_Code__c, PostalCode, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s FROM Lead WHERE Id = :leads[0].Id];
        system.debug('newLeads : ' + newLeads);
        
        Lead testUpdateLead = newLeads[0];
        testUpdateLead.pi__Score__c = 100;
        test.startTest();
        LeadServices.isBatch=false;
        removeDisableRoutingSetting();
        update testUpdateLead;
        //LeadRouter lr = new LeadRouter(newLeads);
        //lr.routeAllLeads();
        test.stopTest();
        
        Lead l = [SELECT Id, PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :testUpdateLead.Id];
        system.debug('the lead looks like: ' + l);
/*        system.assertEquals(dealerAcc1.Id,l.Assigned_Dealer_1__c,'The closest dealer should be '+dealerAcc1.Id);
        system.assertEquals(dealerAcc2.Id,l.Assigned_Dealer_2__c,'The closest dealer should be '+dealerAcc2.Id);
        system.assertEquals(dealerAcc3.Id,l.Assigned_Dealer_3__c,'The closest dealer should be '+dealerAcc3.Id);
        system.assertEquals(dealerAcc4.Id,l.Assigned_Dealer_4__c,'The closest dealer should be '+dealerAcc4.Id);
*/        
        list<Assigned_Dealer__c> assignedDealers = [SELECT Id, Primary_Email__c FROM Assigned_Dealer__c WHERE Lead__c = :l.Id];
/*        system.assertEquals(4,assignedDealers.size());
        for(Assigned_Dealer__c ad:assignedDealers){
            system.assertEquals(DEALER_BRAND_PRIMARY_EMAIL,ad.Primary_Email__c, 'The primary email from the dealer brand should be in the primary email field for the Assigned Dealer record.');
        }
*/    }
 }