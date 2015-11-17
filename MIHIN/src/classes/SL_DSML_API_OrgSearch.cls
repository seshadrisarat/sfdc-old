/*
*Class: SL_DSML_API_OrgSearch
*Description: This class is used to get search results for organization based on the parameters passed from external systems using DSML
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/dsml/organizations') 
global with sharing class SL_DSML_API_OrgSearch 
{
    global class DslmOrgSearchResponse extends SL_RestResponseWrappers.BaseResponse
    {
        public List<SL_DSML_API_Wrapper.ODO> odo;
        public SL_DSML_API_Wrapper.PDO pdo;
        
        public DslmOrgSearchResponse(List<SL_DSML_API_Wrapper.ODO> odos, SL_DSML_API_Wrapper.PDO pdo, Boolean done){
            super(odos.size(), done);
            this.odo = odos;
            this.pdo = pdo;
        }
        
        public DslmOrgSearchResponse(){
            super(0, true);
            this.odo = null;
            this.pdo = null;
        }
        
    }    
    
    @HttpPost
    global static DslmOrgSearchResponse dslmOrgSearch(List<SL_DSML_API_Wrapper.OUR> our, SL_DSML_API_Wrapper.ODE ode, SL_DSML_API_Wrapper.PUR pur)   
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier = new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null);
        try
        {
	        SL_OrganizationSearch objOS = new SL_OrganizationSearch();
	        
	        if (our != null && our.size() > 0)
	        {
	        	for(SL_DSML_API_Wrapper.OUR objOUR : our)
	        	{
	        		objOS.setAccountId.add(objOUR.uid);
	        	}
	        	return prepareResponse(objOS, pur, hcIdentifier);//This method will return the response.
	            //objOS = our.createOrganizationSearch();//This method will set the public variable of the Org Search class and return the instance of same.
	        } 
	        else if (ode != null)
	        {
	        	if(ode.hcIdentifier != null)
	        		hcIdentifier = ode.hcIdentifier;
	        	/* Start - Added By Pankaj Ganwani as per the requirement of MIHIN-117 */
	        	if(hcIdentifier!=NULL && String.isNotEmpty(hcIdentifier.ID))
	        	{
	        		String strOrgIdentifier = String.escapeSingleQuotes(hcIdentifier.ID).trim();
					String strQuery = 'SELECT Organization__c FROM Organization_Identifier__c WHERE Name =: strOrgIdentifier';
					
					if(String.isNotEmpty(hcIdentifier.Type))
					{
						String strOrgIdentifierType = String.escapeSingleQuotes(hcIdentifier.Type).trim();
						strQuery+=' AND Type__c =: strOrgIdentifierType';
					}
					for(Organization_Identifier__c objOrgIdentifier : Database.query(strQuery))
					{
						objOS.setAccountId.add(objOrgIdentifier.Organization__c);
					}
	        	}
	        	/* End - Added By Pankaj Ganwani as per the requirement of MIHIN-117 */
	        	else
	        	{
		        	objOS = ode.createOrganizationSearch();//This method will set the public variable of the Org Search class and return the instance of same.
		        	objOS.setOffSetLimit(pur); //setting the offset and limit.
	        	}
	        	return prepareResponse(objOS, pur,hcIdentifier);//This method will return the response.
	        } 
        }
        catch(Exception ex)
        {
        	return null;
        }
       	return new DslmOrgSearchResponse(new List<SL_DSML_API_Wrapper.ODO>(), null, true);
    }
    
    /*
		@MethodName : prepareResponse
		@param      : List of Account
		@Description: This method is called to get the prepare the REST API response on the basis of the list of the contact send from the calling method.
		@CreatedBy  : Lodhi
		@CreatedDate: 15/JULY/2013
	*/
	private static DslmOrgSearchResponse prepareResponse(SL_OrganizationSearch objOS, SL_DSML_API_Wrapper.PUR pur, SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier)
	{
		List<SL_DSML_API_Wrapper.ODO> lstODO = new List<SL_DSML_API_Wrapper.ODO>(); 
		List<Account> lstAccount = objOS.searchOrganization();
		
		List<Organization_Service__c> lstOS = new List<Organization_Service__c>();
        Map<Id,Set<Id>> mapEServiceIdToSetOfAccId = new Map<Id,Set<Id>>();
        Map<Id,List<SL_DSML_API_Wrapper.SDO>> mapAccIdTolstOfSDO = new Map<Id,List<SL_DSML_API_Wrapper.SDO>>();
		Map<Id, Set<String>> mapOrgIdToSetOfContactId = new Map<Id,Set<String>>();
		
		SL_DSML_API_Wrapper.PDO pdo = null;
        
        if(pur!= null)
        	pdo = new  SL_DSML_API_Wrapper.PDO(pur.hpdId, pur.hpdRequestId);
        	
		if(lstAccount.size() > 0)
		{
			/* Start - Added by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
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
			/* End - Added by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
			
			for(Account objAccount : lstAccount)
			{  
    			lstODO.add(new SL_DSML_API_Wrapper.ODO(objAccount, hcIdentifier, objOS.decLatitude, objOS.decLongitude, mapAccIdTolstOfSDO.containskey(objAccount.Id) ? mapAccIdTolstOfSDO.get(objAccount.Id) : new List<SL_DSML_API_Wrapper.SDO>(), mapOrgIdToSetOfContactId.containskey(objAccount.Id) ? mapOrgIdToSetOfContactId.get(objAccount.Id) : new Set<String>())); //Adding the ODO instance to the lst to prepare the response.
			}
			
			//if there is no account as per the request.
	        if(lstODO.isEmpty())
	        {
	            return  new DslmOrgSearchResponse(lstODO, pdo, true);// returning the response.
	        }
	        else
	        {
	        	//If the account is greater than 200.
	            if(lstODO.size() >= 201)
	            {
	                lstODO.remove(200);
	                return new DslmOrgSearchResponse(lstODO, pdo, false); // returning the response.
	            }   
	            else
	            {
	                return new DslmOrgSearchResponse(lstODO, pdo, true); // returning the response.
	            }   
	        } 
		}
		return new DslmOrgSearchResponse(lstODO, pdo, true);
	}
	/* End */
}