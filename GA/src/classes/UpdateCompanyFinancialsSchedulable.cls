global with sharing class UpdateCompanyFinancialsSchedulable implements Schedulable 
{ 
    global void execute(SchedulableContext ctx) 
    {
        try 
        {
            Database.executeBatch(new UpdateCompanyFinancialsBatchable());
        } 
        catch (Exception e) {  }
    }
}