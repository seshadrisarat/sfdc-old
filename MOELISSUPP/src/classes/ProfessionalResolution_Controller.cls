public class ProfessionalResolution_Controller 
{
	
	public static testMethod void TestHarness()
	{
		ProfessionalResolution_Controller controller = new ProfessionalResolution_Controller();
		Account a = controller.getAccount();
		Contact c = controller.getContact();
		try
		{
			controller.OnInit();
			
			PageReference r = controller.CreateContactFromCapitalIQInfo(123123, null);
			r = controller.GoToCompanyResolution();
		}
		catch(Exception e)
		{ 
			//try swallow.
		}
	}
	
	//the general workflow is as follows
	//the first round of dev
	//check if the account is resolved or not
		//if not resolve it
	//pull up all the pro's for a company
		//let the user select which pro is correct, and move to basic info
		
	public String AccountId { get; set; }
	public String ContactId { get; set; }
	private String ASPNETSessionId;
	private Boolean IsPostback = false;
	public Professionals.Professional[] Results { get; set; }
	
	public Integer PersonId { get; set; }
	public Integer ProfessionalId { get; set; }
	
	public Integer getResultSize()
	{
		if(Results == null) { return 0; }
		return Results.size();
	}
	
	public Account getAccount()
	{
		Account account;
		try
		{
			account = [select a.Name, a.CapitalIQ_CompanyId__c From Account a				   
				where a.id = : AccountId];
		}
		catch(Exception e)
		{
			System.debug('ProfessionalResolution_Controller.getAccount() --> Caught Ex: ' + e);	
		}
		return account;
	}
	
	public Contact getContact()
	{
		Contact contact;
		try
		{
			contact = [select c.Name, c.AccountId, c.CapitalIQPersonId__c, c.CapitalIQProfessionalId__c From Contact c				   
				where c.id = : ContactId];
		}
		catch(Exception e)
		{
			System.debug('ProfessionalResolution_Controller.getContact() --> Caught Ex: ' + e);	
		}
		return contact;
	}
	
	public PageReference OnInit()	
	{
		
		String professionalId = System.currentPageReference().getParameters().get('ProfessionalId');
		AccountId = System.currentPageReference().getParameters().get('AccountId');
		
		if(professionalId != null)
		{
			//we're creating a contact
			return CreateContactFromCapitalIQInfo(Integer.valueOf(professionalId), AccountId);
		}
		
		AccountId = System.currentPageReference().getParameters().get('AccountId');
		ContactId = System.currentPageReference().getParameters().get('ContactId');
		
		//get the account
		//test if it has a 
		Contact c = getContact();
		
		if(AccountId == null)
		{
			if(c != null)
			{
				AccountId = c.AccountId;
			}
			System.debug('ProfessionalResolution_Controller.OnInit() --> Fell back to Contacts AccountId');
		}
		else
		{
			System.debug('ProfessionalResolution_Controller.OnInit() --> AccountId ' + AccountId);
		}
		
		Account a = getAccount();
		
		if(a != null)
		{
			if(a.CapitalIQ_CompanyId__c == null)
			{
				//we haven't resolved the company yet either ...
				return GoToCompanyResolution();
			}
		
			//authenticate
			AuthenticateServiceHTTP auth = new AuthenticateServiceHTTP();
			ASPNETSessionId = auth.LoginOrRetrieveSession();
			
			//get a list of pros at a company
			Results = Professionals.ProSort(Professionals.GetAllProfessionals(Integer.valueOf(a.CapitalIQ_CompanyId__c), ASPNETSessionId));
		}
		return null;
	}
	
	private String myASPNETSessionId;
	public String getASPNETSessionId()
	{
		if(myASPNETSessionId != null) { return myASPNETSessionId; }
		AuthenticateServiceHTTP auth = new AuthenticateServiceHTTP();
		myASPNETSessionid = auth.LoginOrRetrieveSession();
		return myASPNETSessionid;
	}
	public void setASPNETSessionId(String value)
	{
		myASPNETSessionId = value;
	}
	
	public PageReference CreateContactFromCapitalIQInfo(Integer professionalId, String accountId) 
	{
		Contact newContact = new Contact();
		
		ProfessionalsDetail.Person p = ProfessionalsDetail.GetProfessional(professionalId, getASPNETSessionId());
		//newContact.Name = p.FirstName + ' ' + p.LastName;
		newContact.FirstName = p.FirstName;
		newContact.LastName = p.LastName;
		String title = ProfessionalsDetail.GetDetailForProfessionalId(p.ProfessionalDetails.ProfessionalDetail, ProfessionalId).Title;
		if(title.length() > 80) { title = title.subString(0,80); }
		newContact.Title = title;
		newContact.Email = p.EmailAddress;
		newContact.Phone = ProfessionalsDetail.GetDetailForProfessionalId(p.ProfessionalDetails.ProfessionalDetail, ProfessionalId).MainPhoneNumber;
		newContact.Salutation = p.Salutation;
		newContact.Description = p.PersonBiography;
		newContact.AccountId = accountId;
		newContact.CapitalIQProfessionalId__c = String.valueOf(professionalId);
		newContact.CapitalIQPersonId__c = String.valueOf(p.PersonId);
		
		System.debug('CreateContactFromCapitalIQInfo() --> AccountId: ' + accountId);
		
		insert newContact;
		
		PageReference ref = new PageReference('/' + newContact.Id);
		ref.setRedirect(true);
		return ref;
	}
	
	public PageReference Resolve()
	{
		IsPostback = true;
		
		ContactId = System.currentPageReference().getParameters().get('ContactId');
		Contact c = getContact();
		
		c.CapitalIQPersonId__c = String.valueOf(PersonId);
		c.CapitalIQProfessionalId__c = String.valueOf(ProfessionalId);
		
		update c;
		
		PageReference p = new PageReference('/apex/CapitalIQ_Person_basic?id=' + ContactId);
		p.setRedirect(true);
		return p;
	}
	
	public PageReference GoToCompanyResolution()
	{
		PageReference p = new PageReference('/apex/CompanyResolution?ContactId=' + ContactId + '&AccountId=' + AccountId);
		p.setRedirect(true);
		return p;
	}
}