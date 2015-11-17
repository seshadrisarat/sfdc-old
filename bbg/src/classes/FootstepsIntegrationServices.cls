public class FootstepsIntegrationServices {
	
	public static String NO_ERRORS = 'No Errors';
	public static String CONTENT_TYPE = 'text/xml';
	public static String CONTENT_TYPE_ARI = 'application/x-www-form-urlencoded';
	public static String CONTENT_TYPE_HEADER = 'content-type';
	
    public static String AUTH_KEY_HEADER = 'x-auth-token';
    public static String MARINE_MAX_AUTH_TOKEN {
    	get {
    		if (MARINE_MAX_AUTH_TOKEN == null){
    			/*
    				QA Key: '3cd7e0e084d144778850e6c9ee99f93f632ef34436a34bdd9216d34217e6c5ad';
    				Prod : 56742ac0d4864357b62215ce8e8b7e79768c888538ee4213b82b230247ab71d9	
    			*/ 
    			MARINE_MAX_AUTH_TOKEN = Footsteps_Integration_Settings__c.getInstance().Marine_Max_AuthKey__c;
    		}
    		return MARINE_MAX_AUTH_TOKEN;
    	}
    	set;
    }
    
	public class FootstepsWebServiceException extends Exception {}
	

	@testVisible private static String ARI_FOOTSTEPS_CRM_SYSTEM = 'ARI/Footsteps';
	@testVisible private static String MARINE_MAX_CRM_SYSTEM = 'Microsoft Dynamics';
	@testVisible private static String IDS_ASTRA_CRM_SYSTEM = 'IDS Astra';
	@testVisible private static String BAYLINER_BRAND_CODE = 'BL';

	private static String ELEMENT_PREFIX = '';
	private static String NAMESPACE_URI = '';
	
	public static Integer MAX_FOOTSTEPS_LEAD_BATCH_SIZE = 50;
	
	public static List<String> CRM_INTEGRATION_ERROR_EMAILS {
		get{
		
			if (CRM_INTEGRATION_ERROR_EMAILS == null){
				CRM_INTEGRATION_ERROR_EMAILS = new List<String>();
				Footsteps_Integration_Settings__c cs = Footsteps_Integration_Settings__c.getInstance();
				if (String.isNotBlank(cs.Error_Emails__c)){
					CRM_INTEGRATION_ERROR_EMAILS.addAll(cs.Error_Emails__c.split(','));
				}
			}
			return CRM_INTEGRATION_ERROR_EMAILS;
			
		}
		set;
	}
	
	public static String FOOTSTEPS_END_POINT {
		get{
			if (FOOTSTEPS_END_POINT == null){
				FOOTSTEPS_END_POINT = Footsteps_Integration_Settings__c.getInstance().Footsteps_Endpoint__c;
			}
			return FOOTSTEPS_END_POINT;
		}
		set;
	}
	public static String MARINE_MAX_END_POINT {
		get{
			if (MARINE_MAX_END_POINT == null){
				MARINE_MAX_END_POINT = Footsteps_Integration_Settings__c.getInstance().Marine_Max_Endpoint__c;
			}
			return MARINE_MAX_END_POINT;
		}
		set; 
	}
	
	public static String IDS_ASTRA_END_POINT { 
		get{
			if (IDS_ASTRA_END_POINT == null){ 
				IDS_ASTRA_END_POINT = Footsteps_Integration_Settings__c.getInstance().IDS_Astra_Endpoint__c;	  
			}
			return IDS_ASTRA_END_POINT;
		}
		set;
	}
	
	public static Boolean FOOTSTEPS_SEND_DEBUG_EMAIL {
		get{
			if (FOOTSTEPS_SEND_DEBUG_EMAIL == null){
				FOOTSTEPS_SEND_DEBUG_EMAIL = Footsteps_Integration_Settings__c.getInstance().Debug_All__c;
			}
			return FOOTSTEPS_SEND_DEBUG_EMAIL;
		}
		set;
	}
	
	public static Boolean SEND_FOOTSTEPS_LEADS {
		get{
			if (SEND_FOOTSTEPS_LEADS == null){
				SEND_FOOTSTEPS_LEADS = Footsteps_Integration_Settings__c.getInstance().Send_Leads__c;
			}
			return SEND_FOOTSTEPS_LEADS;
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
    *
    * BS-230 - Modify XML / Email Generation to include recent tasks (activities)
    * David Hickman
    */
    public static Map<String, Pardot_Score_Increase_Trigger__c> pardotScoreIncreaseTriggers {
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
    
	public static Set<String> ARI_FILTERD_LEADS = new Set<String>{'searay.com', 
															'global.searay.com', 
															'meridian-yachts.com'};
    
	public static List<String> leadFootstepsIntegrationFields = new List<String>{
		'FirstName', 'LastName', 
		'CreatedDate', 'Industry', 'Email', 'Boat_Year_Interest__c', 
		'Brand_Interest__c', 'Boat_Model_Interest__c', 'Email_Opt_in__c',
		'Boat_Category_of_Interest__c', 'Street', 'City', 'PostalCode',
		'State', 'Country', 'Best_Time_to_Contact__c', 'Preferred_method_of_contact__c',
		'Comments__c', 'LeadSource', 'Lead_Form_Name__c', 'Brand_Code__c', 
		'HasOptedOutOfEmail', 'Spouse_Name__c', 'Occupation_Title__c', 'Company', 
		'Birthday__c', 'Buying_horizon__c', 'First_Time_Boat_Owner__c', 
		'Hull_Identification_Number_HIN__c', 'Phone', 'Best_Phone__c', 'Trade_In_Model__c', 
        'Trade_In_Year__c', 'Trade_In_Comments__c', 'pi__score__c', 'Notes__c'
		
	};
	
	public static List<String> leadFootstepsIntegrationDealerCRMFields = new List<String>{
		'Assigned_Dealer_1__r.CRM_System__c', 
		'Assigned_Dealer_2__r.CRM_System__c', 
		'Assigned_Dealer_3__r.CRM_System__c', 
		'Assigned_Dealer_4__r.CRM_System__c', 
		'Assigned_Dealer_5__r.CRM_System__c', 
		'Assigned_Dealer_6__r.CRM_System__c', 
		'Assigned_Dealer_7__r.CRM_System__c', 
		'Assigned_Dealer_8__r.CRM_System__c', 
		'Assigned_Dealer_9__r.CRM_System__c', 
		'Assigned_Dealer_10__r.CRM_System__c'
		
	};
	
	public static List<String> leadFootstepsIntegrationDealerNumberFields = new List<String>{
		'Assigned_Dealer_1__r.Dealer_Number__c', 
		'Assigned_Dealer_2__r.Dealer_Number__c', 
		'Assigned_Dealer_3__r.Dealer_Number__c', 
		'Assigned_Dealer_4__r.Dealer_Number__c', 
		'Assigned_Dealer_5__r.Dealer_Number__c', 
		'Assigned_Dealer_6__r.Dealer_Number__c', 
		'Assigned_Dealer_7__r.Dealer_Number__c', 
		'Assigned_Dealer_8__r.Dealer_Number__c', 
		'Assigned_Dealer_9__r.Dealer_Number__c', 
		'Assigned_Dealer_10__r.Dealer_Number__c'
		
	};
	
	/*
	* BS-230 - Modify XML / Email Generation
	* (David Hickman)
	*/
	// public static String taskSubSelect = '(Select t.Subject, t.LastModifiedDate, t.WhoId From Tasks t Order By t.LastModifiedDate Desc Limit :maxTaskLimit)';
	
	
	public static Map<String, List<Lead>> filterLeadsWithFootstepsCRMSystem(Set<ID> leadIDs){
		
		
		List<String> leadFootstepsIntegrationFieldsPlusOthers = leadFootstepsIntegrationFields.clone();
    	leadFootstepsIntegrationFieldsPlusOthers.addAll(new List<String>{'Footsteps_Retry__c'});
    	leadFootstepsIntegrationFieldsPlusOthers.addAll(leadFootstepsIntegrationDealerCRMFields);
    	leadFootstepsIntegrationFieldsPlusOthers.addAll(leadFootstepsIntegrationDealerNumberFields);
    	
    	/*
    	* BS-230 - Modify XML / Email Generation
    	* Find the maximum number of days worth of activities to report
    	*/
    	Integer maxTaskLimit = 0;
    	for (Pardot_Score_Increase_Trigger__c psit : pardotScoreIncreaseTriggers.values()) {
    		if (psit.Days_Of_Activities__c > maxTaskLimit) {
    			maxTaskLimit = psit.Days_Of_Activities__c.intValue();
    		}
    	}
    	if (maxTaskLimit == 0) {
    		maxTaskLimit = 7;
    	}
    	
    	List<Lead> outgoingLeads = Database.query(	' Select Id, ' + 
    													String.join(leadFootstepsIntegrationFieldsPlusOthers, ',') + 
    													// ', ' + taskSubSelect +
													' From Lead Where Id in :leadIDs');

		/*
		essentially: 
			if (bayliner){ look at dealer crm system }
			else { look at dealer_brand crm_system } 
		*/
		
		Set<Lead> outgoingFilteredLeads_ARI = new Set<Lead>();
		Set<Lead> outgoingFilteredLeads_MarineMax = new Set<Lead>();
		Set<Lead> outgoingFilteredLeads_IDS = new Set<Lead>();
		
		Set<Id> nonBaylinerDealerIds = new Set<Id>();
		List<Lead> nonBaylinerLeads = new List<Lead>();
		
		for (Lead outgoingLead : outgoingLeads){
			//BS-192 - XML Dealer Routing needs to account for Do Not Send custom settings
			if (!isLeadSendable(outgoingLead.Brand_Code__c, outgoingLead.Lead_Form_Name__c)) {
				continue;
			}
			
			system.debug('Lead is sendable');
			
			if (outgoingLead.Brand_Code__c == BAYLINER_BRAND_CODE){
				for (String crmSystemField : leadFootstepsIntegrationDealerCRMFields){
					List<String> field = crmSystemField.split('\\.', 0);
				    Account assignedDealer = (Account) outgoingLead.getSobject(field[0]);
				    if (assignedDealer != null){
				        if (assignedDealer.get(field[1]) == ARI_FOOTSTEPS_CRM_SYSTEM){
				        	outgoingFilteredLeads_ARI.add(outgoingLead);
				        }
				    }
				}
			}
			else {
				Boolean atLeastOneAssignedDealer = false;
				for (String crmSystemField : leadFootstepsIntegrationDealerCRMFields){
					List<String> field = crmSystemField.split('\\.', 0);
				    Account assignedDealer = (Account) outgoingLead.getSobject(field[0]);
				    if (assignedDealer != null){
				        nonBaylinerDealerIds.add(assignedDealer.Id);
				        atLeastOneAssignedDealer = true;
				    }
				}
				if (atLeastOneAssignedDealer){
					nonBaylinerLeads.add(outgoingLead);
				}
			}
		}
		
		Map<Id, Account> dealersWithBrands = new Map<Id, Account>([Select Id,
												(Select Dealer_CRM_System__c , Brand__c
													From Dealer_Brands__r) 
											From Account where Id in :nonBaylinerDealerIds]);
		
		for (Lead outgoingNonBaylinerLead : nonBaylinerLeads){
			for (String crmSystemField : leadFootstepsIntegrationDealerCRMFields){
				List<String> field = crmSystemField.split('\\.', 0);
			    Account assignedDealer = (Account) outgoingNonBaylinerLead.getSobject(field[0]);
			    if (assignedDealer != null && dealersWithBrands.containsKey(assignedDealer.Id)){
			    	
			    	for (Dealer_Brand__c dBrand : dealersWithBrands.get(assignedDealer.Id).Dealer_Brands__r){
			    		if (dBrand.Brand__c == outgoingNonBaylinerLead.Brand_Code__c) 
			    		{
			    			if (dBrand.Dealer_CRM_System__c == ARI_FOOTSTEPS_CRM_SYSTEM){
			    				outgoingFilteredLeads_ARI.add(outgoingNonBaylinerLead);
			    			}
			    			else if (dBrand.Dealer_CRM_System__c == MARINE_MAX_CRM_SYSTEM){
			    				outgoingFilteredLeads_MarineMax.add(outgoingNonBaylinerLead);
			    			}
			    			else if (dBrand.Dealer_CRM_System__c == IDS_ASTRA_CRM_SYSTEM){
			    				outgoingFilteredLeads_IDS.add(outgoingNonBaylinerLead);
			    			}
			    		}
			    	}
			    }
			}
		}
		
		Map<String, List<Lead>> result = new Map<String, List<Lead>>();
		if (!outgoingFilteredLeads_ARI.isEmpty()){
			result.put(FOOTSTEPS_END_POINT, new List<Lead>(outgoingFilteredLeads_ARI));
		}
		if (!outgoingFilteredLeads_MarineMax.isEmpty()){
			result.put(MARINE_MAX_END_POINT, new List<Lead>(outgoingFilteredLeads_MarineMax));
		}
		if (!outgoingFilteredLeads_IDS.isEmpty()){
			result.put(IDS_ASTRA_END_POINT, new List<Lead>(outgoingFilteredLeads_IDS));
		}
		return result;
	}
	
	@testVisible
	private static String leadFieldValue(Lead outgoingLead, String field, Boolean toFormat){
		String result = '';
		if (outgoingLead != null && outgoingLead.get(field) != null){
			result = toFormat ? ((Datetime)outgoingLead.get(field)).format() : String.valueOf(outgoingLead.get(field));
		}
		return result; 
	}

    
    public static void prepareFootstepsLeadsBatch(List<Lead> leads){
    	for (Lead l : leads){
    		l.Footsteps_Retry__c = true;
    	}
    }
    
    public static void sendFootstepsLeadsBatch(Integer batchSize){
    	
    	SendFootstepsLeadsBatch batch = new SendFootstepsLeadsBatch();
		Database.executeBatch(batch, batchSize);
    	
    }
	
	public static void footstepsFieldsMakeCallout(Set<ID> leadIDs)
    {
    	Map<String, List<Lead>> outgoingLeadsByDestination = filterLeadsWithFootstepsCRMSystem(leadIDs);
    	
    	if (!outgoingLeadsByDestination.isEmpty()){
    		
    		List<String> errors = new List<String>();
    		List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
    	 
    		for (String urlEndPoint : outgoingLeadsByDestination.keySet()){
    		
	    		Map<String, List<Lead>> outgoingLeadsBySource = GroupBy.strings('LeadSource', outgoingLeadsByDestination.get(urlEndPoint));
	    		
	    		Map<String, String> outgoingLeadXMLBySource;
	    		Map<String, String> outgoingLeadIDSXMLBySource;
	    		
	    		if (urlEndPoint.equalsIgnoreCase(IDS_ASTRA_END_POINT)) {
	    			outgoingLeadIDSXMLBySource = generateIDSAstraXMLFromLeadsBySource(outgoingLeadsByDestination.get(urlEndPoint));
	    		} else {
	    			outgoingLeadXMLBySource = generateXMLFromLeadsBySource(outgoingLeadsByDestination.get(urlEndPoint));
	    		}
		    			
	    		List<Lead> allLeadUpdates = new List<Lead>();
	    		
    			if (urlEndPoint == FOOTSTEPS_END_POINT){
    				
		    		for (String leadSource : outgoingLeadXMLBySource.keySet()){
		    			
		    			// send XML payload for each lead source
				    	try{	
			    			Http h = new Http();
						    HttpRequest req = new HttpRequest();
						    req.setHeader(CONTENT_TYPE_HEADER,  CONTENT_TYPE_ARI);
						    req.setEndpoint(urlEndPoint);   
						    req.setTimeout(5000);   
						    req.setMethod('POST');
						    
						    String encodedData = EncodingUtil.urlEncode(outgoingLeadXMLBySource.get(leadSource), 'UTF-8');
						    String postXMLData = 'XML='+encodedData;
						    
						    req.setBody(postXMLData);
						    HttpResponse res = new HttpResponse();
						    if(!Test.isRunningTest()){
						       res = h.send(req);
						    }
						    
						    String resultBody = res.getBody();
						    if (String.isNotBlank(resultBody)){
						    	if (resultBody == '1'){
						    		List<Lead> leadUpdates = outgoingLeadsBySource.get(leadSource);
						    		for (Lead l : leadUpdates){
						    			if (l.Footsteps_Retry__c == true){
						    				l.Footsteps_Retry__c = false;
						    				allLeadUpdates.add(l);
						    			}
						    		}
						    	}
						    	else {
						    		errors.add(FOOTSTEPS_END_POINT + ' : ' + leadSource + ' : ' + 'footsteps returned not successful: ' + resultBody );
						    	}
						    } 
			    		}
			    		catch (Exception e){
			    			errors.add(FOOTSTEPS_END_POINT + ' : ' + leadSource + ' : ' + String.valueOf(e) + ' : ' + e.getStackTraceString() );
			    		}
			    		
			    		Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
			            attachment.setContentType(CONTENT_TYPE);
			            attachment.setFileName('footsteps-ari integration data');
			            attachment.setBody(Blob.valueOf(outgoingLeadXMLBySource.get(leadSource)));     
					    attachments.add(attachment);
		    		}
    			}
	    			
    			if (urlEndPoint == MARINE_MAX_END_POINT){
    				for (String leadSource : outgoingLeadXMLBySource.keySet()){
    					
		    			// send XML payload for each lead source
				    	try{	
			    			Http h = new Http();
						    HttpRequest req = new HttpRequest();
						    req.setHeader(CONTENT_TYPE_HEADER,  CONTENT_TYPE);
                            req.setHeader(AUTH_KEY_HEADER,  MARINE_MAX_AUTH_TOKEN);
                            //req.setClientCertificateName('Marine_Max_Certificate');
						    req.setEndpoint(urlEndPoint);   
						    req.setMethod('POST');
						    req.setTimeout(120000);   
						    req.setBody(outgoingLeadXMLBySource.get(leadSource));
						    HttpResponse res = new HttpResponse();
						    if(!Test.isRunningTest()){
						       res = h.send(req);
						    }
						    Integer resultCode = res.getStatusCode();
					    	if (resultCode == 201){
					    		List<Lead> leadUpdates = outgoingLeadsBySource.get(leadSource);
					    		for (Lead l : leadUpdates){
					    			if (l.Footsteps_Retry__c == true){
					    				l.Footsteps_Retry__c = false;
					    				allLeadUpdates.add(l);
					    			}
					    		}
					    	}
					    	else {
					    		errors.add(MARINE_MAX_END_POINT + ' : ' + leadSource + ' : ' + 'footsteps returned not successful: ' + resultCode );
					    	}
			    		}
			    		catch (Exception e){
			    			errors.add(MARINE_MAX_END_POINT + ' : ' + leadSource + ' : ' + String.valueOf(e) + ' : ' + e.getStackTraceString());
			    		}
			    		
					    Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
			            attachment.setContentType(CONTENT_TYPE);
			            attachment.setFileName('footsteps-marine-max integration data');
			            attachment.setBody(Blob.valueOf(outgoingLeadXMLBySource.get(leadSource)));     
					    attachments.add(attachment);
					    
		    		}
    			}
    			
    			if (urlEndPoint == IDS_ASTRA_END_POINT){
    				
		    		for (String leadSource : outgoingLeadIDSXMLBySource.keySet()){
		    			
		    			// send XML payload for each lead source
				    	try{	
			    			Http h = new Http();
						    HttpRequest req = new HttpRequest();
						    req.setHeader(CONTENT_TYPE_HEADER,  CONTENT_TYPE_ARI);
						    req.setEndpoint(urlEndPoint);   
						    req.setTimeout(5000);   
						    req.setMethod('POST');
						    
						    String encodedData = EncodingUtil.urlEncode(outgoingLeadIDSXMLBySource.get(leadSource), 'UTF-8');
						    String postXMLData = 'type=LEAD&Source=BBG&Destination=820000&XML='+encodedData;
						    system.debug('*********************** IDS Astra post XML data: ' + postXMLData);						    
						    
						    req.setBody(postXMLData);
						    HttpResponse res = new HttpResponse();
						    if(!Test.isRunningTest()){
						       res = h.send(req);
						    }
						    
						    String resultBody = res.getBody();
						    if (String.isNotBlank(resultBody)){
						    	system.debug('*********************** IDS Astra XML post response: ' + resultBody);
						    	if (resultBody.contains('Success')){
						    		List<Lead> leadUpdates = outgoingLeadsBySource.get(leadSource);
						    		for (Lead l : leadUpdates){
						    			if (l.Footsteps_Retry__c == true){
						    				l.Footsteps_Retry__c = false;
						    				allLeadUpdates.add(l);
						    			}
						    		}
						    	}
						    	else {
						    		errors.add(IDS_ASTRA_END_POINT + ' : ' + leadSource + ' : ' + 'IDS returned not successful: ' + resultBody );
						    	}
						    } 
			    		}
			    		catch (Exception e){
			    			errors.add(IDS_ASTRA_END_POINT + ' : ' + leadSource + ' : ' + String.valueOf(e) + ' : ' + e.getStackTraceString() );
			    		}
			    		
			    		Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
			            attachment.setContentType(CONTENT_TYPE);
			            attachment.setFileName('IDS integration data');
			            attachment.setBody(Blob.valueOf(outgoingLeadIDSXMLBySource.get(leadSource)));     
					    attachments.add(attachment);
		    		}
    			}
	    		
	    		if (!allLeadUpdates.isEmpty()){
	    			update allLeadUpdates;
	    		}
    		}
    		
    		if (FOOTSTEPS_SEND_DEBUG_EMAIL || !errors.isEmpty()){
    				 
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailmessage();
	            mail.setToAddresses(CRM_INTEGRATION_ERROR_EMAILS);    		 
	            mail.setSubject('Salesforce CRM Integration Results');    		 
	            mail.setPlainTextBody('CRM integration errors: ' + (!errors.isEmpty() ? String.join(errors, ' \n') : 'No Errors'));
	            mail.setFileAttachments(attachments);
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
	             
    		}
    		
    	}
    	else {
    		System.debug('No Leads to send to Footsteps/ARI, MarineMax, or IDS');
    	}
    }
    
    
    public static Map<Id,Lead> getLeadsWithChangedFootstepsFields(final Map<Id,Lead> triggerOldMap, final Map<Id,Lead> triggerNewMap) {
    	
    	Map<Id, Lead> filteredMap = new Map<Id, Lead>();
    	for (Lead updatedLead : triggerNewMap.values()){
    		for (String leadFieldName : leadFootstepsIntegrationFields){
    			if (triggerOldMap.containsKey(updatedLead.Id) &&
    				updatedLead.get(leadFieldName) != triggerOldMap.get(updatedLead.Id).get(leadFieldName))
				{
    				filteredMap.put(updatedLead.Id, updatedLead);
    			}
    		}
    	}
    	return filteredMap;
    }
    
    
    public static List<String> getDealerNumbers(Lead fromLead){
    	Set<String> dealerNumbers = new Set<String>();
    	for (String crmSystemField : leadFootstepsIntegrationDealerNumberFields){
			List<String> field = crmSystemField.split('\\.', 0);
		    Account assignedDealer = (Account) fromLead.getSobject(field[0]);
		    if (assignedDealer != null){
		        if ( assignedDealer.get(field[1]) != null ){
		        	dealerNumbers.add( String.valueOf( assignedDealer.get(field[1]) ) );
		        }
		    }
		}
		return new List<String>(dealerNumbers);
    }
    
    
    @testVisible 
	private static Map<String, String> leadFormIdentificationNumberMap {
		get {
			if (leadFormIdentificationNumberMap == null){
				leadFormIdentificationNumberMap = new Map<String, String>();
				for (Lead_Form_Settings__c lfs : Lead_Form_Settings__c.getAll().values()){
					//DCH (BS-152) -- Added brand code to the key: lfs.Brand_Code__c + '#' + 
					leadFormIdentificationNumberMap.put( String.valueOf(lfs.Lead_Source__c + '#' + lfs.Brand_Code__c + '#' + lfs.Lead_Form_Name__c).toLowerCase(), lfs.identification_number__c );
				} 
			}
			return leadFormIdentificationNumberMap;
		}
		set;
	}
	
	@testVisible 
	private static Map<String, String> leadFormRequestTypeNumberMap {
		get {
			if (leadFormRequestTypeNumberMap == null){
				leadFormRequestTypeNumberMap = new Map<String, String>();
				for (Lead_Form_Settings__c lfs : Lead_Form_Settings__c.getAll().values()){
					//DCH (BS-152) -- Added brand code to the key: lfs.Brand_Code__c + '#' + 
					leadFormRequestTypeNumberMap.put(String.valueOf(lfs.Lead_Source__c + '#' + lfs.Brand_Code__c + '#' + lfs.Lead_Form_Name__c).toLowerCase(), lfs.internal_request_type_number__c );
				}
			}
			return leadFormRequestTypeNumberMap;
		}
		set;
	}
    
	public static Map<String, String> generateIDSAstraXMLFromLeadsBySource(List<Lead> allOutgoingLeads){
		
		Map<String, String> leadSourceXMLData = new Map<String, String>();
		
		/*
		Map<String, List<Lead>> outgoingLeadsBySource = GroupBy.strings('LeadSource', allOutgoingLeads);
		
		for (String leadSourceName : outgoingLeadsBySource.keySet()){
			
			if (String.isBlank(leadSourceName)) 
			{
				continue;
			}
			
			List<Lead> outgoingLeads = outgoingLeadsBySource.get(leadSourceName);
			
			XmlStreamWriter XML = new XmlStreamWriter();
		
			XML.writeStartDocument('UTF-8', '1.0');
			
			XML.writeStartElement(ELEMENT_PREFIX, 'fsdf', NAMESPACE_URI);
			XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'source', leadSourceName);
			XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'error_notification_address', String.join(CRM_INTEGRATION_ERROR_EMAILS, ';'));

			//Customers - Start
			XML.writeStartElement(ELEMENT_PREFIX, 'customers', NAMESPACE_URI);
			
			for (Lead outgoingLead : outgoingLeads){
				
				ConditionedLead conditionedLead = new ConditionedLead(outgoingLead, leadSourceName);
				
				//Customer - Begin
				XML.writeStartElement(ELEMENT_PREFIX, 'customer', NAMESPACE_URI);
				
					// Destination - Begin
					XML.writeStartElement(ELEMENT_PREFIX, 'destination', NAMESPACE_URI);
						XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', conditionedLead.destinationType);
						
						//TODO: Question to Don, is this the dealer number?  Right now it is form key
						XML.writeStartElement(ELEMENT_PREFIX, 'identification_number', NAMESPACE_URI);
						//XML.writeCData(conditionedLead.destinationIdentificationNumber);
						XML.writeCData('820000');
						XML.writeEndElement();
						
						XML.writeStartElement(ELEMENT_PREFIX, 'dealer_identification_number', NAMESPACE_URI);
						XML.writeCData(String.join(getDealerNumbers(outgoingLead), ','));
						XML.writeEndElement();
						
					XML.writeEndElement();
					//Destination - End
					
					//Name - Start
					XML.writeStartElement(ELEMENT_PREFIX, 'name', NAMESPACE_URI);
					XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'part', 'first');
					XML.writeCData( !String.isBlank(conditionedLead.firstName) ?  conditionedLead.firstName : 'no_first_name' );
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'name', NAMESPACE_URI);
					XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'part', 'last');
					XML.writeCData( !String.isBlank(conditionedLead.lastName) ?  conditionedLead.lastName : 'no_last_name' );
					XML.writeEndElement();
					
					//According to the IDS XML Web Leads document, spouse name is specified as 'spouse_first', 'spouse_last', etc.
					//There is only a single spouse field on the lead.
					XML.writeStartElement(ELEMENT_PREFIX, 'name', NAMESPACE_URI);
					XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'part', 'spouse_first');
					XML.writeCData( conditionedLead.spouseName );
					XML.writeEndElement();
					//Name - End
					
					//Email - Start
					XML.writeStartElement(ELEMENT_PREFIX, 'email', NAMESPACE_URI);
					XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'opt_in', conditionedLead.emailOptIn);
					XML.writeCData( conditionedLead.emailAddress );
					XML.writeEndElement();
					//Email - End
					
					//Contacts - Start
					XML.writeStartElement(ELEMENT_PREFIX, 'contacts', NAMESPACE_URI);
					
						//Addresses - Start
						XML.writeStartElement(ELEMENT_PREFIX, 'addresses', NAMESPACE_URI);
						
							//Address - Start
							XML.writeStartElement(ELEMENT_PREFIX, 'address', NAMESPACE_URI);
								XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', 'home');
							
								XML.writeStartElement(ELEMENT_PREFIX, 'street', NAMESPACE_URI);
								XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'part', '1');
								XML.writeCData( conditionedLead.street );
								XML.writeEndElement();
							
								XML.writeStartElement(ELEMENT_PREFIX, 'city', NAMESPACE_URI);
								XML.writeCData( conditionedLead.city );
								XML.writeEndElement();
							
								XML.writeStartElement(ELEMENT_PREFIX, 'regioncode', NAMESPACE_URI);
								XML.writeCData( conditionedLead.state );
								XML.writeEndElement();
							
								XML.writeStartElement(ELEMENT_PREFIX, 'country', NAMESPACE_URI);
								XML.writeCData( conditionedLead.country );
								XML.writeEndElement();
							
								XML.writeStartElement(ELEMENT_PREFIX, 'postalcode', NAMESPACE_URI);
								XML.writeCData( conditionedLead.zipPostalCode );
								XML.writeEndElement();
							
							XML.writeEndElement(); 
							//Address - End
						
						XML.writeEndElement();
						//Addresses - End
				
						//Phone - Start
						XML.writeStartElement(ELEMENT_PREFIX, 'phone', NAMESPACE_URI);
							XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', 'home');
						
							if (String.isNotBlank(conditionedLead.bestPhone)) {
								XML.writeCData( conditionedLead.bestPhone );
							} else {
								XML.writeCData( conditionedLead.phone );
							}
						XML.writeEndElement();
						//Phone - End
						
					
					XML.writeEndElement();
					//Contacts - End
					
					//Comments - Start
					XML.writeStartElement(ELEMENT_PREFIX, 'comments', NAMESPACE_URI);
						XML.writeCData( conditionedLead.comments );
					XML.writeEndElement();
					//Comments - End
					
					//Units - Start
					XML.writeStartElement(ELEMENT_PREFIX, 'units', NAMESPACE_URI);
				
						//Unit - Start
						XML.writeStartElement(ELEMENT_PREFIX, 'unit', NAMESPACE_URI);
							XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'definition', 'I');
							
							XML.writeStartElement(ELEMENT_PREFIX, 'identification_number', NAMESPACE_URI);
								XML.writeCData( conditionedLead.hinNumber );
							XML.writeEndElement();
							
							XML.writeStartElement(ELEMENT_PREFIX, 'year', NAMESPACE_URI);
								XML.writeCData( conditionedLead.boatYear );
							XML.writeEndElement();
							
							XML.writeStartElement(ELEMENT_PREFIX, 'make', NAMESPACE_URI);
								XML.writeCData( conditionedLead.brandInterest );
							XML.writeEndElement();
							
							XML.writeStartElement(ELEMENT_PREFIX, 'model', NAMESPACE_URI);
								XML.writeCData( conditionedLead.modelOfInterest  );
							XML.writeEndElement();
							
							XML.writeStartElement(ELEMENT_PREFIX, 'category', NAMESPACE_URI);
								XML.writeCData( conditionedLead.boatCategoryOfInterest );
							XML.writeEndElement();
							
							XML.writeStartElement(ELEMENT_PREFIX, 'type', NAMESPACE_URI);
								XML.writeCData( 'N' );
							XML.writeEndElement();
						
						XML.writeEndElement();
						//Unit - End
						
					XML.writeEndElement();
					//Units - End
					
					//End of defined XML per IDS provided "fdsf_generated.xsd"
					
					//The following XML nodes are valid per IDS "IDS XML Web Leads.docx"
					/*
					XML.writeStartElement(ELEMENT_PREFIX, 'identification_numbers', NAMESPACE_URI); 
					
						XML.writeStartElement(ELEMENT_PREFIX, 'internal_request_type_number', NAMESPACE_URI);
						XML.writeCData(internalRequestTypeNumber);
						XML.writeEndElement();
						
						XML.writeStartElement(ELEMENT_PREFIX, 'internal_model_number', NAMESPACE_URI);
						XML.writeCData(internalModelNumber);
						XML.writeEndElement();
						
					XML.writeEndElement();

					
					XML.writeStartElement(ELEMENT_PREFIX, 'owner', NAMESPACE_URI);
					XML.writeCData( conditionedLead.firstTimeBoatOwner );
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'purchase_time', NAMESPACE_URI);
					XML.writeCData( conditionedLead.buyingHorizon );
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'company', NAMESPACE_URI);
					XML.writeCData( conditionedLead.company );
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'job_title', NAMESPACE_URI);
					XML.writeCData( conditionedLead.currentJobTitle );
					XML.writeEndElement();
					
					// BS-244 Remove origination_date
					// XML.writeStartElement(ELEMENT_PREFIX, 'origination_date', NAMESPACE_URI);
					// XML.writeCData( conditionedLead.originationDate );
					// XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'industry', NAMESPACE_URI);
					XML.writeCData( conditionedLead.industry ); 
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'contact_time', NAMESPACE_URI);
					XML.writeCData( conditionedLead.bestTimeToContact );
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'contact_method', NAMESPACE_URI);
					XML.writeCData( conditionedLead.preferedContactMethod  );
					XML.writeEndElement();
					
					if (String.isNotBlank(conditionedLead.leadScore)){
		                XML.writeStartElement(ELEMENT_PREFIX, 'scoring', NAMESPACE_URI);
		                XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', 'PVI');
		                XML.writeStartElement(ELEMENT_PREFIX, 'numeric_score', NAMESPACE_URI);
		                XML.writeCData( conditionedLead.leadScore  );
		                XML.writeEndElement();
		                XML.writeEndElement();
					}
					
					XML.writeEndElement(); // end <customer> 
				}
			
			XML.writeEndDocument();
			
			leadSourceXMLData.put(leadSourceName, XML.getXmlString());
		}
		*/
		
		return leadSourceXMLData;
	}
	
	
	public static Map<String, String> generateXMLFromLeadsBySource(List<Lead> allOutgoingLeads){
		
		Map<String, String> leadSourceXMLData = new Map<String, String>();
		
		Map<String, List<Lead>> outgoingLeadsBySource = GroupBy.strings('LeadSource', allOutgoingLeads);
		
		for (String leadSourceName : outgoingLeadsBySource.keySet()){
			
			if (String.isBlank(leadSourceName)) 
			{
				continue;
			}
			
			List<Lead> outgoingLeads = outgoingLeadsBySource.get(leadSourceName);
			
			XmlStreamWriter XML = new XmlStreamWriter();
		
			XML.writeStartDocument('UTF-8', '1.0');
			
			XML.writeStartElement(ELEMENT_PREFIX, 'fsdf', NAMESPACE_URI);
			XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'source', leadSourceName);
			XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'notification_address', String.join(CRM_INTEGRATION_ERROR_EMAILS, ';'));
			
			XML.writeStartElement(ELEMENT_PREFIX, 'customers', NAMESPACE_URI);
			
			for (Lead outgoingLead : outgoingLeads){
				
				ConditionedLead conditionedLead = new ConditionedLead(outgoingLead, leadSourceName);
				
				XML.writeStartElement(ELEMENT_PREFIX, 'customer', NAMESPACE_URI);
				
				// LEAD SOURCE SECTION  - BEGIN 
				XML.writeStartElement(ELEMENT_PREFIX, 'destination', NAMESPACE_URI);
					XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', conditionedLead.destinationType);
					
					XML.writeStartElement(ELEMENT_PREFIX, 'identification_number', NAMESPACE_URI);
					XML.writeCData(conditionedLead.destinationIdentificationNumber);
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'dealer_identification_code', NAMESPACE_URI);
					XML.writeCData(String.join(getDealerNumbers(outgoingLead), ','));
					XML.writeEndElement();
					
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'identification_numbers', NAMESPACE_URI); 
				
					XML.writeStartElement(ELEMENT_PREFIX, 'internal_request_type_number', NAMESPACE_URI);
					XML.writeCData(conditionedLead.internalRequestTypeNumber);
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'internal_model_number', NAMESPACE_URI);
					XML.writeCData(conditionedLead.internalModelNumber);
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'form_name', NAMESPACE_URI);
					XML.writeCData( conditionedLead.webFormName );
					XML.writeEndElement();
					
				XML.writeEndElement();
				
				// LEAD SOURCE SECTION  - END  
				
				// LEAD INFORMATION - BEGIN 
				
				XML.writeStartElement(ELEMENT_PREFIX, 'owner', NAMESPACE_URI);
				XML.writeCData( conditionedLead.firstTimeBoatOwner );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'purchase_time', NAMESPACE_URI);
				XML.writeCData( conditionedLead.buyingHorizon );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'birth_date', NAMESPACE_URI);
				XML.writeCData( conditionedLead.birthday );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'company', NAMESPACE_URI);
				XML.writeCData( conditionedLead.company );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'job_title', NAMESPACE_URI);
				XML.writeCData( conditionedLead.currentJobTitle );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'name', NAMESPACE_URI);
				XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'part', 'first');
				XML.writeCData( !String.isBlank(conditionedLead.firstName) ?  conditionedLead.firstName : 'no_first_name' );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'name', NAMESPACE_URI);
				XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'part', 'last');
				XML.writeCData( !String.isBlank(conditionedLead.lastName) ?  conditionedLead.lastName : 'no_last_name' );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'name', NAMESPACE_URI);
				XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'part', 'spouse');
				XML.writeCData( conditionedLead.spouseName );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'email', NAMESPACE_URI);
				XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'opt_in', conditionedLead.emailOptIn);
				XML.writeCData( conditionedLead.emailAddress );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'postalcode', NAMESPACE_URI);
				XML.writeCData( conditionedLead.zipPostalCode );
				XML.writeEndElement();
				
				// BS-244 Remove origination_date
				// XML.writeStartElement(ELEMENT_PREFIX, 'origination_date', NAMESPACE_URI);
				// XML.writeCData( conditionedLead.originationDate );
				// XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'industry', NAMESPACE_URI);
				XML.writeCData( conditionedLead.industry ); 
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'contact_time', NAMESPACE_URI);
				XML.writeCData( conditionedLead.bestTimeToContact );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'contact_method', NAMESPACE_URI);
				XML.writeCData( conditionedLead.preferedContactMethod  );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'comments', NAMESPACE_URI);
				XML.writeCData( conditionedLead.comments );
				XML.writeEndElement();
				
				if (String.isNotBlank(conditionedLead.leadScore)){
	                XML.writeStartElement(ELEMENT_PREFIX, 'scoring', NAMESPACE_URI);
	                XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', 'PVI');
	                XML.writeStartElement(ELEMENT_PREFIX, 'numeric_score', NAMESPACE_URI);
	                XML.writeCData( conditionedLead.leadScore  );
	                XML.writeEndElement();
	                XML.writeEndElement();
				}
                
				XML.writeStartElement(ELEMENT_PREFIX, 'units', NAMESPACE_URI);
				
				XML.writeStartElement(ELEMENT_PREFIX, 'unit', NAMESPACE_URI);
				XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'definition', 'I');
				
				/*XML.writeStartElement(ELEMENT_PREFIX, 'type', NAMESPACE_URI);
				XML.writeCharacters( previosPurchaseNewOrUsed  );
				XML.writeEndElement();*/
				
				XML.writeStartElement(ELEMENT_PREFIX, 'year', NAMESPACE_URI);
				XML.writeCData( conditionedLead.boatYear );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'make', NAMESPACE_URI);
				XML.writeCData( conditionedLead.brandInterest );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'model', NAMESPACE_URI);
				XML.writeCData( conditionedLead.modelOfInterest  );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'category', NAMESPACE_URI);
				XML.writeCData( conditionedLead.boatCategoryOfInterest );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'identification_number', NAMESPACE_URI);
				XML.writeCData( conditionedLead.hinNumber );
				XML.writeEndElement();
				
				XML.writeEndElement();
				XML.writeEndElement();
				
				
				XML.writeStartElement(ELEMENT_PREFIX, 'contacts', NAMESPACE_URI);
				
				XML.writeStartElement(ELEMENT_PREFIX, 'phone', NAMESPACE_URI);
				XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', 'home');
				
				if (String.isNotBlank(conditionedLead.bestPhone)) {
					XML.writeCData( conditionedLead.bestPhone );
				} else {
					XML.writeCData( conditionedLead.phone );
				}
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'addresses', NAMESPACE_URI);
				
				XML.writeStartElement(ELEMENT_PREFIX, 'address', NAMESPACE_URI);
				XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', 'home');
				
				XML.writeStartElement(ELEMENT_PREFIX, 'street', NAMESPACE_URI);
				XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'part', '1');
				XML.writeCData( conditionedLead.street );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'city', NAMESPACE_URI);
				XML.writeCData( conditionedLead.city );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'regioncode', NAMESPACE_URI);
				XML.writeCData( conditionedLead.state );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'country', NAMESPACE_URI);
				XML.writeCData( conditionedLead.country );
				XML.writeEndElement();
				
				XML.writeStartElement(ELEMENT_PREFIX, 'postalcode', NAMESPACE_URI);
				XML.writeCData( conditionedLead.zipPostalCode );
				XML.writeEndElement();
				
				XML.writeEndElement(); // address
				
				XML.writeEndElement(); // addressess
				
				XML.writeEndElement(); // contacts
				
				// LEAD INFORMATION - END 
				
				XML.writeEndElement(); // end <customer> 
			}
			
			XML.writeEndDocument();
			
			leadSourceXMLData.put(leadSourceName, XML.getXmlString());
		}
		
		return leadSourceXMLData;
	}	
	
	private class ConditionedLead {
		
		String destinationType = 'oem';
		String destinationIdentificationNumber = '';
		String dealerIdentificationCode = '';
		String internalRequestTypeNumber = '';	
		String internalModelNumber = '';
		String industry;
		String originationDate;
		String firstName;
		String lastName;
		String emailAddress;
		String zipPostalCode;
		String street;
		String city;
		String state;
		String country;
		String phone;
		String bestPhone;
		String modelOfInterest;
		String boatCategoryOfInterest;
		String hinNumber;
		String comments;
		String firstTimeBoatOwner;
		String buyingHorizon;
		String webFormName;
		String birthday;
		String bestTimeToContact;
		String company;
		String currentJobTitle;
		String spouseName;
		String brandInterest;
		String preferedContactMethod;
		String boatYear;
		String leadScore;
		String tradeInModel;
		String tradeInYear;
		String tradeInComments;
		String emailOptIn;
		String towVehicle = '';
		String previousOwner = '';
		String previosPurchaseNewOrUsed = '';
		String notes = '';
		List<Task> tasks;
		
		
		private ConditionedLead(Lead lead, String leadSourceName) {
			this.destinationType = 'dealer';
			this.industry	 = 'Boats'; 
			this.originationDate = leadFieldValue(lead, 'CreatedDate', true );
			this.firstName = leadFieldValue(lead, 'FirstName', false);
			this.lastName = leadFieldValue(lead, 'LastName', false ) ;
			this.emailAddress = leadFieldValue(lead, 'Email', false ) ;
			this.zipPostalCode = leadFieldValue(lead, 'PostalCode', false ) ;
			this.street = leadFieldValue(lead, 'Street', false ) ;
			this.city = leadFieldValue(lead, 'City', false ) ;
			this.state = leadFieldValue(lead, 'State', false );
			this.country = leadFieldValue(lead, 'Country', false );
			this.phone = leadFieldValue(lead, 'Phone', false ) ;
			this.bestPhone = leadFieldValue(lead, 'Best_Phone__c', false ) ;
			this.modelOfInterest = leadFieldValue(lead, 'Boat_Model_Interest__c', false );
			this.boatCategoryOfInterest = leadFieldValue(lead, 'Boat_Category_of_Interest__c', false );
			this.hinNumber = leadFieldValue(lead, 'Hull_Identification_Number_HIN__c', false ) ;
			this.comments	= leadFieldValue(lead, 'Comments__c', false );
			this.firstTimeBoatOwner = leadFieldValue(lead, 'First_Time_Boat_Owner__c', false ) == 'true' ? 'Yes' : 'No' ;
			this.buyingHorizon = leadFieldValue(lead, 'Buying_horizon__c', false )  ;
			this.webFormName = leadFieldValue(lead, 'Lead_Form_Name__c', false );
			this.birthday = leadFieldValue(lead, 'Birthday__c', true ) ;
			this.bestTimeToContact = leadFieldValue(lead, 'Best_Time_to_Contact__c', false ) ;
			this.company = leadFieldValue(lead, 'Company', false ) ;
			this.currentJobTitle = leadFieldValue(lead, 'Occupation_Title__c', false ) ;
			this.spouseName = leadFieldValue(lead, 'Spouse_Name__c', false ) ;
			this.brandInterest = leadFieldValue(lead, 'Brand_Interest__c', false ) ;
			this.preferedContactMethod = leadFieldValue(lead, 'Preferred_method_of_contact__c', false );
			this.boatYear = leadFieldValue(lead, 'Boat_Year_Interest__c', false ) ;
            this.leadScore = leadFieldValue(lead, 'pi__score__c', false ) ;
			this.tradeInModel = leadFieldValue(lead, 'Trade_In_Model__c', false );
			this.tradeInYear = leadFieldValue(lead, 'Trade_In_Year__c', false );
			this.tradeInComments = leadFieldValue(lead, 'Trade_In_Comments__c', false );
			this.emailOptIn = leadFieldValue(lead, 'Email_Opt_in__c', false ) == 'No' ? 'N' : 'Y';
			this.notes = leadFieldValue(lead, 'Notes__c', false );
			
			// this.tasks = lead.getSObjects('tasks');
			
			comments += '\n Trade-In Model: ' +  this.tradeInModel;
			comments += '\n Trade-In Year: ' +  this.tradeInYear;
			comments += '\n Trade-In Comments: ' +  this.tradeInComments;
			comments += '\n Notes: ' +  notes;
		
			//Get the Pardot Score Increase Trigger Custom Setting accumulated point total for the lead's brand
			Pardot_Score_Increase_Trigger__c psit = null; // pardotScoreIncreaseTriggers.get(lead.Brand_Code__c);
    			
			if (psit != null) {
				if (tasks != null && !tasks.isEmpty()) {
					comments += '\nLead Activities:\n';
					for (Integer x = 0; x < Math.min(tasks.size(), psit.Days_Of_Activities__c.intValue()); x++) {
						Task task = tasks[x];
						comments += task.LastModifiedDate.format() + ' - ' + task.Subject + ' \n';
					}
				}
			} else {
				system.debug('*********************** No Pardot Score Increase Trigger custom setting entry for brand: '+ lead.Brand_Code__c);
			}
			
			//DCH (BS-152) -- Added brand code to the key: outgoingLead.Brand_Code__c + '#' + 
			String leadFormKey = String.valueOf(leadSourceName + '#' + lead.Brand_Code__c + '#' + lead.Lead_Form_Name__c).toLowerCase();
			
			if (leadFormIdentificationNumberMap.containsKey(leadFormKey)){
				destinationIdentificationNumber = leadFormIdentificationNumberMap.get(leadFormKey);
			}
			
			if (leadFormRequestTypeNumberMap.containsKey(leadFormKey)){
				internalRequestTypeNumber = leadFormRequestTypeNumberMap.get(leadFormKey);
			}
		
		}
		
	}

}