/*
*	PropertyLeaseTriggerHandler is used to perform logic for PropertyLeaseTrigger.  Performs:
*		1) auto creation of leasing and listing comps data
*
*	Author: Wilson Ng
*	Date:   November 15, 2012
*
*/
public without sharing class PropertyLeaseTriggerHandler {

	// =================================================
	// constructor
	public PropertyLeaseTriggerHandler() { }
	
	// =================================================
	// main entry from triggers
	public void onAfterInsert(List<Property_Lease__c> lstNewPropertyLease) {
		// create leasing comps
		LeasingCompTriggerHandler.createLeaseComps(lstNewPropertyLease);
		// create listing comps
		ListingCompTriggerHandler.createListingComps(lstNewPropertyLease);	
	}


	//
	// test methods
	@isTest
	static void Test_PropertyLeaseTrigger_Insert() {
		// create test data
		list<Location_Neighborhood__c> locList = new list<Location_Neighborhood__c>();
		locList.add(new Location_Neighborhood__c(Name='TestLocation1'));
		insert locList;
		
		list<Property__c> propList = new list<Property__c>();
		propList.add(new Property__c(Name='Prop1', Location_Neighborhood__c=locList[0].Id, Thor_Ownership__c='Thor Owned'));
		propList.add(new Property__c(Name='Prop2', Location_Neighborhood__c=locList[0].Id, Thor_Ownership__c='Thor Owned'));
		propList.add(new Property__c(Name='Prop3', Location_Neighborhood__c=locList[0].Id));
		insert propList;
		
		list<Deal__c> dealList = new list<Deal__c>();
		dealList.add(new Deal__c(Name='Deal1', RecordType=new RecordType(Name='Leasing Deal')));
		dealList.add(new Deal__c(Name='Deal2', RecordType=new RecordType(Name='Leasing Deal')));
		dealList.add(new Deal__c(Name='Deal3', RecordType=new RecordType(Name='Leasing Deal')));
		insert dealList;
		
		list<Deal_Property__c> dpList = new list<Deal_Property__c>();
		dpList.add(new Deal_Property__c(Deal__c=dealList[0].Id, Property__c=propList[0].Id));	// property named filter must be thor owned
		dpList.add(new Deal_Property__c(Deal__c=dealList[1].Id, Property__c=propList[1].Id));
		dpList.add(new Deal_Property__c(Deal__c=dealList[2].Id, Property__c=propList[1].Id));
		insert dpList;
		
		list<Lease__c> leaseList = new list<Lease__c>();
		leaseList.add(new Lease__c(Name='Lease1', RecordType=new RecordType(Name='Thor Leasing Lease')));
		leaseList.add(new Lease__c(Name='Lease2', RecordType=new RecordType(Name='Thor Leasing Lease')));
		leaseList.add(new Lease__c(Name='Lease3', RecordType=new RecordType(Name='Thor Leasing Lease')));
		insert leaseList;
	
		list<Listing__c> listList = new list<Listing__c>();
		listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
		listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
		listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id, Listing_Status__c='Occupied'));
		insert listList;
		
		Test.startTest();
		
		// test insert
		list<Property_Lease__c> plList = new list<Property_Lease__c>();
		plList.add(new Property_Lease__c(Lease__c=leaseList[0].Id, Property__c=propList[0].Id));
		plList.add(new Property_Lease__c(Lease__c=leaseList[1].Id, Property__c=propList[1].Id));
		plList.add(new Property_Lease__c(Lease__c=leaseList[2].Id, Property__c=propList[2].Id));
		insert plList;
		list<Leasing_Comp__c> testLeaseCompList = [select id from Leasing_Comp__c];//9
		system.assertEquals(9, testLeaseCompList.size(), 'Error: Property Lease <insert> trigger did not generate correct leasing comp records.');
		list<Listing_Comp__c> testListCompList = [select id from Listing_Comp__c];//6
		system.assertEquals(6, testListCompList.size(), 'Error: Property Lease <insert> trigger did not generate correct listing comp records.');
		
		Test.stopTest();
	}
}