/* Trigger on After Update of Property to delete current_tenant records and create new previous_tenant records */
 
trigger SL_Property on Property__c (after update)
{
   SL_Property_Trigger_Handler handler = new SL_Property_Trigger_Handler(trigger.isExecuting, trigger.size);
   
   if(Trigger.isUpdate)
   {
       if(Trigger.isAfter)
       {
           handler.onAfterUpdate(trigger.newMap, trigger.oldMap);
       }
   }
}