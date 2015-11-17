/*
*Class: SL_DSML_API_MembershipSearch
*Description: This class is used to get the list of IORO records based on the Affiliation Id passed from external systems
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/dsml/memberships') 
global with sharing class SL_DSML_API_MembershipSearch 
{
	/* Start - Variables */
	//!< No varables available.
	/* End - Variables */
	
	/* Start - Constructor */
	global SL_DSML_API_MembershipSearch()
	{
		//<! do nothing.
	}
	/* End - Constructor*/
	
	/* Start - Response wrapper class */
	global class DslmMembershipSearchResponse extends SL_RestResponseWrappers.BaseResponse
    {
    	/* Start - Inner class variables */
        public SL_DSML_API_Wrapper.PDO pdo;
        public List<SL_DSML_API_Wrapper.IORO> ioro;
        /* End - Inner class variables */
        
        /* Start - Parameterized Inner class Contructor */
        public DslmMembershipSearchResponse(SL_DSML_API_Wrapper.PDO pdo, List<SL_DSML_API_Wrapper.IORO> ioros, Integer size, Boolean done)
        {
            super(size, true);
            this.ioro = ioros;
            this.pdo = pdo;
        }
        /* End - Parameterized Inner class Contructor */
        
        /* Start - Parameterized Contructor */
        public DslmMembershipSearchResponse()
        {
            super(0, true);
            this.ioro = null;
            this.pdo = null;
        }
        /* End - Parameterized Contructor */
    }
    /* End - Response wrapper class */
    
	/*
        @MethodName : dslmMembershipSearch
        @param      : SL_DSML_API_Wrapper.PUR pur, SL_DSML_API_Wrapper.IORDE iorde, List<SL_DSML_API_Wrapper.MUR > murs
        @returnType : DslmMembershipSearchResponse
        @Description: This methods will called from the external system to get the Affilaition records in form of IORO wrapper class objects on the basis of the inputs.
    */
    
    @HttpPost
	global static DslmMembershipSearchResponse dslmMembershipSearch(SL_DSML_API_Wrapper.IORDE iorde, List<SL_DSML_API_Wrapper.MUR > mur, SL_DSML_API_Wrapper.PUR pur)   
	{
        Map<Id,Affiliation__c> mapIdToAffiliation = new Map<Id, Affiliation__c>();//!< This map is used to keep the Affiliation records 
        																		  //!< corresponding to Id to pass in  prepareAffiliationResponse methods to get the IORO records...
        List<SL_DSML_API_Wrapper.IORO> lstIORO = new List<SL_DSML_API_Wrapper.IORO>();//!< List of IORO to get the IORO records get from the method prepareAffiliationResponse
        SL_DSML_API_Wrapper.PDO pdo = null;
        try
        {
        	//checking null condition 
	        if(pur!= null)
	        	pdo = new  SL_DSML_API_Wrapper.PDO(pur.hpdId, pur.hpdRequestId); //!< Assigning the appropriate values.
	        	
	        //This condition is for Q8 services from where we get the Organization and provider Ids to match with the Affiliation to generate the response.
	        if(iorde != null && iorde.hpdHasAnOrg != null && iorde.hpdHasAProvider != null && iorde.hpdMemberType != null)
	        {
	        	Set<String> setAffiliationType = new Set<String>();//!< set to keep the type value for query Affiliation records.
	        	for(String strType : iorde.hpdMemberType)//iterating all the hpdMemberType and keep into set to get the valid organization records and the affiliation records..
	            {
	                setAffiliationType.add(strType.trim());//adding the value to the set.
	            }
	            //Query the Affiliation records on the basis of the iorde inputs.
	            mapIdToAffiliation = new Map<Id, Affiliation__c>([SELECT Id, Provider__c, Organization__c, Type__c, Start_Date__c, End_Date__c, Phone__c, Email__c 
								            					  FROM Affiliation__c 
								            					  WHERE Organization__c =: iorde.hpdHasAnOrg AND Provider__c =: iorde.hpdHasAProvider AND Type__c IN : setAffiliationType]);
	        }
	        else if(mur != null && !mur.isEmpty())//This condition is for Q9
	        {
	        	Set<String> setAffiliationIds = new Set<String>();//!< set to keep the Ids for query Affiliation records.
	        	for(SL_DSML_API_Wrapper.MUR objMUR : mur)
	        	{
	        		//checking the null condition.
	        		if(objMUR.uid != null)
	        			setAffiliationIds.add(objMUR.uid.trim());//!< Addding affiliation Ids to the set to query to affiliation records.
	        	}
	        	//Query the Affiliation records on the basis of the iorde inputs.
	            mapIdToAffiliation = new Map<Id, Affiliation__c>([SELECT Id, Provider__c, Organization__c, Type__c, Start_Date__c, End_Date__c, Phone__c, Email__c 
								            					  FROM Affiliation__c 
								            					  WHERE Id IN : setAffiliationIds]);
	        }
	        	
			//checking the null condition and the map has the values. 					  
	        if(mapIdToAffiliation != null && !mapIdToAffiliation.isEmpty())
	        {
	        	lstIORO = prepareAffiliationResponse(mapIdToAffiliation);//!< calling methods to get the list of the IORO records on the basis of the above query affiliation records.
	        	Integer size = 1 + lstIORO.size();//!< setting the size on the basis of the IORO records.
	        	return new DslmMembershipSearchResponse(pdo, lstIORO, size, true);//!< return the result.
	        }
	        else//!< if there no affiliation records fouded as per the parameters
	        	return new DslmMembershipSearchResponse(pdo, lstIORO, 0, true);//!< sending blank response.
        }
        catch(Exception ex)
        {
        	return new DslmMembershipSearchResponse(pdo, lstIORO, 0, false);//!< sending blank response.
        }
	}
	/* End */
	
	/*
        @MethodName : prepareAffiliationResponse
        @param      : Map<Id, Affiliation__c> mapIdToAffiliations
        @returnType : List<SL_DSML_API_Wrapper.IORO>
        @Description: This method returns list of the IORO records on the basis of the Affiliation records passes as parameter.
    */
	private static List<SL_DSML_API_Wrapper.IORO> prepareAffiliationResponse(Map<Id, Affiliation__c> mapIdToAffiliations)
	{
		List<SL_DSML_API_Wrapper.IORO> lstIORO = new List<SL_DSML_API_Wrapper.IORO>();//!< List of IORO records to keep the IORO records on the basis of Affiliaton and return
        Map<Id, List<String>> mapAffiliationIdToLstOfElectronicServicesId = new Map<Id, List<String>>();//!< Map to keep the Ids of the Electronic_Service__c correspondiong to the Affiliation records. 
        try
        {
            //Getting Affiliation_Service__c related to Affiliation record ids.
            for(Affiliation_Service__c objAS : [SELECT Id, Affiliation__c, Electronic_Service__c 
            									FROM Affiliation_Service__c 
                                                WHERE Affiliation__c IN: mapIdToAffiliations.keySet()])
            {
             	if(mapAffiliationIdToLstOfElectronicServicesId.containsKey(objAS.Affiliation__c))
             		mapAffiliationIdToLstOfElectronicServicesId.get(objAS.Affiliation__c).add(objAS.Electronic_Service__c);
             	else
             		mapAffiliationIdToLstOfElectronicServicesId.put(objAS.Affiliation__c, new List<String>{objAS.Electronic_Service__c});
             }
            
             //Iterating the Affiliation__c records to prepare the wrapper class to send the response.
             for(Affiliation__c objAffiliation : mapIdToAffiliations.values())
             {
                if(mapAffiliationIdToLstOfElectronicServicesId.containsKey(objAffiliation.Id))
                    lstIORO.add(new SL_DSML_API_Wrapper.IORO(objAffiliation, mapAffiliationIdToLstOfElectronicServicesId.get(objAffiliation.Id)));//creating the wrapper class instance to send the responseand and adding to the list.
                else
                    lstIORO.add(new SL_DSML_API_Wrapper.IORO(objAffiliation, new List<String>()));//creating the wrapper class instance to send the responseand and adding to the list.
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