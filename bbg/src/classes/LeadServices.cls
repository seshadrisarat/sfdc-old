/*
Developer   : Poundarik, Shruti
Company     : Bluewolf LLC

Modified By : Angela
Date : 08/25/2012
changes : new method populateLeadGeoFields

Modified By : Ruivo, Tiago
Date : 12/12/2013
Changes : Added funtionality to update consumer action's boat_owner__c when lead is converted

Modified By: Jay, Tiago
Date: 5/16/2014
Changes : As a User I would like to ensure that the Lead routing code only applies to certain Lead Recordtypes

Modified By:  Johnson, David
Davte:  2/10/2015
Changes:  JIRA issue BS-108

Modified By:  Hickman, David
Date:  3/09/2015
Changes:  JIRA issue BS-143
*/
public with sharing class LeadServices {
    private final static decimal LEAD_SCORE_THRESHOLD = 50;
    public static boolean disableTriggerProcessing = false;
    final static String CLASSNAME = '\n\n**** LeadServices.METHODNAME()';
    @TestVisible final static String NO_GEO_RESULTS_MSG = 'No Matching Results Found';
    public static Boolean ranPopulateLeadGeoFields = False;
    public static Boolean routedToDealers = False;
    public static Boolean ranPopulateAccountGeoFields = False;
    public static boolean legacyLeadRouting = true;
    public static final set<string> legacyBrandCodes = new set<string>{'TR','BL','MX'}; 
    private static Map<Id, String> leadStateCodeMap = new Map<Id, String>();
    public static String brandCode;
    public static Boolean isBatch=System.isBatch(); 
    public static Boolean leadRoutingIsRunning = False;
    
    public static Boolean leadGeoNamesWebServiceIsRunning = false;
    public static Boolean leadGeoNamesWebServiceIsFutureRunning = false;
    public static Boolean leadFootstepsWebServiceIsRunning = false;
    public static Boolean bypassTaskTrigger = false;
    public static Integer MAX_LEAD_BATCH_SIZE = 10;
    
    public static Map<Id, RecordType> allowedLeadRecordTypes {
        get{
            
            if (allowedLeadRecordTypes == null){
                allowedLeadRecordTypes = new Map<Id, RecordType>([Select
                                                                  Id,
                                                                  DeveloperName
                                                                  From RecordType
                                                                  Where DeveloperName IN :LeadRoutingAllowedRecordTypes__c.getAll().keySet()
                                                                  AND SObjectType = 'Lead']);
            }
            system.debug('allowed record types looks like: ' + allowedLeadRecordTypes);
            return allowedLeadRecordTypes;
        }
        set;
    }
    
    public static Map<String,Lead_Routing_Do_Not_Send__c> LEAD_DO_NOT_SEND {
        // get the custom settings that dictate whether a lead should be sent to a dealer or not
        get {
            if (LEAD_DO_NOT_SEND == null) {
                LEAD_DO_NOT_SEND = Lead_Routing_Do_Not_Send__c.getAll();
            }
            return LEAD_DO_NOT_SEND;
        }
        set;
    }
    
    //BS-246 - Lead Services - AsyncApexExecutions Limit Error
    public static Id GEONAMES_BATCH_CLASS_ID {
    	//Get the Id of the GeonamesErrorHandlingBatch job.  Used later to determine if the job is 
    	//currently running (preparing / processing)
    	get {
	    	if (GEONAMES_BATCH_CLASS_ID == null) {
	    		GEONAMES_BATCH_CLASS_ID = [Select a.Id From ApexClass a Where Name = 'GeonamesErrorHandlingBatch'].Id;
	    	}
	    	return GEONAMES_BATCH_CLASS_ID;
    	}
    	set;	
    }
    
    //BS-267 - New Lead - Do Not Send Emails to Dealers
    private static boolean isUserLoadingBatch {
    	get {
    		if (isUserLoadingBatch == null) {
    			isUserLoadingBatch = [Select Importing_Leads__c From User Where id = :UserInfo.getUserId()].Importing_Leads__c;
    			
    			if (isUserLoadingBatch == null) {
    				isUserLoadingBatch = false;
    			}
    		}
    		return isUserLoadingBatch;
    	}
    	set;
    }
    
    public static Lead_Form_Settings__c getLeadFormSetting(string brand, string leadFormName) {
    	for (Lead_Form_Settings__c lfs : Lead_Form_Settings__c.getAll().values()) {
			if (lfs.Brand_Code__c.equalsIgnoreCase(brand) && lfs.Lead_Form_Name__c.equalsIgnoreCase(leadFormName)) {
				return lfs;
			}
    	}
    	return null;
    }
    
    public static boolean isLeadSendable(String leadBrandCode, String leadFormName) {
        for(Lead_Routing_Do_Not_Send__c dns : LEAD_DO_NOT_SEND.values()){
            if(leadBrandCode == dns.get('Brand_Code__c') && leadFormName == dns.get('Lead_Form_Name__c')){
                system.debug('Lead routing do not send for brand code: ' + leadBrandCode + ' and form name: ' + leadFormName + ' = NOT SENDABLE');
                return false;
            }
        }
        system.debug('Lead routing do not send for brand code: ' + leadBrandCode + ' and form name: ' + leadFormName + ' = SENDABLE');
        return true;
    }
    
    /*
    * BS-229 - Modify existing new lead logic (Consumer Actions)
    * David Hickman
    */
    public static Map<String, Id> taskRecordTypesByBrand {
        get{
            
            if (taskRecordTypesByBrand == null){
                taskRecordTypesByBrand = new Map<String, Id>();
                
                for (RecordType rt : [Select Id, DeveloperName From RecordType Where SobjectType = 'Task']) {
                	
                	if (rt.DeveloperName.equalsIgnoreCase('Bayliner_Task')) {
                		taskRecordTypesByBrand.put('BL', rt.Id);
                	} else if (rt.DeveloperName.equalsIgnoreCase('Boston_Whaler_Task')) {
                		taskRecordTypesByBrand.put('BW', rt.Id);
                	} else if (rt.DeveloperName.equalsIgnoreCase('Crestliner_Task')) {
                		taskRecordTypesByBrand.put('CL', rt.Id);
                	} else if (rt.DeveloperName.equalsIgnoreCase('Maxum_Task')) {
                		taskRecordTypesByBrand.put('MX', rt.Id);
                	} else if (rt.DeveloperName.equalsIgnoreCase('Meridian_Yachts_Task')) {
                		taskRecordTypesByBrand.put('MD', rt.Id);
                	} else if (rt.DeveloperName.equalsIgnoreCase('Sea_Ray_Task')) {
                		taskRecordTypesByBrand.put('SR', rt.Id);
                	} else if (rt.DeveloperName.equalsIgnoreCase('Trophy_Task')) {
                		taskRecordTypesByBrand.put('TR', rt.Id);
                	} else {
                		system.debug('Unknown branded task type found, Id: ' + rt.Id);
                	}                	
                }
            }
            system.debug('task record types by brand: ' + taskRecordTypesByBrand);
            return taskRecordTypesByBrand;
        }
        set;
    }
    
    /*
    * Sets the flags that will enable geocoding for new leads
    */
    public static void markNewLeadsForGeocodingRetryIfTooManyLeads(list<Lead> newLeads) {
    	if (newLeads.size() > MAX_LEAD_BATCH_SIZE &&
    		!DisableLeadRoutingTrigger__c.getInstance('LeadRouting').Disabled__c && 
            !LeadServices.isBatch && 
            !System.isFuture()) {
	    	for (Lead lead : newLeads) {
	    		lead.Geonames_Retry__c = true;
	    	}
        }       
    }
    
    public static void scheduleGeocodingJobIfTooManyLeads(list<Lead> leads) {
   		if (leads.size() > MAX_LEAD_BATCH_SIZE &&
    		!DisableLeadRoutingTrigger__c.getInstance('LeadRouting').Disabled__c && 
            !LeadServices.isBatch && 
            !LeadServices.leadGeoNamesWebServiceIsRunning &&
            !System.isFuture()) {
            LeadServices.leadGeoNamesWebServiceIsRunning = true;
        	runGeocodingBatchJobIfNotAlreadyRunning();	    	
        } 	
    }
    
    public static void geocodeLeadsIfNotTooMany(map<Id, Lead> leadMap) {
    	if (leadMap.size() <= MAX_LEAD_BATCH_SIZE && 
    		!System.isFuture() &&
    		!leadGeoNamesWebServiceIsFutureRunning &&
            LeadServices.ranPopulateLeadGeoFields == False &&
            !DisableLeadRoutingTrigger__c.getInstance('LeadRouting').Disabled__c  && 
            !LeadServices.isBatch) {
         	leadGeoNamesWebServiceIsFutureRunning = true;
         	
         	boolean disableEmail = (!PardotAssignment.currentUserIsPardotUser() && !DealerRouter.currentUserIsRoutingIntegrationUser());
         	populateLeadGeoFields(leadMap.keySet(), false, disableEmail);	   	
         }
    }
    
    public static void assignDealersToLeadsIfNotGeocodingButScoreOrAssignmentDataHasChanged(map<Id, Lead> oldMap, map<Id, Lead> newMap) {
    	set<Id> leadIdsToRoute = new set<Id>();
    	
    	LeadRouter leadRouter = new LeadRouter();
    	
    	for (Id leadId : newMap.keySet()) {
    		Lead newLead = newMap.get(leadId);
    		Lead oldLead = oldMap.get(leadId);
    		
    		// Only consider leads that have not been marked for geocoding or that do not need to be geocoded
    		if (!newLead.Geonames_Retry__c && !leadAddressHasChanged(oldLead, newLead)) {
    			if (leadScoreHasChangedEnoughToRequireRouting(oldLead, newLead) || leadRouter.objectDataChangeRequiresRouting(oldLead, newLead)) {
    				system.debug('lead ' + newLead.Id + ' has data that has changed in a way to require routing');
    				// If we have legacy routing enabled then we have a different set of rules to consider
    				if (!legacyLeadRouting || !legacyBrandCodes.contains(newLead.Brand_Code__c)) {
    					leadIdsToRoute.add(newLead.Id);
    				}
    			}	
    		}
    	}
    	
    	if (!leadIdsToRoute.isEmpty()) {
    		boolean oldDoNotSendEmail = DealerRouter.doNotSendEmail;
    		
    		// If the current user is not a pardot user then we want to disable sending of email and 
    		// footsteps
    		if (!PardotAssignment.currentUserIsPardotUser() && !DealerRouter.currentUserIsRoutingIntegrationUser()) {
    			system.debug('Disabling sending of email and footsteps because the current user is not a pardot user or routing integration user');
    			DealerRouter.doNotSendEmail = true;	
    		}
    		
    		routeLeads(getLeadsForRouting(leadIdsToRoute));	
    		
    		system.debug('Setting router doNotSendEmail back to ' + oldDoNotSendEmail);
    		DealerRouter.doNotSendEmail = oldDoNotSendEmail;
    	}
    }
    
    public static void geocodeLeadsIfNotTooManyAndAddressHasChanged(map<Id, Lead> oldMap, map<Id, Lead> newMap) {
    	if (newMap.size() <= MAX_LEAD_BATCH_SIZE && 
    		!System.isFuture() &&
    		!leadGeoNamesWebServiceIsFutureRunning &&
            LeadServices.ranPopulateLeadGeoFields == False &&
            !DisableLeadRoutingTrigger__c.getInstance('LeadRouting').Disabled__c  && 
            !LeadServices.isBatch) {
        	set<Id> leadsToGeocode = new set<Id>();
        	
        	for (Id leadId : newMap.keySet()) {
       			Lead oldLead = oldMap.get(leadId);
       			Lead newLead = newMap.get(leadId);
       			
       			if (leadAddressHasChanged(oldLead, newLead)) {
       				leadsToGeocode.add(newLead.Id);	
       			}
        	}
        	
        	if (!leadsToGeocode.isEmpty()) {
        		boolean disableEmail = (!PardotAssignment.currentUserIsPardotUser() && !DealerRouter.currentUserIsRoutingIntegrationUser());
        		populateLeadGeoFields(leadsToGeocode, false, disableEmail);	 	
        	}   	
        }
    }
    
     public static void updateConsumerActionBoatOwnersForConvertedLeads(map<Id, Lead> oldLeadsMap, map<Id, Lead> newLeadsMap) {
    	if (!oldLeadsMap.isEmpty()) {
	    	list<Id> convertedLeads = filterConvertedLeads(oldLeadsMap, newLeadsMap);
	    	if (!convertedLeads.isEmpty()) {
	    		system.debug('A total of ' + convertedLeads.size() + ' converted leads');
		    	list<ConsumerActions__c> consumerActionsToUpdate = processConsumerActions(convertedLeads);
		    	if (!consumerActionsToUpdate.isEmpty()) {
		    		system.debug('A total of ' + consumerActionsToUpdate.size() + ' consumer actions to update');
		    		updateConsumerActions(consumerActionsToUpdate, newLeadsMap);
		    	}
	    	}
    	}
    }
    
    /*
    * Creates consumer actions for new leads that are not SeaRay or Meridian
    */
    public static void createConsumerActionsForLeads(list<Lead> updatedLeads) {
    	list<ConsumerActions__c> consumerActionsToInsert = new list<ConsumerActions__c>();
    	
    	for (Lead lead : updatedLeads) {
    		consumerActionsToInsert.add(createConsumerActionForLead(lead));	
    	}
    	
    	if (!consumerActionsToInsert.isEmpty()) {
    		insert consumerActionsToInsert;
    	}
    }
    
    /*
    * Creates a consumer action for a new lead
    */
    private static ConsumerActions__c createConsumerActionForLead(Lead lead) {
        ConsumerActions__c ca = new ConsumerActions__c();
        ca.Lead_Name__c = lead.Id;
        ca.Name = lead.Type_of_Inquiry__c;
        ca.Lead_Form_Name__c = lead.Lead_Form_Name__c;
        ca.Lead_Source__c = lead.LeadSource;
        ca.Model_Year__c = lead.Boat_Year_Interest__c;
        ca.Model__c = lead.Boat_Model_Interest__c;
        ca.Boat_Class__c =  lead.Boat_Class_Interest__c;
        ca.Time_Horizon__c = lead.Buying_horizon__c;
        ca.Action_Type__c = lead.Type_of_Inquiry__c;
        ca.Website__c = lead.Website;
        ca.Notes__c = lead.Notes__c;
        
        return ca;
    }   
    
    public static void markLeadsForGeodingRetryIfTooManyLeadsAndAddressHasChanged(map<Id, Lead> oldMap, map<Id, Lead> newMap) {
    	if( newMap.size() > MAX_LEAD_BATCH_SIZE && 
            !DisableLeadRoutingTrigger__c.getInstance('LeadRouting').Disabled__c && 
            !LeadServices.isBatch && 
            !System.isFuture()) {	
       		for (Id leadId : newMap.keySet()) {
       			Lead oldLead = oldMap.get(leadId);
       			Lead newLead = newMap.get(leadId);
       			
       			if (leadAddressHasChanged(oldLead, newLead)) {
       				newLead.Geonames_Retry__c = true;
       			}
       		}  	
    	}
    }
    
    private static boolean leadAddressHasChanged(Lead oldLead, Lead newLead) {
    	if (StringUtils.isNotEqualIgnoreCase(oldLead.PostalCode, newLead.PostalCode) ||
    		StringUtils.isNotEqualIgnoreCase(oldLead.Country, newLead.Country) ||
    		StringUtils.isNotEqualIgnoreCase(oldLead.City, newLead.City)) {
        	return true;
        } 
        return false;
    }
    
    /*
    * Checks if the pardot score has changed enough to enable routing to dealers
    */
    private static boolean leadScoreHasChangedEnoughToRequireRouting(Lead oldLead, Lead newLead) {
    	double oldScore = (oldLead.pi__Score__c == null) ? 0 : oldLead.pi__Score__c;
    	double newScore = (newLead.pi__Score__c == null) ? 0 : newLead.pi__Score__c;
        decimal scoreDiff = newScore - oldScore;
        return (scoreDiff >= LEAD_SCORE_THRESHOLD);
    }
    
    /*
    * BS-229 - Modify existing new lead logic (Consumer Actions)
    * Sea Ray and Meridian leads use tasks to track activities.  All other
    * lead brands use consumer actions.
    *
    * David Hickman
    */
    public static void createActivity(list<Lead> leadRecords){
    	List<Id> leadIds = new List<Id>();
    	List<Lead> consumerActionLeads = new List<Lead>();
    	List<Lead> taskLeads = new List<Lead>();
    	
    	//BS-258 - Contacts come in from Pardot as a lead, 
        //which triggers the leadtrigger.createactivity code.  The lead is subsequently converted 
        //to a person account and the lead id is no longer valid.  Resulting in an error in this code.
        for(Lead rec : leadRecords ){ 
        	leadIds.add(rec.id);
        }
        
        for(Lead rec : [Select l.Id, l.Type_of_Inquiry__c, l.Lead_Form_Name__c, l.Brand_Code__c, l.LeadSource, l.Boat_Year_Interest__c, l.Boat_Model_Interest__c, l.Boat_Class_Interest__c, l.Buying_horizon__c, l.Website, l.Notes__c From Lead l Where l.id in :leadIds And IsConverted = False And IsDeleted = False] ){
        	if (rec.Brand_Code__c.equalsIgnoreCase('SR') || rec.Brand_Code__c.equalsIgnoreCase('MD')) {
        		taskLeads.add(rec);
        	} else {
        		consumerActionLeads.add(rec);
        	}
        }
        
        if (!taskLeads.isEmpty()) {
        	createLeadTask(taskLeads);
        } 

		if (!consumerActionLeads.isEmpty()) {
        	createConsumerActionsForLeads(consumerActionLeads);
        }
    	
    }
    
    public static void createConsumerAction(list<Lead> leadRecords){
        list<ConsumerActions__c>consumerActions = new list<ConsumerActions__c>();
        
        for(Lead rec : leadRecords){ 
        	// BS-258 - SR and MD leads use activities and not consumer actions - MTR
        	if (!rec.Brand_Code__c.equalsIgnoreCase('SR') && !rec.Brand_Code__c.equalsIgnoreCase('MD')) {
	            ConsumerActions__c ca = new ConsumerActions__c();
	            ca.Lead_Name__c = rec.Id;
	            ca.Name = rec.Type_of_Inquiry__c;//rec.Name;
	            ca.Lead_Form_Name__c = rec.Lead_Form_Name__c;
	            ca.Lead_Source__c = rec.LeadSource;
	            ca.Model_Year__c = rec.Boat_Year_Interest__c;
	            ca.Model__c = rec.Boat_Model_Interest__c;
	            ca.Boat_Class__c =  rec.Boat_Class_Interest__c;
	            ca.Time_Horizon__c = rec.Buying_horizon__c;
	            ca.Action_Type__c = rec.Type_of_Inquiry__c;
	            ca.Website__c = rec.Website;
	            ca.Notes__c = rec.Notes__c;
	            consumerActions.add(ca);
        	}
	            
        }       
        
        if(!consumerActions.isEmpty())
            insert consumerActions;
    }    
    
    /*
    * BS-229 - Modify existing new lead logic (Consumer Actions)
    * David Hickman
    */
    private static void createLeadTask(list<Lead> leadRecords) {
    	list<Task> tasks = new list<task>();
    	
    	for(Lead lead : leadRecords){
    		Id taskRecordTypeId = taskRecordTypesByBrand.get(lead.Brand_Code__c);
    		String leadFormName = lead.Lead_Form_Name__c == null ? 'New Lead' : lead.Lead_Form_Name__c;
    		
    		if (taskRecordTypeId != null) {
	    		Task t = new Task();
	    		t.WhoId = lead.Id;
				t.Subject = lead.Brand_Code__c + ': ' + leadFormName;
				t.Status = 'Completed';
				t.RecordTypeId = taskRecordTypeId;
				t.Priority = 'Low';
				t.Description = 'Completed the ' + lead.Brand_Code__c + ': ' + leadFormName;
				t.ActivityDate = Date.today();
				t.Activity_Source__c = lead.LeadSource;
            	t.Boat_Model_Year__c = lead.Boat_Year_Interest__c;
            	t.Boat_Model__c = lead.Boat_Model_Interest__c;
            	t.Boat_Class__c =  lead.Boat_Class_Interest__c;
            	t.Time_Horizon__c = lead.Buying_horizon__c;
            	t.Action_Type__c = lead.Type_of_Inquiry__c;
            	t.Website__c = lead.Website;
            	t.Description = lead.Notes__c;
				
				tasks.add(t);
    		} else {
    			system.debug('Unable to determine task record type for brand: ' + lead.Brand_Code__c);
    		}
    	}
    	
    	if(!tasks.isEmpty()) {
    		bypassTaskTrigger = true;
            insert tasks;
    	}
    }
    
    public static List<Lead> filterIrrelevantRecordTypes(List <Lead> leads){
        List<Lead> filteredLeads = new List<Lead>();
        for (Lead l : leads){
            if (allowedLeadRecordTypes.keySet().contains(l.RecordTypeId )){
                filteredLeads.add(l);
            }
        }
        return filteredLeads;
    }
    
    // method to route Leads to the appropriate Dealers
    public static List<Lead> routeLeadsToAppropriateDealers(list<Lead> leadList, String bCode)
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'routeLeadsToAppropriateDealers');
        
        final String UNITED_STATES = 'US';
        final String CANADA = 'CA';
        
        List<Lead> leadListFiltered = filterIrrelevantRecordTypes(leadList);
        list<Lead> leadUpdateList = new list<Lead>();
        if(leadListFiltered != null && !leadListFiltered.isEmpty())
        {
            
            String brandInterest = [Select Brand_Code__c from Lead where id =:leadListFiltered[0].Id].Brand_Code__c;
            for(Lead l : leadListFiltered) {                   
                Boolean countyMatchFound;
                system.debug('COunty ='+l.County__c);
                map<String, list<Id>> CountiesToDealersMap = TerritoryServices.getCountiesToDealersMap(l.Brand_Code__c, leadStateCodeMap.get(l.Id), l.County__c);              
                if(l.Country_ISO_Code__c == UNITED_STATES) 
                {
                    if(CountiesToDealersMap.containsKey(l.county__c)){
                        system.debug('CountiesToDealersMap ='+CountiesToDealersMap);
                        list<Id> dealerList = uniqueIds(CountiesToDealersMap.get(l.county__c));
                        if(dealerList != null && dealerList.size()>0){
                            // update Lead fields with Dealer IDs - workflow will notify the dealers
                            l.Assigned_Dealer_1__c = dealerList[0];
                            if(dealerList.size()>= 2)
                                l.Assigned_Dealer_2__c = dealerList[1];
                            if(dealerList.size()>= 3)
                                l.Assigned_Dealer_3__c = dealerList[2];                          
                            leadUpdateList.add(l);
                            
                            countyMatchFound = true;
                        }
                    }else{
                        countyMatchFound = false;
                    }
                }else if(l.Country_ISO_Code__c == CANADA){
                    list<Territory__c> territoryList = TerritoryServices.findTerritoriesForCanada(l.PostalCode, l.Brand_Code__c, l.Country_ISO_Code__c);
                    list<Id> territoryNames = new list<Id>();
                    for(Territory__c eachTerritoryList :territoryList) {
                        territoryNames.add(eachTerritoryList.Dealer_Name__c);   
                    }
                    list<Id> uniqueDealerIds = uniqueIds(territoryNames);
                    if(uniqueDealerIds != null && uniqueDealerIds.size()>0) {                        
                        l.Assigned_Dealer_1__c = uniqueDealerIds[0];                         
                        if(uniqueDealerIds.size() >= 2)
                            l.Assigned_Dealer_2__c = uniqueDealerIds[1];
                        if(uniqueDealerIds.size() >= 3) 
                            l.Assigned_Dealer_3__c = uniqueDealerIds[2];
                    }else{                       // find by distance                       
                        TerritoryServices.MatchedDealers md = LeadServices.FindDealersByDistance(l, brandInterest);                        
                        if(md != null){
                            // update Lead fields with Dealer IDs - workflow will notify the dealers
                            l.Assigned_Dealer_1__c = md.DealerOneId;
                            l.Assigned_Dealer_2__c = md.DealerTwoId;
                            l.Assigned_Dealer_3__c = md.DealerThreeId;      
                            // add this Lead to the list to update
                            
                        }
                    } 
                    leadUpdateList.add(l);
                }
                system.debug('countyMatchFound ='+CountiesToDealersMap);
                if(( l.Country_ISO_Code__c != CANADA && l.Country_ISO_Code__c != UNITED_STATES) ||
                   (l.Country_ISO_Code__c == UNITED_STATES && countyMatchFound == false))
                {
                    system.debug('IN International');
                    // all other countries are by distance within the same country
                    TerritoryServices.MatchedDealers md = LeadServices.FindDealersByDistance(l, l.Brand_Code__c);
                    if(md != null){
                        system.debug('md ='+md);
                        // update Lead fields with Dealer IDs - workflow will notify the dealers
                        l.Assigned_Dealer_1__c = md.DealerOneId;
                        l.Assigned_Dealer_2__c = md.DealerTwoId;
                        l.Assigned_Dealer_3__c = md.DealerThreeId;                    
                        leadUpdateList.add(l);
                    }
                }
            }
        }
        return leadUpdateList; 
    }
    
    public static TerritoryServices.MatchedDealers FindDealersByDistance(Lead l, String brand){
        return TerritoryServices.findByDistance(l.Longitude__c, l.Latitude__c, brand, l.Country_ISO_Code__c);
    } 
    
    
    // Ensure one future call per web service per transaction
    public static void AutoPopulateGeoLocation(List<Lead> triggerNew, Map<Id, Lead> triggerNewMap, Map<Id, Lead> triggerOldMap,
                                                Boolean isAfter, Boolean isInsert, Boolean isUpdate){
        Boolean isBefore = !isAfter;
        
        if( triggerNew.size() > MAX_LEAD_BATCH_SIZE && 
            !DisableLeadRoutingTrigger__c.getInstance('LeadRouting').Disabled__c && 
            !LeadServices.isBatch && 
            !System.isFuture()) 
        {
            if (isBefore){
                if (isInsert){
                    LeadServices.prepareLeadGeoFieldsBatch(triggerNew);
                }
                else if (isUpdate){
                    final Map<Id,Lead> leadsToProcess = LeadServices.getLeadsWithChangedAddress(triggerOldMap, triggerNewMap);
                    LeadServices.prepareLeadGeoFieldsBatch(leadsToProcess.values());
                }
            }
            else if(isAfter){
                if (!LeadServices.leadGeoNamesWebServiceIsRunning){
                    LeadServices.leadGeoNamesWebServiceIsRunning = true;
                    LeadServices.runGeocodingBatchJobIfNotAlreadyRunning();
                }
            }
        }
        else if (triggerNew.size() <= MAX_LEAD_BATCH_SIZE && !System.isFuture()){
            
            if( !leadGeoNamesWebServiceIsFutureRunning &&
                LeadServices.ranPopulateLeadGeoFields == False &&
                !DisableLeadRoutingTrigger__c.getInstance('LeadRouting').Disabled__c  && 
                !LeadServices.isBatch) 
            {
                if(isAfter){
                	boolean disableEmail = (!PardotAssignment.currentUserIsPardotUser() && !DealerRouter.currentUserIsRoutingIntegrationUser());
                    if(isInsert){
                        leadGeoNamesWebServiceIsFutureRunning = true;
                        LeadServices.populateLeadGeoFields(triggerNewMap.keySet(), false, disableEmail);
                    }
                    else if(isUpdate){
                        final Map<Id,Lead> leadsToProcess = LeadServices.getLeadsWithChangedAddress(triggerOldMap, triggerNewMap);
                        if(!leadsToProcess.isEmpty()) {
                            leadGeoNamesWebServiceIsFutureRunning = true;
                            LeadServices.populateLeadGeoFields(leadsToProcess.keyset(), false, disableEmail);
                        }
                    }
                }   
            }
        }
    }
    
    /*
    public static void FootstepsLeadIntegration(List<Lead> triggerNew, Map<Id, Lead> triggerNewMap, Map<Id, Lead> triggerOldMap,
                                                Boolean isAfter, Boolean isInsert, Boolean isUpdate){
        Boolean isBefore = !isAfter;
        
        if( triggerNew.size() > FootstepsIntegrationServices.MAX_FOOTSTEPS_LEAD_BATCH_SIZE && 
            !LeadServices.isBatch && 
            !leadFootstepsWebServiceIsRunning && 
            !System.isFuture() &&
            FootstepsIntegrationServices.SEND_FOOTSTEPS_LEADS) 
        {
            if (isBefore){
                if (isInsert){
                    FootstepsIntegrationServices.prepareFootstepsLeadsBatch(triggerNew);
                }
                else if (isUpdate){
                    final Map<Id,Lead> leadsToProcess = FootstepsIntegrationServices.getLeadsWithChangedFootstepsFields(triggerOldMap, triggerNewMap);
                    FootstepsIntegrationServices.prepareFootstepsLeadsBatch(leadsToProcess.values());
                }
            }
            else if(isAfter){
                if (!leadFootstepsWebServiceIsRunning){
                    leadFootstepsWebServiceIsRunning = true;
                    FootstepsIntegrationServices.sendFootstepsLeadsBatch(FootstepsIntegrationServices.MAX_FOOTSTEPS_LEAD_BATCH_SIZE);
                }
            }
        }
        else if (triggerNew.size() <= FootstepsIntegrationServices.MAX_FOOTSTEPS_LEAD_BATCH_SIZE && 
                    !LeadServices.isBatch && !leadFootstepsWebServiceIsRunning && !System.isFuture() &&
                    FootstepsIntegrationServices.SEND_FOOTSTEPS_LEADS)
        {
            if(isAfter){
                if(isInsert){
                    leadFootstepsWebServiceIsRunning = true;
                    sendFootstepsLeads(triggerNewMap.keySet());
                }
                else if(isUpdate){
                    final Map<Id,Lead> leadsToProcess = FootstepsIntegrationServices.getLeadsWithChangedFootstepsFields(triggerOldMap, triggerNewMap);
                    if(!leadsToProcess.isEmpty()) {
                        leadFootstepsWebServiceIsRunning = true;
                        sendFootstepsLeads(leadsToProcess.keyset());
                    }
                }
            }
        }
    }
    */
    
    
    // method to call GeoWebService and populate Geo fields on Leads.
    //  --- web service future callouts ---
    
    @future (callout = true)  
    public static void populateLeadGeoFields(Set<ID> leadIDs, Boolean isAccount, boolean disableEmail)
    {
    	if (disableEmail) {
    		DealerRouter.doNotSendEmail = true;
    	}
        geoFieldsMakeCallout(leadIDs, isAccount);
    }
    
    @future (callout = true)  
    public static void sendFootstepsLeads(Set<ID> leadIDs)
    {
    	FootstepsService fsService = new FootstepsService();
        fsService.footstepsFieldsMakeCallout(leadIDs);
    }
    
    //  --- mark lead for web service batch processing ---
    public static void prepareLeadGeoFieldsBatch(List<Lead> leads){
        for (Lead l : leads){
            l.Geonames_Retry__c = true;
        }
    }
    
    //  --- call/execute web service batch  ---
    public static void runGeocodingBatchJobIfNotAlreadyRunning(){
    	
    	//BS-246 - Lead Services - AsyncApexExecutions Limit Error
    	//Check to see if the GeonamesErrorHandlingBatch is currently running (queued / preparing / processing)
    	if ([Select Count() From AsyncApexJob a Where a.ApexClassId = :GEONAMES_BATCH_CLASS_ID And Status In ('Preparing', 'Processing', 'Queued')] < 1) {
	        GeonamesErrorHandlingBatch batch = new GeonamesErrorHandlingBatch();
    	    Database.executeBatch(batch, MAX_LEAD_BATCH_SIZE);
    	}
        
    }
    
    //BS-251
    public static void geoFieldsMakeCallout(Set<ID> leadIDs, Boolean isAccount) {
    	geoFieldsMakeCallout(leadIDs, isAccount, true);
    }
    
    private static list<Lead> getLeadsForRouting(set<Id> leadIds) {
    	/*
    	* BS-230 - BS-225 - Modify Lead Routing Notifications To Include Lead Activities
    	* Find the maximum number of days worth of activities to report
    	*/ 
    	Integer maxTaskLimit = 0;
    	for (Pardot_Score_Increase_Trigger__c psit : LeadServices.pardotScoreIncreaseTriggers.values()) {
    		if (psit.Days_Of_Activities__c > maxTaskLimit) {
    			maxTaskLimit = psit.Days_Of_Activities__c.intValue();
    		}
    	}
    	if (maxTaskLimit == 0) {
    		maxTaskLimit = 7;
    	}
    	 return [
                SELECT 
                Id,
                Name,
                Brand_Code__c, 
                Lead_Emails_Sent__c,
                Street,
                City, 
                State,
                Country, 
                county__c,
                PostalCode,
                Phone,
                Home_Phone__c,
                Work_Phone__c,
                Email,
                Alternate_Email_Address__c,
                Lead_Form_Name__c,
                Type_of_inquiry__c,
                LeadSource, 
                latitude__c, 
                longitude__c, 
                GeoLocation__Latitude__s,
                GeoLocation__Longitude__s,
                GeoNames_WebService_Error__c,
                Country_ISO_Code__c,
                CreatedDate,
                Previous_Boat_Owner__c,
                Current_Owned_Brand__c,
                Current_Owned_Boat_Class__c,
                Currently_Owned_Year__c,
                Current_Owned_ID_Number__c,
                Boat_Model_Interest__c,
                Boat_Class_Interest__c,
                Boat_Category_of_Interest__c,
                Boat_Year_Interest__c,
                Interested_in_Stock_Number__c,
                Interested_in_Length__c,
                Interested_in_ID_Number__c,
                Buying_horizon__c,
                RecordTypeId,
                Notes__c,
                Geonames_Retry__c,
                LastModifiedDate,
                pi__score__c,
                (Select CreatedDate, Dealer__c, Pardot_Score__c From Assigned_Dealers__r order by CreatedDate desc),
                (Select t.Subject, t.LastModifiedDate, t.WhoId From Tasks t Order By t.LastModifiedDate Desc Limit :maxTaskLimit)  //BS-225
                FROM Lead 
                WHERE id in: leadIds AND IsConverted=false
                AND RecordTypeId in :allowedLeadRecordTypes.keySet()];
    }
    
    // --- execute the actual callouts per lead
    public static void geoFieldsMakeCallout(Set<ID> leadIDs, Boolean isAccount, Boolean routeToDealers) {
        final String UNITED_STATES = 'US';
        final String CANADA = 'CA';
        String leadCountry = '';
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'populateLeadGeoFields');
    	
        list<Lead> leadUpdateList = new List<Lead>();
        list<Lead> resultsNotFoundLeadList = new List<Lead>();  
        //list<Lead> leadList = [SELECT Id,Brand_Code__c, Lead_Emails_Sent__c,postalcode,country, City, State, county__c, latitude__c, longitude__c, GeoNames_WebService_Error__c,Country_ISO_Code__c FROM Lead WHERE id in: leadIDs];               
        for(Lead l : getLeadsForRouting(leadIDs)) {
                map<String, String> leadFieldsMap = new map<String, String>();   
                leadFieldsMap.clear();
                
                leadCountry = l.country;
                
                system.debug('Lead Details - Id: ' + l.Id + ', Lead Name: ' + l.Name + ', Lead Source: ' + l.LeadSource + ', Lead Email: ' + l.Email );

                //BS-143
                //Check for a valid country code
                system.debug('Checking for valid country code.  Current lead country = ' + leadCountry);
                if (!countryISOLookupByCode.containsKey(leadCountry)) {
                    system.debug('Lead country is not a code.  Attempting lookup by name');
                    if (countryISOLookupByName.containsKey(leadCountry)) {
                        leadCountry = countryISOLookupByName.get(leadCountry);
                        l.Country_ISO_Code__c = leadCountry;
                        system.debug('Assigned lead country code = ' + leadCountry);
                    }
                }
                 
                if(leadCountry != null && l.postalcode != null) {
                	String cleanedPostalCode = ''; 
                    if(l.postalcode.Contains('-')){
                    	cleanedPostalCode = l.postalcode.subString(0,5);
                    }else{
                        cleanedPostalCode = l.postalcode;    
                    }
                    system.debug('CleanedPostalCode: '+ EncodingUtil.urlEncode(cleanedPostalCode,'UTF-8'));
                    system.debug('country '+leadCountry);
                    leadFieldsMap = GeoNamesWebService.getLocationInfo(EncodingUtil.urlEncode(cleanedPostalCode,'UTF-8'), leadCountry,null, false);
                       
                }
                system.debug('**IN***'+leadFieldsMap.values().isEmpty());
                if(leadFieldsMap.values().isEmpty() && l.city != null){                    
                    system.debug('**IN***'); 
                    system.debug('**IN*** leadFieldsMap.values().isEmpty()'); 
                    leadFieldsMap = GeoNamesWebService.getLocationInfo(null, leadCountry,EncodingUtil.urlEncode(l.city,'UTF-8'), false);
                }
                
                system.debug('*****'+leadFieldsMap); 
                Boolean updFlag = False;        
                System.debug('FIND ME' + leadFieldsMap);
                if(leadFieldsMap.values().isEmpty()){
                   
                    
                    //BS-143
                    //If geocoding was not sucessful and this is an internation lead we 
                    //still want to try and assign a deler based on the lead routing rules.
                    //Need to get the lat / long of the capital so that we have some coordinates
                    //for the distance queries used in lead reouter.
                    if (leadCountry != UNITED_STATES && leadCountry != CANADA) {
                        system.debug('No geocode info and the lead is not domestic');
                        
                        //Get the latitude and longitude of the capital city
                        leadFieldsMap = GeoNamesWebService.getLocationInfo(null, leadCountry, '', false);
                        
                        if(leadFieldsMap.get('lat') != null) {   
                            l.latitude__c = decimal.valueOf(leadFieldsMap.get('lat'));
                            l.GeoLocation__Latitude__s = decimal.valueOf(leadFieldsMap.get('lat'));
                        }            
                        if(leadFieldsMap.get('lng') != null) {  
                            l.longitude__c = decimal.valueOf(leadFieldsMap.get('lng')); 
                            l.GeoLocation__Longitude__s = decimal.valueOf(leadFieldsMap.get('lng'));
                        }
                        if(leadFieldsMap.get('countryCode') != null){
                            system.debug('Country code: ' + leadFieldsMap.get('countryCode'));
                            l.Country_ISO_Code__c = leadFieldsMap.get('countryCode');
                            l.GeoNames_WebService_Error__c = ''; 
                        }
                        if(leadFieldsMap.get('WebService Exception: ') != null) {    
                            l.GeoNames_WebService_Error__c = leadFieldsMap.get('WebService Exception: ');
                            
                            //BS-246
                            if (l.GeoNames_WebService_Error__c.contains('missing postalcode')) {
                            	l.Geonames_Retry__c = false;
                            } else {
                            	l.Geonames_Retry__c = true;
                            }
                        } else {
                            l.Geonames_Retry__c = false;
                        }
                        
                        if (!leadFieldsMap.values().isEmpty()) {
                            l.Assigned_Dealer_1__c =null;
                            l.Assigned_Dealer_2__c =null;  
                            l.Assigned_Dealer_3__c =null;
                            leadUpdateList.add(l);
                            continue;
                        } else {
                            l.GeoNames_WebService_Error__c= NO_GEO_RESULTS_MSG;
                            resultsNotFoundLeadList.add(l);
                            continue;
                        }
                    } else { 
                        l.GeoNames_WebService_Error__c= NO_GEO_RESULTS_MSG;
                        resultsNotFoundLeadList.add(l);
                        continue;
                    } 
                } 
                
                brandCode = l.Brand_Code__c;
                
                if(leadFieldsMap.get('adminName2') != null) {                   
                    l.county__c =leadFieldsMap.get('adminName2').contains('County') ?  leadFieldsMap.get('adminName2').remove('County').trim() : leadFieldsMap.get('adminName2');   
                    l.GeoNames_WebService_Error__c = '';                  
                    updFlag = True;                     
                }
                if(leadFieldsMap.get('lat') != null) {   
                    l.latitude__c = decimal.valueOf(leadFieldsMap.get('lat'));
                    l.GeoLocation__Latitude__s = decimal.valueOf(leadFieldsMap.get('lat'));
                    l.GeoNames_WebService_Error__c = '';                            
                    updFlag = True;     
                }            
                if(leadFieldsMap.get('lng') != null) {  
                    l.longitude__c = decimal.valueOf(leadFieldsMap.get('lng')); 
                    l.GeoLocation__Longitude__s = decimal.valueOf(leadFieldsMap.get('lng'));
                    l.GeoNames_WebService_Error__c = '';                   
                    updFlag = True;    
                }
                if(leadFieldsMap.get('countryCode') != null){
                    l.Country_ISO_Code__c = leadFieldsMap.get('countryCode');
                    l.GeoNames_WebService_Error__c = ''; 
                    updFlag = True;
                }
                if(leadFieldsMap.get('name') != null){
                    String s = leadFieldsMap.get('name');
                    if(leadFieldsMap.get('name').length() > 40)
                        l.City = s.substring(0,40);
                    else
                        l.City = leadFieldsMap.get('name');
                    l.GeoNames_WebService_Error__c = '';  
                    updFlag = True;                 
                }
                
                //BS-251
                //if(leadFieldsMap.get('adminName1') != null){
                //    if(l.State==null){
                //        l.State = leadFieldsMap.get('adminName1');
                //    }
                //    l.GeoNames_WebService_Error__c = ''; 
                //    updFlag = True;
                //    
                //}               
                //if((leadFieldsMap.get('adminCode1') != null)){
                //    leadStateCodeMap.put(l.Id, leadFieldsMap.get('adminCode1'));
                //    
                //}
                if(leadFieldsMap.get('adminCode1') != null){
                	leadStateCodeMap.put(l.Id, leadFieldsMap.get('adminCode1'));
                    l.State = leadFieldsMap.get('adminCode1');
                    l.GeoNames_WebService_Error__c = ''; 
                    updFlag = True;
                } 
                
                if(leadFieldsMap.get('WebService Exception: ') != null) {    
                    l.GeoNames_WebService_Error__c = leadFieldsMap.get('WebService Exception: ');
                    //BS-246
                    if (l.GeoNames_WebService_Error__c.contains('missing postalcode')) {
                      	l.Geonames_Retry__c = false;
                    } else {
                      	l.Geonames_Retry__c = true;
                    }
                    updFlag = True;     
                }
                else{
                    l.Geonames_Retry__c = false;
                    updFlag = True;
                }
                if(leadFieldsMap.get('XML Parsing Exception: ') != null) { 
                    if(leadFieldsMap.get('WebService Exception: ') != null) {    
                        l.GeoNames_WebService_Error__c += leadFieldsMap.get('XML Parsing Exception: '); 
                        
                    } else {
                        l.GeoNames_WebService_Error__c += leadFieldsMap.get('XML Parsing Exception: ');  
                        
                    }
                    updFlag = True;
                } 
                if(updFlag == True) {    
                    l.Assigned_Dealer_1__c =null;
                    l.Assigned_Dealer_2__c =null;  
                    l.Assigned_Dealer_3__c =null;
                    leadUpdateList.add(l);   
                    
                }
                
            } // end of FOR loop
            
            system.debug('leadUpdateList '+leadUpdateList);
            ranPopulateLeadGeoFields = True;
            
            if (!leadUpdateList.isEmpty()){
            	TriggerHandler.bypass('LeadTriggerHandler');
                update leadUpdateList;
                TriggerHandler.clearBypass('LeadTriggerHandler');	
            }
            
            if (routeToDealers == true) {
            	routeLeads(leadUpdateList, resultsNotFoundLeadList);
            }
    }
    
    
    public static void routeLeads(final List<Lead> leadUpdateList){
        routeLeads(leadUpdateList, new List<Lead>());
    }
    
    public static void routeLeads(final List<Lead> leadUpdateList, final List<Lead> resultsNotFoundLeadList){
        if (leadUpdateList != null && leadUpdateList.size() > 0) {
    		// We need to consult our flag for determining if we should use the old BL style
    		// lead routing or the new combined SR type
    		if (!LeadServices.legacyLeadRouting) {
    			// We are using the new SR combined type of lead routing
    			system.debug('Using new combined lead routing');
		        LeadServices.leadRoutingIsRunning = true;
		        try {
		        	LeadRouter lr = new LeadRouter();
		        	lr.routeToDealers(leadUpdateList);
		        }
		        finally {
		        	LeadServices.leadRoutingIsRunning = false;
		        }
    		}
    		else {
    			// We need to use the old legacy BL type	
    			system.debug('Using legacy lead routing');
    			routeLeadsLegacy(leadUpdateList, resultsNotFoundLeadList);
    		}
    	}
        
    }
    
    public static void routeLeadsLegacy(final List<Lead> leadUpdateList, final List<Lead> resultsNotFoundLeadList){
        final List<Lead> legacyLeadTypes = new list<Lead>();
        final List<Lead> AllOtherLeads = new list<Lead>();
        map<string, Dealer_Routing_Test_Mode__c> dealerRoutingTestModes = Dealer_Routing_Test_Mode__c.getAll();
        Dealer_Routing_Test_Mode__c routingTestMode = dealerRoutingTestModes.get('Lead');
        
        system.debug('legacyBrandCodes'+ legacyBrandCodes);
        system.debug('AllOtherLeads'+AllOtherLeads);
            
        for(Lead l:leadUpdateList){
            if(legacyBrandCodes.contains(l.Brand_Code__c)){
                legacyLeadTypes.add(l);
            }
            else {
                system.debug('other lead <><>'+ l);
                AllOtherLeads.add(l);
            }
        }
        
        
        Set<Id> leadIDsToSendToFootsteps_Input = new Set<Id>();
        
        
        //the following if block is legacy code that needs to remain intact for Bayliner, Maxum, and Trophy leads.
        if(!legacyLeadTypes.isEmpty()){
            system.debug('Legacy leads <><>'+ legacyLeadTypes);
            final List<Lead> leadsWithUpdatedDealers = routeLeadsToAppropriateDealers(leadUpdateList,brandCode);
            routeLeadToMarineMaxDealer(leadsWithUpdatedDealers, routingTestMode);
            
            //Also have to update leads that didn't find results
            leadsWithUpdatedDealers.addAll(resultsNotFoundLeadList);
            if(!leadsWithUpdatedDealers.isEmpty()) {
                update leadsWithUpdatedDealers;   
                
                leadIDsToSendToFootsteps_Input.addAll(Pluck.ids(leadsWithUpdatedDealers));
            
            }
            
             if (!leadIDsToSendToFootsteps_Input.isEmpty() &&
             	(routingTestMode == null || routingTestMode.Test_Mode__c == false)){
             		/*
	            String scheduleTime = Datetime.now().addSeconds( 60 ).format( 'ss mm HH dd MM ? yyyy' );
	            String scheduleId = String.valueOf(Datetime.now().getTime());
	            String jobId = System.schedule( 'footstepsIntegration'+scheduleId, scheduleTime, new ScheduleHandler(leadIDsToSendToFootsteps_Input) );
	            */
	            LeadRouter router = new LeadRouter();
	            router.sendToFootsteps(leadIDsToSendToFootsteps_Input);
	        }
        }
        
        if(!AllOtherLeads.isEmpty()){
            system.debug('All Other leads <><>'+ AllOtherLeads);
            // make the magic happen.
            LeadServices.leadRoutingIsRunning = true;
            try {
            	LeadRouter lr = new LeadRouter();
            	lr.routeToDealers(AllOtherLeads);
            }
            finally {
            	 LeadServices.leadRoutingIsRunning = false;
            }
        }
    }
    
    
    public static Map<Id,Lead> getLeadsWithChangedAddress(final Map<Id,Lead> triggerOld, final Map<Id,Lead> triggerNew) {
        final Map<Id,Lead> leadsToProcess = new Map<Id,Lead>();
        for(Lead oldLead :triggerOld.values()) {
            Lead newLead = triggerNew.get(oldLead.Id);
            if(oldLead.PostalCode != newLead.PostalCode/* || oldLead.Country != newLead.Country*/) {
                leadsToProcess.put(newLead.Id, newLead);
            } 
        }
        system.debug('leadsToProcess ***'+ leadsToProcess);
        return leadsToProcess;
    }   

    
    
    
    private static void routeLeadToMarineMaxDealer(list<Lead> leadRecords, Dealer_Routing_Test_Mode__c testMode){
        set<Id> assignedDealerId = new set<Id>();
        
        for(Lead ld : leadRecords){
            if(ld.Assigned_Dealer_1__c != null)
                assignedDealerId.add(ld.Assigned_Dealer_1__c);
            if(ld.Assigned_Dealer_2__c != null)
                assignedDealerId.add(ld.Assigned_Dealer_2__c);
            if(ld.Assigned_Dealer_3__c != null)
                assignedDealerId.add(ld.Assigned_Dealer_3__c);           
        }
        
        map<Id,Account> idToDealer = getDetailsForAssignedDealer(assignedDealerId);
        //map<Id,list<Boat__c>> accountIdToListOfBoats = getAllBoatsTiedToAssignedDealer(assignedDealerId);
        
        for(lead ld : leadRecords){    
            //BS-192 - XML Dealer Routing needs to account for Do Not Send custom settings
            if (isLeadSendable(ld.Brand_Code__c, ld.Lead_Form_Name__c) && !isUserLoadingBatch) {  
                for(Account rec :idToDealer.values()){
                    if(ld.Lead_Emails_Sent__c == null || !ld.Lead_Emails_Sent__c) {             
                        String result = getXml(rec,ld);             
                        Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
                        attachment.setContentType('application/xml');
                        attachment.setFileName('Bayliner Lead');
                        attachment.setBody(Blob.valueOf(result));                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailmessage();
                        String[] toAddresses = new String[] {rec.CRM_System_Email__c};
                        
                        if (testMode != null && testMode.Test_Mode__c) {
                        	toAddresses = new String[] {testMode.Test_CRM_Email__c};
                        }
                        
                        mail.setToAddresses(toAddresses);            
                        mail.setPlainTextBody('bayliner dealer xml');
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});     
                    }           
                }  
            }          
        }       
    }
    
    public static string getXML (Account marineMaxDealer ,lead ld){
    	
    	List<Task> tasks = ld.getSObjects('tasks');
    	
        XmlStreamWriter w = new XmlStreamWriter();  
        w.writeStartDocument(null, '1.0');
        w.writeStartElement('', 'Lead',''); 
        //w.writeNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');  
        //w.writeNamespace('xsd','http://www.w3.org/2001/XMLSchema');
        w.writeStartElement(null, 'customername', null);        
        w.writeCharacters(getValue(ld.name));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeraddress', null);
        w.writeCharacters(getValue(ld.street));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customercity', null); 
        w.writeCharacters(getValue(ld.city));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerState', null);
        w.writeCharacters(getValue(ld.state));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerzip', null);
        w.writeCharacters(getValue(ld.PostalCode));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customercountry', null);
        w.writeCharacters(getValue(ld.Country));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerhomephone', null);       
        w.writeCharacters(getValue(ld.Phone));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeremail1', null);
        w.writeCharacters(getValue(ld.Email));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeremail2', null);
        w.writeCharacters(getValue(ld.Alternate_Email_Address__c));
        w.writeEndElement(); 
        w.writeStartElement(null, 'dealerid', null);
        w.writeCharacters(getValue(marineMaxDealer.Id));
        w.writeEndElement(); 
        w.writeStartElement(null, 'leadformname', null);
        w.writeCharacters(getValue(ld.Lead_Form_Name__c));
        w.writeEndElement();
        w.writeStartElement(null, 'typeofinquiry', null);
        w.writeCharacters(getValue(ld.Type_of_inquiry__c));
        w.writeEndElement(); 
        /*w.writeStartElement(null, 'priority', null);
w.writeCharacters('');
w.writeEndElement();*/ 
        w.writeStartElement(null, 'createddate', null);
        w.writeCharacters(getValue(String.valueOf(ld.CreatedDate)));
        w.writeEndElement(); 
        w.writeStartElement(null, 'previousboatowner', null);
        w.writeCharacters(getValue(String.valueOf(ld.Previous_Boat_Owner__c)));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedbrand', null);
        w.writeCharacters(getValue(ld.Current_Owned_Brand__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedmodel', null);
        w.writeCharacters(getValue(ld.Current_Owned_Model__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedboatclass', null);
        w.writeCharacters(getValue(ld.Current_Owned_Boat_Class__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedyear', null);
        w.writeCharacters(getValue(ld.Currently_Owned_Year__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedidnumber', null);
        w.writeCharacters(getValue(ld.Current_Owned_ID_Number__c));
        w.writeEndElement();
        w.writeStartElement(null, 'boatmodelinterest', null);
        w.writeCharacters(getValue(ld.Boat_Model_Interest__c));
        w.writeEndElement();
        w.writeStartElement(null, 'boatclassinterest', null);
        w.writeCharacters(getValue(ld.Boat_Class_Interest__c));
        w.writeEndElement();
        w.writeStartElement(null, 'boatyearinterest', null);
        w.writeCharacters(getValue(ld.Boat_Year_Interest__c));
        w.writeEndElement();
        w.writeStartElement(null, 'interestedinstocknumber', null);
        w.writeCharacters(getValue(ld.Interested_in_Stock_Number__c));
        w.writeEndElement();
        w.writeStartElement(null, 'interestedinlength', null);
        w.writeCharacters(getValue(ld.Interested_in_length__c));
        w.writeEndElement();
        w.writeStartElement(null, 'interestedinidnumber', null);
        w.writeCharacters(getValue(ld.Interested_in_ID_Number__c));
        w.writeEndElement();
        w.writeStartElement(null, 'purchasetimeframe', null);
        w.writeCharacters(getValue(ld.Buying_horizon__c));
        w.writeEndElement();
        w.writeStartElement(null, 'comments', null);
        
        String comments = getValue(ld.Notes__c);
        
        //Get the Pardot Score Increase Trigger Custom Setting accumulated point total for the lead's brand
    	Pardot_Score_Increase_Trigger__c psit = LeadServices.pardotScoreIncreaseTriggers.get(ld.Brand_Code__c);
    			
		if (psit != null) {
			if (tasks != null && !tasks.isEmpty()) {
				comments += '\nLead Activities:\n';
				for (Integer x = 0; x < Math.min(tasks.size(), psit.Days_Of_Activities__c.intValue()); x++) {
					Task task = tasks[x];
					comments += task.LastModifiedDate.format() + ' - ' + task.Subject + ' \n';
				}
			}
		}
				
        w.writeCharacters(comments);
        
        w.writeEndElement();        
        /*
w.writeStartElement(null, 'leadsourcetype', null);
w.writeCharacters('');
w.writeEndElement();        
w.writeStartElement(null, 'leadsourcedetail', null);
w.writeCharacters('');
w.writeEndElement();        
w.writeStartElement(null, 'leadsource', null);
w.writeCharacters(getValue(ld.LeadSource));
w.writeEndElement(); 
w.writeStartElement(null, 'leadsourcevendor', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'leadwebsourcepage', null);
w.writeCharacters(getValue(ld.Website));
w.writeEndElement(); 
w.writeStartElement(null, 'boatunittype', null);
w.writeCharacters(getValue(ld.Boat_Class_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boattype', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'boatbrand', null);
w.writeCharacters(getValue(ld.Brand_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boatstocknumber', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'boatmodel', null);
w.writeCharacters(getValue(ld.Boat_Model_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boathin', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradeinhorsepower', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradehours', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradetrailerincluded', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'cashdown', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'rentorown', null);
w.writeCharacters('');
w.writeEndElement();*/ 
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }
    // email not required
    
    private static string getValue(String fieldValue){
        String newValue;
        if(String.isBlank(fieldValue))
            newValue = '';
        else
            newValue = fieldValue;
        return newValue;
    }
    
    private static map<Id,Account> getDetailsForAssignedDealer(set<Id> assignedDealerId){
        return new map<Id,Account>([select 
                                    Id,                   
                                    CRM_System_Email__c
                                    from Account
                                    where Id IN :assignedDealerId
                                    and CRM_System__c ='Microsoft Dynamics']);
    }
    
    public static List<Id> uniqueIds(final List<Id> ids) {
        final List<Id> uniqueIds = new List<Id>();
        for(Id eachId :ids) {
            if(uniqueIds.isEmpty()) uniqueIds.add(eachId);
            else {
                Boolean flag = false;
                for(Id eachUniqueId :uniqueIds) {
                    flag = (eachUniqueId == eachId);
                    if(flag) break;
                }
                if(!flag) uniqueIds.add(eachId);
            }
        }
        return uniqueIds;
    }
    /*
private static map<Id,list<Boat__c>> getAllBoatsTiedToAssignedDealer(set<Id> assignedDealerId){

map<Id,list<Boat__c>> dealerIdToBoats = new map<Id,list<Boat__c>>();    
for(Account rec :[Select 
Id,
email__c,
(Select Name, Dealer__c From Boats1__r)
From Account 
where Id IN :assignedDealerId
and CRM_System__c ='Microsoft Dynamics']){
dealerIdToBoats.put(rec.Id,rec.Boats1__r);
}
return dealerIdToBoats;
}*/
    
    //Get only leads that have just been converted
    public static List <Id> filterConvertedLeads(Map <Id,Lead> oldMap, Map <Id,Lead> newMap){
        List <Id> converted= new List <Id>();
        for (Id i:oldMap.keySet()){
            if(!oldMap.get(i).IsConverted && newMap.get(i).IsConverted){
                converted.add(i);
            }
        }
        return converted;
    }
    
    
    //Get consumer action object and update it
    public static List<ConsumerActions__c> processConsumerActions(List <Id> converted){
        List<ConsumerActions__c> consumerActions=new List<ConsumerActions__c>();
        for(Lead l: [SELECT ConvertedAccountId, (SELECT Lead_Name__c, boat_owner__c from Consumer_Actions__r)
                     FROM Lead WHERE Id IN :converted]){
                         for (ConsumerActions__c ca : l.Consumer_Actions__r){
                             ca.Boat_Owner__c=l.ConvertedAccountId;
                             consumerActions.add(ca);
                         }
                     }
        return consumerActions;
    }
    
    //Update database
    public static void updateConsumerActions(List<ConsumerActions__c> consumerActions, Map<Id, Lead> originalLeadsMap ){
        
        try
        {
            update consumerActions;
        }
        catch (DmlException dex)
        {
            for( integer i = 0; i < dex.getNumDml(); i++)
            {
                Id leadToAttachErrorId = consumerActions[ dex.getDmlIndex( i ) ].Lead_Name__c;
                originalLeadsMap.get( leadToAttachErrorId ).addError( 'Error Occurred For Consumer Action : ' + consumerActions[ dex.getDmlIndex( i ) ].Id + ' from Lead ' + leadToAttachErrorId + ' Details : ' + dex.getDmlMessage( i ) );
            }
        }
    }
    
    public static Lead clearDealerFields(Lead l){
        
        // assumption is that there are 10 dealer fields
        Lead le = [SELECT Id, state, County__c,Lead_Form_Name__c, Brand_Code__c,pi__Score__c, PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c, 
                   Assigned_Dealer_5__c,
                   Assigned_Dealer_6__c,
                   Assigned_Dealer_7__c,
                   Assigned_Dealer_8__c,
                   Assigned_Dealer_9__c,
                   Assigned_Dealer_10__c FROM Lead WHERE Id =: l.Id];
        for(integer i=1;i<11;i++){
            le.put('Assigned_Dealer_'+i+'__c',null);
        }
        return le;
    }
    
    public static Map<String, String> countryISOLookupByName{
        get{
            if (countryISOLookupByName == null){
                countryISOLookupByName = new Map<String, String>();
                for (Country_ISO_Code_Lookup__c cs : Country_ISO_Code_Lookup__c.getAll().values()){
                    
                    if (!countryISOLookupByName.containsKey(cs.Country__c)){
                        countryISOLookupByName.put(cs.Country__c, cs.Name);
                    }
                    
                }
            }
            return countryISOLookupByName;
        }
        set;
    }
    
    public static Map<String, String> countryISOLookupByCode{
        get{
            if (countryISOLookupByCode == null){
                countryISOLookupByCode = new Map<String, String>();
                for (Country_ISO_Code_Lookup__c cs : Country_ISO_Code_Lookup__c.getAll().values()){
                    
                    if (!countryISOLookupByCode.containsKey(cs.Country__c)){
                        countryISOLookupByCode.put(cs.Name, cs.Country__c);
                    }
                    
                }
            }
            return countryISOLookupByCode;
        }
        set;
    }
    
        /*
    Checks to see if the Pardot score has increased on the lead and handle as needed
    */
    public static void checkPardotScoreIncrease(List<Id> leadIds) {
    	
    	List<Lead> leadList = [SELECT l.Id, l.pi__score__c, l.LastName, l.FirstName, l.Brand_Code__c FROM Lead l WHERE id in: leadIDs];
    	List<Lead> leadsToReroute = new List<Lead>();
    	
    	for (Lead lead : leadList) {
    		system.debug('*********************** ' + lead.FirstName + ' ' + lead.LastName + ' has a Pardot score of ' + lead.pi__score__c);
    		
    		//Get the last Assigned Dealer record
    		Decimal previousPardotScore;
    		List<Assigned_Dealer__c> assignedDealers = [Select a.Id, a.Pardot_Score__c From Assigned_Dealer__c a Where a.Lead__r.Id = :lead.Id Order By CreatedDate desc LIMIT 1];
    		
    		if (assignedDealers != null && !assignedDealers.isEmpty()) {
    			previousPardotScore = assignedDealers[0].Pardot_Score__c;
    		}
    		system.debug('*********************** Lead previous Pardot score = ' + previousPardotScore);
    		
    		if (previousPardotScore == null) {
    			previousPardotScore = 0;
    		}
    		
    		//Get the Pardot Score Increase Trigger Custom Setting accumulated point total for the lead's brand
    		Pardot_Score_Increase_Trigger__c psit = pardotScoreIncreaseTriggers.get(lead.Brand_Code__c);
    		
    		if (psit != null) {
	    		Decimal pointTrigger = psit.Accumulated_Point_Amount__c;
	    		system.debug('*********************** Pardot point trigger for brand ' + lead.Brand_Code__c + ' = ' + pointTrigger != null ? 'Not defined' : pointTrigger.toPlainString());
	    		
	    		if (pointTrigger != null && pointTrigger > 0) {
	    			system.debug('*********************** Score difference = ' + (lead.pi__score__c - previousPardotScore).toPlainString());
	    			if (lead.pi__score__c - previousPardotScore >= pointTrigger) {
	    				system.debug('*********************** Point trigger amount has been met or exceeded');
	    				leadsToReroute.add(lead);
	    			}
	    		}
    		} else {
    			system.debug('*********************** No Pardot Score Increate Trigger custom setting entry for brand: '+ lead.Brand_Code__c);
    		}
    	}
    	
    	//Reroute any leads that met the criteria (exceeded points)
    	if (!leadsToReroute.isEmpty()) {
   			Map<Id, Lead> newMap = new Map<Id, Lead>(leadsToReroute);
            LeadServices.AutoPopulateGeoLocation(leadsToReroute, newMap, null, true, true, false);
            
            /*
            * Test code
            */
            //for (Lead lead : leadsToReroute) {    
            //	Pardot_Score_Increase_Trigger__c psit = pardotScoreIncreaseTriggers.get(lead.Brand_Code__c);
            //	
            //	/*
            //	* Report the activities
            //	*/
            //	Integer numberOfActivities = psit.Days_Of_Activities__c != null ? psit.Days_Of_Activities__c.intValue() : 7;
            //	List<Task> tasks = [Select t.Subject, t.LastModifiedDate, t.WhoId From Task t WHERE t.WhoId = :lead.Id and t.Status != 'Closed' Order By t.LastModifiedDate Desc Limit :numberOfActivities]; 
            //	
            //	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailmessage();
	        //    mail.setToAddresses(new List<String>{'david.hickman@brunswickboatgroup.com'});    		 
	        //    mail.setSubject('Lead Re-route: Activities');    		 
	        //    mail.setPlainTextBody(lead.FirstName + ' ' + lead.LastName + ' has performed the following activities: ' + (!tasks.isEmpty() ? String.join(tasks, ' \n') : 'No Activities') + '\n\nMaximum number of activities listed: ' + numberOfActivities);
	        //    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});   
	    	//			
            //}
    	}
    }
    
    
    
    private static Map<String, Pardot_Score_Increase_Trigger__c> pardotScoreIncreaseTriggers {
        get{
            if (pardotScoreIncreaseTriggers == null){
                pardotScoreIncreaseTriggers = new Map<String, Pardot_Score_Increase_Trigger__c>();
                for (Pardot_Score_Increase_Trigger__c p : Pardot_Score_Increase_Trigger__c.getAll().values()){
                    
                    if (!pardotScoreIncreaseTriggers.containsKey(p.Brand_Code__c)){
                        pardotScoreIncreaseTriggers.put(p.Brand_Code__c, p);
                    }
                    
                }
            }
            system.debug('pardotScoreIncreaseTriggers: ' + pardotScoreIncreaseTriggers);
            return pardotScoreIncreaseTriggers;
        }
        set;
    }
    
    
}