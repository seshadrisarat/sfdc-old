/**  
* \arg ClassName        : SL_Investor_EntityTriggerDispatcher
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Dispatcher class for Investor_Entity object and associated handlers.
*/
global class SL_Investor_EntityTriggerDispatcher extends SL_TriggerDispatcherBase {
	private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isBeforeDeleteProcessing = false;
	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false; 
	private static Boolean isAfterDeleteProcessing = false;
	private static Boolean isAfterUnDeleteProcessing = false;

	public class SL_Investor_EntityBeforeInsertTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			/*BEFORE INSERT METHODS START*/
			
			/*BEFORE INSERT METHODS END*/
		}
	}
	public class SL_Investor_EntityBeforeUpdateTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			/*BEFORE UPDATE METHODS START*/
			
			/*BEFORE UPDATE METHODS END*/
		}
	}
	public class SL_Investor_EntityBeforeDeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			/*BEFORE DELETE METHODS START*/
			
			/*BEFORE DELETE METHODS END*/
		}
	}
	public class SL_Investor_EntityAfterInsertTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			/*AFTER INSERT METHODS START*/

			SL_Investor_EntityHelper.afterInsert(tp.newMap);
			
			/*AFTER INSERT METHODS END*/
		}
	}
	public class SL_Investor_EntityAfterUpdateTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			/*AFTER UPDATE METHODS START*/

			SL_Investor_EntityHelper.afterUpdate(tp.oldMap, tp.newMap);
			
			/*AFTER UPDATE METHODS END*/
		}
	}
	public class SL_Investor_EntityAfterDeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			/*AFTER DELETE METHODS START*/
			
			/*AFTER DELETE METHODS END*/
		}
	}
	public class SL_Investor_EntityAfterUndeleteTriggerHandler extends SL_TriggerHandlerBase {
		public override void mainEntry(SL_TriggerParameters tp) {
			/*AFTER UNDELETE METHODS START*/
			
			/*AFTER UNDELETE METHODS END*/
		}
	}
	
	public SL_Investor_EntityTriggerDispatcher(){
		super('Investor_Entity');
	}
	
	public virtual override void beforeInsert(SL_TriggerParameters tp) {
		if(!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new SL_Investor_EntityBeforeInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
			isBeforeInsertProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
	}
	public virtual override void beforeUpdate(SL_TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new SL_Investor_EntityBeforeUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
	}
	public virtual override void beforeDelete(SL_TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			execute(new SL_Investor_EntityBeforeDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
			isBeforeDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
	}	
	public virtual override void afterInsert(SL_TriggerParameters tp) {
		if(!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new SL_Investor_EntityAfterInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterInsert);
			isAfterInsertProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterInsert);
	}
	public virtual override void afterUpdate(SL_TriggerParameters tp) {
		if(!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			execute(new SL_Investor_EntityAfterUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
			isAfterUpdateProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
	}
	public virtual override void afterDelete(SL_TriggerParameters tp) {
		if(!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			execute(new SL_Investor_EntityAfterDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterDelete);
			isAfterDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterDelete);
	}
	public virtual override void afterUnDelete(SL_TriggerParameters tp) {
		if(!isAfterUnDeleteProcessing) {
			isAfterUnDeleteProcessing = true;
			execute(new SL_Investor_EntityAfterUnDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
			isAfterUnDeleteProcessing = false;
		}
		else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
	}
}