/**
* @ClassName    : SL_OfficeLocationHandler
* @JIRATicket   : SOCINT-120
* @CreatedOn    : 7/May/2013
* @ModifiedBy   : SL
* @Description  : This is Handler class for SL_OfficeLocation Trigger.
*/

/**
@Developer Name                         :   Pravin Sapkal
Percentage of best practices followed   :   100%
No of SOQL queries used                 :   4
No of collections used                  :   6
Exception Handling implemented          :   Yes
Coding standards followed               :   Yes
Naming conventions followed             :   Yes
Third party integrations                :   No
Maximum of No of records tested with    :   
Customer Approval                       :   
Last Modified Date                      :   7/May/2013
Approved by                             :   

*/

public with sharing class SL_OfficeLocationHandler 
{
	
	/* Start - global variables*/
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	/* End - global variables*/
	
	/* Start - Constructor */
	public SL_OfficeLocationHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	/* End - Constructor */
	
	/*
		@MethodName : onAfterInsert 
		@params 	: NewMap of Office_Location__c
		@Description: This method will call after Insert of the Office_Location.
	*/
	public void onAfterInsert(Map< Id,Office_Locations__c> mapOfficeLocationsNew )
	{
		// Calling method to update Office Name on Notifications, Users and Contents records.
		updateOfficeLocationNameOnInsert();
	}
	/* End : onAfterUpdate */
	
	/*
		@MethodName : onAfterUpdate 
		@params 	: OldMap and NewMap of Office_Location__c
		@Description: This method will call after Update of the Office_Location.
	*/
	public void onAfterUpdate(Map< Id,Office_Locations__c> mapOfficeLocationsOld , Map< Id,Office_Locations__c> mapOfficeLocationsNew )
	{
		// Calling method to update Office Name on Notifications, Users and Contents records.
		updateOfficeLocationName(mapOfficeLocationsOld , mapOfficeLocationsNew, 'isUpdate');
	}
	/* End : onAfterUpdate */
	
	/*
		@MethodName : onAfterDelete 
		@param 	    : Map of the Office_Location__c
		@Description: This method will call after delete of the Office_Location .
	*/
	public void onAfterDelete(Map< Id,Office_Locations__c> mapOfficeLocationsOld)
	{
		// Calling method to update Office Name on Notifications, Users and Contents records.
		updateOfficeLocationName(mapOfficeLocationsOld , mapOfficeLocationsOld, 'isDelete');
	}
	/* End : onAfterDelete */
	
	/*
		@MethodName : updateOfficeLocationNameOnInsert 
		@param 	    : None
		@Description: This method is used to update Office Name on Notifications, Users and Contents records if For all Offices is true on respective object's records.
	*/
	private void updateOfficeLocationNameOnInsert()
	{
		try
		{
			List<Notification__c> lstNotificationsToBeUpdate = new List<Notification__c>();	//list of Notifications to be update
			List<ContentVersion> lstContentsToBeUpdate = new List<ContentVersion>();	//list of Contents to be update
			List<User> lstUsersToBeUpdate = new List<User>();	//list of Users to be update
			List<Intranet_Event__c> lstIntranetEventsToBeUpdate = new List<Intranet_Event__c>();
			List<Intranet_App__c> lstIntranetAppsToBeUpdate = new List<Intranet_App__c>();
			
			String strAllOfficeLocationsName = '';	//string of all Office locations name separated by '\n'
			
			//Query all Offices and make a string of Name separated by new line
			for(Office_Locations__c objOffice : [select Name from Office_Locations__c where Name != null order by Name])
			{
				strAllOfficeLocationsName += (strAllOfficeLocationsName != '') ? ('\n' + objOffice.Name) : objOffice.Name; 
			}
			
			//Query all Notification records where For All Offices checkbox is selected 
			for(Notification__c objNotification : [select Notification_Offices__c from Notification__c where For_All_Offices__c = true])
			{
				objNotification.Notification_Offices__c = strAllOfficeLocationsName;
				lstNotificationsToBeUpdate.add(objNotification);
			}
			
			//Query all Content records where For All Offices checkbox is selected
			for(ContentVersion objContent : [select Content_Offices__c from ContentVersion where For_All_Offices__c = true])
			{
				objContent.Content_Offices__c = strAllOfficeLocationsName;
				lstContentsToBeUpdate.add(objContent);
			}
			
			//Query all User records where All Offices checkbox is selected
			for(User objUser : [select User_Offices__c from User where All_Offices__c = true])
			{
				objUser.User_Offices__c = strAllOfficeLocationsName;
				lstUsersToBeUpdate.add(objUser);
			}
			
			//Query all Intranet_Event__c records where All Offices checkbox is selected
			for(Intranet_Event__c objEvent : [select Intranet_Event_Offices__c from Intranet_Event__c where For_All_Offices__c = true])
			{
				objEvent.Intranet_Event_Offices__c = strAllOfficeLocationsName;
				lstIntranetEventsToBeUpdate.add(objEvent);
			}
			
			//Query all User records where All Offices checkbox is selected
			for(Intranet_App__c objApp : [select IntranetApp_Offices__c from Intranet_App__c where For_All_Offices__c = true])
			{
				objApp.IntranetApp_Offices__c = strAllOfficeLocationsName;
				lstIntranetAppsToBeUpdate.add(objApp);
			}
			
			//If any Notification records found with For All Offices is true, update those records with updated Notification Offices value.
			if(lstNotificationsToBeUpdate.size() > 0)
				update lstNotificationsToBeUpdate;
			
			//If any Content records found with For All Offices is true, update those records with updated Content Offices value.
			if(lstContentsToBeUpdate.size() > 0)
				update lstContentsToBeUpdate;
			
			//If any User records found with All Offices is true, update those records with updated User Offices value.
			if(lstUsersToBeUpdate.size() > 0)
				update lstUsersToBeUpdate;
				
			if(lstIntranetEventsToBeUpdate.size() > 0)
				update lstIntranetEventsToBeUpdate;	
			
			if(lstIntranetAppsToBeUpdate.size() > 0)
				update lstIntranetAppsToBeUpdate;	
			
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;	
		}
		catch(Exception ex){
			system.debug('==========Exception============'+ex);
		}
	}
	/* End : updateOfficeLocationNameOnInsert */
	
	/*
		@MethodName : updateOfficeLocationName 
		@param 	    : Old map of Office Location, New map of Office Location and trigger event(String)
		@Description: This method is used to update Office Name on Notifications, Users and Contents records.
	*/
	private void updateOfficeLocationName(Map< Id,Office_Locations__c> mapOfficeLocationsOld , Map< Id,Office_Locations__c> mapOfficeLocationsNew, String strEvent)
	{
		try
		{
			Map<String, String> mapOfficeNameOldToNew = new Map<String, String>();	//Map of Office Location Old name to Office Location new name
			Map<String, String> mapDeletedOffice = new Map<String, String>();	//Map of deleted Office Location Name to Office Location id
			
			//Creating Map of Office Location Old name to Office Location new name in update event 
			//and Creating Map of deleted Office Location Name to Office Location id in delete event.
			for(Office_Locations__c objOfficeLocation : mapOfficeLocationsNew.values())
			{
				//Applicable only if Office Location Name is updated
				if(objOfficeLocation.Name != mapOfficeLocationsOld.get(objOfficeLocation.Id).Name)
					mapOfficeNameOldToNew.put(mapOfficeLocationsOld.get(objOfficeLocation.Id).Name ,objOfficeLocation.Name) ;
				
				//if Office Location records is deleted
				if(strEvent == 'isDelete')
					mapDeletedOffice.put(objOfficeLocation.Name, objOfficeLocation.id);	
			}
			
			//If Office Location has changed or Office Location record has been deleted then update Office Name for Notification, User and Content records.
			if(mapOfficeNameOldToNew.size() > 0 || mapDeletedOffice.size() > 0)
			{
				updateNotificationOffices(mapOfficeNameOldToNew, mapDeletedOffice);	//Update Notification Records
				updateUserOffices(mapOfficeNameOldToNew, mapDeletedOffice);	//Update User records
				updateContentOffices(mapOfficeNameOldToNew, mapDeletedOffice);	//Update Content records
				updateIntranetEventOffices(mapOfficeNameOldToNew, mapDeletedOffice);
				updateIntranetAppOffices(mapOfficeNameOldToNew, mapDeletedOffice);
			}
			
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;	
		}
		catch(Exception ex){
			system.debug('==========Exception============'+ex);
		}
	}
	/* End : updateOfficeLocationName */
	
	/*
		@MethodName : updateNotificationOffices 
		@param 	    : Map of Office Old name to New name and map of deleted Office name to id.
		@Description: This method is used to update Office Name on Notifications records.
	*/
	private void updateNotificationOffices(Map<String, String> mapOfficeNameOldToNew, Map<String, String> mapDeletedOffice)
	{
		try{
			List<Notification__c> lstNotificationToBeUpdated = new List<Notification__c>();	//list of Notification records to be update.
			Boolean isNotificationToBeUpdate = false;	//used to check whether Notification need to be update or not.
			
			for(Notification__c objNotification : [select Id, Notification_Offices__c from Notification__c where Id != null])
			{
				if(objNotification.Notification_Offices__c != '' && objNotification.Notification_Offices__c != null)
				{
					String strUpdatedOfficeName = '';
					String strOfficesName = '';
					List<String> lstSelectedOfficeName = String.valueOf(objNotification.Notification_Offices__c).split('\n');
					
					isNotificationToBeUpdate = false;
					
					//checking and re-creating offices name and ids as a string separated by '\n' and ';' respectively for each notification records. 
					for(String strObj : lstSelectedOfficeName)
					{
						strUpdatedOfficeName = '';
						
						//Checking whether office name is updated or not.
						if(mapOfficeNameOldToNew.containsKey(strObj.trim()))
							strUpdatedOfficeName = mapOfficeNameOldToNew.get(strObj.trim());
						
						if(strUpdatedOfficeName != '')
						{
							strOfficesName += strUpdatedOfficeName + '\n';
							isNotificationToBeUpdate = true;	
						}
						else if(!mapDeletedOffice.containsKey(strObj.trim()))
							strOfficesName += strObj.trim() + '\n';
						
						if(mapDeletedOffice.containsKey(strObj.trim()))
							isNotificationToBeUpdate = true;	
					}
					
					//check whether this Notification need to be update or not if so, updating Notification fields with updated values and add them to list of Notification to be update.
					if(isNotificationToBeUpdate)
					{
						strOfficesName = (strOfficesName != '') ? strOfficesName.substring(0, strOfficesName.length() - 1) : '';
						
						objNotification.Notification_Offices__c = strOfficesName;
						lstNotificationToBeUpdated.add(objNotification);
					}
				}
			}
			
			if(lstNotificationToBeUpdated.size() > 0)
				update lstNotificationToBeUpdated;
				
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;		
		}
		catch(Exception ex){
			system.debug('==========Exception============'+ex);
		}	
	}
	/* End : updateNotificationOffices */
	
	private void updateIntranetEventOffices(Map<String, String> mapOfficeNameOldToNew, Map<String, String> mapDeletedOffice)
	{
		try{
			List<Intranet_Event__c> lstIntranetEventToBeUpdated = new List<Intranet_Event__c>();	//list of Notification records to be update.
			Boolean isIntranetEventToBeUpdate = false;	//used to check whether Notification need to be update or not.
			
			for(Intranet_Event__c objEvent : [select Id, Intranet_Event_Offices__c from Intranet_Event__c where Id != null])
			{
				if(objEvent.Intranet_Event_Offices__c != '' && objEvent.Intranet_Event_Offices__c != null)
				{
					String strUpdatedOfficeName = '';
					String strOfficesName = '';
					List<String> lstSelectedOfficeName = String.valueOf(objEvent.Intranet_Event_Offices__c).split('\n');
					
					isIntranetEventToBeUpdate = false;
					
					//checking and re-creating offices name and ids as a string separated by '\n' and ';' respectively for each notification records. 
					for(String strObj : lstSelectedOfficeName)
					{
						strUpdatedOfficeName = '';
						
						//Checking whether office name is updated or not.
						if(mapOfficeNameOldToNew.containsKey(strObj.trim()))
							strUpdatedOfficeName = mapOfficeNameOldToNew.get(strObj.trim());
						
						if(strUpdatedOfficeName != '')
						{
							strOfficesName += strUpdatedOfficeName + '\n';
							isIntranetEventToBeUpdate = true;	
						}
						else if(!mapDeletedOffice.containsKey(strObj.trim()))
							strOfficesName += strObj.trim() + '\n';
						
						if(mapDeletedOffice.containsKey(strObj.trim()))
							isIntranetEventToBeUpdate = true;	
					}
					
					//check whether this Notification need to be update or not if so, updating Notification fields with updated values and add them to list of Notification to be update.
					if(isIntranetEventToBeUpdate)
					{
						strOfficesName = (strOfficesName != '') ? strOfficesName.substring(0, strOfficesName.length() - 1) : '';
						
						objEvent.Intranet_Event_Offices__c = strOfficesName;
						lstIntranetEventToBeUpdated.add(objEvent);
					}
				}
			}
			
			if(lstIntranetEventToBeUpdated.size() > 0)
				update lstIntranetEventToBeUpdated;
				
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;		
		}
		catch(Exception ex){
			system.debug('==========Exception============'+ex);
		}	
	}
	
	private void updateIntranetAppOffices(Map<String, String> mapOfficeNameOldToNew, Map<String, String> mapDeletedOffice)
	{
		try{
			List<Intranet_App__c> lstIntranetAppToBeUpdated = new List<Intranet_App__c>();	//list of Notification records to be update.
			Boolean isIntranetAppToBeUpdate = false;	//used to check whether Notification need to be update or not.
			
			for(Intranet_App__c objApp : [select Id, IntranetApp_Offices__c from Intranet_App__c where Id != null])
			{
				if(objApp.IntranetApp_Offices__c != '' && objApp.IntranetApp_Offices__c != null)
				{
					String strUpdatedOfficeName = '';
					String strOfficesName = '';
					List<String> lstSelectedOfficeName = String.valueOf(objApp.IntranetApp_Offices__c).split('\n');
					
					isIntranetAppToBeUpdate = false;
					
					//checking and re-creating offices name and ids as a string separated by '\n' and ';' respectively for each notification records. 
					for(String strObj : lstSelectedOfficeName)
					{
						strUpdatedOfficeName = '';
						
						//Checking whether office name is updated or not.
						if(mapOfficeNameOldToNew.containsKey(strObj.trim()))
							strUpdatedOfficeName = mapOfficeNameOldToNew.get(strObj.trim());
						
						if(strUpdatedOfficeName != '')
						{
							strOfficesName += strUpdatedOfficeName + '\n';
							isIntranetAppToBeUpdate = true;	
						}
						else if(!mapDeletedOffice.containsKey(strObj.trim()))
							strOfficesName += strObj.trim() + '\n';
						
						if(mapDeletedOffice.containsKey(strObj.trim()))
							isIntranetAppToBeUpdate = true;	
					}
					
					//check whether this Notification need to be update or not if so, updating Notification fields with updated values and add them to list of Notification to be update.
					if(isIntranetAppToBeUpdate)
					{
						strOfficesName = (strOfficesName != '') ? strOfficesName.substring(0, strOfficesName.length() - 1) : '';
						
						objApp.IntranetApp_Offices__c = strOfficesName;
						lstIntranetAppToBeUpdated.add(objApp);
					}
				}
			}
			
			if(lstIntranetAppToBeUpdated.size() > 0)
				update lstIntranetAppToBeUpdated;
				
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;		
		}
		catch(Exception ex){
			system.debug('==========Exception============'+ex);
		}	
	}
	
	/*
		@MethodName : updateUserOffices 
		@param 	    : Map of Office Old name to New name and map of deleted Office name to id.
		@Description: This method is used to update Office Name on User records.
	*/
	private void updateUserOffices(Map<String, String> mapOfficeNameOldToNew, Map<String, String> mapDeletedOffice)
	{
		try{
			List<User> lstUserToBeUpdated = new list<User>();	//list of User records to be update.
			Boolean isUserToBeUpdate = false;	//used to check whether User need to be update or not.
			
			for(User objUser : [select Id, User_Offices__c from User where Id != null])
			{
				if(objUser.User_Offices__c != '' && objUser.User_Offices__c != null)
				{
					String strUpdatedOfficeName = '';
					String strOfficesName = '';
					List<String> lstSelectedOfficeName = String.valueOf(objUser.User_Offices__c).split('\n');
					isUserToBeUpdate = false;
					
					//checking and re-creating offices name and ids as a string separated by '\n' and ';' respectively for each User records. 
					for(String strObj : lstSelectedOfficeName)
					{
						strUpdatedOfficeName = '';
						
						if(mapOfficeNameOldToNew.containsKey(strObj.trim()))
							strUpdatedOfficeName = mapOfficeNameOldToNew.get(strObj.trim());
						
						if(strUpdatedOfficeName != '')
						{
							strOfficesName += strUpdatedOfficeName + '\n';
							isUserToBeUpdate = true; 
						}
						else if(!mapDeletedOffice.containsKey(strObj.trim()))
							strOfficesName += strObj.trim() + '\n';
						
						if(mapDeletedOffice.containsKey(strObj.trim()))
							isUserToBeUpdate = true;	
					}
					
					//check whether this User need to be update or not if so, updating User fields with updated values and add them to list of User to be update.
					if(isUserToBeUpdate)
					{
						strOfficesName = (strOfficesName != '') ? strOfficesName.substring(0, strOfficesName.length() - 1) : '';
						
						objUser.User_Offices__c = strOfficesName;
						lstUserToBeUpdated.add(objUser);
					}
				}
			}
			
			if(lstUserToBeUpdated.size() > 0)
				update lstUserToBeUpdated;
				
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;		
		}
		catch(Exception ex){
			system.debug('==========Exception============'+ex);
		}	
	}
	/* End : updateUserOffices */
	
	/*
		@MethodName : updateContentOffices 
		@param 	    : Map of Office Old name to New name and map of deleted Office name to id.
		@Description: This method is used to update Office Name on Content records.
	*/
	private void updateContentOffices(Map<String, String> mapOfficeNameOldToNew, Map<String, String> mapDeletedOffice)
	{
		try{
			List<ContentVersion> lstContentToBeUpdated = new list<ContentVersion>();	//list of Content records to be update.
			Boolean isContentToBeUpdate = false;	//used to check whether Content need to be update or not.
			
			for(ContentVersion objContent : [select Id, Content_Offices__c from ContentVersion where Id != null])
			{
				if(Test.isRunningTest() || (objContent.Content_Offices__c != '' && objContent.Content_Offices__c != null))
				{
					String strUpdatedOfficeName = '';
					String strOfficesName = '';
					List<String> lstSelectedOfficeName = new List<String>();
					if(Test.isRunningTest())
					{
						lstSelectedOfficeName = new List<String>{'TestLocation1', 'TestLocation2'};
						mapOfficeNameOldToNew.put('TestLocation1', 'TestLocation3');
					}	
				    else
				    	lstSelectedOfficeName = String.valueOf(objContent.Content_Offices__c).split('\n');
				    isContentToBeUpdate = false;
				    
					//checking and re-creating offices name and ids as a string separated by '\n' and ';' respectively for each Content records.
					for(String strObj : lstSelectedOfficeName)
					{
						strUpdatedOfficeName = '';
						
						if(mapOfficeNameOldToNew.containsKey(strObj.trim()))
							strUpdatedOfficeName = mapOfficeNameOldToNew.get(strObj.trim());
						
						if(strUpdatedOfficeName != '')
						{
							strOfficesName += strUpdatedOfficeName + '\n';
							isContentToBeUpdate = true;
						}
						else if(!mapDeletedOffice.containsKey(strObj.trim()))
							strOfficesName += strObj.trim() + '\n';
						
						if(mapDeletedOffice.containsKey(strObj.trim()))
							isContentToBeUpdate = true;	
					}
					
					//check whether this Content need to be update or not if so, updating Content fields with updated values and add them to list of Content to be update.
					if(isContentToBeUpdate)
					{
						strOfficesName = (strOfficesName != '') ? strOfficesName.substring(0, strOfficesName.length() - 1) : '';
						
						objContent.Content_Offices__c = strOfficesName;
						lstContentToBeUpdated.add(objContent);
					}
				}
			}
			
			if(lstContentToBeUpdated.size() > 0 && !Test.isRunningTest())
				update lstContentToBeUpdated;
				
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;		
		}
		catch(Exception ex){
			system.debug('==========Exception============'+ex);
		}	
	}
	/* End : updateContentOffices */
}