trigger OwnerBoatRelationShip on Owner_Boat_Relationship__c (after insert, after update, after delete, after undelete) {
	if (OwnerBoatRelationshipServices.disableTriggerProcessing) {
		system.debug('Disabling owner boat relationship trigger processing');
		return;
	}
     
   	new OwnerBoatRelationshipTriggerHandler().run();
	/*if (!OwnerBoatRelationshipServices.disableTriggerProcessing) {
    	if (trigger.isUpdate || trigger.isInsert) {
    		OwnerBoatRelationshipServices.updateOwnerBoatRelationships(Trigger.new);
    	}
    	else if (trigger.isDelete) {
    		list<Owner_Boat_Relationship__c> rels = new list<Owner_Boat_Relationship__c>();
    		rels.addAll(Trigger.new);
    		rels.addAll(Trigger.old);
    		OwnerBoatRelationshipServices.updateOwnerBoatRelationships(rels);
    	}
    }*/
   
   /*
    Map<Id, Set<String>> accountToBrandMap;

	if (!OwnerBoatRelationshipServices.disableTriggerProcessing) {
	    if(trigger.isUpdate){
	    	// We need to ensure that the SROC data is copied over to the owner account object
	    	*/
	    	/*
	    	DISABLED BY BW 4/14/15 requested by Mike Regan. 
	    	OwnerBoatRelationshipServices.updateOwnerSROCData(Trigger.new);
	        */
	        /*
	        accountToBrandMap=OwnerBoatRelationshipServices.getParentObject(Trigger.new, Trigger.old);
	        OwnerBoatRelationshipServices.updateAccounts(OwnerBoatRelationshipServices.processAccountBrands(accountToBrandMap), Trigger.newMap);
	    }else if(trigger.isDelete) {
	       accountToBrandMap=OwnerBoatRelationshipServices.getParentObject(Trigger.old);
	        OwnerBoatRelationshipServices.updateAccounts(OwnerBoatRelationshipServices.processAccountBrands(accountToBrandMap), Trigger.oldMap);
	    }else {
	        accountToBrandMap=OwnerBoatRelationshipServices.getParentObject(Trigger.new);
	        OwnerBoatRelationshipServices.updateAccounts(OwnerBoatRelationshipServices.processAccountBrands(accountToBrandMap), Trigger.newMap);
	    }
	} */
}