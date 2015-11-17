public class OwnerBoatRelationShipTriggerHandler extends TriggerHandler {
	private map<Id, Owner_Boat_Relationship__c> newOwnerBoatRelationshipMap;
	private map<Id, Owner_Boat_Relationship__c> oldOwnerBoatRelationshipMap;
	private list<Owner_Boat_Relationship__c> newOwnerBoatRelationships;
	private list<Owner_Boat_Relationship__c> oldOwnerBoatRelationships;
	
	public OwnerBoatRelationShipTriggerHandler() {
		newOwnerBoatRelationshipMap = (map<Id, Owner_Boat_Relationship__c>)Trigger.newMap;
		oldOwnerBoatRelationshipMap = (map<Id, Owner_Boat_Relationship__c>)Trigger.oldMap;
		newOwnerBoatRelationships = (list<Owner_Boat_Relationship__c>)Trigger.new;
		oldOwnerBoatRelationships = (list<Owner_Boat_Relationship__c>)Trigger.old;
	}
	
	public override void afterInsert() {
		system.debug('OwnerBoatRelationShipTriggerHandler - afterInsert');
		
		OwnerBoatRelationshipServices.setActiveOwnerBoatRelationshipsForBoatsAndUpdateOwnerBrandRelationships(newOwnerBoatRelationships);
		
		/*map<Id, Set<string>> ownerIdToBrandMap = OwnerBoatRelationshipServices.getParentObject(newOwnerBoatRelationships);
		list<Account> accountsToUpdate = OwnerBoatRelationshipServices.updateOwnerBrandRelationships(ownerIdToBrandMap);
	    OwnerBoatRelationshipServices.updateAccounts(accountsToUpdate, newOwnerBoatRelationshipMap);*/
	}
	
	public override void afterUpdate() {
		system.debug('OwnerBoatRelationShipTriggerHandler - afterUpdate');
		
		OwnerBoatRelationshipServices.setActiveOwnerBoatRelationshipsForBoatsAndUpdateOwnerBrandRelationships(newOwnerBoatRelationships);
		
		/*map<Id, Set<string>> ownerIdToBrandMap = OwnerBoatRelationshipServices.getParentObject(newOwnerBoatRelationships, oldOwnerBoatRelationships);
		list<Account> accountsToUpdate = OwnerBoatRelationshipServices.updateOwnerBrandRelationships(ownerIdToBrandMap);
	    OwnerBoatRelationshipServices.updateAccounts(accountsToUpdate, newOwnerBoatRelationshipMap);*/
	}
	
	public override void afterDelete() {
		system.debug('OwnerBoatRelationShipTriggerHandler - afterDelete');
		map<Id, Set<string>> ownerIdToBrandMap = OwnerBoatRelationshipServices.getParentObject(oldOwnerBoatRelationships);
		list<Account> accountsToUpdate = OwnerBoatRelationshipServices.updateOwnerBrandRelationships(ownerIdToBrandMap);
		OwnerBoatRelationshipServices.updateAccounts(accountsToUpdate, oldOwnerBoatRelationshipMap);
	}
}