public with sharing class MDFDataManager {

    private static final Pattern ORG_ID_INSTANCE_PATTERN = Pattern.compile('^\\w{3}(\\w{2})');
    
    // All data generated for the results is done internally.  The only data that could be user provided is the
    // pagename or object name (which should already be protected).  To be extra safe, lets just not allow anything
    // characters in this value that are not alphanumeric, underscore, period, or dash.
    private static final Pattern RESOURCE_NAME_INSTANCE_PATTERN = Pattern.compile('^[a-zA-Z0-9_.-]*$');
    
    public Set<String> resourceNamesSeen {get;set;} // this set is so that we always know what resources we've seen even if a specific day didn't see them    
    public Map<DateTime, Map<String,Integer>> resourceCounts;
    private Map<DateTime, Integer> dailyTotalCounts;
    private Map<String, Integer> visualforceTotalCounts; //grand total by page name    
    private Map<String, Integer> customObjectHighestCounts; //for each custom object, the highest daily count we've ever seen
    private List<String> namesOfTopResources;
    public Set<DateTime> datesProcessedSingleOrg; // Set of dates we've already processed. Can use this to shortcut some logic
    public String dataLabels;
    
    private Map<String, Set<String>> namespaceCache = new Map<String, Set<String>>();
    
    private MDFQueryDAO dao;
    
    //TODO: can set these in the constructor, using presence of new date field to determine if this is 190. Then we can handle presence/absence of version column
    public static final Integer SUBSCRIBER_ORG_ID_COLUMN = 0;
    public static final Integer SUBSCRIBER_STATUS_COLUMN = 3;
    public static final Integer RESOURCE_NAME_COLUMN_v30     = 4;
    public static final Integer RESOURCE_COUNT_COLUMN_v30    = 5;
    public static final Integer RESOURCE_NAME_COLUMN_v31     = 5;
    public static final Integer RESOURCE_COUNT_COLUMN_v31    = 6;
    
    public MDFDataManager(){
        this(new MDFQueryDAOImpl());
    }
    
    public MDFDataManager(MDFQueryDAO dao) {
        this.dao = dao;
        
        this.resourceNamesSeen = new Set<String>();
        this.datesProcessedSingleOrg = new Set<DateTime>();
        this.namesOfTopResources = new List<String>();
        this.resourceCounts = new Map<DateTime, Map<String,Integer>>();
        this.dailyTotalCounts = new Map<DateTime, Integer>();
        this.customObjectHighestCounts = new Map<String, Integer>();
        this.visualforceTotalCounts = new Map<String, Integer>();
    }
    
    public void clearAll(){
        this.resourceCounts.clear();
        this.resourceNamesSeen.clear();
        this.namesOfTopResources.clear();
        this.datesProcessedSingleOrg.clear();
    }
    
    public Set<String> findNamespacesForSubscriberOrg(String subscriberOrgId, String metricsType) {
        Set<String> orgSpecificNamespaces;
        
        if (namespaceCache.containsKey(subscriberOrgId)) {
            orgSpecificNamespaces = namespaceCache.get(subscriberOrgId);
        }
        else {
            orgSpecificNamespaces = new Set<String>();
            
            String instanceIdFromOrgId = extractOrgInstanceFromId(subscriberOrgId);
            /* let's always lookback through 30 days worth of data - its the max date range, 
             * don't want to exclude any apps that might have data */
            Date lookback = Date.today().addDays(-30);
 
            List<MetricsDataFile> dataToExtractNamespace = dao.findMDFs(instanceIdFromOrgId, lookback);
        
            MDFLineFilter filter = new MDFLineFilters.SubscriberOrgFilter(subscriberOrgId);
            MDFDataLineParser parser = new MDFDataLineParser();
            for (MetricsDataFile mdf : dataToExtractNamespace) {
                String ns = mdf.NamespacePrefix;
                MDFDataIterator dataIter = new MDFDataIterator(filter, parser, mdf);
                Iterator<MDFDataModel> iter = dataIter.iterator();
                if (iter.hasNext()) {
                    orgSpecificNamespaces.add(ns);
                }
            }
        }

        return orgSpecificNamespaces;
    }
    
    public Set<String> findNamespacesForAllSubscribers() {
        Set<String> namespaces;
        
        if (namespaceCache.containsKey(null)) {
            namespaces = namespaceCache.get(null);
        }
        else {
            namespaces = dao.findNamespaces();
        }
        
        return namespaces;
    }
    
    private String extractOrgInstanceFromId(String orgId) {
        Matcher m = ORG_ID_INSTANCE_PATTERN.matcher(orgId);
        if (m.find()) {
            return m.group(1);
        }
        else {
            return null;
        }
    }
    
    public void processResourceData(MetricsDataFile mdf, String requestedSubscriberOrgId, Set<String> requestedOrgStatusesSet){
    
 
       DateTime mdfDate = DateTime.newInstance(mdf.MetricsStartDate.yearGmt(), mdf.MetricsStartDate.monthGmt(), mdf.MetricsStartDate.dayGmt());
       if (requestedSubscriberOrgId != null && requestedSubscriberOrgId.length() > 0 && this.datesProcessedSingleOrg.contains(mdfDate)){
            // This means we have already found results for the specified subscriber org, no need to keep searching in other MDF files.
            system.debug(logginglevel.INFO,'shortcut processing for id: ' + requestedSubscriberOrgId + ' and date : ' + String.valueOf(mdfDate) + ' and instance: ' +  + mdf.SendingInstance);
            return;
       }        
           //system.debug(logginglevel.INFO,'processing an MDF for ' + String.valueOf(mdfDate) + ' and instance ' + mdf.SendingInstance);
       if (!resourceCounts.containsKey(mdfDate)){
           resourceCounts.put(mdfDate, new Map<String, Integer>());
       }
       if (mdf.MetricsDataFileLength > 0) {
           //more than a heartbeat, process it
           Map<String,Integer> objectsThisDay = resourceCounts.get(mdfDate);
           final String mdfString = mdf.MetricsDataFile.toString();
            
           
           // take the string and break it into substrings by each line
           integer beginindex = 0;
           integer endindex;
           do{
              endindex  = mdfString.indexof('\n', beginindex);
              if (endindex != -1)
              {
                 String line = mdfString.substring(beginindex, endindex);                 
                 List<String> fields = line.split(',');       
                 String subOrgId = fields.get(SUBSCRIBER_ORG_ID_COLUMN).substringBetween('"');
                 String subOrgStatus = fields.get(SUBSCRIBER_STATUS_COLUMN).substringBetween('"');
                 //system.debug(logginglevel.INFO, 'subOrgId:' + subOrgId + ' requestedSubscriberOrgId: ' + requestedSubscriberOrgId + ' requestedOrgStatusesSet size: ' + requestedOrgStatusesSet.size());
                  if ((string.isEmpty(requestedSubscriberOrgId) && requestedOrgStatusesSet.contains(subOrgStatus))
                        || (subOrgId.equals(requestedSubscriberOrgId))){
                   //if we are looking at multiple orgs via a status check, then we have to check for pre-existing entries and sum up
                   String objName;
                   Integer objCount;
                   // Safe Harbor rules apply, but we anticipate adding some new columns to the data format in Summer '14, and this conditional
                   // lets us process MDF objects created by Spring'14 or later releases on-the-fly.
                   if (fields.size() == 6 || fields.size() == 8){
                       objName = fields.get(RESOURCE_NAME_COLUMN_v30).substringBetween('"');
                       objCount = Integer.valueOf(fields.get(RESOURCE_COUNT_COLUMN_v30).substringBetween('"'));
                   } else { //Summer '14 or later
                       objName = fields.get(RESOURCE_NAME_COLUMN_v31).substringBetween('"');
                       objCount = Integer.valueOf(fields.get(RESOURCE_COUNT_COLUMN_v31).substringBetween('"'));
                   }
                   // take the path out of the objName, which may be there for VF pages
                   Integer lastSlash = objName.lastIndexOf('/');
                   if (lastSlash != -1){
                     objName= objName.substring(lastSlash+1, objName.length());
                   }
                   
                   // Don't accept resource names with special characters
                   if(RESOURCE_NAME_INSTANCE_PATTERN.matcher(objName).matches()) {
                        resourceNamesSeen.add(objName);
                   }
                   
                   if (string.isEmpty(requestedSubscriberOrgId) && objectsThisDay.containsKey(objName)){
                       Integer previousCount = objectsThisDay.get(objName);
                       //system.debug(logginglevel.INFO,'Updating: objName: ' + objName + ' previousCount: '+previousCount + ' objCount: '+ objCount);
                       objectsThisDay.put(objName, previousCount + objCount);
                   } else {
                       //we should only get a single report for a subscriber org, so we don't have to sum up object count, just put()
                       //system.debug(logginglevel.INFO,'Adding new: objName: ' + objName + ' objCount: '+ objCount);
                       objectsThisDay.put(objName,objCount);
                       if (subOrgId.equals(requestedSubscriberOrgId) && !this.datesProcessedSingleOrg.contains(mdfDate)){
                           // we don't need to process this date for any more entries, already found the one we're looking for.  
                           // keep track of the subscriber org id's we've processed already when searching by a subscriber org id, will allow us to shorcut this 
                           datesProcessedSingleOrg.add(mdfDate);
                           system.debug(logginglevel.INFO,'found required data for subscriber org: ' + requestedSubscriberOrgId + ' and date : ' +
                              String.valueOf(mdfDate) + ' on instance: ' +  + mdf.SendingInstance);
                       }
                   }
               }
                 // make the next begin index where we left off, plus 1 to get past the previous new line char
                 beginindex = endindex+1;
              }  
           }
           while (endindex != -1);
       }
    }
    
    private void buildDailyTotalCounts(){
        this.dailyTotalCounts.clear();
        Set<DateTime> datesKnown = resourceCounts.keyset();
        for(DateTime dt : datesknown) {
            Map<String,Integer> objectsThisDay = resourceCounts.get(dt);
            Integer dailySum = 0;
            for(Integer perObjectCount : objectsThisDay.values()){
                dailySum += perObjectCount;
            }
            dailyTotalCounts.put(dt,dailySum);
            // system.debug(logginglevel.INFO, 'putting ' + dailySum + ' in as value for ' + String.valueOf(dt));
        }
    }
    
    private void buildVisualforceTotalCounts(){
        this.visualforceTotalCounts.clear();
        for (String pageNameKnown : resourceNamesSeen){
            visualforceTotalCounts.put(pageNameKnown,0);
        }
        
        Set<DateTime> datesKnown = resourceCounts.keyset();
        for(DateTime dt : datesknown) {
            Map<String,Integer> objectsThisDay = resourceCounts.get(dt);
            for (String pageName : resourceNamesSeen) {
                if (objectsThisDay.containsKey(pageName)){
                    Integer previousValue = visualforceTotalCounts.get(pageName);
                    Integer todaysValue = objectsThisDay.get(pageName);
                    visualforceTotalCounts.put(pageName, previousValue + todaysValue);
                }
            }
        }
    }
    
    private void buildCustomObjectHighestCounts(){
        this.customObjectHighestCounts.clear();
        for (String objectNameKnown : resourceNamesSeen){
            customObjectHighestCounts.put(objectNameKnown,0);
        }
        
        Set<DateTime> datesKnown = resourceCounts.keyset();
        for(DateTime dt : datesknown) {
            Map<String,Integer> objectsThisDay = resourceCounts.get(dt);
            for (String objectName : resourceNamesSeen) {
                if (objectsThisDay.containsKey(objectName)){
                    Integer previousValue = customObjectHighestCounts.get(objectName);
                    Integer todaysValue = objectsThisDay.get(objectName);
                    customObjectHighestCounts.put(objectName, Math.max(previousValue,todaysValue));
                }
            }
        }
    }
    
    /**
      * returns the names and counts of the top five counts in the map. If map has <= 5 keys, then you just get the keys that exist
      * Note: No guarantees on which of the lowest-count resources will be excluded if there is an n-way tie for 5th place.
      */
    public Map<String,Integer> getTopFiveResources(Map<String,Integer> mapOfCounts){
        final Integer HOW_MANY = 5;
        if (mapOfCounts.size() <= HOW_MANY) {
            return mapOfCounts;
        }
        
        Map<String,Integer> candidates = new Map<String,Integer>();
        List<Integer> allCountValues = mapOfCounts.values();
        allCountValues.sort();
        Integer cutoffIndex = allCountValues.size() - HOW_MANY;
        Integer cutoffValue = allCountValues.get(cutoffIndex);
        
        //only consider resources whose count is >= cutoffValue as top-5 candidates
        for(String resource : mapOfCounts.keySet()){
            Integer value = mapOfCounts.get(resource);
            if (value >= cutoffValue){
                candidates.put(resource,value);
            }
        }
        
        if (candidates.size() > HOW_MANY){
            //can happen in case of n-way tie
            for(String resource : mapOfCounts.keySet()){
                Integer value = mapOfCounts.get(resource);
                if (value == cutoffValue){
                    candidates.remove(resource);
                }
                if (candidates.size() == HOW_MANY) break;
            }
        }           
        return candidates;
    }
    
    public void buildAppropriateDataTables(String chartingOption){
        buildDailyTotalCounts(); //same for VF and custom object
        namesOfTopResources.clear();
        if (chartingOption.equals(System.Label.UM_totalVFPageViews) || chartingOption.equals(System.Label.UM_top5VFPages)){
            namesOfTopResources.clear();
            if (chartingOption.equals(System.Label.UM_top5VFPages)) {
                buildVisualforceTotalCounts();
              namesOfTopResources.addAll(getTopFiveResources(visualforceTotalCounts).keySet());
              this.dataLabels = '[\'' + String.join(namesOfTopResources, '\',\'') + '\']';
            } else {
                dataLabels = '[\'Total Pageload Count\']';
            }
        } else {
              //custom object
            if (chartingOption.equals(System.Label.UM_top5ObjCount)) {
                buildCustomObjectHighestCounts();
                namesOfTopResources.addAll(getTopFiveResources(customObjectHighestCounts).keySet());
                this.dataLabels = '[\'' + String.join(namesOfTopResources, '\',\'') + '\']';
            } else {
                dataLabels = '[\'Total Record Count\']';
            }
        }
    }
    
    /*
     *  Returns an array of JS rows that can be fed to Google Charts API
     */    
    public String getSeriesData(String chartingOption){
        if(resourceCounts.isEmpty()) {
           // system.debug(logginglevel.INFO,'getSeriesData - returning EMPTY Array - should not normally happen');
            return '[]';
        }
        //system.debug(logginglevel.INFO,'getSeriesData - chartingOption=' + chartingOption);
        if (chartingOption.equals(System.Label.UM_top5VFPages) || chartingOption.equals(System.Label.UM_top5ObjCount)) {
            //top5
            //system.debug(logginglevel.INFO,'building Series Data for a top 5');
            return getSeriesDataForTopResources();
        } else {
            //daily total counts
           // system.debug(logginglevel.INFO,'building Series Data for a total');
            return getSeriesDataForTotalResources();
        }
    }
    
    /**
     * After the top-N resources have been identified, build a data set to pass to the charting engine.
     * The format is [date (as code for a new JS date), y1, y2, ...]
     */
    private String getSeriesDataForTopResources(){
      List<String> chartableData = new List<String>();
     // system.debug(logginglevel.INFO,'labelRow(top5): ' + dataLabels);
      chartableData.add(dataLabels);
      
      List<DateTime> datesKnown = new List<DateTime>();
      datesKnown.addAll(dailyTotalCounts.keyset());
      datesKnown.sort();
      for(DateTime dt : datesknown) {
          String thisRow = '[' + makeChartsFriendlyDate(dt);
          Map<String,Integer> objectsThisDay = resourceCounts.get(dt);
          for (String resourceName : namesOfTopResources) {
              if (objectsThisDay.containsKey(resourceName)){
                thisRow += ',' + objectsThisDay.get(resourceName);
              } else {
                thisRow += ',0';
              }
          }
          thisRow += ']'; //close row
         // system.debug(logginglevel.INFO,'thisRow(top5): ' + thisRow);
          chartableData.add(thisRow);
      }
      //system.debug(logginglevel.INFO,'getSeriesDataForTopResources - returning List of size: ' + chartableData.size());  
      return '[' + String.join(chartableData,',') + ']';
    }
    
    /**
     * The format is [date (as code for a new JS date), dailytotal]
     */
    private String getSeriesDataForTotalResources(){
      List<String> chartableData = new List<String>();
     // system.debug(logginglevel.INFO,'labelRow(total): ' + dataLabels);
      chartableData.add(dataLabels);
      
      List<DateTime> datesKnown = new List<DateTime>();
      datesKnown.addAll(dailyTotalCounts.keyset());
      datesKnown.sort();
      for(DateTime dt : datesknown) {
          String thisRow = '[' + makeChartsFriendlyDate(dt) + ',' + String.valueOf(dailyTotalCounts.get(dt)) + ']';
          system.debug(logginglevel.INFO,'thisRow(total): ' + thisRow);
          chartableData.add(thisRow);
      }
      //system.debug(logginglevel.INFO,'getSeriesDataForTotalResources - returning List of size: ' + chartableData.size());  
      return '[' + String.join(chartableData,',') + ']';
    }
    
    /*
     * Helper method to turn an Apex DateTime into text that will parse into a new JavaScript Date
     */
    private String makeChartsFriendlyDate(DateTime dt){
        return 'new Date(' + String.valueOf(dt.yearGmt()) + ', ' + String.valueOf(dt.monthGmt() - 1) + ', ' + String.valueOf(dt.dayGmt()) + ')';
    }
}