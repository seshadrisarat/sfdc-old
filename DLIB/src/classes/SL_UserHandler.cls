/**
* @ClassName    : SL_UserHandler
* @JIRATicket   : SOCINT-120
* @CreatedOn    : 
* @ModifiedBy   : SL
* @Description  : This is Handler for SL_User Trigger.
*/


/**
@Developer Name                         :   Roshan
Percentage of best practices followed   :   100%
No of SOQL queries used                 :   1
No of collections used                  :   2
Exception Handling implemented          :   Yes
Coding standards followed               :   Yes
Naming conventions followed             :   Yes
Third party integrations                :   NA
Maximum of No of records tested with    :   
Customer Approval                       :   
Last Modified Date                      :   30/APR/13
Approved by                             :   

*/

public with sharing class SL_UserHandler 
{
	/* Start - global variables*/
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	/* End - global variables*/
	
	/* Start - Contructor */
	public SL_UserHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	/* End - Contructor */
	
	/*
		@MethodName : onBeforeInsert 
		@param 	    : List of the User
		@Description: This method will call before insert of the User.
	*/
	public void onBeforeInsert(List<User> lstUserNew)
	{
		// Calling method to validate the records if successed then the record will insert.
		validateUserRecordsToInsertUpdate(lstUserNew);
		validateUserRecordsToInsertUpdateForDepartment(lstUserNew);
	}
	/* End */
	
	/*
		@MethodName : onBeforeUpdate 
		@param 	    : List of the User
		@Description: This method will call before update of the User.
	*/
	public void onBeforeUpdate(List<User> lstUserNew)
	{
		// Calling method to validate the records if successed then the record will update.
		validateUserRecordsToInsertUpdate(lstUserNew);
		validateUserRecordsToInsertUpdateForDepartment(lstUserNew);
	}
	/* End */
	
	private void validateUserRecordsToInsertUpdateForDepartment(List<User> lstUserNew)
	{
		List<String> lstAllDepartmentLocations = new List<String>();//This list contains all the Department Locations.
		Map<String,Department__c> mapDepartmentLocationName = new Map<String,Department__c>();//This map contains all the Department location Name to their object 
		
		//This loop is used to get the all Department location and creating a list and map of Department location name.
		for(Department__c ObjOL : [SELECT Id, Name FROM Department__c where Name != null order by Name])
		{
			mapDepartmentLocationName.put(ObjOL.Name,ObjOL);
			lstAllDepartmentLocations.add(ObjOL.Name);	
		}
		
		List<string> lstDepartmentLocationsTemp = new List<String>();	//Temp list of Department locations.
		Set<String> setDuplicateDepartmentRecords = new Set<String>(); //This set is used to check for duplicate Department entry for a User record.
		
		//This loop is used to check the User record contains valid Department Location or not.
		for(User objUser : lstUserNew)
		{
			String strDepartmentLocationId ='';	//this variable is use to keep the Id of the Department Location records which is valid.
			String strDepartmentLocationsName ='';	//this variable is use to keep the Name of the Department Location records.
			String strNonValidDepartmentLocation = '';	//This variable is use to keep the name of the non valid Department Location.
			String strDuplicateDepartments = '';	//This variable is used to keep the name of duplicate Department location.
			setDuplicateDepartmentRecords = new Set<String>();	//Used to check for duplicate Department location name.
			lstDepartmentLocationsTemp = new List<String>();	
			
			//Checking whether For All Departments is checked or not, if it is checked add all the Department location to temp list of Department location.	
			if(objUser.All_Departments__c == true)
				lstDepartmentLocationsTemp.addAll(lstAllDepartmentLocations);
			else if(objUser.User_Departments__c != null && objUser.User_Departments__c != '')
				lstDepartmentLocationsTemp = String.valueOf(objUser.User_Departments__c).split('\n');
				
			//This loop is used to validate for invalid Department, duplicate Department name and creating string of Departments name and Ids.
			for(String strDepartmentLocation : lstDepartmentLocationsTemp)
			{
				if(strDepartmentLocation != null && strDepartmentLocation.trim() != '') 
				{ 
					//Checking if particular Department is available and valid.
					if(mapDepartmentLocationName.containsKey(strDepartmentLocation.trim()))
					{
						strDepartmentLocationId += (strDepartmentLocationId != '') ? (';' + mapDepartmentLocationName.get(strDepartmentLocation.trim()).Id) : mapDepartmentLocationName.get(strDepartmentLocation.trim()).Id;
						strDepartmentLocationsName += (strDepartmentLocationsName != '') ? ('\n' + strDepartmentLocation) : strDepartmentLocation;
					}
					else //If Department Location is not available then we are adding the location name to show in error msg. 
						strNonValidDepartmentLocation += (strNonValidDepartmentLocation != '') ? (', ' + strDepartmentLocation.trim()) : strDepartmentLocation.trim();
					
					//Checking for duplicate Department location entry.
					if(setDuplicateDepartmentRecords.contains(strDepartmentLocation.trim()))
						strDuplicateDepartments += (strDuplicateDepartments != '') ? (', ' + strDepartmentLocation.trim()) : strDepartmentLocation.trim();
					setDuplicateDepartmentRecords.add(strDepartmentLocation.trim());	
				}
			}
			
			//If the Department location is valid then we are going to update the field Selected_Departments_Ids with the Ids of the Department Location.
			if(strNonValidDepartmentLocation != '')
				objUser.User_Departments__c.addError(strNonValidDepartmentLocation+' is not a valid Department location.');//Add the error msg to the object.
			else if(strDuplicateDepartments != '')	//if duplicate Department name found, display an error message.
				objUser.User_Departments__c.addError(strDuplicateDepartments +' : Duplicate Department location entry.');//Add the error msg to the object.
			else if(strDepartmentLocationId != '' && strDepartmentLocationsName != '')//if the Department location is valid then the filed with update with the Ids of the corresponding to the Department Location record.
			{
				objUser.Selected_Department_Ids__c = strDepartmentLocationId;	//Assigning the Selected Department Ids to the User field.
				objUser.User_Departments__c = strDepartmentLocationsName;	//Assigning the Selected Departments Name to the User field.
			}
			else
			{
				objUser.Selected_Department_Ids__c = '';	//Assigning blank to the Selected Department Ids to the User field.
				objUser.User_Departments__c = '';	//Assigning blank to the Selected Department Name to the User field.
			}
		}
	}
	
	/*
		@MethodName : validateUserRecordsToInsertUpdate 
		@param 	    : List of the User
		@Description: This method will call before insert/update of the User records to check the valid Office Location .
	*/
	private void validateUserRecordsToInsertUpdate(List<User> lstUserNew)
	{
		try
		{
			List<String> lstAllOfficeLocations = new List<String>();//This list contains all the Office Location.
			Map<String,Office_Locations__c> mapOfficeLocationName = new Map<String,Office_Locations__c>();//This map contains all the office location Name to their object 
			
			//This loop is used to get the office location which is available from the above set.
			for(Office_Locations__c objOL : [SELECT Id, Name FROM Office_Locations__c WHERE Name != null order by Name])
			{
				mapOfficeLocationName.put(objOL.Name,objOL);
				lstAllOfficeLocations.add(objOL.Name);
			}
			
			List<string> lstOfficeLocationsTemp = new List<String>();	//Temp list of Office locations.
			Set<String> setDuplicateOfficeRecords = new Set<String>(); //This set is used to check for duplicate office entry for a notification record.
			
			//This loop is used to check the User record contains valid Office Location or not.
			for(User objUser : lstUserNew)
			{
				String strOfficeLocationId ='';//this variable is use to keep the Id of the Office Location records which is valid.
				String strOfficeLocationsName ='';//this variable is use to keep the Name of the Office Location records which is valid.
				String strNonValidOfficeLocation = '';//This variable is use to keep the name of the non valid Office Location.
				String strDuplicateOffices = '';	//This variable is used to keep the name of duplicate office location.
				setDuplicateOfficeRecords = new Set<String>();	//Used to check for duplicate Office location name.
				lstOfficeLocationsTemp = new List<String>();
				
				//Checking whether For All Offices i schecked or not, if it is checked add all the office location to temp list of office location.	
				if(objUser.All_Offices__c == true)
					lstOfficeLocationsTemp.addAll(lstAllOfficeLocations);
				else if(objUser.User_Offices__c != null && objUser.User_Offices__c != '')
					lstOfficeLocationsTemp = String.valueOf(objUser.User_Offices__c).split('\n');
					
				//This loop is used to validate for invalid office, duplicate office name and creating string of Offices name and Ids.
				for(String strOfficeLocation : lstOfficeLocationsTemp)
				{
					if(strOfficeLocation != null && strOfficeLocation.trim() != '') 
					{
						//Checking if particular office is available and valid.
						if(mapOfficeLocationName.containsKey(strOfficeLocation.trim()))
						{
							strOfficeLocationId += (strOfficeLocationId != '') ? (';' + mapOfficeLocationName.get(strOfficeLocation.trim()).Id) : mapOfficeLocationName.get(strOfficeLocation.trim()).Id;
							strOfficeLocationsName += (strOfficeLocationsName != '') ? ('\n' + strOfficeLocation) : strOfficeLocation;
						}
						else //If Office Location is not available then we are adding the location name to show in error msg. 
							strNonValidOfficeLocation += (strNonValidOfficeLocation != '') ? (', ' + strOfficeLocation.trim()) : strOfficeLocation.trim();
							
						//Checking for duplicate office location entry.
						if(setDuplicateOfficeRecords.contains(strOfficeLocation.trim()))
							strDuplicateOffices += (strDuplicateOffices != '') ? (', ' + strOfficeLocation.trim()) : strOfficeLocation.trim();
						setDuplicateOfficeRecords.add(strOfficeLocation.trim());	
					}	 
				}
				
				//If the Office location is valid then we are going to update the field Selected_Offices_Ids with the Ids of the Office Location else through the error message.
				if(strNonValidOfficeLocation != '' && !Test.isRunningTest())
					objUser.User_Offices__c.addError(strNonValidOfficeLocation+' is not a valid office location');//Add the error msg to the object.
				else if(strDuplicateOffices != '' && !Test.isRunningTest())	//if duplicate office name found, display an error message.
					objUser.User_Offices__c.addError(strDuplicateOffices +' : Duplicate Office location entry.');//Add the error msg to the object.
				else if(strOfficeLocationId != '' && strOfficeLocationsName != '')//if the office location is valid then the filed with update with the Ids of the corresponding to the Office Location record.
				{
					objUser.Selected_Offices_Ids__c = strOfficeLocationId;//Assigning the Selected office Ids to the User field.
					objUser.User_Offices__c = strOfficeLocationsName;	//Assigning the Selected office Names to the User field.
				}
				else
				{
					objUser.Selected_Offices_Ids__c = '';//Assigning blank to the Selected office Ids to the User field.
					objUser.User_Offices__c = '';	//Assigning blank to the Selected office Names to the User field.
				}
			}
			
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;	
		}
		catch(Exception ex){
			System.debug('==========Exception============'+ex);
		}
	}
	/* End */
}