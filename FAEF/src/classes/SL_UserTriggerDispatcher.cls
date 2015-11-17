/**
 * @Author		: Jared Kass
 * @ClassName   : SL_UserTriggerDispatcher
 * @CreatedOn   : 29 Dec 2014
 * @Test		: 
 * @Description : Dispatcher class for User object and associated handlers.
 */
global class SL_UserTriggerDispatcher extends SL_TriggerDispatcherBase {
	private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isBeforeDeleteProcessing = false;
  	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false; 
  	private static Boolean isAfterDeleteProcessing = false;
	private static Boolean isAfterUnDeleteProcessing = false;

	public class SL_UserBeforeInsertTriggerHandler extends SL_TriggerHandlerBase {
    	public override void mainEntry(SL_TriggerParameters tp) {
  			/*BEFORE INSERT METHODS START*/

    		/*BEFORE INSERT METHODS END*/
		}
  	}
  	public class SL_UserBeforeUpdateTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	    	/*BEFORE UPDATE METHODS START*/
       		SL_UserHelper.updateFrequency(tp);
	        /*BEFORE UPDATE METHODS END*/
	    }
  	}
  	public class SL_UserBeforeDeleteTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*BEFORE DELETE METHODS START*/

	        /*BEFORE DELETE METHODS END*/
	    }
  	}
  	public class SL_UserAfterInsertTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*AFTER INSERT METHODS START*/
					SL_UserHelper.creatGroupMembers(tp);
	        /*AFTER INSERT METHODS END*/
	    }
  	}
  	public class SL_UserAfterUpdateTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*AFTER UPDATE METHODS START*/
	      
	        /*AFTER UPDATE METHODS END*/
	    }
  	}
  	public class SL_UserAfterDeleteTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*AFTER DELETE METHODS START*/
	      
	        /*AFTER DELETE METHODS END*/
	    }
  	}
  	public class SL_UserAfterUndeleteTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*AFTER UNDELETE METHODS START*/
	      
	        /*AFTER UNDELETE METHODS END*/
	    }
  	}
  
  	public SL_UserTriggerDispatcher(){
    	super('User');
  	}
  
  	public virtual override void beforeInsert(SL_TriggerParameters tp) {
	    if(!isBeforeInsertProcessing) {
	      isBeforeInsertProcessing = true;
	      execute(new SL_UserBeforeInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
	      isBeforeInsertProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
  	}
  	public virtual override void beforeUpdate(SL_TriggerParameters tp) {
	    if(!isBeforeUpdateProcessing) {
	      isBeforeUpdateProcessing = true;
	      execute(new SL_UserBeforeUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
	      isBeforeUpdateProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
  	}
  	public virtual override void beforeDelete(SL_TriggerParameters tp) {
	    if(!isBeforeDeleteProcessing) {
	      isBeforeDeleteProcessing = true;
	      execute(new SL_UserBeforeDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
	      isBeforeDeleteProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
  	} 
  	public virtual override void afterInsert(SL_TriggerParameters tp) {
	    if(!isAfterInsertProcessing) {
	      isAfterInsertProcessing = true;
	      execute(new SL_UserAfterInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterInsert);
	      isAfterInsertProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterInsert);
  	}
  	public virtual override void afterUpdate(SL_TriggerParameters tp) {
	    if(!isAfterUpdateProcessing) {
	      isAfterUpdateProcessing = true;
	      execute(new SL_UserAfterUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
	      isAfterUpdateProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
  	}
  	public virtual override void afterDelete(SL_TriggerParameters tp) {
	    if(!isAfterDeleteProcessing) {
	      isAfterDeleteProcessing = true;
	      execute(new SL_UserAfterDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterDelete);
	      isAfterDeleteProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterDelete);
  	}
  	public virtual override void afterUnDelete(SL_TriggerParameters tp) {
	    if(!isAfterUnDeleteProcessing) {
	      isAfterUnDeleteProcessing = true;
	      execute(new SL_UserAfterUnDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
	      isAfterUnDeleteProcessing = false;
	    }
    	else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
  	}
}