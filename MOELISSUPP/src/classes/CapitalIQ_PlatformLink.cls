public class CapitalIQ_PlatformLink 
{
	public static testMethod void TestHarness()
	{
		String s = RenderLink(21835, PublicOwnership, 'Test Link Text');
		String s2 = RenderLink(21835, PublicOwnership, null);
		try
		{
			String s3 = RenderLink(0, 1, 'notnull');
		}
		catch(Exception e)
		{
			System.debug('threw --> ' + e);
		}
	}
	
	public static String CapitalIQ = 'https://www.capitaliq.com';
	public static String Redirect = '/ciqdotnet/ExternalRedirect.axd';

	public static String CompanyIdField = 'companyId';
	public static String RedirectIdField = 'redirectId';	
	
	public static String PlatformUrl(Integer CompanyId, Integer RedirectId)
	{
		return CapitalIQ + Redirect + '?' + CompanyIdField + '=' + String.valueOf(CompanyId) + '&' + RedirectIdField + '=' + String.valueOf(RedirectId);
	}
	
	public static String RenderLink(Integer CompanyId, Integer RedirectId, String LinkText)
	{
		if(LinkText == null) { LinkText = 'View More'; }
		if(CompanyId == 0 ) { throw new CapitalIQException('CompanyId was zero for external link.'); }
		String tag = '';
		tag = tag + '<a href=\'';
		tag = tag + PlatformUrl(Companyid, RedirectId);
		tag = tag + '\' target=\'_blank\'>';
		tag = tag + LinkText;
		tag = tag + '</a>'; 
		
		return tag;
	}
	
	public static Integer CompanyTearsheet = 0;
	public static Integer PublicOwnership = 123;
	public static Integer SECFilings = 302;
	public static Integer Professionals = 401;
	public static Integer BoardMembers = 402;
	public static Integer DirectInvestmentSubs = 428;
	public static Integer Suppliers = 1490;
	public static Integer KeyStats = 106;
	public static Integer IncomeStatement = 108;
	public static Integer KeyDevelopments = 812;
}