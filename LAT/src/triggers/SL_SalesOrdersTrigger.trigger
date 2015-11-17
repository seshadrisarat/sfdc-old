/**
@Trigger Name  : SL_SalesOrdersTrigger
@JIRA Ticket   : LAT-4
@Created on    : 30/04/2015
@Modified by   : Sanath Kumar
@Description   : Trigger on insert and update of Sales_Orders__c, This trigger will Update OwnerId to the User indicated by the IntegrationID__c field
*/
trigger SL_SalesOrdersTrigger on Sales_Orders__c (before insert , before update) 
{
    //// initialize the handler class SL_SalesOrdersTrigger
    SL_SalesOrdersHandler triggerHandler = new SL_SalesOrdersHandler();
    
    //Called on before insert of Sales_Orders__c record
    if(trigger.isBefore && trigger.isInsert)
    {
        triggerHandler.onBeforeInsert(trigger.new);
    }
    
    //Called on before update of Sales_Orders__c record    
    if(trigger.isBefore && trigger.isUpdate)
    {
        triggerHandler.onbeforeUpdate(trigger.new);
    }
}