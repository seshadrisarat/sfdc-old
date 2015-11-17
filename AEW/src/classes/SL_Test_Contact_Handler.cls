/*
    *  ClassName    : SL_Test_Contact_Handler 
    *  JIRATicket   : AEW-12
    *  CreatedOn    : 07/02/2015
    *  ModifiedBy   : Harsh
    *  Description  : Test Class for Trigger on Contact
*/
@isTest
private class SL_Test_Contact_Handler {
    
    /*
        * MethodName : setup()
        * Param      : 
        * Description: Generic method to create Account, Opportunity, Product, PBEntry and OLI 
    */
    private static testMethod void testContactUpdates() {
        // Create common test accounts
        Account objAccount = new Account(Name = 'TestAccount-01', BillingCountry = 'United States', BillingState = 'Texas');
        insert objAccount;
		
		Account objAccountNew = new Account(Name = 'TestAccount-02', BillingCountry = 'United States', BillingState = 'Texas');
        insert objAccountNew;
		
        List <Contact> lstContacts = new List<Contact>{new Contact(LastName = 'Test-01', FirstName = 'Contact', AccountId = objAccount.Id),
        											  new Contact(LastName = 'Test-02', FirstName = 'Contact', AccountId = objAccount.Id),
        											  new Contact(LastName = 'Test-03', FirstName = 'Contact', AccountId = objAccount.Id)};
		insert lstContacts;
        system.assert(lstContacts[2].Id != NULL);
        
        Opportunity objOpportunity = new Opportunity(Name = 'TestOpportunity-01', Probability=90, Stagename = 'Prospecting', CloseDate = date.today()+2, Amount = 1000, AccountId = objAccount.Id);
        insert objOpportunity;
        
        // Inserting 1 tasks with WhatId is there and 1 without WhatId, so we will update the without one to the old Account of the current Contact....
        List<Task> lstTasks = new List<Task>{new Task(WhoId = lstContacts[0].Id, Subject = 'Task_For_Contact-01', Priority = 'Normal', Status = 'Not Started'),
        									 new Task(WhoId = lstContacts[0].Id, WhatId = objOpportunity.Id, Subject = 'Task_For_Contact-01', Priority = 'Normal', Status = 'Not Started'),
        									 new Task(WhoId = lstContacts[1].Id, Subject = 'Task_For_Contact-02', Priority = 'Normal', Status = 'Not Started'),
        									 new Task(WhoId = lstContacts[1].Id, WhatId = objOpportunity.Id, Subject = 'Task_For_Contact-02', Priority = 'Normal', Status = 'Not Started'),
        									 new Task(WhoId = lstContacts[2].Id, Subject = 'Task_For_Contact-03', Priority = 'Normal', Status = 'Not Started'),
        									 new Task(WhoId = lstContacts[2].Id, WhatId = objOpportunity.Id, Subject = 'Task_For_Contact-04', Priority = 'Normal', Status = 'Not Started')};
       insert lstTasks;
       system.assert(lstTasks[5].Id != NULL);
       
       // Inserting 1 tasks with WhatId is there and 1 without WhatId, so we will update the without one to the old Account of the current Contact....
        List<Event> lstEvents = new List<Event>{new Event(WhoId = lstContacts[0].Id, Subject = 'Task_For_Contact-01', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addMinutes(30)),
        									 new Event(WhoId = lstContacts[0].Id, WhatId = objOpportunity.Id, Subject = 'Task_For_Contact-01', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addMinutes(30)),
        									 new Event(WhoId = lstContacts[1].Id, Subject = 'Task_For_Contact-02', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addMinutes(30)),
        									 new Event(WhoId = lstContacts[1].Id, WhatId = objOpportunity.Id, Subject = 'Task_For_Contact-02', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addMinutes(30)),
        									 new Event(WhoId = lstContacts[2].Id, Subject = 'Task_For_Contact-03', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addMinutes(30)),
        									 new Event(WhoId = lstContacts[2].Id, WhatId = objOpportunity.Id, Subject = 'Task_For_Contact-04', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addMinutes(30)) };
       insert lstEvents;
       system.assert(lstEvents[5].Id != NULL);
       
       AEW_Mailing__c objAEWMailing = new AEW_Mailing__c(Name = 'Test Mailing - 01', Business_Unit__c = 'DIG');
       insert objAEWMailing;
       
       // inserting a fund Communication record....
       Fund_Communication__c objFundCommunication = new Fund_Communication__c(Name = 'Test_FC_REC_Contact_01', AEW_Mailing__c = objAEWMailing.Id, Primary_Recipient__c = lstContacts[0].Id);
       insert objFundCommunication;
       
       List<Fund_Communication_Recipient__c> lstFundCommunicationRec = new List<Fund_Communication_Recipient__c>{new Fund_Communication_Recipient__c(Fund_Communication__c = objFundCommunication.Id, Contact__c = lstContacts[0].Id),
       																					  						new Fund_Communication_Recipient__c(Fund_Communication__c = objFundCommunication.Id, Contact__c = lstContacts[1].Id),
       																					  						new Fund_Communication_Recipient__c(Fund_Communication__c = objFundCommunication.Id, Contact__c = lstContacts[2].Id)};
       insert lstFundCommunicationRec;
       
       Campaign objCampaign = new Campaign(Name = 'Test Capaign - 01');
       insert objCampaign;
       
       
       List<CampaignMember> lstCampaignMembers  = new List<CampaignMember>{new CampaignMember(CampaignId = objCampaign.Id,  ContactId = lstContacts[0].Id),
       																		new CampaignMember(CampaignId = objCampaign.Id, ContactId = lstContacts[1].Id),
       																		new CampaignMember(CampaignId = objCampaign.Id, ContactId = lstContacts[2].Id)};
       insert lstCampaignMembers;
       
       
       /**** Creating the FundRaising Opportunity Contact records for covering the sendEmail method()**/
       Fund__c objFund = new Fund__c(Name = 'Test Fund - 01');
       insert objFund;
       
       Fundraising_Opportunity__c objFundraisingOpportunity = new Fundraising_Opportunity__c(Name = 'Test FundRaising - 01', Stage__c = 'Finals', AEW_Point_Person__c = UserInfo.getUserId(), Organization__c = objAccount.Id, Fund__c = objFund.Id);
       insert objFundraisingOpportunity;
       
       
       List<Fundraising_Opportunity_Contact__c> lstFundOppConsToInsert = new List<Fundraising_Opportunity_Contact__c>{new Fundraising_Opportunity_Contact__c(Fundraising_Opportunity__c = objFundraisingOpportunity.Id, Contact__c = lstContacts[0].Id, Role__c = 'Decision Maker'),
       																												  new Fundraising_Opportunity_Contact__c(Fundraising_Opportunity__c = objFundraisingOpportunity.Id, Contact__c = lstContacts[1].Id, Role__c = 'Decision Maker'),
       																												  new Fundraising_Opportunity_Contact__c(Fundraising_Opportunity__c = objFundraisingOpportunity.Id, Contact__c = lstContacts[2].Id, Role__c = 'Decision Maker')};
       insert lstFundOppConsToInsert;
       
       /**** ENDS ****/
		Test.startTest();       
		// Checking the Task for Contact-01 where WhatId is Blank
		Task objTaskForContact_01 = [Select Id, WhatId From Task Where Id =: lstTasks[0].Id];
        system.assert(objTaskForContact_01.WhatId == NULL);
		// Checking the Task for Contact-02 where WhatId is Blank
		Task objTaskForContact_02 = [Select Id, WhatId From Task Where Id =: lstTasks[2].Id];
        system.assert(objTaskForContact_02.WhatId == NULL);
        // Checking the Task for Contact-03 where WhatId is Blank
        Task objTaskForContact_03 = [Select Id, WhatId From Task Where Id =: lstTasks[4].Id];
        system.assert(objTaskForContact_03.WhatId == NULL);       
       	
       	// Checking the Task for Contact-01 where WhatId is Blank
		Event objEventForContact_01 = [Select Id, WhatId From Event Where Id =: lstEvents[0].Id];
        system.assert(objEventForContact_01.WhatId == NULL);
		// Checking the Task for Contact-02 where WhatId is Blank
		Event objEventForContact_02 = [Select Id, WhatId From Event Where Id =: lstEvents[2].Id];
        system.assert(objEventForContact_02.WhatId == NULL);
        // Checking the Task for Contact-03 where WhatId is Blank
        Event objEventForContact_03 = [Select Id, WhatId From Event Where Id =: lstEvents[4].Id];
        system.assert(objEventForContact_03.WhatId == NULL);       
       	
       	// There will be no Affiliations records for any of the Contact records.
       	system.assert([Select Id From Affiliation__c Where Contact__c IN : lstContacts].size() == 0);
       	
        // Checking the Contact Status of the CapaignMember and Fund_Communication records
        List<CampaignMember> lstCampMembers = [Select Id, Contact_Status__c From CampaignMember Where ContactId IN : lstContacts];
        system.assert(lstCampMembers[0].Contact_Status__c == NULL);
        system.assert(lstCampMembers[0].Contact_Status__c == NULL);
        system.assert(lstCampMembers[0].Contact_Status__c == NULL);
        
        List<Fund_Communication_Recipient__c> lstFundCommunicationsReciptent = [Select Id, Contact_Status__c, Contact__c From Fund_Communication_Recipient__c Where Contact__c IN : lstContacts];
        system.assert(lstFundCommunicationsReciptent[0].Contact_Status__c == NULL);
        system.assert(lstFundCommunicationsReciptent[1].Contact_Status__c == NULL);
        system.assert(lstFundCommunicationsReciptent[2].Contact_Status__c == NULL);
        
        // Updating the Contact Status to "Retired", so the email portion will get cover
        lstContacts[0].Status__c = lstContacts[2].Status__c = 'Retired';
        lstContacts[1].Status__c = 'InActive'; // will work same as the Retired status as per recent requirement on AEW-12
       	update lstContacts;
        
        // Updating the Contact.Account Id 
       	lstContacts[0].AccountId = lstContacts[1].AccountId = lstContacts[2].AccountId = objAccountNew.Id;
       	update lstContacts;
       	
       	// There will be 3 Affiliations records for each of the Contact records. with the OLD Account i.e TestAccount-01 only.....
       	List<Affiliation__c> lstAffiliationRecords = [Select Contact__c, Role__c, Organization__c, Id From Affiliation__c Where Contact__c IN : lstContacts];
       	system.assertEquals(lstAffiliationRecords .size(), 3);
       	system.assertEquals(lstAffiliationRecords[0].Organization__c, objAccount.Id);
       	system.assertEquals(lstAffiliationRecords[0].Role__c, 'Previous Employee');
       	
       	system.assertEquals(lstAffiliationRecords[1].Organization__c, objAccount.Id);
       	system.assertEquals(lstAffiliationRecords[2].Role__c, 'Previous Employee');
       	
       	system.assertEquals(lstAffiliationRecords[2].Organization__c, objAccount.Id);
       	system.assertEquals(lstAffiliationRecords[2].Role__c, 'Previous Employee');
       	
       	// Checking the Task for Contact-01 where WhatId is updated to previous Account tha is "TestAccount-01"
		objTaskForContact_01 = [Select Id, WhatId From Task Where Id =: lstTasks[0].Id];
        system.assert(objTaskForContact_01.WhatId == objAccount.Id);
		// Checking the Task for Contact-02 where WhatId is Blank
		objTaskForContact_02 = [Select Id, WhatId From Task Where Id =: lstTasks[2].Id];
        system.assert(objTaskForContact_02.WhatId == objAccount.Id);
        // Checking the Task for Contact-03 where WhatId is Blank
        objTaskForContact_03 = [Select Id, WhatId From Task Where Id =: lstTasks[4].Id];
        system.assert(objTaskForContact_03.WhatId == objAccount.Id);       
       	
       	// Checking the Task for Contact-01 where WhatId is Blank
		objEventForContact_01 = [Select Id, WhatId From Event Where Id =: lstEvents[0].Id];
        system.assert(objEventForContact_01.WhatId == objAccount.Id);
		// Checking the Task for Contact-02 where WhatId is Blank
		objEventForContact_02 = [Select Id, WhatId From Event Where Id =: lstEvents[2].Id];
        system.assert(objEventForContact_02.WhatId == objAccount.Id);
        // Checking the Task for Contact-03 where WhatId is Blank
        objEventForContact_03 = [Select Id, WhatId From Event Where Id =: lstEvents[4].Id];
        system.assert(objEventForContact_03.WhatId == objAccount.Id);
       	
       	// The campaignMember Contact_Status will be "Inactive"  related to the contacts
       	lstCampMembers = [Select Id, Contact_Status__c From CampaignMember Where ContactId IN : lstContacts];
        system.assertEquals(lstCampMembers[0].Contact_Status__c, 'Inactive');
        system.assertEquals(lstCampMembers[1].Contact_Status__c, 'Inactive');
        system.assertEquals(lstCampMembers[2].Contact_Status__c, 'Inactive');
       	
       	// The Fund Communication Contact_Status will be "Inactive"  related to the contacts
       	lstFundCommunicationsReciptent = [Select Id, Contact_Status__c, Contact__c From Fund_Communication_Recipient__c Where Contact__c IN : lstContacts];
        system.assertEquals(lstFundCommunicationsReciptent[0].Contact_Status__c, 'Inactive');
        system.assertEquals(lstFundCommunicationsReciptent[0].Contact_Status__c, 'Inactive');
        system.assertEquals(lstFundCommunicationsReciptent[0].Contact_Status__c, 'Inactive');
       	   		
       	Test.stopTest();   				 
    }
}