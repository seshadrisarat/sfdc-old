/*
*Class: SL_DSML_API_ListSearch
*Description: This class is used to return the list of Organization, Contact, Affiliation and Organization Affiliation records based on the parameters passed from external systems using DSML.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/dsml/list') 
global with sharing class SL_DSML_API_ListSearch 
{
    /* Start - Variables */
    private static Set<String> setAccountId = new Set<String>();//< This set of account Id is used to filter the affliation records.
    private static Set<String> setContactId = new Set<String>();//< Thus set of contact Id is used to filter the affiliation records.
    private static Set<String> setElectronicServiceId = new Set<String>();//This set is used to keep the Electronic Service Id to get the Electronic_Service__c record to mapp with SDO wrapper class
    private static List<Affiliation__c> lstAffiliation = new List<Affiliation__c>();//This list is used to create the IORO record to add in the response.
    /* End - Variables */
    global class DslmListSearchResponse extends SL_RestResponseWrappers.BaseResponse
    {
    	public SL_DSML_API_Wrapper.PDO pdo;
        public List<SL_DSML_API_Wrapper.IDO> ido; 
        public List<SL_DSML_API_Wrapper.ODO> odo;
        public List<SL_DSML_API_Wrapper.IORO> ioro;
        public List<SL_DSML_API_Wrapper.OORO> ooro;
        public List<SL_DSML_API_Wrapper.SDO> sdo;
        
        public DslmListSearchResponse(List<SL_DSML_API_Wrapper.ODO> odo, List<SL_DSML_API_Wrapper.IDO> idos, 
                                      List<SL_DSML_API_Wrapper.IORO> ioros, List<SL_DSML_API_Wrapper.OORO> ooros, 
                                      List<SL_DSML_API_Wrapper.SDO> sdo, SL_DSML_API_Wrapper.PDO pdo,Boolean done, Integer intSize)
        {
            super(intSize, done);
            this.odo = odo;
            this.ido = idos;
            this.ioro = ioros;
            this.ooro = ooros;
            this.pdo = pdo;
            this.sdo = sdo;
        }
        
        public DslmListSearchResponse(){
            super(0, true);
            this.odo = null;
            this.ido = null;
            this.ioro = null;
            this.ooro = null;
            this.pdo = null;
            this.sdo = null;
        }
    }
    @HttpPost
    global static DslmListSearchResponse dslmProviderSearch(SL_DSML_API_Wrapper.ODE ode, SL_DSML_API_Wrapper.IDE ide, SL_DSML_API_Wrapper.IORDE iorde, SL_DSML_API_Wrapper.PUR pur)   
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<SL_DSML_API_Wrapper.ODO> lstODO = new List<SL_DSML_API_Wrapper.ODO>();
        List<SL_DSML_API_Wrapper.IDO> lstIDO = new List<SL_DSML_API_Wrapper.IDO>();
        List<SL_DSML_API_Wrapper.IORO> lsIORO = new List<SL_DSML_API_Wrapper.IORO>();
        List<SL_DSML_API_Wrapper.OORO> lstOORO = new List<SL_DSML_API_Wrapper.OORO>();
        List<SL_DSML_API_Wrapper.SDO> lstSDO = new List<SL_DSML_API_Wrapper.SDO>();///< This list is used to send the SDO records which is related to Electronic_Service__c.
        Set<String> setAffiliationType = new Set<string>();
        setElectronicServiceId = new Set<String>();///< Intialize the set
        lstAffiliation = new List<Affiliation__c>();
        SL_DSML_API_Wrapper.PDO pdo = null;
        
        if(pur!= null)
        	pdo = new  SL_DSML_API_Wrapper.PDO(pur.hpdId, pur.hpdRequestId);
        
        try
        {
            if (ode != null)
            {
            	SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier = new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null);
                SL_OrganizationSearch objOS = new SL_OrganizationSearch();
                objOS = ode.createOrganizationSearch();
                if(ode.hcIdentifier != null)
                	hcIdentifier = ode.hcIdentifier;
                objOS.setOffSetLimit(pur);
                lstODO = prepareOrganizationResponse(objOS, hcIdentifier);
            }
            
            if (ide != null)
            {
            	SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier = new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null);
                SL_ProvidersSearch objPS = new SL_ProvidersSearch();
                objPS = ide.createProviderSearch();
                objPS.setOffSetLimit(pur);
                /* ode!=null has been added by Pankaj Ganwani to avoid NULL pointer exception if ode is NULL*/
                if(ode!=null && ode.hcIdentifier != null)
                	hcIdentifier = ode.hcIdentifier;
                lstIDO = prepareContactResponse(objPS, hcIdentifier);///< calling function which will return the response of the wrapper class.
            } 
            
            if(iorde != null && iorde.hpdMemberType != null && iorde.hpdMemberType.size() > 0)
            {
                for(String strType : iorde.hpdMemberType)///< iterating all the hpdMemberType and keep into set to get the valid the affiliation records..
                {
                    setAffiliationType.add(strType.trim());///< adding the value to the set.
                }
            }
            
            lsIORO = prepareAffiliationResponse(setAffiliationType);///< This function is call to return the list of IORO records on the basis of the affliation type...
            lstOORO = prepareOrganizationAffiliationResponse();///< This function will return all the lst of the OORO records.
            lstSDO = SL_DSML_API_Wrapper.prepareElectronicServicesResponse(setElectronicServiceId);//getting lst of SDO wrapper class on the basis of the IORO.
            
            Integer intSize = lstODO.size() + lstIDO.size() + lsIORO.size() + lstOORO.size() + lstSDO.size();
            
            return new DslmListSearchResponse(lstODO, lstIDO, lsIORO, lstOORO, lstSDO, pdo, true, intSize);
        }
        catch(Exception ex)
        {
            System.debug('===========Exception======'+ex);
            return new DslmListSearchResponse(new List<SL_DSML_API_Wrapper.ODO>(), new List<SL_DSML_API_Wrapper.IDO>(), 
                                              new List<SL_DSML_API_Wrapper.IORO>(),  new List<SL_DSML_API_Wrapper.OORO>(), 
                                              new List<SL_DSML_API_Wrapper.SDO>(), pdo, false, 0);
        }
   
    }
    
     /*
        @MethodName : prepareContactResponse
        @param      : List of Contact
        @Description: This method is called to get the prepare the REST API response on the basis of the list of the contact send from the calling method.
        @CreatedBy  : Lodhi
        @CreatedDate: 29/JULY/2013
    */
    private static List<SL_DSML_API_Wrapper.IDO> prepareContactResponse(SL_ProvidersSearch objPS, SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier)
    {
        try
        {
        	List<Contact> lstContact = objPS.searchProvider();
            setContactId = new Set<String>();
            List<SL_DSML_API_Wrapper.IDO> lstIDO = new List<SL_DSML_API_Wrapper.IDO>();///< This list contains all the response record to send to the extrernal system.
            
            Set<Id> setAffiliationIds = new Set<Id>();// set to hold all those affiliations which are related to the Contacts returned as search results. These affiliations are used to get child affiliation service records on basis of which we get electronic service records.
            Map<Id, Set<Id>> mapEServiceToSetOfProvider = new Map<Id, Set<Id>>();
            Map<Id, List<SL_DSML_API_Wrapper.SDO>> mapProviderIdToSDO = new Map<Id, List<SL_DSML_API_Wrapper.SDO>>();
            
            if(lstContact.size() > 0)
            {
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
                
                ///< Iterating the lstContact to prepare the response in proper format.
                for(Contact objContact : lstContact)
                {
                    setContactId.add(objContact.Id);
                    lstAffiliation.addAll(objContact.Affiliations__r);
                    lstIDO.add(new SL_DSML_API_Wrapper.IDO(objContact, hcIdentifier, objPS.decLatitude, objPS.decLongitude, mapProviderIdToSDO.containskey(objContact.Id) ? mapProviderIdToSDO.get(objContact.Id) : new List<SL_DSML_API_Wrapper.SDO>()));///< adding this IDO instance to the lst to send the response.
                }
                /* End - Updated by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
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
        @MethodName : prepareOrganizationResponse
        @param      : List of Account
        @Description: This method is called to get the prepare the REST API response on the basis of the list of the account send from the calling method.
        @CreatedBy  : Lodhi
        @CreatedDate: 29/JULY/2013
    */
    private static List<SL_DSML_API_Wrapper.ODO> prepareOrganizationResponse(SL_OrganizationSearch objOS, SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier)
    {
    	List<Account> lstAccount = objOS.searchOrganization();
        List<SL_DSML_API_Wrapper.ODO> lstODO = new List<SL_DSML_API_Wrapper.ODO>(); 
        
        List<Organization_Service__c> lstOS = new List<Organization_Service__c>();
        Map<Id,Set<Id>> mapEServiceIdToSetOfAccId = new Map<Id,Set<Id>>();
        Map<Id,List<SL_DSML_API_Wrapper.SDO>> mapAccIdTolstOfSDO = new Map<Id,List<SL_DSML_API_Wrapper.SDO>>();
        Map<Id, Set<String>> mapOrgIdToSetOfContactId = new Map<Id,Set<String>>();
        
        setAccountId = new Set<String>();
        try
        {
            if(!lstAccount.isEmpty())
            {
                /* Start - Updated by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
                for(Account objAccount : lstAccount)
                {
                	lstOS.addAll(objAccount.Organization_Services__r);
                }
                
                /* Start - Added By Pankaj Ganwani on 24/JUNE/2015 */
                Map<Id, Account> mapIdToAccount = new Map<Id, Account>(lstAccount);
                
                for(Contact objContact : [SELECT Id, AccountId FROM Contact WHERE AccountId IN : mapIdToAccount.keyset() AND RecordType.DeveloperName =: 'Provider'])
                {
                	if(!mapOrgIdToSetOfContactId.containskey(objContact.AccountId))
                		mapOrgIdToSetOfContactId.put(objContact.AccountId, new Set<String>{objContact.Id});
                	else
                		mapOrgIdToSetOfContactId.get(objContact.AccountId).add(objContact.Id);
                }
                /* End - Added By Pankaj Ganwani on 24/JUNE/2015 */
                
                for(Organization_Service__c objOService : [SELECT Electronic_Service__c, Organization__c FROM Organization_Service__c WHERE ID IN : lstOS])
                {
                	if(!mapEServiceIdToSetOfAccId.containskey(objOService.Electronic_Service__c))
                		mapEServiceIdToSetOfAccId.put(objOService.Electronic_Service__c, new Set<Id>{objOService.Organization__c});
                	else
                		mapEServiceIdToSetOfAccId.get(objOService.Electronic_Service__c).add(objOService.Organization__c);
                }
                
                for(Electronic_Service__c objEService : [SELECT Id, Protocol__c, Payload__c, Address__c, Certificate__c, Name, Service_Destinations__c FROM Electronic_Service__c WHERE Id IN : mapEServiceIdToSetOfAccId.keyset()])
                {
                	if(mapEServiceIdToSetOfAccId.containskey(objEService.Id))
                	{
                		for(Id accountId : mapEServiceIdToSetOfAccId.get(objEService.Id))
                		{
                			if(!mapAccIdTolstOfSDO.containskey(accountId))
	            				mapAccIdTolstOfSDO.put(accountId, new List<SL_DSML_API_Wrapper.SDO>{new SL_DSML_API_Wrapper.SDO(objEService)});
	            			else
	            				mapAccIdTolstOfSDO.get(accountId).add(new SL_DSML_API_Wrapper.SDO(objEService));
                		}
                	}
                }                
                
                for(Account objAccount : lstAccount)
                {  
                    setAccountId.add(objAccount.Id);///< adding this account Id to set to filter the OrganizationAffiliation records.
                    lstODO.add(new SL_DSML_API_Wrapper.ODO(objAccount, hcIdentifier, objOS.decLatitude, objOS.decLongitude, mapAccIdTolstOfSDO.containskey(objAccount.Id) ? mapAccIdTolstOfSDO.get(objAccount.Id) : new List<SL_DSML_API_Wrapper.SDO>(), mapOrgIdToSetOfContactId.containskey(objAccount.Id) ? mapOrgIdToSetOfContactId.get(objAccount.Id) : new Set<String>())); ///< Adding the ODO instance to the lst to prepare the response.
                }
                /* End - Updated by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
            }
            return lstODO;  
        }
        catch(Exception ex)
        {
            System.debug('===========Exception=========='+ex);
            return new List<SL_DSML_API_Wrapper.ODO>();
        }
        
    }
    /* End */
    
    
    
    /*
        @MethodName : prepareAffiliationResponse
        @param      : Set of the Affiliation type
        @Description: This method is called to get the prepare the REST API response on the basis of the set of the Affiliation__c.type__c send from the calling method.
        @CreatedBy  : Lodhi
        @CreatedDate: 29/JULY/2013
    */
    private static List<SL_DSML_API_Wrapper.IORO> prepareAffiliationResponse(Set<String> setAffiliationType)
    {
        List<SL_DSML_API_Wrapper.IORO> lstIORO = new List<SL_DSML_API_Wrapper.IORO>();
        List<Affiliation__c> lstAffiliationFilter = new List<Affiliation__c>();//This lst contains all the filter affiliation records to converted to IORO.
        Map<Id, List<String>> mapAffiliationIdToLstOfElectronicServicesId = new Map<Id, List<String>>();
        //Map<Id, List<Affiliation_Service__c>> mapAffiliationIdToLstOfAffiliationService = new Map<Id, List<Affiliation_Service__c>>();//< This map is used to keep the list of theAffiliation_Service__c records corresponding to the affiliation id. 
        Set<Id> setAffiliationId = new Set<Id>();//This set is used to keep the affiliation Id to get the Affiliation_Service__c record to mapp with IORO wrapper class
        try
        {
        	 for(Affiliation__c objAffiliation : lstAffiliation)
             {
             	if(setContactId.contains(objAffiliation.Provider__c) && setAccountId.contains(objAffiliation.Organization__c) &&(setAffiliationType.contains(objAffiliation.Type__c) || setAffiliationType.size() == 0))
                {
             		setAffiliationId.add(objAffiliation.Id);
             		lstAffiliationFilter.add(objAffiliation);
                }
             }
             
        	 for(Affiliation_Service__c objAS : [SELECT Id, Affiliation__c, Electronic_Service__c
    		 									 FROM Affiliation_Service__c 
    		 									 WHERE Affiliation__c IN: setAffiliationId])
    		 {
    		 	if(mapAffiliationIdToLstOfElectronicServicesId.containsKey(objAS.Affiliation__c))
             		mapAffiliationIdToLstOfElectronicServicesId.get(objAS.Affiliation__c).add(objAS.Electronic_Service__c);
             	else
             		mapAffiliationIdToLstOfElectronicServicesId.put(objAS.Affiliation__c, new List<String>{objAS.Electronic_Service__c});
             		
    		 }
        	
             ///< Iterating the Affiliation__c records to prepare the wrapper class to send the response.
             for(Affiliation__c objAffiliation : lstAffiliationFilter)
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
             return lstIORO;///<  return the list of the of the wrapper class as response from the calling methods..
        }
        catch(Exception ex)
        {
            return new List<SL_DSML_API_Wrapper.IORO>();///< If there is exception then sending the blank list to the response...
        }
    }
    /* End */
    
    /*
        @MethodName : prepareOrganizationAffiliationResponse
        @CreatedBy  : Lodhi
        @CreatedDate: 29/JULY/2013
        
    */
    private static List<SL_DSML_API_Wrapper.OORO> prepareOrganizationAffiliationResponse()
    {
        try
        {
            List<SL_DSML_API_Wrapper.OORO> lstOORO = new List<SL_DSML_API_Wrapper.OORO>();///< This lst is used to keep the OORO records  on the basis of the Organization_Affiliation__c records.
            
            ///< Query all the Organization_Affiliation__c records on the basis of the Organization records and prepare the OROO wrapper class instance and add to the list.
            for(Organization_Affiliation__c objOA : [SELECT Id, Start_Date__c, Affiliation_Type__c, Member_Organization__r.Name, Member_Organization__c, 
                                                            Affiliated_Organization__c, End_Date__c 
                                                     FROM Organization_Affiliation__c
                                                     WHERE Member_Organization__c IN: setAccountId AND Affiliated_Organization__c IN: setAccountId])
            {
                lstOORO.add(new SL_DSML_API_Wrapper.OORO(objOA));///< adding the OORO instance to the lst to send to the calling methods...
            }
            return lstOORO;///< return the lst after adding all the OORO objects...
        }
        catch(Exception ex)
        {
            System.debug('============Exception======='+ex);
            return new  List<SL_DSML_API_Wrapper.OORO>();///< if there is exception then return blank lst as response..
        }
    }

}