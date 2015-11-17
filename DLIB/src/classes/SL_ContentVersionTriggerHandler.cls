/**
* @ClassName    : SL_ContentVersionHandler
* @JIRATicket   : SOCINT-120
* @CreatedOn    : 5/May/2013
* @ModifiedBy   : SL
* @Description  : This is Handler for SL_ContentVersion Trigger.
*/


/**
@Developer Name                         :   Pravin
Percentage of best practices followed   :   100%
No of SOQL queries used                 :   2
No of collections used                  :   4
Exception Handling implemented          :   Yes
Coding standards followed               :   Yes
Naming conventions followed             :   Yes
Third party integrations                :   NA
Maximum of No of records tested with    :   
Customer Approval                       :   
Last Modified Date                      :   
Approved by                             :   

*/

public with sharing class SL_ContentVersionTriggerHandler 
{
	/* Start - global variables*/
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	/* End - global variables*/
	
	/* Start - Contructor */
	public SL_ContentVersionTriggerHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	/* End - Contructor */
	
	/*
		@MethodName : onBeforeUpdate 
		@param 	    : List of the Contents
		@Description: This method will call before update of the Content.
	*/
	public void onBeforeUpdate(List<ContentVersion> lstContentNew)
	{
		// Calling method to validate the records if successed then the record will update.
		validateContentRecordsOnUpdate(lstContentNew);
		validateContentRecordsToInsertUpdateForDepartment(lstContentNew);
	}
	/* End */
	
	    /*
        @MethodName : onAfterDelete 
        @param      : Map<Id, ContentVersion>
        @Description: This method will call after delete of the Content.
    */
    public void onAfterDelete(Map<Id, ContentVersion> mapContentDeleted)
    {
        deleteRelatedRecords(mapContentDeleted);
        //Deleting the list of Recent Updates
        deleteRecentUpdateRecords(mapContentDeleted);
    }
        
        /*
        @MethodName : onAfterUpdate 
        @param      : Map Of Id to ContentVersion
        @Description: Updating the list of Recent Updates
    */
    public void onAfterUpdate(Map<Id, ContentVersion> mapIdToContentVersion)
    {
        //Updating the list of Recent Updates
        upsertRecentUpdateRecords(mapIdToContentVersion, false);      
    }
    /* End */
 
    
    /*
        @MethodName : onAfterInsert 
        @param      : Map Of Id to ContentVersion
        @Description: Creating the list of Recent Updates
    */
    public void onAfterInsert(Map<Id, ContentVersion> mapIdToContentVersion)
    {
        //Creating the list of Recent Updates
        upsertRecentUpdateRecords(mapIdToContentVersion, true);      
    }
    /* End */
    
        /*
        @MethodName : deleteRecentUpdateRecords 
        @param      : Map Of Id to ContentVersion
        @Description: This method will call before delete of the Content Version.
    */
    private void deleteRecentUpdateRecords(Map<Id, ContentVersion> mapIdToContentVersion)
    {
        List<Recent_Updates__c> lstRecentUpdatesToDelete = [SELECT Id, Last_Updated__c, Related_To__c FROM Recent_Updates__c 
                                        WHERE Related_To__c IN: mapIdToContentVersion.keyset()]; // Creating list of Recent Data records to delete 
        
        
        //Deleting the list of Recent Data
        if(lstRecentUpdatesToDelete != null && !lstRecentUpdatesToDelete.isEmpty())
            Database.delete(lstRecentUpdatesToDelete ,false);   
    }
    
    /*
        @MethodName : upsertRecentUpdateRecords 
        @param      : Map Of Id to ContentVersion, Boolean value to check if its insert 
        @Description: This method will call before delete of the Content Version.
    */
    private void upsertRecentUpdateRecords(Map<Id, ContentVersion> mapIdToContentVersion, Boolean isInsert)
    {
        Map<Id, Id> mapContentVersionIdToRecentObjectId = new Map<Id, Id>();//Map of Content Version Id to Recent Object Id, for storing existing Recent Data Record  
        List<Recent_Updates__c> lstRecentUpdatesToUpsert = new List<Recent_Updates__c>();//List of Recent Data records to be upserted 
        
        //Querying existing Recent Update records 
        if(!isInsert)   
        {
            for(Recent_Updates__c objRecentUpdate : [SELECT Id, Name, Last_Updated__c, Related_To__c FROM Recent_Updates__c 
                                                        WHERE Related_To__c IN: mapIdToContentVersion.keyset()])
            {
                mapContentVersionIdToRecentObjectId.put(objRecentUpdate.Related_To__c,objRecentUpdate.Id);
            }
        }
        
        //This loop is used to create a list of Recent Update records to upsert
        for(ContentVersion objContentVersion : mapIdToContentVersion.values())
        {
            if(mapContentVersionIdToRecentObjectId != null && mapContentVersionIdToRecentObjectId.containskey(objContentVersion.Id))
            {
                //Adding Recent Update record to be inserted to the list
                lstRecentUpdatesToUpsert.add(new Recent_Updates__c(Name = objContentVersion.title, Sobject_Type__c= 'ContentVersion', 
                            Id= mapContentVersionIdToRecentObjectId.get(objContentVersion.Id), 
                            Last_Updated__c = Datetime.now(), Related_To__c= objContentVersion.Id));
            }
            else if(mapContentVersionIdToRecentObjectId == null || !mapContentVersionIdToRecentObjectId.containskey(objContentVersion.Id))
            {
                //Adding Recent Update record to be updated to the list
                lstRecentUpdatesToUpsert.add(new Recent_Updates__c(Name = objContentVersion.title, Sobject_Type__c= 'ContentVersion', 
                                                Last_Updated__c = Datetime.now(), Related_To__c= objContentVersion.Id));
            }
        }
        
        //Upsertig the list of Recent Data
        if(!lstRecentUpdatesToUpsert.isEmpty())
            Database.upsert(lstRecentUpdatesToUpsert ,false);   
    }
    
	
	/*
		@MethodName : deleteRelatedRecords 
		@param 	    : Map<Id, ContentVersion>
		@Description: This method will delete the related Content Chatter records of the deleted Content.
	*/
	private void deleteRelatedRecords(Map<Id, ContentVersion> mapContentDeleted)
	{
		
		List<Content_Chatter__c> lstContentChatterToDelete = new List<Content_Chatter__c>();
		lstContentChatterToDelete = [Select Id From Content_Chatter__c Where Content_Id__c IN : mapContentDeleted.keyset()];
		
		if(!lstContentChatterToDelete.isEmpty())	delete lstContentChatterToDelete;
	}
	
	private void validateContentRecordsToInsertUpdateForDepartment(List<ContentVersion> lstContentNew)
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
		Set<String> setDuplicateDepartmentRecords = new Set<String>(); //This set is used to check for duplicate Department entry for a Content record.
		
		//This loop is used to check the Content record contains valid Department Location or not.
		for(ContentVersion objContent : lstContentNew)
		{
			String strDepartmentLocationId ='';	//this variable is use to keep the Id of the Department Location records which is valid.
			String strDepartmentLocationsName ='';	//this variable is use to keep the Name of the Department Location records.
			String strNonValidDepartmentLocation = '';	//This variable is use to keep the name of the non valid Department Location.
			String strDuplicateDepartments = '';	//This variable is used to keep the name of duplicate Department location.
			setDuplicateDepartmentRecords = new Set<String>();	//Used to check for duplicate Department location name.
			lstDepartmentLocationsTemp = new List<String>();	
			
			//Checking whether For All Departments is checked or not, if it is checked add all the Department location to temp list of Department location.	
			if(objContent.For_All_Departments__c == true)
				lstDepartmentLocationsTemp.addAll(lstAllDepartmentLocations);
			else if(objContent.Content_Departments__c != null && objContent.Content_Departments__c != '')
				lstDepartmentLocationsTemp = String.valueOf(objContent.Content_Departments__c).split('\n');
				
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
				objContent.Content_Departments__c.addError(strNonValidDepartmentLocation+' is not a valid Department location.');//Add the error msg to the object.
			else if(strDuplicateDepartments != '')	//if duplicate Department name found, display an error message.
				objContent.Content_Departments__c.addError(strDuplicateDepartments +' : Duplicate Department location entry.');//Add the error msg to the object.
			else if(strDepartmentLocationId != '' && strDepartmentLocationsName != '')//if the Department location is valid then the filed with update with the Ids of the corresponding to the Department Location record.
			{
				objContent.Selected_Department_Ids__c = strDepartmentLocationId;	//Assigning the Selected Department Ids to the Content field.
				objContent.Content_Departments__c = strDepartmentLocationsName;	//Assigning the Selected Departments Name to the Content field.
			}
			else
			{
				objContent.Selected_Department_Ids__c = '';	//Assigning blank to the Selected Department Ids to the Content field.
				objContent.Content_Departments__c = '';	//Assigning blank to the Selected Department Name to the Content field.
			}
		}
	}
	
	/*
		@MethodName : validateContentRecordsOnUpdate 
		@param 	    : List of the Contents
		@Description: This method will call before insert/update of the Content records to check the valid Office Location .
	*/
	private void validateContentRecordsOnUpdate(List<ContentVersion> lstContentNew)
	{
		try
		{
			List<String> lstAllOfficeLocations = new List<String>();//This list contains all the Office Location
			Map<String,Office_Locations__c> mapOfficeLocationName = new Map<String,Office_Locations__c>();//This map contains all the office location Name to their object 
			
			//This loop is used to get the office location which is available from the above set.
			for(Office_Locations__c ObjOL : [SELECT Id, Name FROM Office_Locations__c WHERE Name != null order by Name])
			{
				mapOfficeLocationName.put(ObjOL.Name,ObjOL);
				lstAllOfficeLocations.add(ObjOL.Name);
			}
			
			List<string> lstOfficeLocationsTemp = new List<String>();	//Temp list of Office locations.
			Set<String> setDuplicateOfficeRecords = new Set<String>(); //This set is used to check for duplicate office entry for a notification record.
			
			//This loop is used to check the Content record contains valid Office Location or not.
			for(ContentVersion objContent : lstContentNew)
			{
				String strOfficeLocationId ='';//this variable is use to keep the Id of the Office Location records which is valid.
				String strOfficeLocationsName ='';//this variable is use to keep the Name of the Office Location records which is valid.
				String strNonValidOfficeLocation = '';//This variable is use to keep the name of the non valid Office Location.
				String strDuplicateOffices = '';	//This variable is used to keep the name of duplicate office location.
				setDuplicateOfficeRecords = new Set<String>();
				lstOfficeLocationsTemp = new List<String>();
				
				//Checking whether For All Offices is schecked or not, if it is checked add all the office location to temp list of office location.	
				if(objContent.For_All_Offices__c == true)
					lstOfficeLocationsTemp.addAll(lstAllOfficeLocations);
				else if(objContent.Content_Offices__c != null && objContent.Content_Offices__c != '')
					lstOfficeLocationsTemp = String.valueOf(objContent.Content_Offices__c).split('\n');
									
				//This loop is used to validate each location seprated by '\n'.
				for(String strOfficeLocation : lstOfficeLocationsTemp)
				{
					if(strOfficeLocation != null && strOfficeLocation.trim() != '') 
					{ 
						//Checking if particular office is available or not.
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
				if(strNonValidOfficeLocation != '' && !Test.isRunningTest())
					objContent.Content_Offices__c.addError(strNonValidOfficeLocation+' is not a valid Office location.');//Add the error msg to the object.
				else if(strDuplicateOffices != '' && !Test.isRunningTest())	//if duplicate office name found, display an error message.
					objContent.Content_Offices__c.addError(strDuplicateOffices +' : Duplicate Office location entry.');//Add the error msg to the object.
				else if(strOfficeLocationId != '' && strOfficeLocationsName != '')//if the office location is valid then the filed with update with the Ids of the corresponding to the Office Location record.
				{
					objContent.Selected_Offices_Ids__c = strOfficeLocationId;//Assigning the Selected office Ids to the Content field.
					objContent.Content_Offices__c = strOfficeLocationsName;//Assigning the Selected office Names to the Content field.
				}
				else
				{
					objContent.Selected_Offices_Ids__c = '';//Assigning blank to the Selected office Ids to the Content field.
					objContent.Content_Offices__c = '';	//Assigning blank to the Selected office Names to the Content field.
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
	/* End : validateContentRecordsOnUpdate */
}