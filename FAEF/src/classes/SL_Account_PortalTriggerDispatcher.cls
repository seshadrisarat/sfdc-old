/**
 * @Author		: Jared Kass
 * @ClassName   : SL_Account_PortalTriggerDispatcher
 * @CreatedOn   : 29 Dec 2014
 * @Test		: 
 * @Description : Dispatcher class for Account Portal object and associated handlers.
 */
global class SL_Account_PortalTriggerDispatcher extends SL_TriggerDispatcherBase {
	private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isBeforeDeleteProcessing = false;
  	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false; 
  	private static Boolean isAfterDeleteProcessing = false;
	private static Boolean isAfterUnDeleteProcessing = false;

	public class SL_Account_PortalBeforeInsertTriggerHandler extends SL_TriggerHandlerBase {
    	public override void mainEntry(SL_TriggerParameters tp) {
  			/*BEFORE INSERT METHODS START*/
	      	SL_Account_PortalHelper.createChatterGroup(tp);    		
      		/*BEFORE INSERT METHODS END*/
		}
  	}
  	public class SL_Account_PortalBeforeUpdateTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	    	/*BEFORE UPDATE METHODS START*/
       		
	        /*BEFORE UPDATE METHODS END*/
	    }
  	}
  	public class SL_Account_PortalBeforeDeleteTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*BEFORE DELETE METHODS START*/
	      	SL_Account_PortalHelper.removeChatterGroup(tp);
	        /*BEFORE DELETE METHODS END*/
	    }
  	}
  	public class SL_Account_PortalAfterInsertTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*AFTER INSERT METHODS START*/

	        /*AFTER INSERT METHODS END*/
	    }
  	}
  	public class SL_Account_PortalAfterUpdateTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*AFTER UPDATE METHODS START*/
	      
	        /*AFTER UPDATE METHODS END*/
	    }
  	}
  	public class SL_Account_PortalAfterDeleteTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*AFTER DELETE METHODS START*/
	      
	        /*AFTER DELETE METHODS END*/
	    }
  	}
  	public class SL_Account_PortalAfterUndeleteTriggerHandler extends SL_TriggerHandlerBase {
	    public override void mainEntry(SL_TriggerParameters tp) {
	        /*AFTER UNDELETE METHODS START*/
	      
	        /*AFTER UNDELETE METHODS END*/
	    }
  	}
  
  	public SL_Account_PortalTriggerDispatcher(){
    	super('Account_Portal__c');
  	}
  
  	public virtual override void beforeInsert(SL_TriggerParameters tp) {
	    if(!isBeforeInsertProcessing) {
	      isBeforeInsertProcessing = true;
	      execute(new SL_Account_PortalBeforeInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
	      isBeforeInsertProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeInsert);
  	}
  	public virtual override void beforeUpdate(SL_TriggerParameters tp) {
	    if(!isBeforeUpdateProcessing) {
	      isBeforeUpdateProcessing = true;
	      execute(new SL_Account_PortalBeforeUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
	      isBeforeUpdateProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeUpdate);
  	}
  	public virtual override void beforeDelete(SL_TriggerParameters tp) {
	    if(!isBeforeDeleteProcessing) {
	      isBeforeDeleteProcessing = true;
	      execute(new SL_Account_PortalBeforeDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
	      isBeforeDeleteProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.beforeDelete);
  	} 
  	public virtual override void afterInsert(SL_TriggerParameters tp) {
	    if(!isAfterInsertProcessing) {
	      isAfterInsertProcessing = true;
	      execute(new SL_Account_PortalAfterInsertTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterInsert);
	      isAfterInsertProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterInsert);
  	}
  	public virtual override void afterUpdate(SL_TriggerParameters tp) {
	    if(!isAfterUpdateProcessing) {
	      isAfterUpdateProcessing = true;
	      execute(new SL_Account_PortalAfterUpdateTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
	      isAfterUpdateProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUpdate);
  	}
  	public virtual override void afterDelete(SL_TriggerParameters tp) {
	    if(!isAfterDeleteProcessing) {
	      isAfterDeleteProcessing = true;
	      execute(new SL_Account_PortalAfterDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterDelete);
	      isAfterDeleteProcessing = false;
	    }
	    else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterDelete);
  	}
  	public virtual override void afterUnDelete(SL_TriggerParameters tp) {
	    if(!isAfterUnDeleteProcessing) {
	      isAfterUnDeleteProcessing = true;
	      execute(new SL_Account_PortalAfterUnDeleteTriggerHandler(), tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
	      isAfterUnDeleteProcessing = false;
	    }
    	else execute(null, tp, SL_TriggerParameters.TriggerEvent.afterUndelete);
  	}
}