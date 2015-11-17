/**
* \arg ClassName      : SL_Test_TearSheetReportPDF
* \arg JIRATicket     : WP-131
* \arg CreatedOn      : 20/APR/2015
* \arg LastModifiedOn : 22/APR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class is used to check the functionality of tearsheet report pdf controller.
*/

@isTest
private class SL_Test_TearSheetReportPDF 
{
	private static List<Event> lstEvent;
	private static List<Event> lstChildEvents;
	private static Account objAccount;
	private static Fund__c objFund;
	private static List<Contact> lstContact;
	private static Fundraising_Opportunity__c objFundraisingOpp;
	private static List<Associated_Commitment__c> lstAssociatedCommitment;
	
	private static void createData()
	{
		objAccount = new Account(Name = 'Test Account', Website = 'www.test.com', Description = 'This is test description');
		insert objAccount;
		
		objFund = new Fund__c(Name = 'Test Fund');
		insert objFund;
		
		objFundraisingOpp = new Fundraising_Opportunity__c(Name = 'Test FundRaising Opp', Fund__c = objFund.Id);
		insert objFundraisingOpp;
		
		lstContact = new List<Contact>{
											new Contact(LastName = 'Test Contact 1', Title = 'Test Title1'),
											new Contact(LastName = 'Test Contact 2', Title = 'Test Title2'),
											new Contact(LastName = 'Test Contact 3', Title = 'Test Title3'),
											new Contact(LastName = 'Test Contact 4', Title = 'Test Title4'),
											new Contact(LastName = 'Test Contact 5', Title = 'Test Title5')
									  };
		insert lstContact;
		
		lstEvent = new List<Event>{new Event(Subject = 'Test Event 1', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addDays(2)
											 , WhatId = objAccount.Id, Location = 'Finland', Internal_Contacts__c = 'Test Contact 1, Test Contact 2',
											 External_Contacts__c = 'Test Contact 3, Test Contact 4, Test Contact 5'),
									new Event(Subject = 'Test Event 1', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addDays(2)
											 , WhatId = objFundraisingOpp.Id)
								   };
		insert lstEvent;
		
		lstChildEvents = new List<Event>{
											new Event(Subject = 'Test child Event 1', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addDays(2), ParentId__c = lstEvent[0].Id, WhatId = objAccount.Id),
											new Event(Subject = 'Test child Event 1', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addDays(2), ParentId__c = lstEvent[0].Id, WhatId = objFundraisingOpp.Id)
										};
		
		lstAssociatedCommitment = new List<Associated_Commitment__c>{
																		new Associated_Commitment__c(Investor__c = objAccount.Id, Fund__c = objFund.Id)
																	};
		insert lstAssociatedCommitment;
	}
	
	static testMethod void checkFunctionality()
	{
		createData();
		
		Apexpages.currentPage().getParameters().put('id', lstEvent[0].Id);
		
		SL_TearSheetReportPDFController objController = new SL_TearSheetReportPDFController();
		objController.getAssociatedCommitment();
		objController.getAssociatedEntities();
		objController.getExternalAttendees();
		objController.getPreviousEvents();
		objController.getTimeZoneCode();
		objController.getMostRecentFundName();
		objController.getFundRaisingOpportunity();
	}
}