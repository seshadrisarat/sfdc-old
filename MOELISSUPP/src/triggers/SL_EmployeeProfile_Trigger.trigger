trigger SL_EmployeeProfile_Trigger on Employee_Profile__c (before update) 
{
	SL_EmployeeProfile_Trigger_Handler handler = new SL_EmployeeProfile_Trigger_Handler(Trigger.isExecuting, Trigger.size);
 
    if(trigger.IsUpdate)
    {
       //if(trigger.IsAfter)  		
       		//handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap,Trigger.new);
       	if(trigger.IsBefore)  		
       		handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap,Trigger.new);
    }  
}