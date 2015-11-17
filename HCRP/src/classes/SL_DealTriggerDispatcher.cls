/**  
* \arg ClassName        : SL_DealTriggerDispatcher
* \arg JIRATicket       : 
* \arg CreatedOn        : 2015-06-23
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Edward Rivera
* \arg ModifiedBy       : 
* \arg Description      : Dispatcher class for Deal object and associated handlers.
*/
global class SL_DealTriggerDispatcher extends SL_TriggerDispatcherBase {

	public class SL_DealBeforeInsertTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			List<Deal__c> newList = (List<Deal__c>) tp.newList;
			/*BEFORE INSERT METHODS START*/
			
			/*BEFORE INSERT METHODS END*/
		}
	}
	public class SL_DealBeforeUpdateTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Deal__c> newMap = (Map<Id, Deal__c>) tp.newMap;
			Map<Id, Deal__c> oldMap = (Map<Id, Deal__c>) tp.oldMap;
			/*BEFORE UPDATE METHODS START*/
			
			/*BEFORE UPDATE METHODS END*/
		}
	}
	public class SL_DealBeforeDeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Deal__c> oldMap = (Map<Id, Deal__c>) tp.oldMap;
			/*BEFORE DELETE METHODS START*/
			
			/*BEFORE DELETE METHODS END*/
		}
	}
	public class SL_DealAfterInsertTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Deal__c> newMap = (Map<Id, Deal__c>) tp.newMap;
			/*AFTER INSERT METHODS START*/
			// pass only the records in trigger.newMap that are ready for stamping, utilizes a formula so needs to be in after insert
			update SL_DealHelper.stampCurrency(SL_DealHelper.getClosedWonDeals(newMap.values()));
			/*AFTER INSERT METHODS END*/
		}
	}
	public class SL_DealAfterUpdateTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Deal__c> newMap = (Map<Id, Deal__c>) tp.newMap;
			Map<Id, Deal__c> oldMap = (Map<Id, Deal__c>) tp.oldMap;
			/*AFTER UPDATE METHODS START*/
			// pass only the records in trigger.newMap that are ready for stamping
			update SL_DealHelper.stampCurrency(SL_DealHelper.getClosedWonDeals(SL_util_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), 'Capture_Local_Currency_Formula__c')));
			/*AFTER UPDATE METHODS END*/
		}

		public override void inProgressEntry(SL_TriggerParameters tp) {

		}
	}
	public class SL_DealAfterDeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Deal__c> oldMap = (Map<Id, Deal__c>) tp.oldMap;
			/*AFTER DELETE METHODS START*/
			
			/*AFTER DELETE METHODS END*/
		}
	}
	public class SL_DealAfterUndeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Deal__c> newMap = (Map<Id, Deal__c>) tp.newMap;
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
	
	public SL_DealTriggerDispatcher(){
		super('Deal');
	}
	
	public virtual override void beforeInsert(SL_TriggerParameters tp) {
		if(!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new SL_DealBeforeInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
			isBeforeInsertProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
	}
	public virtual override void beforeUpdate(SL_TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new SL_DealBeforeUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
	}
	public virtual override void beforeDelete(SL_TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			execute(new SL_DealBeforeDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
			isBeforeDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
	}	
	public virtual override void afterInsert(SL_TriggerParameters tp) {
		if(!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new SL_DealAfterInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterInsert);
			isAfterInsertProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterInsert);
	}
	public virtual override void afterUpdate(SL_TriggerParameters tp) {
		if(!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			execute(new SL_DealAfterUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
			isAfterUpdateProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
	}
	public virtual override void afterDelete(SL_TriggerParameters tp) {
		if(!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			execute(new SL_DealAfterDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterDelete);
			isAfterDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterDelete);
	}
	public virtual override void afterUnDelete(SL_TriggerParameters tp) {
		if(!isAfterUnDeleteProcessing) {
			isAfterUnDeleteProcessing = true;
			execute(new SL_DealAfterUnDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
			isAfterUnDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
	}
}