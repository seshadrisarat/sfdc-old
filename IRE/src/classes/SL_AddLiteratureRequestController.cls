/**
* \arg ClassName      : SL_AddLiteratureRequestController
* \arg JIRATicket     : IRE-4
* \arg CreatedOn      : 4th/March/2015
* \arg LastModifiedOn : 25/March/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This class is used to insert literature request and related multiple literature request items.
*/
public with sharing class SL_AddLiteratureRequestController 
{
	/* Start - variables */
	public Contact objContact 										{	get;set;	}
	public Literature_Requests__c objLRequest 						{	get;set;	}
	public String strSelectedAddress 								{	get;set;	}
	public String strContactName									{	get;set;	}
	public String strCustomAddress 									{	get;set;	}
	public String strCustomCity 									{	get;set;	}
	public String strCustomState 									{	get;set;	}
	public String strCustomZip 										{	get;set;	}
	public List<LiteratureItemsWrapper> lstLiteratureItemsWrapper	{	get;set;	}
	public Integer rowIndex 										{	get;set;	}
	
	private Map<Id, Literature_Item__c> mapLitItemIdToLiteratureItem; 
	private String strURLId;
	private boolean isRedirect;
	private boolean isEditpage;
	/* End - variables */
	
	
	/* Start - SL_AddLiteratureRequestController Constructor */
	public SL_AddLiteratureRequestController(ApexPages.standardcontroller std)
	{ 
		strURLId = apexpages.currentpage().getparameters().containsKey('id') ? 
				   apexpages.currentpage().getparameters().get('id') :
				   apexpages.currentpage().getparameters().get('contactId');
		initialization();
	}
	/* End - SL_AddLiteratureRequestController Constructor */
	
	/*
     @InnerClassName: LiteratureItemsWrapper
     @param None
     @Description: Wrraper class to bind data
	*/
	public class LiteratureItemsWrapper
	{
		public Literature_Requested_Item__c objLiteratureItem		{	get;set;	}
		public boolean isDisplay 									{   get;set;	}
		public Boolean isSelected 									{	get;set;	}
		public Boolean isQtyEditable 								{	get;set;	}
		public String strSelectedLiteratureItemType 				{	get;set;	}
		public String strSelectedLiteratureItemId	 				{	get;set;	}
		public String strItemName					 				{	get;set;	}
		public List<SelectOption> lstItemName						{	get;set;	}
		
		/* Start - LiteratureItemsWrapper Constructor */
		public LiteratureItemsWrapper(Literature_Requested_Item__c objLiteratureItem, boolean isDisplay, 
									  Boolean isQtyEditable, String strSelectedLiteratureItemType, 
									  String strSelectedLiteratureItemId, String strItemName)
		{
			this.objLiteratureItem = objLiteratureItem;
			this.isDisplay = isDisplay;	
			this.isSelected = false;
			this.isQtyEditable = isQtyEditable; 
			this.strSelectedLiteratureItemType = strSelectedLiteratureItemType;
			this.strSelectedLiteratureItemId = strSelectedLiteratureItemId;
			this.strItemName = strItemName; 
			this.lstItemName = new List<SelectOption>{new SelectOption('','--None--')};
		}
		/* End - LiteratureItemsWrapper Constructor */
	}
	
	/*
     @MethodName: initialization
     @param: na
     @Description: to initialize variables
    */
    void initialization()
    {
    	isRedirect = false;
    	mapLitItemIdToLiteratureItem = new Map<Id, Literature_Item__c>();
    	lstLiteratureItemsWrapper = new List<LiteratureItemsWrapper>();
    	
    	if(strURLId.startsWith('003'))
		{	
			isEditpage = false;
			objContact = getContactDetail(strURLId);
			strContactName = objContact.Name;
			objLRequest = new Literature_Requests__c(Contact__c = objContact.Id, 
													 Recipient_Phone_Number__c = objContact.Phone, 
													 Status__c = 'New');
		}
		else
		{
			isEditpage = true;
			Literature_Requests__c objLitReq = [SELECT Id, 
													  Contact__c,
													  Contact__r.Name,
													  Send_By__c, 
													  Status__c, 
													  Delivery_Method__c, 
													  Print_Literature_Request_with__c,
													  Street__c,
													  City__c,
													  State_Province__c,
													  Zip_Postal_Code__c,
													  Description__c,
													  Recipient_Phone_Number__c
												 FROM Literature_Requests__c 
												WHERE Id =: strURLId];
												
			strCustomAddress = objLitReq.Street__c;
			strCustomCity = objLitReq.City__c;
			strCustomState = objLitReq.State_Province__c;
			strCustomZip = objLitReq.Zip_Postal_Code__c;
			strContactName = objLitReq.Contact__r.Name;
			
			objLRequest = objLitReq;
			objContact = getContactDetail(objLitReq.Contact__c);
		}
    	
    	fetchLitratureReqLineItems();
    	lstLiteratureItemsWrapper.add(new LiteratureItemsWrapper(new Literature_Requested_Item__c(), true, true, null, null, null));
    }
    
    /*
     @MethodName: getContactDetail
     @param: na
     @Description: 
    */
    private Contact getContactDetail(String strContactId)
    {
    	List<Contact> lstContact = [SELECT Id,
    								  	   Name,
    								   	   OtherStreet, 
	    								   OtherState, 
	    								   OtherPostalCode, 
	    								   OtherCity, 
	    								   MailingStreet, 
	    								   MailingState, 
	    								   MailingPostalCode, 
	    								   MailingCountry, 
	    								   MailingCity,
	    								   Phone
	    							  FROM Contact 
	    							 WHERE Id =: strContactId LIMIT 1];
    	
    	return (lstContact.isEmpty() ? new Contact() : lstContact[0]);
    }
    
    /*
     @MethodName: saveLitratureReqAndItems
     @param: na
     @Description: This method is used to save litrature request and related Literature request items records. 
    */
    public PageReference saveLitratureReqAndItems()
    {
    	try
    	{
            for(Integer i=0; i < lstLiteratureItemsWrapper.size(); i++)
            {
                if (lstLiteratureItemsWrapper[i].objLiteratureItem.Quantity__c <=0 || lstLiteratureItemsWrapper[i].objLiteratureItem.Quantity__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'All requested items must have a quantity that is not blank and greater than 0.'));
                    return null;
                }
            }
            if (lstLiteratureItemsWrapper.size() < 1){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Must select items for literature request.'));
                return null;
            }
	    	for(LiteratureItemsWrapper objWrapper : lstLiteratureItemsWrapper)
			{
				objWrapper.isDisplay = false;
			}
	    	
	    	if(strSelectedAddress == 'other')
	    	{
	    		isRedirect = true;
	    		objLRequest.Street__c = objContact.OtherStreet;
	    		objLRequest.City__c = objContact.OtherCity;
	    		objLRequest.State_Province__c = objContact.OtherState;  
	    		objLRequest.Zip_Postal_Code__c = objContact.OtherPostalCode;
	    		objLRequest.Contact_Name__c = objContact.Name;
	    	}
	    	else if(strSelectedAddress == 'custom')
	    	{
	    		if(strCustomAddress == '' || strCustomAddress == null || strCustomCity == '' || strCustomCity == null || strCustomState == '' || strCustomState == null || 
	    		   strCustomZip == '' || strCustomZip == null)
	    		{	
	    			isRedirect = false;
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Custom address fields can'+'\'' +'t be empty.'));
	    		}
	    		else
	    		{
	    			isRedirect = true;
	    			objLRequest.Street__c = strCustomAddress;
	    			objLRequest.City__c = strCustomCity;
		    		objLRequest.State_Province__c = strCustomState;
		    		objLRequest.Zip_Postal_Code__c = strCustomZip;
		    		objLRequest.Contact_Name__c = strContactName;
	    		}
	    	}
	    	else 
	    	{
	    		isRedirect = true;
	    		objLRequest.Street__c =  objContact.MailingStreet;
	    		objLRequest.City__c = objContact.MailingCity;
	    		objLRequest.State_Province__c = objContact.MailingState;
	    		objLRequest.Zip_Postal_Code__c = objContact.MailingPostalCode;
	    		objLRequest.Contact_Name__c = objContact.Name;
	    	}
	    		
			database.upsert(objLRequest);
	    	
	    	if(objLRequest !=null)
	    	{
	    		List<Literature_Requested_Item__c> lstLiteratureItemRequestedToSave= new List<Literature_Requested_Item__c>();
				
				
				String strAccountId = [SELECT AccountId 
										 FROM Contact 
										WHERE ID =: objContact.Id LIMIT 1].AccountId;
				
				List<Due_Diligence__c> lstDueDiligence = [ SELECT Id, 
																  Fund__c, 
																  Account__c, 
																  Received_Approval__c 
														     FROM Due_Diligence__c 
														    WHERE Account__c =: strAccountId 
														      AND Received_Approval__c = true]; 
														     
				Set<Id> setFundLookupIds = new Set<Id>();
				
				for(Due_Diligence__c objDueDiligence : lstDueDiligence)
				{
					if(objDueDiligence.Fund__c != null)
						setFundLookupIds.add(objDueDiligence.Fund__c);
				}
				
				
	    		for(Integer i=0; i < lstLiteratureItemsWrapper.size(); i++)
				{
					if(lstLiteratureItemsWrapper[i].strSelectedLiteratureItemId == null || lstLiteratureItemsWrapper[i].strSelectedLiteratureItemId == '')
					{
						lstLiteratureItemsWrapper[i].isDisplay = true;
						isRedirect = false;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select an item from pick list to save.'));
					}
					
					Literature_Requested_Item__c objLiteratureItemRequested	= new Literature_Requested_Item__c(id = lstLiteratureItemsWrapper[i].objLiteratureItem.Id, 
																			  Literature_Item__c = lstLiteratureItemsWrapper[i].strSelectedLiteratureItemId, 
																			  Literature_Request__c = objLRequest.Id,
																			  Investor__c = lstLiteratureItemsWrapper[i].objLiteratureItem.Investor__c, 
																			  Quantity__c = lstLiteratureItemsWrapper[i].objLiteratureItem.Quantity__c); 
					
					// Commenting out the section checking for the selling agreement
					//if(mapLitItemIdToLiteratureItem.get(lstLiteratureItemsWrapper[i].strSelectedLiteratureItemId)!= null 
					//   && setFundLookupIds.contains(mapLitItemIdToLiteratureItem.get(lstLiteratureItemsWrapper[i].strSelectedLiteratureItemId).Fund__c))   
					//{
						if(mapLitItemIdToLiteratureItem.get(lstLiteratureItemsWrapper[i].strSelectedLiteratureItemId).PPM__c == true && 
						   (objLiteratureItemRequested.Investor__c == '' || objLiteratureItemRequested.Investor__c == null))
						{
							lstLiteratureItemsWrapper[i].isDisplay = true;
							isRedirect = false;
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An item you selected was PPM. You must enter an investor and the quantity must be 1.'));
							break;	
						}
						
						lstLiteratureItemRequestedToSave.add(objLiteratureItemRequested);
						lstLiteratureItemsWrapper[i].objLiteratureItem = objLiteratureItemRequested;
					//}
					//else
					//{
					//	isRedirect = false;
					//	lstLiteratureItemsWrapper[i].isDisplay = true;
						
					//	if(mapLitItemIdToLiteratureItem.containskey(lstLiteratureItemsWrapper[i].strSelectedLiteratureItemId))
					//	{
					//		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, mapLitItemIdToLiteratureItem.get(lstLiteratureItemsWrapper[i].strSelectedLiteratureItemId).Name + 
					//		' can' + '\'' + 't' + ' be sent because no selling agreement exists with the Contact.'));
					//	}	
					//}
				}
				
	    		if(!lstLiteratureItemRequestedToSave.isEmpty())
	    		{
					Database.upsert(lstLiteratureItemRequestedToSave, false);
					
					for(Integer i=0; i < lstLiteratureItemsWrapper.size(); i++)
					{
						if(lstLiteratureItemsWrapper[i].objLiteratureItem.Id == null)
						{
							lstLiteratureItemsWrapper[i].isDisplay = true;
							isRedirect = false;
						}
					}
					
	    		}	
	    	}
	    	
	    	if(isRedirect)
	    	{
	    		PageReference pageRef = new PageReference(String.valueof(URL.getSalesforceBaseUrl().toExternalForm()) + '/'+strURLId);
				pageRef.setRedirect(true);
				return pageRef;
	    	}
	    	return null;
	    }	
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;	
		}	
    }
    
    /*
     @MethodName: getLiteratureItemsDetails
     @param: None
     @Description: This method is used to get the details of selected Literature Items
	*/
    public void getLiteratureItemsDetails()
    {
    	try
    	{
    		String selectedItemId; 
    		
    		if(rowIndex!=null)
	    		selectedItemId = lstLiteratureItemsWrapper[rowIndex].strSelectedLiteratureItemId;
    		
	    	List<Literature_Item__c> lstLiteratureItem = [SELECT Id,
			    												  Name,	 
			    												  Type__c, 
			    												  Fund__c, 
			    												  PPM__c 
			    										     FROM Literature_Item__c 
			    										    WHERE Id =: selectedItemId 
			    										    ORDER BY Name LIMIT 1];
	
	    	for(Literature_Item__c objLitItem : lstLiteratureItem)
	    	{
	    		lstLiteratureItemsWrapper[rowIndex].strItemName = objLitItem.Name;
	    		
	    		if(Boolean.valueOf(objLitItem.PPM__c) == true)
	    			lstLiteratureItemsWrapper[rowIndex].objLiteratureItem.Quantity__c = 1;
				else
					lstLiteratureItemsWrapper[rowIndex].objLiteratureItem.Quantity__c = null;
				
				mapLitItemIdToLiteratureItem.put(objLitItem.Id,objLitItem);
	    	}
			rowIndex = null;
		}	
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));	
		}	
    }
    
    /*
     @MethodName: addLiteratureRequestItems
     @param: None
     @Description: This method is  used to add new empty row
	*/
	public void addLiteratureRequestItems()
	{
		lstLiteratureItemsWrapper.add(new LiteratureItemsWrapper(new Literature_Requested_Item__c(), true, true, null, null, null));
	}
	/* End of addNewNRIDoc method */
	
	/*
     @MethodName: removeLiteratureRequestItems
     @param: None
     @Description: This method is used to remove Literature Request Items
	*/
	public void removeLiteratureRequestItems()
	{
		try
		{
			List<Literature_Requested_Item__c> lstLiteratureItemRequestedToDelete = new List<Literature_Requested_Item__c>();
			
			if(!lstLiteratureItemsWrapper.isEmpty())
			{
				for(Integer i=0; i < lstLiteratureItemsWrapper.size(); i++)
            	{
					if(lstLiteratureItemsWrapper[i].isSelected == true)
					{
						if(lstLiteratureItemsWrapper[i].objLiteratureItem.Id != null)
							lstLiteratureItemRequestedToDelete.add(lstLiteratureItemsWrapper[i].objLiteratureItem);
						
						lstLiteratureItemsWrapper.remove(i);
						i = i-1;
					}	
				}
				
				if(!lstLiteratureItemRequestedToDelete.isEmpty())
					delete 	lstLiteratureItemRequestedToDelete;
			}
			else
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No literature items to remove.'));
		}	
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));	
		}	
	}
	
	/*
     @MethodName: fetchLitratureReqLineItems
     @param: na
     @Description: This method is used to display Literature items records on edit page. 
    */
    public void  fetchLitratureReqLineItems()
    {
    	lstLiteratureItemsWrapper = new List<LiteratureItemsWrapper>();
    	
    	Set<Id> setLiteratureItemId = new Set<Id>();
    	try
    	{
	    	for(Literature_Requested_Item__c objLitItemsRequest : [ SELECT Id, 
	    																   Literature_Item__c, 
	    																   Literature_Item__r.Type__c,
	    																   Literature_Item__r.Name,  
	    																   Literature_Request__c, 
	    																   Quantity__c,
	    																   Investor__c 
	    															  FROM Literature_Requested_Item__c 
	    															 WHERE Literature_Request__c =: objLRequest.Id
	    															 ORDER BY Literature_Item__r.Name])
	    	{
	    		if(isEditpage == true )
					lstLiteratureItemsWrapper.add(new LiteratureItemsWrapper(objLitItemsRequest, false, true, objLitItemsRequest.Literature_Item__r.Type__c, objLitItemsRequest.Literature_Item__c, objLitItemsRequest.Literature_Item__r.Name));
	    		else
					lstLiteratureItemsWrapper.add(new LiteratureItemsWrapper(objLitItemsRequest, false, false, objLitItemsRequest.Literature_Item__r.Type__c, objLitItemsRequest.Literature_Item__c, objLitItemsRequest.Literature_Item__r.Name));
	    		
	    		if(objLitItemsRequest.Id != null)
		    		setLiteratureItemId.add(objLitItemsRequest.Literature_Item__c);
	    	}
	    	
	    	if(!setLiteratureItemId.isEmpty())
	    	{
	    		for(Literature_Item__c objLitItems : [SELECT Id,
		    												  Name,	 
		    												  Type__c, 
		    												  Fund__c, 
		    												  PPM__c 
		    										     FROM Literature_Item__c 
		    										    WHERE Id IN : setLiteratureItemId
		    										    ORDER BY Name])
		    	{
		    		mapLitItemIdToLiteratureItem.put(objLitItems.Id, objLitItems);
		    	}									    
	    	}
    	}
    	catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));	
		}	
    }
    
    /*
     @MethodName: getPicklistValues
     @param: sObject API Name and Field API Name
     @Description: This method is used to get picklist values from describe calls
    */
	private static List<SelectOption> getPicklistValues(String strObjectAPIName, String strFieldNameAPIName)
	{
		try
		{
			List<SelectOption> options = new List<SelectOption>();
			Schema.SObjectType targetType = Schema.getGlobalDescribe().get(strObjectAPIName);//From the Object Api name retrieving the SObject
			Sobject Object_name = targetType.newSObject();
			
			Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
			Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
			
			Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
			
			List<Schema.PicklistEntry> pick_list_values = field_map.get(strFieldNameAPIName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
			
			options.add(new SelectOption('','--None--'));
			
			for (Schema.PicklistEntry f : pick_list_values)  //for all values in the picklist list
			{
				options.add(new SelectOption(f.getLabel(), f.getValue()));			      
			}
			
			return options;
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}	
	}
	
	/*
     @MethodName: getLiteratureItemTypeValues
     @param: NA
     @Description: This method is used to get picklist values for LiteratureItemType
    */
    public static List<SelectOption> getLiteratureItemTypeValues()
    {
	    List<SelectOption> lstItemType = getPicklistValues('Literature_Item__c','Type__c'); 
		return lstItemType;
    }
   
	/*
     @MethodName: updateItems
     @param: NA
     @Description: This method is used to update list of items name in Item picklist
    */
    public void updateItems()
	{
    	try
    	{
	    	if(rowIndex!=null)
	    	{
	    		String selectedItemType = lstLiteratureItemsWrapper[rowIndex].strSelectedLiteratureItemType;
	    		List<SelectOption> lstItemName = new List<SelectOption>();
	    		
	    		lstItemName.add(new SelectOption('','--None--'));
	    		for(Literature_Item__c objLitItems : [SELECT Id,
		    												  Name,	 
		    												  Type__c, 
		    												  Fund__c, 
		    												  PPM__c 
		    										     FROM Literature_Item__c 
		    										    WHERE Type__c =: selectedItemType 
		    										    ORDER BY Name LIMIT 999])
		    	{
		    		lstItemName.add(new SelectOption(objLitItems.Id, objLitItems.Name));
		    	}
		    	
		    	lstLiteratureItemsWrapper[rowIndex].lstItemName = lstItemName;
	    	}
	    	rowIndex = null;
    	}
    	catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}	
	}
    
}