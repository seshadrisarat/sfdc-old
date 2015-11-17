public with sharing class SL_CreateRecords 
{
	public String strJSONBody	{get;set;}					// JSON String with required field values of any Object records 
	public String strObjectName {get;set;}					// To store object Name
  	public Map<String,String> mapObjectNameAndJSONString; 	// Map of Object name and JSON String
  	private String strNameSpace;							// To store Namespace name if installed in Managed package
  	private List<String> lstObjectName = new List<String>{'Department__c','Office_Locations__c','Intranet_App__c','Notification__c','Intranet_Event__c','ContentVersion','User'};
  	
  	/*Constructor*/
  	public SL_CreateRecords()
  	{
  		strJSONBody = strObjectName = strNameSpace = '';
  		mapObjectNameAndJSONString = new Map<String,String>();
  		
  		try
  		{
  			/*Checking if Managed Package is installed in the Org with Namespace as SLSI*/
	  		if(UserInfo.isCurrentUserLicensed('SLSI'))
	  		{
	  			strNameSpace = 'SLSI__';
	  			lstObjectName = new List<String>{'SLSI__Department__c','SLSI__Office_Locations__c','SLSI__Intranet_App__c','SLSI__Notification__c','SLSI__Intranet_Event__c','ContentVersion','User'};
	  		}
  		}
  		catch(TypeException ex)
  		{
  			strNameSpace = '';
  		}
  	}
  	
  	/*This method is used to get the string and store in a Map with respective to its object name*/
  	public void csvToJSONValidate()
  	{
  		strJSONBody = strJSONBody.replaceAll('"TRUE"', 'true').replaceAll('"FALSE"', 'false');
  		strJSONBody = strJSONBody.replaceAll('"null"', 'null').replaceAll('"null"', 'null');
  		
  		if(String.isNotBlank(strNameSpace) && strObjectName != 'ContentVersion' && strObjectName != 'User')
	  		mapObjectNameAndJSONString.put(strNameSpace+strObjectName,strJSONBody);
	  	else
	  		mapObjectNameAndJSONString.put(strObjectName,strJSONBody);
	  		
	}
	
	/*This method is called when we will create the records on click of Save one by one for each object*/
	public void createRecords()
	{
		for(String objectName : lstObjectName)
		{
			List<sObject> lstRecordsToCreate = new List<sObject>();
			if(mapObjectNameAndJSONString.containsKey(objectName))
			{ 
				Type objectType = Type.forName('List<'+objectName+'>');
				
				if(objectName == 'ContentVersion')
				{
					List<sObject> lstRecords = (List<sObject>) JSON.deserialize(mapObjectNameAndJSONString.get(objectName), objectType);
					for(sObject objCV: lstRecords)
					{
						if(String.isNotBlank((String)objCV.get('PathOnClient')))
						{	
							String pathOnClient = (String) objCV.get('PathOnClient');
							PageReference updateVersionData = new PageReference(pathOnClient.substring(0,pathOnClient.lastIndexOf('.')));
							
							if (Test.IsRunningTest())
								Blob content=Blob.valueOf('UNIT.TEST');
							else
								objCV.put('VersionData',updateVersionData.getContent());

		  					lstRecordsToCreate.add(objCV);
						}
					}
				}
				else 
					lstRecordsToCreate = (List<sObject>) JSON.deserialize(mapObjectNameAndJSONString.get(objectName), objectType);
			}	
			DataBase.insert(lstRecordsToCreate,false);
		}
		mapObjectNameAndJSONString = new Map<String,String>();
	}
}