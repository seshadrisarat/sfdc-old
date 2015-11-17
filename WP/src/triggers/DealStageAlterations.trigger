trigger DealStageAlterations on Deal__c (after update) {
	if (trigger.isAfter){
		Deal__c dealold = trigger.old[0];
	    Deal__c deal = trigger.new[0];
	    String dealStage = deal.Stage__c;
		String deal_id = deal.Id;

		System.debug('6737 AR: DEBUG DEAL STAGE ALTERATIONS STEP0--->' + dealold.Stage__c + '-New--->' + dealStage);
       	if (dealold.Stage__c != 'Deal Exited Portfolio' && deal.Stage__c == 'Deal Exited Portfolio'){
       		//RecordType DealRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Exited_Portfolio_Company' and sObjectType = 'Deal__c' limit 1];
        	//deal.Prior_Record_Type__c = dealold.RecordTypeId;
        	//System.debug('AR: DEBUG DEAL STAGE ALTERATIONS STEP1--->' + dealold.Stage__c + '-New--->' + dealStage + '--Prior-RecId->' + dealold.RecordTypeId);
        	//deal.RecordType.Name = DealRecTypeId.Id;
			//deal.RecordType.Name = DealRecTypeId.Name;
			//deal.RecordType.DeveloperName = DealRecTypeId.DeveloperName;
			//deal.RecordType.Id = DealRecTypeId.Id;
        }
		if (dealold.Stage__c != 'Committed-Deal Closed' && deal.Stage__c == 'Committed-Deal Closed'){
       		RecordType DealRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Portfolio_Company' and sObjectType = 'Deal__c' limit 1];
       		//deal.Prior_Record_Type__c = dealold.RecordTypeId;
       		//System.debug('AR: DEBUG DEAL STAGE ALTERATIONS STEP2--->' + dealold.Stage__c + '-New--->' + dealStage + '--Prior-RecId->' + dealold.RecordTypeId);
			//deal.RecordTypeId = DealRecTypeId.Id;
			//deal.RecordType.Name = DealRecTypeId.Name;
			//deal.RecordType.DeveloperName = DealRecTypeId.DeveloperName;
			//deal.RecordType.Id = DealRecTypeId.Id;
		}
		if (deal.Stage__c != 'Committed-Deal Closed' && deal.Stage__c != 'Deal Exited Portfolio' && dealold.Stage__c != deal.Stage__c){
       		RecordType DealRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Platform_Deal' and sObjectType = 'Deal__c' limit 1];
       		//deal.Prior_Record_Type__c = dealold.RecordTypeId;
       		//System.debug('AR: DEBUG DEAL STAGE ALTERATIONS STEP3--->' + dealold.Stage__c + '-New--->' + dealStage + '--Prior-RecId->' + dealold.RecordTypeId);
			//deal.RecordType.Name = DealRecTypeId.Name;
			//deal.RecordType.DeveloperName = DealRecTypeId.DeveloperName;
			//deal.RecordType.Id = DealRecTypeId.Id;
		}
	  }//trigger.isAfter and isBefore
}