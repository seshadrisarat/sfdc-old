public class CompanyResolution_Controller 
{
	public static testMethod void TestHarness()
	{
		try
		{
			CapitalIQSetup_Controller.InitOrgInfo(); 
			CompanyResolution_Controller controller = new CompanyResolution_Controller();
			controller.Cancel();
			CapitalIQOrganization__c org = controller.getOrganizationInfo();
			CompanyResolution.SearchCompanyInfo[] d = controller.getCompanyInfo();
			Integer i = controller.getResultSize();
			Account a = controller.getAccount();
			Lead l = controller.getLead();
			controller.OnInit();
		}
		catch(Exception e){}
	}
	
	//Private Backing Fields
	private CompanyResolution.SearchCompanyInfo[] info;
	private Boolean IsPostback = false;
	public String AccountId { get; set;}
	public String LeadId { get; set; }
	
	//Properties
	public CompanyResolution.SearchCompanyInfo[] getCompanyInfo()
	{
		return info;
	}
	
	public String SearchType { get; set; }
	public String TargetId { get; set; }
	
	public Integer getResultSize()
	{
		if(info == null) { return 0; }
		return info.size();
	}

	public String SearchText { get; set; }
			
	public Account getAccount()
	{
		Account account = new Account();
		try
		{
			account = [select a.Name From Account a				   
				where a.id = : AccountId];
		}
		catch(Exception e)
		{
			System.debug('CompanyResolution_Controller.getAccount() --> Caught Ex: ' + e);	
		}
		return account;
	}
	
	public Lead getLead()
	{
		Lead account = new Lead();
		try
		{
			account = [select a.Name, a.Company From Lead a				   
				where a.id = : LeadId];
		}
		catch(Exception e)
		{
			System.debug('CompanyResolution_Controller.getLead() --> Caught Ex: ' + e);	
		}
		return account;
	}

	public CapitalIQOrganization__c getOrganizationInfo()
	{
		AuthenticateServiceHTTP auth = new AuthenticateServiceHTTP();
		return auth.getOrgInfo(); 
	}
	
	//Life Cycle and Functions
	public PageReference OnInit()
	{
		String qsAccountId = System.currentPageReference().getParameters().get('AccountId');
		String qsLeadId = System.currentPageReference().getParameters().get('LeadId');
		
		if(qsAccountId != null) { AccountId = qsAccountId; }
		else if (qsLeadId != null) { LeadId = qsLeadId;}
		
		if(qsAccountId != null && !IsPostback)
		{
			Account current = getAccount();
			SearchText = current.Name;
			SearchType = '2';
		}
		else if (qsLeadId != null && !IsPostBack)
		{
			Lead current = getLead();
			SearchText = current.Company;
			SearchType = '2';
		}
		
		if(!IsPostback)
		{
			DoResolution();
		}
		
		return null;
	}
	
	public PageReference DoSearch()
	{
		IsPostback = true;
		DoResolution();
		return null;
	}
	
	public PageReference Cancel()
	{
		PageReference p = new PageReference('/' + AccountId);
		p.setRedirect(true);
		return p; 
	}
	
	public PageReference Resolve()
	{
		IsPostback = true;
		PageReference p; 
		if(System.currentPageReference().getParameters().get('AccountId') != null)
		{
			Account current = getAccount();
			current.CapitalIQ_CompanyId__c = TargetId; //this cannot be null
			
			System.debug('CompanyResolution_Controller.Resolve() --> Setting CapitalIQ_CompanyId to ' + TargetId);
			
			update current; 
			p = new PageReference('/' + AccountId);
		}
		else if (System.currentPageReference().getParameters().get('LeadId') != null)
		{
			Lead current = getLead();
			current.CapitalIQ_CompanyId__c = TargetId; //this cannot be null
			
			System.debug('CompanyResolution_Controller.Resolve() --> Setting CapitalIQ_CompanyId to ' + TargetId);
			
			update current; 
			p = new PageReference('/' + LeadId);
		}
		
		p.setRedirect(true);
		return p;
	}
	
	public void DoResolution()
	{
		try
		{
			info = CompanyResolution.SearchCompanies(SearchText, SearchType, SearchType == '2', '16', Session.getASPNETSessionId());
		}
		catch(Exception e){}
	}
}