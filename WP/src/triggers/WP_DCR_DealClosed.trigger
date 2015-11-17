trigger WP_DCR_DealClosed on Deal__c (after update) {
	if (trigger.isAfter){
		Deal__c dealold = trigger.old[0];
	    Deal__c deal = trigger.new[0];
	    String dealStage = deal.Stage__c;
		String deal_id = deal.Id;
		//Boolean rsent = deal.Reminder_Sent__c;
		
		System.debug('DEBUG WORKFLOW STEP1-Old?--->' + dealold.Stage__c + '-New--->' + dealStage);
       	if (dealold.Stage__c != 'Committed-Deal Closed' && deal.Stage__c == 'Committed-Deal Closed')
        {
			//check if deal_id already exists in DCR Process Log records. If yes don't create one else create a new workflow record
			List<DCR_Process_Log__c> dcr_list = [SELECT Id, Deal__c, Reminder_Sent__c, Time_Expired__c, DCR_Sent_On__c
        	FROM DCR_Process_Log__c
        	WHERE Deal__c =: deal_id];
        	if (dcr_list.size()>0){
        	//Don't do anything i.e.; donot create any workflow records and exit
        	}else{
			String DealClosedBy = UserInfo.getName();
			String DealClosedEmail = UserInfo.getUserEmail();
			Date DealClosedOn = System.Today();
			DCR_Process_Log__c dcr_process_log = new DCR_Process_Log__c();
				              
			dcr_process_log.Deal__c = deal_id;
			dcr_process_log.Deal_Closed_By__c = DealClosedBy;
			dcr_process_log.Deal_Closed_Email__c = DealClosedEmail;
			dcr_process_log.Deal_Closed_On__c = DealClosedOn;
			dcr_process_log.Reminder_Sent__c = false;
			dcr_process_log.Time_Expired__c = false;
			insert dcr_process_log ;
        	}
        }//if ends   
		if (dealold.Stage__c == 'Committed-Deal Closed' && deal.Stage__c != 'Committed-Deal Closed')
		{
			//For every other Stage of the Deal -> Check if there exists any DCR Log based on this Deal_Id and delete them
			List<DCR_Process_Log__c> dcr_list = [SELECT Id, Deal__c, Reminder_Sent__c, Time_Expired__c, DCR_Sent_On__c
        	FROM DCR_Process_Log__c
        	WHERE Deal__c =: deal_id];
        	if (dcr_list.size()>0){
            	for(DCR_Process_Log__c dcr_item:dcr_list) {
					System.debug('DEBUG delete DCR_Process Log =' + dcr_item.Id);	 
					delete dcr_item;
        		}  		
        	}        	
		}//else ends
	  }//trigger.isAfter and isBefore 
}//WP_DCR_DealClosed