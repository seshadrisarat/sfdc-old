/**
*  Trigger Name   : SL_OpportunityTrigger
*  JIRATicket     : STARGAS-5, STARGAS-19, STARGAS-20, STARGAS-21, STARGAS-24, STARGAS-26, STARGAS-32 and STARGAS-35
*  CreatedOn      : 20/08/2014
*  ModifiedBy     : Pankaj Ganwani
*  Description    : trigger to call handler class method on before insert,before update, 
                    Need to be able to auto-populate a Service Company picklist field value based on the value in the Territory object Service Company field.
*/
trigger SL_OpportunityTrigger on Opportunity (before insert,before update,after insert,after update) 
{
    //Handler class for trigger
    SL_Opportunity_Handler handler = new SL_Opportunity_Handler();
    
     //Before insert of the trigger, calling the handler class beforeInsert method for necessary updates.
    if(trigger.isBefore)
    {
        if(Trigger.isInsert)
            handler.onBeforeInsert(Trigger.new);
        if(Trigger.isUpdate)
            handler.onBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
    }
    
    //on after insert of the opportunity record we are calling onAfterInsert method for necessary updates
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            handler.onAfterInsert(Trigger.NewMap);
        if(Trigger.isUpdate)
            handler.onAfterUpdate(Trigger.OldMap, Trigger.NewMap);
    }
    
}