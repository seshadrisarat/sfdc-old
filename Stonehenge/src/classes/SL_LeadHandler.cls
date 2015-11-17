/**
 
* \see http://silverline.jira.com/browse/STONEPII-17
 
* \brief SL_LeadTrigger trigger handler.Runs on after update of lead.
 
*/
public without sharing class SL_LeadHandler 
{
	/*	Constructor	*/
	public SL_LeadHandler() 
	{}
	
	/* 
	Method : onAfterUpdate
	Parameters : Lead New Map
	Desc : This Method fires on after update of Lead
	
	*/
	public void onAfterUpdate(Map<Id,Lead> mapNew)
	{
		// This method creates Contact Roles for all the Converted Opportunities
		createContactRole(mapNew);
	}
	
	/*
	Method : createContactRole
	Parameters : Lead New Map
	Desc : Creates a new Contact Role for all the Converted Opportunities.
	
	*/
	private void createContactRole(Map<Id,Lead> mapNew)
	{
		Set<Id> setConvertedOppIds = new Set<Id>(); // Set of all the converted Opportunity Id's
		List<Contact_Role__c> lstNewContactRoles = new List<Contact_Role__c>(); // list of all the new contact roles
		
		for(Lead l : mapNew.values())
		{
			if(l.IsConverted && l.ConvertedOpportunityId != null)
			{
				// adding all the converted Opportunity Id's to Set
				setConvertedOppIds.add(l.ConvertedOpportunityId);
			}
		}
		
		for(Opportunity opp : [Select Id,AccountId,Account.PersonEmail From Opportunity WHERE Id IN :setConvertedOppIds])
		{
			// Creating a new Contact Role for each converted Opportunity
			Contact_Role__c cr = new Contact_Role__c();
			cr.Opportunity__c = opp.Id;
			cr.Contact__c = opp.AccountId;
			cr.Role__c = 'Tenant';
			cr.Contact_Email__c = opp.Account.PersonEmail;
			lstNewContactRoles.add(cr);
		}
		
		if(!lstNewContactRoles.isEmpty())
			insert lstNewContactRoles;
	}
	
	@isTest(SeeAllData=true)
	private static void testLeadTrigger()
	{
		Account account = new Account();
		account.Name = 'test';
		insert account;
		
		Contact contact = new Contact();
		contact.LastName = 'test';
		contact.AccountId = account.Id;
		insert contact;
		
		Lead l1 = new Lead();
		l1.Company = 'test1';
		l1.LastName = 'test';
		l1.Status = 'Open';
		l1.Fax = '2334';
		l1.Property_Name__c = '10 Downing';
		insert l1;
		
		// Create dummy conversion
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l1.id);
        lc.setAccountId(account.Id);
        lc.setContactId(contact.Id);
        lc.setOpportunityName('Test Opportunity');
        LeadStatus convertstatus = [select Id, MasterLabel from LeadStatus where IsConverted= true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
	}
	
}