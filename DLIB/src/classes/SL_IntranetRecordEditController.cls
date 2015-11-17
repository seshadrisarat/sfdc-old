public with sharing class SL_IntranetRecordEditController 
{
	/*Public variables declaration*/
	public Sobject EventOrNotification 												{	get;set;	}
	public String strNotificationOrEventId 											{	get;set;	}	// Will store Event or Notification record Id
	public String strWidgetId														{	get;set;	}	// Will store widget Id whose record is being edited
	public String strObjectName														{	get;set;	}	// Will store Object name whose record is being Edited
	public String strFieldSetName													{	get;set;	}	// Will store fieldSetName of the Object Edited
	public List<SL_UtilityWrappers.FieldSetDescribe> lstSObjectFields 				{	get;set;	}	// Will store all describe fieldset fields  
	/*Private variables*/
	private String strQuery;
	
	/*Constructor*/
	public SL_IntranetRecordEditController()
	{
		lstSObjectFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		strQuery = '';
		
		fetchValues(); // Use to fetch values based on Parameters.
	}
	
	/* Start - Method for getting fetching record based on Record Id 
	   @Name           - fetchValues
	   @Parameters     - None 
	   @Return Type    - void  
	   @Description    - Function for getting Notification/Event record 
	*/
	private void fetchValues()
	{
		strWidgetId = ApexPages.currentPage().getParameters().get('widgetId');
		strNotificationOrEventId = ApexPages.currentPage().getParameters().get('recordId');
		strObjectName = String.valueOf(((Id)strNotificationOrEventId).getSObjectType());
		strFieldSetName = ApexPages.currentPage().getParameters().get('fieldSetName');
		
		if(strObjectName == 'Notification__c' || strObjectName == 'Intranet_Event__c')
		{
			/* getting Non-editbale field via describe call*/
	        SObjectType notificationType = Schema.getGlobalDescribe().get(strObjectName);
	        /*Set is used to get all the non-editable fields*/
			Set<String> setNonEditableField = new Set<String>();
			/*List which will store the default fields which will show in popup if fieldset in not present */
			List<String> lstDefaultNotificationFields = new List<String>{'Name', 'Notification_Detail__c'};
			List<String> lstDefaultEventFields = new List<String>{'Date_of_Event__c', 'End_Date__c'};
			
			/*Iteration to get all the non-editable fields and store it in a Set(setNonEditableField)*/
			for(Schema.SObjectField sobjField:notificationType.getDescribe().fields.getMap().values())
			{
				if(!sobjField.getDescribe().isCreateable())
			   		setNonEditableField.add(sobjField.getDescribe().getName());
			}
			setNonEditableField.add('OwnerId');
			
			Set<String> setTempField = new Set<String>();	// To store the field API name which need to be added in Query
			
			if(String.isNotBlank(strFieldSetName))
			{
				SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet(strObjectName,strFieldSetName, '', '', '', setNonEditableField);
				lstSObjectFields = objFieldSetWrapper.lstFieldWrapper;
			}
			
			if(lstSObjectFields.isEmpty() && strObjectName == 'Notification__c')
				lstSObjectFields.addAll( Utilities.describeDefaultFields(strObjectName, lstDefaultNotificationFields));
			else if(lstSObjectFields.isEmpty() && strObjectName == 'Intranet_Event__c')
				lstSObjectFields.addAll( Utilities.describeDefaultFields(strObjectName, lstDefaultEventFields));

			for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstSObjectFields)
            	setTempField.add(objFieldSetResult.fieldAPIName);
			
			strQuery = 'Select Id' ;
			for(String strField : setTempField)
            	strQuery += ','+ strField; 
            	
			strQuery += ' FROM ' +strObjectName+ ' WHERE Id =: strNotificationOrEventId';
			
		}
        EventOrNotification = Database.query(strQuery);
	}
	
	/* Start - Method for getting fetching record based on Record Id 
	   @Name           - updateEventOrNotificationRecord
	   @Parameters     - None 
	   @Return Type    - void  
	   @Description    - Function for updating Notification/Event record 
	*/
	public void updateEventOrNotificationRecord() 
    {
    	try{    
            if(EventOrNotification != null){
                update EventOrNotification;
            }
    	}
    	catch(Exception ex){
            system.debug('Exception:'+ex);
    	}
    }
    
    /* Start - Method for getting fetching record based on Record Id 
	   @Name           - deleteEventOrNotificationRecord
	   @Parameters     - None 
	   @Return Type    - void  
	   @Description    - Function for delete Notification/Event record 
	*/
    public void deleteEventOrNotificationRecord()
    {
    	try{    
            if(EventOrNotification != null){
                delete EventOrNotification;
            }
    	}
    	catch(Exception ex){
            system.debug('Exception:'+ex);
    	}
    }
	
	
}