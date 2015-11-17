@isTest
public class TestLeadServices {
	private static Id DEALER_RECORD_TYPE = [Select Id from RecordType where SobjectType='Account' and Name='Dealer' limit 1].Id;
	public static final String ERROR_CODE = 'M4B 1B3';
	public static final String SUCCESS_CODE = 'M2V 1K7';
	static final Decimal TEST_LONGITUDE_FOR_DEALER_1 = -121.894;
    static final Decimal TEST_LATITUDE_FOR_DEALER_1 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_2 = -121.893;
    static final Decimal TEST_LATITUDE_FOR_DEALER_2 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_3 = -121.892;
    static final Decimal TEST_LATITUDE_FOR_DEALER_3 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_4 = -121.891;
    static final Decimal TEST_LATITUDE_FOR_DEALER_4 = 37.4352;
    static final string TEST_DNS_FORM_NAME = 'TestForm';
 
    static List<RecordType> recTypes;
    static Id allowedRecordTypesId;

    static{
        recTypes=[SELECT Id, developerName from RecordType where SObjectType='Lead' and isActive=true LIMIT 2];
    }

    static void setup(){
        DisableLeadRoutingTrigger__c dlrt= new DisableLeadRoutingTrigger__c ();
        dlrt.Name='LeadRouting';
        insert dlrt;

        RecordType allowedRecType= recTypes[0];
        allowedRecordTypesId=allowedRecType.Id;

        insert new LeadRoutingAllowedRecordTypes__c(Name=allowedRecType.developerName);
        
        Pardot_Score_Increase_Trigger__c psit = new Pardot_Score_Increase_Trigger__c(Name='SeaRay', Brand_Code__c='SR',Accumulated_Point_Amount__c=50, Days_Of_Activities__c=7);
        insert psit;
        
        Pardot_Connector_User_Alias__c pcua = new Pardot_Connector_User_Alias__c(Name='Sea Ray Pardot', Pardot_Instance__c='SR', User_Alias__c='SRPardot');
        insert pcua;
        
        Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=getIntegrationUserId());
		insert config;
    }
    
    static testMethod void assignDealersToLeadsIfNotGeocodingButAssignmentDataHasChanged_leadsNotAssignedIfNothingChanges() {
    	list<Lead> oldLeads = setupLeadsDealersAndRoutingRules();
    	oldLeads = getLead(oldLeads[0].Id);
    	
    	list<Lead> newLeads = getLead(oldLeads[0].Id);
    	map<Id, Lead> oldLeadsMap = new map<Id, Lead>();
    	map<Id, Lead> newLeadsMap = new map<Id, Lead>();
    	
    	oldLeadsMap.put(oldLeads[0].Id, oldLeads[0]);
    	newLeadsMap.put(newLeads[0].Id, newLeads[0]);
    	
    	Test.startTest();
    	LeadServices.assignDealersToLeadsIfNotGeocodingButScoreOrAssignmentDataHasChanged(oldLeadsMap, newLeadsMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Lead__c=:newLeads[0].Id];
    	system.assertEquals(0, assignedDealers.size());
    }
    
    static testMethod void assignDealersToLeadsIfNotGeocodingButAssignmentDataHasChanged_leadsAssignedIfProductCategoryChanges() {
    	list<Lead> oldLeads = setupLeadsDealersAndRoutingRules();

    	list<Lead> newLeads = getLead(oldLeads[0].Id);
    	newLeads[0].Boat_Category_of_Interest__c = 'Yacht';
    	update newLeads;
    	
    	map<Id, Lead> oldLeadsMap = new map<Id, Lead>();
    	map<Id, Lead> newLeadsMap = new map<Id, Lead>();
    	oldLeadsMap.put(oldLeads[0].Id, oldLeads[0]);
    	newLeadsMap.put(newLeads[0].Id, newLeads[0]);
    	
    	Test.startTest();
    	LeadServices.assignDealersToLeadsIfNotGeocodingButScoreOrAssignmentDataHasChanged(oldLeadsMap, newLeadsMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Lead__c=:newLeads[0].Id];
    	system.assertEquals(1, assignedDealers.size());
    }
    
    static testMethod void assignDealersToLeadsIfNotGeocodingButAssignmentDataHasChanged_leadsNotAssignedIfGeocoding() {
    	list<Lead> oldLeads = setupLeadsDealersAndRoutingRules();

    	list<Lead> newLeads = getLead(oldLeads[0].Id);
    	newLeads[0].Geonames_Retry__c = true;
    	update newLeads;
    	
    	map<Id, Lead> oldLeadsMap = new map<Id, Lead>();
    	map<Id, Lead> newLeadsMap = new map<Id, Lead>();
    	oldLeadsMap.put(oldLeads[0].Id, oldLeads[0]);
    	newLeadsMap.put(newLeads[0].Id, newLeads[0]);
    	
    	Test.startTest();
    	LeadServices.assignDealersToLeadsIfNotGeocodingButScoreOrAssignmentDataHasChanged(oldLeadsMap, newLeadsMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Lead__c=:newLeads[0].Id];
    	system.assertEquals(0, assignedDealers.size());
    }
    
    static testMethod void assignDealersToLeadsIfNotGeocodingButAssignmentDataHasChanged_leadsNotAssignedIfAddressChanged() {
    	list<Lead> oldLeads = setupLeadsDealersAndRoutingRules();

    	list<Lead> newLeads = getLead(oldLeads[0].Id);
    	newLeads[0].PostalCode = '91790';
    	update newLeads;
    	
    	map<Id, Lead> oldLeadsMap = new map<Id, Lead>();
    	map<Id, Lead> newLeadsMap = new map<Id, Lead>();
    	oldLeadsMap.put(oldLeads[0].Id, oldLeads[0]);
    	newLeadsMap.put(newLeads[0].Id, newLeads[0]);
    	
    	Test.startTest();
    	LeadServices.assignDealersToLeadsIfNotGeocodingButScoreOrAssignmentDataHasChanged(oldLeadsMap, newLeadsMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Lead__c=:newLeads[0].Id];
    	system.assertEquals(0, assignedDealers.size());
    }
    
    static testMethod void assignDealersToLeadsIfNotGeocodingButAssignmentDataHasChanged_leadsAssignedIfScoreChanged() {
    	list<Lead> oldLeads = setupLeadsDealersAndRoutingRules();

    	list<Lead> newLeads = getLead(oldLeads[0].Id);
    	newLeads[0].pi__score__c = newLeads[0].pi__score__c + DealerRouter.SCORE_THRESHOLD;
    	update newLeads;
    	
    	map<Id, Lead> oldLeadsMap = new map<Id, Lead>();
    	map<Id, Lead> newLeadsMap = new map<Id, Lead>();
    	oldLeadsMap.put(oldLeads[0].Id, oldLeads[0]);
    	newLeadsMap.put(newLeads[0].Id, newLeads[0]);
    	
    	Test.startTest();
    	LeadServices.assignDealersToLeadsIfNotGeocodingButScoreOrAssignmentDataHasChanged(oldLeadsMap, newLeadsMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Lead__c=:newLeads[0].Id];
    	system.assertEquals(1, assignedDealers.size());
    }
    
    static testMethod void testFilterIrrelevantRecordTypes(){
        setup();

        Id notAllowedRecordTypesId= recTypes[1].Id;


        UnitTest.addData(TestUtilities.createLeads(notAllowedRecordTypesId, 200, false)).tag('Leads');
        UnitTest.get('Leads').divide(2).part('Leads with Allowed Record Types')
                                        .part('Leads without Allowed Record Types');

        UnitTest.get('Leads with Allowed Record Types').assign('RecordTypeId', allowedRecordTypesId);
    
        UnitTest.get('Leads').dummyInsert();

        Test.startTest();
            List<Lead> filteredRecordTypes= LeadServices.filterIrrelevantRecordTypes(UnitTest.get('Leads').getList());
        Test.stopTest();

        UnitTest.analyze('Leads with Allowed Record Types').assertEquivalence(filteredRecordTypes, 'The test should return all the leads associated with the record types specified in the custom setting');
    }

    static testMethod void testErrorFieldPopulationOnWebserviceCalloutError(){
        setup();

        List<Lead> testLeads = TestUtilities.createLeads(allowedRecordTypesId, 2, false);
        testLeads.get(0).postalcode = SUCCESS_CODE; //this does not cause an error
        testLeads.get(1).postalcode = ERROR_CODE; //this causes an error
        testLeads.get(0).Country_ISO_Code__c = 'CA'; //the developers are aware that the two zip codes above are not in Canada
        testLeads.get(1).Country_ISO_Code__c = 'CA';

        test.startTest();
            insert testLeads;
        test.stopTest();

        Lead passLead = [SELECT Id, Geonames_Retry__c FROM Lead WHERE Id = :testLeads.get(0).Id];
        Lead failLead = [SELECT Id, Geonames_Retry__c FROM Lead WHERE Id = :testLeads.get(1).Id];

        System.assert(!passLead.Geonames_Retry__c, 'This lead should not have caused an error, so the checkbox should be unchecked.');
        System.assert(failLead.Geonames_Retry__c, 'This lead should have caused an error, so the checkbox should be checked.');
    }
    
    static testMethod void testProcessNoResultsOnWebserviceLeads(){
    	setup();
    	
    	List<Lead> testLeads = TestUtilities.createLeads(allowedRecordTypesId, 2, false);
    	testLeads.get(0).postalcode = 'NoResultsTest'; //no results
        testLeads.get(1).postalcode = SUCCESS_CODE; //normal lead
        testLeads.get(0).Country_ISO_Code__c = 'US'; 
        testLeads.get(1).Country_ISO_Code__c = 'CA'; //Dev are aware that is not in Canada
        
        test.startTest();
            insert testLeads;
        test.stopTest();
        
        Lead failLead = [SELECT Id, Assigned_Dealer_1__c,GeoNames_WebService_Error__c  FROM Lead WHERE Id = :testLeads.get(0).Id];
        Lead passLead = [SELECT Id, county__c,GeoNames_WebService_Error__c FROM Lead WHERE Id = :testLeads.get(1).Id];
    	
    	System.assertEquals(LeadServices.NO_GEO_RESULTS_MSG,failLead.GeoNames_WebService_Error__c, 'If it doesnt find results, updates error field and lead');
    	System.assertNotEquals(LeadServices.NO_GEO_RESULTS_MSG, passLead.GeoNames_WebService_Error__c,'If it finds results, error field is blank or null');
    	
    	System.assertEquals(null, failLead.Assigned_Dealer_1__c,'If it doesnt find results, no assigned dealer');
    	System.assertNotEquals(null, passLead.county__c, 'If it finds results,assigns county');
    	
    }
    
    
    static testmethod void testGetLeadsWithChangedFootstepsFields(){
    	setup();
    	
    	FootstepsService.leadFootstepsIntegrationFields = new List<String>{
			'FirstName', 'LastName'
		};

        UnitTest.addData(TestUtilities.createLeads(null, 200, false)).tag('Leads');
        UnitTest.get('Leads')
        	.divide(2)
        	.part('Leads with no changes')
        	.part('Leads with a field change');
        	
        UnitTest.get('Leads with a field change')
        	.divide(2)
        	.part('Leads with a change in a monitiored field')
        	.part('Leads with a change in some other field');
        
        UnitTest.get('Leads').dummyInsert();
        
        Map<Id, Lead> oldMap = new Map<Id, Lead>((List<Lead>)UnitTest.get('Leads').getList().deepClone(true));
		
		UnitTest.get('Leads with a change in a monitiored field')
			.property('FirstName').assign('NewName')
			.property('LastName').assign('NewLastName');
			
		UnitTest.get('Leads with a change in some other field')
			.property('LeadSource').assign('NewName');
		
		Map<Id, Lead> newMap = new Map<Id, Lead>((List<Lead>)UnitTest.get('Leads').getList());


        Test.startTest();
            Map<Id, Lead> filteredLeads = FootstepsService.getLeadsWithChangedFootstepsFields(newMap, oldMap);
        Test.stopTest();

        UnitTest.analyze('Leads with a change in a monitiored field').assertEquivalence(filteredLeads.values(), 
        	'The test should return all the leads with a change in a monitored field');
    
    }
    
    /*
    
    static testMethod void testCheckPardotScoreIncrease(){
        setup();

        List<Lead> testLeads = TestUtilities.createLeads(allowedRecordTypesId, 2, false);
        List<Id> leadIds = new List<Id>();
        
        for (Lead lead : testLeads) {
        	leadIds.add(lead.Id);
        }
        
        LeadServices.checkPardotScoreIncrease(leadIds);
    }*/
    
    static list<Lead> setupLeadsDealersAndRoutingRules() {
    	setup();
    	disableTriggers();
    	createLeadRoutingDoNotSend();
    	createDealerRoutingTestMode();
    	createZipRoutingRule();
    	
    	Account dealer = createDealer();
		dealer.Longitude__c = TEST_LONGITUDE_FOR_DEALER_1;
    	dealer.Latitude__c = TEST_LATITUDE_FOR_DEALER_1;
		dealer.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer;
		
		disableTriggers();
		
		Dealer_Brand__c db = createDealerBrand(dealer, 'SR');
		insert db;
		Territory__c t = createTerritory(db);
		t.Zipcode_Postal_Code__c = dealer.ShippingPostalCode;
		insert t;
		
		disableTriggers();
    	
    	list<Lead> leads = createLeads(1);
    	
    	disableTriggers();
    	return leads;
    }
    
    static list<Lead> createLeads(integer numberOfLeads) {
    	list<Lead> leads = TestUtilities.createLeads(allowedRecordTypesId, numberOfLeads, false);
    	
    	for (integer i=0; i<numberOfLeads; i++) {
    		leads[i].Street ='111 Street';
     		leads[i].City = 'Knoxville';
     		leads[i].State ='TN';
     		leads[i].County__c ='Knox';
     		leads[i].PostalCode = '37929';
     		leads[i].Country = 'US';
     		leads[i].Country_ISO_Code__c = 'US';
     		leads[i].pi__score__c = 50;
     		leads[i].Brand_Interest__c = 'Sea Ray';
     		leads[i].GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
     		leads[i].GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
     		leads[i].latitude__c = TEST_LATITUDE_FOR_DEALER_1;
     		leads[i].longitude__c = TEST_LONGITUDE_FOR_DEALER_1;
    	}
    	
    	insert leads;
    	
    	return leads;
    }
    
    static list<Lead> getLead(Id leadId) {
    	return [select Id,
                Name,
                Brand_Code__c, 
                Lead_Emails_Sent__c,
                Street,
                City, 
                State,
                Country, 
                county__c,
                PostalCode,
                Phone,
                Home_Phone__c,
                Work_Phone__c,
                Email,
                Alternate_Email_Address__c,
                Lead_Form_Name__c,
                Type_of_inquiry__c,
                LeadSource, 
                latitude__c, 
                longitude__c, 
                GeoLocation__Latitude__s,
                GeoLocation__Longitude__s,
                GeoNames_WebService_Error__c,
                Country_ISO_Code__c,
                CreatedDate,
                Previous_Boat_Owner__c,
                Current_Owned_Brand__c,
                Current_Owned_Boat_Class__c,
                Currently_Owned_Year__c,
                Current_Owned_ID_Number__c,
                Boat_Model_Interest__c,
                Boat_Class_Interest__c,
                Boat_Category_of_Interest__c,
                Boat_Year_Interest__c,
                Interested_in_Stock_Number__c,
                Interested_in_Length__c,
                Interested_in_ID_Number__c,
                Buying_horizon__c,
                RecordTypeId,
                Notes__c,
                Geonames_Retry__c,
                pi__score__c,
                (Select CreatedDate, Dealer__c, Pardot_Score__c From Assigned_Dealers__r order by CreatedDate desc)
                FROM Lead 
                where Id = :leadId];
    }
    
    private static Account createDealer() {
		Account dealer = new Account();
		
		system.debug('Dealer Record Type Id = ' + DEALER_RECORD_TYPE);
		
		dealer.RecordTypeId = DEALER_RECORD_TYPE;
		dealer.Name = 'Test Dealer';
		dealer.Dealer_Number__c = '00000.000';
		dealer.ShippingStreet = '800 South Gay Street';
		dealer.ShippingCity = 'Knoxville';
		dealer.ShippingState = 'TN';
		dealer.ShippingPostalCode = '37929';
		dealer.ShippingCountry = 'US';
		dealer.Country_ISO_Code__c = 'US';
		dealer.County__c = 'Knox';
		
		return dealer;
	}
	
	private static Dealer_Brand__c createDealerBrand(Account dealer, string brand) {
		Dealer_Brand__c dealerBrand = new Dealer_Brand__c();
		dealerBrand.Name = 'dealerBrand-' + brand;
		dealerBrand.Status__c = 'Active';
		dealerBrand.Dealer__c = dealer.Id;	
		dealerBrand.Dealer_Primary_Email__c = 'test@test.com';
		dealerBrand.Brand__c = brand;
		
		return dealerBrand;
	}
	
	private static Territory__c createTerritory(Dealer_Brand__c dealerBrand) {
		Territory__c territory = new Territory__c();
		territory.Brand__c = dealerBrand.Brand__c;
		territory.Dealer_Brand__c = dealerBrand.Id;	
		
		return territory;
	}
	
	private static void createZipRoutingRule() {
		Lead_Routing_Rule__c rule = new Lead_Routing_Rule__c();
		rule.Name = 'Zip';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Zip/Postal Code with or without Product Category';
		rule.Number_of_Leads_1__c = '10';
		
		insert rule;
	}
    
    private static Id getIntegrationUserId() {
		User[] users = [select Id from User where Name='Integration User'];
		return users[0].Id;
	}
	
	private static void disableTriggers() {
		AccountServices.disableDealerBrandTriggerProcessing = true;
		LeadServices.disableTriggerProcessing = true;
		OwnerServices.isApexTest = true;
		DealerRouter.doNotSendEmail = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		TerritoryServices.disableTriggerProcessing = true;
		OwnerServices.populateOwnerGeoFieldsIsRunning = true;
	}
	
	
	private static void createLeadRoutingDoNotSend() {
		Lead_Routing_Do_Not_Send__c dns = new Lead_Routing_Do_Not_Send__c(Name='Test', Brand_Code__c='SR', Lead_Form_Name__c=TEST_DNS_FORM_NAME);
	   	insert dns;
	}
	
	private static void createDealerRoutingTestMode() {
		Dealer_Routing_Test_Mode__c tm = new Dealer_Routing_Test_Mode__c(Name='Lead', Test_Mode__c=true, Process_Footsteps__c=true);
		insert tm;
	}
}