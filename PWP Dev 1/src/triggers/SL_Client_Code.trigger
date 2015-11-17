trigger SL_Client_Code on Client_Code__c (before insert) 
{
    SL_Client_Code_Handler objHandler = new SL_Client_Code_Handler();
    if(Trigger.isBefore && Trigger.isInsert)
    {
        objHandler.onBeforeInsert(Trigger.new);
    }
}