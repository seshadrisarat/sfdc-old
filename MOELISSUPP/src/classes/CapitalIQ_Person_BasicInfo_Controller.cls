public class CapitalIQ_Person_BasicInfo_Controller 
{
	public static testMethod void TestHarness()
	{
		Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		System.currentPageReference().getParameters().put('id', cntct.Id);
		CapitalIQ_Person_BasicInfo_Controller controller = new CapitalIQ_Person_BasicInfo_Controller();
		controller.OnInit();
		controller.updateDescription = true;
		controller.updateFirstName = true;
		controller.updateLastName = true;
		controller.updateEmail = true;
		controller.updatePhone = true;
		controller.updateMobilePhone = true;
		controller.updateSalutation = true;
		controller.updateTitle = true;
		String s = controller.getCIQDescription();
		
		s = controller.getCIQSalutation();
		s = controller.getCIQFirstName();
		s = controller.getCIQLastName();
		s = controller.getCIQName();
		s = controller.getCIQEmailAddress();
		s = controller.getCIQBirthDate();
		s = controller.getCIQMobilePhone();
		s = controller.getCIQPhone();
		PageReference reference = controller.Cancel();
		AuthenticateServiceHTTP svce = controller.getAuthService();
		
		Boolean b = controller.updateFirstName;
		b = controller.updateLastName;
		b = controller.updateName;
		b = controller.updateBirthDate;
		b = controller.updatePhone; 
		b = controller.updateMobilePhone;
		
		Contact c = new Contact();
		controller.ContactId = c.Id;
		
		controller.updateFirstName = false;
		controller.updateLastName = false;
		controller.updateName = false;
		controller.updateBirthDate = false;
		controller.updatePhone = false;
		controller.updateMobilePhone = false; 
		controller.getContact();
		controller.getCIQSalutation();
		
		Pagereference pr = controller.Save();
	}	

	public String ContactId { get; set;}
	public Contact getContact()
	{
		return Session.Contact;
	}
	public void setContact(Contact contact)
	{
		Session.Contact = contact;	
	}
	
	public PageReference OnInit()
	{		
		ContactId = ApexPages.currentPage().getParameters().get('id');
		auth = new AuthenticateServiceHTTP();
		try
		{
			Contact temp = 
			[select
				c.AccountId
				,	c.Name
				,	c.FirstName
				,	c.LastName
				,	c.Phone
				,	c.Fax
				,	c.MobilePhone
				,	c.HomePhone
				,	c.Salutation
				,	c.Title
				,	c.Birthdate
				,	c.Description
				,	c.Email
				,	c.CapitalIQPersonId__c
				,	c.CapitalIQProfessionalId__c
				From Contact c			   
				where c.id = : ContactId];
			Session.Contact = temp;
			
			ASPNETSessionId = auth.LoginOrRetrieveSession();
			if(temp.CapitalIQPersonId__c != null)
			{
				personId = Integer.valueOf(temp.CapitalIQPersonId__c);
			}
			else
			{
				personId = 0;
			}
			if(temp.CapitalIQProfessionalId__c != null)
			{
				professionalId = Integer.valueOf(temp.CapitalIQProfessionalId__c);
			}
			else
			{
				professionalId = 0;
			}
			
			if(professionalId != 0)
			{
				PersonInfo = ProfessionalsDetail.GetProfessional(professionalId, ASPNETSessionId);
			}
			else
			{
				PersonInfo = ProfessionalsDetail.GetPerson(personId, ASPNETSessionId);
			}
		}
		catch(Exception e)
		{
			//do nothing
		}
		return null;
	}
	
	private Integer personId;
	private Integer professionalId;
	
	public Boolean updateFirstName { get; set; }
	public Boolean updateLastName { get; set; }
	public Boolean updateName { get; set; }
	public Boolean updateBirthDate { get; set; }
	public Boolean updateEmail { get; set; }
	public Boolean updatePhone { get; set; }
	public Boolean updateMobilePhone { get; set; }
	
	public Boolean updateSalutation { get; set; }
	public Boolean updateTitle { get; set; }
	public Boolean updateDescription { get; set; }
	
	public String getCIQFirstName()
	{
		if(PersonInfo != null)
		{
			return PersonInfo.FirstName;
		}
		return '';
	}
	
	public String getCIQLastName()
	{
		if(PersonInfo != null)
		{
			return PersonInfo.LastName;
		}
		return '';
	}
	
	public String getCIQName()
	{
		if(PersonInfo != null)
		{
			return PersonInfo.FirstName + ' ' + PersonInfo.LastName;
		}
		return '';
	}
	
	public String getCIQEmailAddress()
	{
		if(PersonInfo != null)
		{
			return PersonInfo.EmailAddress;
		}
		return '';
	}
	
	public String getCIQSalutation()
	{
		if(PersonInfo != null)
		{
			return PersonInfo.Salutation;
		}
		return '';
	}
	
	public String getCIQBirthDate()
	{
		if(PersonInfo != null)
		{
			return PersonInfo.YearBorn;
		}
		return '';
	}
	
	public String getCIQTitle()
	{
		if(PersonInfo != null)
		{
			if(PersonInfo.ProfessionalDetails != null && PersonInfo.ProfessionalDetails.ProfessionalDetail.size() != 0)
			{
				return ProfessionalsDetail.GetDetailForProfessionalId(PersonInfo.ProfessionalDetails.ProfessionalDetail, professionalId).Title;
			}
		}
		return '';
	}
	
	public String getCIQPhone()
	{
		if(PersonInfo != null)
		{
			if(PersonInfo.ProfessionalDetails != null && PersonInfo.ProfessionalDetails.ProfessionalDetail.size() != 0)
			{
				return PersonInfo.ProfessionalDetails.ProfessionalDetail[0].MainPhoneNumber;
			}
		}
		return '';
	}
	
	public String getCIQMobilePhone()
	{
		return '';
	}
	
	public String getCIQDescription()
	{
		if(PersonInfo != null)
		{
			return PersonInfo.PersonBiography;
		}
		return '';
	}
	
	public PageReference Save()
	{
		try
		{
			ContactId = ApexPages.currentPage().getParameters().get('id');
			Contact temp;
			try
			{
				temp = 
				[select
					c.AccountId
					,	c.FirstName
					,	c.LastName
					,	c.Phone
					,	c.Fax
					,	c.MobilePhone
					,	c.HomePhone
					,	c.Salutation
					,	c.Title
					,	c.Birthdate
					,	c.Description
					,	c.Email
					,	c.CapitalIQPersonId__c
					,	c.CapitalIQProfessionalId__c
					From Contact c			   
					where c.id = : ContactId];
			}
			catch(Exception e)
			{
				temp = new Contact();
			}
			
			if(updateFirstName) {temp.FirstName = getCIQFirstName();}
			if(updateLastName) {temp.LastName = getCIQLastName();}
			/*if(updateBirthDate) {temp.BirthDate = getCIQBirthDate();}*/
			if(updateEmail) {temp.Email = getCIQEmailAddress();}
			if(updatePhone) {temp.Phone = getCIQPhone();}
			if(updateMobilePhone) {temp.MobilePhone = getCIQMobilePhone();}
			if(updateSalutation) {temp.Salutation = getCIQSalutation();}
			if(updateTitle) {temp.Title = getCIQTitle().subString(0,80);}
			if(updateDescription) {temp.Description = getCIQDescription();}
			
			try
			{
				update temp;
			}
			catch(Exception e)
			{
				System.debug('Exception thrown : ' + e);
			}
			
			PageReference p = new PageReference('/' + ContactId);
			p.setRedirect(true);
			return p;
		}
		catch(Exception e)
		{
			return null;
		}
	}
	
	public PageReference Cancel()
	{
		PageReference p = new PageReference('/' + ContactId);
		p.setRedirect(true);
		return p;
	}
	
	public ProfessionalsDetail.Person PersonInfo { get; set; }
	
	private Boolean IsPostback = false;
	
	private AuthenticateServiceHTTP auth;
	public AuthenticateServiceHTTP getAuthService()
	{
		return auth;
	}
	
	private String ASPNETSessionId;
}