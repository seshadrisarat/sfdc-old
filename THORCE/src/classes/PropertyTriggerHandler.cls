/*
*	PropertyTriggerHandler is used to perform logic for PropertyTrigger.  Performs 2 tasks:
*		1) retrieving map coordinates lat/lng for new or updated property address
*		2) create and delete property comps
*
*	Author: Wilson Ng
*	Date:   November 09, 2012
*
*/
public without sharing class PropertyTriggerHandler {
	
	// =================================================
	// constructor
	public PropertyTriggerHandler() { }
	
	// =================================================
	// main entry from triggers
	public void onBeforeDelete(List<Property__c> lstOldProperty) {
		// delete property comps
		deletePropertyComps(lstOldProperty);
	}
	public void onAfterInsert(List<Property__c> lstNewProperty) {
		list<string> idList = new list<string>();
		for(Property__c p : lstNewProperty)
			if(p.Map_Coordinates__Latitude__s==null || p.Map_Coordinates__Longitude__s==null)		// retrieve map coordinates if empty
				idList.add(p.Id);

		// callout to retrieve map coordinates
		if(GeoLocationHelper.enabled && GeoLocationHelper.firstTime && idList.size() > 0)
			GeoLocationHelper.getGeoLocation(idList);
			
		// create property comps
		createPropertyComps(lstNewProperty);
	}
	public void onAfterUpdate(List<Property__c> lstNewProperty, Map<Id, Property__c> mapOldProperty) {
		list<string> idList = new list<string>();
		for(Property__c p : lstNewProperty) {
			Property__c oldp = mapOldProperty.get(p.Id);
			if(p.Street__c != oldp.Street__c || p.City__c != oldp.City__c || p.State__c != oldp.State__c || p.Zip_Code__c != oldp.Zip_Code__c)		// retrieve map coordinates if address changed
				idList.add(p.Id);
		}
		
		// callout to retrieve map coordinates
		if(GeoLocationHelper.enabled && GeoLocationHelper.firstTime && idList.size() > 0)
			GeoLocationHelper.getGeoLocation(idList);
	}
	
	//
	// delete all related property comp
	private void deletePropertyComps(list<Property__c> properties) {
		list<Property_Comp__c> delList = [select id from Property_Comp__c where Property_Comp__c in :properties];
		delete delList;
	}
	//
	// create all related property comp based upon the current property location/neighborhood
	private void createPropertyComps(list<Property__c> properties) {
		// map of unique location/neighborhood
		map<Id, list<Property__c>> locationPropertyMap = new map<Id, list<Property__c>>();
		for(Property__c p : properties) {
			if(!locationPropertyMap.containsKey(p.Location_Neighborhood__c))
				locationPropertyMap.put(p.Location_Neighborhood__c, new list<Property__c>());
			locationPropertyMap.get(p.Location_Neighborhood__c).add(p);
		}
			
		// query all other properties with same location/neighborhood
		set<Property_Comp__c> pcSet = new set<Property_Comp__c>();
		for(Property__c existingProp : [select id, Location_Neighborhood__c from Property__c where Location_Neighborhood__c in :locationPropertyMap.keySet()])
			for(Property__c newProp : locationPropertyMap.get(existingProp.Location_Neighborhood__c))
				if(newProp.Id != existingProp.Id) {
					// create both comp and reverse comp
					Property_Comp__c pc1 = new Property_Comp__c(Property__c=newProp.Id, Property_Comp__c=existingProp.Id);
					pc1.Upsert_Key__c = PropertyCompTriggerHandler.formatUpsertKey(pc1);
					pcSet.add(pc1);				// add comp
					Property_Comp__c pc2 = new Property_Comp__c(Property__c=existingProp.Id, Property_Comp__c=newProp.Id);
					pc2.Upsert_Key__c = PropertyCompTriggerHandler.formatUpsertKey(pc2);
					pcSet.add(pc2);				// add reverse comp
				}

		// insert property comps
		if(pcSet.size() > 0) {
			PropertyCompTriggerHandler.firstTime = false;		// reverse comp handled above...skip propertycomp trigger
			upsert (new list<Property_Comp__c>(pcSet)) Property_Comp__c.Upsert_Key__c;
		}
	}
	
	//
	// test methods
	@isTest
	static void Test_PropertyTrigger() {
		
		// enable geolocationhelper code
		GeoLocationHelper.enabled = true;
		
		// create test data
		list<Location_Neighborhood__c> locList = new list<Location_Neighborhood__c>();
		locList.add(new Location_Neighborhood__c(Name='TestLocation1'));
		locList.add(new Location_Neighborhood__c(Name='TestLocation2'));
		insert locList;
		
		Test.startTest();
		
		// test create
		list<Property__c> propList = new list<Property__c>();
		propList.add(new Property__c(Name='Prop1', Location_Neighborhood__c=locList[0].Id, Street__c='test street', City__c='test city', State__c='TS'));
		propList.add(new Property__c(Name='Prop2', Location_Neighborhood__c=locList[0].Id, Map_Coordinates__Latitude__s=41, Map_Coordinates__Longitude__s=41));
		propList.add(new Property__c(Name='Prop3', Location_Neighborhood__c=locList[0].Id));
		propList.add(new Property__c(Name='Prop4', Location_Neighborhood__c=locList[1].Id));
		insert propList;
		list<Property_Comp__c> testPCList = [select id from Property_Comp__c];
		system.assertEquals(6, testPCList.size(), 'Error: Property <insert> trigger did not generate correct number of property comps.');
		
		// test update
		propList[2].Street__c = 'test street';
		update propList[2];
				
		// test delete
		delete propList[2];
		testPCList = [select id from Property_Comp__c];
		system.assertEquals(2, testPCList.size(), 'Error: Property <delete> trigger did not delete correct number of property comps.');
		
		Test.stopTest();
	}
}