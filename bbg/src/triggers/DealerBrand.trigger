trigger DealerBrand on Dealer_Brand__c (after insert, after update, after delete, after undelete) {
	if (AccountServices.disableDealerBrandTriggerProcessing) {
		return;
	}
    map<Id, set<string>> dealerToBrandMap;

    if(trigger.isUpdate){
    	system.debug('Updating accounts');
    	try {
    		AccountServices.disableTriggerProcessing = true;
    		dealerToBrandMap=OwnerBoatRelationshipServices.getParentObject(Trigger.new);
        	//dealerToBrandMap=OwnerBoatRelationshipServices.getDealerToBrandMapForChangedBrands(Trigger.newMap, Trigger.oldMap);
        	OwnerBoatRelationshipServices.updateAccounts(OwnerBoatRelationshipServices.processAccountBrands(dealerToBrandMap), Trigger.newMap);
    	}
    	finally {
    		AccountServices.disableTriggerProcessing = false;
    	}
        
        if (!DBMServices.disableTriggerProcessing) {
	        DBMServices.disableTriggerProcessing = true;
			try {
		        // If the owner has changed we need to update the sharing rules
		        system.debug('Updating sharing rules');
		        new DBMServices().updateApexSharingRules(Trigger.new, Trigger.oldMap);
			}
			finally {
				 DBMServices.disableTriggerProcessing = false;
			}
        }
    }else if(trigger.isDelete) {
    	try {
    		AccountServices.disableTriggerProcessing = true;
        	Map<Id, Set<String>> accountToBrandMap=OwnerBoatRelationshipServices.getParentObject(Trigger.old);
        	OwnerBoatRelationshipServices.updateAccounts(OwnerBoatRelationshipServices.processAccountBrands(accountToBrandMap), Trigger.oldMap);
    	}
    	finally {
    		AccountServices.disableTriggerProcessing = false;
    	}
    }else if (trigger.isInsert) {
    	try {
    		AccountServices.disableTriggerProcessing = true;
    		system.debug('Updating accounts');
        	dealerToBrandMap=OwnerBoatRelationshipServices.getDealerToBrandMap(Trigger.new);
        	OwnerBoatRelationshipServices.updateAccounts(OwnerBoatRelationshipServices.processAccountBrands(dealerToBrandMap), Trigger.newMap);
    	}
		finally {
			 DBMServices.disableTriggerProcessing = false;
		}
        
        if (!DBMServices.disableTriggerProcessing) {
	        DBMServices.disableTriggerProcessing = true;
			try {
				system.debug('Updating sharing rules');
		        new DBMServices().createApexSharingRules(Trigger.new);
			}
			finally {
				 DBMServices.disableTriggerProcessing = false;
			}
        }
    }
}