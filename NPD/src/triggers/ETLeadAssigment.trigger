trigger ETLeadAssigment on Lead (after insert) 
{
    // Make sure we do not repeat the call
    if(!RunLeadAssigmentRules.isRunning)
    {
        Set<Id> listIds = new Set<Id>();
        
        // For all the leads
        for (Lead theLead:trigger.new) 
        {
            // Set your criteria
            if(theLead.Created_by_ET__c) 
            {
                listIds.add(theLead.id);    
            }      
        }
        
        // call the @future method 
        RunLeadAssigmentRules.updateLeads(listIds);
    }
}