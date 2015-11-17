/**
* @ClassName    : SL_BusinessAddressAssociationController   
* @JIRATicket   : SEGAL-6
* @CreatedOn    : 15/Jan/2015
* @ModifiedBy   : Pradeep
*/                       

public with sharing class SL_BusinessAddressAssociationController extends SL_Paginator
{
	private Id ContactId;
	public string strEntityId 						    { get;set;}
	private String strQuery = '';     // Variable used to store fields present in fiedset
	private String strContactAddressQuery = '';     // Variable used to store fields present in fiedset
	private String strQueryString = '';  
	//public String strSearchText   {get;set;}  // Variable used to store Search text.
	public String strSelectedTab   {get;set;}
	private map<Id,Boolean> mapAddrIdToPrimaryOrNot;
	private static final String Contact_Address_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Address__c' AND DeveloperName = 'Contact_Address'].Id;
	private static final String Entity_Address_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Address__c' AND DeveloperName = 'Entity_Address'].Id;
	private static final Integer PAGE_SIZE = 5;
	public Address__c objAddress {get;set;}
	public boolean isAddressSelected  				{get;set;}
	public boolean isSuccessfullSave  				{get;set;}
	public boolean isPrimaryContactAddressExists    {get;set;}
	public String strPrimaryContactAddressId        {get;set;}  
	public String strSaveOrSaveNew    			 {get;set;}
	private Integer intRowIndex;
	public Integer intPrimaryAddressRowIndex     {get;set;}
	public Integer intSaveOrCancelAddressIndex   {get;set;}
	public String strAddressIdToRemove           {get;set;}
	public String strContactAddressIdToRemove    {get;set;}
	public String strEntityName                  {get;set;}
	public String strUpdatedPrimaryAddressId     {get;set;}      
	public list<AddressWrapper> lstBusinessAddrAssociatedWithContactEntity {get;set;}
	public list<ContactAddressWrapper> lstContactAddrAssociatedWithContact {get;set;}
	private map<Id,Address__c> mapAddressOfContactAddress ;  
	private map<Id,Contact_Address__c> mapAddressIdToContactAddressAssociation ;
	public Boolean isPrimaryAddressUpdated               {get;set;}
	private String strDefaultCountry;
	
	// Constructor
	public SL_BusinessAddressAssociationController(ApexPages.StandardController controller)
	{
		try
		{
			initialize();
			ContactId = controller.getId(); // Getting the Current Contact record from where page is launched.
			Contact objContact = [Select AccountId,Account.Name from Contact where Id=:ContactId];// Querying Contact's Entity(Account)
			strEntityId = objContact.AccountId;
			strEntityName = objContact.Account.Name;
			
			// Querying Default Country for Contact Address 
			for(SL_DefaultCountryForContactAddress__c objDC : SL_DefaultCountryForContactAddress__c.getall().values())	 	
			{
				strDefaultCountry = objDC.Name;
				break;
			}
			
			objAddress = new Address__c(RecordTypeId = Contact_Address_RECORDTYPE_ID,Contact__c=ContactId,Country__c = strDefaultCountry);
			lstBusinessAddrAssociatedWithContactEntity = queryBusinessAddressForContactEntity(); // Querying Business Addresses of 'Contact Address' recordtype for Contact's Entity
			lstContactAddrAssociatedWithContact = queryContactAddressesForContact();
			initPagination();
		}	
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));  
		}
	}
	
	/*
       @ClassName : AddressWrapper
   	   @Description: Wrapper class to bind checkbox for selection of Business addresses to associate with contact.
   */
    public class AddressWrapper
	{
		public Address__c objAddress    		 { get; set; }
		public Boolean isSelected        		 { get; set; } 
		public Boolean isSelectionEnabled        { get; set; } 
		public Integer intRowIndex               { get; set; } 

		public AddressWrapper(Address__c objAddress,Boolean isSelected,Boolean isSelectionEnabled,Integer intRowIndex)
		{
			this.objAddress = objAddress;
			this.isSelected = isSelected;
			this.isSelectionEnabled = isSelectionEnabled;
			this.intRowIndex = intRowIndex;
		}
	}
	
	/*
       @ClassName  : ContactAddressWrapper
   	   @Description: Wrapper class to bind edit and delete links to Contact Address Associations.
    */
   
	public class ContactAddressWrapper
	{
		public Address__c objAddress  	  		 { get; set; }
		public Integer intRowIndex               { get; set; }
		public Id idContactAddress               { get; set; }
		public Boolean isEditRecord              { get; set; }
		public Boolean isSaveRecord              { get; set; }
		public Boolean isCancelRecord            { get; set; }
		public Boolean isEditToBeDisplayed       { get; set; }
		public Boolean isPrimaryAddr             { get; set; }
		 
		public ContactAddressWrapper(Address__c objAddress,Boolean isPrimaryAddr,Integer intRowIndex,Id idContactAddress)
		{
			isEditRecord = true;
			isSaveRecord = false;
			isCancelRecord = false;
			isEditToBeDisplayed = false;
			this.isPrimaryAddr = isPrimaryAddr;
			this.objAddress = objAddress;
			this.intRowIndex = intRowIndex;
			this.idContactAddress = idContactAddress;

			if(objAddress.RecordTypeId == Contact_Address_RECORDTYPE_ID)
				isEditToBeDisplayed = true;
		}
	}
	
	/* 
      @MethodName: initialize
      @param: None
      @Description: Initializing all global variables
   */
     public void initialize()
     {
   		intRowIndex = 0;
   		objAddress = new Address__c();
   		isAddressSelected = false;
   		isPrimaryContactAddressExists = false;
   		isPrimaryAddressUpdated = false;
   		strPrimaryContactAddressId = '';
   		strSelectedTab= 'tab1';
   		strDefaultCountry = '';
   		lstBusinessAddrAssociatedWithContactEntity = new list<AddressWrapper>();
   		lstContactAddrAssociatedWithContact = new list<ContactAddressWrapper>();
   		mapAddrIdToPrimaryOrNot = new map<Id,Boolean>();
   		mapAddressOfContactAddress = new map<Id,Address__c>();
   		mapAddressIdToContactAddressAssociation = new map<Id,Contact_Address__c>();
     }
     
     /*!
      *  @MethodName: initPagination
      *  @param None: None.
      *  @Description: This method will initalize the variables which is required in pagination.
    */
    private void initPagination() 
    {
        page=1;//initally page is 1. 
        FirstPage = 0; //first page index is initially 0
        TotalRows = lstBusinessAddrAssociatedWithContactEntity.size();// total rows to be spanned across pages
        PageSize = PAGE_SIZE;// no. of rows you want to show per page
        LastPage = Math.mod(TotalRows, PageSize) == 0 ? TotalRows / PageSize : TotalRows / PageSize + 1;// calculate the index of last page
        noOfPages = Math.mod(TotalRows, PageSize) > 0 ? TotalRows / PageSize + 1 : TotalRows / PageSize;
    }
	
	/*
      @MethodName: queryBusinessAddressForContactEntity
      @Description: Method used to Query Business Addresses of 'Contact Address' recordtype for Contact's Entity(Account)
   */
   
	private list<AddressWrapper> queryBusinessAddressForContactEntity()
	{
		List<AddressWrapper> lstQueriedAddressesForContactEntity = new List<AddressWrapper>();
		try
		{
			// Creating string with fields present in fieldset
			strQuery = formingQueryWithFieldsPresentInFieldSet('Address__c','SL_AddressFieldsToDisplay');
			strQueryString = '';
			mapAddrIdToPrimaryOrNot = new map<Id,Boolean>();
			
			// Querying Address records for contact's Entity
			if(!String.isEmpty(strQuery))
	    		strQueryString = 'Select Name,' + strQuery + ' from Address__c where Entity__c =:strEntityId AND RecordTypeId =:Entity_Address_RECORDTYPE_ID' ;
    		else 
    			strQueryString = 'Select Name,Entity__c	 from Address__c where Entity__c =:strEntityId AND RecordTypeId =:Entity_Address_RECORDTYPE_ID' ;
    			
    		// Querying contact Addresses for contact.	
    		for(Contact_Address__c objCA : [Select Address__c,Contact__c,Default_Contact_Address__c
	    		     						from Contact_Address__c
	    									where Address__c != null AND Contact__c =:ContactId])
	    	{
				mapAddrIdToPrimaryOrNot.put(objCA.Address__c,objCA.Default_Contact_Address__c);	
	    	}		
	    		
	    	lstQueriedAddressesForContactEntity = createWrapperClassInstancesforQueriedRecords(Database.Query(strQueryString));	
		}
		
    	catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage())); 
		}	
		
		return lstQueriedAddressesForContactEntity;
	}
	
	/*
      @MethodName: queryContactAddressesForContact
      @Description: Method used to Query Contact Addresses Associations for contact.
   */
   
	private list<ContactAddressWrapper> queryContactAddressesForContact()
	{
		try
		{
			// Creating string with fields present in fieldset 
			strContactAddressQuery = formingQueryWithFieldsPresentInFieldSet('Address__c','SL_AddressFieldsToDisplayInContactAddres');
			String strQueryContactAddress = '';
			list<ContactAddressWrapper> lstQueriedContactAddresses = new list<ContactAddressWrapper>();
			Integer rowIndex = 0;
			isPrimaryContactAddressExists = false;
			strPrimaryContactAddressId = '';
			set<Id> setAddressIds = new set<Id>();
			mapAddrIdToPrimaryOrNot = new map<Id,Boolean>();
							
			// Querying contact Address Associations for contact.				
			for(Contact_Address__c objCA : Database.Query('Select Name,Address__c,Default_Contact_Address__c from Contact_Address__c where Contact__c =:ContactId AND Address__c != null')) 
	    	{
	    		setAddressIds.add(objCA.Address__c);
	    	}	
	    	
	    	// Creating dynamic Query for Contact Addresses 
			if(!String.isEmpty(strContactAddressQuery))
		    	strQueryContactAddress = 'Select Name,Entity__r.Name,RecordType.DeveloperName,' + strContactAddressQuery + ' from Address__c where Id IN:setAddressIds' ;
			else 
				strQueryContactAddress = 'Select Name,Entity__r.Name,RecordType.DeveloperName, from Address__c where Id IN:setAddressIds' ;
	    	
	    	// Querying Contact Addresses related to contact to display in 'Contact Address Associations' tab.
	    	for(Address__c objAddress : Database.Query(strQueryContactAddress))
	    	{
	    		mapAddressOfContactAddress.put(objAddress.Id,objAddress);
	    	}
				
			// Querying Contact Addresses Associations related to contact to bind edit and delete links to contact Addresses.
			for(Contact_Address__c objCA : Database.Query('Select Name,Address__c,Default_Contact_Address__c from Contact_Address__c where Contact__c =:ContactId AND Address__c != null')) 
	    	{
	    		if(objCA.Default_Contact_Address__c)
	    		{
	    			strPrimaryContactAddressId = objCA.Address__c;
	    			isPrimaryContactAddressExists = true;
	    		}	
	    		mapAddressIdToContactAddressAssociation.put(objCA.Address__c,objCA);
	    		mapAddrIdToPrimaryOrNot.put(objCA.Address__c,objCA.Default_Contact_Address__c);
	    			
	    		rowIndex += 1;
	    		lstQueriedContactAddresses.add(new ContactAddressWrapper(mapAddressOfContactAddress.get(objCA.Address__c),objCA.Default_Contact_Address__c,rowIndex,objCA.Id));
	    	}
	    	return lstQueriedContactAddresses;
		}
    	
    	catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
		}
	}
	
	// Method used to create wrapper class instances for Queried address records
	private list<AddressWrapper> createWrapperClassInstancesforQueriedRecords(list<Address__c> lstAddressRecords)
	{
		List<AddressWrapper> lstQueriedAddressesForContactEntity = new List<AddressWrapper>();
		try
		{
			lstBusinessAddrAssociatedWithContactEntity = new list<AddressWrapper>();
	    	intRowIndex = 0;
	    	
	    	// Iterating through address records
			for(Address__c objAddr : lstAddressRecords)
			{
				Boolean isSelectionEnabled = mapAddrIdToPrimaryOrNot.containsKey(objAddr.Id) ? false : true;
	    		
	    		intRowIndex += 1;	
	    		//Add the fetched records to the list  
	    		lstQueriedAddressesForContactEntity.add(new AddressWrapper(objAddr,false,isSelectionEnabled,intRowIndex)); // Creating Wrapper class Instance for Address record.
			}
		}
		
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
		}
		
		return lstQueriedAddressesForContactEntity;
	}
	
	/*
        @Method-Name  : formingQueryWithFieldsPresentInFieldSet
        @Description  : This method is used for forming dynamic query for Business Address based on fields present in fieldsets
    */ 
   
    private string formingQueryWithFieldsPresentInFieldSet(String sobjName,String strfieldSetName )
    {
    	String strfieldSetQuery = '';
    	try
    	{
    		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
    		Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sobjName);
        	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
       
        	// to get description of fieldsets
       	    Schema.FieldSet fieldSetObjForAddress  = DescribeSObjectResultObj.FieldSets.getMap().get(strfieldSetName);
       	    
       	    for(Schema.FieldSetMember fieldSet : fieldSetObjForAddress.getFields())
            {
            	if(fieldSet.getFieldPath() != 'Name')
            		strfieldSetQuery += strfieldSetQuery == '' ? fieldSet.getFieldPath() : ', ' + fieldSet.getFieldPath();
            }
    	}
    	
    	catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
		}
		return strfieldSetQuery;
    }
    
    /*
        @Method-Name  : searchAddresses
        @Description  : This method is used for Searching Addresses based on Selected Entity in 'Entity Search' tab.
    */ 
      
    public void searchAddresses()  
    { 
    	try
    	{
    		lstBusinessAddrAssociatedWithContactEntity = new list<AddressWrapper>();
    		
    		// Querying addresses for selected entity in 'Entity Search' tab.
	    	if(!String.isEmpty(strEntityId) && !String.isEmpty(strEntityName))
	    	{
	    		String strQuerString = 'Select Name,' + strQuery + ' from Address__c where Entity__c =:strEntityId AND RecordTypeId =:Entity_Address_RECORDTYPE_ID ';
	    		lstBusinessAddrAssociatedWithContactEntity = createWrapperClassInstancesforQueriedRecords(Database.Query(strQuerString));
	    	}  
			initPagination();    	
    	}
    	
    	catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		} 
    }
    
     /*  
        @Method-Name  : createContactAddressAssociation
        @Description  : This method is used for Creating Contact Addresses Associations for selected addresses in 'Entity Search' tab. 
    */ 
    public void createContactAddressAssociation()  
    { 
    	try
    	{
    		list<Contact_Address__c> lstCAToInsert = new list<Contact_Address__c>();
    		isAddressSelected = false;   // To check whether any address is selected or not.
    		isSuccessfullSave = true;   
    	
	    	for(AddressWrapper objAddressWrapper: lstBusinessAddrAssociatedWithContactEntity)
	    	{
	    		// Checking if address is selected
	    		if(objAddressWrapper.isSelected)
	    		{
	    			isAddressSelected = true;
	    			
	    			// Creating contact Address for selected address
	    			Contact_Address__c objConAddr = new Contact_Address__c(Contact__c = ContactId,Address__c = objAddressWrapper.objAddress.Id,Default_Contact_Address__c = false );
	    			lstCAToInsert.add(objConAddr);
	    			
	    			// Disabling option to select once contact address is created to avoid duplicates
	    			objAddressWrapper.isSelected = false;
	    			objAddressWrapper.isSelectionEnabled = false;
	    		}
	    	}
	    	
	    	// Inserting Contact Address Associations for selected addresses
	    	if(!lstCAToInsert.isEmpty())
	    		Database.insert(lstCAToInsert,false);
	    		
	    	// Querying Contact Addresses for contact 	
	    	lstContactAddrAssociatedWithContact = queryContactAddressesForContact();	
	    		
	    	// Redirecting to Contact Address Association tab onClick of save.	
	    	if(isAddressSelected)	
	    		strSelectedTab = 'tab1';	
	    }
	    catch(Exception ex)
		{
			isSuccessfullSave = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}    
    }
    
    // This method is called onclick of Save and Save & New button in 'New Address' tab to create address record for contact's Entity
    public void saveAddress()
    {
    	try
    	{
    		isSuccessfullSave = false;
    		//Inserting new Address
    		insert objAddress;
    		
    		Boolean isPrimaryAddress = false;
    		
    		// Checking if there is no contact Address association for contact then making the newly inserted Contact Address association as Primary.
    		if(mapAddrIdToPrimaryOrNot.isEmpty())
    			isPrimaryAddress = true;
    			
    		// Updating contact Address as primary address if there are no Contact address associations exists before.	
    		if(isPrimaryAddress)	
    		{
	    		Contact_Address__c objContactAddress = [ Select Contact__c,Address__c,Default_Contact_Address__c
	    												 from Contact_Address__c
	    												 where Address__c =: objAddress.Id AND Contact__c =: ContactId limit 1];
	    		objContactAddress.Default_Contact_Address__c = true;
	    		update objContactAddress;								 
    		}
    		
    		lstContactAddrAssociatedWithContact = queryContactAddressesForContact();
    		
    		objAddress = new Address__c(RecordTypeId = Contact_Address_RECORDTYPE_ID,Contact__c=ContactId,Country__c = strDefaultCountry);
    	   		
    	   	isSuccessfullSave = true;
    	   	initPagination();	
    	}	
    	catch(Exception e)
    	{
    		strSelectedTab = 'tab2';
    		isSuccessfullSave = false;
    	}
    }
    
    /*
		@Method Name	: saveUpdatedAddressRecord
		@Description	: This method saves the particular updated Address record on which save link is clicked in 'Contact Address Association' tab.
	*/
    
    public void saveUpdatedAddressRecord()
    {
    	try
    	{
    		if(intSaveOrCancelAddressIndex != null)
    		{
    			sObject objAddrOrConAddr;
    			
    			// Getting the object from list on which save link is checked.
    			objAddrOrConAddr = lstContactAddrAssociatedWithContact[intSaveOrCancelAddressIndex - 1].objAddress;
    			
    			if(objAddrOrConAddr != null)
    			{
    				update objAddrOrConAddr; // Updating Address record.
    				lstContactAddrAssociatedWithContact = queryContactAddressesForContact(); 
    				lstContactAddrAssociatedWithContact[intSaveOrCancelAddressIndex - 1].isEditRecord = true; // Keeping Address record in read only mode once address record is updated.
    			}	
    			
    			if(lstContactAddrAssociatedWithContact[intSaveOrCancelAddressIndex - 1].isPrimaryAddr)
    			{
    				isPrimaryAddressUpdated = true;
    			}	
    				
	    		intSaveOrCancelAddressIndex = null;
    		}	
    	}
    	catch(Exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return;				
    	}
    }
    
    /*
		@Method Name	: cancelUpdatedAddressRecord
		@Description	: This method cancels the changes made to updated Contact Address Association record on which cancel link is clicked.
	*/
    public void cancelUpdatedAddressRecord()
    {
    	try
    	{
    		// Used to store the Queried Address
    		list<sObject> lstCanceledAddress = new list<sObject>();
    		
			if(intSaveOrCancelAddressIndex != null)
			{
				Id objAddressCancelled;
				String strAddrQuery;
				
				// Getting the Id of address record on which cancel link is clicked..
				objAddressCancelled = lstContactAddrAssociatedWithContact[intSaveOrCancelAddressIndex - 1].objAddress.Id; 
				strAddrQuery = strContactAddressQuery;
				
				if(strAddrQuery != null && objAddressCancelled != null)
				{
					// Querying cancelled address record to display original field values.
					lstCanceledAddress = Database.query('Select Name,Entity__r.Name,RecordType.DeveloperName,'+ strAddrQuery + ' from Address__c where Id =:objAddressCancelled');
					
					if(!lstCanceledAddress.isEmpty())
					{
						// Assigning the original address from database to the address on which cancel link is clicked
						lstContactAddrAssociatedWithContact[intSaveOrCancelAddressIndex - 1].objAddress = (Address__c)lstCanceledAddress[0];
					}	
				}
				intSaveOrCancelAddressIndex = null;
			}		    		
    	}
    	catch(Exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return;				
    	}
    }
    
    /*
		@Method Name	: deleteAddress
		@Description	: Method used to delete Contact Address record on which delete link is clicked in 'Contact Address Associations' tab.
	*/
    public void deleteAddress()
    {
    	try
    	{
    		if(!String.isEmpty(strAddressIdToRemove) && !String.isEmpty(strContactAddressIdToRemove))
    		{
    			// deleting Contact Address record 
    			delete new Contact_Address__c(Id = strContactAddressIdToRemove);
	    		lstContactAddrAssociatedWithContact = queryContactAddressesForContact();
	    		
	    		if(mapAddressOfContactAddress.containsKey(strAddressIdToRemove))		
	    		{
	    			Address__c objAddress = mapAddressOfContactAddress.get(strAddressIdToRemove);
	    			
	    			// Deleting address on contact address association if address is of 'Contact Address' type.
	    			if(objAddress.RecordTypeId == Contact_Address_RECORDTYPE_ID)
	    				delete new Address__c(id=strAddressIdToRemove);
	    		}  
    		}
    		
    		lstBusinessAddrAssociatedWithContactEntity = queryBusinessAddressForContactEntity(); // Querying Business Addresses of 'Contact Address' recordtype for Contact's Entity
    		initPagination();
    	}
    	catch(Exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return;				
    	}
    }
    
     /*
		@Method Name	: updatedPrimaryContactAddress
		@Description	: Method used to update Primary Contact address for contact.
	*/
	
    public void updatedPrimaryContactAddress()
    {
    	try
    	{
    		if(!String.isEmpty(strUpdatedPrimaryAddressId) && mapAddressIdToContactAddressAssociation.containsKey(strUpdatedPrimaryAddressId))
    		{
    			Contact_Address__c objCA = mapAddressIdToContactAddressAssociation.get(strUpdatedPrimaryAddressId);
    			objCA.Default_Contact_Address__c = true;
    			update objCA;
    			
    			strPrimaryContactAddressId = objCA.Address__c;
    		}
    	}
    	catch(Exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return;				
    	}
    }
}