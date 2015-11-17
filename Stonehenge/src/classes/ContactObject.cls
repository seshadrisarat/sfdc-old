public class ContactObject
{
	public static testMethod void myUnitTest() 
    {
    	Account objTestAccount = new Account();
    	objTestAccount.Name = 'Test Account';
    	insert objTestAccount;
    	
    	Contact objTestContact = new Contact();
    	objTestContact.LastName = 'Test Contact';
    	objTestContact.AccountId = objTestAccount.Id;
    	insert objTestContact;
    	
    	Opportunity objOpp = new Opportunity();
		objOpp.Name = 'test';
		objOpp.AccountId = objTestAccount.Id;
		objOpp.Pricebook2Id = [Select Id from Pricebook2 limit 1].Id;
		//objOpp.CurrencyIsoCode = 'USD'; 
		objOpp.StageName = 'Validated';
		objOpp.CloseDate = date.newInstance(2009, 04, 16);
		insert objOpp;
		
		OpportunityContactRole objOCR = new OpportunityContactRole();
		objOCR.OpportunityId = objOpp.Id;
		objOCR.ContactId = objTestContact.Id;
		insert objOCR;
    	
    	ContactObject objContactObject = new ContactObject(objOCR);
    	String temp = objContactObject.ContactName;
    	objContactObject.ContactName = 'test';
    	temp = objContactObject.ContactName;
    	objContactObject.ContactId = objTestContact.Id;
    	
    	Boolean bool = objContactObject.isRole;
    	bool = objContactObject.isRole;
    }
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
}