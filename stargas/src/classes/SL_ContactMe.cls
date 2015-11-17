/**  
* \arg ClassName      : SL_ContactMe
* \arg JIRATicket     : STARGAS-12
* \arg CreatedOn      : 23/JUL/2014
* \arg LastModifiedOn : 23/SEPT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This controller is used to update the contact details
*/
public without sharing class SL_ContactMe 
{
	/* Start - Page Variables */
	public Welcome_Kit__c objWelcomeKit	{get;set;}//this variable is used to show email address of welcome kit object record
	public String strHomePhone			{get;set;}//this variable is used to show the home phone number of related account
	public String strMobile				{get;set;}//this variable is used to show the phone number of related account
	public String strContactPreference  {get;set;}// this variable is used to show contact preferences
	/* End - Page Variables */
	
	/* Start - Constructor */
	public SL_ContactMe()
	{
		initialize();
	}
	/* End - Constructor */
	
	/*
		* MethodName        : initialize
		* param             : None
		* Description       : This function is used to initialize the page variables
	*/
	void initialize()
	{
		Map<String,String> mapPageParameters = Apexpages.currentPage().getParameters();
		if(!mapPageParameters.containskey('welcomekitId') || String.isEmpty(mapPageParameters.get('welcomekitId')))
		{
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Insufficient Parameters.'));
			return;
		}
		
		//fetching welcome kit record details
		List<Welcome_Kit__c> lstWelcomeKit = [SELECT Id,Client_Name__c ,Client_Name__r.Phone, Client_Name__r.Home_Phone__c, Email__c, Contact_Preference__c
											  FROM Welcome_Kit__c
											  WHERE Id=:mapPageParameters.get('welcomekitId')];
		if(!lstWelcomeKit.isEmpty())
		{
			objWelcomeKit = lstWelcomeKit[0];
			strContactPreference = objWelcomeKit.Contact_Preference__c;
			strHomePhone = objWelcomeKit.Client_Name__r.Home_Phone__c;
			strMobile = objWelcomeKit.Client_Name__r.Phone;
		}
	}
	
	/*
		* MethodName        : getContactPreferences
		* param             : None
		* Description       : This function is used to fill the contract preferences on page
	*/
	public List<Selectoption> getContactPreferences()
	{
		return new List<Selectoption>{new Selectoption('Email','Email'), new Selectoption('Phone','Phone')};
	}
	
	/*
		* MethodName        : save
		* param             : None
		* Description       : This function is used to save the welcome kit record.
	*/
	public Pagereference saveDetails()
	{
		try
		{
			objWelcomeKit.Contact_Preference__c = strContactPreference;
			objWelcomeKit.Letter_Status__c = 'Contact Me';
			update objWelcomeKit;
			update new Account(Id = objWelcomeKit.Client_Name__c, Home_Phone__c = strHomePhone, Phone = strMobile);
			return new Pagereference('/apex/SL_ContactMeConfirmation');
		}
		catch(DMLException ex)
		{
			System.debug('======================='+ex.getMessage()+'================='+ex.getLineNumber());
		}
		return null;
	}
}