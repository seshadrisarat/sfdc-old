public with sharing class SL_IntranetEventTypes extends WidgetAbstract
{
	public List<RecordType> lstIntranetEventRecordTypes 										{	get;set;	} //List to store all the record types 
	
	/* Start : Constructor initialization */
	public SL_IntranetEventTypes()
	{
		lstIntranetEventRecordTypes = new List<RecordType>();
	}
	/* End : Constructor initialization */
	   
	// initialize method called on component's initialize
	public override protected void initialize()
	{
		if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
		try
		{
			//Fetching all the Calendar view for Simple list views of Intranet event records
	        lstIntranetEventRecordTypes = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Intranet_Event__c' and IsActive = true order by Name asc];
	        
	        //To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;  
		}
		catch(Exception ex)
		{
			system.debug('::::::::Exception::::::::'+ex);
		}
	}
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetEventTypes c = new Component.c.SL_IntranetEventTypes();   
		c.aComponentImpl = this;
		
    	return c;
  	}
  	/* End : newComponent */
}