/**  
* \arg ClassName      : SL_MassRelationshipCreation
* \arg JIRATicket     : HL-14
* \arg CreatedOn      : 21/MAY/2014
* \arg LastModifiedOn : 27/MAY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Controller for SL_MassRelationshipCreation page for creating Mass relation ship records.
*/
global with sharing class SL_MassRelationshipCreation 
{
	/* Start - Variables */
	public String strHLContactId			{	get;set;	}//!< Hold the HL Contact Id.
	public String strHLContactName			{	get;set;	}//!< Hold the HL Contact Name.
	public String strShowContact			{	get;set;	}//!< Get the picklist value corresponding to which Contact need to display.
	public String strEngagementId			{	get;set;	}//!< This variable to store the Id of the Engagment.
	public String strPicklistValue			{	get;set;	}//!< have the picklist value option.
	
	
	 private Map<String, Schema.SObjectType> mapGlobalDescribe;//!< Describe map to get the fields, fieldset and picklist values etc...
	
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_MassRelationshipCreation(ApexPages.StandardController stdController)
	{
		intialization();
		strPicklistValue = getPicklistValue('Relationship__c', 'Strength_Rating__c');
		strEngagementId = (Id)stdController.getRecord().Id;
	}
	/* End - Constructor */
	
	/* Start - Wrapper class to display column */
	global class RelationshipWrapper
	{
		public String strContactName		{	get;set;	}
		public String strContactId			{	get;set;	}
		public String strRelationshipId		{	get;set;	}
		public String strCompanyName		{	get;set;	}
		public String strAppearOn			{	get;set;	}
		public String strStrenghScore		{	get;set;	}
		public Boolean blSyncOutlook		{	get;set;	}
		
		public RelationshipWrapper(String strContactName, String strContactId, String strRelationshipId, 
								   String strCompanyName, String strAppearOn, String strStrenghScore, Boolean blSyncOutlook)
		{
			this.strContactName = strContactName;
			this.strContactId = strContactId;
			this.strRelationshipId = strRelationshipId;
			this.strCompanyName = strCompanyName;
			this.strAppearOn = strAppearOn;
			this.strStrenghScore = strStrenghScore;
			this.blSyncOutlook = blSyncOutlook;
		}
	}
	/* End - Wrapper*/
	
	/*
		@MethodName : intialization 
		@param 	    : NA
		@Description: to intializa all global variables. 
	*/
	private void intialization()
	{
		mapGlobalDescribe = Schema.getGlobalDescribe();
		strEngagementId = strHLContactId = strHLContactName = strPicklistValue = '';
		strShowContact = 'All_Contacts';
	}
	/* End */
	
	/*
		@MethodName : getContactOptions 
		@param 	    : NA
		@Description: method to get the option for show contact.
	*/
	public List<Selectoption> getContactOptions()
    {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new Selectoption('All_Contacts', 'All Contacts'));
    	options.add(new Selectoption('External_Team', 'External Team'));
    	options.add(new Selectoption('Client_Team', 'Client Team'));
    	options.add(new Selectoption('Counterparty_Contacts', 'Counterparty Contacts'));
    	return options;
	}
	/* End */
	
	/*
		@MethodName : getRelationShipRecords 
		@param 	    : NA
		@Description: remote action method to return the relation ship records.
	*/
	@RemoteAction
	global static List<RelationshipWrapper> getRelationShipRecords(String strParentId, String strHLContactId, String strContactOption)
	{
		List<RelationshipWrapper> lstRW = new List<RelationshipWrapper>();
		Set<String> setCTContactIds = new Set<String>();
		Set<String> setETContactIds = new Set<String>();
		Set<String> setCPContactIds = new Set<String>();
		Map<String, Relationship__c> mapContactIdToRelationship = new Map<String, Relationship__c>();
		Map<Id, Contact> mapIdToContact = new Map<Id, Contact>();
		if(strContactOption == 'All_Contacts')
		{
			setCTContactIds = getContactIds('Engagement_External_Team__c', 'Engagement__c', strParentId, 'Contact__c', 'Type__c', 'Client');
			setETContactIds = getContactIds('Engagement_External_Team__c', 'Engagement__c',strParentId,'Contact__c', 'Type__c', 'External');
			setCPContactIds = getContactIds('Engagement_Counterparty__c', 'Engagement__c', strParentId, 'Coverage_Officer__c', '', '');
		}
		else if(strContactOption == 'External_Team')
			setETContactIds = getContactIds('Engagement_External_Team__c', 'Engagement__c',strParentId,'Contact__c', 'Type__c', 'External');
		else if(strContactOption == 'Client_Team')
			setCTContactIds = getContactIds('Engagement_External_Team__c', 'Engagement__c', strParentId, 'Contact__c', 'Type__c', 'Client');
		else if(strContactOption == 'Counterparty_Contacts')
			setCPContactIds = getContactIds('Engagement_Counterparty__c', 'Engagement__c', strParentId, 'Coverage_Officer__c', '', '');
			
		mapIdToContact = new Map<Id, Contact>([SELECT Id , 
													  Name, 
													  Account.Name 
												 FROM Contact 
												WHERE (Id IN:setETContactIds 
												   OR Id IN:setCTContactIds 
												   OR Id IN:setCPContactIds)
												  AND RecordType.DeveloperName = 'External_Contact']);
		
		for(Relationship__c objRelationship : [SELECT Id, 
													  HL_Contact__c, 
													  External_Contact__c, 
													  Sync_to_Outlook__c, 
													  Strength_Rating__c
												 FROM Relationship__c
												WHERE External_Contact__c IN:mapIdToContact.keySet() 
												  AND HL_Contact__c =: strHLContactId ])
		{
			mapContactIdToRelationship.put(objRelationship.HL_Contact__c + '=' + objRelationship.External_Contact__c, objRelationship);
		}
		
		for(Contact objContact : mapIdToContact.values())
		{
			String strAppearOn = (setCTContactIds.contains(objContact.Id)) ? 'Client Team' 
							   : (setETContactIds.contains(objContact.Id)) ? 'External Team': 'Counterparty Contact';
							   
			if(mapContactIdToRelationship.containskey(strHLContactId + '=' + objContact.Id))
			{
				lstRW.add(new RelationshipWrapper(objContact.Name, objContact.Id, 
												  mapContactIdToRelationship.get(strHLContactId + '=' + objContact.Id).Id, 
												  objContact.Account.Name, strAppearOn, 
												  mapContactIdToRelationship.get(strHLContactId + '=' + objContact.Id).Strength_Rating__c,
												  mapContactIdToRelationship.get(strHLContactId + '=' + objContact.Id).Sync_to_Outlook__c));
			}
			else
			{
				lstRW.add(new RelationshipWrapper(objContact.Name, objContact.Id,'', objContact.Account.Name, strAppearOn, '', false));
			}
		}
		
		return lstRW;
	}
	/* End */
	
	
	/*
		@MethodName : getContactIds 
		@param 	    : Sobject name, Engagement relation ship name, Engagement Id, Contact relationship name.
		@Description: method to get the contact ids from Engagement related records.
	*/
	private static Set<String> getContactIds(String strSobjectName, String strParentRelationship, 
											 String strParentId, String strContactRelationship, 
											 String strType, String strTypeValue)
	{
		Set<String> setContactId = new Set<String>();
		String strQuery = 'SELECT Id, ' + strContactRelationship + ' FROM '+ strSobjectName + ' WHERE ' + strParentRelationship + ' = \'' + strParentId +'\'';
		strQuery += (String.isNotBlank(strType) && String.isNotEmpty(strType) &&  String.isNotBlank(strTypeValue) && String.isNotEmpty(strTypeValue)) 
					? 'AND ' + strType + ' = \'' + strTypeValue + '\'' : '';
					
		for(Sobject sobj : Database.query(strQuery))
		{
			if(sobj.get(strContactRelationship) != null)
				setContactId.add(String.valueOf(sobj.get(strContactRelationship)));
		}
		return setContactId;
	}
	/* End */
	
	/*
		@MethodName : upsertRelationshipRecord 
		@param 	    : 
		@Description: method to upsert the relationship records.
	*/
	@RemoteAction
	public static String upsertRelationshipRecord(String strRelationshipId, String strHLContactId, String strContactId, String strStrengthScore, Boolean blnSyncOutlook)
	{
		Relationship__c objRelationShip = new Relationship__c(HL_Contact__c = strHLContactId,
															  External_Contact__c = strContactId, 
															  Strength_Rating__c = (strStrengthScore != 'none') ? strStrengthScore : '', 
															  Sync_to_Outlook__c = blnSyncOutlook);
															  
		if(strRelationshipId != '' && strRelationshipId != null)
			objRelationShip.Id = strRelationshipId;
			
		upsert 	objRelationShip;
		return objRelationShip.Id;
	} 	
	/* End */
	
	/*
		@MethodName : getPicklistValue 
		@param 	    : Sobject name and filed api name.
		@Description: method to get picklist value from field.
	*/
	private String getPicklistValue(String strSobjectName, String strFieldName)
	{
		List<SelectOption> options = new List<SelectOption>();
		Schema.SObjectType targetType = mapGlobalDescribe.get(strSobjectName);//!< From the Object Api name retrieving the SObject
    	Sobject Object_name = targetType.newSObject();
 		Schema.sObjectType sobject_type = Object_name.getSObjectType(); //!< grab the sobject that was passed
   		Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //!< describe the sobject
   		Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //!< get a map of fields for the passed sobject
   		List<Schema.PicklistEntry> pick_list_values = field_map.get(strFieldName).getDescribe().getPickListValues(); 
   														//!< grab the list of picklist values for the passed field on the sobject
   		String strPicklist = '';
    	for (Schema.PicklistEntry a : pick_list_values) 
    	{ 
    		strPicklist += (strPicklist == '') ? a.getValue():  ':' + a.getValue();
    	}
    	return strPicklist;
	}
	/* End */
	
	
	/*
		@MethodName : cancel 
		@param 	    : NA
		@Description: method will redirect to Engagement detail page.
	*/
	public Pagereference cancel()
	{
		return new Pagereference('/'+strEngagementId);
	}
	/* End */
}