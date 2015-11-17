/**
* @Trigger Name     : SL_Project
* @JIRATicket       : DLIB-4
* @CreatedOn        : 22/AUG/2014
* @ModifiedBy       : Lodhi
* @Description      : This is the trigger on Project__c Object
*/
trigger SL_Project on Project__c (after undelete, after update, after insert) 
{
	SL_ProjectHandler objProjectHandler = new SL_ProjectHandler(Trigger.isExecuting, Trigger.size);
	
	if(trigger.isAfter && trigger.isInsert)
    {
        //calling functions of handler class on before insert
		objProjectHandler.onAfterInsert(trigger.newMap);
    }
    if(trigger.isAfter && trigger.isUpdate)
    {
    	//calling functions of handler class on after Update
		objProjectHandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
	}
	if(trigger.isAfter && trigger.isUnDelete)
    {
    	//calling functions of handler class on after Updelete
    	objProjectHandler.onAfterUndelete(trigger.newMap);
    }					
}