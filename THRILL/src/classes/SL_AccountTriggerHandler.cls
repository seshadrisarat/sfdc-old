/**  
* \arg ClassName        : SL_AccountTriggerHandler
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Handler class for Account object.
*/
global class SL_AccountTriggerHandler extends SL_TriggerHandlerBase {

	public override void beforeInsert(List<SObject> newListGeneric){
		List<Account> newList = (List<Account>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		
		/*BEFORE INSERT METHODS END*/
	}
	
	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	
}