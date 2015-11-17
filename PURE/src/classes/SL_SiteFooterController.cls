public with sharing class SL_SiteFooterController {
	
	public String pureInsurancelink			{get;set;}
	public String privacyPolicyLink			{get;set;}
	public String fAQlink					{get;set;}
	public String shareYourStorylink		{get;set;}
	
	public SL_SiteFooterController()
	{
		// Initializations
		pureInsurancelink = privacyPolicyLink = fAQlink = shareYourStorylink = '';
		
		PortalURLMap__c oFAQ = new PortalURLMap__c();
		PortalURLMap__c oPureinsurance = new PortalURLMap__c();
		PortalURLMap__c oPrivacyPolicy = new PortalURLMap__c();
		PortalURLMap__c oShareYourStory = new PortalURLMap__c();
		
		oFAQ = PortalURLMap__c.getInstance('FAQ');
		oPureinsurance = PortalURLMap__c.getInstance('pureInsurance.com');
		oPrivacyPolicy = PortalURLMap__c.getInstance('PrivacyPolicy');
		oShareYourStory = PortalURLMap__c.getInstance('ShareYourStory');

		fAQlink = (oFAQ != null) ? oFAQ.URL__c : '#';
		pureInsurancelink = (oPureinsurance != null) ? oPureinsurance.URL__c : '#';
		privacyPolicyLink = (oPrivacyPolicy != null) ? oPrivacyPolicy.URL__c : '#';
		shareYourStorylink = (oShareYourStory != null) ? oShareYourStory.URL__c : '#';
	}
}