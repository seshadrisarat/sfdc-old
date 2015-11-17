/*
*Class: SL_DSML_API_CredentialWrite
*Description: This class is used for creating and updating Credential records with respective Providers update.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/dsml/writelicenses') 
global with sharing class SL_DSML_API_CredentialWrite 
{
	//Reponse wrapper class.
	global class DslmCredentialWriteResponse
    {
    	public SL_DSML_API_Wrapper.PUR pur;
        public List<SL_DSML_API_Wrapper.IUR> iur; 
        
        public DslmCredentialWriteResponse(SL_DSML_API_Wrapper.PUR pur, List<SL_DSML_API_Wrapper.IUR> iur)
        {
            this.pur = pur;
            this.iur = iur;
        }
    }
    
    @HttpPost
    global static DslmCredentialWriteResponse dslmCredentialWrite(SL_DSML_API_Wrapper.PDO pdo, List<SL_DSML_API_Wrapper.NPI> npi)   
    {
    	RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Set<String> setNPIs = new Set<String>();
        Set<String> setLicenses = new Set<String>();
        
        for(SL_DSML_API_Wrapper.NPI objNPI : npi)
        {
        	if(objNPI.npiNumber != null)
        		setNPIs.add(objNPI.npiNumber);
        	for(SL_DSML_API_Wrapper.LDO objLDO : objNPI.ldo)
        	{
        		if(objLDO.licenseNumber != null)
        			setLicenses.add(objLDO.licenseNumber);
        	}
        	
        }
        SL_ProvidersSearch objProviderSearch = new SL_ProvidersSearch();
        objProviderSearch.setNPI = setNPIs;
        objProviderSearch.setLicenses = setLicenses;
        return prepareResonse(objProviderSearch, pdo, npi);
    }
    
    
    private static DslmCredentialWriteResponse prepareResonse(SL_ProvidersSearch objProviderSearch, SL_DSML_API_Wrapper.PDO pdo, List<SL_DSML_API_Wrapper.NPI> npi)
    {
    	List<Contact> lstContact = objProviderSearch.searchProvider();
    	Map<String, List<Contact>> mapNPIToLstContact = new Map<String,List<Contact>>();
    	Map<String, List<Provider_Credential__c>> mapProviderId_LicenseToLstProviderCredential = new Map<String, List<Provider_Credential__c>>();
    	Map<String, Provider_Credential__c> mapProviderId_LicenseToProviderCredentialUpsert = new Map<String, Provider_Credential__c>();
    	Map<String, Contact> mapNPIToContactToUpdate = new Map<String, Contact>();
    	Map<String, Database.SaveResult> mapContactSaveResult = new Map<String, Database.SaveResult>();
    	Map<String, Database.UpsertResult> mapProviderCredentialUpsertResult = new Map<String, Database.UpsertResult>();
    	
    	List<Contact> lstContactToUpdate = new List<Contact>();
    	List<Provider_Credential__c> lstProviderCredentialUpsert = new List<Provider_Credential__c>();
    	
    	List<RecordType> lstRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Provider_License' AND SobjectType = 'Provider_Credential__c'];
    	
		for(Contact objContact : lstContact)
		{
			if(!mapNPIToLstContact.containsKey(objContact.NPI__c))
				mapNPIToLstContact.put(objContact.NPI__c, new List<Contact>());
			mapNPIToLstContact.get(objContact.NPI__c).add(objContact);
			
			for(Provider_Credential__c objPC : objContact.Provider_Credentials__r)
			{
				if(!mapProviderId_LicenseToLstProviderCredential.containsKey(objPC.Provider__c +'__'+objPC.Credential_Number__c))
					mapProviderId_LicenseToLstProviderCredential.put(objPC.Provider__c +'__'+objPC.Credential_Number__c, new List<Provider_Credential__c>());
				mapProviderId_LicenseToLstProviderCredential.get(objPC.Provider__c +'__'+objPC.Credential_Number__c).add(objPC);
			}
		}
		
		for(SL_DSML_API_Wrapper.NPI objNPI : npi)
    	{
    		if(objNPI.npiNumber != null && mapNPIToLstContact.containsKey(objNPI.npiNumber) && mapNPIToLstContact.get(objNPI.npiNumber).size() == 1)
    		{
    			lstContactToUpdate.add( new Contact(Id = mapNPIToLstContact.get(objNPI.npiNumber)[0].Id,
    												NPI__c = mapNPIToLstContact.get(objNPI.npiNumber)[0].NPI__c,
    												NPI_Status__c = objNPI.npiStatus, Access__c = objNPI.access));
    												
        		for(SL_DSML_API_Wrapper.LDO objLDO : objNPI.ldo)
        		{
        			if(mapProviderId_LicenseToLstProviderCredential.containsKey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber)
        				&& mapProviderId_LicenseToLstProviderCredential.get(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber).size() == 1)
        			{
        				lstProviderCredentialUpsert.add(new Provider_Credential__c(Id = mapProviderId_LicenseToLstProviderCredential.get(
																						    mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ 
																						    objLDO.licenseNumber)[0].Id ,
																						Credential_Number__c = objLDO.licenseNumber,
																					    Provider__c = mapNPIToLstContact.get(objNPI.npiNumber)[0].Id,
																					    State__c = objLDO.licenseState,
																					    Current_Status__c = objLDO.licenseStatus,
																					    Type__c = 'License', 
																					    RecordTypeId = (!lstRT.isEmpty()) ? lstRT[0].Id : null));
        			}
        			else if(!mapProviderId_LicenseToLstProviderCredential.containsKey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber))
        			{
        				lstProviderCredentialUpsert.add(new Provider_Credential__c(Provider__c = mapNPIToLstContact.get(objNPI.npiNumber)[0].Id,
																				   State__c = objLDO.licenseState,
																				   Credential_Number__c = objLDO.licenseNumber,
																				   Current_Status__c = objLDO.licenseStatus,
																				   Type__c = 'License', 
																				   RecordTypeId = (!lstRT.isEmpty()) ? lstRT[0].Id : null));
        			}
        		}
    		}
    	}
    	
    	List<Database.SaveResult> lstSaveResult = Database.update(lstContactToUpdate, false);
    	List<Database.UpsertResult> lstUpserResult = Database.upsert (lstProviderCredentialUpsert, false);
    	
    	for(Integer index = 0; index < lstContactToUpdate.size(); index++)
    	{
    		mapNPIToContactToUpdate.put(lstContactToUpdate[index].NPI__c, lstContactToUpdate[index]);
    		mapContactSaveResult.put(lstContactToUpdate[index].NPI__c, lstSaveResult[index]);
    	}
    	
    	for(Integer index = 0; index < lstProviderCredentialUpsert.size(); index++)
    	{
    		mapProviderId_LicenseToProviderCredentialUpsert.put(lstProviderCredentialUpsert[index].Provider__c +'__'+lstProviderCredentialUpsert[index].Credential_Number__c, 
    															lstProviderCredentialUpsert[index]);
    		mapProviderCredentialUpsertResult.put(lstProviderCredentialUpsert[index].Provider__c +'__'+lstProviderCredentialUpsert[index].Credential_Number__c, 
    										      lstUpserResult[index]);
    	}
    	
    	List<SL_DSML_API_Wrapper.IUR> iur = new List<SL_DSML_API_Wrapper.IUR>();
    	
    	for(SL_DSML_API_Wrapper.NPI objNPI : npi)
    	{
    		List<SL_DSML_API_Wrapper.LUR> lur = new List<SL_DSML_API_Wrapper.LUR>();
    		SL_DSML_API_Wrapper.IUR objIUR = new SL_DSML_API_Wrapper.IUR(null, objNPI.npiNumber, '', null);
    		if(objNPI.npiNumber != null && mapNPIToLstContact.containsKey(objNPI.npiNumber) && mapNPIToLstContact.get(objNPI.npiNumber).size() == 1 
    			&& mapContactSaveResult.containskey(objNPI.npiNumber) && mapContactSaveResult.get(objNPI.npiNumber).isSuccess())
    		{
        		for(SL_DSML_API_Wrapper.LDO objLDO : objNPI.ldo)
        		{
        			if(((mapProviderId_LicenseToLstProviderCredential.containsKey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber)
        				&& mapProviderId_LicenseToLstProviderCredential.get(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber).size() <= 1)
        				||!mapProviderId_LicenseToLstProviderCredential.containsKey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber))
        				&& mapProviderCredentialUpsertResult.containskey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber)
        				&& mapProviderCredentialUpsertResult.get(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber).isSuccess())
        			{
        				lur.add(new SL_DSML_API_Wrapper.LUR(mapProviderId_LicenseToProviderCredentialUpsert.get(
        													mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber).Id,
        													objLDO.licenseNumber, true, ''));
        			}
        			else if(((mapProviderId_LicenseToLstProviderCredential.containsKey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber)
        				&& mapProviderId_LicenseToLstProviderCredential.get(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber).size() <= 1)
        				||!mapProviderId_LicenseToLstProviderCredential.containsKey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber))
        				&& mapProviderCredentialUpsertResult.containskey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber)
        				&& !mapProviderCredentialUpsertResult.get(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber).isSuccess())
        			{
        				lur.add(new SL_DSML_API_Wrapper.LUR(null, objLDO.licenseNumber, false, 'Duplicate Licenses found with this LicenseNumber'));
        			}
        			else if(mapProviderId_LicenseToLstProviderCredential.containsKey(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber)
        				&& mapProviderId_LicenseToLstProviderCredential.get(mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber).size() > 1)
        			{
        				lur.add(new SL_DSML_API_Wrapper.LUR(null, objLDO.licenseNumber, false, 
        													mapProviderCredentialUpsertResult.get(
        													mapNPIToLstContact.get(objNPI.npiNumber)[0].Id +'__'+ objLDO.licenseNumber).getErrors()[0].getMessage()));
        			}
        		}
        		objIUR = new SL_DSML_API_Wrapper.IUR(mapNPIToContactToUpdate.get(objNPI.npiNumber).Id, objNPI.npiNumber, '', lur);
    		}
    		else if(objNPI.npiNumber != null && mapNPIToLstContact.containsKey(objNPI.npiNumber) && mapNPIToLstContact.get(objNPI.npiNumber).size() == 1 
    			&& mapContactSaveResult.containskey(objNPI.npiNumber) && !mapContactSaveResult.get(objNPI.npiNumber).isSuccess())
    		{
    			objIUR = new SL_DSML_API_Wrapper.IUR(null, objNPI.npiNumber, mapContactSaveResult.get(objNPI.npiNumber).getErrors()[0].getMessage(), lur);
    		}
    		else if(objNPI.npiNumber != null && !mapNPIToLstContact.containsKey(objNPI.npiNumber))
    		{
    			objIUR = new SL_DSML_API_Wrapper.IUR(null, objNPI.npiNumber, 'NPI not found', lur);
    		}
    		else if(objNPI.npiNumber != null && mapNPIToLstContact.containsKey(objNPI.npiNumber) && mapNPIToLstContact.get(objNPI.npiNumber).size() > 1)
    		{
    			objIUR = new SL_DSML_API_Wrapper.IUR(null, objNPI.npiNumber, 'Multiple Providers matching this NPI', lur);
    		}
    		iur.add(objIUR);
    	}
    	
    	return new DslmCredentialWriteResponse(new SL_DSML_API_Wrapper.PUR(pdo.hpdId, pdo.hpdRequestId), iur);
    }
}