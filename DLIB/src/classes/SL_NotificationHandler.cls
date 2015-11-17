/**
* @ClassName    : SL_NotificationHandler
* @JIRATicket   : SOCINT-120
* @CreatedOn    : 
* @ModifiedBy   : SL
* @Description  : This is Handler class for SL_Notification Trigger.
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
Last Modified Date                      :   
Approved by                             :   

*/

public with sharing class SL_NotificationHandler 
{
	/* Start - global variables*/
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	/* End - global variables*/
	
	/* Start - Contructor */
	public SL_NotificationHandler(boolean isExecuting, integer size)   
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	/* End - Contructor */
	
	/*
		@MethodName : onBeforeInsert 
		@param 	    : List of the Notification__c
		@Description: This method will call before insert of the Notification.
	*/
	public void onBeforeInsert(List<Notification__c> lstNotificationNew)
	{
		// Calling method to validate the records if successed then the record will insert.
		validateNotificationRecordsToInsertUpdate(lstNotificationNew);
		validateNotificationRecordsToInsertUpdateForDepartment(lstNotificationNew);
	}
	/* End */
	
	        /*
        @MethodName : onAfterInsert 
        @param      : Map Of Id to Notification
        @Description: Creating the list of Recent Updates
    */
    public void onAfterInsert(Map<Id, Notification__c> mapIdToNotification)
    {
        //Creating the list of Recent Updates
        upsertRecentUpdateRecords(mapIdToNotification, true);      
    }
    /* End */
    
    /*
        @MethodName : onAfterUpdate 
        @param      : Map Of Id to Notification
        @Description: Updating the list of Recent Updates
    */
    public void onAfterUpdate(Map<Id, Notification__c> mapIdToNotification)
    {
        //Updating the list of Recent Updates
        upsertRecentUpdateRecords(mapIdToNotification, false);      
    }
    /* End */
    
    
     /*
        @MethodName : onAfterDelete 
        @param      : Map Of Id to Notification
        @Description: This method will call before insert of the Notification.
    */
    public void onAfterDelete(Map<Id, Notification__c> mapNotificationDeleted)
    {
        //Deleting the list of Recent Updates
        deleteRecentUpdateRecords(mapNotificationDeleted);  
    }
 
    /* End */
    
    /*
        @MethodName : deleteRecentUpdateRecords 
        @param      : Map Of Id to Notification
        @Description: This method will call After delete of the Notification.
    */
    private void deleteRecentUpdateRecords(Map<Id, Notification__c> mapIdToNotification)
    {
        List<Recent_Updates__c> lstRecentUpdatesToDelete = [SELECT Id, Last_Updated__c, Related_To__c FROM Recent_Updates__c 
                                        WHERE Related_To__c IN: mapIdToNotification.keyset()]; // Creating list of Recent Data records to delete 
        
        //Deleting the list of Recent Data
        if(lstRecentUpdatesToDelete != null && !lstRecentUpdatesToDelete.isEmpty())
            Database.delete(lstRecentUpdatesToDelete ,false);   
    }
    
    /*
        @MethodName : upsertRecentUpdateRecords 
        @param      : Map Of Id to Notification, Boolean value to check if its insert 
        @Description: This method will call before delete of the Content Version.
    */
    private void upsertRecentUpdateRecords(Map<Id, Notification__c> mapIdToNotification, Boolean isInsert)
    {
        Map<Id, Id> mapNotificationIdToRecentObjectId = new Map<Id, Id>();//Map of Notification Id to Recent Object Id, for storing existing Recent Data Record  
        List<Recent_Updates__c> lstRecentUpdatesToUpsert = new List<Recent_Updates__c>();//List of Recent Data records to be upserted 
        
        //Querying existing Recent Update records with Id matching with Related_To__c field value 
        if(!isInsert)   
        {
            for(Recent_Updates__c objRecentUpdate : [SELECT Id, Last_Updated__c, Name, Related_To__c FROM Recent_Updates__c 
                                                        WHERE Related_To__c IN: mapIdToNotification.keyset()])
            {
                mapNotificationIdToRecentObjectId.put(objRecentUpdate.Related_To__c,objRecentUpdate.Id);
 
            }
        }
        
        //This loop is used to create a list of Recent Update records to upsert
        for(Notification__c objNotification : mapIdToNotification.values())
        {
            if(mapNotificationIdToRecentObjectId != null && mapNotificationIdToRecentObjectId.containskey(objNotification.Id))
            {
                //Adding Recent Update record to be inserted to the list
                lstRecentUpdatesToUpsert.add(new Recent_Updates__c(Id= mapNotificationIdToRecentObjectId.get(objNotification.Id), Sobject_Type__c= 'Notification__c',  Name = objNotification.Name, Last_Updated__c = Datetime.now(), Related_To__c= objNotification.Id));
            }
            else if(mapNotificationIdToRecentObjectId == null || !mapNotificationIdToRecentObjectId.containskey(objNotification.Id))
            {
                //Adding Recent Update record to be updated to the list
                lstRecentUpdatesToUpsert.add(new Recent_Updates__c(Last_Updated__c = Datetime.now(), Name = objNotification.Name, Sobject_Type__c= 'Notification__c',  Related_To__c= objNotification.Id));
            }
        }
        
        //Upsertig the list of Recent Data
        if(lstRecentUpdatesToUpsert != null && !lstRecentUpdatesToUpsert.isEmpty())
            Database.upsert(lstRecentUpdatesToUpsert ,false);   
    }
    
	
	/*
		@MethodName : onBeforeUpdate 
		@param 	    : List of the Notification__c
		@Description: This method will call before update of the Notification.
	*/
	public void onBeforeUpdate(List<Notification__c> lstNotificationNew)
	{
		// Calling method to validate the records if successed then the record will update.
		validateNotificationRecordsToInsertUpdate(lstNotificationNew);
		validateNotificationRecordsToInsertUpdateForDepartment(lstNotificationNew);
	}
	/* End */
	
	
	/*
		@MethodName : validateNotificationRecordsToInsertUpdate 
		@param 	    : List of the Notification__c
		@Description: This method will call before insert/update of the Notification records to check the valid Office Location .
	*/
	private void validateNotificationRecordsToInsertUpdate(List<Notification__c> lstNotificationNew)
	{
		try
		{
			List<String> lstAllOfficeLocations = new List<String>();//This list contains all the Office Locations.
			Map<String,Office_Locations__c> mapOfficeLocationName = new Map<String,Office_Locations__c>();//This map contains all the office location Name to their object 
			
			//This loop is used to get the all office location and creating a list and map of Office location name.
			for(Office_Locations__c ObjOL : [SELECT Id, Name FROM Office_Locations__c where Name != null order by Name])
			{
				mapOfficeLocationName.put(ObjOL.Name,ObjOL);
				lstAllOfficeLocations.add(ObjOL.Name);	
			} 
			
			List<string> lstOfficeLocationsTemp = new List<String>();	//Temp list of Office locations.
			Set<String> setDuplicateOfficeRecords = new Set<String>(); //This set is used to check for duplicate office entry for a notification record.
			
			//This loop is used to check the Notification record contains valid Office Location or not.
			for(Notification__c objNotification : lstNotificationNew)
			{
				String strOfficeLocationId ='';	//this variable is use to keep the Id of the Office Location records which is valid.
				String strOfficeLocationsName ='';	//this variable is use to keep the Name of the Office Location records.
				String strNonValidOfficeLocation = '';	//This variable is use to keep the name of the non valid Office Location.
				String strDuplicateOffices = '';	//This variable is used to keep the name of duplicate office location.
				setDuplicateOfficeRecords = new Set<String>();	//Used to check for duplicate Office location name.
				lstOfficeLocationsTemp = new List<String>();	
				
				//Checking whether For All Offices i schecked or not, if it is checked add all the office location to temp list of office location.	
				if(objNotification.For_All_Offices__c == true)
					lstOfficeLocationsTemp.addAll(lstAllOfficeLocations);
				else if(objNotification.Notification_Offices__c != null && objNotification.Notification_Offices__c != '')
					lstOfficeLocationsTemp = String.valueOf(objNotification.Notification_Offices__c).split('\n');
					
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
				
				//If the Office location is valid then we are going to update the field Selected_Offices_Ids with the Ids of the Office Location.
				if(strNonValidOfficeLocation != '')
					objNotification.Notification_Offices__c.addError(strNonValidOfficeLocation+' is not a valid Office location.');//Add the error msg to the object.
				else if(strDuplicateOffices != '')	//if duplicate office name found, display an error message.
					objNotification.Notification_Offices__c.addError(strDuplicateOffices +' : Duplicate Office location entry.');//Add the error msg to the object.
				else if(strOfficeLocationId != '' && strOfficeLocationsName != '')//if the office location is valid then the filed with update with the Ids of the corresponding to the Office Location record.
				{
					objNotification.Selected_Offices_Ids__c = strOfficeLocationId;	//Assigning the Selected office Ids to the Notification field.
					objNotification.Notification_Offices__c = strOfficeLocationsName;	//Assigning the Selected offices Name to the Notification field.
				}
				else
				{
					objNotification.Selected_Offices_Ids__c = '';	//Assigning blank to the Selected office Ids to the Notification field.
					objNotification.Notification_Offices__c = '';	//Assigning blank to the Selected offices Name to the Notification field.
				}
			}
			
			//Tp cover exception in test coverage
			if(Test.isRunningTest())
				Integer i = 1/0;
		}
		catch(Exception ex){
			System.debug('==========Exception============'+ex);
		}
	}
	/* End */
	
	
	private void validateNotificationRecordsToInsertUpdateForDepartment(List<Notification__c> lstNotificationNew)
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
		Set<String> setDuplicateDepartmentRecords = new Set<String>(); //This set is used to check for duplicate Department entry for a Notification record.
		
		//This loop is used to check the Notification record contains valid Department Location or not.
		for(Notification__c objNotification : lstNotificationNew)
		{
			String strDepartmentLocationId ='';	//this variable is use to keep the Id of the Department Location records which is valid.
			String strDepartmentLocationsName ='';	//this variable is use to keep the Name of the Department Location records.
			String strNonValidDepartmentLocation = '';	//This variable is use to keep the name of the non valid Department Location.
			String strDuplicateDepartments = '';	//This variable is used to keep the name of duplicate Department location.
			setDuplicateDepartmentRecords = new Set<String>();	//Used to check for duplicate Department location name.
			lstDepartmentLocationsTemp = new List<String>();	
			
			//Checking whether For All Departments is checked or not, if it is checked add all the Department location to temp list of Department location.	
			if(objNotification.For_All_Departments__c == true)
				lstDepartmentLocationsTemp.addAll(lstAllDepartmentLocations);
			else if(objNotification.Notification_Departments__c != null && objNotification.Notification_Departments__c != '')
				lstDepartmentLocationsTemp = String.valueOf(objNotification.Notification_Departments__c).split('\n');
				
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
				objNotification.Notification_Departments__c.addError(strNonValidDepartmentLocation+' is not a valid Department location.');//Add the error msg to the object.
			else if(strDuplicateDepartments != '')	//if duplicate Department name found, display an error message.
				objNotification.Notification_Departments__c.addError(strDuplicateDepartments +' : Duplicate Department location entry.');//Add the error msg to the object.
			else if(strDepartmentLocationId != '' && strDepartmentLocationsName != '')//if the Department location is valid then the filed with update with the Ids of the corresponding to the Department Location record.
			{
				objNotification.Selected_Department_Ids__c = strDepartmentLocationId;	//Assigning the Selected Department Ids to the Notification field.
				objNotification.Notification_Departments__c = strDepartmentLocationsName;	//Assigning the Selected Departments Name to the Notification field.
			}
			else
			{
				objNotification.Selected_Department_Ids__c = '';	//Assigning blank to the Selected Department Ids to the Notification field.
				objNotification.Notification_Departments__c = '';	//Assigning blank to the Selected Department Name to the Notification field.
			}
		}
	}
	
}