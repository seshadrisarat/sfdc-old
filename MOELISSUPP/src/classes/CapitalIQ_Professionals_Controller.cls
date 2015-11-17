public class CapitalIQ_Professionals_Controller 
{
	public static testMethod void TestHarness()
	{
		CapitalIQ_Professionals_Controller controller = new CapitalIQ_Professionals_Controller();
		controller.acctId = new Account();
		
		String s = controller.getProsLink();
		s = controller.getBMLink();
		s = controller.getAccountId();
		s = CapitalIQ_Professionals_Controller.GetAddProfessionalLink(123123213);
		controller.setDrawControls(false);
		Boolean b = controller.getDrawControls();
		s = controller.SessionId();
	}	
	
	public CapitalIQ_Professionals_Controller()
	{
		try
		{
			acctId = Session.Account; 
		}
		catch(Exception e)
		{
			System.debug('CapitalIQ_Professionals_Controller.ctor threw -> ' + e);
			return;
		}
	}	

	public String getProsLink()
	{
		if(acctId == null || acctId.CapitalIQ_CompanyId__c == null)
		{
			return '';
		}
		return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.Professionals, 'View More Professionals');
	}
	
	public String getBMLink()
	{
		if(acctId.CapitalIQ_CompanyId__c == null)
		{
			return '';
		}
		return CapitalIQ_PlatformLink.RenderLink(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), CapitalIQ_PlatformLink.BoardMembers, 'View More Board Members');
	}
	
	public Account acctId;
	
	public String getAccountId()
	{
		return acctId.Id;
	}
	
	private Boolean myDrawControls = true;
	public void setDrawControls(Boolean drawControls)
	{
		myDrawControls = drawControls;
		if(acctId.CapitalIQ_CompanyId__c != null && SessionId() != null)
		{
			if(myDrawControls)
			{
				if(myExecutives == null)
				{
					myExecutives = Professionals.ProSort(Professionals.GetKeyProfessionals(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), SessionId()));
				}
				if(myBoardMembers == null)
				{
					myBoardMembers = Professionals.GetBoardMembers(Integer.valueOf(acctId.CapitalIQ_CompanyId__c), SessionId());
				}
			}
		}
	}
	
	public static String GetAddProfessionalLink(Integer professionalId)
	{
		String link = '<a href=\"/apex/ProfessionalResolution?ProfessionalId=' + String.valueOf(professionalId) + '\"';
		link = link + 'Add</a>';
		return link;
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
			myASPNETSessionid = String.valueOf(Session.get(Session.CapitalIQSession)); 
		}
		return myASPNETSessionid;
	}
	
	private Professionals.Professional[] myExecutives;
	public Professionals.Professional[] getExecutives()
	{
		return myExecutives;
	}
	
	private Professionals.Professional[] myBoardMembers;
	public Professionals.Professional[] getBoardMembers()
	{
		return myBoardMembers;
	}
	
}