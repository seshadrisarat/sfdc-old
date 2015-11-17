global class SL_Batch_ProcessContactUpload_RelSci implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	String query;
	
	global SL_Batch_ProcessContactUpload_RelSci(String strBatchQuery) {
			
		query = strBatchQuery;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
	
			return Database.getQueryLocator(query);
		
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
   		if (!SL_RelSci_Broker.IsIntegrationEnabled()){
   			return;
   		}
		
		Map<String, Set<Long>> relationshipsToCreate = new Map<String, Set<Long>>();

		List<Relationship__c> relationshipUploadsNoMatch = new List<Relationship__c>();
		List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
			//establishRelationship
			for(sObject batchObject: scope){
				Relationship__c relationship = (Relationship__c)batchObject;
				if (relationship != null){
					String pwpUserIdentifier = relationship.PWP_Employee__r.username;
					Long syncVersionId = Long.valueOf(relationship.RelSci_SyncId__c);
					
					boolean uploadComplete = (!Test.isRunningTest()) ? SL_RelSci_Broker.IsUploadComplete(syncVersionId, pwpUserIdentifier) : true;

					//syncVersionId = SL_RelSci_Broker.establishRelationship('Yacov','Wrocherinsky','');

					if (uploadComplete == true){
						//check for matched entity
						Long matchedEntityId = (!Test.isRunningTest()) ? SL_RelSci_Broker.getMatchedEntityId(syncVersionId, pwpUserIdentifier) : 73631;
						if (matchedEntityId == -1) //no match
						{		
							relationship.RelSci_Status__c = 'Processed';
							relationship.RelSci_EntityId__c = null;
							relationshipUploadsNoMatch.add(relationship);
						}
						else if (matchedEntityId > 0) //match is found
						{
							Set<Long> existingValue = relationshipsToCreate.get(pwpUserIdentifier);
							if (existingValue == null)
							{
								existingValue = new Set<Long>();
								//get value set, add new value
							}
							existingValue.add(matchedEntityId);
							relationshipsToCreate.put(SL_RelSci_Broker.getImpersonatingUserId(pwpUserIdentifier), existingValue);
							//SL_RelSci_Broker.addRelationship(matchedEntityId);
							relationship.RelSci_Status__c = 'Processed';
							relationship.RelSci_EntityId__c = String.valueOf(matchedEntityId);
						}
						
						// if -1, it will be updated from another list, if zero then dont update so it can reprocess, since it error out.
						if (matchedEntityId > 0){ 
							relationshipsToUpdate.add(relationship);
						}
					}
					else{
						//do nothing as this will get processed again
					}
				}

			}
			if (relationshipsToCreate.size() > 0){
				if (SL_RelSci_Broker.bulkAddRelationship(relationshipsToCreate) == true){
					database.update(relationshipsToUpdate, false);
				}
			}
			if (relationshipUploadsNoMatch.size() > 0){
				database.update(relationshipUploadsNoMatch, false);
			}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}