/*
*   ListingCompTriggerHandler is used to perform logic for ListingCompTrigger.  Performs:
*       1) auto-populating the hidden Upsert_Key__c value
*
*   Author: Wilson Ng
*   Date:   November 14, 2012
*
*/
public without sharing class ListingCompTriggerHandler {

    // =================================================
    // constructor
    public ListingCompTriggerHandler() { }
    
    // =================================================
    // main entry from triggers
    public void onBeforeInsert(List<Listing_Comp__c> lstNewListingComp) {
        for(Listing_Comp__c lc : lstNewListingComp)
            lc.Upsert_Key__c = formatUpsertKey(lc);             // auto set the upsert key
    }
    
    //
    // returns formated Upsert Key value
    public static string formatUpsertKey(Listing_Comp__c lc) {
        return string.format('{0},{1}', new string[] { lc.Listing__c, lc.Lease__c } );
    }
    
    
    // query listings and create listing comps for active leases (lease_expiration_date < today)
    public static void createListingComps(list<Property_Lease__c> leases) {
        
        // retrieve all unique location/neighborhoods
        map<string, set<string>> locationMap = new map<string, set<string>>();
        for(Property_Lease__c pl : [select Id, Lease__c, Property__c, Property__r.Location_Neighborhood__c from Property_Lease__c where Id in :leases and ( Lease__r.Lease_Expiration_Date__c=null or Lease__r.Lease_Expiration_Date__c<:system.today() ) ]) {
            // add to location map
            if(!locationMap.containsKey(pl.Property__r.Location_Neighborhood__c))
            {
                locationMap.put(pl.Property__r.Location_Neighborhood__c, new set<string>());
            }
            locationMap.get(pl.Property__r.Location_Neighborhood__c).add(pl.Lease__c);
        }

        if(locationMap.size() > 0)
        {
            set<Listing_Comp__c> insSet = new set<Listing_Comp__c>();
            // query listings with filter equals location/neighborhood and status not equals Occupied or Leased
            for(Listing__c l : [select Id, Name, Property__r.Location_Neighborhood__c from Listing__c where Property__r.Location_Neighborhood__c in :locationMap.keySet() and Listing_Status__c not in :SimilarAvailableListingTriggerHandler.listingCompsStatusFilter ])
                for(string leaseId : locationMap.get(l.Property__r.Location_Neighborhood__c)) {
                    // create listing comp
                    Listing_Comp__c lc = new Listing_Comp__c(Lease__c=leaseId, Listing__c=l.Id);
                    lc.Upsert_Key__c = ListingCompTriggerHandler.formatUpsertKey(lc);
                    insSet.add(lc); 
                }
    
            if(insSet.size() > 0) {
                upsert (new list<Listing_Comp__c>(insSet)) Listing_Comp__c.Upsert_Key__c; 
            }
        }
    }
    
    public static boolean leasedListingCompsCreated = false;
    public static void createLeasedListingComps(list<Listing__c> listings)
    {
        if(leasedListingCompsCreated)
        {
            return;
        }
        leasedListingCompsCreated = true;
        list<Listing__c> listingsToUpdate = new list<listing__C>();
        list<Property_Lease__c> propertyLeases = new list<Property_Lease__c>();
        list<Lease__c> compLeases = new list<Lease__c>();

        
        map<id,id> listingToPropertyIdMap = new map<id,id>();
        list<RecordType> rt = [select id, name from recordType where sObjectType = 'Lease__c' and name='External Lease'];
        
        for(Listing__c listing : listings)
        {
            if(listing.listing_status__c != 'Leased' || listing.Lease__c != null)
            {
                continue;
            }
            listingToPropertyIdMap.put(listing.id,listing.Property__c);
            

            Lease__c thisLease = new lease__c(id=listing.lease__c); 
                
            //if the listing has a listing owner use that for the new lease. Otherwise use the current user
            thisLease.OwnerId = listing.Listing_Owner__c != null ? listing.Listing_Owner__c : UserInfo.getUserId();
            if(!rt.isEmpty())
            {
                thisLease.recordTypeId = rt[0].id;
            }
            thisLease.Space__c = listing.space__c;
            thisLease.Listing__c = listing.id;
            thisLease.Name = listing.name + ' - External Lease';
            thisLease.Space__c = listing.space__c;
            thisLease.Ground_Sqft__c = listing.Ground_Floor_SF__c;
            thisLease.Ground_Floor_Price_Sqft__c = listing.Ground_Rent__c;
            thisLease.Basement_Sqft__c=listing.Basement_SF__c;
            thisLease.Basement_Price_Sqft__c=listing.Basement_Rent__c;
            thisLease.Lower_level_Sqft__c=listing.Lower_Level_SF__c;
            thisLease.Lower_level_Price_Sqft__c=listing.Lower_Level_Rent__c;
            thisLease.X2nd_Floor_Sqft__c=listing.Size_Second_SF__c;
            thisLease.X2nd_Floor_Price_Sqft__c=listing.Second_Level_Rent__c;
            thisLease.X3rd_Floor_Sqft__c=listing.Size_Third_Level_SF__c;
            thisLease.X3nd_Floor_Price_Sqft__c=listing.Third_Level_Rent__c;
            
            thisLease.Mezzanine_Sqft__c=listing.Size_Mezzanine_SF__c;
            thisLease.Mezzanine_Price_Sqft__c=listing.Mezzanine_Rent__c;
            
            thisLease.Storage_Sqft__c=listing.Storage_sf__c;
            thisLease.Storage_Price_Sqft__c=listing.Storage_Price_SPF__c;
            
            thisLease.Sub_Basement_Sqft__c = listing.Sub_Basement_sf__c;
            thisLease.Sub_Basement_Price_Sqft__c=listing.Sub_Basement_Price_sf__c;
            
            thisLease.Leased_Square_Footage__c=listing.Total_Overall_SF__c;
            thisLease.Gross_Rent__c=listing.Total_Rent__c;
            compLeases.add(thisLease);
  
            
        } 
        if(!compLeases.isEmpty())
        {
            database.upsert(compLeases); 
           
            for(Lease__c lease : compLeases)
            {
                Property_Lease__c thisPropetyLease = new Property_Lease__c();
                thisPropetyLease.Lease__c = lease.id;
                thisPropetyLease.Property__c = listingToPropertyIdMap.get(lease.Listing__c);
                propertyLeases.add(thisPropetyLease);
                
                Listing__c parentListing = new Listing__c(id=lease.Listing__c);
                parentListing.lease__c = lease.id;
                listingsToUpdate.add(parentListing);
                    
            } 
            database.insert(propertyLeases);
            database.updatE(listingsToUpdate);
        }       
        
        
        
            
    }
    
    public static void cleanupLeasedListingRecords(list<Listing__c> listings)
    {
        set<id> leasedListings = new set<id>();
        for(Listing__c listing : listings)
        {
            if(listing.Listing_status__c == 'Leased')
            {
                leasedListings.add(listing.id);
            }
        }
        list<Similar_Listing__c> similarListingsToDelete = [select id from Similar_Listing__c where Listing__c in :leasedListings];
        delete similarListingstoDelete;
        
        list<Similar_Available_Listing__c> similarAvailableListingsToDelete = [select id from Similar_Available_Listing__c where Similar_Listing__c in :leasedListings];
        delete similarAvailableListingsToDelete;
    
        list<Site_Survey__c> siteSurveysToDelete = [select id from Site_Survey__c where Listing__c in :leasedListings];
        delete siteSurveysToDelete;
    
        list<Listing_Comp__c> listingsCompsToDelete = [select id from Listing_Comp__c where Listing__c in :leasedListings];
        delete listingsCompsToDelete;    
    }
    
    
    // query leases and create listing comps for non occupied or leased listings
    public static void createListingComps(list<Listing__c> listings) {
                
        // retrieve all unique location/neighborhoods
        map<string, set<string>> locationMap = new map<string, set<string>>();
        for(Listing__c l : [select Id, Property__c, Property__r.Location_Neighborhood__c 
                            from Listing__c 
                            where Id in :listings and 
                                  Listing_Status__c not in :SimilarAvailableListingTriggerHandler.listingCompsStatusFilter ]) 
        {
            // add to location map
            if(!locationMap.containsKey(l.Property__r.Location_Neighborhood__c))
            {
                locationMap.put(l.Property__r.Location_Neighborhood__c, new set<string>());
            }
            locationMap.get(l.Property__r.Location_Neighborhood__c).add(l.Id);
        }
 
        if(locationMap.size() > 0)
        {
            set<Listing_Comp__c> insSet = new set<Listing_Comp__c>();
            
            // query property_lease with filter equals location/neighborhood and lease is active (expiration date < system.today)
            for(Property_Lease__c pl : [select Id, 
                                               Name, 
                                               Lease__c, 
                                               Property__c, 
                                               Property__r.Location_Neighborhood__c 
                                        from Property_Lease__c 
                                        where Property__r.Location_Neighborhood__c in :locationMap.keySet() and 
                                              ( Lease__r.Lease_Expiration_Date__c=null or Lease__r.Lease_Expiration_Date__c<:system.today() ) ])
            {    
                for(string listingId : locationMap.get(pl.Property__r.Location_Neighborhood__c))
                {
                    // create listing comp
                    Listing_Comp__c lc = new Listing_Comp__c(Lease__c=pl.Lease__c, Listing__c=listingId);
                    lc.Upsert_Key__c = ListingCompTriggerHandler.formatUpsertKey(lc);
                    insSet.add(lc); 
                }
            }
 
            if(insSet.size() > 0) 
            {
                upsert (new list<Listing_Comp__c>(insSet)) Listing_Comp__c.Upsert_Key__c; 
            }
        }
    }
    
    
    //
    // test methods
    @isTest
    static void Test_ListingCompTrigger() {
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
        listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));      // property named filter must equals non-thor owned
        listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
        listList.add(new Listing__c(Name='Prop3', Property__c=propList[2].Id));
        insert listList;
        
        list<Lease__c> leaseList = new list<Lease__c>();
        leaseList.add(new Lease__c(Name='Lease1', RecordType=new RecordType(Name='Thor Leasing Lease')));
        leaseList.add(new Lease__c(Name='Lease2', RecordType=new RecordType(Name='Thor Leasing Lease')));
        leaseList.add(new Lease__c(Name='Lease3', RecordType=new RecordType(Name='Thor Leasing Lease')));
        insert leaseList;
        
        Test.startTest();
        
        // test insert
        list<Listing_Comp__c> lcList = new list<Listing_Comp__c>();
        lcList.add(new Listing_Comp__c(Lease__c=leaseList[0].Id, Listing__c=listList[0].Id));
        lcList.add(new Listing_Comp__c(Lease__c=leaseList[1].Id, Listing__c=listList[1].Id));
        lcList.add(new Listing_Comp__c(Lease__c=leaseList[2].Id, Listing__c=listList[2].Id));
        insert lcList;
        list<Listing_Comp__c> testLCList = [select Id, Upsert_Key__c from Listing_Comp__c];
        system.assertEquals(3, testLCList.size(), 'Error: Listing Comp <insert> trigger did not insert records.');
        system.assertNotEquals(null, testLCList[0].Upsert_Key__c, 'Error: Listing Comp <insert> trigger did not populate the upsert key value.');
        
        test.stopTest();
    }
}