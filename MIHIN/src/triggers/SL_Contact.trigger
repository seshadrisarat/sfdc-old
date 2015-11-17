/*
*Trigger: SL_Contact
*Description: This trigger is used to update the Latitude, Longitude and Geocoding_Required__c fields on change of the other contact address. 
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_Contact on Contact (before update ,before insert, after update, after insert) 
{
    SL_ContactHandler objContactHandler = new SL_ContactHandler(Trigger.isExecuting, Trigger.size);// This handler for MIHIN-62 functionality.
    if(Trigger.isBefore && Trigger.isInsert)
    {
        objContactHandler.onBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate)    
    {
        objContactHandler.onBeforeUpdate(Trigger.OldMap, Trigger.NewMap);
    }
    
    /* Start - Added By Pankaj Ganwani on 16th JUNE 2015 as per the requirements of MIHIN-109*/
    if(Trigger.isAfter && Trigger.isInsert)
    {
    	objContactHandler.onAfterInsert(Trigger.new);
    }
    /* End - Added By Pankaj Ganwani on 16th JUNE 2015 as per the requirements of MIHIN-109*/

    if(Trigger.isAfter && Trigger.isUpdate)
    {
        objContactHandler.onAfterUpdate(Trigger.OldMap, Trigger.NewMap);
    }

}