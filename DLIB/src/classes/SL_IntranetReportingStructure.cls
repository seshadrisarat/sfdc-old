/**
* @ClassName    : SL_IntranetReportingStructure 
* @JIRATicket   : Socint-192
* @CreatedOn    : 24/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the Implementation Class for The SL_IntranetReportingStructureController.
*/

/**
@ Roshan Pillai 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 2
No of collections used                  : 3
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetReportingStructure extends WidgetAbstract 
{
	public List<User> lstReportingUsers 					{get;set;}
	public List<User> lstManager 							{get;set;}
	public Integer numberOfRecordToDisplay					{get;set;}		 
	public Integer totalRecords								{get;set;}		 
	private Id userId;
	private Integer numberToDisplay;										 
	
	/* Constructor initialization */
    public SL_IntranetReportingStructure()
    {
    	numberOfRecordToDisplay = 5;
    	totalRecords = 10;
    	numberToDisplay = 0;
		lstReportingUsers = new list<User>();
		lstManager = new List<User>();
		
		userId = Apexpages.currentPage().getParameters().get('id');
		
		if(userId == null)
			userId = UserInfo.getUserId();
		
	}
    /* End : Constructor initialization */

    // initialize method called on component's initialize
	public override protected void initialize()
	{
		prepareWidgetConfiguration();						// To fetch widget configuration
		getEmployeeReportingStructure();
	}
	
	/* Start - Method to get feed item related to particular user.
	   @Name           - prepareWidgetConfiguration
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function To get the employee reporting structure configuration.
	*/ 
	private void prepareWidgetConfiguration()
	{
		if(this.properties != null) {
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('numbertodisplay') && configuration.get('numbertodisplay') != '') 	
				numberToDisplay	= Integer.valueOf(configuration.get('numbertodisplay'));
			
			if(configuration.containsKey('totalrecords') && configuration.get('totalrecords') != '') 		
				totalRecords = Integer.valueOf(configuration.get('totalrecords'));
		}
		
		if(numberToDisplay > 0)
 			numberOfRecordToDisplay = numberToDisplay;
 		else if(numberToDisplay == 0 || numberToDisplay == null)
 			numberToDisplay = numberOfRecordToDisplay = 5;
		
		if(totalRecords == 0 || totalRecords == null)
 			totalRecords = 10;
	}
    /*End*/
    
    /* Start - Method to get feed item related to particular user.
	   @Name           - getEmployeeReportingStructure
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function To get the employee reporting structure and dispaly them on the page.
	*/  
	private void getEmployeeReportingStructure()
	{
		String strQueryReportingUser = 'SELECT Id, Name, LastName, ManagerId, Hire_Date__c, isActive, FirstName, Title, Select_Offices__c, Extension, ' + 
									   'SmallPhotoUrl, Phone, MobilePhone, FullPhotoUrl, ' + 
								       'Email, Department, CreatedDate, CommunityNickname, Fax, Street, State, PostalCode, Country, City ' +
								       'FROM User ' + 
								       'WHERE ManagerId = \''+ userId +'\'' + 
								       ' AND isActive = true ' +
								       ' AND Exclude_from_Intranet_Directory__c = FALSE';
								     	
		String strQueryForManager =  'SELECT Id, Name, LastName, ManagerId, ' + 
									 'Manager.lastName, Manager.Name, Manager.phone,  Manager.Hire_Date__c, Manager.isActive, Manager.FirstName, ' +
							   		 'Manager.Title, Manager.Select_Offices__c, Manager.Extension, Manager.SmallPhotoUrl, Manager.MobilePhone, ' +
							   		 'Manager.FullPhotoUrl, Manager.Email, Manager.Department, Manager.CreatedDate, Manager.CommunityNickname, ' +
							   		 'Manager.Fax, Manager.Street, Manager.State, Manager.PostalCode, Manager.Country, Manager.City ' +
						   			 'FROM User ' +
						   			 'WHERE Exclude_from_Intranet_Directory__c = FALSE AND ' +
						   			 'Id = \''+ userId +'\'';
						   			 
						   			 
		/*SOCINT-1027 to filter the Users when logged as Admin in Community*/
		String networkId = Network.getNetworkId(); 
		
		/*When logged in as Admin the Network Id will be null*/
		if(String.isEmpty(networkId)) 
		{
			strQueryForManager += ' AND ContactId = null'; //Add the filter ContactId = null so when we logged in as Admin and it wont display Community Licence Users.        
			strQueryReportingUser += ' AND ContactId = null'; //Add the filter ContactId = null when we logged in as Admin and it wont display Community Licence Users.
		}
		/*When accessing Community as Admin User and Network Id will not be null*/
		else if(String.isNotEmpty(networkId))
		{
			strQueryReportingUser += ' AND Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =\''+ networkId +'\' )'; //Adding the filter will provide all the members of the community related to its Network Id.
			strQueryForManager += ' AND Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =\''+ networkId +'\' )'; //Adding the filter will provide all the members of the community related to its Network Id.
		}
		/*---End---*/
		
		strQueryForManager += ' LIMIT 1'; 
		
		//Querying all the reporting users along with Manager
		lstReportingUsers = database.query(strQueryReportingUser);
		
		if(userId != null)
		{
			for(User objUser : database.query(strQueryForManager))
			{
				if(objUser.ManagerId != null)
					lstManager.add(objUser.Manager);
				
			}
		}
	}
	/* End : getEmployeeReportingStructure Method */
	
	/* @Name           - showMoreRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function to show more records on click of showMore.
	*/
	public void showMoreRecords()
	{
		numberOfRecordToDisplay += numberToDisplay;
		if(numberOfRecordToDisplay > totalRecords)
			numberOfRecordToDisplay = TotalRecords;
	}
    
    
    /* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetReportingStructure c = new Component.c.SL_IntranetReportingStructure();   
		c.aComponentImpl = this;
		
    	return c;
  	}
  	/* End : newComponent */
}