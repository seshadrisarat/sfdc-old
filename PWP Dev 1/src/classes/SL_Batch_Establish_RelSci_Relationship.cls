global class SL_Batch_Establish_RelSci_Relationship implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	String query;
	
	global SL_Batch_Establish_RelSci_Relationship(String strBatchQuery) 
	{
		query = strBatchQuery;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		//read records where processed 
		return Database.getQueryLocator(query); 
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
	
		if (!SL_RelSci_Broker.IsIntegrationEnabled()){
   			return;
   		}
   		List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
		//establishRelationship
		Long syncVersionId = -1;
		for(sObject batchObject: scope){
			Relationship__c relationship = (Relationship__c)batchObject;
			if (batchObject != null){
				//relationship.firstname
				String extContactFirstName = relationship.External_Contact__r.FirstName;
				String extContactLastName = relationship.External_Contact__r.LastName;
				String pwpUserIdentifier = relationship.PWP_Employee__r.username;
				if (String.isNotEmpty(extContactFirstName) && String.isNotEmpty(extContactLastName) && String.isNotEmpty(pwpUserIdentifier))
				{
					syncVersionId = (!Test.isRunningTest()) ? SL_RelSci_Broker.establishRelationship(extContactFirstName, extContactLastName, relationship.External_Contact__r.Email, pwpUserIdentifier, relationship.Account__r.Name) : 123;

					if (SyncVersionId != -1){
						//update relationship__c
						relationship.RelSci_Status__c = 'Uploaded';
						relationship.RelSci_SyncId__c = String.valueOf(syncVersionId);
						relationshipsToUpdate.add(relationship);
					}else{
						//do nothing, the establish of the sync failed for some reason. We should allow this to be picked up again
					}
				}
				else{ //record does not have a first or lastname, we dont want to keep processing it
					relationship.RelSci_Status__c = 'Invalid';
					relationshipsToUpdate.add(relationship);
				}
			}

		}

		database.update(relationshipsToUpdate, false);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}