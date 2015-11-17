/**  
* \arg ClassName        : SL_AccountTriggerDispatcher
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Dispatcher class for Account object and associated handlers.
*/
global class SL_AccountTriggerDispatcher extends SL_TriggerDispatcherBase {

	public class SL_AccountBeforeInsertTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			List<Account> newList = (List<Account>) tp.newList;
			/*BEFORE INSERT METHODS START*/
			
			/*BEFORE INSERT METHODS END*/
		}
	}
	public class SL_AccountBeforeUpdateTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Account> newMap = (Map<Id, Account>) tp.newMap;
			Map<Id, Account> oldMap = (Map<Id, Account>) tp.oldMap;
			/*BEFORE UPDATE METHODS START*/
			
			/*BEFORE UPDATE METHODS END*/
		}
	}
	public class SL_AccountBeforeDeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Account> oldMap = (Map<Id, Account>) tp.oldMap;
			/*BEFORE DELETE METHODS START*/
			
			/*BEFORE DELETE METHODS END*/
		}
	}
	public class SL_AccountAfterInsertTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Account> newMap = (Map<Id, Account>) tp.newMap;
			/*AFTER INSERT METHODS START*/
			SL_AccountHelper.updateProspectSharing(newMap);
			/*AFTER INSERT METHODS END*/
		}
	}
	public class SL_AccountAfterUpdateTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Account> newMap = (Map<Id, Account>) tp.newMap;
			Map<Id, Account> oldMap = (Map<Id, Account>) tp.oldMap;
			/*AFTER UPDATE METHODS START*/
			SL_AccountHelper.updateProspectSharing(newMap);
			/*AFTER UPDATE METHODS END*/
		}
	}
	public class SL_AccountAfterDeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Account> oldMap = (Map<Id, Account>) tp.oldMap;
			/*AFTER DELETE METHODS START*/
			
			/*AFTER DELETE METHODS END*/
		}
	}
	public class SL_AccountAfterUndeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			Map<Id, Account> newMap = (Map<Id, Account>) tp.newMap;
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
	
	public SL_AccountTriggerDispatcher(){
		super('Account');
	}
	
	public virtual override void beforeInsert(SL_TriggerParameters tp) {
		if(!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new SL_AccountBeforeInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
			isBeforeInsertProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
	}
	public virtual override void beforeUpdate(SL_TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new SL_AccountBeforeUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
	}
	public virtual override void beforeDelete(SL_TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			execute(new SL_AccountBeforeDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
			isBeforeDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
	}	
	public virtual override void afterInsert(SL_TriggerParameters tp) {
		if(!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new SL_AccountAfterInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterInsert);
			isAfterInsertProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterInsert);
	}
	public virtual override void afterUpdate(SL_TriggerParameters tp) {
		if(!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			execute(new SL_AccountAfterUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
			isAfterUpdateProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
	}
	public virtual override void afterDelete(SL_TriggerParameters tp) {
		if(!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			execute(new SL_AccountAfterDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterDelete);
			isAfterDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterDelete);
	}
	public virtual override void afterUnDelete(SL_TriggerParameters tp) {
		if(!isAfterUnDeleteProcessing) {
			isAfterUnDeleteProcessing = true;
			execute(new SL_AccountAfterUnDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
			isAfterUnDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
	}
}