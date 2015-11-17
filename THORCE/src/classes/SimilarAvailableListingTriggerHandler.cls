/*
*	SimilarAvailableListingTriggerHandler is used to perform logic for SimilarAvailableListingTrigger.  Performs:
*		1) auto-populating the hidden Upsert_Key__c value
*
*	Author: Wilson Ng
*	Date:   November 14, 2012
*
*/
public without sharing class SimilarAvailableListingTriggerHandler {

	public static string[] listingCompsStatusFilter = new string[] { 'Occupied', 'Leased' };
	public static string[] dealCompsStageFilter = new string[] { 'Closed Won', 'Lost/Declined' };
	public static string[] dealCompsRecordTypeFilter = new string[] { 'Leasing_Deal' };

	// =================================================
	// constructor
	public SimilarAvailableListingTriggerHandler() { }
	
	// =================================================
	// main entry from triggers
	public void onBeforeInsert(List<Similar_Available_Listing__c> lstNewSimilarAvailableListing) {
		for(Similar_Available_Listing__c sal : lstNewSimilarAvailableListing)
			sal.Upsert_Key__c = formatUpsertKey(sal);				// auto set the upsert key
	}
	
		
	//
	// returns formated Upsert Key value
	public static string formatUpsertKey(Similar_Available_Listing__c sal) {
		return string.format('{0},{1}', new string[] { sal.Deal__c, sal.Similar_Listing__c } );
	}
	
	
	//
	// query listing and create similar available listing for non-occupied/leased listings only
	public static void createSimilarAvailableListings(list<Deal_Property__c> dealProperties) {
		
		// query deal record type and property location, filter for Leasing Deals only
		map<string, set<string>> locationMap = new map<string, set<string>>();
		for(Deal_Property__c dp : [select Id, Deal__c, Deal__r.RecordType.Name, Property__c, Property__r.Location_Neighborhood__c from Deal_Property__c where Id in :dealProperties and Deal__r.RecordType.DeveloperName in :dealCompsRecordTypeFilter]) {
			// add to location map
			if(!locationMap.containsKey(dp.Property__r.Location_Neighborhood__c))
				locationMap.put(dp.Property__r.Location_Neighborhood__c, new set<string>());
			locationMap.get(dp.Property__r.Location_Neighborhood__c).add(dp.Deal__c);
		}
		
		if(locationMap.size() > 0) {
			set<Similar_Available_Listing__c> insSet = new set<Similar_Available_Listing__c>();
			// query listings with filter equals location/neighborhood and status not equals Occupied or Leased
			for(Listing__c l : [select Id, Name, Property__r.Location_Neighborhood__c from Listing__c where Property__r.Location_Neighborhood__c in :locationMap.keySet() and Listing_Status__c not in :listingCompsStatusFilter ])
				for(string dealId : locationMap.get(l.Property__r.Location_Neighborhood__c)) {
					// create similar available listing
					Similar_Available_Listing__c sal = new Similar_Available_Listing__c(Deal__c=dealId, Similar_Listing__c=l.Id);
					sal.Upsert_Key__c = SimilarAvailableListingTriggerHandler.formatUpsertKey(sal);
					insSet.add(sal);	
				}
	
			if(insSet.size() > 0) {
				upsert (new list<Similar_Available_Listing__c>(insSet)) Similar_Available_Listing__c.Upsert_Key__c; 
			}
		}
	}
	
	//
	// query deal properties and create similar available listing for Leasing Deals only
	public static void createSimilarAvailableListings(list<Listing__c> listings) {
		
		// query listing's property location, filter for non occupied/leased listings
		map<string, set<string>> locationMap = new map<string, set<string>>();
		for(Listing__c l : [select Id, Property__c, Property__r.Location_Neighborhood__c from Listing__c where Id in :listings and Listing_Status__c not in :listingCompsStatusFilter] ) {
			// add to location map
			if(!locationMap.containsKey(l.Property__r.Location_Neighborhood__c))
				locationMap.put(l.Property__r.Location_Neighborhood__c, new set<string>());
			locationMap.get(l.Property__r.Location_Neighborhood__c).add(l.Id);
		}
		
		if(locationMap.size() > 0) {
			set<Similar_Available_Listing__c> insSet = new set<Similar_Available_Listing__c>();
			// query property deals with filter equals location/neighborhood and leasing deals with stage value not equals closed won or lost/declined
			for(Deal_Property__c dp : [select Id, Name, Deal__c, Property__c, Property__r.Location_Neighborhood__c from Deal_Property__c where Property__r.Location_Neighborhood__c in :locationMap.keySet() and Deal__r.RecordType.DeveloperName in :dealCompsRecordTypeFilter and Deal__r.Deal_Stage__c not in :dealCompsStageFilter ])
				for(string listingId : locationMap.get(dp.Property__r.Location_Neighborhood__c)) {
					// create similar available listing
					Similar_Available_Listing__c sal = new Similar_Available_Listing__c(Deal__c=dp.Deal__c, Similar_Listing__c=listingId);
					sal.Upsert_Key__c = SimilarAvailableListingTriggerHandler.formatUpsertKey(sal);
					insSet.add(sal);	
				}
	
			if(insSet.size() > 0) {
				upsert (new list<Similar_Available_Listing__c>(insSet)) Similar_Available_Listing__c.Upsert_Key__c; 
			}
		}
	}
	
	
	//
	// test methods
	@isTest
	static void Test_SimilarAvailableListingTrigger() {
		// create test data
		list<Location_Neighborhood__c> locList = new list<Location_Neighborhood__c>();
		locList.add(new Location_Neighborhood__c(Name='TestLocation1'));
		insert locList;
		
		list<Property__c> propList = new list<Property__c>();
		propList.add(new Property__c(Name='Prop1', Location_Neighborhood__c=locList[0].Id, Thor_Ownership__c='Thor Owned'));
		propList.add(new Property__c(Name='Prop2', Location_Neighborhood__c=locList[0].Id, Thor_Ownership__c='Thor Owned'));
		propList.add(new Property__c(Name='Prop3', Location_Neighborhood__c=locList[0].Id, Thor_Ownership__c='Non-Thor Owned'));
		insert propList;
		
		list<Listing__c> listList = new list<Listing__c>();
		listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));		// property named filter must equals non-thor owned
		listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
		listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
		insert listList;
		
		list<Deal__c> dealList = new list<Deal__c>();
		dealList.add(new Deal__c(Name='Deal1', RecordType=new RecordType(Name='Leasing Deal')));
		dealList.add(new Deal__c(Name='Deal2', RecordType=new RecordType(Name='Leasing Deal')));
		dealList.add(new Deal__c(Name='Deal3', RecordType=new RecordType(Name='Leasing Deal')));
		insert dealList;
	
		Test.startTest();
		
		// test inserts
		list<Similar_Available_Listing__c> salList = new list<Similar_Available_Listing__c>();
		salList.add(new Similar_Available_Listing__c(Deal__c=dealList[0].Id, Similar_Listing__c=listList[0].Id));	// deal named filter must equals leasing deal; listing named filter must not equals occupied or leased
		salList.add(new Similar_Available_Listing__c(Deal__c=dealList[1].Id, Similar_Listing__c=listList[1].Id));
		salList.add(new Similar_Available_Listing__c(Deal__c=dealList[2].Id, Similar_Listing__c=listList[2].Id));
		insert salList;
		list<Similar_Available_Listing__c> testSALList = [select id, Upsert_Key__c from Similar_Available_Listing__c];
		system.assertEquals(3, testSALList.size(), 'Error: Similar Available Listing <insert> trigger did not insert records.');
		system.assertNotEquals(null, testSALList[0].Upsert_Key__c, 'Error: Similar Available Listing <insert> trigger did not populate the upsert key value.');
		
		Test.stopTest();
	}
	
}