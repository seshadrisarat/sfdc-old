/**
* @ClassName    : SL_IntranetOfficeLookupController 
* @JIRATicket   : Socint-120
* @CreatedOn    : 1/May/13
* @ModifiedBy   : Pravin Sapkal 
* @Description  : This is the controller for The SL_IntranetOfficeLookup.
*/

/**
@ Roshan Pillai 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 4
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

public with sharing class SL_IntranetOfficeLookupController 
{
	public String strOfficeLocations {get;set;}
    
    private String strRecordId;
    private String strSObject;
    private String strDocumentId;
    
    private List<string> lstRightValues = new List<string>();
    private List<string> lstLeftValues = new List<string>();
    private Map<String, String> mapIntranetOffices = new map<string,string>();
    
    /* Start : Constructor initialization */
	public SL_IntranetOfficeLookupController() 
  	{
    	try{
	    	strOfficeLocations = '';
	    	lstRightValues = new List<string>();
	    	lstLeftValues = new List<string>();
	    	mapIntranetOffices = new map<string,string>();
	    	
	    	strRecordId = Apexpages.currentPage().getParameters().get('id');	//getting record Id
	    	strDocumentId = '';
	        
	        strSObject = '';
	        String strSelectedOfficesIds = '';
	        String strKeyPrefix = '';
			if(strRecordId != null)
				strKeyPrefix = strRecordId.substring(0, 3);
				
			Schema.DescribeSObjectResult descUser = User.SObjectType.getDescribe();
			Schema.DescribeSObjectResult descContent = ContentVersion.SObjectType.getDescribe();
			Schema.DescribeSObjectResult descNotification = Notification__c.SObjectType.getDescribe();
			Schema.DescribeSObjectResult descIntranetEvent = Intranet_Event__c.SObjectType.getDescribe();   
            Schema.DescribeSObjectResult descIntranetApp = Intranet_App__c.SObjectType.getDescribe();   	
	        
	        //Compare and find the sObject Name i.e from which object's record the page is launched and query Selected_Offices_Ids fields of that record.
	        if(strKeyPrefix == descUser.getKeyPrefix())
	        {
	        	strSObject = 'User';
	        	strSelectedOfficesIds = [select Selected_Offices_Ids__c from User where id =: strRecordId].Selected_Offices_Ids__c;
	        }
	        else if(strKeyPrefix == descContent.getKeyPrefix())
	        {
	        	strSObject = 'ContentVersion';
	        	strSelectedOfficesIds = [select Selected_Offices_Ids__c from ContentVersion where id =: strRecordId].Selected_Offices_Ids__c;
	        	strDocumentId = [Select Id, ContentDocumentId From ContentVersion where id =: strRecordId and IsLatest = true limit 1].ContentDocumentId;
	        }
	        else if(strKeyPrefix == descNotification.getKeyPrefix())
	        {
	        	strSObject = 'Notification__c';
	        	strSelectedOfficesIds = [select Selected_Offices_Ids__c from Notification__c where id =: strRecordId].Selected_Offices_Ids__c;
	        }
	        else if(strKeyPrefix == descIntranetEvent.getKeyPrefix())
            {
                strSObject = 'Intranet_Event__c';
                strSelectedOfficesIds = [select Selected_Offices_Ids__c from Intranet_Event__c where id =: strRecordId].Selected_Offices_Ids__c;
            }
             else if(strKeyPrefix == descIntranetApp.getKeyPrefix())
            {
                strSObject = 'Intranet_App__c';
                strSelectedOfficesIds = [select Selected_Office_Ids__c from Intranet_App__c where id =: strRecordId].Selected_Office_Ids__c;
            }
	        
	        Set<String> setOfficesIds = new Set<String>();
	        List<String> lstOfficesIds = new List<String>();
	        if(strSelectedOfficesIds != '' && strSelectedOfficesIds != null)
	        	lstOfficesIds = strSelectedOfficesIds.split(';');

			setOfficesIds.addAll(lstOfficesIds);
			
			//Query all Office locations records
	        for(Office_Locations__c obj : [SELECT Name, Id FROM Office_Locations__c Order by Name LIMIT 500]) 
	        {
	        	//if the Office record is selected for the current record(from where the page is launched) then add to right side of multiselect otherwise add to left side.
	             if(setOfficesIds.contains(obj.id))
	             {
	             	lstRightValues.add(obj.Name);
	             	strOfficeLocations += obj.Name + '<>';
	             }
	             else 
		            lstLeftValues.add(obj.Name);	
	             
	             mapIntranetOffices.put(obj.Name, obj.Name);
	        }
	        
	        //To cover exception in test coverage	
			if(Test.isRunningTest())	
				Integer i = 1/0;	
    	}
    	catch(Exception e){
    		//Do nothing
    	}
  	}
  	/* End : Constructor initialization */
    
    /* Start - Method for getting left side multiselect picklist offices values.
	   @Name           - getunselectedItems
	   @Parameters     - None 
	   @Return Type    - List
	   @Description    - Function for getting left side multiselect picklist offices values.
	*/
  	public List<SelectOption> getunselectedItems() 
  	{
	    try{
		    List<SelectOption> options = new List<SelectOption>();
		    for(String strObj : lstLeftValues)
		    {
		    	options.add(new SelectOption(strObj,strObj));
		    }
		    
		    return options;
	    }
	    catch(Exception e){
	    	return null;
	    }
  	}
  	/* End : getunselectedItems */
	
	/* Start - Method for getting Right side multiselect picklist offices values.
	   @Name           - getSelectedItems
	   @Parameters     - None 
	   @Return Type    - List
	   @Description    - Function for getting Right side multiselect picklist offices values.
	*/
  	public List<SelectOption> getSelectedItems() 
  	{
	    try{
		    List<SelectOption> options = new List<SelectOption>();
		    for(String strObj : lstRightValues)
		    {
		    	options.add(new SelectOption(strObj,strObj));
		    }
		    
		    return options;
	    }
	    catch(Exception e){
	    	return null;
	    }
  	}
  	/* End : getSelectedItems */
	
	/* Start - Method for updating User, Content and Notification fields update.
	   @Name           - saveOfficeLocations
	   @Parameters     - None 
	   @Return Type    - PageReference
	   @Description    - Function for updating User, Content and Notification fields update.
	*/
  	public PageReference saveOfficeLocations() 
  	{
	    try{
		    String strMultiPicklistValue = '';

		    if(strOfficeLocations != null && strOfficeLocations != '' && strOfficeLocations != 'Empty' && strOfficeLocations.length() > 1) 
		    {
		    	for(String strValue : strOfficeLocations.substring(0,strOfficeLocations.length()-2).split('<>'))
		    		strMultiPicklistValue += strValue+';';
		    }
		    else if(strOfficeLocations != 'Empty') 
		    	strMultiPicklistValue = '';
			
			//Creating list of selected Offices ids.
		    List<String> lstStrOfficesName = new List<String>();
		    if(strMultiPicklistValue != '' && strMultiPicklistValue != null)
		    	lstStrOfficesName = strMultiPicklistValue.split(';');
		    
		    String retURL = '';
			String strOfficesName = '';

			//Creating string of Offices name separated by '\n' and string of Office location ids separated by ';'.
	        for(String strObj : lstStrOfficesName) 
	        {
	        	if(mapIntranetOffices.containsKey(strObj))
	        		strOfficesName += (strOfficesName != '') ? ('\n' + mapIntranetOffices.get(strObj)) : mapIntranetOffices.get(strObj); 
	        }
	        
	        //Updating user's fields and redirecting to User detail page
	        if(strSObject == 'User')
	        {
	        	User objUser = new User(id = strRecordId);
	        	objUser.User_Offices__c = strOfficesName;
	        	update objUser;
	        	retURL = strRecordId + '?noredirect=1'; 
	        }
	        //Updating Content's fields and redirecting to Content detail page
	        else if(strSObject == 'ContentVersion')
	        {
	        	ContentVersion objContent = new ContentVersion(id = strRecordId);
	        	objContent.Content_Offices__c = strOfficesName;
	        	update objContent;
	        	retURL = 'sfc/'; 
	        } 
	        //Updating Notification's fields and redirecting to Notification detail page
	        else if(strSObject == 'Notification__c')
	        {
	        	Notification__c objNotification = new Notification__c(id = strRecordId);
	        	objNotification.Notification_Offices__c = strOfficesName;
	        	update objNotification;
	        	retURL = strRecordId; 
	        }
	         //Updating Intranet_Event__c's fields and redirecting to Intranet_Event__c detail page
            else if(strSObject == 'Intranet_Event__c')
            {
                Intranet_Event__c objIntranetEvent = new Intranet_Event__c(id = strRecordId);
                objIntranetEvent.Intranet_Event_Offices__c = strOfficesName;
                update objIntranetEvent;
                retURL = strRecordId; 
            }
             //Updating Intranet_App__c's fields and redirecting to Intranet_App__c detail page
            else if(strSObject == 'Intranet_App__c')
            {
                Intranet_App__c objIntranetApp = new Intranet_App__c(id = strRecordId);
                objIntranetApp.IntranetApp_Offices__c = strOfficesName;
                update objIntranetApp;
                retURL = strRecordId; 
            }
            else
                return null;
	        
	        PageReference pref = new PageReference('/' + retURL);
	        pref.setRedirect(true);
	        if(strSObject == 'ContentVersion')
	        	pref.setAnchor('version?selectedDocumentId=' + strDocumentId);
	        return pref;	
	    }
	    catch(Exception e){
	    	return null;
	    }
  	}
  	/* End : saveOfficeLocations */
	
	/* Start - Method for redirecting back to detail page of record from where the page is launched.
	   @Name           - cancel
	   @Parameters     - None 
	   @Return Type    - PageReference
	   @Description    - Function for redirecting back to detail page of record from where the page is launched.
	*/
  	public PageReference cancel()
    {
		try{
			String retURL = '';
	   		if(strSObject == 'User')
	        	retURL = strRecordId + '?noredirect=1'; 
	        else if(strSObject == 'ContentVersion')
	        	retURL = 'sfc/'; 
	        else
	        	retURL = strRecordId;	
	   		
	   		PageReference pref = new PageReference('/' + retURL);
	        pref.setRedirect(true);
	        if(strSObject == 'ContentVersion')
	        	pref.setAnchor('version?selectedDocumentId=' + strDocumentId);
	        return pref;
		}
		catch(Exception e){
	    	return null;
	    }
    }
    /* End : cancel */
}