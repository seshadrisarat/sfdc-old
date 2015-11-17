/**
* @ClassName 	:	SL_Manage_Assumptions_Controller 
* @JIRATicket   :	SLPSA-11
* @CreatedOn    :	25/Jun/13
* @ModifiedBy   :	Hemant
* @Description  :	This is Handler for Project_Assumption__c object
*/

/**
Percentage of best practices followed	: 100%
No of SOQL queries used					: 1
No of SOSL queries used					: 0
No of collections used					: 0
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	: 20
Customer Approval						:
Last Modified Date						: 25/Jun/13
Approved by								:

*/
public with sharing class SL_Project_Assumption_Handler 
{
	/* Start - Variables */
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	/* End - Variables */
	
	 /*  Consructor */
	public SL_Project_Assumption_Handler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	
	/*
		@MethodName		: onBeforeInsertUpdate
		@param			: lstNewAssumption (Trigger New Values)
		@Description	: Method to be called when a Project_Assumption__c has been inserted or updated
	*/
	public void onBeforeInsertUpdate(List<Project_Assumption__c> lstNewAssumption)
	{
		try
		{
			set<Id> setAssumptionIds = new set<Id>();
			map<Id,Assumption__c> mapIdAssumption = new map<Id,Assumption__c>();
			
			//Storing the Assumption Ids to setAssumptionIds
			for(Project_Assumption__c objAssumption : lstNewAssumption)
				setAssumptionIds.add(objAssumption.Assumption__c);
			
			//Querying Assumption records 
			for(Assumption__c objAssumption : [Select Id,Assumption_Detail__c from Assumption__c where Id In: setAssumptionIds])
				mapIdAssumption.put(objAssumption.Id,objAssumption);
				
			for(Project_Assumption__c objProjectAssum : lstNewAssumption)
			{
				//Updating the values of Assumption_Detail field
				if(objProjectAssum.Assumption_Detail_One_time_use__c == null || objProjectAssum.Assumption_Detail_One_time_use__c == '')
					objProjectAssum.Assumption_Detail__c =  mapIdAssumption.get(objProjectAssum.Assumption__c).Assumption_Detail__c;
				else
					objProjectAssum.Assumption_Detail__c = objProjectAssum.Assumption_Detail_One_time_use__c;
                
                //Updating the Assumption_Detail_UI__c field
				if(objProjectAssum.Assumption_Detail__c != null && objProjectAssum.Assumption_Detail__c != '')
					objProjectAssum.Assumption_Detail_UI__c = objProjectAssum.Assumption_Detail__c.length()>255 ? objProjectAssum.Assumption_Detail__c.substring(0,252)+ '...':objProjectAssum.Assumption_Detail__c;
				else
					objProjectAssum.Assumption_Detail_UI__c = '';
			}
		}
		catch(Exception ex)
		{
			System.debug('===============Exception============'+ex.getMessage()+'========@line Number=='+ex.getLineNumber());
		}
	}
	
	//Test Method
    @isTest 
    static void SL_Project_Assumption_Handler_Test()
    {
    	Assumption__c objAssumption1 = new Assumption__c(Name='Assumption',Task_Type__c = 'All,Configuration',Component__c = 'All,Account',Industries__c = 'All,Investment Banking');
    	insert objAssumption1;
    	Project_Assumption__c objProjectAssum = new Project_Assumption__c();
    	objProjectAssum.Assumption__c = objAssumption1.Id;
    	insert objProjectAssum;
    	objProjectAssum.Assumption_Detail_One_time_use__c = 'test';
    	update objProjectAssum;
    }
}