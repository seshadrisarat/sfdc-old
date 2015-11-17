trigger SL_ProjectTimeTracking on Project_Time_Tracking__c (after insert, after update) 
{
    //Handler class for calling functions based on event
    SL_ProjectTimeTrackingHandler objProjTimeTracking = new SL_ProjectTimeTrackingHandler();
    
     // calling on After Insert
    if(trigger.isAfter && Trigger.isInsert)
    	objProjTimeTracking.onAfterInsert(trigger.newMap);
    
   // calling on before Update
    if(Trigger.isAfter && Trigger.isUpdate)
    	objProjTimeTracking.onAfterUpdate(trigger.oldMap, trigger.newMap);
}