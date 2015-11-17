public with sharing class ConvertOwnersController {
	
	public String LastName{get;set;}
	
	public void ConvertOwners(){
		List<Contact> contacts = new List<Contact>();

		contacts = [select id, lastname, ScriptCompleted__c, Account.OwnerId from Contact where ScriptCompleted__c = true order by lastname limit 2000];
		
		for (Contact c : contacts)
		{
		c.OwnerId = c.Account.OwnerId;
		c.ScriptCompleted__c = false;
		LastName = c.lastname;
		}
		
		update contacts;
	}
	
	public void ConvertOwnersBackward(){
		List<Contact> contacts = new List<Contact>();

		contacts = [select id, lastname, ScriptCompleted__c, Account.OwnerId from Contact where ScriptCompleted__c = true order by lastname desc limit 2000];
		
		for (Contact c : contacts)
		{
		c.OwnerId = c.Account.OwnerId;
		c.ScriptCompleted__c = false;
		LastName = c.lastname;
		}
		
		update contacts;
	}
	
	public static testMethod void t1() {
		
		Account a = new Account();
		a.Name = 'test';
		a.Prospect_Status__c = 'Qualified Prospect';
		
		insert a;
		
		Contact c = new Contact();
		c.FirstName = 'test';
		c.LastName = 'test';
		c.AccountId = a.id;
		c.ScriptCompleted__c = true;
		
		insert c;
		
		ConvertOwnersController coc = new ConvertOwnersController();
		coc.ConvertOwners();
		coc.ConvertOwnersBackward();
	}	
	

}