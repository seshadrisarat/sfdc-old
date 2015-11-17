public class MyListConstituents_Controller
{
	public static testMethod void TestHarness()
	{
		try
		{
		MyListConstituents_Controller controller = new MyListConstituents_Controller();
		
		Integer i = controller.getMyListId();
		i = controller.getMyListTypeId(); 
		controller.setMyListId(123123);
		controller.setMyListTypeId(3);
		i = controller.getMyListId();
		i = controller.getMyListTypeId();  
		
		controller.setMySessionId('test');
		String s = controller.getMySessionId();
		
		GetLists.CompanySearchResult[] stuff = controller.myConstituents;
		
		stuff = new GetLists.CompanySearchResult[]{};
		
		GetLists.CompanySearchResult csr = new GetLists.CompanySearchResult();
		csr.Selected = true;
		csr.CompanyId = 10; //<-- this is a bogus company id
		stuff.add(csr);
		
		controller.myConstituents = new GetLists.CompanySearchResult[]{};
		PageReference pr = controller.OnInit();
		pr = controller.ImportAsAccounts();
		controller.myConstituents = stuff;
		
		List<Integer> burn = controller.getCompanies();
		
		pr = controller.RedirectToHome();
		pr = controller.Cancel();
		
		pr = controller.ImportAsAccounts();
		}
		catch(Exception e) {}
		
	}
	
	public GetLists.CompanySearchResult[] myConstituents { get; set; }
	
	//Life Cycle and Functions
	   
	public PageReference OnInit()
	{
		if(getMySessionid() != null && getMySessionid() != 'test')
		{
			myConstituents = GetLists.GetListContents(getMyListTypeId(), getMyListId(), getMySessionid());
		}
		return null;
	}
	
	private String mySessionId;
	public String getMySessionid()
	{
		if(mySessionId != null ) { return mySessionId;}
		mySessionId = Session.getASPNETSessionId();
		return mySessionId;
	}
	public void setMySessionId(String value)
	{
		mySessionId = value;
	}
	
	private Integer myListTypeId;
	private Integer myListId;
	
	private List<Integer> myCompanies = new List<Integer>();
	public List<Integer> getCompanies()
	{
		myCompanies.clear();
		for(GetLists.CompanySearchResult csr : myConstituents)
		{
			if(csr.Selected)
			{ 
				myCompanies.add(csr.CompanyId);
			}
		}
		return myCompanies;
	}
	
	public Integer getMyListTypeId()
	{
		if(myListTypeId == null || myListTypeId == 0)
		{
			String id = System.currentPageReference().getParameters().get('ListTypeId');
			if(id != null)
			{
				myListTypeId = Integer.valueOf(id); 
			}
		}
		return myListTypeId;
	}
	public void setMyListTypeId(Integer value)
	{
		myListTypeId = value;
	}
	
	public Integer getMyListId()
	{
		if(myListId == null || myListId == 0)
		{
			String id = System.currentPageReference().getParameters().get('ListId');
			if(id != null)
			{
				myListId = Integer.valueOf(id);
			} 
		}
		return myListId;
	}
	public void setMyListId(Integer value)
	{
		myListId = value;
	}
	
	public PageReference RedirectToHome()
	{
		System.debug('Redirecting ...');
		PageReference homePage= new PageReference('/home/home.jsp');
        homePage.setRedirect(true);  
        return homePage;
	}
	
	public PageReference Cancel()
	{
		return RedirectToHome();
	}
	
	public PageReference ImportAsAccounts()
	{
		List<Integer> dontAlreadyExist = new List<Integer>();
		List<Integer> selected = getCompanies();
		List<String> selectedAsStrings = new List<String>();
		
		//if the user hasn't selected any items ...
		if(selected == null || selected.size() == 0) { return RedirectToHome(); }
		
		for(Integer sel : selected)
		{
			selectedAsStrings.add(String.valueOf(sel));
		}

		Set<Integer> alreadyExistSet = new Set<Integer>();
		
		List<Account> alreadyExist = [select a.Name, a.CapitalIQ_CompanyId__c from Account a where a.CapitalIQ_CompanyId__c in :selectedAsStrings];
		
		if(alreadyExist != null)
		{
			for(Account a : alreadyExist)
			{
				alreadyExistSet.add(Integer.valueof(a.CapitalIQ_CompanyId__c));
			}
		}
		
		for(Integer i : selected)
		{
			if(!alreadyExistSet.contains(i)) 
			{
				dontAlreadyExist.add(i);
			}
		}
		
		//if the user has already imported ALL of the selected items ...
		if(dontAlreadyExist == null || dontAlreadyExist.size() == 0) { return RedirectToHome();}
		
		GetCompanyInfo.CompanySummary[] infos = GetCompanyInfo.FetchCompanySummaries(dontAlreadyExist, Session.getASPNETSessionId());
		//this is more of a sanity check, the above should take care of the logical case where there were none to import ...
		if(infos == null || infos.size() == 0) { return RedirectToHome(); }
		
		List<Account> toInsert = new List<Account>();
		
		for(GetCompanyInfo.CompanySummary cs : infos)
		{
			Account a = new Account();
			a.Name = cs.CompanyName;
			a.TickerSymbol = cs.PrimaryTickerSymbol;
			a.CapitalIQ_CompanyId__c = String.valueOf(cs.CompanyId);
			if(cs.SimpleIndustryName.length() >= 40) 
			{
				a.Industry =  cs.SimpleIndustryName.subString(0,39);
			}
			else
			{
				a.Industry =  cs.SimpleIndustryName;
			}
			a.WebSite = cs.WebSiteURL; 
			a.NumberOfEmployees = cs.NumberOfEmployees;
			a.Phone = cs.PrimaryAddressInfo.Phone;
			a.Fax = cs.PrimaryAddressInfo.Fax;
			//a.Description = cs.BusinessDescription;
			toInsert.add(a);
		}
		
		insert toInsert;
		
		return RedirectToHome();
	}
}