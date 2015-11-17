/**
* \arg ClassName      : SL_Batch_LinkOpportunities
* \arg JIRATicket     : NPD-219
* \arg CreatedOn      : 12/Oct/15
* \arg LastModifiedOn : 12/Oct/15
* \arg CreatededBy    : Praful Gadge
* \arg ModifiedBy     : Praful Gadge
* \arg Description    : This batch process is used to Link Opportunities to ISO Goals.
*/
global class SL_Batch_LinkOpportunities implements Database.Batchable<sObject> {
	
	/*
        * MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns Opportunity records where Close Date falls within the ISO Goals start and end date
    */
	global Database.QueryLocator start(Database.BatchableContext BC) {
	    
	    Date earliestDate, latestDate = System.Date.Today();
        
        for (AggregateResult ar: [SELECT MIN(Start_Date__c) min, MAX(End_Date__c) max FROM ISO_Goal__c WHERE IsActive__c = true]){
            earliestDate = (Date)ar.get('min');
            latestDate = (Date)ar.get('max');
        }
        
		return Database.getQueryLocator([SELECT Id, OwnerId, CloseDate FROM Opportunity WHERE CloseDate < :latestDate AND CloseDate > :earliestDate]);
	}

	/*
        * MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Opportunity> lstOpportunity
        * Description  : Processes Opportunity records returned by start method
    */
   	global void execute(Database.BatchableContext BC, List<Opportunity> lstOpportunity) {
   	    
	    Map<Id, Opportunity> mapOppIdToOpportunityToUpdate = new Map<Id, Opportunity>();
	    Map<Id, Set<Id>> mapOwnerIdToSetOppIds = new Map<Id, Set<Id>>();
	    
	    for(Opportunity objOpp : lstOpportunity){
	        
	         if(!mapOwnerIdToSetOppIds.containsKey(objOpp.OwnerId))
	            mapOwnerIdToSetOppIds.put(objOpp.OwnerId, new Set<Id>{objOpp.Id});
	        else
	            mapOwnerIdToSetOppIds.get(objOpp.OwnerId).add(objOpp.Id);
	    }
	    
	    for(ISO_Goal__c objISOGoal : [SELECT Id, OwnerId FROM ISO_Goal__c WHERE IsActive__c = true AND OwnerId =: mapOwnerIdToSetOppIds.keySet()]){
	       
	       if(mapOwnerIdToSetOppIds.containsKey(objISOGoal.OwnerId)){
	           for(Id oppId : mapOwnerIdToSetOppIds.get(objISOGoal.OwnerId)){
	               if(!mapOppIdToOpportunityToUpdate.containsKey(oppId))
	                    mapOppIdToOpportunityToUpdate.put(oppId, new Opportunity(Id = oppId, ISO_Goal__c = objISOGoal.Id));
	               else
	                    mapOppIdToOpportunityToUpdate.get(oppId).ISO_Goal__c = objISOGoal.Id;
	           }
	       }
	    }
	    
	    if(!mapOppIdToOpportunityToUpdate.isEmpty())
	        update mapOppIdToOpportunityToUpdate.values();
	        
	}
	
	/*
        * MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
	global void finish(Database.BatchableContext BC) {
		//Do Nothing
	}
	
}