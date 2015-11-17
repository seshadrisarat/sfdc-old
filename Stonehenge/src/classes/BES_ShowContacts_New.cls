public class BES_ShowContacts_New
{
	public static testMethod void myUnitTest() 
    {
    	Account acc = new Account();
    	acc.NAme = 'test';
    	insert acc;
    	
    	Opportunity opp = new Opportunity();
    	opp.Name = 'test';
    	opp.AccountId = acc.Id;
    	opp.StageName = 'Open';
    	opp.CloseDate = date.today();
    	insert opp;
    	
    	string OpprId = opp.Id;
    	system.currentPageReference().getParameters().put('Id',OpprId);
    	system.currentPageReference().getParameters().put('ContactId','');
    	BES_ShowContacts_New ShowContacts = new BES_ShowContacts_New();
    	ShowContacts.RedirectToRole();
    	ShowContacts.getNullEmailContacts();
    	ShowContacts.getNullEmailContact();   
    	ShowContacts.RedirectToEmail();
    	ShowContacts.CancelContacts();
    }
	public String OpprId{get;set;}
	public String ContactId{get;set;}
	public Boolean renderMessage{get;set;}
	public String Message{get;set;}
	//List<OpportunityContactRole> lstOCRole;
	List<Contact_Role__c> lstContactRole = new List<Contact_Role__c>();
	public BES_ShowContacts_New()
	{
		OpprId = system.currentPageReference().getParameters().get('Id');
		//lstOCRole = [select ContactId from OpportunityContactRole where OpportunityId =:OpprId and ]
		lstContactRole = [select Contact__c, Contact__r.personEmail from Contact_Role__c where Opportunity__c = :OpprId and (Contact__r.personEmail = null or Role__c != 'Tenant' or Role__c != 'Guarantor')];
		getNullEmailContacts();
		
	}
	public List<ContactObject> getNullEmailContact()
    {
    	return lstconObj;
    }
	List<ContactObject> lstconObj;
	public PageReference RedirectToRole()
	{
		
			PageReference pr = new PageReference('/p/opp/ContactRoleEditUi/e?oppid=' + OpprId + '&retURL=' + OpprId);
			pr.setRedirect(true);
			return pr;
		
	}
	public PageReference RedirectToEmail()
	{
		ContactId = system.currentPageReference().getParameters().get('ContactId');
		if(ContactId != null)
		{
			PageReference pr = new PageReference('/' + ContactId);
			pr.setRedirect(true);
			return pr;
		}
		else
		{
			return null;
		}
	}
    /*public class ContactObject
    {
    	public string  ContactName{get;set;}
    	public string ContactId{get;set;}
    	public Boolean isRole{get;set;}
    	public Boolean isEmail{get;set;}
    	public ContactObject(OpportunityContactRole con)
    	{
    		ContactId = con.ContactId;
    		if(con.Contact.Email == null)
    		{
    			isRole = false;
    			isEmail = true;
    		}
    		else
    		{
    			isRole = true;
    			isEmail = false;
    		}	
    		system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Contact Id &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&' +  con.ContactId);
    		String  FirstName = [select LastName  from Contact where Id = : con.ContactId Limit 1].LastName;
			ContactName = FirstName;
			system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&& Contact Name &&&&&&&&&&&&&&&&&&&&&&&&&&&' + FirstName); 
    	}
    }*/
    public PageReference getNullEmailContacts()
	{
		lstconObj = new List<ContactObject>();
		/*for(Integer k=0;k<lstContactRole.size();k++)
		{
			ContactObject conObj = new ContactObject(lstContactRole[k]);
			lstconObj.add(conObj);
		}*/
		if(lstconObj.size() <= 0) 
		{
			renderMessage = true;
		}
		else
		{
			renderMessage = false;
		}
		return null;  
	}
	public PageReference CancelContacts()
	{
		PageReference pr = new PageReference('/'+OpprId);
		pr.setRedirect(true);
		return pr;
	} 
}