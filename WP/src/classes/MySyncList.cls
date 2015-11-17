public with sharing class MySyncList {
	private final Contact ct;
	public MySyncList(ApexPages.StandardController stdController) 
	{
		this.ct = (Contact)stdController.getRecord();
		//this.contact = (Contact)stdController.getRecord();
	}
	
	public void createCompanyListMembers()
	{
		//return contact.FirstName;
		ID contactid = this.ct.ID;
		List<Contact> lstInital = [Select c.Initials__c From Contact c where c.User_ID__c= :UserInfo.getUserId()];
		
		if (!lstInital.isEmpty())
		{
			String userInital = lstInital[0].Initials__c;
			String listname = '*My Sync List (' + userInital + ')';
			List<Company_List__c> clc = [Select c.Id from Company_List__c c where c.Name= :listname];
			
			if (!clc.isEmpty())
			{
				List<Company_List_Member__c> listmember = [Select Id from Company_List_Member__c where Company_List__c= :clc[0].Id and Contact__c= :ct.ID];
				if (listmember.isEmpty()) {
					Company_List_Member__c objCompanyListMember = new Company_List_Member__c(Company_List__c = clc[0].Id, Contact__c = this.ct.ID);
					System.debug('createcompanylistmem ' + objCompanyListMember);
					Database.insert(objCompanyListMember, true);
				}
			}
			
		}
		
	}
}