public without sharing class SL_Apply_Now_Intermediate 
{
	Private String pId;
	Private String cId;
	Private String aa;
	
	public SL_Apply_Now_Intermediate()
	{
		pId = '';
		cId = '';
		aa = '';
		if(ApexPages.currentPage().getParameters().containsKey('cid'))
			cId = ApexPages.currentPage().getParameters().get('cid');
		if(ApexPages.currentPage().getParameters().containsKey('pid'))
			pId = ApexPages.currentPage().getParameters().get('pid');
		if(ApexPages.currentPage().getParameters().containsKey('aa'))
			aa = ApexPages.currentPage().getParameters().get('aa');
	}
	
	public pageReference redirect()
	{
		List<Cookie> lstCookies = new List<Cookie>();
		if(cid != null && cid != '')
		{
			Cookie cidCookie = new Cookie('cid',String.valueOf(cId),null,-1,false);
			lstCookies.add(cidCookie);
		}
		
		if(pid != null && pid != '')
		{
			Cookie pidCookie = new Cookie('pid',String.valueOf(pId),null,-1,false);
			lstCookies.add(pidCookie);
		}
		
		if(aa != null && aa != '')
		{
			Cookie aaCookie = new Cookie('aa',String.valueOf(aa),null,-1,false);
			lstCookies.add(aaCookie);
		}
		
		
		if(!Test.isRunningTest())
		{
			//Pagereference pr = new Pagereference('https://stonehenge.uat.cs7.force.com/Application');
			Pagereference pr = new Pagereference(Site.getCurrentSiteUrl());
			pr.setCookies(lstCookies); 
			pr.setRedirect(true);
			return pr; 
		}
		else
			return null;
	}
	
	@isTest
	private static void Apply_Now_Intermediate()
	{
		ApexPages.currentPage().getParameters().put('cid', 'cid');
		ApexPages.currentPage().getParameters().put('pid', 'pid');
		ApexPages.currentPage().getParameters().put('aa', 'aa');
		SL_Apply_Now_Intermediate inter = new SL_Apply_Now_Intermediate();
		inter.redirect();
	}
}