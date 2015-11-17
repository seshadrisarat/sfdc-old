/*
* Handles the lead trigger
*
* @author Mike Regan
*/
public class BoatTriggerHandler extends TriggerHandler {
	private map<Id, Boat__c> newBoatMap;
	private map<Id, Boat__c> oldBoatMap;
	private list<Boat__c> newBoats;
	private list<Boat__c> oldBoats;
	public static boolean disableBoatTrigger = false;

	public BoatTriggerHandler() {
		newBoatMap = (map<Id, Boat__c>)Trigger.newMap;
		oldBoatMap = (map<Id, Boat__c>)Trigger.oldMap;
		newBoats = (list<Boat__c>)Trigger.new;
		oldBoats = (list<Boat__c>)Trigger.old;
		disableBoatTrigger = UserUtil.isDisableBoatTrigger();
  	}
  	
  	public override void beforeInsert() {
  		system.debug('BoatTriggerHandler - beforeInsert');
        BoatServices.AddDealer(newBoats); 
        
        List<Boat__c> filteredBoats = BoatServices.filterBoatsNoDealerBrand(newBoats);
       	if (!filteredBoats.isEmpty()){
        	system.debug('Found boats with no dealer brand');
        	Map<Id, List<Dealer_Brand__c>> dealerToBrands = BoatServices.findPossibleDealerBrand(filteredBoats);
        	BoatServices.stampBoatDealerBrand(filteredBoats, dealerToBrands); 
        }
        else {
        	system.debug('There are no boats without a dealer brand');
        }
  	}
  	
  	public override void afterInsert() {
  		system.debug('BoatTriggerHandler - afterInsert');
  		if (!disableBoatTrigger) {
	  		BoatServices.disableTriggerProcessing = true;
	    	try {       
	        	BoatServices.createBoatAndBoatOwnerShip(newBoats);     
	    	}
	    	finally {
	    	}
	        
	        if (!DBMServices.disableTriggerProcessing) {
		        DBMServices.disableTriggerProcessing = true;
				try {
			        // Make sure we have sharing rules
			        new DBMServices().createApexSharingRules(newBoats);
				}
				finally {
				}
	        }   
	        
	        /* BS-145 -- Disabled until dealer salesperson formatting issue is resolved */
	        BoatServices.createContact(newBoats);
  		}
  	}
  	
  	public override void beforeUpdate() {
  		system.debug('BoatTriggerHandler - beforeUpdate');
    	List<Boat__c> filteredBoats = BoatServices.filterBoatsNoDealerBrand(newBoats);
        if (!filteredBoats.isEmpty()){
        	Map<Id, List<Dealer_Brand__c>> dealerToBrands = BoatServices.findPossibleDealerBrand(filteredBoats);
        	BoatServices.stampBoatDealerBrand(filteredBoats, dealerToBrands); 
        }
  	}
  	
  	public override void afterUpdate() {
  		system.debug('BoatTriggerHandler - afterUpdate');
  		if (!disableBoatTrigger) {
	  		BoatServices.disableTriggerProcessing = true;
	    	try { 
	            Map<Id, Set<String>> accountToBrandMap=OwnerBoatRelationshipServices.getParentObject(OwnerBoatRelationshipServices.filterBoats(newBoats, oldBoatMap));
	            OwnerBoatRelationshipServices.updateAccounts(OwnerBoatRelationshipServices.processAccountBrands(accountToBrandMap), newBoatMap);
	
	            if(!BoatServices.isWorkFlowRunning){
	               BoatServices.updateBoatOwner(newBoats);
	            }
	    	}
	    	finally {
	    		BoatServices.disableTriggerProcessing = false;
	    	}
	        
	        if (!DBMServices.disableTriggerProcessing) {
		        DBMServices.disableTriggerProcessing = true;
				try {
			        // Make sure we have sharing rules
			        new DBMServices().createApexSharingRules(newBoats);
				}
				finally {
					 DBMServices.disableTriggerProcessing = false;
				}
	        }
	        
	        /* BS-145 -- Disabled until dealer salesperson formatting issue is resolved */
	        BoatServices.createContact(newBoats);
  		}
  	}
  	
  	public override void beforeDelete() {
  		system.debug('BoatTriggerHandler - beforeDelete');
  		BoatServices.disableTriggerProcessing = true;
    	AccountServices.disableTriggerProcessing = true;
    	try {
        	OwnerBoatRelationshipServices.deleteChildJunctionObjects(oldBoatMap);
    	}
    	finally {
    		AccountServices.disableTriggerProcessing = false;	
    	}
  	}
}