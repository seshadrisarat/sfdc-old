public class CapitalIQ_Financials_Controller 
{
	public static testMethod void TestHarness()
	{
		CapitalIQSetup_Controller.InitOrgInfo();
		CapitalIQ_Financials_Controller controller = new CapitalIQ_Financials_Controller();
		Account a = new Account();
		a.CapitalIQ_CompanyId__c = '123123';
		controller.setAccount(a);
		controller.getAccount();
		controller.setDrawControls(true);
		controller.getDrawControls();
		
		String s = controller.getFinancialsLink();
		s = controller.getHeader5();
		s = controller.getHeader4();
		s = controller.getHeader3();
		s = controller.getHeader2();
		s = controller.getHeader1();
		s = controller.getHeader0();
		s = controller.getAnnual5();
		s = controller.getAnnual4();
		s = controller.getAnnual3();
		s = controller.getAnnual2();
		s = controller.getAnnual1();
		s = controller.getAnnual0();
		s = controller.getFiling5();
		s = controller.getFiling4();
		s = controller.getFiling3();
		s = controller.getFiling2();
		s = controller.getFiling1();
		s = controller.getFiling0();
		FinancialData.DisplayItem[] d = controller.getDisplayItems();
	}
	
	public CapitalIQ_Financials_Controller()
	{
		try
		{
			myAccount = Session.Account; 
		}
		catch(Exception e)
		{
			System.debug('CapitalIQ_KeyDevs_Controller.ctor threw -> ' + e);
			return;
		}
	}
	
	private Boolean myDrawControls = true;
	public void setDrawControls(Boolean drawControls)
	{
		if(drawControls == null)
		{
			myDrawControls = true;
		}
		else
		{
			myDrawControls = drawControls;
		}
		if(myDisplayItems == null)
		{
			if(myAccount != null && myAccount.CapitalIQ_CompanyId__c != null && myDrawControls)
			{
				if(SessionId() != null)
				{
					myDisplayItems = FinancialData.FormatData(FinancialData.GetTearsheetFinancials(Integer.valueOf(myAccount.CapitalIQ_CompanyId__c), SessionId()));
				}
			}
		}
	}
	public Boolean getDrawControls()
	{
		return myDrawControls;
	}
	
	private String myASPNETSessionId;
	private String SessionId()
	{
		if(myASPNETSessionId == null)
		{
			myASPNETSessionId = String.valueOf(Session.get(Session.CapitalIQSession));
		}
		return myASPNETSessionId;
	}
	
	private Account myAccount;
	public Account getAccount() 
	{ 
		return myAccount;
	}
	public void setAccount(Account inAcct)
	{
		myAccount = inAcct;
	}
	
	public String getFinancialsLink()
	{
		if(myAccount != null && myAccount.CapitalIQ_CompanyId__c == null)
		{
			return '';
		}
		return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(myAccount.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.IncomeStatement, 'View More Financials');
	}
	
	private FinancialData.DisplayItem[] myDisplayItems;
	public FinancialData.DisplayItem[] getDisplayItems()
	{
		return myDisplayItems; 
	}
	
	public String getHeader5()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].EffectiveDates[0];
		}
		else
		{
			return '';
		}
	}
	public String getHeader4()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].EffectiveDates[1];
		}
		else
		{
			return '';
		}
	}
	public String getHeader3()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].EffectiveDates[2];
		}
		else
		{
			return '';
		}
	}
	public String getHeader2()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].EffectiveDates[3];
		}
		else
		{
			return '';
		}
	}
	public String getHeader1()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].EffectiveDates[4];
		}
		else
		{
			return '';
		}
	}
	public String getHeader0()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].EffectiveDates[5];
		}
		else
		{
			return '';
		}
	}
	
	public String getAnnual5()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].Headers[0];
		}
		else
		{
			return '';
		}
	}
	public String getAnnual4()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].Headers[1];
		}
		else
		{
			return '';
		}
	}
	public String getAnnual3()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].Headers[2];
		}
		else
		{
			return '';
		}
	}
	public String getAnnual2()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].Headers[3];
		}
		else
		{
			return '';
		}
	}
	public String getAnnual1()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].Headers[4];
		}
		else
		{
			return '';
		}
	}
	public String getAnnual0()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].Headers[5];
		}
		else
		{
			return '';
		}
	}
	
	public String getFiling5()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].FilingDates[0];
		}
		else
		{
			return '';
		}
	}
	public String getFiling4()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].FilingDates[1];
		}
		else
		{
			return '';
		}
	}
	public String getFiling3()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].FilingDates[2];
		}
		else
		{
			return '';
		}
	}
	public String getFiling2()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].FilingDates[3];
		}
		else
		{
			return '';
		}
	}
	public String getFiling1()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].FilingDates[4];
		}
		else
		{
			return '';
		}
	}
	public String getFiling0()
	{
		FinancialData.DisplayItem[] diArray = getDisplayItems();
		if(diArray != null && diArray.size() > 0)
		{
			return diArray[0].FilingDates[5];
		}
		else
		{
			return '';
		}
	}
}