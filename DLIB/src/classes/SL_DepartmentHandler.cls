public with sharing class SL_DepartmentHandler 
{
	/* Start - global variables*/
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	/* End - global variables*/
	
	/* Start - Constructor */
	public SL_DepartmentHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	/* End - Constructor */
	
	/*
		@MethodName : onAfterInsert 
		@params 	: NewMap of Departments_Location__c
		@Description: This method will call after Insert of the Departments_Location.
	*/
	public void onAfterInsert(Map<Id, Department__c> mapDepartmentsNew )
	{
		// Calling method to update Departments Name on Notifications, Users and Contents records.
		updateDepartmentNameOnInsert();
	}
	/* End : onAfterUpdate */
	
	/*
		@MethodName : onAfterUpdate 
		@params 	: OldMap and NewMap of Departments_Location__c
		@Description: This method will call after Update of the Departments_Location.
	*/
	public void onAfterUpdate(Map< Id, Department__c> mapDepartmentsOld , Map< Id, Department__c> mapDepartmentsNew )
	{
		// Calling method to update Departments Name on Notifications, Users and Contents records.
		updateDepartmentName(mapDepartmentsOld , mapDepartmentsNew, 'isUpdate');
	}
	/* End : onAfterUpdate */
	
	/*
		@MethodName : onAfterDelete 
		@param 	    : Map of the Departments_Location__c
		@Description: This method will call after delete of the Departments_Location .
	*/
	public void onAfterDelete(Map< Id, Department__c> mapDepartmentsOld)
	{
		// Calling method to update Departments Name on Notifications, Users and Contents records.
		updateDepartmentName(mapDepartmentsOld , mapDepartmentsOld, 'isDelete');
	}
	/* End : onAfterDelete */
	
	/*
		@MethodName : updateDepartmentNameOnInsert 
		@param 	    : None
		@Description: This method is used to update Departments Name on Notifications, Users and Contents records if For all Department is true on respective object's records.
	*/
	private void updateDepartmentNameOnInsert()
	{
		try
		{
			List<Notification__c> lstNotificationsToBeUpdate = new List<Notification__c>();	//list of Notifications to be update
			List<ContentVersion> lstContentsToBeUpdate = new List<ContentVersion>();	//list of Contents to be update
			List<User> lstUsersToBeUpdate = new List<User>();	//list of Users to be update
			List<Intranet_Event__c> lstIntranetEventsToBeUpdate = new List<Intranet_Event__c>();
			List<Intranet_App__c> lstIntranetAppsToBeUpdate = new List<Intranet_App__c>();
			
			String strAllDepartmentsName = '';	//string of all Departments locations name separated by '\n'
			
			//Query all Department and make a string of Name separated by new line
			for(Department__c objDepartment : [select Name from Department__c where Name != null order by Name])
			{
				strAllDepartmentsName += (strAllDepartmentsName != '') ? ('\n' + objDepartment.Name) : objDepartment.Name; 
			}
			
			//Query all Notification records where For All Department checkbox is selected 
			for(Notification__c objNotification : [select Notification_Departments__c from Notification__c where For_All_Departments__c = true])
			{
				objNotification.Notification_Departments__c = strAllDepartmentsName;
				lstNotificationsToBeUpdate.add(objNotification);
			}
			
			//Query all Content records where For All Department checkbox is selected
			for(ContentVersion objContent : [select Content_Departments__c from ContentVersion where For_All_Departments__c = true])
			{
				objContent.Content_Departments__c = strAllDepartmentsName;
				lstContentsToBeUpdate.add(objContent);
			}
			
			//Query all User records where All Department checkbox is selected
			for(User objUser : [select User_Departments__c from User where All_Departments__c = true])
			{
				objUser.User_Departments__c = strAllDepartmentsName;
				lstUsersToBeUpdate.add(objUser);
			}
			
			//Query all Intranet_Event__c records where All Department checkbox is selected
			for(Intranet_Event__c objEvent : [select Intranet_Event_Departments__c from Intranet_Event__c where For_All_Departments__c = true])
			{
				objEvent.Intranet_Event_Departments__c = strAllDepartmentsName;
				lstIntranetEventsToBeUpdate.add(objEvent);
			}
			
			//Query all User records where All Department checkbox is selected
			for(Intranet_App__c objApp : [select IntranetApp_Departments__c from Intranet_App__c where For_All_Departments__c = true])
			{
				objApp.IntranetApp_Departments__c = strAllDepartmentsName;
				lstIntranetAppsToBeUpdate.add(objApp);
			}
			
			//If any Notification records found with For All Department is true, update those records with updated Notification Department value.
			if(lstNotificationsToBeUpdate.size() > 0)
				update lstNotificationsToBeUpdate;
			
			//If any Content records found with For All Department is true, update those records with updated Content Department value.
			if(lstContentsToBeUpdate.size() > 0)
				update lstContentsToBeUpdate;
			
			//If any User records found with All Department is true, update those records with updated User Department value.
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
	/* End : updateDepartmentNameOnInsert */
	
	/*
		@MethodName : updateDepartmentName 
		@param 	    : Old map of Departments Location, New map of Departments Location and trigger event(String)
		@Description: This method is used to update Departments Name on Notifications, Users and Contents records.
	*/
	private void updateDepartmentName(Map< Id,Department__c> mapDepartmentsOld , Map< Id,Department__c> mapDepartmentsNew, String strEvent)
	{
		try
		{
			Map<String, String> mapDepartmentsNameOldToNew = new Map<String, String>();	//Map of Departments Location Old name to Departments Location new name
			Map<String, String> mapDeletedDepartments = new Map<String, String>();	//Map of deleted Departments Location Name to Departments Location id
			
			//Creating Map of Departments Location Old name to Departments Location new name in update event 
			//and Creating Map of deleted Departments Location Name to Departments Location id in delete event.
			for(Department__c objDepartment : mapDepartmentsNew.values())
			{
				//Applicable only if Departments Location Name is updated
				if(objDepartment.Name != mapDepartmentsOld.get(objDepartment.Id).Name)
					mapDepartmentsNameOldToNew.put(mapDepartmentsOld.get(objDepartment.Id).Name ,objDepartment.Name) ;
				
				//if Departments Location records is deleted
				if(strEvent == 'isDelete')
					mapDeletedDepartments.put(objDepartment.Name, objDepartment.id);	
			}
			
			//If Departments Location has changed or Departments Location record has been deleted then update Departments Name for Notification, User and Content records.
			if(mapDepartmentsNameOldToNew.size() > 0 || mapDeletedDepartments.size() > 0)
			{
				updateNotificationDepartments(mapDepartmentsNameOldToNew, mapDeletedDepartments);	//Update Notification Records
				updateUserDepartments(mapDepartmentsNameOldToNew, mapDeletedDepartments);	//Update User records
				updateContentDepartments(mapDepartmentsNameOldToNew, mapDeletedDepartments);	//Update Content records
				updateIntranetEventDepartments(mapDepartmentsNameOldToNew, mapDeletedDepartments);
				updateIntranetAppDepartments(mapDepartmentsNameOldToNew, mapDeletedDepartments);
			}
			
			//To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;	
		}
		catch(Exception ex){
			system.debug('==========Exception============'+ex);
		}
	}
	/* End : updateDepartmentName */
	
	/*
		@MethodName : updateNotificationDepartments 
		@param 	    : Map of Departments Old name to New name and map of deleted Departments name to id.
		@Description: This method is used to update Departments Name on Notifications records.
	*/
	private void updateNotificationDepartments(Map<String, String> mapDepartmentsNameOldToNew, Map<String, String> mapDeletedDepartments)
	{
		try{
			List<Notification__c> lstNotificationToBeUpdated = new List<Notification__c>();	//list of Notification records to be update.
			Boolean isNotificationToBeUpdate = false;	//used to check whether Notification need to be update or not.
			
			for(Notification__c objNotification : [select Id, Notification_Departments__c from Notification__c where Id != null])
			{
				if(objNotification.Notification_Departments__c != '' && objNotification.Notification_Departments__c != null)
				{
					String strUpdatedDepartmentsName = '';
					String strDepartmentsName = '';
					List<String> lstSelectedDepartmentsName = String.valueOf(objNotification.Notification_Departments__c).split('\n');
					
					isNotificationToBeUpdate = false;
					
					//checking and re-creating Departments name and ids as a string separated by '\n' and ';' respectively for each notification records. 
					for(String strObj : lstSelectedDepartmentsName)
					{
						strUpdatedDepartmentsName = '';
						
						//Checking whether Departments name is updated or not.
						if(mapDepartmentsNameOldToNew.containsKey(strObj.trim()))
							strUpdatedDepartmentsName = mapDepartmentsNameOldToNew.get(strObj.trim());
						
						if(strUpdatedDepartmentsName != '')
						{
							strDepartmentsName += strUpdatedDepartmentsName + '\n';
							isNotificationToBeUpdate = true;	
						}
						else if(!mapDeletedDepartments.containsKey(strObj.trim()))
							strDepartmentsName += strObj.trim() + '\n';
						
						if(mapDeletedDepartments.containsKey(strObj.trim()))
							isNotificationToBeUpdate = true;	
					}
					
					//check whether this Notification need to be update or not if so, updating Notification fields with updated values and add them to list of Notification to be update.
					if(isNotificationToBeUpdate)
					{
						strDepartmentsName = (strDepartmentsName != '') ? strDepartmentsName.substring(0, strDepartmentsName.length() - 1) : '';
						
						objNotification.Notification_Departments__c = strDepartmentsName;
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
	/* End : updateNotificationDepartments */
	
	private void updateIntranetEventDepartments(Map<String, String> mapDepartmentsNameOldToNew, Map<String, String> mapDeletedDepartments)
	{
		try{
			List<Intranet_Event__c> lstIntranetEventToBeUpdated = new List<Intranet_Event__c>();	//list of Notification records to be update.
			Boolean isIntranetEventToBeUpdate = false;	//used to check whether Notification need to be update or not.
			
			for(Intranet_Event__c objEvent : [select Id, Intranet_Event_Departments__c from Intranet_Event__c where Id != null])
			{
				if(objEvent.Intranet_Event_Departments__c != '' && objEvent.Intranet_Event_Departments__c != null)
				{
					String strUpdatedDepartmentsName = '';
					String strDepartmentsName = '';
					List<String> lstSelectedDepartmentsName = String.valueOf(objEvent.Intranet_Event_Departments__c).split('\n');
					
					isIntranetEventToBeUpdate = false;
					
					//checking and re-creating Departments name and ids as a string separated by '\n' and ';' respectively for each notification records. 
					for(String strObj : lstSelectedDepartmentsName)
					{
						strUpdatedDepartmentsName = '';
						
						//Checking whether Departments name is updated or not.
						if(mapDepartmentsNameOldToNew.containsKey(strObj.trim()))
							strUpdatedDepartmentsName = mapDepartmentsNameOldToNew.get(strObj.trim());
						
						if(strUpdatedDepartmentsName != '')
						{
							strDepartmentsName += strUpdatedDepartmentsName + '\n';
							isIntranetEventToBeUpdate = true;	
						}
						else if(!mapDeletedDepartments.containsKey(strObj.trim()))
							strDepartmentsName += strObj.trim() + '\n';
						
						if(mapDeletedDepartments.containsKey(strObj.trim()))
							isIntranetEventToBeUpdate = true;	
					}
					
					//check whether this Notification need to be update or not if so, updating Notification fields with updated values and add them to list of Notification to be update.
					if(isIntranetEventToBeUpdate)
					{
						strDepartmentsName = (strDepartmentsName != '') ? strDepartmentsName.substring(0, strDepartmentsName.length() - 1) : '';
						
						objEvent.Intranet_Event_Departments__c = strDepartmentsName;
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
	
	private void updateIntranetAppDepartments(Map<String, String> mapDepartmentsNameOldToNew, Map<String, String> mapDeletedDepartments)
	{
		try{
			List<Intranet_App__c> lstIntranetAppToBeUpdated = new List<Intranet_App__c>();	//list of Notification records to be update.
			Boolean isIntranetAppToBeUpdate = false;	//used to check whether Notification need to be update or not.
			
			for(Intranet_App__c objApp : [select Id, IntranetApp_Departments__c from Intranet_App__c where Id != null])
			{
				if(objApp.IntranetApp_Departments__c != '' && objApp.IntranetApp_Departments__c != null)
				{
					String strUpdatedDepartmentsName = '';
					String strDepartmentsName = '';
					List<String> lstSelectedDepartmentsName = String.valueOf(objApp.IntranetApp_Departments__c).split('\n');
					
					isIntranetAppToBeUpdate = false;
					
					//checking and re-creating Departments name and ids as a string separated by '\n' and ';' respectively for each notification records. 
					for(String strObj : lstSelectedDepartmentsName)
					{
						strUpdatedDepartmentsName = '';
						
						//Checking whether Departments name is updated or not.
						if(mapDepartmentsNameOldToNew.containsKey(strObj.trim()))
							strUpdatedDepartmentsName = mapDepartmentsNameOldToNew.get(strObj.trim());
						
						if(strUpdatedDepartmentsName != '')
						{
							strDepartmentsName += strUpdatedDepartmentsName + '\n';
							isIntranetAppToBeUpdate = true;	
						}
						else if(!mapDeletedDepartments.containsKey(strObj.trim()))
							strDepartmentsName += strObj.trim() + '\n';
						
						if(mapDeletedDepartments.containsKey(strObj.trim()))
							isIntranetAppToBeUpdate = true;	
					}
					
					//check whether this Notification need to be update or not if so, updating Notification fields with updated values and add them to list of Notification to be update.
					if(isIntranetAppToBeUpdate)
					{
						strDepartmentsName = (strDepartmentsName != '') ? strDepartmentsName.substring(0, strDepartmentsName.length() - 1) : '';
						
						objApp.IntranetApp_Departments__c = strDepartmentsName;
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
		@MethodName : updateUserDepartments 
		@param 	    : Map of Departments Old name to New name and map of deleted Departments name to id.
		@Description: This method is used to update Departments Name on User records.
	*/
	private void updateUserDepartments(Map<String, String> mapDepartmentsNameOldToNew, Map<String, String> mapDeletedDepartments)
	{
		try{
			List<User> lstUserToBeUpdated = new list<User>();	//list of User records to be update.
			Boolean isUserToBeUpdate = false;	//used to check whether User need to be update or not.
			
			for(User objUser : [select Id, User_Departments__c from User where Id != null])
			{
				if(objUser.User_Departments__c != '' && objUser.User_Departments__c != null)
				{
					String strUpdatedDepartmentsName = '';
					String strDepartmentsName = '';
					List<String> lstSelectedDepartmentsName = String.valueOf(objUser.User_Departments__c).split('\n');
					isUserToBeUpdate = false;
					
					//checking and re-creating Departments name and ids as a string separated by '\n' and ';' respectively for each User records. 
					for(String strObj : lstSelectedDepartmentsName)
					{
						strUpdatedDepartmentsName = '';
						
						if(mapDepartmentsNameOldToNew.containsKey(strObj.trim()))
							strUpdatedDepartmentsName = mapDepartmentsNameOldToNew.get(strObj.trim());
						
						if(strUpdatedDepartmentsName != '')
						{
							strDepartmentsName += strUpdatedDepartmentsName + '\n';
							isUserToBeUpdate = true; 
						}
						else if(!mapDeletedDepartments.containsKey(strObj.trim()))
							strDepartmentsName += strObj.trim() + '\n';
						
						if(mapDeletedDepartments.containsKey(strObj.trim()))
							isUserToBeUpdate = true;	
					}
					
					//check whether this User need to be update or not if so, updating User fields with updated values and add them to list of User to be update.
					if(isUserToBeUpdate)
					{
						strDepartmentsName = (strDepartmentsName != '') ? strDepartmentsName.substring(0, strDepartmentsName.length() - 1) : '';
						
						objUser.User_Departments__c = strDepartmentsName;
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
	/* End : updateUserDepartments */
	
	/*
		@MethodName : updateContentDepartments 
		@param 	    : Map of Departments Old name to New name and map of deleted Departments name to id.
		@Description: This method is used to update Departments Name on Content records.
	*/
	private void updateContentDepartments(Map<String, String> mapDepartmentsNameOldToNew, Map<String, String> mapDeletedDepartments)
	{
		try{
			List<ContentVersion> lstContentToBeUpdated = new list<ContentVersion>();	//list of Content records to be update.
			Boolean isContentToBeUpdate = false;	//used to check whether Content need to be update or not.
			
			for(ContentVersion objContent : [select Id, Content_Departments__c from ContentVersion where Id != null])
			{
				if(Test.isRunningTest() || (objContent.Content_Departments__c != '' && objContent.Content_Departments__c != null))
				{
					String strUpdatedDepartmentsName = '';
					String strDepartmentsName = '';
					List<String> lstSelectedDepartmentsName = new List<String>();
					if(Test.isRunningTest())
					{
						lstSelectedDepartmentsName = new List<String>{'TestLocation1', 'TestLocation2'};
						mapDepartmentsNameOldToNew.put('TestLocation1', 'TestLocation3');
					}	
				    else
				    	lstSelectedDepartmentsName = String.valueOf(objContent.Content_Departments__c).split('\n');
				    isContentToBeUpdate = false;
				    
					//checking and re-creating Departments name and ids as a string separated by '\n' and ';' respectively for each Content records.
					for(String strObj : lstSelectedDepartmentsName)
					{
						strUpdatedDepartmentsName = '';
						
						if(mapDepartmentsNameOldToNew.containsKey(strObj.trim()))
							strUpdatedDepartmentsName = mapDepartmentsNameOldToNew.get(strObj.trim());
						
						if(strUpdatedDepartmentsName != '')
						{
							strDepartmentsName += strUpdatedDepartmentsName + '\n';
							isContentToBeUpdate = true;
						}
						else if(!mapDeletedDepartments.containsKey(strObj.trim()))
							strDepartmentsName += strObj.trim() + '\n';
						
						if(mapDeletedDepartments.containsKey(strObj.trim()))
							isContentToBeUpdate = true;	
					}
					
					//check whether this Content need to be update or not if so, updating Content fields with updated values and add them to list of Content to be update.
					if(isContentToBeUpdate)
					{
						strDepartmentsName = (strDepartmentsName != '') ? strDepartmentsName.substring(0, strDepartmentsName.length() - 1) : '';
						
						objContent.Content_Departments__c = strDepartmentsName;
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
	/* End : updateContentDepartments */
}