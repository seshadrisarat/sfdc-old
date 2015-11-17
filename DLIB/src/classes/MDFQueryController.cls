public with sharing class MDFQueryController {
	
	public transient static final Pattern ORG_ID_PATTERNN = Pattern.compile('^00D\\w{12}$');
	
    private transient List<MetricsDataFile> queryHits; 

    public integer daysLookback {get; set;}
    public String requestedNamespace {get; set;}
    public String requestedMetricsType {get; set;}
    public String chartingOption {get; set;}
    public String dateRange {get; set;}
    public String orgSetting  {get; set;}
    public String requestedSubscriberOrgId {get; set;}
    private Set<String> requestedOrgStatusesSet;
    public String orgStatus {get; set;}
    
    public String reachedLimitsMessage {get; set;}
    public String noDataFoundMessage {get; set;}
    public String nothingSelectedMessage {get; set;}
    
    private MDFDataManager mgr;
    private MDFQueryDAO dao;
    
    public MDFQueryController() {
    	this.dao = new MDFQueryDAOImpl();
        this.mgr = new MDFDataManager(this.dao);
        
        // defaults and initializations
        this.orgStatus = System.Label.UM_anyStatus;
        this.chartingOption = System.Label.UM_totalVFPageViews;
        // defaulting to 0 days should allow no results unless we've selected a value and submit the form
        this.daysLookback = 0;
        this.requestedMetricsType = 'Visualforce';
        this.requestedOrgStatusesSet = new Set<String>();
        
         // Clear out messages before we validate
        this.reachedLimitsMessage = null;
        this.noDataFoundMessage = null; 
        this.nothingSelectedMessage = Label.UM_nothingSelected;
        
        getNamespaces();
      
    }
    
    private void executeQuery () {
        // build the variables to bind
        if (chartingOption.equals(System.Label.UM_totalVFPageViews) || chartingOption.equals(System.Label.UM_top5VFPages)){
           this.requestedMetricsType = 'Visualforce';
        } else {
           this.requestedMetricsType = 'CustomObject';
        }
        
        this.daysLookback = figureOutDaysLookbackFromDateRangeLabel(this.dateRange);
        Date lookback = Date.today().addDays(-Integer.valueOf(this.daysLookback));
        
        this.queryHits = dao.findMDFs(this.requestedMetricsType, this.requestedNamespace, lookback);
    }
    
    public void getPage(){    
        mgr.clearAll();  
        executeQuery();
        requestedOrgStatusesSet = buildStatusesSetFromOrgStatus(orgStatus);

        if (this.queryHits == null || queryHits.isEmpty()){
           this.noDataFoundMessage = System.Label.UM_noDataFound;
           return;
        }

         if (limits.getHeapSize() > limits.getLimitHeapSize()){
               // set error message and return;
               // This result set could be larger than the apex heap size limit depending on data volume
               // If expecting large volumes of data the query could be broken up so the heap size could be limited.
               system.debug(logginglevel.INFO, 'Exceeded heap limit with query, current heap size in bytes:'+limits.getHeapSize() + 'heap limit:'+ limits.getLimitHeapSize());
               this.reachedLimitsMessage = 'Heap limit reached due to large volume of data. Choose a smaller time range and try again.';
               return;
         } 
        
        for(MetricsDataFile m: this.queryHits){ 
            // processing this result set could potentially take longer than the current apex limits based on the amount
            // of metrics date returned for the time period.  If expecting large volumes of data perhaps the query could be 
            // broken up so the search time could be limited.
            if (limits.getCpuTime() > limits.getLimitCpuTime()){
               system.debug(logginglevel.INFO, 'Exceeded CPU time limit with query, current CPU time in milliseconds:'+limits.getCpuTime() + 'CPU limit:'+ limits.getLimitCpuTime());
               // set error message and return;
               this.reachedLimitsMessage = 'CPU time limit reached due to large volume of data. Choose a smaller time range and try again.';
               return;
            }         
            mgr.processResourceData(m,requestedSubscriberOrgId,requestedOrgStatusesSet);
        }
        mgr.buildAppropriateDataTables(this.chartingOption);
    }

	/**
	 * Translate the value in the org status select into a Set of valid 
	 * org statuses
	 */
    private Set<String> buildStatusesSetFromOrgStatus(String orgStatus){
      Set<String> statusSet = new Set<String>();
      if (orgStatus.equals(System.Label.UM_anyStatus)){
        statusSet.add('ACTIVE');
        statusSet.add('TRIAL');
        statusSet.add('FREE');
      } else if (orgStatus.equals(System.Label.UM_activeOnly)){
        statusSet.add('ACTIVE');
      } else if (orgStatus.equals(System.Label.UM_trialOnly)){
        statusSet.add('TRIAL');
      } else if (orgStatus.equals(System.Label.UM_freeOnly)){
        statusSet.add('FREE');
      }
      
      return statusSet;
    }
    
    
    public String getSeriesData(){
        return mgr.getSeriesData(this.chartingOption);
    }
        
    public void runQuery() {
        // clear out any messages that may have been present in previous searches
        this.reachedLimitsMessage = null;
        this.noDataFoundMessage = null;
        this.nothingSelectedMessage = null;
        getPage();
    }


    
    private Integer figureOutDaysLookbackFromDateRangeLabel(String dateRange){
        if (string.isEmpty(dateRange)){
          return 0;
        }
        else if(dateRange.equals(System.Label.UM_defaultDateLabel) || dateRange.equals(System.Label.UM_last30Days)) {
            return 30;
        } else if (dateRange.equals(System.Label.UM_last7Days)) {
            return 7;
        }
         else {
            return 2;
        }
    }
    
    public List<SelectOption> getAllMetricsTypes() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Visualforce','Visualforce')); 
        options.add(new SelectOption('CustomObject','Custom Objects')); 
        return options;
    }
    
    public List<SelectOption> getChartingOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(System.Label.UM_totalVFPageViews, System.Label.UM_totalVFPageViews));
        options.add(new SelectOption(System.Label.UM_top5VFPages, System.Label.UM_top5VFPages));
        options.add(new SelectOption(System.Label.UM_totalRecordCount, System.Label.UM_totalRecordCount)); 
        options.add(new SelectOption(System.Label.UM_top5ObjCount, System.Label.UM_top5ObjCount)); 
        return options;
    }
    
     public List<SelectOption> getDateRanges() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(System.Label.UM_last30Days, System.Label.UM_last30Days));
        options.add(new SelectOption(System.Label.UM_last7Days, System.Label.UM_last7Days));
        options.add(new SelectOption(System.Label.UM_last2Days, System.Label.UM_last2Days));
        return options;
    }
    
    public List<SelectOption> getOrgStatusList() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(System.Label.UM_anyStatus, System.Label.UM_anyStatus));
        options.add(new SelectOption(System.Label.UM_activeOnly, System.Label.UM_activeOnly));
        options.add(new SelectOption(System.Label.UM_trialOnly, System.Label.UM_trialOnly));
        options.add(new SelectOption(System.Label.UM_freeOnly, System.Label.UM_freeOnly)); 
        return options;
    }
    
    public List<SelectOption> getNamespaces() {
    	Set<String> validNamespaces;
    	
    	/* present the user with the correct list of namespaces
    	 * - we want to show a list that is only relevant for the specified subscriber org if a single org is selected
    	 * - otherwise show them all namespaces this org collects metrics for */
    	if (validateOrgId(this.requestedSubscriberOrgId)) {
    		validNamespaces = mgr.findNamespacesForSubscriberOrg(this.requestedSubscriberOrgId, this.requestedMetricsType);
    		if (validNamespaces == null || validNamespaces.size() == 0) {
    			/* this is sort of a fallback in case we don't find anything, (we're basing the instance we search based
    			 * on what is encoded in the org id, so it's possible that is not correct and there won't be any results)
    			 * we'll still present the user with all namespaces */
    			 validNamespaces = mgr.findNamespacesForAllSubscribers();
    		}
    	}
    	else {
    		validNamespaces = mgr.findNamespacesForAllSubscribers();
    	}
    	
    	/* present the user the namespaces in name sorted order */
    	List<String> sortedNamespaces = new List<String>(validNamespaces);
    	sortedNamespaces.sort();

		/* build and return the options based on the correct list of namespaces */
        List<SelectOption> options = new List<SelectOption>(); 
        for(String ns : sortedNamespaces) {
          options.add(new SelectOption( ns, ns ));
        }
        
        if (options.size() == 0) {
           /* add an option saying there are not any namespaces */
           options.add(new SelectOption('None','No Apps Available')); 
        }
        
        /* default the actively selected namespace to the first one in the list */
		if (sortedNamespaces.size() > 0) {
			this.requestedNamespace = sortedNamespaces.get(0);
		}
        
        return options;
    }
    
    public void changeNamespaceSelectOptions() {
    	/* load up the namespaces for the specified org in the cache so when the app select gets rerendered the data will be there */
    	if (validateOrgId(this.requestedSubscriberOrgId)) {
    		mgr.findNamespacesForSubscriberOrg(this.requestedSubscriberOrgId, this.requestedMetricsType);
    	}
    }
    
    private Boolean validateOrgId(String orgId) {
    	Boolean valid = false;
    		
    	if (orgId != null) {
    		Matcher m = ORG_ID_PATTERNN.matcher(orgId);
			valid = m.matches();
    	}
    	
    	return valid;
    }
}