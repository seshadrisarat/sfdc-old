/**  
* \arg ClassName        : SL_Relationship_GroupTriggerDispatcher
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Dispatcher class for Relationship_Group object and associated handlers.
*/
global class SL_Relationship_GroupTriggerDispatcher extends SL_TriggerDispatcherBase {

	public class SL_Relationship_GroupBeforeInsertTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			List<Relationship_Group__c> newList = (List<Relationship_Group__c>) tp.newList;
			/*BEFORE INSERT METHODS START*/
			
			/*BEFORE INSERT METHODS END*/
		}
	}
	public class SL_Relationship_GroupBeforeUpdateTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Relationship_Group__c> newMap = (Map<Id, Relationship_Group__c>) tp.newMap;
			Map<Id, Relationship_Group__c> oldMap = (Map<Id, Relationship_Group__c>) tp.oldMap;
			/*BEFORE UPDATE METHODS START*/
			
			/*BEFORE UPDATE METHODS END*/
		}
	}
	public class SL_Relationship_GroupBeforeDeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Relationship_Group__c> oldMap = (Map<Id, Relationship_Group__c>) tp.oldMap;
			/*BEFORE DELETE METHODS START*/
			
			/*BEFORE DELETE METHODS END*/
		}
	}
	public class SL_Relationship_GroupAfterInsertTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Relationship_Group__c> newMap = (Map<Id, Relationship_Group__c>) tp.newMap;
			/*AFTER INSERT METHODS START*/

			SL_Relationship_GroupHelper.updateSharing(newMap);
			
			/*AFTER INSERT METHODS END*/
		}
	}
	public class SL_Relationship_GroupAfterUpdateTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Relationship_Group__c> newMap = (Map<Id, Relationship_Group__c>) tp.newMap;
			Map<Id, Relationship_Group__c> oldMap = (Map<Id, Relationship_Group__c>) tp.oldMap;
			/*AFTER UPDATE METHODS START*/

			SL_Relationship_GroupHelper.updateSharing(newMap);
			
			/*AFTER UPDATE METHODS END*/
		}
	}
	public class SL_Relationship_GroupAfterDeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Relationship_Group__c> oldMap = (Map<Id, Relationship_Group__c>) tp.oldMap;
			/*AFTER DELETE METHODS START*/
			
			/*AFTER DELETE METHODS END*/
		}
	}
	public class SL_Relationship_GroupAfterUndeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Relationship_Group__c> newMap = (Map<Id, Relationship_Group__c>) tp.newMap;
			/*AFTER UNDELETE METHODS START*/
			
			/*AFTER UNDELETE METHODS END*/
		}
	}
	
	private static Boolean isBeforeInsertProcessing  = false;
	private static Boolean isBeforeUpdateProcessing  = false;
	private static Boolean isBeforeDeleteProcessing  = false;
	private static Boolean isAfterInsertProcessing   = false;
	private static Boolean isAfterUpdateProcessing   = false; 
	private static Boolean isAfterDeleteProcessing   = false;
	private static Boolean isAfterUnDeleteProcessing = false;
	
	public SL_Relationship_GroupTriggerDispatcher(){
		super('Relationship_Group');
	}
	
	public virtual override void beforeInsert(SL_TriggerParameters tp) {
		if(!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new SL_Relationship_GroupBeforeInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
			isBeforeInsertProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
	}
	public virtual override void beforeUpdate(SL_TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new SL_Relationship_GroupBeforeUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
	}
	public virtual override void beforeDelete(SL_TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			execute(new SL_Relationship_GroupBeforeDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
			isBeforeDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
	}	
	public virtual override void afterInsert(SL_TriggerParameters tp) {
		if(!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new SL_Relationship_GroupAfterInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterInsert);
			isAfterInsertProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterInsert);
	}
	public virtual override void afterUpdate(SL_TriggerParameters tp) {
		if(!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			execute(new SL_Relationship_GroupAfterUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
			isAfterUpdateProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
	}
	public virtual override void afterDelete(SL_TriggerParameters tp) {
		if(!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			execute(new SL_Relationship_GroupAfterDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterDelete);
			isAfterDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterDelete);
	}
	public virtual override void afterUnDelete(SL_TriggerParameters tp) {
		if(!isAfterUnDeleteProcessing) {
			isAfterUnDeleteProcessing = true;
			execute(new SL_Relationship_GroupAfterUnDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
			isAfterUnDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
	}
}