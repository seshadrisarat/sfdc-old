public class CapitalIQ_Basic_Controller 
{
	public static testMethod void TestHarness()
	{
		CapitalIQ_Basic_Controller controller = new CapitalIQ_Basic_Controller();
		
		controller.setASPNetSessionId('testharness');
		String burn = controller.getASPNetSessionId();
		
		GetCompanyInfo.CompanySummary info = new GetCompanyInfo.CompanySummary();
		info.PrimaryAddressInfo = new GetCompanyInfo.PrimaryCompanyAddress();
		controller.capitalIQBasicInfo = info;
		String s = controller.getCIQName();
		s = controller.getCIQTicker();
		s = controller.getCIQDescription();
		s = controller.getCIQWebSite();
		Integer i = controller.getCIQEmployees();
		s = controller.getCIQPhone();
		s = controller.getCIQFax();
		s = controller.getCIQIndustry();
		
		Boolean b = false;
		b = controller.updateName;
		b = controller.updateIndustry;
		b = controller.updatePhone;
		b = controller.updateFax;
		b = controller.updateEmployees;
		b = controller.updateBillingAddress;
		b = controller.updateDescription;
		b = controller.updateWebsite;
		b = controller.updateTicker;
		
		Account newAcct = new Account();
		newAcct.CapitalIQ_CompanyId__c = '21835'; 
		newAcct.Name = 'TestMSFT';
		insert newAcct;
		
		Lead newLead = new Lead();
		newLead.CapitalIQ_CompanyId__c = '21835';
		newLead.FirstName = 'TestMSFT';
		newLead.LastName = 'TestMSFT';
		newLead.Company = 'TestMSFT';
		insert newLead;
		controller.innerLeadId = String.valueOf(newLead.Id);
		
		String leadId = controller.getLeadId();
		String accountid = controller.getAccountId();
		s = controller.getTabStyle();
		controller.OnInit();
		controller.Cancel();
		
		controller.updateName = b;
		controller.updateIndustry = b;
		controller.updatePhone = b;
		controller.updateFax = b;
		controller.updateEmployees = b;
		controller.updateBillingAddress = b;
		controller.updateDescription = b;
		controller.updateWebsite = b;
		controller.updateTicker = b;
		
		controller.Save();
		
		controller.innerLeadId = null;
		controller.innerAccountId = String.valueOf(newAcct.Id);
		s = controller.getTabStyle();
		controller.OnInit();
		controller.Cancel();
		controller.Save();
		
		controller.myAccount = newAcct;
		s = controller.getSalesforceDescription();
		s = controller.getSalesforceWebSite();
		s = controller.getSalesforceName();
		s = controller.getSalesforcePhone();
		s = controller.getSalesforceFax();
		s = controller.getSalesforceIndustry();
		
		controller.myAccount = null;
		controller.myLead = newLead;
		
		s = controller.getSalesforceDescription();
		s = controller.getSalesforceWebSite();
		s = controller.getSalesforceName();
		s = controller.getSalesforcePhone();
		s = controller.getSalesforceFax();
		s = controller.getSalesforceIndustry();

		
		
		Lead l = controller.getLead();
		Account a = controller.getAccount();
	}
	
	private String ASPNETSessionId;
	private Boolean IsPostback = false;
	public Account myAccount;
	public Lead myLead;
	public GetCompanyInfo.CompanySummary capitalIQBasicInfo;
	
	public String innerAccountId;
	public String getAccountId()
	{ 
		if(innerAccountId != null)
		{
			return innerAccountId;
		}
		innerAccountId = System.currentPageReference().getParameters().get('AccountId');
		return innerAccountId;
	}
	public void setAccountId(String value)
	{
		innerAccountId = value;
	}
	
	public String innerLeadId;
	public String getLeadId()
	{ 
		if(innerLeadId != null)
		{
			return innerLeadId;
		}
		innerLeadId = System.currentPageReference().getParameters().get('LeadId');
		return innerLeadId;
	}  
	public void getSetLeadId(String value)
	{
		innerLeadId = value;
	}
	
	public Boolean updateName { get; set;}
	public Boolean updateIndustry { get; set;}
	public Boolean updatePhone { get; set;}
	public Boolean updateFax { get; set;}
	public Boolean updateEmployees { get; set;}
	public Boolean updateBillingAddress { get; set;}
	public Boolean updateDescription { get; set;}
	public Boolean updateWebsite { get; set;}
	public Boolean updateTicker { get; set;}
	
	public String getTabStyle()
	{
		if(getAccountId() != null)
		{
			return 'Account';
		}
		else if (getLeadId() != null)
		{
			return 'Lead';
		}
		return '';
	}
	
	public String getCIQName()
	{
		return capitalIQBasicInfo.CompanyName;
	}
	public String getCIQTicker()
	{
		return capitalIQBasicInfo.PrimaryTickerSymbol;
	}
	public String getCIQDescription()
	{
		return capitalIQBasicInfo.BusinessDescription;
	}
	public String getCIQWebSite()
	{
		return capitalIQBasicInfo.WebSiteURL;
	}
	public Integer getCIQEmployees()
	{
		return capitalIQBasicInfo.NumberOfEmployees;
	}
	public String getCIQPhone()
	{
		return capitalIQBasicInfo.PrimaryAddressInfo.Phone;
	}
	public String getCIQFax()
	{
		return capitalIQBasicInfo.PrimaryAddressInfo.Fax;
	}
	public String getCIQIndustry()
	{
		return capitalIQBasicInfo.SimpleIndustryName;
	}
	
	public String getSalesforceName()
	{
		if(myAccount != null)
		{
			return myAccount.Name;
		}
		else if(myLead != null)
		{
			return myLead.Company;
		}
		return '-';
	}
	
	public String getSalesforceTicker()
	{
		if(myAccount != null)
		{
			return myAccount.TickerSymbol;
		}
		else if(myLead != null)
		{
			return 'N/A';//return myLead.Name;
		}
		return '-';
	}
	
	public String getSalesforceDescription()
	{
		if(myAccount != null)
		{
			return myAccount.Description;
		}
		else if(myLead != null)
		{
			return myLead.Description;
		}
		return '-';
	}
	
	public String getSalesforceWebSite()
	{
		if(myAccount != null)
		{
			return myAccount.WebSite;
		}
		else if(myLead != null)
		{
			return myLead.WebSite;
		}
		return '-';
	}
	
	public Integer getSalesforceNumberOfEmployees()
	{
		if(myAccount != null)
		{
			return myAccount.NumberOfEmployees;
		}
		else if(myLead != null)
		{
			return myLead.NumberOfEmployees;
		}
		return 0;
	}
	
	public String getSalesforcePhone()
	{
		if(myAccount != null)
		{
			return myAccount.Phone;
		}
		else if(myLead != null)
		{
			return myLead.Phone;
		}
		return '-';
	}
	
	public String getSalesforceFax()
	{
		if(myAccount != null)
		{
			return myAccount.Fax;
		}
		else if(myLead != null)
		{
			return myLead.Fax;
		}
		return '-';
	}
	
	public String getSalesforceIndustry()
	{
		if(myAccount != null)
		{
			return myAccount.Industry;
		}
		else if(myLead != null)
		{
			return myLead.Industry;
		}
		return '-';
	}

	private String myASPNetSessionId;
	public String getASPNetSessionId()
	{
		if(myASPNetSessionId != null) { return myASPNetSessionId; }
	
		AuthenticateServiceHTTP auth = new AuthenticateServiceHTTP();
		myASPNetSessionId = auth.LoginOrRetrieveSession(); //this won't actually do a login unless its a fresh hit.
		return myASPNetSessionId;	
	}
	public void setASPNetSessionId(String value)
	{
		myASPNetSessionId = value;
	}

	public PageReference OnInit()
	{		
		if(getAccountId() != null)
		{
			try
			{
				myAccount = getAccount();
				
				if(myAccount.CapitalIQ_CompanyId__c == null)
				{
					throw new CapitalIQException('CapitalIQ CompanyId is null, please resolve to Capital IQ entity.');
				}
				
				if(getASPNetSessionId() != null && getASPNetSessionId() != 'testharness')
				{
					capitalIQBasicInfo = GetCompanyInfo.FetchCompanySummary(Integer.valueOf(myAccount.CapitalIQ_CompanyId__c), getASPNetSessionId());
				}
			}
			catch(Exception e)
			{
				System.debug('@@@ CapitalIQ_Basic_Controller.OnInit() threw --> ' + e);
			}
		}
		
		if(getLeadId() != null)
		{
			myLead = getLead();
			if(myLead.CapitalIQ_CompanyId__c == null)
			{
				throw new CapitalIQException('CapitalIQ CompanyId is null, please resolve to Capital IQ entity.');
			}
			
			capitalIQBasicInfo = GetCompanyInfo.FetchCompanySummary(Integer.valueOf(myLead.CapitalIQ_CompanyId__c), getASPNetSessionId());
		}
		
		if(capitalIQBasicInfo == null)
		{
			capitalIQBasicInfo = new GetCompanyInfo.CompanySummary();
			capitalIQBasicInfo.PrimaryAddressInfo = new GetCompanyInfo.PrimaryCompanyAddress();
		} 
		
		return null;
	}
	
	public PageReference Save()
	{
		PageReference p;
		if(getAccountId() != null)
		{
			myAccount = getAccount();
			if(updateName != null && updateName) {myAccount.Name = getCIQName();}
			if(updateIndustry!= null && updateIndustry) { myAccount.Industry = getCIQIndustry();}
			if(updatePhone != null && updatePhone) { myAccount.Phone = getCIQPhone();}
			if(updateFax != null && updateFax) { myAccount.Fax = getCIQFax();}
			if(updateEmployees != null && updateEmployees) { myAccount.NumberOfEmployees = getCIQEmployees();}
			if(updateWebsite != null && updateWebsite) { myAccount.WebSite = getCIQWebSite();}
			if(updateTicker != null && updateTicker) { myAccount.TickerSymbol = getCIQTicker();}
			
			try
			{
				update myAccount;
			}
			catch(Exception e)
			{
				//swallow;
			}
			
			p = new PageReference('/' + getAccountId());
		}
		else if (getLeadId() != null)
		{
			myLead = getLead();
			if(updateName != null && updateName) {myLead.Company = getCIQName();}
			if(updateIndustry!= null && updateIndustry) { myLead.Industry = getCIQIndustry();}
			if(updatePhone!= null && updatePhone) { myLead.Phone = getCIQPhone();}
			if(updateFax != null && updateFax) { myLead.Fax = getCIQFax();}
			if(updateEmployees != null && updateEmployees) { myLead.NumberOfEmployees = getCIQEmployees();}
			/* if(updateDescription) {myLead.Description = getCIQDescription();} */
			if(updateWebsite != null && updateWebsite) { myLead.WebSite = getCIQWebSite();}
			
			try
			{
				update myLead;
			}
			catch(Exception e)
			{
				//swallow;
			}
		
			p = new PageReference('/' + getLeadId());
		}
		p.setRedirect(true);
		return p;
	}
	
	public PageReference Cancel()
	{
		if(getAccountId() != null)
		{
			PageReference p = new PageReference('/' + getAccountId());
			p.setRedirect(true);
			return p;
		}
		else if (getLeadId() != null)
		{
			PageReference p = new PageReference('/' + getLeadId());
			p.setRedirect(true);
			return p;
		}
		return null;
	}
	
	public Account getAccount()
	{
		Account account = new Account();
		try
		{
			account = [select a.Name, a.Description, a.WebSite, a.CapitalIQ_CompanyId__c, a.Industry, a.TickerSymbol, a.NumberOfEmployees, a.Phone, a.Fax From Account a				   
				where a.id = : getAccountId()];
		}
		catch(Exception e)
		{
			System.debug('CapitalIQ_Basic_Controller.getAccount(' + getAccountId() + ') --> Caught Ex: ' + e);	
		}
		return account;
	}
	
	public Lead getLead()
	{
		if(getLeadId() == null) { return new Lead();}
		Lead lead = new Lead();
		try
		{
			lead = [select l.Name, l.Company, l.Description, l.WebSite, l.CapitalIQ_CompanyId__C, l.Industry, l.NumberOfEmployees, l.Phone, l.Fax From Lead l
			where l.id = : getLeadId()];
		}	
		catch(Exception e)
		{
			System.debug('CapitalIQ_Basic_Controller.getLead('+ getLeadId() +') --> Caught Ex: ' + e);
		}
		return lead;
	}
}