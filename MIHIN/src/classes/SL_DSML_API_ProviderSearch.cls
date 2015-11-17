/*
*Class: SL_DSML_API_ProviderSearch
*Description: This class is used to get the details of Contact records based on the parameters passed from external system using DSML
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/dsml/providers') 
global with sharing class SL_DSML_API_ProviderSearch 
{
    global class DslmProviderSearchResponse extends SL_RestResponseWrappers.BaseResponse
    {
        public List<SL_DSML_API_Wrapper.IDO> ido;
        public SL_DSML_API_Wrapper.PDO pdo;
        
        public DslmProviderSearchResponse(List<SL_DSML_API_Wrapper.IDO> idos, SL_DSML_API_Wrapper.PDO pdo, Boolean done){
            super(idos.size(), done);
            this.ido = idos;
            this.pdo = pdo;
        }
        
        public DslmProviderSearchResponse(){
            super(0, true);
            this.ido = null;
            this.pdo = null;
        }
    }
    
    @HttpPost
    global static DslmProviderSearchResponse dslmProviderSearch(List<SL_DSML_API_Wrapper.IUR> iur, SL_DSML_API_Wrapper.IDE ide, SL_DSML_API_Wrapper.PUR pur)   
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //Creating Provider serch class instance to call the serach provider methods and get the serached Providers records.
        SL_ProvidersSearch objPS = new SL_ProvidersSearch();
        SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier = new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null);
        List<Contact> lstContact = new List<Contact>();
        try
        {
	        //This condition is for Q2 services from where we get the Provider record Id if that is satisfied then we will do the searching on the basis of the provider Id.
	        if (iur != null && iur.size() > 0)
	        {
	        	for(SL_DSML_API_Wrapper.IUR objIUR : iur)
	        	{
	        		objPS.setProviderId.add(objIUR.uid);
	        	}
	        	//lstContact = objPS.searchProvider();//calling SL_ProvidersSearch class method to search the provider records as per the values set to the public variables.
	        }
	        else if (ide != null)
	        {
	        	
	        	if(ide.hcIdentifier!= null)
	        		hcIdentifier = ide.hcIdentifier;
	        	
	        	/* Start - Added By Pankaj Ganwani as per the requirement of MIHIN-116 */
	        	if(hcIdentifier!=NULL && String.isNotEmpty(hcIdentifier.ID))
	        	{
	        		String strProviderIdentifier = String.escapeSingleQuotes(hcIdentifier.ID).trim();
					String strQuery = 'SELECT Provider__c FROM Provider_Identifier__c WHERE Name =:strProviderIdentifier';
					
					if(String.isNotEmpty(hcIdentifier.Type))
					{
						String strProviderIdentifierType = String.escapeSingleQuotes(hcIdentifier.Type).trim();
						strQuery+=' AND Type__c =:strProviderIdentifierType';
					}
					for(Provider_Identifier__c objProviderIdentifier : Database.query(strQuery))
					{
						objPS.setProviderId.add(objProviderIdentifier.Provider__c);
					}
	        	}
	        	/* End - Added By Pankaj Ganwani as per the requirement of MIHIN-116 */
	        	else
	        	{
		            objPS = ide.createProviderSearch(); 
		            objPS.setOffSetLimit(pur);
		            //lstContact = objPS.searchProvider();//calling SL_ProvidersSearch class method to search the provider records as per the values set to the public variables.
	        	}
	        } 
	        
        }
        catch(Exception ex)
        {
        	
        }
        
        return prepareResponse(objPS, pur, hcIdentifier); //calling function which will return the response of the wrapper class.
    }
    
    
    /*
        @MethodName : prepareResponse
        @param      : List of Contact
        @Description: This method is called to get the prepare the REST API response on the basis of the list of the contact send from the calling method.
        @CreatedBy  : Lodhi
        @CreatedDate: 8/JULY/2013
    */
    private static DslmProviderSearchResponse prepareResponse(SL_ProvidersSearch objPS, SL_DSML_API_Wrapper.PUR pur, SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier)
    {
    	List<Contact> lstContact = objPS.searchProvider();
        List<SL_DSML_API_Wrapper.IDO> lstIDO = new List<SL_DSML_API_Wrapper.IDO>();//This list contains all the response record to send to the extrernal system.
        Set<Id> setAffiliationIds = new Set<Id>();
        Map<Id, Set<Id>> mapEServiceToSetOfProvider = new Map<Id, Set<Id>>();
        Map<Id, List<SL_DSML_API_Wrapper.SDO>> mapProviderIdToSDO = new Map<Id, List<SL_DSML_API_Wrapper.SDO>>();
        
        if(lstContact.size() > 0)
        {
        	/* Start - Added by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
            for(Contact objContact : lstContact)
            {
            	if(!objContact.Affiliations__r.isEmpty())
            		setAffiliationIds.addAll((new Map<Id, Affiliation__c>(objContact.Affiliations__r)).keyset());
            }
            
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
            /* End - Added by Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110(Read API v18)*/
            //Iterating the lstContact to prepare the response in proper format.
            for(Contact objContact : lstContact)
            {
                lstIDO.add(new SL_DSML_API_Wrapper.IDO(objContact, hcIdentifier, objPS.decLatitude, objPS.decLongitude, mapProviderIdToSDO.containskey(objContact.Id) ? mapProviderIdToSDO.get(objContact.Id) : new List<SL_DSML_API_Wrapper.SDO>()));//adding this IDO instance to the lst to send the response.
            }
        }
        
        SL_DSML_API_Wrapper.PDO pdo = null;
        
        if(pur!= null)
        	pdo = new  SL_DSML_API_Wrapper.PDO(pur.hpdId, pur.hpdRequestId);
        
        //if there is no provider as per the request.
        if(lstIDO.isEmpty())
        {
            return  new DslmProviderSearchResponse(lstIDO, pdo, true);// returning the response.
        }
        else
        {
            //If the provider is greater than 200.
            if(lstIDO.size() >= 201)
            {
                lstIDO.remove(200);
                return new DslmProviderSearchResponse(lstIDO, pdo, false); // returning the response.
            }   
            else
            {
                return new DslmProviderSearchResponse(lstIDO, pdo, true); // returning the response.
            }   
        } 
    }
    
    /* End - Method */
}