/**
* @ClassName 	: SL_HelpRightSideBar 
* @JIRATicket   : CW-38
* @CreatedOn    : 29/Jan/13
* @ModifiedBy   : Hemant
* @Description  : Used to get a Site Directory name from custom setting
*/

/**
@Hemant
Percentage of best practices followed	: 100%
No of SOQL queries used					: 0
No of collections used					: 0
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	: 
Customer Approval						: 
Last Modified Date						: 29/Jan/13
Approved by								: 

*/

public without sharing class SL_HelpRightSideBar
{
	/* Start - Variables*/
	public String strSiteDirectory		{	get;set;	} // Used to dynamically get the site directory as per CW-38 (Hemant)
	public String strCustomSettingName{	get;set;	}
	/* Start - Constructor*/
	public SL_HelpRightSideBar()
	{
		try
		{
			strCustomSettingName = getCustomSettingName();
			
			// Get the Site Directory from the custom setting as per CW-38 (Hemant)
			SL_Navigation__c objNavigation = SL_Navigation__c.getValues(strCustomSettingName + '_' +'Site Directory');
			
			if(objNavigation!= null)
				strSiteDirectory = objNavigation.URL__c;
			else
				strSiteDirectory = '#';
				
		}
		catch(Exception ex)
		{
			System.debug('### Exception:----------' + ex);
		}
	}
	
	/* Start - Method to get the site Name used in custom setting */
	private String getCustomSettingName()
	{
		/* Getting info about the Name  */
		String strSitePrefix = Site.getName();
		
		if(strSitePrefix == Null)
			strSitePrefix = 'CalendarAnything_Website';
			
		SL_SiteName__c objNav = SL_SiteName__c.getValues(strSitePrefix);
		
		if(objNav != null)
			return objNav.SiteIdentifier__c;
		else
			return '#';
	}
	/* END -  */
	
	@isTest
	private static void test_SL_HelpRightSideBar()
	{
		SL_HelpRightSideBar objHelpRightSideBar1 = new SL_HelpRightSideBar();
		SL_SiteName__c objSite = new  SL_SiteName__c();
        objSite.Name = 'CalendarAnything_Website';
        objSite.SiteIdentifier__c = 'ca';
        insert objSite;
        SL_Navigation__c objCustSetting = new SL_Navigation__c();
        objCustSetting.Name = 'ca_Site Directory';
       	objCustSetting.URL__c = 'Website_Feature__kav,Website_Use_Case__kav';
       	insert objCustSetting;
       	
		SL_HelpRightSideBar objHelpRightSideBar2 = new SL_HelpRightSideBar();
	}
}