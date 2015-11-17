/*
*	SimilarListingTriggerHandler is used to perform logic for SimilarListingTrigger.  Performs:
*		1) auto-populating the hidden Upsert_Key__c value
*		2) auto creation and deletion of reverse similar listing records 
*
*	Author: Wilson Ng
*	Date:   November 14, 2012
*
*/
public without sharing class SimilarListingTriggerHandler {

	public static boolean firstTime = true;			// prevent recursive triggers
	
	// =================================================
	// constructor
	public SimilarListingTriggerHandler() { }
	
	// =================================================
	// main entry from triggers
	public void onBeforeInsert(List<Similar_Listing__c> lstNewSimilarListing) {
		for(Similar_Listing__c sl : lstNewSimilarListing)
			sl.Upsert_Key__c = formatUpsertKey(sl);				// auto set the upsert key
	}
	public void onBeforeUpdate(List<Similar_Listing__c> lstNewSimilarListing, Map<Id, Similar_Listing__c> mapOldSimilarListing) {
		for(Similar_Listing__c sl : lstNewSimilarListing) {
			Similar_Listing__c oldsl = mapOldSimilarListing.get(sl.Id);
			if(sl.Similar_Listing__c != oldsl.Similar_Listing__c || sl.Upsert_Key__c == null)	// if property comp changed. then update the upsert key
				sl.Upsert_Key__c = formatUpsertKey(sl);
		}
	}
	public void onAfterInsert(List<Similar_Listing__c> lstNewSimilarListing) {
		if(!firstTime) return;
		firstTime = false;
		createReversedSimilarListings(lstNewSimilarListing);		// creates reverse comps
	}
	public void onAfterUpdate(List<Similar_Listing__c> lstNewSimilarListing, Map<Id, Similar_Listing__c> mapOldSimilarListing) {
		if(!firstTime) return;
		firstTime = false;
		list<Similar_Listing__c> createList = new list<Similar_Listing__c>();
		list<Similar_Listing__c> deleteList = new list<Similar_Listing__c>();
		for(Similar_Listing__c sl : lstNewSimilarListing) {
			Similar_Listing__c oldsl = mapOldSimilarListing.get(sl.Id);
			if(sl.Similar_Listing__c != oldsl.Similar_Listing__c) {		// check for lookup changed, if so, then delete old reverse, and create new one
				createList.add(sl);
				deleteList.add(oldsl);
			} 
		}
		if(deleteList.size() > 0)
			deleteReversedSimilarListings(deleteList);
		if(createList.size() > 0)
			createReversedSimilarListings(createList);
	}
	public void onAfterDelete(List<Similar_Listing__c> lstOldSimilarListing) {
		if(!firstTime) return;
		firstTime = false;
		deleteReversedSimilarListings(lstOldSimilarListing);		// deletes reverse comps
	}
		
	//
	// returns formatted Upsert Key value
	public static string formatUpsertKey(Similar_Listing__c sl) {
		return string.format('{0},{1}', new string[] { sl.Listing__c, (sl.Similar_Listing__c!=null?sl.Similar_Listing__c:'') } );
	}
	
	// returns formated Revered Upsert Key value
	public static string formatReversedUpsertKey(Similar_Listing__c sl) {
		return string.format('{0},{1}', new string[] { sl.Similar_Listing__c, sl.Listing__c } );
	}
	
	//
	// create all related similar listings comp based upon the current listing's property location/neighborhood
	public static void createSimilarListings(list<Listing__c> listings) {
		// map of unique location/neighborhood
		map<Id, set<string>> locationMap = new map<Id, set<string>>();
		for(Listing__c l : [select id, Property__r.Location_Neighborhood__c from Listing__c where id in :listings and listing_status__c != 'Leased']) {
			id locId = l.Property__r.Location_Neighborhood__c;
			if(!locationMap.containsKey(locId))
				locationMap.put(locId, new set<string>());
			locationMap.get(locId).add(l.Id);
		}
			
		// query all other listings with same property location/neighborhood
		set<Similar_Listing__c> slSet = new set<Similar_Listing__c>();
		for(Listing__c existingListing : [select id, Property__r.Location_Neighborhood__c from Listing__c where Property__r.Location_Neighborhood__c in :locationMap.keySet() and listing_status__c != 'Leased'])
			for(string newListingId : locationMap.get(existingListing.Property__r.Location_Neighborhood__c))
				if(newListingId != existingListing.Id) {
					// create both similar listing and reverse similar listing
					Similar_Listing__c sl1 = new Similar_Listing__c(Listing__c=newListingId, Similar_Listing__c=existingListing.Id);
					sl1.Upsert_Key__c = SimilarListingTriggerHandler.formatUpsertKey(sl1);
					slSet.add(sl1);				// add comp
					Similar_Listing__c sl2 = new Similar_Listing__c(Listing__c=existingListing.Id, Similar_Listing__c=newListingId);
					sl2.Upsert_Key__c = SimilarListingTriggerHandler.formatUpsertKey(sl2);
					slSet.add(sl2);				// add reverse record						
				}

		// insert similar listings
		if(slSet.size() > 0) {
			SimilarListingTriggerHandler.firstTime = false;		// reverse record handled above...skip similarlisting trigger
			upsert (new list<Similar_Listing__c>(slSet)) Similar_Listing__c.Upsert_Key__c;
		}
	}
	
	//
	// delete all related similar listings
	public static void deleteSimilarListings(list<Listing__c> listings) {
		list<Similar_Listing__c> delList = [select id from Similar_Listing__c where Similar_Listing__c in :listings];
		delete delList;
	}
	
	
	//
	// creates reversed similar listings
	private void createReversedSimilarListings(list<Similar_Listing__c> similarListings) {
		set<Similar_Listing__c> upsSet = new set<Similar_Listing__c>();
		for(Similar_Listing__c sl : similarListings)
			if(sl.Similar_Listing__c != null)
				upsSet.add(new Similar_Listing__c(Listing__c=sl.Similar_Listing__c, Similar_Listing__c=sl.Listing__c, Upsert_Key__c=formatReversedUpsertKey(sl)));
		if(upsSet.size() > 0)
			upsert (new list<Similar_Listing__c>(upsSet)) Similar_Listing__c.Upsert_Key__c;
	}
	
	//
	// deletes reverse similar listings
	private void deleteReversedSimilarListings(list<Similar_Listing__c> similarListings) {
		set<string> upsertkeys = new set<string>();
		for(Similar_Listing__c sl : similarListings)
			upsertkeys.add(formatReversedUpsertKey(sl));
		if(upsertkeys.size() > 0) {
			list<Similar_Listing__c> delList = [select id from Similar_Listing__c where Upsert_Key__c in :upsertkeys];
			delete delList;
		}
	}
	
	
	//
	// test methods
	@isTest
	static void Test_SimilarListingTrigger() {
		// create test data
		list<Location_Neighborhood__c> locList = new list<Location_Neighborhood__c>();
		locList.add(new Location_Neighborhood__c(Name='TestLocation1'));
		locList.add(new Location_Neighborhood__c(Name='TestLocation2'));
		locList.add(new Location_Neighborhood__c(Name='TestLocation3'));
		insert locList;
		
		list<Property__c> propList = new list<Property__c>();
		propList.add(new Property__c(Name='Prop1', Location_Neighborhood__c=locList[0].Id));
		propList.add(new Property__c(Name='Prop2', Location_Neighborhood__c=locList[0].Id));
		propList.add(new Property__c(Name='Prop3', Location_Neighborhood__c=locList[1].Id));
		propList.add(new Property__c(Name='Prop4', Location_Neighborhood__c=locList[2].Id));
		insert propList;
		
		Test.startTest();
		
		list<Listing__c> listList = new list<Listing__c>();
		listList.add(new Listing__c(Name='Prop1', Property__c=propList[0].Id));
		listList.add(new Listing__c(Name='Prop2', Property__c=propList[1].Id));
		listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
		listList.add(new Listing__c(Name='Prop4', Property__c=propList[3].Id));
		insert listList;
		list<Similar_Listing__c> testSLList = [select id, Upsert_Key__c from Similar_Listing__c];
		system.assertEquals(2, testSLList.size(), 'Error: Similar Listing <insert> trigger did not generate correct number of similar listing.');
		system.assertNotEquals(null, testSLList[0].Upsert_Key__c, 'Error: Similar Listing <insert> trigger did not populate upsert key value.');
	
		// test inserts	
		firstTime = true;//needs to reset the recursive trigger indicator for next dml in test method
		list<Similar_Listing__c> slList = new list<Similar_Listing__c>();
		slList.add(new Similar_Listing__c(Listing__c=listList[2].Id, Similar_Listing__c=listList[0].Id));
		slList.add(new Similar_Listing__c(Listing__c=listList[2].Id, Similar_Listing__c=listList[1].Id));
		insert slList;
		testSLList = [select id from Similar_Listing__c];
		system.assertEquals(6, testSLList.size(), 'Error: Similar Listing <insert> trigger did not generate correct number of similar listing.');

		// test updates
		firstTime = true;//needs to reset the recursive trigger indicator for next dml in test method
		slList[0].Similar_Listing__c=listList[3].Id;
		update slList[0];
		testSLList = [select id from Similar_Listing__c where Listing__c=:listList[3].Id];
		system.assertEquals(1, testSLList.size(), 'Error: Similar Listing <update> trigger did not generate correct number of similar listing.');
		
		// test deletes
		firstTime = true;//needs to reset the recursive trigger indicator for next dml in test method
		delete slList[1];
		testSLList = [select id from Similar_Listing__c];
		system.assertEquals(4, testSLList.size(), 'Error: Similar Listing <delete> trigger did not delete correct number of similar listing.');
		
		Test.stopTest();
	}
}