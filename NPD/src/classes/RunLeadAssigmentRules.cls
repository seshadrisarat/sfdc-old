public with sharing class RunLeadAssigmentRules
{
    public static boolean isRunning = false;
    
    // Do nothing
    public RunLeadAssigmentRules()
    {   
    }
    
    @future
    static public void updateLeads(Set<id> theLeadId)
    {
        // Make sure the trigger does not go on a loop
        RunLeadAssigmentRules.isRunning = true;
        
        // set the dml options
        Database.DMLOptions dmo = new Database.DMLOptions();
        
        // Use defaults
        dmo.assignmentRuleHeader.useDefaultRule = true;
        
        List<Lead> leads = [Select id from Lead where id IN :theLeadId];
        
        if(leads.size() > 0)
        {
            // set the options for all the leads
            for(Lead theLead :leads)
            {
                theLead.setOptions(dmo);
            }
            
            // update all the leads
            Database.update(leads);
        }    
    }
}