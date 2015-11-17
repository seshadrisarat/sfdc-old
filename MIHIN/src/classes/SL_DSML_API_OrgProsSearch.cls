/*
*Class: SL_DSML_API_OrgProsSearch
*Description: This class is used for following purposes:
			- To get the list of filtered Affiliation records based on iorde attributes 
			- To get the list of ODO records based on the Accounts
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/dsml/organization/providers') 
global with sharing class SL_DSML_API_OrgProsSearch 
{
	/* Start - Variables */
	private static Set<String> setContactId = new Set<String>();//This set is used to keep the id of the contact to get the records.
	private static Set<Id> setAffiliationId = new Set<Id>();//This set is used to keep the affiliation Id to get the Affiliation_Service__c record to mapp with IORO wrapper class
	private static Set<String> setElectronicServiceId = new Set<String>();//This set is used to keep the Electronic Service Id to get the Electronic_Service__c record to mapp with SDO wrapper class
	private static List<Affiliation__c> lstAffiliation = new List<Affiliation__c>();//This list is used to keep all the Affiliation get from provider search and Organization search.
	/* End - Variables */
    global class DslmOrgProsSearchResponse extends SL_RestResponseWrappers.BaseResponse
    {
    	public SL_DSML_API_Wrapper.PDO pdo;
        public SL_DSML_API_Wrapper.ODO odo;
        public List<SL_DSML_API_Wrapper.IDO> ido;
        public List<SL_DSML_API_Wrapper.IORO> ioro;
        public List<SL_DSML_API_Wrapper.SDO> sdo;
        
        public DslmOrgProsSearchResponse(SL_DSML_API_Wrapper.ODO odo, List<SL_DSML_API_Wrapper.IDO> idos, 
        									List<SL_DSML_API_Wrapper.IORO> ioros,List<SL_DSML_API_Wrapper.SDO> sdo,
        									SL_DSML_API_Wrapper.PDO pdo, Boolean done, Integer size)
        {
            super(size, true);
            this.odo = odo;
            this.ido = idos;
            this.ioro = ioros;
            this.pdo = pdo;
            this.sdo = sdo;
        }
        
        public DslmOrgProsSearchResponse(){
            super(0, true);
            this.odo = null;
            this.ido = null;
            this.ioro = null;
            this.pdo = null;
            this.sdo = null;
        }
    }
    @HttpPost
    global static DslmOrgProsSearchResponse dslmProviderSearch(SL_DSML_API_Wrapper.OUR our, SL_DSML_API_Wrapper.IDE ide, SL_DSML_API_Wrapper.IORDE iorde, SL_DSML_API_Wrapper.PUR pur)   
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<SL_DSML_API_Wrapper.IDO> lstIDO = new List<SL_DSML_API_Wrapper.IDO>();
        List<SL_DSML_API_Wrapper.IORO> lstIORO = new List<SL_DSML_API_Wrapper.IORO>();
        List<SL_DSML_API_Wrapper.SDO> lstSDO = new List<SL_DSML_API_Wrapper.SDO>();///< This list is used to send the SDO records which is related to Electronic_Service__c.
        SL_DSML_API_Wrapper.ODO objODO = new SL_DSML_API_Wrapper.ODO();
        setElectronicServiceId = new Set<String>();///< Intialize the set
        lstAffiliation = new List<Affiliation__c>();///< Intialize the Affiliation lst to create the wrapper class object and send it to the response.
        SL_DSML_API_Wrapper.PDO pdo = null;
        
        if(pur!= null)
        	pdo = new  SL_DSML_API_Wrapper.PDO(pur.hpdId, pur.hpdRequestId);
        try
        {
	        if(our != null)
	        {
	        	SL_OrganizationSearch objOS = new SL_OrganizationSearch();
	        	objOS = our.createOrganizationSearch();//setting all the public variablesof the Organization search. 
	        	List<Account> lstAccount = objOS.searchOrganization();
	        	SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier = new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null);
	        	if(lstAccount.size() > 0 )
	        	{
	        		objODO = prepareOrganizationResponse(lstAccount[0]);
		        	SL_ProvidersSearch objPS = new SL_ProvidersSearch();
		        	if(ide != null)
		        	{
		        		if(ide.hcIdentifier != null)
		        			hcIdentifier = ide.hcIdentifier;
		        			
		        		objPS = ide.createProviderSearch();
		        	}
		        	lstAffiliation = getFilterAffiliation(iorde, lstAffiliation);
		        	if(setContactId.size() > 0)
		        	{
			        	objPS.setProviderId.addAll(setContactId);
			        	objPS.setOffSetLimit(pur);
			        	lstIDO = prepareContactResponse(objPS, hcIdentifier);
		        		lstIORO = prepareAffiliationResponse(lstAffiliation);
		        		lstSDO = SL_DSML_API_Wrapper.prepareElectronicServicesResponse(setElectronicServiceId);//getting lst of SDO wrapper class on the basis of the IORO.
		        	}
	        		Integer size = 1 + lstIDO.size() + lstIORO.size() + lstSDO.size();
	        		return new DslmOrgProsSearchResponse(objODO, lstIDO, lstIORO, lstSDO, pdo, true, size);
	        	} 
	        	return new DslmOrgProsSearchResponse(null, lstIDO, lstIORO, lstSDO, pdo, true, 0);
	        }
	        return new DslmOrgProsSearchResponse(null, lstIDO, lstIORO, lstSDO, pdo, true, 0);
        }
        catch(Exception ex)
        {
        	 return new DslmOrgProsSearchResponse(null, lstIDO, lstIORO, lstSDO, pdo, true, 0);
        }
          
    }
    /* End */
    
    /*
		@MethodName : getFilterAffiliation
		@param      : iorde and the lst of the Affilaition records.
		@Description: This method is used to get the filter Affiliation records on the basis of the iorde attributes and set of the account id need to query.
		@CreatedBy  : Lodhi
		@CreatedDate: 02/AUG/2013
	*/
	private static List<Affiliation__c> getFilterAffiliation(SL_DSML_API_Wrapper.IORDE iorde, List<Affiliation__c> lstAffiliations)
	{
		Set<String> setAffiliationType = new Set<String>();
		List<Affiliation__c> lstAffiliationFilter = new List<Affiliation__c>();
		setContactId = new Set<String>();
		setAffiliationId = new Set<Id>();
		//checking if the "iorde" record is null or not.
    	if(iorde != null && iorde.hpdMemberType != null && iorde.hpdMemberType.size() > 0)
    	{
    		for(String strType : iorde.hpdMemberType)//iterating all the hpdMemberType and keep into set to get the valid organization records and the affiliation records..
    		{
    			setAffiliationType.add(strType.trim());//adding the value to the set.
    		}
    		
    		//If there is value in setAffiliationType than add the filter to the Affiliation and the organization to create ODO and IORO records..
    		for(Affiliation__c objAffiliation : lstAffiliations)
    		{
    			if(setAffiliationType.contains(objAffiliation.Type__c))//checking the condition to get the account Id and the affiliation records..
    			{
    				setAffiliationId.add(objAffiliation.Id);
    				setContactId.add(objAffiliation.Provider__c);//adding values.
    				lstAffiliationFilter.add(objAffiliation);//adding values..
    			}
    		}
    	}
    	else //if iorde records is null then all the affiliation and account will included in response. 
    	{
    		for(Affiliation__c objAffiliation : lstAffiliations)
    		{
    			setAffiliationId.add(objAffiliation.Id);
    			setContactId.add(objAffiliation.Provider__c);
    		}
    		lstAffiliationFilter.addAll(lstAffiliations);//adding all the affiliation records.
    	}
    	return lstAffiliationFilter;
	}
	/* End */
    
    /*
		@MethodName : prepareOrganizationResponse
		@param      : Account
		@Description: This method is called to get the prepare the REST API response on the basis of the list of the account send from the calling method.
		@CreatedBy  : Lodhi
		@CreatedDate: 24/JULY/2013
	*/
    private static SL_DSML_API_Wrapper.ODO prepareOrganizationResponse(Account objAccount)
    {
   		List<Organization_Service__c> lstOS = new List<Organization_Service__c>();
   		Set<Id> setEServiceId = new Set<Id>();
   		List<SL_DSML_API_Wrapper.SDO> lstSDO = new List<SL_DSML_API_Wrapper.SDO>();
   		try
		{
			lstAffiliation = new List<Affiliation__c>();
			if(objAccount != null)
			{
    			lstAffiliation.addAll(objAccount.Affiliations__r);
    			lstOS.addAll(objAccount.Organization_Services__r);
    			
    			/* Start - Added By Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110 */
    			for(Organization_Service__c objOS : [SELECT Electronic_Service__c FROM Organization_Service__c WHERE ID IN : lstOS])
    			{
    				setEServiceId.add(objOS.Electronic_Service__c);
    			}
    			
    			for(Electronic_Service__c objEService : [SELECT Id, Protocol__c, Payload__c, Address__c, Certificate__c, Name, Service_Destinations__c FROM Electronic_Service__c WHERE Id IN : setEServiceId])
    			{
    				lstSDO.add(new SL_DSML_API_Wrapper.SDO(objEService));
    			}
    			/* End - Added By Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110 */
    			
    			Map<String,Contact> mapIdToContact = new Map<String,Contact>([SELECT Id FROM Contact WHERE AccountId =:objAccount.Id AND RecordType.DeveloperName =: 'Provider']);
    			
    			return new SL_DSML_API_Wrapper.ODO(objAccount, new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null), null, null,lstSDO, mapIdToContact.keyset());
			}
			else
				return null;
		}
		catch(Exception ex)
		{
			System.debug('===========Exception=========='+ex);
			return null;
		}
    }
	/* End */
    
     /*
		@MethodName : prepareContactResponse
		@param      : List of Contact
		@Description: This method is called to get the prepare the REST API response on the basis of the list of the contact send from the calling method.
		@CreatedBy  : Lodhi
		@CreatedDate: 24/JULY/2013
	*/
    private static List<SL_DSML_API_Wrapper.IDO> prepareContactResponse(SL_ProvidersSearch objPS, SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier)
    {
    	try
    	{
    		List<Contact> lstContact = objPS.searchProvider();
	    	List<SL_DSML_API_Wrapper.IDO> lstIDO = new List<SL_DSML_API_Wrapper.IDO>();//This list contains all the response record to send to the extrernal system.
	    	
	    	Set<Id> setAffiliationIds = new Set<Id>();// set to hold all those affiliations which are related to the Contacts returned as search results. These affiliations are used to get child affiliation service records on basis of which we get electronic service records.
            Map<Id, Set<Id>> mapEServiceToSetOfProvider = new Map<Id, Set<Id>>();
            Map<Id, List<SL_DSML_API_Wrapper.SDO>> mapProviderIdToSDO = new Map<Id, List<SL_DSML_API_Wrapper.SDO>>();
            
	    	if(lstContact.size() > 0)
	    	{
	    		setContactId = new Set<String>();
	    		
	    		/* Start - Updated by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
                for(Contact objContact : lstContact)
	            {
	            	if(!objContact.Affiliations__r.isEmpty())
	            		setAffiliationIds.addAll((new Map<Id, Affiliation__c>(objContact.Affiliations__r)).keyset());
	            }
	            
	            //getting affiliation service records in order to collect provider records that are associated with each Electronic service
	            for(Affiliation_Service__c objAffiliationService : [SELECT Affiliation__r.Provider__c, Electronic_Service__c FROM Affiliation_Service__c WHERE Affiliation__c IN : setAffiliationIds])
	            {
	            	if(!mapEServiceToSetOfProvider.containskey(objAffiliationService.Electronic_Service__c))
	            		mapEServiceToSetOfProvider.put(objAffiliationService.Electronic_Service__c, new Set<Id>{objAffiliationService.Affiliation__r.Provider__c});
	            	else
	            		mapEServiceToSetOfProvider.get(objAffiliationService.Electronic_Service__c).add(objAffiliationService.Affiliation__r.Provider__c);
	            }  
	            
	            for(Electronic_Service__c objEService : [SELECT Id, Protocol__c, Payload__c, Address__c, Certificate__c, Name, Service_Destinations__c FROM Electronic_Service__c WHERE Id IN : mapEServiceToSetOfProvider.keyset()])
	            {
	            	if(mapEServiceToSetOfProvider.containskey(objEService.Id))
	            	{
	            		for(Id providerId : mapEServiceToSetOfProvider.get(objEService.Id))
	            		{
	            			if(!mapProviderIdToSDO.containskey(providerId))
	            				mapProviderIdToSDO.put(providerId, new List<SL_DSML_API_Wrapper.SDO>{new SL_DSML_API_Wrapper.SDO(objEService)});
	            			else
	            				mapProviderIdToSDO.get(providerId).add(new SL_DSML_API_Wrapper.SDO(objEService));
	            		}
	            	}
	            }	    		
	    		
	    		//Iterating the lstContact to prepare the response in proper format.
	    		for(Contact objContact : lstContact)
	    		{
	    			setContactId.Add(objContact.Id);
	    			//Creating the IDO wrapper class object to set the response values.
	    			lstIDO.add(new SL_DSML_API_Wrapper.IDO(objContact, hcIdentifier, objPS.decLatitude, objPS.decLongitude, mapProviderIdToSDO.containskey(objContact.Id) ? mapProviderIdToSDO.get(objContact.Id) : new List<SL_DSML_API_Wrapper.SDO>()));//adding this IDO instance to the lst to send the response.
	    		}
	    	}
	    	return lstIDO;
    	}
    	catch(Exception ex)
    	{
    		System.debug('============Exception========='+ex.getLineNumber());
    		return new List<SL_DSML_API_Wrapper.IDO>();
    	}
    }
    
    /* End - Method */
    
    /*
		@MethodName : prepareAffiliationResponse
		@param      : List of Contact
		@Description: This method is called to get the prepare the REST API response on the basis of the list of the Affiliation__c send from the calling method.
		@CreatedBy  : Lodhi
		@CreatedDate: 24/JULY/2013
	*/
    private static List<SL_DSML_API_Wrapper.IORO> prepareAffiliationResponse(List<Affiliation__c> lstAffiliations)
    {
    	List<SL_DSML_API_Wrapper.IORO> lstIORO = new List<SL_DSML_API_Wrapper.IORO>();
    	Map<Id, List<String>> mapAffiliationIdToLstOfElectronicServicesId = new Map<Id, List<String>>();
    	//Map<Id, List<Affiliation_Service__c>> mapAffiliationIdToLstOfAffiliationService = new Map<Id, List<Affiliation_Service__c>>();//< This map is used to keep the list of theAffiliation_Service__c records corresponding to the affiliation id.
    	try
    	{
    		//Getting Affiliation_Service__c related to Affiliation records.
    		 for(Affiliation_Service__c objAS : [SELECT Id, Affiliation__c, Electronic_Service__c
    		 									 FROM Affiliation_Service__c 
    		 									 WHERE Affiliation__c IN: setAffiliationId])
    		 {
    		 	
    		 	if(mapAffiliationIdToLstOfElectronicServicesId.containsKey(objAS.Affiliation__c))
             		mapAffiliationIdToLstOfElectronicServicesId.get(objAS.Affiliation__c).add(objAS.Electronic_Service__c);
             	else
             		mapAffiliationIdToLstOfElectronicServicesId.put(objAS.Affiliation__c, new List<String>{objAS.Electronic_Service__c});
             		
    		 }
    		 //Iterating the Affiliation__c records to prepare the wrapper class to send the response.
	   		 for(Affiliation__c objAffiliation : lstAffiliations)
	   		 {
	   		 	if(setContactId.contains(objAffiliation.Provider__c))
	   		 	{
	   		 		if(mapAffiliationIdToLstOfElectronicServicesId.containsKey(objAffiliation.Id))
	   		 		{
	   		 			setElectronicServiceId.addAll(mapAffiliationIdToLstOfElectronicServicesId.get(objAffiliation.Id));
		   		 		lstIORO.add(new SL_DSML_API_Wrapper.IORO(objAffiliation, mapAffiliationIdToLstOfElectronicServicesId.get(objAffiliation.Id)));//creating the wrapper class instance to send the responseand and adding to the list.
	   		 		}
	   		 		else
	   		 		{
	   		 			lstIORO.add(new SL_DSML_API_Wrapper.IORO(objAffiliation, new List<String>()));//creating the wrapper class instance to send the responseand and adding to the list.
	   		 		}
	   		 	}
	   		 }
	   		 return lstIORO;// return the list of the of the wrapper class as response from the calling methods..
    	}
    	catch(Exception ex)
    	{
    		return new List<SL_DSML_API_Wrapper.IORO>();//If there is exception then sending the blank list to the response...
    	}
    }
	/* End */
}