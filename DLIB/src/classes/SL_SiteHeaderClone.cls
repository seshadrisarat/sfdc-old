public class SL_SiteHeaderClone
{
	/* Start - Home Page Variables */
	public String strhomeURL										{	get;set;	}
	public String strcontactURL										{	get;set;	}
	public String strfeatureURL										{	get;set;	}
	public String struseCasesURL									{	get;set;	}
	public String strinstallURL										{	get;set;	}
	public String strpricingURL										{	get;set;	}
	public String strhelpURL										{	get;set;	}
	public String strfreeTrailURL									{	get;set;	}
	public String strinstallCalenderAnythingURL						{	get;set;	}
	public String strSubscriptionOrgId								{   get;set;    }
	public final String	strUrlForSubId;
	public String strCustomSettingName								{	get;set;	}
	public String strProductTitle									{	get;set;	}
	public String strSitePrefixOriginal								{	get;set;	}
	public String strSuccessStory                                   {	get;set;	}   
	public String strUsecase                                         {	get;set;	}   
	/* End - Home Page Variables */
	
	/*Start */
	public SL_SiteHeaderClone()
	{
		initialization();
		
		if(System.currentPageReference().getParameters().containsKey('subId'))
		{
			strSubscriptionOrgId = System.currentPageReference().getParameters().get('subId');
		}
		
		strUrlForSubId = '?subId='+strSubscriptionOrgId;
		//To get the value for URL in the Navigation from the custom setting.
		getNavigationURLFromCustomSetting();
	}
	
	/* Start - Method*/
	private void initialization()
	{
		/*Start - Home page*/
		strSubscriptionOrgId = strhomeURL = strcontactURL = strSitePrefixOriginal = strfeatureURL = struseCasesURL = strinstallURL = strpricingURL = strhelpURL = strfreeTrailURL = strinstallCalenderAnythingURL = '';
		
		strCustomSettingName = getCustomSettingName();
		
		/* End - Home Page*/
	}
	
	/* Start - Method to get the URL from getCustomSettingValue method and assign to respective string */
	private void getNavigationURLFromCustomSetting()
	{
		strhomeURL = getCustomSettingValue(strCustomSettingName + '_' +'HomeClone');
		strcontactURL = getCustomSettingValue(strCustomSettingName + '_' +'ContactClone') + strUrlForSubId;
		strSuccessStory = getCustomSettingValue(strCustomSettingName + '_' +'SuccessStory');
		strUsecase = getCustomSettingValue(strCustomSettingName + '_' +'UseCases');
		strhelpURL = getCustomSettingValue(strCustomSettingName + '_' +'HelpClone') + strUrlForSubId;
		
	/*	strfeatureURL = getCustomSettingValue(strCustomSettingName + '_' +'Feature') + strUrlForSubId + '#features';
		strhelpURL = getCustomSettingValue(strCustomSettingName + '_' +'Help') + strUrlForSubId;
		struseCasesURL = getCustomSettingValue(strCustomSettingName + '_' +'Use Cases') + strUrlForSubId + '#use-cases';
		strinstallURL = getCustomSettingValue(strCustomSettingName + '_' +'Install');
		strpricingURL = getCustomSettingValue(strCustomSettingName + '_' +'Pricing');
		strfreeTrailURL = getCustomSettingValue(strCustomSettingName + '_' +'Free Trial');
		strinstallCalenderAnythingURL = getCustomSettingValue(strCustomSettingName + '_' +'Install Calendar Anything');*/
		strProductTitle = getCustomSettingValue(strCustomSettingName + '_' +'ProductCategory');
		if(strProductTitle.length() > 3)
			strProductTitle = strProductTitle.subString(0,strProductTitle.length()-3);
	}
	/* End - Method to get the URL from getCustomSettingValue method and assign to respective string */
	
	/* Start - Method to get the prefix used in custom setting */
	private String getCustomSettingName()
	{
		String strSitePrefix = Site.getName();
		
		if(strSitePrefix == Null)
			strSitePrefix = 'CalendarAnything_Website';
			
		strSitePrefixOriginal = 	Site.getPrefix();
		if(strSitePrefixOriginal == null ||strSitePrefixOriginal =='/' )
			strSitePrefixOriginal ='';
		else if(strSitePrefixOriginal != null &&strSitePrefixOriginal != '/')
		{
			strSitePrefixOriginal = strSitePrefixOriginal.substring(1,strSitePrefixOriginal.length());
		}
		
		system.debug('++++++++++++++++++++++++++++++++++++++'+strSitePrefixOriginal);
		SL_SiteName__c objNav = SL_SiteName__c.getValues(strSitePrefix);
		if(objNav != null)
			return objNav.SiteIdentifier__c;
		else
			return '#';
	}
	/* END -  */
	
	/* Start - Method to get the URL from the custom setting */
	private String getCustomSettingValue(String strCSName)
	{
		String strUrl = '';
		SL_Navigation__c objNavigation = SL_Navigation__c.getValues(strCSName);
		if(objNavigation!= null)
			strUrl = objNavigation.URL__c;
		else
			strUrl = '#';
		return strUrl;
	}
	/* Start - Method to get the URL from the custom setting */
	
}