/**  
* \arg ClassName      : SL_ContractReviewPDF
* \arg JIRATicket     : STARGAS-12
* \arg CreatedOn      : 25/JUL/2014
* \arg LastModifiedOn : 25/JUL/2014
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is controller is used for SL_ContractReviewPDF
*/
public without sharing class SL_ContractReviewPDF {
	
	public Opportunity objOpportunity            {get; set;}// Oppportunity Binded with Pdf Report
	public Welcome_Kit__c objWelcomeKit			 {get; set;}// Welcome kit object to store information regarding current Contract record.
	public Boolean isCeiling					 {get; set;}// If Price is Ceiling
	public Boolean isFixed						 {get; set;}// If Pricing TYpe is fixed
	public Boolean isCeilingWithFee				 {get; set;}// If Price TYpe is Ceiling With Fee
	public List<String> lstImage1				 {get; set; }//Static Resource Path for SL_PDFImages1 resource, there are three resources as the 
													//size of static resource can't be greater than 5MB 
	public List<String> lstImage2				 {get; set; }// List of Static Resource Path for SL_PDFImages2 Static resource
	public List<String> lstImage3				 {get; set; }// List of Static Resource Path for SL_PDFImages3 static resource
	public String strServiceCompany				 {get; set; }// variable to hold value of service company field on Opportunity record.
	public List<Prospect_Service_Contract__c> lstPSC	{get;set;}// this list is used to hold the service contract records corresponding to current Opportunity	
	public SL_ContractReviewPDF() 
	{
		isCeiling = isFixed = isCeilingWithFee= false; //Initailizing the variables
		strServiceCompany = '';
		lstPSC = new List<Prospect_Service_Contract__c>();//Initializing the list
		String strOpportunityId = ApexPages.currentPage().getParameters().get('oppid');
		String strWelcomeKitId = ApexPages.currentPage().getParameters().get('id');
		//Querying Opportunity
        objOpportunity=[SELECT Id, Sold_Date__c, Account.ShippingCountry,X10_Business_Days_After_Sold_Date__c, Territory__r.Division__r.Phone__c, 
	       			 	Account.Name,  Account.IsPersonAccount, Ceiling_Limit__c ,Ceiling_Fee__c ,
	        			Estimated_1st_Delivery_Date__c, Delivery_Option__c ,Price_Plan_Start_Date__c, Price_Plan_End_Date__c,Account.ShippingState,
	        			Account.ShippingStreet, Account.ShippingCity, Account.ShippingPostalCode, Account.BillingCountry, AccountId,  Account.Energy_AccountNumLong__c,
	                  	Service_Contract_Name_txt__c, Service_Contract__c, Payments_Start_Date__c, Service_Code__c, is_budget__c, pmt_per_period__c,
	                  	promotion_code__c , Territory__r.Division__r.Service_Company__c, price_gallon__c, Pricing_Type__c, Account.Delivery_State__c,
	                  	Delivery_State2__c, Delivery_City2__c, Delivery_Street2__c, Delivery_Zip2__c, Billing_Street__c, Billing_State__c, Billing_Zip__c,
	                  	Billing_City__c, Territory__r.Division_Service_Company__c
                   		FROM Opportunity WHERE Id =: strOpportunityId];
		
		//Fetching record of current welcome kit record
		List<Welcome_Kit__c> lstWelcomeKit = [SELECT Signed_Date__c, Electronic_Signature__c, Email__c, IP_Address__c FROM Welcome_Kit__c WHERE Id =:strWelcomeKitId LIMIT 1];
		if(!lstWelcomeKit.isEmpty())
			objWelcomeKit = lstWelcomeKit[0];//assigning the value to welcome kit object
		
		strServiceCompany = objOpportunity.Territory__r.Division__r.Service_Company__c;
		if(objOpportunity.Pricing_Type__c != null)
		{
			isCeilingWithFee  = isCeilingWithFeeTrue(objOpportunity.Pricing_Type__c);
			isCeiling = isCeilingWithFee != true? isCeilingTrue(objOpportunity.Pricing_Type__c): false;
			isFixed =  !objOpportunity.Pricing_Type__c.contains('Ceiling') && objOpportunity.Pricing_Type__c != 'Variable' ? true: false ;
		}
		
        //List of Images's Path to display under Service Contract   
        //Used 3 Static Resources as Image size should not be greater than 5 MB       
		lstImage1 = new List<String>();
		lstImage2 = new List<String>();
		lstImage3 = new List<String>();
		Set<String> setImage1 = new Set<String>();
		Set<String> setImage2 = new Set<String>();
		Set<String> setImage3 = new Set<String>();
		
		for(Prospect_Service_Contract__c obj: [Select Service_Plan_Template__c, Opportunity__c, Service_Plan_Code__r.Service_Contract_Description__c, Energy_Price__c
												From Prospect_Service_Contract__c where Opportunity__c =: strOpportunityId ])
		{
			if(obj.Service_Plan_Template__c == 'Advantage')
				setImage3.add('image3/AdvantageServicePlan.jpg');
			else if(obj.Service_Plan_Template__c == 'Basic')
				setImage2.add('images2/BasicServicePlan.jpg');
			else if(obj.Service_Plan_Template__c == 'Copper')
				setImage2.add('images2/CopperServicePlan.jpg');
			else if(obj.Service_Plan_Template__c == 'Elite')
				setImage2.add('images2/EliteServicePlan.jpg');
			else if(obj.Service_Plan_Template__c == 'Gold')
				setImage2.add('images2/GoldServicePlan.jpg');
			else if(obj.Service_Plan_Template__c == 'Platinum')
				setImage3.add('image3/PlatinumServicePlan.jpg');
			else if(obj.Service_Plan_Template__c == 'Premier')
				setImage1.add('images1/PremierServicePlan.jpg');
			else if(obj.Service_Plan_Template__c == 'Silver')
				setImage1.add('images1/SilverServicePlan.jpg');
			else if(obj.Service_Plan_Template__c == 'Value')
				setImage1.add('images1/ValueServicePlan.jpg');
			lstPSC.add(obj);//adding objects to list
		}
		lstImage3.addAll(setImage3);
		lstImage2.addAll(setImage2);
		lstImage1.addAll(setImage1);
	}
	/** 
        * @Name      : isCeilingTrue()
        * @parameter : Opportunity Pricing type
        * @Description  : It will return true if Pricing Type comes under Ceiling
    */
	private static Boolean isCeilingTrue(String strPricingType)
    {
        if(strPricingType == null || strPricingType == '')
            return false;
        else
            return ((New set<String>{'Min Ceiling', 'Max Ceiling', 'Min Ceiling 3 Years', 'Ceiling','Max Ceiling 3 Years', '2nd Max Ceiling 3 Years'}).contains(strPricingType));
    }
    
    /** 
        * @Name      : isCeilingWithFeeTrue()
        * @parameter : Opportunity Pricing type
        * @Description  : It will return true if Pricing Type comes under Ceiling
    */
	private static Boolean isCeilingWithFeeTrue(String strPricingType)
    {
        if(strPricingType != null && strPricingType.contains('Ceiling') && strPricingType.contains('with') && strPricingType.contains('fee'))
            return true;
        else
        	return false;
    }
    
    
}