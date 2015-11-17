/**
* @date 11/9/2014
* @description This class holds the trigger parameters.
*/
public class SL_TriggerParameters {

	/** 
	* @date 11/9/2014
	* @description A enum that represents the trigger event.
	*/
	public Enum TriggerEvent { beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete }
	public TriggerEvent tEvent;
	
	public List<SObject> oldList { get; private set; }
	public List<SObject> newList { get; private set; }
	public Map<Id, SObject> oldMap { get; private set; }
	public Map<Id, SObject> newMap { get; private set; }
	public String triggerObject { get; private set; }
	public Boolean isExecuting { get; private set; }
	
	/** 
	* @date 11/9/2014
	* @description Constructs the TriggerParameter object.
	* @param List<SObject> A list of records with the state of 'before' event.
	* @param List<SObject> A list of records with the state of 'after' event.
	* @param Map<Id, SObject> A map of records with the state of 'before' event.
	* @param Map<Id, SObject> A map of records with the state of 'after' event.
	* @param Boolean A flag to indicate 'isBefore' event.
	* @param Boolean A flag to indicate 'isAfter' event.
	* @param Boolean A flag to indicate 'isDelete' event.
	* @param Boolean A flag to indicate 'isInsert' event.
	* @param Boolean A flag to indicate 'isUpdate' event.
	* @param Boolean A flag to indicate 'isUnDelete' event.
	* @param Boolean A flag to indicate 'isExecuting'.
	*/
	public SL_TriggerParameters(List<SObject> olist, List<SObject> nlist, Map<Id, SObject> omap, Map<Id, SObject> nmap,
								Boolean ib, Boolean ia, Boolean id, Boolean ii, Boolean iu, Boolean iud, Boolean ie) {
		this.oldList = olist;
		this.newList = nlist;
		this.oldMap = omap;
		this.newMap = nmap;
		this.triggerObject = ((this.oldList != null && this.oldList.size() > 0) ? this.oldList[0] : this.newList[0]).getSObjectType().getDescribe().getName();
		if (ib){
			if (ii) tEvent = TriggerEvent.beforeInsert;
			else if (iu) tEvent = TriggerEvent.beforeUpdate;
			else if (id) tEvent = TriggerEvent.beforeDelete;
		}
		else if (ia) {
			if (ii) tEvent = TriggerEvent.afterInsert;
			else if (iu) tEvent = TriggerEvent.afterUpdate;
			else if (id) tEvent = TriggerEvent.afterDelete;
			else if (iud) tEvent = TriggerEvent.afterUndelete;
		}
		isExecuting = ie;
	}
}