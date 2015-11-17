/*
*   ListingTriggerHandler is used to perform logic for ListingTrigger.  Performs:
*       1) create and delete similar listing records
*
*   Author: Wilson Ng
*   Date:   November 14, 2012
*
*/
public without sharing class ListingTriggerHandler {
    
    // =================================================
    // constructor
    public ListingTriggerHandler() { }
    
    // =================================================
    // main entry from triggers
    public void onBeforeDelete(List<Listing__c> lstOldListing) {
        // delete similar listing records
        SimilarListingTriggerHandler.deleteSimilarListings(lstOldListing);
    }
    public void onAfterInsert(List<Listing__c> lstNewListing) {
        // create similar listings
        SimilarListingTriggerHandler.createSimilarListings(lstNewListing);
        // create similar available listings
        SimilarAvailableListingTriggerHandler.createSimilarAvailableListings(lstNewListing);
        // create listing comps
        ListingCompTriggerHandler.createListingComps(lstNewListing);
        
        
        ListingCompTriggerHandler.createLeasedListingComps(lstNewListing);
        
        ListingCompTriggerHandler.cleanupLeasedListingRecords(lstNewListing);
    }

    // if listing status changed from/to occupied/leased, needs to add or delete similarAvailableListings and ListingComps?
    public void onAfterUpdate(map<Id, Listing__c> mapNewListing, map<Id, Listing__c> mapOldListing) {
        // create similar listings
        SimilarListingTriggerHandler.createSimilarListings(mapNewListing.values());
        // create similar available listings
        SimilarAvailableListingTriggerHandler.createSimilarAvailableListings(mapNewListing.values());
        // create listing comps
        ListingCompTriggerHandler.createListingComps(mapNewListing.values());    
        //create leasing comps
        list<Listing__c> listingsToUpdateLeasesFor = new list<listing__c>();
        for(Id listingId : mapNewListing.keySet())
        {
            if( (mapNewListing.get(listingId).lease__c == null) || 
                (mapOldListing.get(listingId).listing_status__c != 'Leased'))
            {
                listingsToUpdateLeasesFor.add(mapNewListing.get(listingId));
            }
        }
        if(!listingsToUpdateLeasesFor.isEmpty())
        {
            ListingCompTriggerHandler.createLeasedListingComps(mapNewListing.values());
        }
        ListingCompTriggerHandler.cleanupLeasedListingRecords(mapNewListing.values());
    
    }
    
    
    //
    // test methods
    @isTest
    static void Test_ListingTrigger() {
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
        dpList.add(new Deal_Property__c(Deal__c=dealList[0].Id, Property__c=propList[0].Id));   // property named filter must be thor owned
        dpList.add(new Deal_Property__c(Deal__c=dealList[1].Id, Property__c=propList[1].Id));
        dpList.add(new Deal_Property__c(Deal__c=dealList[2].Id, Property__c=propList[1].Id));
        insert dpList;
        
        list<Lease__c> leaseList = new list<Lease__c>();
        leaseList.add(new Lease__c(Name='Lease1', RecordType=new RecordType(Name='Thor Leasing Lease')));
        leaseList.add(new Lease__c(Name='Lease2', RecordType=new RecordType(Name='Thor Leasing Lease')));
        leaseList.add(new Lease__c(Name='Lease3', RecordType=new RecordType(Name='Thor Leasing Lease')));
        insert leaseList;
    
        list<Property_Lease__c> plList = new list<Property_Lease__c>();
        plList.add(new Property_Lease__c(Lease__c=leaseList[0].Id, Property__c=propList[0].Id));
        plList.add(new Property_Lease__c(Lease__c=leaseList[1].Id, Property__c=propList[1].Id));
        plList.add(new Property_Lease__c(Lease__c=leaseList[2].Id, Property__c=propList[2].Id));
        insert plList;
        
        Test.startTest();
        
        // test insert
        SimilarListingTriggerHandler.firstTime = true;//needs to reset the recursive trigger indicator for next dml in test method
        list<Listing__c> listList = new list<Listing__c>();
        listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
        listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
        listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id, Listing_Status__c='Occupied'));
        insert listList;
        list<Similar_Listing__c> testSLList = [select id from Similar_Listing__c];//6
        system.assertEquals(6, testSLList.size(), 'Error: Listing <insert> trigger did not generate correct similar listing records.');
        list<Similar_Available_Listing__c> testSALList = [select id from Similar_Available_Listing__c];//6
        system.assertEquals(6, testSALList.size(), 'Error: Listing <insert> trigger did not generate correct similar available listing records.');
        list<Listing_Comp__c> testLCList = [select id from Listing_Comp__c];//6
        system.assertEquals(6, testLCList.size(), 'Error: Listing <insert> trigger did not generate correct listing comp records.');
        
        // test delete
        SimilarListingTriggerHandler.firstTime = true;//needs to reset the recursive trigger indicator for next dml in test method
        delete listList[1];
        testSLList = [select id from Similar_Listing__c];//2
        system.assertEquals(2, testSLList.size(), 'Error: Listing <delete> trigger did not delete correct similar listing records.');
        
        Test.stopTest();
    }
}