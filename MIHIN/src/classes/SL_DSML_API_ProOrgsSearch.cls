/*
*Class: SL_DSML_API_ProOrgsSearch
*Description: This class is used to get the details of provider and organization based on the values of Contact and Organization Ids
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/dsml/provider/organizations') 
global with sharing class SL_DSML_API_ProOrgsSearch 
{
    /* Start - Variables */
    private static Set<String> setAccountId = new Set<String>();//This set is used to keep the id of the account to get the account records fetch.
    private static Set<Id> setAffiliationId = new Set<Id>();//This set is used to keep the affiliation Id to get the Affiliation_Service__c record to mapp with IORO wrapper class
    private static Set<String> setElectronicServiceId = new Set<String>();//This set is used to keep the Electronic Service Id to get the Electronic_Service__c record to mapp with SDO wrapper class
    private static List<Affiliation__c> lstAffiliation = new List<Affiliation__c>();//This list is used to keep all the Affiliation get from provider search and Organization search.
    
    /* End - Variables */
    
    global class DslmProOrgsSearchResponse extends SL_RestResponseWrappers.BaseResponse
    {
    	public SL_DSML_API_Wrapper.PDO pdo;
        public SL_DSML_API_Wrapper.IDO ido;
        public List<SL_DSML_API_Wrapper.ODO> odo;
        public List<SL_DSML_API_Wrapper.IORO> ioro;
       	public List<SL_DSML_API_Wrapper.SDO> sdo;
        
        public DslmProOrgsSearchResponse(SL_DSML_API_Wrapper.IDO ido, List<SL_DSML_API_Wrapper.ODO> odos, 
        									List<SL_DSML_API_Wrapper.IORO> ioros,  List<SL_DSML_API_Wrapper.SDO> sdo,
        									SL_DSML_API_Wrapper.PDO pdo, Boolean done, Integer size)
        {
            super(size, true);
            this.ido = ido;
            this.odo = odos;
            this.ioro = ioros;
            this.pdo = pdo;
            this.sdo = sdo;
        }
        
        public DslmProOrgsSearchResponse(){
            super(0, true);
            this.ido = null;
            this.odo = null;
            this.ioro = null;
            this.pdo = null;
            this.sdo = null;
        }
        
    }
    
    @HttpPost
    global static DslmProOrgsSearchResponse dslmProviderSearch(SL_DSML_API_Wrapper.IUR iur, SL_DSML_API_Wrapper.ODE ode, SL_DSML_API_Wrapper.IORDE iorde, SL_DSML_API_Wrapper.PUR pur)   
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        SL_DSML_API_Wrapper.IDO objIDO = new SL_DSML_API_Wrapper.IDO(new Contact(), new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null), null, null, new List<SL_DSML_API_Wrapper.SDO>());///< This list will the provider records after convert it into the wrapper class object.
        List<SL_DSML_API_Wrapper.ODO> lstODO = new List<SL_DSML_API_Wrapper.ODO>();///< This list will store all the Organization and its related records by convert in the wrapper class in thier respectively.
        List<SL_DSML_API_Wrapper.IORO> lstIORO = new List<SL_DSML_API_Wrapper.IORO>();///< This list will store all the Affiliation records in the from of the wrapper class and send it in response
        List<SL_DSML_API_Wrapper.SDO> lstSDO = new List<SL_DSML_API_Wrapper.SDO>();///< This list is used to send the SDO records which is related to Electronic_Service__c.
        lstAffiliation = new List<Affiliation__c>();///< Intialize the Affiliation lst to create the wrapper class object and send it to the response..
        setAccountId = new Set<String>();///< Intialize the set which contains the ids of the Account to be quired.
        setElectronicServiceId = new Set<String>();///< Intialize the set
        List<Contact> lstContact = new List<Contact>();///< This list is used to get the provider records from the SearchProviders classa and send it to prepare response.
        SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier = new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null);
       
        SL_DSML_API_Wrapper.PDO pdo = null;
        
        if(pur!= null)
        	pdo = new  SL_DSML_API_Wrapper.PDO(pur.hpdId, pur.hpdRequestId);
        try
        {
            //Checking if the iur is valid or not or having null values.
            if(iur != null)
            {
                //Creating Provider serch class instance to call the serach provider methods and get the serached Providers records.
                SL_ProvidersSearch objPS = new SL_ProvidersSearch();
                objPS = iur.createProviderSearch();//setting the Provider Search public variable to get the searched record on the basis of the variable.
                lstContact = objPS.searchProvider();//calling SL_ProvidersSearch class method to search the provider records as per the values set to the public variables.
                if(lstContact.size() > 0)//checking if there is records or not..
                {
                    objIDO = prepareProviderResponse(lstContact[0]);//calling to prepare tyhe response.
                    
                    SL_OrganizationSearch objOS = new SL_OrganizationSearch();
                    //checking for the organization records to be get on the basis of the "ODE" record get fro the request..
                    if (ode != null)
                    {
                    	if(ode.hcIdentifier != null)
                    		hcIdentifier = ode.hcIdentifier;
                        objOS = ode.createOrganizationSearch();
                    }
                    lstAffiliation = getFilterAffiliation(iorde, lstAffiliation);
                    if(setAccountId.size() > 0)
                    {
                        objOS.setAccountId.addAll(setAccountId);//adding the Account id to the SL_OrganizationSearch variable..
                         objOS.setOffSetLimit(pur); //setting the offset and limit.
                        lstODO = prepareOrganizationResponse(objOS, hcIdentifier);// getting the lst of ODO wrapper class on the basis of the records getting from the searchOrganization method.
                        lstIORO = prepareAffiliationResponse(lstAffiliation);//getting the lst of IORO wrapper class on the basis of the lstAffiliation2 and the above Account Id..
                        lstSDO = SL_DSML_API_Wrapper.prepareElectronicServicesResponse(setElectronicServiceId);//getting lst of SDO wrapper class on the basis of the IORO. 
                    }
                    Integer size = 1 + lstODO.size() + lstIORO.size() + lstSDO.size();
                    return new DslmProOrgsSearchResponse(objIDO, lstODO, lstIORO, lstSDO, pdo, true, size);// return the result on the basis of the above object and the list's.
                }
                
                return new DslmProOrgsSearchResponse(null, lstODO, lstIORO, lstSDO, pdo, true, 0);
            }
             return new DslmProOrgsSearchResponse(null, lstODO, lstIORO, lstSDO, pdo, true, 0);
        }
        catch(Exception ex)
        {
            System.debug('==============Exception=========='+ex);
            return new DslmProOrgsSearchResponse(null, lstODO, lstIORO, lstSDO, pdo, true, 0);
        }
    }
    /* End */
    
    /*
        @MethodName : prepareProviderResponse
        @param      : List of Contact
        @Description: This method is called to get the prepare the REST API response on the basis of the list of the contact send from the calling method.
        @CreatedBy  : Lodhi
        @CreatedDate: 22/JULY/2013
    */
    private static SL_DSML_API_Wrapper.IDO prepareProviderResponse(Contact objContact)
    {
        Set<Id> setEService = new Set<Id>();
        /* Start - Updated by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
        List<SL_DSML_API_Wrapper.SDO> lstSDO = new List<SL_DSML_API_Wrapper.SDO>();
        try
        {
            lstAffiliation = new List<Affiliation__c>();
            lstAffiliation.addAll(objContact.Affiliations__r);
            /* Start - Added By Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110 */
            for(Affiliation_Service__c objAffService : [SELECT Electronic_Service__c FROM Affiliation_Service__c WHERE Affiliation__c IN : (new Map<Id, Affiliation__c>(lstAffiliation)).keyset()])
            {
            	setEService.add(objAffService.Electronic_Service__c);
            }
            
            for(Electronic_Service__c objEService : [SELECT Id, Protocol__c, Payload__c, Address__c, Certificate__c, Name, Service_Destinations__c FROM Electronic_Service__c WHERE Id IN : setEService])
            {
            	lstSDO.add(new SL_DSML_API_Wrapper.SDO(objEService));
            }
            /* End - Added By Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110 */
            //Creating the IDO wrapper class object to set the response values.
            SL_DSML_API_Wrapper.IDO objIDO = new SL_DSML_API_Wrapper.IDO(objContact, new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null), null, null, lstSDO);
            return objIDO;
        /* End - Updated by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
        }
        catch(Exception ex)
        {
            System.debug('============Exception========='+ex.getLineNumber());
            return new SL_DSML_API_Wrapper.IDO(new Contact(), new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null), null, null, new List<SL_DSML_API_Wrapper.SDO>());
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
        setAccountId = new Set<String>();
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
                    setAccountId.add(objAffiliation.Organization__c);//adding values.
                    lstAffiliationFilter.add(objAffiliation);//adding values..
                }
            }
        }
        else //if iorde records is null then all the affiliation and account will included in response. 
        {
            for(Affiliation__c objAffiliation : lstAffiliations)
            {
                setAffiliationId.add(objAffiliation.Id);
                setAccountId.add(objAffiliation.Organization__c);
            }
            lstAffiliationFilter.addAll(lstAffiliations);//adding all the affiliation records.
        }
        return lstAffiliationFilter;
    }
    /* End */
    /*
        @MethodName : prepareOrganizationResponse
        @param      : List of Account
        @Description: This method is called to get the prepare the REST API response on the basis of the list of the account send from the calling method.
        @CreatedBy  : Lodhi
        @CreatedDate: 22/JULY/2013
    */
    private static List<SL_DSML_API_Wrapper.ODO> prepareOrganizationResponse(SL_OrganizationSearch objOS, SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier)
    {
    	List<Account> lstAccount = objOS.searchOrganization();
        List<SL_DSML_API_Wrapper.ODO> lstODO = new List<SL_DSML_API_Wrapper.ODO>(); 
        setAccountId = new Set<String>();
        
        List<Organization_Service__c> lstOS = new List<Organization_Service__c>();
        Map<Id,Set<Id>> mapEServiceIdToSetOfAccId = new Map<Id,Set<Id>>();
        Map<Id,List<SL_DSML_API_Wrapper.SDO>> mapAccIdTolstOfSDO = new Map<Id,List<SL_DSML_API_Wrapper.SDO>>();
        Map<Id, Set<String>> mapOrgIdToSetOfContactId = new Map<Id,Set<String>>();
        
        try
        {
            if(lstAccount.size() > 0)
            {
            	/* Start - Updated by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
                for(Account objAccount : lstAccount)
                {
                	lstOS.addAll(objAccount.Organization_Services__r);
                }
                
                for(Organization_Service__c objOService : [SELECT Electronic_Service__c, Organization__c FROM Organization_Service__c WHERE ID IN : lstOS])
                {
                	if(!mapEServiceIdToSetOfAccId.containskey(objOService.Electronic_Service__c))
                		mapEServiceIdToSetOfAccId.put(objOService.Electronic_Service__c, new Set<Id>{objOService.Organization__c});
                	else
                		mapEServiceIdToSetOfAccId.get(objOService.Electronic_Service__c).add(objOService.Organization__c);
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
                    setAccountId.add(objAccount.Id);//adding this account Id to set to filter the affiliation records.
                    lstODO.add(new SL_DSML_API_Wrapper.ODO(objAccount, hcIdentifier, objOS.decLatitude, objOS.decLongitude, mapAccIdTolstOfSDO.containskey(objAccount.Id) ? mapAccIdTolstOfSDO.get(objAccount.Id) : new List<SL_DSML_API_Wrapper.SDO>(), mapOrgIdToSetOfContactId.containskey(objAccount.Id) ? mapOrgIdToSetOfContactId.get(objAccount.Id) : new Set<String>())); //Adding the ODO instance to the lst to prepare the response.
                }
                /* End - Updated by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
                return lstODO;
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
        @param      : List of Contact
        @Description: This method is called to get the prepare the REST API response on the basis of the list of the Affiliation__c send from the calling method.
        @CreatedBy  : Lodhi
        @CreatedDate: 22/JULY/2013
    */
    private static List<SL_DSML_API_Wrapper.IORO> prepareAffiliationResponse(List<Affiliation__c> lstAffiliations)
    {
        List<SL_DSML_API_Wrapper.IORO> lstIORO = new List<SL_DSML_API_Wrapper.IORO>();
        //Map<Id, List<Affiliation_Service__c>> mapAffiliationIdToLstOfAffiliationService = new Map<Id, List<Affiliation_Service__c>>();//< This map is used to keep the list of theAffiliation_Service__c records corresponding to the affiliation id.
        Map<Id, List<String>> mapAffiliationIdToLstOfElectronicServicesId = new Map<Id, List<String>>(); 
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
                if(setAccountId.contains(objAffiliation.Organization__c))
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