/*
*Trigger: SL_User
*Description: This trigger is used to calculate the number of licenses used by organizations
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_User on User (before insert,after insert,after update,before update) 
{
    SL_UserHandler objSL_UserHandler = new SL_UserHandler();//instantiating the Handler
    if(Trigger.isBefore && Trigger.isInsert)
    {
        objSL_UserHandler.onBeforeInsert(Trigger.new);//Calling function for on before insert
    }
    if(Trigger.isAfter && Trigger.isInsert)
    {
        objSL_UserHandler.onAfterInsert(Trigger.newMap);//Calling function for on after insert
    }
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        objSL_UserHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);//Calling function for on after update
    }
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        objSL_UserHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);//Calling function for on before update
    }
}