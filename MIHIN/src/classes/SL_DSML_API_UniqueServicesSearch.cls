/*
*Class: SL_DSML_API_UniqueServicesSearch
*Description: This class is used to get the Affiliation records based on the input parameters passed from external system using DSML
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/

@RestResource(urlMapping='/dsml/services') 
global with sharing class SL_DSML_API_UniqueServicesSearch 
{	
	/* Start - Variables */
	//!< No varables available.
	/* End - Variables */
	
	/* Start - Constructor */
	global SL_DSML_API_UniqueServicesSearch()
	{
		//<! do nothing.
	}
	/* End - Constructor*/
	
	/* Start - Response wrapper class */
	global class DslmUniqueServicesSearchResponse extends SL_RestResponseWrappers.BaseResponse
    {
    	/* Start - Inner class variables */
    	public SL_DSML_API_Wrapper.PDO pdo;
        public List<SL_DSML_API_Wrapper.SDO> sdo;
        /* End - Inner class variables */
        
		/* Start - Parameterized Inner class Contructor */
        public DslmUniqueServicesSearchResponse( SL_DSML_API_Wrapper.PDO pdo, List<SL_DSML_API_Wrapper.SDO> sdo, Integer size, Boolean done)
        {
            super(size, true);
            this.sdo = sdo;
            this.pdo = pdo;
        }
        /* End - Parameterized Inner class Contructor */
        
        /* Start - Parameterized Contructor */
        public DslmUniqueServicesSearchResponse()
        {
            super(0, true);
            this.sdo = null;
            this.pdo = null;
        }
        /* End - Parameterized Contructor */
    }
    /* End - Response wrapper class */
    
	/*
        @MethodName : dslmUniqueServicesSearch
        @param      : List<SL_DSML_API_Wrapper.SUR> sur, SL_DSML_API_Wrapper.PUR pur
        @returnType : DslmUniqueServicesSearchResponse
        @Description: This methods will called from the external system to get the Affilaition records in form of IORO wrapper class objects on the basis of the inputs.
    */ 
    @HttpPost
	global static DslmUniqueServicesSearchResponse dslmUniqueServicesSearch(List<SL_DSML_API_Wrapper.SUR> sur, SL_DSML_API_Wrapper.PUR pur)   
	{
		List<SL_DSML_API_Wrapper.SDO> lstSDO = new List<SL_DSML_API_Wrapper.SDO>();//!< This list is used to keep the SDO corresponding to each Electronic_Service__c record.
		SL_DSML_API_Wrapper.PDO pdo = null;
		try
		{
			//checking null condition 
	        if(pur!= null)
	        	pdo = new  SL_DSML_API_Wrapper.PDO(pur.hpdId, pur.hpdRequestId); //!< Assigning the appropriate values.
	        if(sur != null && !sur.isEmpty())
	        {
	        	Set<String> setElectronicServiceIds = new Set<String>();//!< set to keep the ids to query Electronic Service records.
	        	for(SL_DSML_API_Wrapper.SUR objSUR : sur)
	        	{
	        		//checking the null condition.
	        		if(objSUR.uid != null)
	        			setElectronicServiceIds.add(objSUR.uid.trim());//!< Addding Electronic Service Ids to the set to query to Electronic Service records.
	        	}
	        	lstSDO = SL_DSML_API_Wrapper.prepareElectronicServicesResponse(setElectronicServiceIds);
	        	Integer size = 1 + lstSDO.size();
	        	return new DslmUniqueServicesSearchResponse(pdo, lstSDO, size, true);
	        }
	        else
	        {
	        	return new DslmUniqueServicesSearchResponse(pdo, lstSDO, 0, true);
	        }
		}
		catch(Exception ex)
		{
			return new DslmUniqueServicesSearchResponse(pdo, lstSDO, 0, false);
		}
	}
	/* End */
}