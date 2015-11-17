/*
*	LeasingCompTriggerHandler is used to perform logic for LeasingCompTrigger.  Performs:
*		1) auto-populating the hidden Upsert_Key__c value
*
*	Author: Wilson Ng
*	Date:   November 14, 2012
*
*/
public without sharing class LeasingCompTriggerHandler {

	// =================================================
	// constructor
	public LeasingCompTriggerHandler() { }
	
	// =================================================
	// main entry from triggers
	public void onBeforeInsert(List<Leasing_Comp__c> lstNewLeasingComp) {
		for(Leasing_Comp__c lc : lstNewLeasingComp)
			lc.Upsert_Key__c = formatUpsertKey(lc);				// auto set the upsert key
	}
	
	//
	// returns formated Upsert Key value
	public static string formatUpsertKey(Leasing_Comp__c lc) {
		return string.format('{0},{1}', new string[] { lc.Lease__c, lc.Deal__c } );
	}
	
	
	//
	// query deals and create leasing comps for active leases
	public static void createLeaseComps(list<Property_Lease__c> leases) {
		
		// retrieve all unique location/neighborhoods
		map<string, set<string>> locationMap = new map<string, set<string>>();
		for(Property_Lease__c pl : [select Id, Lease__c, Property__c, Property__r.Location_Neighborhood__c from Property_Lease__c where Id in :leases and ( Lease__r.Lease_Expiration_Date__c=null or Lease__r.Lease_Expiration_Date__c<:system.today() ) ]) {
			// add to location map
			if(!locationMap.containsKey(pl.Property__r.Location_Neighborhood__c))
				locationMap.put(pl.Property__r.Location_Neighborhood__c, new set<string>());
			locationMap.get(pl.Property__r.Location_Neighborhood__c).add(pl.Lease__c);
		}

		if(locationMap.size() > 0) {
			set<Leasing_Comp__c> insSet = new set<Leasing_Comp__c>();
			// query deal properties with filter equals location/neighborhood and deal recordtype equals leasing deal and deal stage not equals Closed Won or Lost/Declined
			for(Deal_Property__c dp : [select Id, Name, Deal__c, Property__c, Property__r.Location_Neighborhood__c from Deal_Property__c where Property__r.Location_Neighborhood__c in :locationMap.keySet() and Deal__r.RecordType.DeveloperName in :SimilarAvailableListingTriggerHandler.dealCompsRecordTypeFilter and Deal__r.Deal_Stage__c not in :SimilarAvailableListingTriggerHandler.dealCompsStageFilter ])
				for(string leaseId : locationMap.get(dp.Property__r.Location_Neighborhood__c)) {
					// create leasing comp
					Leasing_Comp__c lc = new Leasing_Comp__c(Lease__c=leaseId, Deal__c=dp.Deal__c);
					lc.Upsert_Key__c = LeasingCompTriggerHandler.formatUpsertKey(lc);
					insSet.add(lc);	
				}
	
			if(insSet.size() > 0) {
				upsert (new list<Leasing_Comp__c>(insSet)) Leasing_Comp__c.Upsert_Key__c; 
			}
		}
	}
	
	// query leases and create leasing comps for non-closed/lost deals
	public static void createLeaseComps(list<Deal_Property__c> deals) {
		
		// retrieve all unique location/neighborhoods
		map<string, set<string>> locationMap = new map<string, set<string>>();
		for(Deal_Property__c dp : [select Id, Deal__c, Property__c, Property__r.Location_Neighborhood__c from Deal_Property__c where Id in :deals and Deal__r.RecordType.DeveloperName in :SimilarAvailableListingTriggerHandler.dealCompsRecordTypeFilter and Deal__r.Deal_Stage__c not in :SimilarAvailableListingTriggerHandler.dealCompsStageFilter ]) {
			// add to location map
			if(!locationMap.containsKey(dp.Property__r.Location_Neighborhood__c))
				locationMap.put(dp.Property__r.Location_Neighborhood__c, new set<string>());
			locationMap.get(dp.Property__r.Location_Neighborhood__c).add(dp.Deal__c);
		}

		if(locationMap.size() > 0) {
			set<Leasing_Comp__c> insSet = new set<Leasing_Comp__c>();
			// query property leases with filter equals location/neighborhood and lease is active (expiration date < today)      
			for(Property_Lease__c pl : [select Id, Name, Lease__c, Property__c, Property__r.Location_Neighborhood__c from Property_Lease__c where Property__r.Location_Neighborhood__c in :locationMap.keySet() and ( Lease__r.Lease_Expiration_Date__c=null or Lease__r.Lease_Expiration_Date__c<:system.today() ) ])
				for(string dealId : locationMap.get(pl.Property__r.Location_Neighborhood__c)) {
					// create leasing comp
					Leasing_Comp__c lc = new Leasing_Comp__c(Lease__c=pl.Lease__c, Deal__c=dealId);
					lc.Upsert_Key__c = LeasingCompTriggerHandler.formatUpsertKey(lc);
					insSet.add(lc);	
				}
	
			if(insSet.size() > 0) {
				upsert (new list<Leasing_Comp__c>(insSet)) Leasing_Comp__c.Upsert_Key__c; 
			}
		}
	}
	
	
	//
	// test methods
	@isTest
	static void Test_LeasingCompTrigger() {
		// create test data
		list<Deal__c> dealList = new list<Deal__c>();
		dealList.add(new Deal__c(Name='Deal1', RecordType=new RecordType(Name='Leasing Deal')));
		dealList.add(new Deal__c(Name='Deal2', RecordType=new RecordType(Name='Leasing Deal')));
		dealList.add(new Deal__c(Name='Deal3', RecordType=new RecordType(Name='Leasing Deal')));
		insert dealList;
		
		list<Lease__c> leaseList = new list<Lease__c>();
		leaseList.add(new Lease__c(Name='Lease1', RecordType=new RecordType(Name='Thor Leasing Lease')));
		leaseList.add(new Lease__c(Name='Lease2', RecordType=new RecordType(Name='Thor Leasing Lease')));
		leaseList.add(new Lease__c(Name='Lease3', RecordType=new RecordType(Name='Thor Leasing Lease')));
		insert leaseList;
		
		Test.startTest();
		
		// test insert
		list<Leasing_Comp__c> lcList = new list<Leasing_Comp__c>();
		lcList.add(new Leasing_Comp__c(Lease__c=leaseList[0].Id, Deal__c=dealList[0].Id));
		lcList.add(new Leasing_Comp__c(Lease__c=leaseList[1].Id, Deal__c=dealList[1].Id));
		lcList.add(new Leasing_Comp__c(Lease__c=leaseList[2].Id, Deal__c=dealList[2].Id));
		insert lcList;
		list<Leasing_Comp__c> testLCList = [select Id, Upsert_Key__c from Leasing_Comp__c];
		system.assertEquals(3, testLCList.size(), 'Error: Leasing Comp <insert> trigger did not insert records.');
		system.assertNotEquals(null, testLCList[0].Upsert_Key__c, 'Error: Leasing Comp <insert> trigger did not populate the upsert key value.');
		
		test.stopTest();
	}
}