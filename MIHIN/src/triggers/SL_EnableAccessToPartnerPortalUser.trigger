/*
*Trigger: SL_EnableAccessToPartnerPortalUser
*Description: Trigger to enable sharing of record of Gold Partner users on insert/update of Contact record.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_EnableAccessToPartnerPortalUser on Contact (after insert, after update) 
{
    SL_EnableAccessToPartnerUsersHandler objHandler = new SL_EnableAccessToPartnerUsersHandler();
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
       // objHandler.onAfterInsert(Trigger.New); 
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
       // objHandler.onAfterUpdate(Trigger.New, Trigger.OldMap);
    }
}