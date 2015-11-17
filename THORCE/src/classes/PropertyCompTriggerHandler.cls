/*
*	PropertyCompTriggerHandler is used to perform logic for PropertyCompTrigger.  Performs:
*		1) auto-populating the hidden Upsert_Key__c value
*		2) auto creation and deletion of reverse property comp records 
*
*	Author: Wilson Ng
*	Date:   November 14, 2012
*
*/
public without sharing class PropertyCompTriggerHandler {

	public static boolean firstTime = true;			// prevent recursive triggers
	
	// =================================================
	// constructor
	public PropertyCompTriggerHandler() { }
	
	// =================================================
	// main entry from triggers
	public void onBeforeInsert(List<Property_Comp__c> lstNewPropertyComp) {
		for(Property_Comp__c pc : lstNewPropertyComp)
			pc.Upsert_Key__c = formatUpsertKey(pc);				// auto set the upsert key
	}
	public void onBeforeUpdate(List<Property_Comp__c> lstNewPropertyComp, Map<Id, Property_Comp__c> mapOldPropertyComp) {
		for(Property_Comp__c pc : lstNewPropertyComp) {
			Property_Comp__c oldpc = mapOldPropertyComp.get(pc.Id);
			if(pc.Property_Comp__c != oldpc.Property_Comp__c || pc.Upsert_Key__c == null)	// if property comp changed. then update the upsert key
				pc.Upsert_Key__c = formatUpsertKey(pc);
		}
	}
	public void onAfterInsert(List<Property_Comp__c> lstNewPropertyComp) {
		if(!firstTime) return;
		firstTime = false;
		createReverseComps(lstNewPropertyComp);			// create reverse comps
	}
	public void onAfterUpdate(List<Property_Comp__c> lstNewPropertyComp, Map<Id, Property_Comp__c> mapOldPropertyComp) {
		if(!firstTime) return;
		firstTime = false;
		list<Property_Comp__c> createList = new list<Property_Comp__c>();
		list<Property_Comp__c> deleteList = new list<Property_Comp__c>();
		for(Property_Comp__c pc : lstNewPropertyComp) {
			Property_Comp__c oldpc = mapOldPropertyComp.get(pc.Id);
			if(pc.Property_Comp__c != oldpc.Property_Comp__c) {			// check for lookup changed, if so, then delete old reverse, and create new one
				createList.add(pc);
				deleteList.add(oldpc);
			} 
		}
		if(deleteList.size() > 0)
			deleteReverseComps(deleteList);
		if(createList.size() > 0)
			createReverseComps(createList);
	}
	public void onAfterDelete(List<Property_Comp__c> lstOldPropertyComp) {
		if(!firstTime) return;
		firstTime = false;
		deleteReverseComps(lstOldPropertyComp);			// deletes reverse comps
	}
		
	//
	// returns formated Upsert Key value
	public static string formatUpsertKey(Property_Comp__c pc) {
		return string.format('{0},{1}', new string[] { pc.Property__c, (pc.Property_Comp__c!=null?pc.Property_Comp__c:'') } );
	}
	public static string formatReversedUpsertKey(Property_Comp__c pc) {
		return string.format('{0},{1}', new string[] { pc.Property_Comp__c, pc.Property__c } );
	}
	
	//
	// creates reverse comps
	private void createReverseComps(list<Property_Comp__c> propertyComps) {
		set<Property_Comp__c> upsSet = new set<Property_Comp__c>();
		for(Property_Comp__c pc : propertyComps)
			if(pc.Property_Comp__c != null) 
				upsSet.add(new Property_Comp__c(Property__c=pc.Property_Comp__c, Property_Comp__c=pc.Property__c, Upsert_Key__c=formatReversedUpsertKey(pc)));
		if(upsSet.size() > 0)
			upsert (new list<Property_Comp__c>(upsSet)) Property_Comp__c.Upsert_Key__c;
	}
	
	//
	// deletes reverse comps
	private void deleteReverseComps(list<Property_Comp__c> propertyComps) {
		set<string> upsertkeys = new set<string>();
		for(Property_Comp__c pc : propertyComps)
			upsertkeys.add(formatReversedUpsertKey(pc));
		if(upsertkeys.size() > 0) {
			list<Property_Comp__c> delList = [select id from Property_Comp__c where Upsert_Key__c in :upsertkeys];
			delete delList;
		}
	}
	
	
	//
	// test methods
	@isTest
	static void Test_PropertyCompTrigger() {
		
		// create test data
		list<Location_Neighborhood__c> locList = new list<Location_Neighborhood__c>();
		locList.add(new Location_Neighborhood__c(Name='TestLocation1'));
		locList.add(new Location_Neighborhood__c(Name='TestLocation2'));
		locList.add(new Location_Neighborhood__c(Name='TestLocation3'));
		insert locList;
				
		list<Property__c> propList = new list<Property__c>();
		propList.add(new Property__c(Name='Prop1', Location_Neighborhood__c=locList[0].Id));
		propList.add(new Property__c(Name='Prop2', Location_Neighborhood__c=locList[1].Id));
		propList.add(new Property__c(Name='Prop3', Location_Neighborhood__c=locList[2].Id));
		insert propList;
		
		Test.startTest();
		
		// test inserts
		list<Property_Comp__c> pcList = new list<Property_Comp__c>();
		pcList.add(new Property_Comp__c(Property__c=propList[0].Id, Property_Comp__c=propList[1].Id));
		pcList.add(new Property_Comp__c(Property__c=propList[1].Id, Property_Comp__c=propList[2].Id));
		insert pcList;
		list<Property_Comp__c> testPCList = [select id, Upsert_Key__c from Property_Comp__c];
		system.assertEquals(4, testPCList.size(), 'Error: Property Comp <insert> trigger did not generate reverse comps.');
		system.assertNotEquals(null, testPCList[0].Upsert_Key__c, 'Error: Property Comp <insert> trigger did not properly generate the upsert key value.');
		
		// test updates
		firstTime = true;//needs to reset the recursive trigger indicator for next dml in test method
		pcList[0].Property_Comp__c=propList[2].Id;
		update pcList[0];
		testPCList = [select id from Property_Comp__c where Property__c=:propList[2].Id];
		system.assertEquals(2, testPCList.size(), 'Error: Property Comp <update> trigger did not generate reverse comps.');
		
		// test deletes
		firstTime = true;//needs to reset the recursive trigger indicator for next dml in test method
		delete pcList;
		testPCList = [select id from Property_Comp__c];
		system.assertEquals(0, testPCList.size(), 'Error: Property Comp <delete> trigger did not delete reverse comps.');
		
		Test.stopTest();
	}
}