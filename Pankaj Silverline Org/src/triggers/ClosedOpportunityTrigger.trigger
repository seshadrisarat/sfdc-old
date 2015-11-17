trigger ClosedOpportunityTrigger on Opportunity (before insert, before update) 
{
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        List<Task> lstTask = new List<Task>();
        for(Opportunity objOpp :Trigger.New)
        {
            if(objOpp.StageName == 'Closed Won')
            {
                lstTask.add(new Task(Priority = 'Low',Subject = 'Follow Up Test Task', WhatId = objOpp.Id));
            }
        }
        if(!lstTask.isEmpty())
            insert lstTask;
    }
}