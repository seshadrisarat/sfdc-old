trigger ClosedOpportunityTrigger on Opportunity (after insert, after update ) 
{
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
    List<Task> lstTask = new List<Task>();
        for(Opportunity obj : Trigger.New)
        {
            if(obj.stageName == 'Closed Won')
            lstTask .add(New task(Subject = 'Follow Up Test Task', WhatId = obj .Id));
        }
        insert lstTask;
    }
}