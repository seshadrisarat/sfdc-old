public class CapitalIQ_KeyDevs_Controller 
{
	public static testMethod void TestHarness()
	{
		CapitalIQ_KeyDevs_Controller controller = new CapitalIQ_KeyDevs_Controller();
		Account a = new Account();
		a.CapitalIQ_CompanyId__c = '123123';
		controller.setAccount(a);
		CapitalIQException e = new CapitalIQException();
		String s = controller.getKeyDevsLink();
		KeyDevelopments.KeyDevelopment[] d = controller.getKeyDevelopments();
		controller.setDrawControls(false);
		controller.getDrawControls();
		controller.getAccount();
	}
	
	public CapitalIQ_KeyDevs_Controller()
	{
		try
		{
			acctId = Session.Account; 
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
		myDrawControls = drawControls;
		if(myKeyDevelopments == null) 
		{
			if(acctId != null)
			{
				if(acctId.CapitalIQ_CompanyId__c != null && myDrawControls)
				{
					if(SessionId() != null)
					{
						System.debug('Inside KeyDevs controller call.');
						myKeyDevelopments = KeyDevelopments.GetKeyDevelopments(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), SessionId());
					}
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
	
	private Account acctId;
	public Account getAccount()
	{
		return acctId;
	}
	public void setAccount(Account inAcct)
	{
		acctId = inAcct;
	}
	
	public String getKeyDevsLink()
	{
		if(acctId.CapitalIQ_CompanyId__c == null)
		{
			return '';
		}
		return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.KeyDevelopments, 'View More Key Developments');
	}
	
	private KeyDevelopments.KeyDevelopment[] myKeyDevelopments;
	public KeyDevelopments.KeyDevelopment[] getKeyDevelopments()
	{ 
		return myKeyDevelopments;
	}
}