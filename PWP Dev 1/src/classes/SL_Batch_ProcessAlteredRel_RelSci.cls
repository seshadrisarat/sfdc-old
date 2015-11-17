global class SL_Batch_ProcessAlteredRel_RelSci implements Database.Batchable<sObject>, Database.AllowsCallouts  {
	
	String query;
	
	global SL_Batch_ProcessAlteredRel_RelSci(String strBatchQuery) {
		query = strBatchQuery;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	   	
	   	boolean removeProcessedRecords = false;
	   	Map<String, Set<string>> bulkRels = new Map<String, Set<string>>();
	   	if (!SL_RelSci_Broker.IsIntegrationEnabled()){
   			return;
   		}
		
		for(sObject batchObject: scope){
			RelSci_Processing__c relsci = (RelSci_Processing__c) batchObject;

			if (relsci != null){
				String userIdentifier = relsci.RelSci_User_Identifier__c;
				String entityID = relsci.RelSci_EntityId__c;
				Set<String> existingValue = bulkRels.get(userIdentifier);
				if (existingValue == null)
				{
					existingValue = new Set<String>();
					//get value set, add new value
	
				}
				existingValue.add(entityID);

				bulkRels.put(userIdentifier, existingValue);

			}
		}
		if (bulkRels.size()>0) {
			removeProcessedRecords = SL_RelSci_Broker.bulkDeleteRelationships(bulkRels);
		}

		if (removeProcessedRecords == true){
			Database.Delete(scope, false);
			Database.EmptyRecycleBin(scope);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}