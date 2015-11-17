/**  
* \arg ClassName      : SL_ContractReview
* \arg JIRATicket     : STARGAS-12
* \arg CreatedOn      : 25/JUL/2014
* \arg LastModifiedOn : 15/APR/2015
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is controller is used for SL_ContractReview
*/
public without sharing class SL_ContractReview 
{
	public Welcome_Kit__c objWelcomeKit {get; private set;} //Welcome Kit object binded to the page
	public SL_ContractReviewDoc__c objContractReview{get; set;} //Custom setting object to display the static data
	public String strIpAddress {get;set;} //IP address to display in the page
	public Boolean isConfirmed {get; set;} //Checkbox to specify whether the conditions are agreed
	public Boolean isError {get;set;} //Displaying error message on page 
	public Boolean isSaved {get;set;}//Dispaying message on page whether contract has been signed.
	public String strOpportunityId {get;set;}//Opportunity Id binded with the page
	public String strLogoPath   {get;private set;}//this variable is used to show logo from the division table on the contract review page
	public String strGMSignPath {get;private set;}//this variable is used to show division GM signature on contract review page from division table.
	
	//Constructor
	public SL_ContractReview()
	{		
		Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();
		try
		{
		if(mapHeaders != null)
		{
		  strIpAddress = mapHeaders.get('True-Client-IP');
		  
		  if(strIpAddress == null)
		    strIpAddress = mapHeaders.get('X-Salesforce-SIP');
		}
		strOpportunityId ='';
		isError = isSaved = isConfirmed = false;
		//Getting Id from parameters 
		String strWelcomeKitId = ApexPages.currentPage().getParameters().get('id');
		
		//Creating instance of custom setting 
		List<SL_ContractReviewDoc__c> lstContractReview = SL_ContractReviewDoc__c.getall().values();
		
		if(!lstContractReview.isEmpty())
			objContractReview = lstContractReview[0];
		
		//Query Welcome Kit object
		if(!String.isEmpty(strWelcomeKitId))
		{
			objWelcomeKit = [Select Id, Email__c, Electronic_Signature__c, Name, Opportunity__c, Opportunity__r.Account.Name, Opportunity__r.Account.Energy_AccountNumLong__c, Opportunity__r.Territory__r.Division__r.Service_Company__c, Opportunity__r.Recorded__c, Opportunity__r.Division_GM__c, Opportunity__r.Territory__r.Division__r.Logo__c, Opportunity__r.Territory__r.Division__r.GM_Sign__c,Client_Name__r.Name From Welcome_Kit__c where Id =: strWelcomeKitId ];
			strOpportunityId = objWelcomeKit.Opportunity__c;
		}
		
		if(String.isNotEmpty(objWelcomeKit.Opportunity__r.Territory__r.Division__r.GM_Sign__c))
			strGMSignPath = formatRichText(objWelcomeKit.Opportunity__r.Territory__r.Division__r.GM_Sign__c);
		if(String.isNotEmpty(objWelcomeKit.Opportunity__r.Territory__r.Division__r.Logo__c))
			strLogoPath = formatRichText(objWelcomeKit.Opportunity__r.Territory__r.Division__r.Logo__c);
		}
		catch(Exception ex)
		{
			system.debug('==============='+ex.getMessage()+'========================='+ex.getLineNumber());
		}
	}
		
	/*
		* MethodName        : formatRichText
		* param             : Value of the rich text area field
		* Description       : This function is used to set the formatting of the field value in order to show image on contract review page.
	*/
	private String formatRichText(String strRichText)
	{
		return strRichText.subStringBetween(strRichText.contains('src') ? 'src="' : 'href="','"').replaceAll('&amp;','&');
	}
	
	/*
		* MethodName        : save
		* param             : None
		* Description       : Moving to next page(Confirmation) on click of "I accept and confirm my agreement"
	*/
	public Pagereference save()
	{
		isError = isSaved = false;		
		try
		{
			//If no error, go to next page
			if((objWelcomeKit.Email__c != null ) && isConfirmed && String.isNotEmpty(objWelcomeKit.Electronic_Signature__c))
			{
				objWelcomeKit.Signed_Date__c = Datetime.now();
				objWelcomeKit.IP_Address__c = strIpAddress;
				objWelcomeKit.Confirm_Name_Email_IP__c = isConfirmed;
				objWelcomeKit.Letter_Status__c = 'Signed';
				//Update welcome kit object
				update objWelcomeKit;
				
				List<Welcome_Kit__c> lstWelcomeKit = [SELECT Electronic_Signature__c, Signed_Date__c FROM Welcome_Kit__c WHERE Opportunity__c =: strOpportunityId ORDER BY CreatedDate DESC LIMIT 1];
				if(!lstWelcomeKit.isEmpty())
				{
					update new Opportunity(Id = strOpportunityId, Welcome_Kit_Date_Signed__c = lstWelcomeKit[0].Signed_Date__c, Welcome_Kit_ElectronicSignature__c = lstWelcomeKit[0].Electronic_Signature__c);	
				}			
				PageReference pgRef = new PageReference('/apex/SL_Confirmation?oppid='+strOpportunityId+'&id='+objWelcomeKit.Id);
				pgRef.setRedirect(true);
				return pgRef;
			}
			//Else display the error message
			else if(!isConfirmed)
			{
				isError = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.SL_ValidateConfirmationAndElectronicSign));
			}
			else
			{
				isError = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SL_ValidateAllFields));
			}
		}
		//Debugging and displaying error, if occurs any
		catch(Exception e)
		{
			isError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			system.debug(e.getMessage()+'===============Error==@'+e.getLineNumber());
		}
		return null;
	}
	
	/*
		* MethodName        : contactMe
		* param             : None
		* Description       : This function is used to show error messages when electronic signature or confirmation checkbox is checked on click of Contact Me button.
	*/
	public Pagereference contactMe()
	{
		if(isConfirmed)
		{
			isError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Contract_Confirmation_Error));
		}
		else
		{
			return new Pagereference('/apex/SL_ContactMe?welcomeKitId='+objWelcomeKit.Id);
		}
		return null;
	}
}