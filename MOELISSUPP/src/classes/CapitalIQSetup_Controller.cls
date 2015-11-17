public class CapitalIQSetup_Controller 
{
	public static testMethod void TestHarness()
	{
		CapitalIQSetup_Controller controller = new CapitalIQSetup_Controller();
		controller.ClearEntries();
		CapitalIQSetup_Controller.InitOrgInfo();
		controller.CheckData();
		controller.Reset();
		
		controller.SelfRedirect();
		controller.myOrg=  new CapitalIQOrganization__c();
		controller.myOrg.WebServiceUrl__c = 'http://api.capitaliq.com/';
		controller.Save();
		
	}
	
	public CapitalIQOrganization__c myOrg;
	
	public PageReference CheckData()
	{		
		try
		{
			InitOrgInfo();
		} 
		catch(Exception e)
		{
			System.debug('\n\nCapitalIQSetup_Controller.CheckData() --> Caught Ex:' + e);
		}
		
		return null;
	}
	
	public void ClearEntries()
	{
		CapitalIQOrganization__c[] orgs = [Select org.Username__c, org.Password__c, org.WebServiceUrl__c
											From CapitalIQOrganization__c org];
		delete orgs;
	}
	
	public static void InitOrgInfo()
	{
			CapitalIQOrganization__c[] orgs = [Select org.Username__c, org.Password__c, org.WebServiceUrl__c
				From CapitalIQOrganization__c org LIMIT 1];
			if(orgs.size() == 0)
			{
				CreateDefaultEntry();
			}
	}
	
	public static void CreateDefaultEntry()
	{
		System.debug('CapitalIQSetup_Controller() --> Creating default organization info.');
		//create new default
		CapitalIQOrganization__c org = new CapitalIQOrganization__c(Username__c = 'Please Enter Username', Password__c='Please Enter Password');
		org.WebServiceUrl__c = 'https://api.capitaliq.com/';
		insert org;
	}
	
	public PageReference Reset()
	{
		System.debug('CapitalIQSetup_Controller() --> Creating default organization info.');
		ClearEntries();
		CreateDefaultEntry();
		return SelfRedirect();
	}
	
	public CapitalIQOrganization__c getCapitalIQOrganization()
	{
		if(myOrg != null){ return myOrg; }
		else
		{
			try
			{
				myOrg = [Select org.Username__c, org.Password__c, org.WebServiceUrl__c
						From CapitalIQOrganization__c org LIMIT 1];
			}
			catch(Exception e)
			{
				System.debug('\n\nCapitalIQOrganization.Get() --> Caught Ex:' + e);
			}
		}
		return myOrg;
	}
	
	public PageReference SelfRedirect()
	{
		PageReference setup = new PageReference('/apex/CapitalIQ_Setup');
        setup.setRedirect(true);  
        return setup;
	}
	
	public PageReference Save() 
	{
		if(myOrg.WebServiceUrl__c.endsWith('/'))
		{
			myOrg.WebServiceUrl__c = myOrg.WebServiceUrl__c.subString(0,  myOrg.WebServiceUrl__c.length() - 1);
		}
		try
		{
			update myOrg;
		}
		catch (Exception e)
		{
			// do nothing	
		}
        PageReference homePage= new PageReference('/home/home.jsp');
        homePage.setRedirect(true);  
        return homePage;
	}
}