/**
* \arg  TriggerName    : SL_TickSheetProperty_Trigger
* \arg  JIRATicket     : WP-104
* \arg  CreatedOn      : 18/JULY/2013
* \arg  ModifiedBy     : -
* \arg  Description    : Trigger to call the ticksheet property handler method
                         on insert/update of ticksheet property record
*/
trigger SL_TickSheetProperty_Trigger on Ticksheet_Property__c (before insert, before update) 
{
    SL_TickSheetProperty_Handler objTickSheetPropertyHandler = new SL_TickSheetProperty_Handler();
    
    //called before inserting Ticksheet_Property__c record
    if(trigger.isBefore && trigger.isInsert)
    {
        objTickSheetPropertyHandler.onBeforeInsert(trigger.new);
    }
    
    //called before updating Ticksheet_Property__c record
    if(trigger.isBefore && trigger.isUpdate)
    {
        objTickSheetPropertyHandler.onBeforeUpdate(trigger.new,trigger.oldMap);
    }
    
    //called after inserting Ticksheet_Property__c record
    if(trigger.isAfter && trigger.isInsert)
    {
        //do nothing
    }
    
    //called after updating Ticksheet_Property__c record
    if(trigger.isAfter && trigger.isUpdate)
    {
        //do nothing
    }
}