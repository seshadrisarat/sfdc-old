/**
* \arg ClassName      		: SL_CustomSearchFeature
* \arg JIRATicket     		: STARGAS-30
* \arg CreatedOn      		: 20/OCT/2014
* \arg LastModifiedOn       : 21/APR/2015
* \arg CreatededBy    		: Pankaj Ganwani
* \arg ModifiedBy     		: Pankaj Ganwani
* \arg Description    		: This class used to handle the SL_CustomSearchFeature page functionality
*/
global without sharing class SL_CustomSearchFeature 
{
	/* Start - Variable */
	public String strZipCode						            						{get;set;}//the variable is used to hold the value of entered zip code by the user
	public String strDivisionCity					            						{get;set;}//this variable is used to hold the value of selected division - city 
	public List<Services_by_Location__c> lstServicesbyLocation  						{get;private set;}//this list is used to hold the records of service chart details corresponding to selected territory's state value
	public Territory__c objTerritory                            						{get;private set;}//this variable is used to show details of selected territory.
	public Price_Table__c objPriceTable													{get;private set;}//this variable is used to show the oil pricing details corresponding to selected territory.
	/* End - Variable */
	
	/* Start - Constructor */
	public SL_CustomSearchFeature()
	{
	    initialization();//calling method to initialize the variables
	}
	/* End - Constructor */
    
    /*
    * MethodName        : initialization
    * param             : NA
    * Description       : This function will initialize the variables.
    */
	private void initialization()
	{
		strZipCode = strDivisionCity = '';		
		objTerritory = new Territory__c();
		lstServicesbyLocation = new List<Services_by_Location__c>();
		objPriceTable = new Price_Table__c();
	}
	/* End */
    
    /*
    * MethodName        : getDivision
    * param             : zip code value
    * Description       : This function will search all the divisions corresponding to the zip code.
    */
    @RemoteAction
    global static List<String> getDivision(String strZipCode)
    {	
    	List<String> lstCompanyDivisionCity = new List<String>();
    	
    	if(!lstCompanyDivisionCity.isEmpty())
    		lstCompanyDivisionCity.clear();	//clearing the list	
    	
    	if(!String.isBlank(strZipCode))	
    	{
	        try
	        {
		        //fetching the territories corresponding to entered zip code
		        for(Territory__c objTerritory : [SELECT Division_Service_Company__c, Division__r.Name, City__c, Division__r.State__c
		        								 FROM Territory__c
		        								 WHERE Zip_Postal_Code__c =:strZipCode AND IsActive__c = true])
		        {
		        	//checking if service company and city is not empty
		        	if(String.isNotEmpty(objTerritory.Division_Service_Company__c) && String.isNotEmpty(objTerritory.City__c))
		        	{
		        		//framing string for territory
		        		String strCompanyDivisionCity = String.format('{0} ### {1} ### {2}', new List<String>{objTerritory.Division_Service_Company__c.trim(), objTerritory.Division__r.Name.trim(), objTerritory.City__c.trim()});
		        		//adding it to list
		        		lstCompanyDivisionCity.add(String.isNotEmpty(objTerritory.Division__r.State__c) ? strCompanyDivisionCity + ' ### ' + objTerritory.Division__r.State__c : strCompanyDivisionCity);
		        	}
		        }
	        }
	        catch(Exception ex)
	        {
	        	System.debug('=====================Exception======================'+ex.getMessage());
	        }
    	}
    	return lstCompanyDivisionCity;		
    }
    /* End */
    
    /*
    * MethodName        : searchRecords
    * param             : NA
    * Description       : This function will search related records.
    */
    public void searchRecords()
    {    	
    	//checking if picklist value and zip code is not empty
    	if(String.isBlank(strDivisionCity) || String.isBlank(strZipCode))
    	{
    		objTerritory = null;//blank out the details of previous territory from page if division city is blank
    		objPriceTable = null;//blank out the details of previous pricing table from page if division city is blank 
    		if(!lstServicesbyLocation.isEmpty())
    			lstServicesbyLocation.clear();
    		Apexpages.addMessage(new apexpages.Message(ApexPages.Severity.INFO,Label.SL_FillCompanyDivision));
    		return;
    	}
    	
    	if(!lstServicesbyLocation.isEmpty())
    		lstServicesbyLocation.clear();//clearing the list if this is not empty
    	
		//splitting the string to get the values of selected service company, state and city
		String [] strSplittedString = strDivisionCity.split('###');
				
		try
		{
			//fetching the most recent territory record corresponding to selected service company and city commbination
			List<Territory__c> lstTerritory= [SELECT Id, Region__c, City__c, Zip_Postal_Code__c, Division__r.Name, Travel_Zone__c, Service_Zone__c, Delivery_Zone__c, Division__r.Division_Oil_Pricing_Group__c,
								   		 			 Division_Service_Company__c, Division__r.Phone__c, Division_Database__c, Oil_Rep__r.Name, Propane_Rep__r.Name, RESS_Rep__r.Name
								  			  FROM   Territory__c
								  			  WHERE  Zip_Postal_Code__c =:strZipCode AND Division__r.Name =: strSplittedString[1].trim() AND City__c =:strSplittedString[2].trim() AND Division_Service_Company__c=:strSplittedString[0].trim()
								  			  ORDER BY CreatedDate DESC LIMIT 1];
			
			
			
			//if list is empty simply return
			if(lstTerritory.isEmpty())
				return;
			
			objTerritory = lstTerritory[0];//assigning the value to territory object
			
			objPriceTable = new Price_Table__c();//creating new instance of price table object
			
			//checking if division service company field value is blank for the selected Territory, then show a user friendly message to user.
			if(String.isEmpty(objTerritory.Division_Service_Company__c))
				Apexpages.addMessage(new apexpages.Message(ApexPages.Severity.INFO,Label.SL_EmptyServiceCompany));						
			
			//iterating over pricing table object to fetch pricing details corresponding to selected territory's group and oil record type
			for(Price_Table__c objPricingTable : [SELECT Variable_Price__c, Fixed_Price__c, Ceiling_Limit__c, Ceiling_Initial__c, Ceiling_Fee__c 
												  FROM Price_Table__c   
		 										  WHERE Division_Group__c =: objTerritory.Division__r.Division_Oil_Pricing_Group__c AND RecordType.DeveloperName =:'Oil' AND IsActive__c =true])
		   {
		  		if(objPricingTable.Variable_Price__c!=null)
		  			objPriceTable.Variable_Price__c = objPricingTable.Variable_Price__c;
		  			
		  		if(objPricingTable.Fixed_Price__c!=null)
		  			objPriceTable.Fixed_Price__c = objPricingTable.Fixed_Price__c;
		  		
		  		if(objPricingTable.Ceiling_Limit__c!=null)
		  			objPriceTable.Ceiling_Limit__c = objPricingTable.Ceiling_Limit__c;
		  		
		  		if(objPricingTable.Ceiling_Initial__c!=null)
		  			objPriceTable.Ceiling_Initial__c = objPricingTable.Ceiling_Initial__c;
		  		
		  		if(objPricingTable.Ceiling_Fee__c!=null)
		  			objPriceTable.Ceiling_Fee__c = objPricingTable.Ceiling_Fee__c;
		   }
			
			//checking if splitted string contains state part
			if(strSplittedString.size() == 4)
			{
				//getting the values of service chart details
				lstServicesbyLocation = [SELECT Id,
	                                        	Heating_Oil__c,
	                                        	Propane__c,
	                                         	Plumbing__c,
	                                         	Gas_Service__c,
	                                         	A_C_Service__c,
	                                         	Generators__c,
	                                         	Generator_Service__c,
	                                         	Security__c,
	                                        	Chimney__c,
	                                         	HVAC__c,
	                                         	Duct_Cleaning__c,
	                                         	Electrical__c,
	                                         	Energy_Audits__c,
	                                         	USG_E__c,
	                                         	Depot_Name_temp__c,
	                                         	Brand__c,
	                                         	State__c
	                                    FROM 	Services_by_Location__c
	                                   WHERE 	State__c =: strSplittedString[3].trim() ORDER BY Brand__c, State__c, Depot_Name_temp__c];
			}
		}
		catch(Exception ex)
		{
			System.debug('==============Exception==============='+ex.getMessage());
		}
    		
    }
    /* End */
}