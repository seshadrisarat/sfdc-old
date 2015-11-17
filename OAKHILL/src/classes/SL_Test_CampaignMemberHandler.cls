/**
* \arg ClassName      : SL_Test_CampaignMemberHandler
* \arg JIRATicket     : OAKHILL-26
* \arg CreatedOn      : 18/JUNE/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class works as test class for SL_CampaignMember trigger for checking the functionality of roll ups.
*/
@isTest
private class SL_Test_CampaignMemberHandler 
{
	static List<Contact> lstContact;
	static List<Lead> lstLead;
	static List<Campaign> lstCampaign;
	static List<CampaignMember> lstCampaignMember;
	
	//Method for preparding test data
	private static void createData()
	{
		lstContact = new List<Contact>{
										  new Contact(LastName = 'Test Contact 1', Email = 'Test1@gmail.com'),
										  new Contact(LastName = 'Test Contact 2', Email = 'Test1@gmail.com'),
										  new Contact(LastName = 'Test Contact 3', Email = 'Test2@gmail.com')
									  };
		insert lstContact;
		
		lstLead = new List<Lead>{
									new Lead(LastName = 'Test Lead 1', Email = 'Test3@gmail.com', Company = 'Test Company 1'),
									new Lead(LastName = 'Test Lead 2', Email = 'Test4@gmail.com', Company = 'Test Company 2')
								};
		insert lstLead;
		
		lstCampaign = new List<Campaign>{
											new Campaign(Name = 'Test Campaign 1'),
											new Campaign(Name = 'Test Campaign 2')
										};
		insert lstCampaign;
		
		lstCampaignMember = new List<CampaignMember>{
														new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = lstContact[0].Id),
														new CampaignMember(CampaignId = lstCampaign[0].Id, LeadId = lstLead[0].Id),
														new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = lstContact[1].Id),
														new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = lstContact[1].Id),
														new CampaignMember(CampaignId = lstCampaign[1].Id, LeadId = lstLead[1].Id)
													};
		insert lstCampaignMember;
	}
	
	//method for checking insert functionality
    static testMethod void checkForInsert() 
    {
        createData();
        system.assertEquals('test3@gmail.com;test1@gmail.com', [SELECT Campaign_Member_Emails__c FROM Campaign WHERE Id=:lstCampaign[0].Id].Campaign_Member_Emails__c);
        system.assertEquals('test1@gmail.com;test4@gmail.com', [SELECT Campaign_Member_Emails__c FROM Campaign WHERE Id=:lstCampaign[1].Id].Campaign_Member_Emails__c);
    }
    
    //method for checking delete functionality
    static testMethod void checkForDelete()
    {
    	createData();
    	
    	Test.startTest();
    	delete lstCampaignMember[4];
    	Test.stopTest();
    	
        system.assertEquals('test1@gmail.com', [SELECT Campaign_Member_Emails__c FROM Campaign WHERE Id=:lstCampaign[1].Id].Campaign_Member_Emails__c);
    }
}