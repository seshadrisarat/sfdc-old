/*
*Trigger: SL_ProviderSpecialty
*Description: Implement a trigger on insert of Provider Specialty to roll up its name to a comma separated text field on
              Provider called 'Specialties''
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
// Trigger on afterInsert and after delete on Provider Specialty
trigger SL_ProviderSpecialty on Provider_Specialty__c (after insert, after update, after delete)
{
    // Handler class for calling functions based on event
    SL_ProviderSpecialty_Handler objHandler = new SL_ProviderSpecialty_Handler(Trigger.isExecuting, Trigger.size);

    if(trigger.isAfter && trigger.isInsert)
    {
        // Calling functions of handler class on after insert of Provider Specialty
        objHandler.onAfterInsert(trigger.New);
    }
 
    if(trigger.isAfter && trigger.isUpdate)
    {
        objHandler.onAfterUpdate(trigger.Old, trigger.New);
    }

    if(trigger.isAfter && trigger.isDelete)
    {
        // Calling functions of handler class on after delete of Provider Specialty
        objHandler.onAfterDelete(trigger.Old);
    }
}