/**
*  ClassName      : SL_ActivityMilestoneBatch
*  JIRATicket     : THOR-26
*  CreatedOn      : 05/SEP/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the batch rollup the task and event dates based on type to the Lead and Opportunity
*/
global class SL_ActivityMilestoneBatch implements Database.Batchable<Sobject>
{
	/* START : Global variables */
    public string strQuery = ''; 
    /* END : Global variables */
    
    
    /* Start : Constructor */
    public SL_ActivityMilestoneBatch(String strQuery)
    {
        this.strQuery = strQuery;   
    }
    /* End : Constructor */
    
    
    /*
    	* MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns list of Opportunities/Leads to execute method
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	return Database.getQueryLocator(strQuery);
    }
    
    
    /*
    	* MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Task> lstSobjects
        * Description  : Processes Opportunity/Lead records returned by start method
    */
    global void execute(Database.BatchableContext BC, List<Sobject> lstSobjects)
    {
    	SL_ActivityMilestoneGenericClass  objActivityMilestoneGenericClass  = new SL_ActivityMilestoneGenericClass(lstSobjects);
    }
    
    
    /*
    	* MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        ///Does nothing
    }
}