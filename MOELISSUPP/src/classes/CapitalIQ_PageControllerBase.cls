public class CapitalIQ_PageControllerBase 
{
	public static testMethod void TestHarness()
	{	
		try
		{
			CapitalIQ_PageControllerBase extension = new CapitalIQ_PageControllerBase();
			
			Integer i = extension.getTab();
			
			extension.setTab(0);
			Boolean b = extension.getIsCompany();
			extension.setTab(1);
			b = extension.getIsCompany();
			String s = extension.getCompanyTabClass();
			
			extension.setAccountId('garbage');
			s = extension.getAccountId();
			
			extension.setASPNETSessionId('test');
			s = extension.getASPNETSessionId();
			
			AuthenticateServiceHTTP auth = extension.getAuthService();
			
			PageReference pr = extension.OnInit();
			
			extension.setTab(0);
			b = extension.getIsFinancials();
			extension.setTab(2);
			b = extension.getIsFinancials();
			s = extension.getFinancialsTabClass();
			
			extension.setTab(0);
			b = extension.getIsKeyDevs();
			extension.setTab(3);
			b = extension.getIsKeyDevs();
			s = extension.getKeyDevsTabClass();
			
			extension.setTab(0);
			b = extension.getIsPros(); 
			extension.setTab(4);
			b = extension.getIsPros();
			s = extension.getProsTabClass();
			
			s = extension.getCompanyTabLink();
			s = extension.getFinancialsTabLink();
			s = extension.getKeyDevsTabLink();
			s = extension.getProsTabLink();
			
			Account act2 = extension.getFullAccount();
		}
		catch(Exception e) 
		{}
	}
	public CapitalIQ_PageControllerBase()
	{
		//do nothing, this is for testing.	
	}
	
    public CapitalIQ_PageControllerBase(ApexPages.StandardController stdController)
	{
		Account temp = [select a.Name, a.Description, a.WebSite, a.CapitalIQ_CompanyId__c, a.Industry, a.TickerSymbol, a.NumberOfEmployees, a.Phone, a.Fax From Account a where a.id = : getAccountId()];
		Session.Account = temp; 
		if(ApexPages.currentPage().getParameters().get('tab') != null)
		{
			this.myTab = Integer.valueOf(ApexPages.currentPage().getParameters().get('tab'));
		}
		if(temp != null)
		{
			mySessionId = getASPNETSessionId();
		}
    }
	
	private String myAccountId;
	public String getAccountId()
	{
		if(myAccountId != null) { return myAccountId;}
		myAccountId = ApexPages.currentPage().getParameters().get('id');
		return myAccountId;
	}
	public void setAccountId(String value)
	{
		myAccountId = value;
	}
	
	private String mySessionId;
	public String getASPNETSessionId()
	{
		if(mySessionid != null && mySessionId != '') { return mySessionId;}
		auth = new AuthenticateServiceHTTP();
		mySessionId = auth.LoginOrRetrieveSession();
		return mySessionId;
	}
	public void setASPNETSessionid(String value)
	{
		mySessionId = value;
	}
	
	private Integer myTab;
	public void setTab(Integer tab)
	{
		myTab = tab;
	}
	public Integer getTab()
	{
		return myTab;
	}
	
	public Boolean getIsCompany()
	{
		return myTab == 1 || myTab == null;
	}
	
	public Boolean getIsFinancials()
	{
		return myTab == 2;
	}
	
	public Boolean getIsKeyDevs()
	{
		return myTab == 3;
	}
	
	public Boolean getIsPros()
	{
		return myTab == 4;
	}
	
	private final Account acctId;
	private final Account acct;
	public Account getFullAccount()
	{
		return acct;
	}
    
	private AuthenticateServiceHTTP auth;
	public AuthenticateServiceHTTP getAuthService()
	{
		return auth;
	}
	
	public String getCompanyTabClass()
	{
		if(myTab == 1 || myTab == null){ 
			return 'currentTab primaryPalette';
		}
		return '';
	}
	public String getFinancialsTabClass()
	{
		if(myTab == 2){ 
			return 'currentTab primaryPalette';
		}
		return '';
	}
	public String getKeyDevsTabClass()
	{
		if(myTab == 3){ 
			return 'currentTab primaryPalette';
		}
		return 'last';
	}
	public String getProsTabClass()
	{
		if(myTab == 4){ 
			return 'currentTab primaryPalette';
		}
		return '';
	}
	
	public PageReference OnInit()
	{
		return null;
	}
	
	public String getCompanyTabLink()
	{
		return '/apex/CapitalIQ?id=' + ApexPages.currentPage().getParameters().get('id') + '&Tab=1';
	}
	public String getFinancialsTabLink()
	{
		return '/apex/CapitalIQ?id=' + ApexPages.currentPage().getParameters().get('id') + '&Tab=2';
	}
	public String getKeyDevsTabLink()
	{
		return '/apex/CapitalIQ?id=' + ApexPages.currentPage().getParameters().get('id') + '&Tab=3';
	}
	public String getProsTabLink()
	{
		return '/apex/CapitalIQ?id=' + ApexPages.currentPage().getParameters().get('id') + '&Tab=4';
	}
}