public with sharing virtual class FootStepsService {
	
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
	
	/*public static String IDS_ASTRA_END_POINT { 
		get{
			if (IDS_ASTRA_END_POINT == null){ 
				IDS_ASTRA_END_POINT = Footsteps_Integration_Settings__c.getInstance().IDS_Astra_Endpoint__c;	  
			}
			return IDS_ASTRA_END_POINT;
		}
		set;
	}*/
	
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
	
	protected virtual List<FootstepsModel> getFootstepsModelsFrom(map<Id, set<Id>> idToDealerIdMap) {
		return new List<FootstepsModel>();
	}
	
	public Map<String, List<FootstepsModel>> filterLeadsWithFootstepsCRMSystem(map<Id, set<Id>> idToDealerIdMap){

    	
    	List<FootstepsModel> outgoingLeads = getFootstepsModelsFrom(idToDealerIdMap);

		/*
		essentially: 
			if (bayliner){ look at dealer crm system }
			else { look at dealer_brand crm_system } 
		*/
		
		Set<FootstepsModel> outgoingFilteredLeads_ARI = new Set<FootstepsModel>();
		Set<FootstepsModel> outgoingFilteredLeads_MarineMax = new Set<FootstepsModel>();
		Set<FootstepsModel> outgoingFilteredLeads_IDS = new Set<FootstepsModel>();
		
		Set<Id> nonBaylinerDealerIds = new Set<Id>();
		List<FootstepsModel> nonBaylinerLeads = new List<FootstepsModel>();
		
		for (FootstepsModel outgoingLead : outgoingLeads){
			//BS-192 - XML Dealer Routing needs to account for Do Not Send custom settings
			if (!isLeadSendable(outgoingLead.brandCode, outgoingLead.leadFormName)) {
				System.debug('Not sending lead because brand Code is: ' + outgoingLead.brandCode + ' and lead form name is: ' +outgoingLead.leadFormName);
				continue;
			}
			
			system.debug('Lead is sendable');
			
			if (outgoingLead.brandCode == BAYLINER_BRAND_CODE){
				for (String crmSystem : outgoingLead.assignedDealerIdToCRMSystemMap.values()){
					if (crmSystem == ARI_FOOTSTEPS_CRM_SYSTEM){
						outgoingFilteredLeads_ARI.add(outgoingLead);
						system.debug('Lead with ID: ' + outgoingLead.sourceId + ' will be sent to CRM: ' + ARI_FOOTSTEPS_CRM_SYSTEM);
				    }
				}
			}
			else { 
				Boolean atLeastOneAssignedDealer = false;
				for (Id dealerAccountId : outgoingLead.assignedDealerIdToCRMSystemMap.keySet()){
					atLeastOneAssignedDealer = true;
					nonBaylinerDealerIds.add(dealerAccountId);
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
		
		for (FootstepsModel outgoingNonBaylinerLead : nonBaylinerLeads){
			for (Id dealerAccountId : outgoingNonBaylinerLead.assignedDealerIdToCRMSystemMap.keySet()){
			    if (dealersWithBrands.containsKey(dealerAccountId)){
			    	system.debug('lead brand code: ' + outgoingNonBaylinerLead.brandCode);
			    	for (Dealer_Brand__c dBrand : dealersWithBrands.get(dealerAccountId).Dealer_Brands__r){
			    		system.debug('dealer brand code: ' + dBrand.Brand__c);
			    		if (dBrand.Brand__c == outgoingNonBaylinerLead.brandCode) 
			    		{
			    			if (dBrand.Dealer_CRM_System__c == ARI_FOOTSTEPS_CRM_SYSTEM){
			    				outgoingFilteredLeads_ARI.add(outgoingNonBaylinerLead);
			    				system.debug('Lead with ID: ' + outgoingNonBaylinerLead.sourceId + ' will be sent to CRM: ' + ARI_FOOTSTEPS_CRM_SYSTEM);
			    			}
			    			else if (dBrand.Dealer_CRM_System__c == MARINE_MAX_CRM_SYSTEM){
			    				outgoingFilteredLeads_MarineMax.add(outgoingNonBaylinerLead);
			    				system.debug('Lead with ID: ' + outgoingNonBaylinerLead.sourceId + ' will be sent to CRM: ' + MARINE_MAX_CRM_SYSTEM);
			    			}
			    			else if (dBrand.Dealer_CRM_System__c == IDS_ASTRA_CRM_SYSTEM){
			    				outgoingFilteredLeads_IDS.add(outgoingNonBaylinerLead);
			    				system.debug('Lead with ID: ' + outgoingNonBaylinerLead.sourceId + ' will be sent to CRM : ' + IDS_ASTRA_CRM_SYSTEM);
			    			}
			    			else {
			    				system.debug('No dealer CRM system found for Lead with ID: ' + outgoingNonBaylinerLead.sourceId + ' it will not be sent');
			    			}
			    		}
			    	}
			    }
			}
		}
		
		Map<String, List<FootstepsModel>> result = new Map<String, List<FootstepsModel>>();
		if (!outgoingFilteredLeads_ARI.isEmpty()){
			result.put(FOOTSTEPS_END_POINT, new List<FootstepsModel>(outgoingFilteredLeads_ARI));
		}
		if (!outgoingFilteredLeads_MarineMax.isEmpty()){
			result.put(MARINE_MAX_END_POINT, new List<FootstepsModel>(outgoingFilteredLeads_MarineMax));
		}
		/*if (!outgoingFilteredLeads_IDS.isEmpty()){
			result.put(IDS_ASTRA_END_POINT, new List<FootstepsModel>(outgoingFilteredLeads_IDS));
		}*/
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
    
    
    public void footstepsFieldsMakeCallout(Set<ID> ids) {
    	map<Id, set<Id>> idToDealerIdMap = new map<Id, set<Id>>();
    	
    	for (Id id : ids) {
    		idToDealerIdMap.put(id, new Set<Id>());
    	}
    	
    	footstepsFieldsMakeCallout(idToDealerIdMap);
    }
    
    public void footstepsFieldsMakeCallout(map<Id, set<Id>> idToDealerIdMap) {
    	set<Id> ids = idToDealerIdMap.keySet();
    	Map<String, List<FootstepsModel>> outgoingLeadsByDestination = filterLeadsWithFootstepsCRMSystem(idToDealerIdMap);
    	
    	if (!outgoingLeadsByDestination.isEmpty()){
    		system.debug('There are ' + outgoingLeadsByDestination.size() + ' outgoing leads by destination');
    		List<String> errors = new List<String>();
    		List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
    	 
    		for (String urlEndPoint : outgoingLeadsByDestination.keySet()){
    		
	    		//Map<String, List<Lead>> outgoingLeadsBySource = GroupBy.strings('LeadSource', outgoingLeadsByDestination.get(urlEndPoint));
	    		Map<String, List<FootstepsModel>> outgoingLeadsBySource = new Map<String, List<FootstepsModel>>();
	    		for (FootstepsModel model : outgoingLeadsByDestination.get(urlEndPoint)) {
	    			if (!outgoingLeadsBySource.containsKey(model.leadSource)) {
	    				outgoingLeadsBySource.put(model.leadSource, new List<FootstepsModel>());
	    			}
	    			outgoingLeadsBySource.get(model.leadSource).add(model);
	    		}
	    		
	    		Map<String, String> outgoingLeadXMLBySource = generateXMLFromLeadsBySource(outgoingLeadsByDestination.get(urlEndPoint));
		    			
	    		List<FootstepsModel> footStepsRetrySuccess = new List<FootstepsModel>();
	    		
    			if (urlEndPoint == FOOTSTEPS_END_POINT){
    				system.debug('Sending: ' + outgoingLeadXMLBySource.keySet().size() + ' XML messages for urlEndPoint: ' + urlEndPoint);
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
						    String postXMLData = 'xml='+encodedData;
						    
						    req.setBody(postXMLData);
						    HttpResponse res = new HttpResponse();
						    if(!Test.isRunningTest() && FootstepsService.SEND_FOOTSTEPS_LEADS){
						       res = h.send(req);
						    }
						    else {
						    	system.debug('Would have sent XML to endpoint: ' + urlEndPoint);
						    	system.debug('postXMLData: ' + postXMLData);
						    }
						    
						    String resultBody = res.getBody();
						    if (String.isNotBlank(resultBody)){
						    	if (resultBody == '1'){
						    		List<FootstepsModel> leadUpdates = outgoingLeadsBySource.get(leadSource);
						    		for (FootstepsModel l : leadUpdates){
						    			if (l.footStepsRetry){
						    				footStepsRetrySuccess.add(l);
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
	    			
    			else if (urlEndPoint == MARINE_MAX_END_POINT){
    				system.debug('Sending: ' + outgoingLeadXMLBySource.keySet().size() + ' XML messages for urlEndPoint: ' + urlEndPoint);
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
						    if(!Test.isRunningTest() && FootstepsService.SEND_FOOTSTEPS_LEADS){
						       res = h.send(req);
						    }
						    else {
						    	system.debug('Would have sent XML to endpoint: ' + urlEndPoint);
						    	system.debug('postXMLData: ' + outgoingLeadXMLBySource.get(leadSource));
						    }
						    
						    Integer resultCode = res.getStatusCode();
					    	if (resultCode == 201){
					    		List<FootstepsModel> leadUpdates = outgoingLeadsBySource.get(leadSource);
					    		for (FootStepsModel l : leadUpdates){
					    			if (l.footStepsRetry){
					    				footStepsRetrySuccess.add(l);
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
    			else {
    				system.debug('Not sending footsteps XML for urlEndpoint: ' + urlEndpoint);
				}
	    		
	    		if (!footStepsRetrySuccess.isEmpty()){
	    			// TODO update all the footStepsRetrySuccess and set the footsteps retry false;
	    			// update allLeadUpdates;
	    		}
    		}
    		

    		
    		if (FOOTSTEPS_SEND_DEBUG_EMAIL || !errors.isEmpty()){
    				 
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailmessage();
	            mail.setToAddresses(CRM_INTEGRATION_ERROR_EMAILS);    		 
	            mail.setSubject('footsteps integration errors');    		 
	            mail.setPlainTextBody('footsteps integration errors: ' + (!errors.isEmpty() ? String.join(errors, ' \n') : 'No Errors'));
	            mail.setFileAttachments(attachments);
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
	             
    		}
    		
    	}
    	else {
    		System.debug('No Leads to send to Footsteps/ARI or MarineMax');
    	}
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
    
	public Map<String, String> generateIDSAstraXMLFromLeadsBySource(List<FootstepsModel> allOutgoingLeads){
		
		Map<String, String> leadSourceXMLData = new Map<String, String>();
		
		//Map<String, List<Lead>> outgoingLeadsBySource = GroupBy.strings('LeadSource', allOutgoingLeads);
		Map<String, List<FootStepsModel>> outgoingLeadsBySource = new Map<String, List<FootStepsModel>>();
		for (FootstepsModel model : allOutgoingLeads) {
			if (!outgoingLeadsBySource.containsKey(model.leadSource)) {
				outgoingLeadsBySource.put(model.leadSource, new List<FootStepsModel>());
			}
			outgoingLeadsBySource.get(model.leadSource).add(model);
		}
		
		for (String leadSourceName : outgoingLeadsBySource.keySet()){
			
			if (String.isBlank(leadSourceName)) 
			{
				continue;
			}
			
			List<FootStepsModel> outgoingLeads = outgoingLeadsBySource.get(leadSourceName);
			
			XmlStreamWriter XML = new XmlStreamWriter();
		
			XML.writeStartDocument('UTF-8', '1.0');
			
			XML.writeStartElement(ELEMENT_PREFIX, 'fsdf', NAMESPACE_URI);
			XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'source', leadSourceName);
			XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'error_notification_address', String.join(CRM_INTEGRATION_ERROR_EMAILS, ';'));

			//Customers - Start
			XML.writeStartElement(ELEMENT_PREFIX, 'customers', NAMESPACE_URI);
			
			for (FootStepsModel outgoingLead : outgoingLeads){
				
				//ConditionedLead conditionedLead = new ConditionedLead(outgoingLead, leadSourceName);
				FootStepsModel conditionedLead = outgoingLead;
				
				//Customer - Begin
				XML.writeStartElement(ELEMENT_PREFIX, 'customer', NAMESPACE_URI);
				
					// Destination - Begin
					XML.writeStartElement(ELEMENT_PREFIX, 'destination', NAMESPACE_URI);
						XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', conditionedLead.destinationType);
						
						//TODO: Question to Don, is this the dealer number?  Right now it is form key
						XML.writeStartElement(ELEMENT_PREFIX, 'identification_number', NAMESPACE_URI);
						XML.writeCData(conditionedLead.destinationIdentificationNumber);
						XML.writeEndElement();
						
						XML.writeStartElement(ELEMENT_PREFIX, 'dealer_identification_number', NAMESPACE_URI);
						XML.writeCData(String.join(new List<String>(outgoingLead.dealerAccountNumbersSet), ','));
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
					*/
					
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
					
					// BS-385
					XML.writeStartElement(ELEMENT_PREFIX, 'origination_date', NAMESPACE_URI);
					XML.writeCData( conditionedLead.originationDate );
					XML.writeEndElement();
					
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
		
		return leadSourceXMLData;
	}
	
	
	public Map<String, String> generateXMLFromLeadsBySource(List<FootstepsModel> allOutgoingLeads){
		
		Map<String, String> leadSourceXMLData = new Map<String, String>();
		
		//Map<String, List<Lead>> outgoingLeadsBySource = GroupBy.strings('LeadSource', allOutgoingLeads);
		Map<String, List<FootstepsModel>> outgoingLeadsBySource = new Map<String, List<FootstepsModel>>();
		for (FootstepsModel model : allOutgoingLeads) {
			if (!outgoingLeadsBySource.containsKey(model.leadSource)) {
				outgoingLeadsBySource.put(model.leadSource, new List<FootstepsModel>());
			}
			system.debug('assigning model to lead source group: ' + model.leadSource);
			outgoingLeadsBySource.get(model.leadSource).add(model);
		}
		
		for (String leadSourceName : outgoingLeadsBySource.keySet()){
			
			if (String.isBlank(leadSourceName)) 
			{
				system.debug('found blank lead source skipping');
				continue;
			}
			
			List<FootstepsModel> outgoingLeads = outgoingLeadsBySource.get(leadSourceName);
			
			XmlStreamWriter XML = new XmlStreamWriter();
		
			XML.writeStartDocument('UTF-8', '1.0');
			
			XML.writeStartElement(ELEMENT_PREFIX, 'fsdf', NAMESPACE_URI);
			XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'source', leadSourceName);
			XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'notification_address', String.join(CRM_INTEGRATION_ERROR_EMAILS, ';'));
			
			XML.writeStartElement(ELEMENT_PREFIX, 'customers', NAMESPACE_URI);
			
			for (FootstepsModel outgoingLead : outgoingLeads){
				
				//ConditionedLead conditionedLead = new ConditionedLead(outgoingLead, leadSourceName);
				FootstepsModel conditionedLead = outgoingLead;
				
				XML.writeStartElement(ELEMENT_PREFIX, 'customer', NAMESPACE_URI);
				
				// LEAD SOURCE SECTION  - BEGIN 
				XML.writeStartElement(ELEMENT_PREFIX, 'destination', NAMESPACE_URI);
					XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'type', conditionedLead.destinationType);
					
					XML.writeStartElement(ELEMENT_PREFIX, 'identification_number', NAMESPACE_URI);
					XML.writeCData(conditionedLead.destinationIdentificationNumber);
					XML.writeEndElement();
					
					XML.writeStartElement(ELEMENT_PREFIX, 'dealer_identification_code', NAMESPACE_URI);
					XML.writeCData(String.join(new List<String>(outgoingLead.dealerAccountNumbersSet), ','));
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
				
				// BS-385
				XML.writeStartElement(ELEMENT_PREFIX, 'origination_date', NAMESPACE_URI);
				XML.writeCData( conditionedLead.originationDate );
				XML.writeEndElement();
				
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
				

				if (conditionedLead.boatRelationShips != null && !conditionedLead.boatRelationShips.isEmpty()) {
					// write any previously owned boat "unit" elements
					for (Owner_Boat_Relationship__c obr : conditionedLead.boatRelationShips) {
						XML.writeStartElement(ELEMENT_PREFIX, 'unit', NAMESPACE_URI);
						XML.writeAttribute(ELEMENT_PREFIX, NAMESPACE_URI, 'definition', obr.status__c == 'Active' ? 'C' : 'P');
						
						XML.writeStartElement(ELEMENT_PREFIX, 'year', NAMESPACE_URI);
						XML.writeCData( obr.Hin_Number__r.model_year__c );
						XML.writeEndElement();
						
						XML.writeStartElement(ELEMENT_PREFIX, 'make', NAMESPACE_URI);
						XML.writeCData( obr.Hin_Number__r.brand_del__c );
						XML.writeEndElement();
						
						XML.writeStartElement(ELEMENT_PREFIX, 'model', NAMESPACE_URI);
						XML.writeCData( obr.Hin_Number__r.boat_model__c );
						XML.writeEndElement();
						
						XML.writeStartElement(ELEMENT_PREFIX, 'category', NAMESPACE_URI);
						XML.writeCData( obr.Hin_Number__r.boat_class__c );
						XML.writeEndElement();
						
						XML.writeStartElement(ELEMENT_PREFIX, 'identification_number', NAMESPACE_URI);
						XML.writeCData( obr.Hin_Number__r.name );
						XML.writeEndElement();
						
						XML.writeEndElement();
					}
				}
				
				// end "units" element
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

}