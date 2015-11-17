trigger TerritoryTrigger on Territory__c (before insert, before update, after delete, after insert, after undelete, after update) {
	if (TerritoryServices.disableTriggerProcessing) {
		system.debug('Territory trigger processing is disabled');
		return;
	}
	if (trigger.isBefore) {
		// Commented out by Mike Regan for BS-270 
		/*if (trigger.isInsert) {
			TerritoryServices.insertCountryName(trigger.new);		
		}
		else if (trigger.isUpdate) {
			TerritoryServices.updateCountryName(trigger.new);	
		}*/
	}
	if (trigger.isAfter) {
		/*
		* BS-249
		* Need to "roll up" the boat category (boat_class__c) on the territory to the owning account
		* The category(ies) are maintained on the account as a single field... multiple category
		* values will be comma separated
		* Needed to allow syncing dealer boat category data with Pardot
		*
		* Initially created for Sea Ray only
	    *
	    * David Hickman - 06.03.15
	    */
	    Set<Id> territoriesToRewrite = new Set<Id>();
	    Set<Id> territoriesToUpdate = new Set<Id>();
	    
	    if (trigger.isInsert) {
	    	if (!DBMServices.disableTriggerProcessing) {
		        DBMServices.disableTriggerProcessing = true;
				try {
			        // Make sure we have sharing rules
			        new DBMServices().createApexSharingRules(Trigger.new);
				}
				finally {
					 DBMServices.disableTriggerProcessing = false;
				}
	        }     
	    }
	    
	    /*
	    * If the boat category on the territory has changed, or this is a delete, we need to 
	    * evaluate the boat category on all of the territories to see if one needs to be removed
	    */
	    if (trigger.isUpdate) {
	    	for (Territory__c territory : trigger.new) {
	    		if (territory.Boat_Class__c != trigger.oldMap.get(territory.Id).Boat_Class__c) {
	    			//We have a difference.  What type of change?
	    			Set<String> newBoatCategories = new Set<String>(territory.Boat_Class__c.split(';'));
	    			Set<String> oldBoatCategories = new Set<String>(trigger.oldMap.get(territory.Id).Boat_Class__c.split(';'));
	    			Boolean rewriteCategories = false;
	    			
	    			//If a territory has been removed then we need to rewrite
	    			for (String oldBoatCategory : oldBoatCategories) {
	    				if (!newBoatCategories.contains(oldBoatCategory)) {
	    					territoriesToRewrite.add(territory.Id);
	    					rewriteCategories = true;
	    					break;
	    				}
	    			}
	    			
	    			if (!rewriteCategories) {
	    				territoriesToUpdate.add(territory.Id);
	    			}
	    			
	    		}
	    	}
	    	
	    	if (!territoriesToRewrite.isEmpty()) {
	    		TerritoryServices.rewriteSRDealerBoatCategories(territoriesToRewrite);
	    	}
	    	if (!territoriesToUpdate.isEmpty()) {
	    		TerritoryServices.addSRDealerBoatCategories(TerritoryServices.getTerritoryIds(trigger.new));
	    	}
	    } else if (trigger.isDelete) {
	    	TerritoryServices.rewriteSRDealerBoatCategories(territoriesToUpdate);
	    } else {
	    	/*
	    	* Just need to check to see if the boat category is already on the account, if not then add it
	    	*/
	    	TerritoryServices.addSRDealerBoatCategories(TerritoryServices.getTerritoryIds(trigger.new));
	    }
	}
}