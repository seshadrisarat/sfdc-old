/*
*       MapSearch_Controller is used to perform Controller logic for new Map Search VF page.  This controller inherits the Advanced Search controller.
*       This controller is used for display the custom UI for adding and managing many to many junction data for Map Searches.
* 
*       Author  :   Wilson Ng 
*       Date    :   October 18, 2012
* 
*/
public with sharing class MapSearch_Controller extends AdvancedSearch_Controller {
    
    public static final String PARAM_IDS = 'ids';
    
    public MapSearch_Controller controller{get;set;}
    public transient String actionButton{get;set;}
    
    // Properties - label merges TODO
    public String mapSearchTabLabel{get{ return String.format('Map Search {0}', new string[]{toObjectLabelPlural==null?'':toObjectLabelPlural}); }}
    
    public boolean useMapSearch{get;private set;}
        
    // constructor using sobject standardcontroller
    public MapSearch_Controller(ApexPages.StandardController stdController) {
        system.debug('in MapSearch standard controller - '+this);

        // configuration values are passed directly into the properties variables
        rec = stdController.getRecord();
        
        initialize();
    }
    // constructor using custom controller
    public MapSearch_Controller() {
        system.debug('in MapSearch custom controller - '+this);
        // configuration values comes in through the url parameters
        map<String, String> params = ApexPages.currentPage().getParameters(); 
        system.debug('url parameters are: '+params);
        configName = params.get(PARAM_CONFIGNAME);
        retUrl = params.get(PARAM_RETURL);
        fromId = (Id)params.get(PARAM_FROMID);
        fromName = params.get(PARAM_FROMNAME);
        actionIds = params.get(PARAM_IDS);
        initialize();
    }
    protected override void initialize(){
        super.initialize();
        
        controller = this;
    }
    
    // process input configuration variables
    public override PageReference myinitfunc() {
        system.debug('in MapSearch myinitfunc...configName['+configName+'], fromId['+fromId+'], fromName['+fromName+'], retURL['+retURL+'], ids['+actionIds+']');
        
        // initialize base
        super.myinitfunc();
        
        // initialize specific or overridden map search configurations      
        try {
            useMapSearch = currConfig.Use_Map_Search__c;
            tabInFocus = string.isNotEmpty(actionIds) ? 'theMapSearchTab' : 
                            useM2M2 ? 'theManageTab' : 
                            useAdvancedSearch ? 'theSearchTab' :
                            'theMapSearchTab';
        }
        catch (Exception ex) {
            // throw an exception
            //TODO -label
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(Label.AdvancedSearch_Configuration_Error, new string[] {ex.getMessage()})));
            isFatalError = true;
        }
        return null;
    }
    
    
    //
    // Javascript Remoting methods
    // NOTE: remote methods needs to be in this class, not in MapSearch_Controller
    
    static set<string> propertyObjects = new set<string> { 'Property__c', 'Property_Comp__c' };
    static set<string> listingObjects = new set<string> { 'Listing__c', 'Site_Survey__c', 'Similar_Listing__c', 'Similar_Available_Listing__c' } ;
    static set<string> leaseObjects = new set<string> { 'Lease__c', 'Property_Lease__c', 'Leasing_Comp__c', 'Listing_Comp__c' };

    static boolean isPropertyObject(string obj) { return propertyObjects.contains(obj); }
    static boolean isListingObject(string obj) { return listingObjects.contains(obj); }
    static boolean isLeaseObject(string obj) { return leaseObjects.contains(obj); }

    static string propertyHolder = '{0}';
    static string listingHolder = '{1}';
    static string leaseHolder = '{2}';
    
    static string[] propertyFields = new string[] { 'Id', 'Name' , 'Total_Overall_SF__c', 'Annual_Market_Rent_PSF__c', 'Street__c', 'Property_Photo_Document_Url__c', 'Map_Coordinates__Longitude__s', 'Map_Coordinates__Latitude__s' };
    static string[] listingFields = new string[] { 'Id', 'Name', 'Space__c', 'Listing_Status__c', 'Total_Overall_SF__c', 'Total_Rent__c' };
    static string[] leaseFields = new string[] { 'Id', 'Name', 'Lease_Expiration_Date__c', 'Leased_Square_Footage__c', 'Gross_Rent__c' };
    
    static string propertySFFilterField = 'Total_Retail_Space_SF__c';
    static string listingSFFilterField = 'Ground_floor_SF__c';
    static string leaseSFFilterField = 'Leased_Square_Footage__c';
    
    /* TODO - if move into helper class:
    static map<string, string> propertyLookupRelationships = new map<string, string> {
        'Property__c' => '',
        'Property_Comp__c' => 'Property_Comp__r.',
        'Site_Survey__c' => 'Listing__r.Property__r.',
        'Similar_Listing__c' => 'Similar_Listing__r.Property__r.'
        //ALL ELSE => 'Property__r.'
    };
    static map<string, string> listingLookupRelationships = new map<string, string> {
        'Site_Survey__c' => 'Listing__r.',
        'Similar_Listing__c' => 'Similar_Listing__r.'
        //ALL ELSE => ''
    };
    static map<string, string> leaseLookupRelationships = new map<string, string> {
        'Property_Lease__c' => 'Lease__r.'
        //ALL ELSE => ''
    };
    
    */
    
    // action returns list of location/neighborhood based on the input startswith string value
    @RemoteAction
    public static list<MapSearch_Helper.Location> getLocations(string startswith) {
        list<MapSearch_Helper.Location> locationList = null;
        if (!MapSearch_Helper.IsNullOrEmpty(startswith)) {
            locationList = new list<MapSearch_Helper.Location>();
            string searchLocation = startswith + '%';
            string query = 'select Id, Name from Location_Neighborhood__c where Name like :searchLocation order by Name asc';
            for(Location_Neighborhood__c loc : database.query(query))
                locationList.add(new MapSearch_Helper.Location(loc.Name));
            
            string subLocationQuery =  'select Id, Name from Location_submarket__c where Name like :searchLocation order by Name asc';   
            for(Location_submarket__c loc : database.query(subLocationQuery))
                locationList.add(new MapSearch_Helper.Location(loc.Name));        
        }
        return locationList;
    }
    
    // action performs map search based on lat/long map coordinates
    @RemoteAction
    public static list<MapSearch_Helper.ProfileInfo> getProfilesByCoordinates(string configname, string points) {
        system.debug('get profiles by coordinates - configname['+configname+']  points['+points+']');
        
        // check config name
        if(string.isEmpty(configname))
            throw new M2M2_Exception(String.format(Label.M2M2_Configuration_Error, new string[] {'Missing Many to Many 2 Configuration Name.'}));
        M2M2_Config__c currConfig = M2M2_Config__c.getInstance(configname);
        if(currConfig == null)
            throw new M2M2_Exception(String.format(Label.M2M2_Configuration_Error, new string[] {'Invalid Many to Many 2 Configuration Name ['+configname+']'}));
        string objectName = currConfig.Search_Object_Name__c;
        
        list<MapSearch_Helper.ProfileInfo> filteredProfiles = null;
        list<MapSearch_Helper.Coordinates> coordinates = MapSearch_Helper.GetPointsFromString(points, ';', ',');
        if (coordinates == null)
            return null;
    
        list<MapSearch_Helper.Coordinates> minMaxArray = MapSearch_Helper.SetMaxMinPoints(coordinates);
        MapSearch_Helper.Coordinates min = minMaxArray[0];
        MapSearch_Helper.Coordinates max = minMaxArray[1];
    
        list<MapSearch_Helper.ProfileInfo> profiles = GetProfilesByCoordinatesRectangle(objectname, min, max, currConfig.FilterClause__c);
        if (profiles == null || profiles.Size() == 0)
            return null;
    
        filteredProfiles = new list<MapSearch_Helper.ProfileInfo>();
        //find in area
        for(MapSearch_Helper.ProfileInfo item : profiles)
            if (MapSearch_Helper.PoligonContains(points, string.Format('{0}, {1}', new list<string> { String.valueOf(item.Latitude), String.valueOf(item.Longitude) } )))
                filteredProfiles.Add(item);

        return filteredProfiles;        
    }
    // retrieves profiles within a specified rectangle area
    private static list<MapSearch_Helper.ProfileInfo> getProfilesByCoordinatesRectangle(string objectname, MapSearch_Helper.Coordinates min, MapSearch_Helper.Coordinates max, string additionalFilter) {
        system.debug('get profiles by coordinates rectangle - objectname['+objectname+'], min['+min+'], max['+max+'],  additionalFilter['+additionalFilter+']');
        double minLat = min.X, minLong = min.Y, maxLat = max.X, maxLong = max.Y;
        //TODO - how to order by
        string query = string.format('select '+constructListOfFields(objectname)+' from {3} where {0}Map_Coordinates__Latitude__s >= :minLat and {0}Map_Coordinates__Latitude__s <= :maxLat and {0}Map_Coordinates__Longitude__s >= :minLong and {0}Map_Coordinates__Longitude__s <= :maxLong ',
                            constructListOfReplacementLookups(objectname) ) +
                            (additionalFilter!=null?' and ( '+additionalFilter+' ) ':'') + ' limit 1000';
        system.debug('getProfilesByCoordinatesRectangle SOQL query: ' + query);
        return parseQuery(objectname, database.query(query));
    }
    
    // action performs map search using search filters of area (location/neighborhood) and floor sizes 
    @RemoteAction
    public static list<MapSearch_Helper.ProfileInfo> getProfilesByFilters(string configname, string area, double flrSzeMin, double flrSzeMax) {
        system.debug('get profiles by filters - configname['+ configname + '], area['+area+'], flrsizemin['+flrSzeMin+'], flrsizemax['+flrSzeMax+']');
        // check config name
        if(string.isEmpty(configname))
            throw new M2M2_Exception(String.format(Label.M2M2_Configuration_Error, new string[] {'Missing Many to Many 2 Configuration Name.'}));
        M2M2_Config__c currConfig = M2M2_Config__c.getInstance(configname);
        if(currConfig == null)
            throw new M2M2_Exception(String.format(Label.M2M2_Configuration_Error, new string[] {'Invalid Many to Many 2 Configuration Name ['+configname+']'}));
        string objectName = currConfig.Search_Object_Name__c;

        if (!MapSearch_Helper.IsNullOrEmpty(area)) {
            //TODO - how to order by
           
            string query = string.format('select '+constructListOfFields(objectname)+' from {3} where ({0}Location_Neighborhood_name__c = :area or {0}Submarket__r.name = :area) and ' + constructSFFilter(objectname, 'flrSzeMin', 'flrSzeMax'),
                                constructListOfReplacementLookups(objectname) ) +
                                (currConfig.FilterClause__c!=null?' and ( '+currConfig.FilterClause__c+' ) ':'') + ' limit 1000';
            system.debug('getProfilesByFilters SOQL query: ' + query);              
            return parseQuery(objectname, database.query(query));
        }
        return null;
    }
    
    // action returns list of profiles with specified salesforce ids (profileIds)
    @RemoteAction
    public static list<MapSearch_Helper.ProfileInfo> getProfilesByPortions(string configname, string profileIds) {
        system.debug('get profiles by portions - configname['+configname+'], profileids['+profileIds+']');
        // check config name
        if(string.isEmpty(configname))
            throw new M2M2_Exception(String.format(Label.M2M2_Configuration_Error, new string[] {'Missing Many to Many 2 Configuration Name.'}));
        M2M2_Config__c currConfig = M2M2_Config__c.getInstance(configname);
        if(currConfig == null)
            throw new M2M2_Exception(String.format(Label.M2M2_Configuration_Error, new string[] {'Invalid Many to Many 2 Configuration Name ['+configname+']'}));

        return getProfilesByPortionsInternal(currConfig.Search_Object_Name__c, profileIds);
    }
    
    private static list<MapSearch_Helper.ProfileInfo> getProfilesByPortionsInternal(string objectname, string profileIds) {
        system.debug('get profiles by portions internal - objectname['+objectname+'], profileids['+profileIds+']');

        if(!MapSearch_Helper.IsNullOrEmpty(profileIds)) {
            // special handling for leasing objects
            // check object prefix using 1st 3 chars of the profileIds
            objectname = getObjectName(profileIds.subString(0, 3));
            if(isLeaseObject(objectname) && objectname!='Property_Lease__c') {
                // find all property_lease__c records for leases
                list<string> propLeaseIds = (objectname=='Lease__c' ? retrievePropertyLeaseIds(profileIds.split(',')) : retrievePropertyLeaseIds(objectname, profileIds.split(',')) );
                if(propLeaseIds!=null && propLeaseIds.size() > 0)
                    return getProfilesByPortionsInternal('Property_Lease__c', string.join(propLeaseIds, ','));
                return null;
            }
            
            list<string> idsList = profileIds.split(',');
            //TODO - how to order by
            string query = string.format('select '+constructListOfFields(objectname)+' from {3} where id in :idsList limit 1000', 
                                constructListOfReplacementLookups(objectname) );
            system.debug('getProfilesByPortions SOQL query: ' + query);
            return parseQuery(objectname, database.query(query));
        }
        return null;
    }
    
    private static string getObjectName(string prefix) {
        for(Schema.sobjecttype mytype : Schema.getGlobalDescribe().values())
            if(prefix.equals(mytype.getdescribe().getKeyprefix()))
                return mytype.getdescribe().getname();
        return null;
    }
    
    // constructs SF filter depending on the obj field
    private static string constructSFFilter(string obj, string minFld, string maxFld) {
        string objHolder = (isLeaseObject(obj) ? leaseHolder : 
                            isListingObject(obj) ? listingHolder :
                            propertyHolder);
        string filterField = (isLeaseObject(obj) ? leaseSFFilterField :
                                isListingObject(obj) ? listingSFFilterField :
                                propertySFFilterField);
        return string.format('({0}{1}=null or ({0}{1} >= :{2} and {0}{1} <= :{3}))', new string[] { objHolder, filterField, minFld, maxFld } ); 
    } 
                                
    
    // constructs the replacement lookups for {0} to {3} in the SOQL query statements
    private static string[] constructListOfReplacementLookups(string obj) {
        string propertyLookup = (obj=='Property__c' ? '' :
                                    obj=='Property_Comp__c' ? 'Property_Comp__r.' :
                                    obj=='Site_Survey__c' ? 'Listing__r.Property__r.' :
                                    obj=='Similar_Listing__c' ? 'Similar_Listing__r.Property__r.' :
                                    obj=='Similar_Available_Listing__c' ? 'Similar_Listing__r.Property__r.' :
                                    'Property__r.');
        string listingLookup = (obj=='Site_Survey__c' ? 'Listing__r.' :
                                obj=='Similar_Listing__c' ? 'Similar_Listing__r.' :
                                obj=='Similar_Available_Listing__c' ? 'Similar_Listing__r.' :
                                '');
        string leaseLookup = (obj=='Property_Lease__c' ? 'Lease__r.' :
                                '');
        return new string[] { propertyLookup, listingLookup, leaseLookup, obj };
    }
    
    // constructs the list of fields from property, listing and lease object, including replacement positions holders
    private static string constructListOfFields(string obj) {
        string propFields = propertyHolder + string.join(propertyFields, ','+propertyHolder);
        string listFields = listingHolder + string.join(listingFields, ','+listingHolder);
        string leasFields = leaseHolder + string.join(leaseFields, ','+leaseHolder);
        return propFields + (isListingObject(obj) ? ','+listFields : '') + (isLeaseObject(obj) ? ','+leasFields : '');
    }
    
    // parses each queried sobject row into generic profileinfo object
    private static list<MapSearch_Helper.ProfileInfo> parseQuery(string sobj, list<sObject> sobjList) {
        list<MapSearch_Helper.ProfileInfo> retList = new list<MapSearch_Helper.ProfileInfo>();
        for(sObject row : (list<sObject>)sobjList) {
            // property level
            sObject p = (sobj=='Property__c' ? (sObject)row : 
                                sobj=='Property_Comp__c' ? (sObject)row.getSObject('Property_Comp__r') :
                                sobj=='Site_Survey__c' ? ((sObject)row.getSObject('Listing__r')).getSObject('Property__r') :
                                sobj=='Similar_Listing__c' ? ((sObject)row.getSObject('Similar_Listing__r')).getSObject('Property__r') :
                                sobj=='Similar_Available_Listing__c' ? ((sObject)row.getSObject('Similar_Listing__r')).getSObject('Property__r') :
                                (sObject)row.getSObject('Property__r'));
            // listing and lease level
            sObject l = (sobj=='Listing__c' ? (sObject)row : 
                                sobj=='Site_Survey__c' ? (sObject)row.getSObject('Listing__r') :
                                sobj=='Similar_Listing__c' ? (sObject)row.getSObject('Similar_Listing__r') :
                                sobj=='Similar_Available_Listing__c' ? (sObject)row.getSObject('Similar_Listing__r') :
                                sobj=='Lease__c' ? (sObject)row :
                                sobj=='Property_Lease__c' ? (sObject)row.getSObject('Lease__r') :
                                p);
            // skip if map coordinates are empty
            if(p.get('Map_Coordinates__Latitude__s')==null || p.get('Map_Coordinates__Longitude__s')==null)
                continue;
                
            // remove duplicates ... scratch that...duplicates will remain in return list
//          if(!profileExists(retList, (string)l.get('Id'))) {
                MapSearch_Helper.ProfileInfo pi = new MapSearch_Helper.ProfileInfo();
                pi.Oid = (string)l.get('Id');
                pi.Name = (string)l.get('Name');
                pi.Status = (string)(isListingObject(sobj) ? l.get('Listing_Status__c') : 
                                    isLeaseObject(sobj) ? formatDate(l.get('Lease_Expiration_Date__c')) : '');
                pi.Latitude = (double)p.get('Map_Coordinates__Latitude__s');
                pi.Longitude = (double)p.get('Map_Coordinates__Longitude__s');
                string space = (string)(isListingObject(sobj) ? l.get('Space__c') : '');
                pi.Street = (string)p.get('Street__c') + (string.isNotEmpty(space) ? ' '+space : '');
                pi.Photo = (string)p.get('Property_Photo_Document_Url__c');
                pi.SizeTotal = (double)l.get((isLeaseObject(sobj) ? 'Leased_Square_Footage__c' : 'Total_Overall_SF__c'));
                pi.AnnualRent = (double)l.get((isListingObject(sobj) ? 'Total_Rent__c' : 
                                    isLeaseObject(sobj) ? 'Gross_Rent__c' : 'Annual_Market_Rent_PSF__c' ));                
                retList.add(pi);
//          }
        }
        return retList;
    }
    
    // checks for null value and if not null formats a date to mm/dd/yyyy
    private static string formatDate(object mydate) {
        return (mydate != null ? ((Date)mydate).format() : '');
    }
    
    // returns true if myid already exists in the list of profiles
    private static boolean profileExists(list<MapSearch_Helper.ProfileInfo> mylist, string myid) {
        for(MapSearch_Helper.ProfileInfo pi : mylist)
            if(pi.Oid == myid)
                return true;
        return false;
    }
    
    // retrieve a list of property lease ids from list of either leasing_comp or listing_comp ids
    private static list<string> retrievePropertyLeaseIds(string objectname, list<string> ids) {
        // retrive lease ids from objectname first
        string query = 'select Lease__c from '+objectname+' where id in :ids limit 1000';
        system.debug(objectname+' SOQL query: ' + query);
        list<id> leaseids = new list<id>();
        for(sobject sobj : database.query(query))
            leaseids.add((Id)sobj.get('Lease__c'));
        return (leaseids.size() > 0 ? retrievePropertyLeaseIds(leaseids) : null);
    }
    
    // retrieve a list of property lease ids from list of lease ids
    private static list<string> retrievePropertyLeaseIds(list<string> leaseids) {
        // retrieve all property_lease ids using list of lease ids
        string query = 'select id from Property_Lease__c where Lease__c in :leaseids limit 1000';
        system.debug('Property_Lease__c SOQL query: ' + query);
        list<string> propLeaseids = new list<string>();
        for(sobject sobj : database.query(query))
            propLeaseids.add((string)sobj.get('Id'));
        // return list of property lease ids
        return propLeaseids;
    }
    
    
    //
    // action functions
    public PageReference insertRecords() {
        return addNewRecords('theMapSearchTab');
    }
    
    public PageReference deleteRecords() {
        // handle translating toIds to junctionIds
        system.debug('in mapsearch deleterecords, objectname is: '+objectName+', toField is: ' +toField+', actionIds: '+actionIds);
        list<id> juncIdsList = new list<id>();
        for(id s : actionIds.split(',')) {
            sobjectwrapper swrap = findOneToId(manageList, s);
            if(swrap != null)
                juncIdsList.add(swrap.record.Id);
        }
        if(juncIdsList.size() > 0) {
            this.actionIds = string.join(juncIdsList, ',');
            system.debug('junction actionIds: ' + this.actionIds);
        }
        return massDelete('theMapSearchTab');
    }
    
    public PageReference showInMap() {
        tabInFocus = 'theMapSearchTab';
        return null;
    }
    
    //
    // exception class
    public class MapSearch_Exception extends Exception {}
    
    
    //
    // Test methods
    @isTest
    static void testThisClass(){
        
        // insert config record: Deal_Property__c
        string configName = 'DealProperties';
        M2M2_Config__c testConfig = new M2M2_Config__c(Name=configName, ObjectName__c='Deal_Property__c', FromField__c='Deal__c', ToField__c='Property__c', 
                                    AllowDuplicates__c=false, FilterClause__c='Thor_Ownership__c in (\'Thor Owned\')', 
                                    IsTextSearch__c=false, SearchResultLimit__c=10, Tab_Label__c='properties', Use_M2M2__c=true,
                                    Search_Object_Name__c='Property__c', Use_Salesforce_Create_New__c=true, Use_Listviews__c=false, Use_Advanced_Search__c=true, Use_Map_Search__c=true);
        insert testConfig;

        // insert deal
        Deal__c deal = new Deal__c(Name='test deal', RecordType=new Recordtype(Name='Leasing Deal'));
        insert deal;
        
        // insert properties
        list<Location_Neighborhood__c> locs = new list<Location_Neighborhood__c>();
        locs.add(new Location_Neighborhood__c(Name='soho'));
        locs.add(new Location_Neighborhood__c(Name='chelsea'));
        locs.add(new Location_Neighborhood__c(Name='chinatown'));
        insert locs;
        list<Property__c> props = new list<Property__c>();
        props.add(new Property__c(Name='test property1', Location_Neighborhood__c=locs[0].Id, Total_Retail_Space_SF__c=100, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Thor Owned'));
        props.add(new Property__c(Name='test property2', Location_Neighborhood__c=locs[0].Id, Total_Retail_Space_SF__c=200, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Thor Prospect'));
        props.add(new Property__c(Name='test property3', Location_Neighborhood__c=locs[0].Id, Total_Retail_Space_SF__c=300, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Thor Owned'));
        props.add(new Property__c(Name='test property4', Location_Neighborhood__c=locs[1].Id, Total_Retail_Space_SF__c=400, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Thor Owned'));
        props.add(new Property__c(Name='test property5', Location_Neighborhood__c=locs[1].Id, Total_Retail_Space_SF__c=500, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Non-Thor Owned'));
        insert props;
        
        Test.startTest();
        
        // set initial page and controller instance
        PageReference testPageReference = Page.MapSearch_Page; 
        map<string, string> params = testPageReference.getParameters();
        params.put(M2M2_Controller.PARAM_CONFIGNAME, configName);
        params.put(M2M2_Controller.PARAM_FROMID, deal.Id);
        params.put(M2M2_Controller.PARAM_FROMNAME, deal.Name);
        params.put(M2M2_Controller.PARAM_RETURL, '/'+deal.Id);
        Test.setCurrentPage(testPageReference);
        MapSearch_Controller testController = new MapSearch_Controller(new ApexPages.StandardController(deal));     // cover both custom and standard controller
        testController = new MapSearch_Controller();
        testController.myinitfunc();
        system.assertEquals(false, ApexPages.hasMessages(), 'Error: VF page/controller initialization has errors - ' + testController.concatenateApexPagesMessages());
        
        // test callouts
        list<MapSearch_Helper.Location> testLocs = getLocations('ch');
        system.assertEquals(2, testLocs.size(), 'Error: GetLocations did not return correct number of locations.');

        string rect = '40,-70; 41,-70; 41,-69; 40,-69';
        list<MapSearch_Helper.ProfileInfo> testProfiles = getProfilesByCoordinates(configName, rect); 
        system.assertEquals(3, testProfiles.size(), 'Error: GetProfilesByCoordinates did not return correct number of profiles.');
    
        testProfiles = getProfilesByFilters(configName, 'soho', 100, 500); 
        system.assertEquals(2, testProfiles.size(), 'Error: GetProfilesByFilters test1 did not return correct number of profiles.');
    
        testProfiles = getProfilesByFilters(configName, 'chelsea', 100, 500); 
        system.assertEquals(1, testProfiles.size(), 'Error: GetProfilesByFilters test2 did not return correct number of profiles.');
    
        testProfiles = getProfilesByPortions(configName, '' + props[0].Id); 
        system.assertEquals(1, testProfiles.size(), 'Error: GetProfilesByPortions did not return correct number of profiles.');
    
        // test actions
        testController.actionIds = '' + props[0].Id + ',' + props[2].Id + ',' + props[3].Id;
        testController.insertRecords();
        system.assertEquals(3, testController.manageList.size(), 'Error: InsertRecords failed.');
    
        testController.actionIds = '' + props[0].Id;
        testController.deleteRecords(); 
        system.assertEquals(2, testController.manageList.size(), 'Error: DeleteRecords failed.');
    
        testController.showInMap();
    
        Test.stopTest();
    }
    
    @isTest
    static void testThisClass_PropertyLease(){
        
        // insert config record: Property_Lease__c
        string configName = 'Lease';
        M2M2_Config__c testConfig = new M2M2_Config__c(Name=configName, ObjectName__c='Lease__c', SearchResultLimit__c=10, Use_M2M2__c=false,
                                    Search_Object_Name__c='Property_Lease__c', Use_Advanced_Search__c=false, Use_Map_Search__c=true);
        insert testConfig;

        // insert lease
        Lease__c lease = new Lease__c(Name='test lease', RecordType=new Recordtype(Name='Thor Leasing Lease'));
        insert lease;
        
        // insert properties
        Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='soho');
        insert loc;
        list<Property__c> props = new list<Property__c>();
        props.add(new Property__c(Name='test property1', Location_Neighborhood__c=loc.Id, Total_Retail_Space_SF__c=100, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Thor Owned'));
        props.add(new Property__c(Name='test property2', Location_Neighborhood__c=loc.Id, Total_Retail_Space_SF__c=200, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Thor Prospect'));
        props.add(new Property__c(Name='test property3', Location_Neighborhood__c=loc.Id, Total_Retail_Space_SF__c=300, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Thor Owned'));
        props.add(new Property__c(Name='test property4', Location_Neighborhood__c=loc.Id, Total_Retail_Space_SF__c=400, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Thor Owned'));
        props.add(new Property__c(Name='test property5', Location_Neighborhood__c=loc.Id, Total_Retail_Space_SF__c=500, Map_Coordinates__Latitude__s=40.5, Map_Coordinates__Longitude__s=-69.5, Thor_Ownership__c='Non-Thor Owned'));
        insert props;
        
        // insert property leases
        list<Property_Lease__c> propLeases = new list<Property_Lease__c>();
        for(Property__c prop : props)
            propLeases.add(new Property_Lease__c(Lease__c=lease.Id, Property__c=prop.Id));
        insert propLeases;
    
        Test.startTest();
        
        // set initial page and controller instance
        PageReference testPageReference = Page.MapSearch_Page; 
        map<string, string> params = testPageReference.getParameters();
        params.put(M2M2_Controller.PARAM_CONFIGNAME, configName);
        params.put(M2M2_Controller.PARAM_FROMID, lease.Id);
        params.put(M2M2_Controller.PARAM_FROMNAME, lease.Name);
        params.put(M2M2_Controller.PARAM_RETURL, '/'+lease.Id);
        Test.setCurrentPage(testPageReference);
        MapSearch_Controller testController = new MapSearch_Controller(new ApexPages.StandardController(lease));        // cover both custom and standard controller
        testController = new MapSearch_Controller();
        testController.myinitfunc();
        system.assertEquals(false, ApexPages.hasMessages(), 'Error: VF page/controller initialization has errors - ' + testController.concatenateApexPagesMessages());
        
        // test callouts
        list<MapSearch_Helper.ProfileInfo> testProfiles = getProfilesByPortions(configName, '' + lease.id); 
        system.assertEquals(5, testProfiles.size(), 'Error: GetProfilesByPortions did not return correct number of profiles.');
    
        Test.stopTest();
    }
}