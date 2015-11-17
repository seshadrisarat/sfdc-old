/**
 
* \date 2ng August 2011
 
* \see http://silverline.jira.com/browse/stonePII-16
* \see http://silverline.jira.com/browse/STONEPII-10

last Modified on 
* \date 24th April 2013
 
* \see http://silverline.jira.com/browse/stonePII-114
*/ 

public without sharing class SL_Property_Trigger_Handler 
{
    private Boolean m_isExecuting = false;
    private Integer Batchsize = 0;
    private static final Id CaseRecordTypeId = [Select Id from RecordType where sObjectType='Case' and Name='Legal Process'].Id;
    set<Id> setPropertyIds = new set<Id>();
	set<Id> setPropIds = new set<Id>();
	set<Id> setProprIds = new set<Id>();
	set<Id> setOpportunityIds = new set<Id>();
	Map<Id, Id> mapCaseProperty = new Map<Id, Id>();
	List<Current_Tenant__c> lstCurrentTenants = new List<Current_Tenant__c>();
	List<CaseContactRole> lstCaseContactRoles = new List<CaseContactRole>();
	List<Case> lstCase = new List<Case>();
	
    
    /**
     \Start Constructor   
    
    * \Name        : SL_Property_Trigger_Handler
    
    * \Parameters  : isExecuting,size
    
    */
    
    public SL_Property_Trigger_Handler(Boolean isExecuting, Integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /**
    
    * \Start Method 
    
    * \Name         : onAfterUpdate
    
    * \Parameters   : List<Property__c>
    
    * \Description  : Perform Action after updation of a Property__c record
    
    */
    public void onAfterUpdate(Map<Id,Property__c> mapPropertyUpdatedNew, Map<Id,Property__c> mapPropertyUpdatedOld)
    {
    	try
    	{    	
    		List<Property__c> lstProperty = new List<Property__c>();
    		List<Property__c> lstOldProperty = new List<Property__c>();	
    		lstProperty.addAll(mapPropertyUpdatedNew.values());
    		lstOldProperty.addAll(mapPropertyUpdatedOld.values());
    		setPropIds = new set<Id>(); 
    		setProprIds = new set<Id>();
    		setPropertyIds = new set<Id>();
    		Set<Id> setPropertyIdToCreatePreviousTenant = new Set<Id>();
    		Set<Id> setContactCaseRoleIds = new Set<Id>();
	        List<Previous_Tenant__c> lstPreviousTenants = new List<Previous_Tenant__c>(); 
	        Map<Id, Id> mapOpportunityAccount = new Map<Id, Id>();
	        Map<Id,String> mapOldLegal = new Map<Id,String>();
	        List<Current_Tenant__c> lstCurrentTenantToCreate = new List<Current_Tenant__c>();
	        List<Current_Tenant__c> lstCurrentTenantToDelete = new List<Current_Tenant__c>();
	        Set<Id> setRequiredPropertyId = new Set<Id>();
	        Set<String> setPreviousTenants = new Set<String>();
	        
			// Storing the values of Old List in map for proper refering.
	        for(Property__c property : lstOldProperty)
	        {
	        	mapOldLegal.put(property.Id,property.Legal_Alert__c);
	        }
	        // Storing the Property ids in set.
	        for(Property__c property : lstProperty)
	        {
	        	setOpportunityIds.add(property.Id);
	        	
	        	///Create a set of property ids for which Move_Current_Tenants_to_Previous__c checkbox is checked
	        	if(!mapPropertyUpdatedOld.get(property.Id).Move_Current_Tenants_to_Previous__c && property.Move_Current_Tenants_to_Previous__c)
	        		setPropertyIdToCreatePreviousTenant.add(property.Id);
	        }
	        if(setOpportunityIds.size() > 0)
	        {
	        	lstProperty = [Select Opportunity__r.RecordType.Name, Opportunity__r.StageName, Opportunity__r.Reason_Lost__c, Opportunity__r.Account.PersonContactId, Opportunity__c, Legal_Alert__c, Id From Property__c where Id in : setOpportunityIds];
	        }
	        // To Map the Property object with Case
	        for(Property__c property : lstProperty)
	        {
	            setPropertyIds.add(property.Id);
	            /* creates a new case for update of property */
	            // checking the condition.
	            if((property.Legal_Alert__c != null || property.Legal_Alert__c != '') && (mapOldLegal.get(property.Id) == null || mapOldLegal.get(property.Id) == ''))
	            { 
	            	// Mapping the Case and Property Object
	            	Case objCase = new Case();
					objCase.RecordTypeId = CaseRecordTypeId; 
					if(property.Opportunity__c != null)
						objCase.Opportunity__c = property.Opportunity__c;
					//objCase.ContactId = property.Opportunity__r.Account.PersonContactId;
					objCase.Status = 'Late';
					objCase.Property_Lookup__c = property.Id; 
					objCase.Subject = 'Late Payment Case';
					// storing the object case to list for inserting
					lstCase.add(objCase);
					setPropIds.add(property.Id);
	            }
	            
				/* ******** Adding one more condition as per latest comment on STONEPII-114 ***************/
	           if(property.Opportunity__r.RecordType.Name == 'Renewal Opportunity' && property.Opportunity__r.StageName ==  'Closed Lost' && property.Opportunity__r.Reason_Lost__c == 'Roommate Change' )
	            	setProprIds.add(property.Id);
	            
	        } 
			/*Inserting Case Legal records*/
	        if(lstCase.size() > 0)
	        	insert lstCase; 
	        	
			// For getting the Current_Tenant__c related List 
			for(Case objCase : lstCase)
			{
				mapCaseProperty.put(objCase.Property_Lookup__c, objCase.Id);				
			}
			// Querying for the Current Tenants.
			if(setPropIds.size() > 0)
			{
				lstCurrentTenants = [Select Role__c, Contact__r.PersonContactId, Property__c From Current_Tenant__c where Property__c IN: setPropIds];
			}
			// Getting the Current Tenants to Case Contact Role	        
			for(Current_Tenant__c objCT : lstCurrentTenants)
	        {
	        	if(!setContactCaseRoleIds.contains(objCT.Contact__r.PersonContactId) && objCT.Contact__r.PersonContactId != null )
	        	{
		        	CaseContactRole objCCR = new CaseContactRole();
		        	objCCR.CasesId = mapCaseProperty.get(objCT.Property__c);
		        	objCCR.ContactId = objCT.Contact__r.PersonContactId;
		        	objCCR.Role = objCT.Role__c;
		        	lstCaseContactRoles.add(objCCR); 
		        	setContactCaseRoleIds.add(objCT.Contact__r.PersonContactId);
	        	}
	        } 
	        
			// Inserting the Case Contact Roles
			if(lstCaseContactRoles.size() > 0)
				insert lstCaseContactRoles; 
	        
	        lstCurrentTenants = [Select Property__c,Role__c,Lease_End_Date__c,Lease_Start_Date__c, Id,Property__r.Unit_Status__c,Contact__c, 
	                            Name From Current_Tenant__c where  ( Property__c IN : setPropertyIds AND (Property__r.Unit_Status__c = '1. Rented'        
	                            OR Property__r.Unit_Status__c = '2. Rent Ready'
	                            OR Property__r.Unit_Status__c = '3. Renovating' )) OR Property__c IN : setProprIds ];
	       
	        
	        for(Previous_Tenant__c objPreviousTenant:[SELECT Property__c,Contact__c,Role__c, Lease_End_Date__c,Lease_Start_Date__c
	                                                  FROM Previous_Tenant__c
	                                                  WHERE  ( Property__c IN : setPropertyIds AND (Property__r.Unit_Status__c = '1. Rented'        
						                              OR Property__r.Unit_Status__c = '2. Rent Ready'
						                              OR Property__r.Unit_Status__c = '3. Renovating' )) OR Property__c IN : setProprIds])
	        {
	        	setPreviousTenants.add(objPreviousTenant.Property__c + '-' + objPreviousTenant.Contact__c + '-' + objPreviousTenant.Role__c + '-' + objPreviousTenant.Lease_End_Date__c
	                                    + '-' + objPreviousTenant.Lease_Start_Date__c);
	        }
	       
	       
	        for(Current_Tenant__c currentTenant : lstCurrentTenants)
	        {
	        	if(mapPropertyUpdatedOld.get(currentTenant.Property__c).Unit_Status__c == '5. Notice')
	        	{
		            Previous_Tenant__c previous = new Previous_Tenant__c
		            (
			            Name = currentTenant.Name,
			            Property__c = currentTenant.Property__c,
			            Contact__c = currentTenant.Contact__c,
			            Role__c = currentTenant.Role__c,
			            Lease_End_Date__c = currentTenant.Lease_End_Date__c,
			            Lease_Start_Date__c = currentTenant.Lease_Start_Date__c
		            );
		            lstPreviousTenants.add(previous);
		            lstCurrentTenantToDelete.add(currentTenant);
		            setPreviousTenants.add(currentTenant.Property__c + '-' + currentTenant.Contact__c + '-' + currentTenant.Role__c + '-' + currentTenant.Lease_End_Date__c
	                                    + '-' + currentTenant.Lease_Start_Date__c);
	        	}
	        }
	        
	        for(Property__c objProperty:mapPropertyUpdatedNew.values())
	        {
	        	if(mapPropertyUpdatedOld.get(objProperty.Id).Unit_Status__c == '5. Notice' &&  (objProperty.Unit_Status__c == '1. Rented'        
	                            || objProperty.Unit_Status__c == '2. Rent Ready'
	                            || objProperty.Unit_Status__c == '3. Renovating' ))
	        	{
	        		setRequiredPropertyId.add(objProperty.Id);
	        	}
	        }
	        
	        
	        ///Create a list of previous tenants to insert
	        for(Current_Tenant__c currentTenant : [SELECT Name,Property__c,Contact__c,Role__c,Lease_End_Date__c, Lease_Start_Date__c
	                                               FROM Current_Tenant__c
	                                               WHERE Property__c IN:setPropertyIdToCreatePreviousTenant])
	        {
	            Previous_Tenant__c previous = new Previous_Tenant__c
	            (
		            Name = currentTenant.Name,
		            Property__c = currentTenant.Property__c,
		            Contact__c = currentTenant.Contact__c,
		            Role__c = currentTenant.Role__c,
		            Lease_End_Date__c = currentTenant.Lease_End_Date__c,
		            Lease_Start_Date__c = currentTenant.Lease_Start_Date__c
	            );
	            
	            lstPreviousTenants.add(previous);
	            lstCurrentTenantToDelete.add(currentTenant);
	            setPreviousTenants.add(currentTenant.Property__c + '-' + currentTenant.Contact__c + '-' + currentTenant.Role__c + '-' + currentTenant.Lease_End_Date__c
	                                    + '-' + currentTenant.Lease_Start_Date__c);
	        }  
	        
	        for(Contact_Role__c objCR : [Select Role__c, Opportunity__r.Property__c, Opportunity__r.Lease_End_Date__c,
                                         Opportunity__r.Lease_Start_date__c, Opportunity__c, Id, Contact__c 
                                         From Contact_Role__c
                                         where Opportunity__r.Property__c IN: setRequiredPropertyId and
                                         Opportunity__r.StageName = 'Signed Lease' and 
                                         (Opportunity__r.RecordType.DeveloperName = 'New_Lease_Opportunity' or
                                         Opportunity__r.RecordType.DeveloperName ='Renewal_Opportunity')])
	        {
	        	if(!setPreviousTenants.contains(objCR.Opportunity__r.Property__c + '-' + objCR.Contact__c + '-' + objCR.Role__c + '-' + objCR.Opportunity__r.Lease_End_Date__c
	                                    + '-' + objCR.Opportunity__r.Lease_Start_date__c))
	        	{
	       			lstCurrentTenantToCreate.add
	       			(new Current_Tenant__c
                        (
                                Contact__c = objCR.Contact__c,
                                Role__c = objCR.Role__c,
                                Lease_End_Date__c = objCR.Opportunity__r.Lease_End_Date__c,
                                Lease_Start_Date__c = objCR.Opportunity__r.Lease_Start_date__c,
                                Property__c = objCR.Opportunity__r.Property__c
              			 )
                    );
	        	}
	        }
	        
	         
	        /*Inserting Previous_Tenant records*/
	        if(lstPreviousTenants.size() > 0)
	            insert lstPreviousTenants;
	        
	        /*Deleting old Current_Tenant records*/
	        if(lstCurrentTenantToDelete.size() > 0)
	            delete lstCurrentTenantToDelete;
	        
	        /*Insert new Current_Tenant records*/    
	        if(lstCurrentTenantToCreate.size() > 0)
	        	insert lstCurrentTenantToCreate;
	        
    	}	
    	catch(Exception e) 
    	{
			system.debug('--Exception -----------'+e.getMessage() +'======@line number========'+e.getLinenumber());
			throw e;
		}
    }
    
    @isTest
    static void test()
    {
    	Id accRecId = [Select Id from RecordType where sObjectType='Account' and Name='Client/Tenant Account'].Id;
    	// Inserting the Account record
        Account account = new Account(RecordTypeId = accRecId, LastName = 'testAccount');
        insert account;
        
        // Inserting the Opportunity record
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'testOpportunity';
        objOpp.AccountId = account.Id;
        objOpp.StageName = 'Closed Lost';
        objOpp.CloseDate = date.today();
        insert objOpp;
        
        // Inserting the Property__c record
        Property__c property = new Property__c(Name = 'testProperty');
        property.Opportunity__c = objOpp.Id;
        property.Unit_Status__c = '2. Rent Ready';
        insert property;
        
        // Inserting the Current_Tenant record
        Current_Tenant__c current = new Current_Tenant__c();
        current.Property__c = property.Id;
        current.Role__c = 'Abc';
        current.Contact__c = account.Id;
        insert current;
        
        property.Legal_Alert__c = 'hitest';
        update property;
    }
}