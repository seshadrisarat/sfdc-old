/**
* @ClassName    : SL_IntranetUserInfo 
* @JIRATicket   : Socint-181
* @CreatedOn    : 1/July/13
* @ModifiedBy   : Roshan 
* @Description  : This is the Implementation Class for The SL_IntranetUserInfoController.
*/

/**
@ Roshan Pillai 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 
No of collections used                  : 
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetUserInfo extends WidgetAbstract  
{
	// Global Variables
	public User objUser 					{	get; set;	}
	private String strApplicationId;
	public Boolean hasEditAccess			{	get; set;	}
		
	/* Constructor initialization */
    public SL_IntranetUserInfo()
    {
		strApplicationId = '';
    }
    /* End : Constructor initialization */
    
    public override protected void initialize()
	{
		List<User> lstUser = [Select SmallPhotoUrl, Intranet_Administrator__c 
							  From User 
							  where Id =:UserInfo.getUserId() limit 1];
		objUser = lstUser[0];
		hasEditAccess = getObjectAccess('create', new PageRegion__c().getsObjectType()) && getObjectAccess('delete', new PageRegion__c().getsObjectType()) 
						&& getObjectAccess('create', new Page__c().getsObjectType()) && getObjectAccess('delete', new Page__c().getsObjectType())
						&& getObjectAccess('create', new PageRegionWidget__c().getsObjectType()) && getObjectAccess('delete', new PageRegionWidget__c().getsObjectType());
	}
	
    /* @Name           - updateApplicationId
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for updating Application Id to custom seetings.
	*/	
	public void updateApplicationId() 
	{
		try
		{
			strApplicationId = ApexPages.currentPage().getParameters().get('tsid');
			
			if(String.isNotBlank(strApplicationId))
			{
				SL_IntranetApplicationSetting__c objAppSeetings = SL_IntranetApplicationSetting__c.getInstance('Default Settings');
				
				if(objAppSeetings != null)
				{
					objAppSeetings.WaterCooler_App_Id__c = strApplicationId;
					update objAppSeetings;
				}
				else
				{
					insert new SL_IntranetApplicationSetting__c(Name = 'Default Settings', 
															    WaterCooler_App_Id__c = strApplicationId);
				}
			}
		}
		catch(Exception ex){
			system.debug('::::::::::::: Exception ::::::::::::'+ex);
		}
	}
	/* End : updateApplicationId */
	
	/* @Name           - goToSalesforce
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for return back to home page of salesforce
	*/	
	public Pagereference goToSalesforce() 
	{
		strApplicationId = '';
		SL_IntranetApplicationSetting__c objAppSeetings = SL_IntranetApplicationSetting__c.getInstance('Default Settings');
		
		if(objAppSeetings != null && objAppSeetings.WaterCooler_App_Id__c != null)
			strApplicationId += '?tsid=' + objAppSeetings.WaterCooler_App_Id__c;

		Pagereference pref = new Pagereference('/home/home.jsp'+strApplicationId);
		pref.setRedirect(true);
		return pref;
	}
	/* End : goToSalesforce */
    
    
    /* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetUserInfo c = new Component.c.SL_IntranetUserInfo();   
		c.aComponentImpl = this;
    	return c;
  	}
  	/* End : newComponent */
}