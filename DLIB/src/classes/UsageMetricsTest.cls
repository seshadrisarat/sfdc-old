@isTest 
private class UsageMetricsTest {

    // Used for creating test data 
    private static final integer NUMBER_SUBSCRIBER_ORGS = 10;
    private static final integer NUMBER_RESOURCES = 5;
  
    /* Tests we can create a controller object and run with defaults.  No Data found message is displayed  */
    static testMethod void testQueryWithNoResults() {
       MDFQueryController mdfController = new MDFQueryController();
       System.assert(mdfController!=null, 'MDFQueryController should not be null'); 
       // runs initial query to get page data. Shouldn't get any results 
       mdfController.runQuery();      
       System.assert(mdfController.noDataFoundMessage.equals(System.Label.UM_noDataFound), 'no data found message should be populated');
    }
    
     /* Tests we get the correct amount of options from the controller  */
     static testMethod void testGetControllerOptions() {
       MDFQueryController mdfController = new MDFQueryController();
       System.assert(mdfController!=null, 'MDFQueryController should not be null'); 
       System.assert(mdfController.getAllMetricsTypes().size() == 2, 'Should have 2 metrics types options');
       System.assert(mdfController.getChartingOptions().size() == 4, 'Should have 4 charting options');
       System.assert(mdfController.getDateRanges().size() == 3, 'Should have 3 date ranges');
       System.assert(mdfController.getOrgStatusList().size() == 4, 'Should have 4 org status options');
     }
    
    /* Tests we can create a MetricsData file with no data (i.e. Heartbeat entry) and get a single result  */
      static testMethod void testQueryWithHeartBeatResult() {
       // Make an MDF file with all fields but no file
       MetricsDataFile mockMdf = createMockMdf(getDate(), 'Visualforce', false);
       MDFDataManager mgr = new MDFDataManager();
       Set<String> statusSet = new Set<String>();
       statusSet.add('TRIAL');
       mgr.processResourceData(mockMdf, null,  statusSet);
       System.assert(mgr.resourceCounts.size() == 1, 'expected one resource count');
    }
    
     /* Tests we can create a MetricsData file with subscriber data for Visualforce Pages and get the correct results  */
     static testMethod void testVFQueryWithResults() {
       // Make an MDF file with all fields including some metrics data
       MetricsDataFile mockMdf = createMockMdf(getDate(), 'Visualforce', true);
       MDFDataManager mgr = new MDFDataManager();
       Set<String> statusSet = new Set<String>();
       statusSet.add('ACTIVE');
       statusSet.add('TRIAL');
       statusSet.add('FREE');
       // Use any status but no org specified org id
       mgr.processResourceData(mockMdf, null, statusSet);  
       validateQueryData(mgr, mockMdf);
       mgr.buildAppropriateDataTables(System.Label.UM_totalVFPageViews);
       String totalVFPageData = mgr.getSeriesData(System.Label.UM_totalVFPageViews);
       System.assert(totalVFPageData!=null && totalVFPageData.contains('Total Pageload Count') && totalVFPageData.contains('new Date'),
          'Total VF page results data not complete, results :'+totalVFPageData);
        mgr.buildAppropriateDataTables(System.Label.UM_top5VFPages);
        String top5VFPageData = mgr.getSeriesData(System.Label.UM_top5VFPages);
        System.assert(top5VFPageData!=null && top5VFPageData.contains('mockPage0') && top5VFPageData.contains('new Date'),
          'Top 5 VP page results data not complete, results :'+top5VFPageData);
       System.assert(mgr.datesProcessedSingleOrg.size() == 0 , 'single org processing should not have occured for a multi org search'); 
       
       // now perform a new search based on specific sub org that exists
       mgr = new MDFDataManager();
       mgr.processResourceData(mockMdf, '00DxxMOCKORG1', statusSet);  
       validateQueryData(mgr, mockMdf);
       System.assert(mgr.datesProcessedSingleOrg.size() > 0 , 'single org processing should add at least 1 org in this map'); 
    }
    
     /* Tests we can create a MetricsData file with subscriber data for Custom Obect counts and get the correct results  */
     static testMethod void testObjCountQueryWithResults() {
       MetricsDataFile mockMdf = createMockMdf(getDate(), 'CustomObject', true);
       MDFDataManager mgr = new MDFDataManager();
       Set<String> statusSet = new Set<String>();
       statusSet.add('ACTIVE');
       statusSet.add('TRIAL');
       statusSet.add('FREE');
       // search with a status set but no org specified
       mgr.processResourceData(mockMdf, null, statusSet);  
       validateQueryData(mgr, mockMdf);
       mgr.buildAppropriateDataTables(System.Label.UM_totalRecordCount);
       String totalRecordCountData = mgr.getSeriesData(System.Label.UM_totalRecordCount);
       System.assert(totalRecordCountData!=null && totalRecordCountData.contains('Total Record Count') && totalRecordCountData.contains('new Date'),
           'results data not complete, results :'+totalRecordCountData);
           
       System.assert(mgr.datesProcessedSingleOrg.size() == 0 , 'single org processing should not have occured for a multi org search'); 

       mgr.buildAppropriateDataTables(System.Label.UM_top5ObjCount);
       String top5RecordCountData = mgr.getSeriesData(System.Label.UM_top5ObjCount);
       System.assert(top5RecordCountData!=null && top5RecordCountData.contains('CustomObject0') && top5RecordCountData.contains('new Date'),
          'Top 5 VP page results data not complete, results :'+top5RecordCountData);
       // now perform a new search based on specific sub org that exists
       mgr = new MDFDataManager();
       mgr.processResourceData(mockMdf, '00DxxMOCKORG1', statusSet);  
       System.assert(mgr.datesProcessedSingleOrg.size() > 0 , 'single org processing should add at least 1 org in this map'); 
       validateQueryData(mgr, mockMdf);
       
    }
    
    /* Validates some of the results generated in the MDFDataManager  */
    private static void validateQueryData(MDFDataManager mgr, MetricsDataFile mockMdf){
       System.assert(mgr.resourceCounts.size() == 1, 'expected one resource count');
       System.assert(mgr.resourceNamesSeen.size() == NUMBER_RESOURCES, 'should have been '+NUMBER_RESOURCES +' resource names found but found ' + mgr.resourceNamesSeen.size());
       Map<String,Integer> objectsThisDay = mgr.resourceCounts.get(DateTime.newInstance(mockMdf.MetricsStartDate.yearGmt(), mockMdf.MetricsStartDate.monthGmt(), mockMdf.MetricsStartDate.dayGmt()));
       System.assert(objectsThisDay!=null, 'objectsThisDay map should not be null');
       System.assert(objectsThisDay.size()== NUMBER_RESOURCES, 'Should be ' +NUMBER_RESOURCES +' objects in the map since thats what we created but found '+objectsThisDay.size());
    }
    
    /*  Creates a MetricsDataFile for the specified date, type (Visualforce or CustomObject), and whether we should create a MDF file in entry.  Doesn't acutally save the file just creates a reference to it for testing.  */
     private static MetricsDataFile createMockMdf(DateTime myDate, String type, Boolean withFile){
       MetricsDataFile mockMdf = new MetricsDataFile();
       mockMdf.MetricsType = type;
       mockMdf.MetricsStartDate = myDate;
       mockMdf.MetricsEndDate = myDate;
       mockMdf.NamespacePrefix = 'MOCK_NAMESPACE';
       mockMdf.SendingInstance = 'xx';
       if (withFile){
          //create some metrics data to populate the MetricsDataFile field
          String dataFileText = createMetricsDataForNamespace(type);
          mockMdf.MetricsDataFile = Blob.valueOf(dataFileText);
          mockMdf.MetricsDataFileLength = 1;  //this is set internally, but anything greater than 1 is ok for testing
       }
       return mockMdf;
     }
     
     /* Creates a String representation of the MetricsDataFile field */
     private static String createMetricsDataForNamespace(String type) {
        String data = '';
        for(Integer subOrgCount = 0; subOrgCount < NUMBER_SUBSCRIBER_ORGS ; subOrgCount++){
           // add org id
           String orgIdToken =  '00D' + 'xx' + 'MOCKORG' + subOrgCount;
           // add org name
           String orgNameToken = 'Mock Org ' + subOrgCount;
           if (type == 'Visualforce'){
              data += generateLinesForEachPage(orgIdToken, orgNameToken);
           }
           else{
              data += generateLinesForEachObject(orgIdToken, orgNameToken);
           }
        }
       return data;
    }
    
    /* generates lines of visualforce page usage data for the MetricsDataFile field */
    private static String generateLinesForEachPage(String orgIdToken, String orgNameToken){
       final String pageName = 'apex/mockPage';
       final String orgEdition = 'Enterprise Edition';
       final String orgStatus = 'TRIAL';
       final String quote = '"';
       final String comma = ',';
       String allPagesforOrg = '';
       for(Integer pageCount = 0; pageCount < NUMBER_RESOURCES ; pageCount++){
           // add org id
           allPagesforOrg +=  quote + orgIdToken + quote + comma;
           // add org name
           allPagesforOrg +=  quote + orgNameToken + quote + comma;
           // add org edition
           allPagesforOrg +=  quote + orgEdition + quote + comma;
           // add org status
           allPagesforOrg +=  quote + orgStatus + quote + comma;
           // add page name
           allPagesforOrg +=  quote + pageName + pageCount + quote + comma;
           // add number times page was accessed (random number between 1-1000)
           Integer pageAccesses = Math.round(Math.random()*1000);
           allPagesforOrg +=  quote + string.valueOf(pageAccesses) + quote + comma;
           // add unique users
           Integer uniqueUsers = Math.round(Math.random()*100);
           allPagesforOrg +=  quote + string.valueOf(uniqueUsers) + quote + comma;
           // average load time in ms
           Integer loadTime = Math.round(Math.random()*100);
           allPagesforOrg +=  quote + string.valueOf(loadTime) + quote;
           // end the line
           allPagesforOrg += '\n';
       }
      return allPagesforOrg;
    }
    
    /* generates lines of visualforce page usage data for the MetricsDataFile field */
    private static String generateLinesForEachObject(String orgIdToken, String orgNameToken){
       final String orgEdition = 'Enterprise Edition';
       final String orgStatus = 'TRIAL';
       final String quote = '"';
       final String comma = ',';
       String allObjectCountforOrg = '';
       for(Integer objectCount = 0; objectCount < NUMBER_RESOURCES ; objectCount++){
           // add org id
           allObjectCountforOrg +=  quote + orgIdToken + quote + comma;
           // add org name
           allObjectCountforOrg +=  quote + orgNameToken + quote + comma;
           // add org edition
           allObjectCountforOrg +=  quote + orgEdition + quote + comma;
           // add org status
           allObjectCountforOrg +=  quote + orgStatus + quote + comma;
           // add page name
           allObjectCountforOrg +=  quote + 'CustomObject' + objectCount + quote + comma ;
            // add count - randon number between 1 and 1000
           Integer count = Math.round(Math.random()*1000);
           allObjectCountforOrg +=  quote + string.valueOf(count) + quote;
           // end the line
           allObjectCountforOrg += '\n';
       }
      return allObjectCountforOrg;
    }
    
    private static DateTime getDate(){
       DateTime dt = DateTime.now();
       DateTime myDate =  DateTime.newInstanceGmt(dt.yearGmt(), dt.monthGmt(), dt.dayGmt(),0,0,0);
       return myDate;
    }
    
    
}