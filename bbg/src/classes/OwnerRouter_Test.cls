@isTest
public class OwnerRouter_Test {
	private static Id DEALER_RECORD_TYPE = [Select Id from RecordType where SobjectType='Account' and Name='Dealer' limit 1].Id;
	private static Id OWNER_RECORD_TYPE_ID = [select Id from recordtype where SobjectType='Account' and Name='Owner'].Id;
	static final Decimal TEST_LONGITUDE_FOR_DEALER_1 = -121.894;
    static final Decimal TEST_LATITUDE_FOR_DEALER_1 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_2 = -121.893;
    static final Decimal TEST_LATITUDE_FOR_DEALER_2 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_3 = -121.892;
    static final Decimal TEST_LATITUDE_FOR_DEALER_3 = 37.4352;
    static final Decimal TEST_LONGITUDE_FOR_DEALER_4 = -121.891;
    static final Decimal TEST_LATITUDE_FOR_DEALER_4 = 37.4352;
    static final string TEST_DNS_FORM_NAME = 'TestForm';
    
    static testmethod void testRouteBaylinerLead() {
    	disableTriggers();
		createConfiguration();
    	createLeadRoutingDoNotSend();
    	createDealerRoutingTestMode();
    	
    	Account owner = createOwner();
    	owner.Longitude__c = TEST_LONGITUDE_FOR_DEALER_1;
    	owner.Latitude__c = TEST_LATITUDE_FOR_DEALER_1;
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
        owner.Lead_Form_Name__pc = TEST_DNS_FORM_NAME;
        owner.Brand_Relationships__c = 'BL';
        owner.Brand__c = 'BL';
		insert owner;
		
		Account dealer1 = createDealer();
		dealer1.Longitude__c = TEST_LONGITUDE_FOR_DEALER_1;
    	dealer1.Latitude__c = TEST_LATITUDE_FOR_DEALER_1;
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'BL');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Zipcode_Postal_Code__c = dealer1.ShippingPostalCode;
		insert d1b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerServices.legacyOwnerRouting = true;
		test.startTest();
		OwnerServices.routeOwners(owners);
		test.stopTest();
    		
    	owner = loadOwnerRouting(owner.Id);		
		
		system.assertEquals(dealer1.Id, owner.Assigned_Dealer_1__c);
    }
    
    static testmethod void testEmailsNotSendWithFormMatchingDNSList() {
    	disableTriggers();
		createConfiguration();
    	createLeadRoutingDoNotSend();
    	createZipRoutingRule();
    	
    	Account owner = createOwner();
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
        owner.Lead_Form_Name__pc = TEST_DNS_FORM_NAME;
		insert owner;
		
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Zipcode_Postal_Code__c = dealer1.ShippingPostalCode;
		insert d1b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		owner = loadOwnerRouting(owner.Id);		
		
		// Make sure the email flag is false
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.assert(assignedDealers.size() == 1);
		system.assert(assignedDealers[0].Is_Sendable__c == false);
    }
    
    static testmethod void testRouteByZip_DoesNotRouteWithoutStateOrZip() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		createConfiguration();
		
		disableTriggers();
		
		createZipRoutingRule();
		
		Account owner = createOwner();
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
        owner.PersonMailingPostalCode = '';
        owner.PersonMailingState = '';
		insert owner;
		
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.County__c = dealer1.County__c;
		d1b1t1.Zipcode_Postal_Code__c = dealer1.ShippingPostalCode;
		insert d1b1t1;
				
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.ShippingStreet = '8913 Town and Country Circle';
		dealer2.ShippingPostalCode = '37922';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.Zipcode_Postal_Code__c = dealer2.ShippingPostalCode;
		d2b1t1.County__c = dealer2.County__c;
		insert d2b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching zip code
		owner = loadOwnerRouting(owner.Id);		
		system.assertEquals(null, owner.Assigned_Dealer_1__c);
		
		// Make sure the assigned dealer relationship was not created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.assertEquals(0, assignedDealers.size());
	}
	
	static testmethod void testRouteByZip_RoutesWithCountryStateAndCountyNoZip() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		createConfiguration();
		
		disableTriggers();
		
		createZipRoutingRule();
		
		Account owner = createOwner();
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
        owner.PersonMailingPostalCode = '';
		insert owner;
		
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.County__c = dealer1.County__c;
		d1b1t1.Zipcode_Postal_Code__c = 'All';
		d1b1t1.State_Province__c = dealer1.ShippingState;
		insert d1b1t1;
				
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.ShippingStreet = '8913 Town and Country Circle';
		dealer2.ShippingPostalCode = '37922';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.County__c = dealer2.County__c;
		d2b1t1.Zipcode_Postal_Code__c = 'All';
		d2b1t1.State_Province__c = dealer2.ShippingState;
		insert d2b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching zip code
		owner = loadOwnerRouting(owner.Id);		
		system.assertEquals(dealer1.Id, owner.Assigned_Dealer_1__c);
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.assertEquals(2, assignedDealers.size());
		system.assertEquals(dealer1.Id, assignedDealers[0].Dealer__c);
	}
    
	static testmethod void testRouteByZip() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		createConfiguration();
		
		disableTriggers();
		
		createZipRoutingRule();
		
		Account owner = createOwner();
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Zipcode_Postal_Code__c = dealer1.ShippingPostalCode;
		insert d1b1t1;
				
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.ShippingStreet = '8913 Town and Country Circle';
		dealer2.ShippingPostalCode = '37922-1234';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d1b1t1.Zipcode_Postal_Code__c = dealer2.ShippingPostalCode;
		insert d2b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching zip code
		owner = loadOwnerRouting(owner.Id);		
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assertEquals(dealer1.Dealer_Number__c, owner.Assigned_Dealer_1__r.Dealer_Number__c);
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assertEquals(1, assignedDealers.size());
		system.assertEquals(dealer1.Id, assignedDealers[0].Dealer__c);
	}
	
	static testmethod void testRouteByZipAndProductCategory() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createZipCategoryRoutingRule();
		
		Account owner = createOwner();
		owner.Boat_Category_of_Interest__pc = 'Category1';
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same zip and category that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Zipcode_Postal_Code__c = dealer1.ShippingPostalCode;
		d1b1t1.Boat_Class__c = 'Category1';
		d1b1t1.County__c = dealer1.County__c;
		insert d1b1t1;
			
		// Second dealer has the same zip but different category	
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.Boat_Class__c = 'Category2';
		d2b1t1.County__c = dealer2.County__c;
		insert d2b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching zip code and category
		owner = loadOwnerRouting(owner.Id);		
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assert(owner.Assigned_Dealer_1__r.Dealer_Number__c == dealer1.Dealer_Number__c);
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assert(assignedDealers.size() == 1);
		system.assert(assignedDealers[0].Dealer__c == dealer1.Id);
	}
	
	static testmethod void testRouteByZipAndProductCategory_DoesNotRouteWithoutProductCategory() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createZipCategoryRoutingRule();
		
		Account owner = createOwner();
		owner.Boat_Category_of_Interest__pc = '';
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same zip and category that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Zipcode_Postal_Code__c = dealer1.ShippingPostalCode;
		d1b1t1.Boat_Class__c = 'Category1';
		d1b1t1.County__c = dealer1.County__c;
		insert d1b1t1;
			
		// Second dealer has the same zip but different category	
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.Boat_Class__c = 'Category2';
		d2b1t1.County__c = dealer2.County__c;
		insert d2b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching zip code and category
		owner = loadOwnerRouting(owner.Id);		
		system.assertEquals(null, owner.Assigned_Dealer_1__c);
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.assertEquals(0, assignedDealers.size());
	}
	
	static testmethod void testRouteByZipAndProductCategory_DoesNotRouteWithoutZip() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createZipCategoryRoutingRule();
		
		Account owner = createOwner();
		owner.PersonMailingPostalCode = '';
		owner.Boat_Category_of_Interest__pc = 'Category1';
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same zip and category that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Zipcode_Postal_Code__c = dealer1.ShippingPostalCode;
		d1b1t1.Boat_Class__c = 'Category1';
		d1b1t1.County__c = dealer1.County__c;
		insert d1b1t1;
			
		// Second dealer has the same zip but different category	
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.Boat_Class__c = 'Category2';
		d2b1t1.County__c = dealer2.County__c;
		insert d2b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching zip code and category
		owner = loadOwnerRouting(owner.Id);		
		system.assertEquals(null, owner.Assigned_Dealer_1__c);
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.assertEquals(0, assignedDealers.size());
	}
	
	
	static testmethod void testRouteByLatLon() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createLatLonRoutingRule();
		
		Account owner = createOwner();
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the closest lat lon we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Zipcode_Postal_Code__c = dealer1.ShippingPostalCode;
		d1b1t1.Boat_Class__c = 'Category1';
		insert d1b1t1;
			
		// Second dealer has different lat lon that should match next	
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		insert d2b1t1;
		
		// Third dealer has different lat lon that should match third	
		Account dealer3 = createDealer();
		dealer3.Name = 'Test Dealer 3';
		dealer3.Dealer_Number__c = '00002.000';
		dealer3.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_3;
        dealer3.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_3;
		insert dealer3;
		
		Dealer_Brand__c d3b1 = createDealerBrand(dealer3, 'SR');
		insert d3b1;
		
		Territory__c d3b1t1 = createTerritory(d3b1);
		insert d3b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the closest lat lon
		owner = loadOwnerRouting(owner.Id);		
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.assert(owner.Assigned_Dealer_2__c != null);
		system.assert(owner.Assigned_Dealer_3__c != null);
		system.assert(owner.Assigned_Dealer_1__r.Dealer_Number__c == dealer1.Dealer_Number__c);
		system.assert(owner.Assigned_Dealer_2__r.Dealer_Number__c == dealer2.Dealer_Number__c);
		system.assert(owner.Assigned_Dealer_3__r.Dealer_Number__c == dealer3.Dealer_Number__c);
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assert(assignedDealers.size() == 3);
		system.assert(assignedDealers[0].Dealer__c == dealer1.Id);
		system.assert(assignedDealers[1].Dealer__c == dealer2.Id);
		system.assert(assignedDealers[2].Dealer__c == dealer3.Id);
	}
	
	
	static testmethod void testRouteByStateAndProductCategory() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createStateAndCategoryRoutingRule();
		
		Account owner = createOwner();
		owner.Boat_Category_of_Interest__pc = 'Category1';
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same state and category that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.State_Province__c = owner.PersonMailingState;
		d1b1t1.Boat_Class__c = 'Category1';
		insert d1b1t1;
			
		// Second dealer has the same state but different category	
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.Boat_Class__c = 'Category2'; // Different category
		d2b1t1.State_Province__c = owner.PersonMailingState;
		insert d2b1t1;
		
		
		// Third dealer has a different state but same category	
		Account dealer3 = createDealer();
		dealer3.Name = 'Test Dealer 3';
		dealer3.Dealer_Number__c = '00002.000';
		dealer3.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_3;
        dealer3.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_3;
		insert dealer3;
		
		Dealer_Brand__c d3b1 = createDealerBrand(dealer3, 'SR');
		insert d3b1;
		
		Territory__c d3b1t1 = createTerritory(d3b1);
		d3b1t1.Boat_Class__c = 'Category1';
		d3b1t1.State_Province__c = 'GA'; // different state
		insert d3b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching state and category
		owner = loadOwnerRouting(owner.Id);		
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.assert(owner.Assigned_Dealer_2__c == null);
		system.assert(owner.Assigned_Dealer_3__c == null);
		system.assert(owner.Assigned_Dealer_1__r.Dealer_Number__c == dealer1.Dealer_Number__c);
		
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assert(assignedDealers.size() == 1);
		system.assert(assignedDealers[0].Dealer__c == dealer1.Id);
	}
	
	static testmethod void testRouteByCountryAndProductCategory() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createCountryAndCategoryRoutingRule();
		
		Account owner = createOwner();
		owner.Boat_Category_of_Interest__pc = 'Category1';
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same country and category that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Boat_Class__c = 'Category1';
		insert d1b1t1;
			
		// Second dealer has the same country but different category	
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.Boat_Class__c = 'Category2'; // Different category
		insert d2b1t1;
		
		
		// Third dealer has a different country but same category	
		Account dealer3 = createDealer();
		dealer3.Name = 'Test Dealer 3';
		dealer3.Dealer_Number__c = '00002.000';
		dealer3.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_3;
        dealer3.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_3;
        dealer3.Country_ISO_Code__c = 'CA'; // Different country
		insert dealer3;
		
		Dealer_Brand__c d3b1 = createDealerBrand(dealer3, 'SR');
		insert d3b1;
		
		Territory__c d3b1t1 = createTerritory(d3b1);
		d3b1t1.Boat_Class__c = 'Category1';
		insert d3b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching country and category
		owner = loadOwnerRouting(owner.Id);		
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.assert(owner.Assigned_Dealer_2__c == null);
		system.assert(owner.Assigned_Dealer_3__c == null);
		system.assert(owner.Assigned_Dealer_1__r.Dealer_Number__c == dealer1.Dealer_Number__c);
		
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assert(assignedDealers.size() == 1);
		system.assert(assignedDealers[0].Dealer__c == dealer1.Id);
	}
	
	
	static testmethod void testRouteByCountry() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createCountryRoutingRule();
		
		Account owner = createOwner();
		owner.Boat_Category_of_Interest__pc = 'Category1';
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same country and category that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Boat_Class__c = 'Category1';
		insert d1b1t1;
			
		// Second dealer has the same country but not category, should match second
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.Boat_Class__c = 'Category2'; // Different category
		insert d2b1t1;
		
		
		// Third dealer has a different country but same category and should not match	
		Account dealer3 = createDealer();
		dealer3.Name = 'Test Dealer 3';
		dealer3.Dealer_Number__c = '00002.000';
		dealer3.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_3;
        dealer3.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_3;
        dealer3.Country_ISO_Code__c = 'CA'; // Different country
		insert dealer3;
		
		Dealer_Brand__c d3b1 = createDealerBrand(dealer3, 'SR');
		insert d3b1;
		
		Territory__c d3b1t1 = createTerritory(d3b1);
		d3b1t1.Boat_Class__c = 'Category1';
		insert d3b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching country and category
		owner = loadOwnerRouting(owner.Id);		
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.assert(owner.Assigned_Dealer_2__c != null);
		system.assert(owner.Assigned_Dealer_3__c == null);
		system.assert(owner.Assigned_Dealer_1__r.Dealer_Number__c == dealer1.Dealer_Number__c);
		system.assert(owner.Assigned_Dealer_2__r.Dealer_Number__c == dealer2.Dealer_Number__c);
		
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assert(assignedDealers.size() == 2);
		system.assert(assignedDealers[0].Dealer__c == dealer1.Id);
		system.assert(assignedDealers[1].Dealer__c == dealer2.Id);
	}
	
	static testmethod void testRouteByRegionalOffice() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createRegionalOfficeRoutingRule();
		
		Account owner = createOwner();
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same country and category that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
        dealer1.Dealer_Type__c = 'Regional Office';
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Regional_Office_Country__c = owner.Home_Address_ISO_Code__c;
		insert d1b1t1;
			
		// Second dealer has the same country and should match second
		Account dealer2 = createDealer();
		dealer2.Dealer_Type__c = 'Regional Office';
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.Regional_Office_Country__c = owner.Home_Address_ISO_Code__c;
		insert d2b1t1;
		
		
		// Third dealer has a different country and should not match
		Account dealer3 = createDealer();
		dealer3.Dealer_Type__c = 'Regional Office';
		dealer3.Name = 'Test Dealer 3';
		dealer3.Dealer_Number__c = '00002.000';
		dealer3.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_3;
        dealer3.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_3;
        dealer3.Country_ISO_Code__c = 'CA'; // Different country
		insert dealer3;
		
		Dealer_Brand__c d3b1 = createDealerBrand(dealer3, 'SR');
		insert d3b1;
		
		Territory__c d3b1t1 = createTerritory(d3b1);
		d3b1t1.Regional_Office_Country__c = 'CA';
		insert d3b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching country and category
		owner = loadOwnerRouting(owner.Id);		
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.assert(owner.Assigned_Dealer_2__c != null);
		system.assert(owner.Assigned_Dealer_3__c == null);
		system.assert(owner.Assigned_Dealer_1__r.Dealer_Number__c == dealer1.Dealer_Number__c);
		system.assert(owner.Assigned_Dealer_2__r.Dealer_Number__c == dealer2.Dealer_Number__c);
		
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assert(assignedDealers.size() == 2);
		system.assert(assignedDealers[0].Dealer__c == dealer1.Id);
		system.assert(assignedDealers[1].Dealer__c == dealer2.Id);
	}
	
	static testmethod void testRouteByCountyCountryAndProductCategory() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		
		createCountyCountryAndCategoryRoutingRule();
		
		Account owner = createOwner();
		owner.Boat_Category_of_Interest__pc = 'Category1';
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same country and category and county that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.Boat_Class__c = 'Category1';
		d1b1t1.County__c = owner.County__c;
		d1b1t1.State_Province__c = owner.PersonMailingState;
		insert d1b1t1;
			
		// Second dealer has the same country and county but different category	
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d1b1t1.County__c = owner.County__c;
		d2b1t1.Boat_Class__c = 'Category2'; // Different category
		d2b1t1.State_Province__c = owner.PersonMailingState;
		insert d2b1t1;
		
		
		// Third dealer has a different country but same category and county	
		Account dealer3 = createDealer();
		dealer3.Name = 'Test Dealer 3';
		dealer3.Dealer_Number__c = '00002.000';
		dealer3.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_3;
        dealer3.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_3;
        dealer3.Country_ISO_Code__c = 'CA'; // Different country
		insert dealer3;
		
		Dealer_Brand__c d3b1 = createDealerBrand(dealer3, 'SR');
		insert d3b1;
		
		Territory__c d3b1t1 = createTerritory(d3b1);
		d3b1t1.Boat_Class__c = 'Category1';
		d3b1t1.County__c = owner.County__c;
		d3b1t1.State_Province__c = owner.PersonMailingState;
		insert d3b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching country and category
		owner = loadOwnerRouting(owner.Id);		
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.assert(owner.Assigned_Dealer_2__c == null);
		system.assert(owner.Assigned_Dealer_3__c == null);
		system.assert(owner.Assigned_Dealer_1__r.Dealer_Number__c == dealer1.Dealer_Number__c);
		
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assert(assignedDealers.size() == 1);
		system.assert(assignedDealers[0].Dealer__c == dealer1.Id);
	}
	
	static testmethod void testRouteByCountyCountry() {
		// This will disable the AccountTrigger. Since we are setting the lat and long we don't need
		// the geocoding to be done. Also we are directly calling the routing so we don't want that to
		// be performed
		disableTriggers();
		createConfiguration();
		createExcludedDealerTypes();
		
		createCountyCountryRoutingRule();
		
		Account owner = createOwner();
		owner.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        owner.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert owner;
		
		// First dealer has the same country and county that we want to match on
		Account dealer1 = createDealer();
		dealer1.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer1.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer1;
		Dealer_Brand__c d1b1 = createDealerBrand(dealer1, 'SR');
		insert d1b1;
		Territory__c d1b1t1 = createTerritory(d1b1);
		d1b1t1.County__c = owner.County__c;
		d1b1t1.State_Province__c = owner.PersonMailingState;
		insert d1b1t1;
			
		// Second dealer has the same country but different county and should not match
		Account dealer2 = createDealer();
		dealer2.Name = 'Test Dealer 2';
		dealer2.Dealer_Number__c = '00001.000';
		dealer2.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_2;
        dealer2.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_2;
		insert dealer2;
		
		Dealer_Brand__c d2b1 = createDealerBrand(dealer2, 'SR');
		insert d2b1;
		
		Territory__c d2b1t1 = createTerritory(d2b1);
		d2b1t1.County__c = 'Hazard'; // Different county
		d2b1t1.State_Province__c = owner.PersonMailingState;
		insert d2b1t1;
		
		// Third dealer has a different country but same county	
		Account dealer3 = createDealer();
		dealer3.Name = 'Test Dealer 3';
		dealer3.Dealer_Number__c = '00002.000';
		dealer3.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_3;
        dealer3.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_3;
        dealer3.Country_ISO_Code__c = 'CA'; // Different country
		insert dealer3;
		
		Dealer_Brand__c d3b1 = createDealerBrand(dealer3, 'SR');
		insert d3b1;
		
		Territory__c d3b1t1 = createTerritory(d3b1);
		d3b1t1.County__c = owner.County__c;
		d3b1t1.State_Province__c = owner.PersonMailingState;
		insert d3b1t1;
		
		// Fourth dealer has same country and county but is an excluded type
		Account dealer4 = createDealer();
		dealer4.Name = 'Test Dealer 4';
		dealer4.Dealer_Number__c = '00003.000';
		dealer4.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_4;
        dealer4.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_4;
        dealer4.Country_ISO_Code__c = 'US';
        dealer4.Dealer_Type__c = 'Regional Office';
		insert dealer4;
		
		Dealer_Brand__c d4b1 = createDealerBrand(dealer4, 'SR');
		insert d4b1;
		
		Territory__c d4b1t1 = createTerritory(d4b1);
		d4b1t1.County__c = owner.County__c;
		d4b1t1.State_Province__c = owner.PersonMailingState;
		insert d4b1t1;
		
		list<Account> owners = new list<Account>();
		owners.add(owner);
		OwnerRouter router = new OwnerRouter();
		test.startTest();
		router.routeToDealers(owners);
		test.stopTest();
		
		// Make sure the owner was routed to the correct dealer with the matching country and category
		owner = loadOwnerRouting(owner.Id);		
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_1__r.Dealer_Number__c=' + owner.Assigned_Dealer_1__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_2__r.Dealer_Number__c=' + owner.Assigned_Dealer_2__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_3__r.Dealer_Number__c=' + owner.Assigned_Dealer_3__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_4__r.Dealer_Number__c=' + owner.Assigned_Dealer_4__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'owner.Assigned_Dealer_5__r.Dealer_Number__c=' + owner.Assigned_Dealer_5__r.Dealer_Number__c);
		system.debug(LoggingLevel.Info, 'dealer1.Id=' + dealer1.Id);
		system.assert(owner.Assigned_Dealer_1__c != null);
		system.assert(owner.Assigned_Dealer_2__c == null);
		system.assert(owner.Assigned_Dealer_3__c == null);
		system.assert(owner.Assigned_Dealer_4__c == null);
		system.assert(owner.Assigned_Dealer_1__r.Dealer_Number__c == dealer1.Dealer_Number__c);
		
		
		// Make sure the assigned dealer relationship was created
		list<Assigned_Dealer__c> assignedDealers = loadOwnerAssignedDealers(owner);
		system.debug(LoggingLevel.Info, 'Assigned Dealers = ' + assignedDealers.size());
		system.assert(assignedDealers.size() == 1);
		system.assert(assignedDealers[0].Dealer__c == dealer1.Id);
	}
	
	private static list<Assigned_Dealer__c> loadOwnerAssignedDealers(Account owner) {
		return [select Id, Dealer__c, Owner__c, Primary_Email__c, Owner_Country_ISO_Code__c, Owner_Form_Name__c, Owner_Product_Category__c, Owner_Record_Type__c, Owner_Subject_Line_Formula__c, Subject_Line__c, Is_Sendable__c from Assigned_Dealer__c where Owner__c=:owner.Id];
	}
	
	private static Account loadOwnerRouting(Id ownerId) {
		list<Account> owners = [select Id, Assigned_Dealer_1__c, Assigned_Dealer_1__r.Dealer_Number__c, Assigned_Dealer_2__c, Assigned_Dealer_2__r.Dealer_Number__c, Assigned_Dealer_3__c, Assigned_Dealer_3__r.Dealer_Number__c, Assigned_Dealer_4__c, Assigned_Dealer_4__r.Dealer_Number__c, Assigned_Dealer_5__c,
								Assigned_Dealer_5__r.Dealer_Number__c, Assigned_Dealer_6__c, Assigned_Dealer_6__r.Dealer_Number__c, Assigned_Dealer_7__c, Assigned_Dealer_8__c, Assigned_Dealer_9__c, Assigned_Dealer_10__c
								from Account where Id=:ownerId];
		if (owners.size() > 0) {
			return owners[0];
		}
		return null;
	}
	
	private static Id getIntegrationUserId() {
		User[] users = [select Id from User where Name='Integration User'];
		return users[0].Id;
	}
	
	private static void disableTriggers() {
		OwnerServices.isApexTest = true;
		DealerRouter.doNotSendEmail = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		TerritoryServices.disableTriggerProcessing = true;
		OwnerServices.populateOwnerGeoFieldsIsRunning = true;
	}
	
	private static void createConfiguration() {
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=getIntegrationUserId());
		insert config;
	}
	
	private static void createExcludedDealerTypes() {
		Dealer_Types_to_Exclude_from_Locator__c exclude = new Dealer_Types_to_Exclude_from_Locator__c(Name='Regional Office',Dealer_Type__c='Regional Office');
		insert exclude;
	}
	
	private static void createLeadRoutingDoNotSend() {
		Lead_Routing_Do_Not_Send__c dns = new Lead_Routing_Do_Not_Send__c(Name='Test', Brand_Code__c='SR', Lead_Form_Name__c=TEST_DNS_FORM_NAME);
	   	insert dns;
	}
	
	private static void createDealerRoutingTestMode() {
		Dealer_Routing_Test_Mode__c tm = new Dealer_Routing_Test_Mode__c(Name='Owner', Test_Mode__c=true, Process_Footsteps__c=true);
		insert tm;
	}
	
	private static Account createOwner() {
		Account owner = new Account();
		
		system.debug('Owner Record Type Id = ' + OWNER_RECORD_TYPE_ID);
		owner.RecordTypeId = OWNER_RECORD_TYPE_ID;
        owner.LastName = 'Last';
        owner.FirstName = 'First';
        owner.County__c = 'Knox';
        owner.PersonMailingStreet  = '800 South Gay Street';
        owner.PersonMailingState = 'TN';
        owner.PersonMailingCity = 'Knoxville';
        owner.PersonMailingCountry = 'US';
        owner.PersonMailingPostalCode = '37929-234';
        owner.OwnerId = Configuration__c.getInstance('BoatOwner').RecordId__c;
        owner.Home_Address_ISO_Code__c = 'US';
        owner.Brand_Relationships__c = 'SR';
        owner.Brand__c = 'SR';
        
        return owner;
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
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'Zip';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Zip/Postal Code with or without Product Category';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;
	}
	
	private static void createZipCategoryRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'ZipCategory';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Zip/Postal Code w/Product Category';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;	
	}
	
	private static void createLatLonRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'LatLon';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Lat/Lon';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;		
	}
	
	private static void createStateAndCategoryRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'StateProduct';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'State & Product Category';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;			
	}
	
	private static void createCountryAndCategoryRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'CountryProduct';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Country w/Product Category';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;			
	}
	
	private static void createCountryRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'Country';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Country with or without Product Category';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;			
	}
	
	private static void createRegionalOfficeRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'RegionalOffice';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Regional Office';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;	
	}	
	
	private static void createCountyCountryAndCategoryRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'CountyCountryCategory';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'County w/Country w/Product Category';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;		
	}
	
	private static void createCountyCountryRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'CountyCountry';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'County w/Country';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;		
	}
	
	private static void createCanadianTerritoriesRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'CanadianTerritories';
		rule.Country_Code__c = 'CA';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Canadian Territories';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;		
	}
}