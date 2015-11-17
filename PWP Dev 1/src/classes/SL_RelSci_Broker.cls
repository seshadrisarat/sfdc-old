public class SL_RelSci_Broker{
	enum RelationshipStrength {Weak, Average, Strong}
	enum RestVerb {POST, GET}
	
	static boolean m_IsEnabled = true;
	static string m_apiURL = '';
	static string m_apiUsername = '';
	static string m_apiPW = '';
	static string m_relationship_strength = '';
	static string m_debugRelsciUserId = '';
	static string m_RelsciUserId = '';

	static String s_syncversion;
	private string m_SyncVersion = '';

	public String SyncVersion{
	 get{ return m_SyncVersion;}
	 set{ m_SyncVersion = value;}	
	
	}
	//public SL_RelSci_Broker(String apiUser, String apiPassword) {
	//	m_apiUsername = apiUser;
	//	m_apiPW = apiPassword;
		//todo: move to get api from database object
	//	m_apiURL = 'https://sf.relsci.com/v1/';
	//}

	public static Boolean IsIntegrationEnabled(){

		hydrateBrokerSettings('');
		return m_IsEnabled;
	}
	
	public  static void hydrateBrokerSettings(String userIdentifier){
		//todo: move to get api from database object
		RelSciIntegration__c relsci = RelSciIntegration__c.getOrgDefaults();

	
		m_IsEnabled = relsci.Enabled__c;
		m_apiUsername = relsci.API_Username__c;
		m_apiPW = relsci.API_Password__c;
		m_apiURL = relsci.API_URL__c;

		// If Debug User is set in org defaults, then always use this user as the 'RelSci username'
		m_debugRelsciUserId = relsci.Debug_RelSci_Username__c;

		//If not debug, then try to set as passed-in user
		if (String.isEmpty(m_debugRelsciUserId)){
			m_RelsciUserId = userIdentifier;
		}
		else{ //priority is debug user id
			m_RelsciUserId = m_debugRelsciUserId;
		}

		String relSciStrengh = relsci.Relationship_Strength__c;
		hydrateRelSciStrength(relSciStrengh);

		
	}
	//public  static void hydrateBrokerSettings(){

	//	hydrateBrokerSettings('');
		//m_relationship_strength = relsci.Relationship_Strength__c;
		
	//}


	public  static  Boolean bulkAddRelationship(Map<String, Set<Long>> userAndRelationships){
		///BulkRelationshipCollection
		boolean bulkAddSuccess = false;
		List<BulkRelationshipCollection> bulkrelcollection = new List<BulkRelationshipCollection>();

		for(String item: userAndRelationships.keySet()){

			BulkRelationshipCollection bulkRelColItem = new BulkRelationshipCollection();
			bulkRelColItem.Relationships = new List<BulkRelationship>();

			bulkRelColItem.User = item;
			
			
			Set<Long> relationships = userAndRelationships.get(item);
			for(Long relationship : relationships){
				BulkRelationship bulkRelItem = new BulkRelationship();
				bulkRelItem.EntityId = relationship;
				bulkRelItem.Strength = m_relationship_strength;

				bulkRelColItem.Relationships.add(bulkRelItem);

			}
			 
			bulkrelcollection.add(bulkRelColItem);
		}

		String bulkRelCollectionSerialized  = JSON.serialize(bulkrelcollection);
		//String entityStrengthJson = getEntityAndStrengthJson(entityID, m_relationship_strength);
		String uri = m_apiURL + 'Bulk/Relationships/Add';
		String response = '';
		System.debug('add Bulk Relationship URI: ' + uri);
		System.debug('add Bulk Relationship Payload: ' + bulkRelCollectionSerialized);
		response = (!Test.isRunningTest()) ? sendHTTPRequest(uri, RestVerb.POST, bulkRelCollectionSerialized) : '[{"User":"bwilcox@pwpartners.com","Statuses":[{"EntityId":5129469,"IsProprietaryPerson":false,"Status":"Success"}]}]';

		BulkStatusCollection[] bulkStatusCollectionResponse;
	   if (String.isNotEmpty(response)){

	   
			try{
			   		
				bulkStatusCollectionResponse = (BulkStatusCollection[])JSON.deserialize(response, BulkStatusCollection[].class);	
			}
			catch (JSONException jsonEx)
		   	{
	   			System.debug('Error deserializing response of Bulk Status Collection: ' + jsonEx.getMessage());
			}
			catch (Exception ex)
			{
			   System.debug('The following exception has occurred: ' + ex.getMessage());
			}
	   }
	    bulkAddSuccess = (bulkStatusCollectionResponse != null);
	   return bulkAddSuccess;

	}

	public static Boolean bulkDeleteRelationships(Map<String, Set<string>> bulkDelRelationshipRecords){
		
		boolean bulkdeleteSuccess = false;
		List<BulkDelete> bulkDeleteRecords = new List<BulkDelete>();
		System.debug('bulk delete');
		for(String userIdentifier: bulkDelRelationshipRecords.keySet()){
		System.debug('userIdentifier: ' + userIdentifier);
			BulkDelete bulkdeleteItem = new BulkDelete();
			bulkdeleteItem.Relationships = new List<EntityToDelete>();


			bulkdeleteItem.User = userIdentifier;
			Set<String> entityIds = bulkDelRelationshipRecords.get(userIdentifier);
			List<EntityToDelete> convertedEntityIds = new List<EntityToDelete>();
			for(String entityID: entityIds){
				System.debug('entityID: ' + entityID);
				System.debug('ConvertEntityIdStringToLong entityID: ' + ConvertEntityIdStringToLong(entityID));
				EntityToDelete entityToDel = new EntityToDelete();
				entityToDel.EntityId = ConvertEntityIdStringToLong(entityID);

				convertedEntityIds.add(entityToDel);
			}
			
			bulkdeleteItem.Relationships = convertedEntityIds;
			bulkDeleteRecords.add(bulkdeleteItem);			

		}

		String bulkDeletePayload = JSON.serialize(bulkDeleteRecords);
		System.debug(bulkDeletePayload);
	   
	   hydrateBrokerSettings('');
				
	   String uri = m_apiURL + 'Bulk/Relationships/Delete';
	   String response = '';
	   response = sendHTTPRequest(uri, RestVerb.POST, bulkDeletePayload);
	   System.debug('bulk delete response: ' + response);
	   
	   
	   BulkStatusCollection[] bulkStatusCollectionResponse;
	   if (String.isNotEmpty(response)){

	   
			try{
			   		
				bulkStatusCollectionResponse = (BulkStatusCollection[])JSON.deserialize(response, BulkStatusCollection[].class);	
			}
			catch (JSONException jsonEx)
		   	{
	   			System.debug('Error deserializing response of Bulk Status Collection: ' + jsonEx.getMessage());
			}
			catch (Exception ex)
			{
			   System.debug('The following exception has occurred: ' + ex.getMessage());
			}
	   }
	    bulkdeleteSuccess = (bulkStatusCollectionResponse != null);
	   return bulkdeleteSuccess;
	    //return Long.valueOf(response);
	}

	private static void hydrateRelSciStrength(String defaultStrength){
		
		m_relationship_strength = RelationshipStrength.Average.name();
		if (String.isNotEmpty(defaultStrength)){
			
			if (defaultStrength == RelationshipStrength.Average.name()){
						m_relationship_strength = RelationshipStrength.Average.name();
						return;
			}	
			if (defaultStrength == RelationshipStrength.Strong.name()){
						m_relationship_strength = RelationshipStrength.Strong.name();
						return;
			}
			if (defaultStrength ==RelationshipStrength.Weak.name()){
						m_relationship_strength = RelationshipStrength.Weak.name();
						return;
			}

			
		}
		else{
			m_relationship_strength = RelationshipStrength.Average.name();
		}

	}

	public static Long establishRelationship(String targetFirstName, String targetLastName, String targetEmail, String userIdentifier, String companyName){//, string syncVersion){
		

		System.debug('establishRelationship: ' + targetFirstName + ' - ' + targetLastName);
		//hydrate settings
		hydrateBrokerSettings(userIdentifier);
		//Create and Set Sync
		//createAndSetSyncVersionNumber();
		Long syncVersionId = createSetSyncVersionNumber(userIdentifier);
		if (syncVersionId != -1)
		{

			String syncVersion = String.valueOf(syncVersionId);
			System.debug('syncVersion: ' + syncVersion);
			//String syncVersion = s_syncversion;
			//m_SyncVersion = syncVersion;
			//Create Contact API Object
			String apiContact = getApiContactJson(targetFirstName, targetLastname, targetEmail, companyName);
			System.debug('apiContact:' + apiContact);
			//Upload Contact API Object
			postContactUpload(apiContact, syncVersionId);


			//Start the Sync by checking for progress
			Boolean startUpload = IsUploadComplete(syncVersionId, userIdentifier);


		}
		return syncVersionId;

		//SL_RelSci_Broker_Callback callBackHandler = new SL_RelSci_Broker_Callback(syncVersion);
			 
		//System.enqueueJob(callBackHandler);
			 
		//SL_RelSci_Broker_Callback
		//return m_SyncVersion;
		//schedule job in 2 minutes to check for contact upload
		//SL_RelSci_Broker_Callback m = new SL_RelSci_Broker_Callback();
		//String sch = '20 30 8 10 2 ?';
		//String jobID = system.schedule('Process Contact Upload: ' + m_SyncVersion , sch, m);
	}
	
	//@future (callout=true)
	//public static void processContactUpload(Long syncVersionId, String userIdentifier){
	//	System.debug('process contact upload: ' + syncVersionId);
	//	//m_SyncVersion = syncVersionId;
	//	hydrateBrokerSettings('');
		
	//	//Review Results
	//	long matchedEntityId = getMatchedEntityId(syncVersionId, userIdentifier);
	//		System.debug('matchedEntityId: ' + matchedEntityId);
	//	//If Match or possible match found, Add Relationship
	//	if (matchedEntityId <> -1){
	//		addRelationship(matchedEntityId);
	//	}
	//}



	
	
	private static  String sendHTTPRequest(String uri, RestVerb restVerb, String requestBody){
		 
		 String response = '';
		 HttpRequest req = new HttpRequest();
	     req.setEndpoint(uri);
	     req.setMethod(restVerb.name());
	     req.setHeader('Content-Type', 'application/json');
	     String combinedUserAndPW = '';
	     combinedUserAndPW = m_apiUsername + ':' + m_apiPW;

	     String encodedUserAndPW = EncodingUtil.base64Encode(Blob.valueOf(combinedUserAndPW));
	   	 //req.setHeader('Username', m_apiUsername);
		 //req.setHeader('Password', m_apiPW);
		 req.setHeader('Authorization', 'Basic ' + encodedUserAndPW);

		 if (!String.isEmpty(requestBody)){
		 	req.setBody(requestBody); 
		 }
		 HTTPResponse res;
		 Http http = new Http();
		 
		 try {
	     res = http.send(req);
	 	 }
	 	 catch (CalloutException callOutEx)
	 	 {
	 	 	System.debug('An Error has occurred with the callout: '+ callOutEx);
	 	 	System.debug('Callout Error URL: ' + uri);
	 	 	System.debug('Callout Error Payload: ' + requestBody);
	 	 }
	 	 catch (Exception ex)
	 	 {
	 	 	
	 	   System.debug('The following exception has occurred: ' + ex.getMessage());	
	 	 }

		 boolean responseReceived = false;
		 responseReceived = (res != null);

		 if (responseReceived == true){

		 	
			response = res.getBody();	
			System.debug('Request - Response Code: + ' + String.valueOf(res.GetStatusCode()) + 'Status: ' + res.getStatus());				
		 	
		 }
		 else
		 {
		 	System.debug('Request failed - No Response');		
		 }
	 	 
	     
		 return response;
	 
	}
		
	/*
	public void createAndSetSyncVersionNumber() {
		
	   hydrateBrokerSettings();
				
	   String uri = m_apiURL + 'Sync/New?syncType=Relationship';
	   String response = '';
	   response = sendHTTPRequest(uri, RestVerb.GET, '');
	   SyncVersion = response;
	 
	}
	*/
	
	public static String getImpersonatingUserId(String userIdentifier){
		hydrateBrokerSettings(userIdentifier);
		return m_RelsciUserId;
	}

	private static String getImpersonatingUserQueryString(){
		String useridQueryString = '';
		String userID = m_RelsciUserId;

		if (String.isNotEmpty(userID)){
			useridQueryString = '&UserIdentifier=' + userID;
		}
		else{
			useridQueryString = '';
		}

		return useridQueryString;


	}

	private static Long createSetSyncVersionNumber(String userIdentifier) {
		
		Long longResponse = -1;
	   hydrateBrokerSettings(userIdentifier);
		
		
	   String uri = m_apiURL + 'Sync/New?syncType=Relationship' + getImpersonatingUserQueryString();
	   String response = '';
	   response = sendHTTPRequest(uri, RestVerb.GET, '');
	   if (String.isEmpty(response)){
			longResponse = -1;
		}
		else{

			try{
			longResponse = Long.valueOf(response);	
			}
			catch(TypeException typeEx){
				System.debug('Create Sync Failed - Not a valid Long type - Response: ' +  response + ' Exception: ' + typeEx.getMessage());				
			}
			catch(Exception ex){
				System.debug('Create Sync Failed - Response: ' +  response + ' Exception: '+ ex.getMessage());
			}

			System.debug('createSetSyncVersionNumber: ' +  response);
		}
	    
	 
	 return longResponse;
	}

	   


	private static  void postContactUpload(String apiContact, Long syncVersionId){
		String syncVersion = String.valueOf(syncVersionId);
		String uri = m_apiURL + 'Sync/Upload?syncVersionId=' + syncVersion + getImpersonatingUserQueryString();
		String response = '';

		response = sendHTTPRequest(uri, RestVerb.POST, apiContact);

		System.debug('Uploading Contact for apiContact: ' + apiContact + ' and syncVersion: ' + syncVersion);
		
		//IsUploadComplete(syncVersionId);
  		/*
  		Integer i = 0;
        //poll till percent 100
        
        
        Integer start = System.Now().millisecond();
        do {
        	
        	while(System.Now().millisecond()< start+1000){ 
        		//wait- simulate thread.sleep
        	}        
			    
		} while (!IsUploadComplete());

		  */   		

	}
	
	//private static  Boolean IsUploadComplete(){
	//	return IsUploadComplete(m_SyncVersion);	
	//}
	
/*	private  static  void addRelationship(long entityID){
		
		String entityStrengthJson = getEntityAndStrengthJson(entityID, m_relationship_strength);
		String uri = m_apiURL + 'Relationships/Add';
		String response = '';
		System.debug('addRelationship URI: ' + uri);
		response = sendHTTPRequest(uri, RestVerb.POST, entityStrengthJson);
		
	}*/


	//private  static long getMatchedEntityId(){
	//	return getMatchedEntityId(m_SyncVersion);
	//}
	public static  long getMatchedEntityId(Long syncVersionId, String userIdentifier){
		
		hydrateBrokerSettings(userIdentifier);
		String response = '';
		String syncVersion = String.valueOf(syncVersionId);
		String uri = m_apiURL + 'Sync/Results?syncVersionId='+ syncVersion + '&skip=0&limit=1'+ getImpersonatingUserQueryString();
		System.debug('sendHTTPRequest uri: ' + uri);
		response = sendHTTPRequest(uri, RestVerb.GET, '');
		System.debug('getMatchedEntityId response: ' + response);
		long retrievedEntityID = -1;
		if (String.isEmpty(response)){
			//if send request failed
			retrievedEntityID = 0;

		}
		else{

		    JSONParser parser = JSON.createParser(response);
		    while (parser.nextToken() != null) {
		        // Start at the array of ApiMatchResult.
		        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
		            while (parser.nextToken() != null) {
		                // Advance to the start object marker to
		                //  find next ApiMatchResult object.
		                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
		                    // Read entire ApiMatchResult, including its Matched Result and array of Possible Matches.
		                    ApiMatchResult matchResult = (ApiMatchResult)parser.readValueAs(ApiMatchResult.class);
		                    
		                    if (matchResult != null){
		                    	if (matchResult.MatchedEntity != null){
		                    		if (matchResult.MatchedEntity.Entity != null){
		                    			retrievedEntityID = matchResult.MatchedEntity.Entity.EntityId;			
		                    		}	                    		
		                    	}
		                    	//if no Matched Result is found, choose the first possible match
			                    /* This code has been commented in consideration of dealing with exact match only*/
			                    /*if (retrievedEntityID == -1){
			                    	if (matchResult.PossibleMatches != null){
			                    		if (matchResult.PossibleMatches.size()> 0){
			                    				if (matchResult.PossibleMatches[0].Entity != null){
					                    			retrievedEntityID = matchResult.PossibleMatches[0].Entity.EntityId;			
					                    		}
			                    		}	                    		
		                    		}	                    	
			                    }*/
		                    }
		                    // Skip the child start array and start object markers.
		                    parser.skipChildren();
		                }
		            }
		        }
		    }
	    }
	    return retrievedEntityID;
	    
	}
	
	private static  Integer getUploadProgress(Long syncVersionId){
		
		
		String syncVersion = String.valueOf(syncVersionId);
		String response = '';
		String uri = m_apiURL + 'Sync/Progress?syncVersionId='+ syncVersion + getImpersonatingUserQueryString();
		Integer percentComplete = 0;
		

		response = sendHTTPRequest(uri, RestVerb.GET, '');
		

		if (String.isNotEmpty(response)){

		
			JSONParser parser = JSON.createParser(response);
		    while (parser.nextToken() != null) {
	        	// Start at the object marker as this is not an array
	            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
	            	// Read entire ApiMatchProgress object
	                ApiMatchProgress matchProgress = (ApiMatchProgress)parser.readValueAs(ApiMatchProgress.class);
	                percentComplete = matchProgress.PercentComplete;
	                parser.skipChildren();
	            }	           
			}
		}
	    
	    return percentComplete;
	}
		
	public static Boolean IsUploadComplete(Long syncVersionId, String userIdentifier){		
		
		hydrateBrokerSettings(userIdentifier);
		Integer percentComplete = 0;

		percentComplete = getUploadProgress(syncVersionId);
		return percentComplete == 100;
	}

private class ApiMatchProgress {

    public String SyncVersionId;
    public Integer PercentComplete;

} 

private class ApiMatchResult {
	
	public ApiSyncResultEntity MatchedEntity;	
	public List<ApiSyncResultEntity> PossibleMatches;
	
}

private class ApiSyncResultEntity {
	
	public ApiEntity Entity;

}

private class ApiEntity {
	
	public long EntityId;	

}

private class SFDCRelationship {
	
	public String FirstName;
	public String LastName;
	public String Email;	

}


private class BulkRelationshipCollection{

	void BulkRelationshipCollection(){
		Relationships = new List<BulkRelationship>();
	}	

	public string User;
	public List<BulkRelationship> Relationships;
}

private class BulkRelationship{
	public Long EntityId;
	public String Strength;

}

//public class RelationshipStrength{

//}

private class BulkStatusCollection{
	
	public String User;
	public List<BulkStatus> Statuses;

}

private class BulkStatus{
	public Long EntityId;
	public String Status;
}


private class EntityToDelete{

	public Long EntityId;

}
private class BulkDelete {

	public String User;
	public List<EntityToDelete> Relationships;

	
}

private static Long ConvertEntityIdStringToLong(String entityID){

	return Long.valueOf(entityID);
}

	private static String getApiContactJson(String firstName, String lastName, string emailAddress, String companyName){
		//Create ApiContact
		 JSONGenerator gen = JSON.createGenerator(true);
        // open the JSON generator
        gen.writeStartArray();

  		gen.writeStartObject();
        gen.writeStringField('Name', firstName +' '+ lastName);
		gen.writeStringField('Email', (emailAddress != null) ? emailAddress : '');
		gen.writeStringField('Company', companyName!=null ? companyName : '');
        gen.writeEndObject();            

      	gen.writeEndArray();

        String jsonContacts = gen.getAsString();
     	return jsonContacts;
	}
	

	//private static  String getEntityAndStrengthJson(long entityID, String relationshipStrength){
	//	  //Create EntityAndStrength
	//	 JSONGenerator gen = JSON.createGenerator(true);
 //       // open the JSON generator
 //       gen.writeStartArray();
	//	gen.writeStartObject();
 //       gen.writeNumberField('EntityId', entityID);
	//	gen.writeStringField('Strength', relationshipStrength);
 //       gen.writeEndObject();            

 //     	gen.writeEndArray();

 //       String jsonEntityAndStrength = gen.getAsString();
 //    	return jsonEntityAndStrength;
	//}
}