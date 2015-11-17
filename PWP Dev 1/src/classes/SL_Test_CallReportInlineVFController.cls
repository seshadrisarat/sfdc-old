/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 
 /**
* \arg ClassName      : SL_Test_CallReportInlineVFController
* \arg JIRATicket     : PWP-1,PWP-2,PWP-14
* \arg CreatedOn      : 04/Dec/14
* \arg LastModifiedOn : 12/FEB/2015
* \arg CreatededBy    : Nrusingh
* \arg ModifiedBy     : Pradeep
* \arg Description    : This class is test class for SL_CallReportInlineVFController
*/

@isTest
private class SL_Test_CallReportInlineVFController 
{
    static testMethod void CallReportInlineVFController() 
    {
		// Create Contact Record
		List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'TestContact0'),
													 new Contact(LastName = 'TestContact1'),
													 new Contact(LastName = 'TestContact2')};
		insert lstContact;
		
		// Create Account Record
		List<Account> lstAccount = new List<Account>{new Account(Name = 'TestAccount0'),
													 new Account(Name = 'TestAccount1'),
													  new Account(Name = 'TestAccount2')};
		insert lstAccount;
		
		// Create Call report record
		Call_Report__c objCallReport = new Call_Report__c(Name = 'Test CR1', Call_Report_Date__c = Date.today(), Reference_Account__c = lstAccount[0].Id); 
		insert objCallReport;
		
		// Create Task Record
		List<Task> lstTask = new List<Task>{
											new Task(Status = 'Completed', Subject = 'test1', WhoId = lstContact[0].Id,
													 WhatId = lstAccount[0].Id),
											new Task(Status = 'Completed', Subject = 'test2', WhoId = lstContact[0].Id,
													 WhatId = lstAccount[0].Id),
											new Task(Status = 'Completed', Subject = 'test3', WhoId = lstContact[0].Id,
													 WhatId = lstAccount[0].Id)};
		insert lstTask;
		
		// Create Event Record
		List<Event> lstEvent = new List<Event>{
												new Event(Subject = 'test1', WhoId = lstContact[0].Id, WhatId = lstAccount[0].Id,
														  StartDateTime = Datetime.now(), EndDateTime = Datetime.now()),
												new Event(Subject = 'test1', WhoId = lstContact[0].Id, WhatId = lstAccount[0].Id,
														  StartDateTime = Datetime.now(), EndDateTime = Datetime.now()),
												new Event(Subject = 'test1', WhoId = lstContact[0].Id, WhatId = lstAccount[0].Id,
														  StartDateTime = Datetime.now(), EndDateTime = Datetime.now())};
		insert lstEvent;
														  
		// Create Call ReportAttendee Record
		List<Call_Report_Attendees__c> lstCallReportAttendees = new List<Call_Report_Attendees__c>
			{new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id , Call_Report_Attendee__c = lstContact[0].Id),
			 new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id , Call_Report_Attendee__c = lstContact[1].Id),
			 new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id , Call_Report_Attendee__c = lstContact[2].Id)}; 
		insert lstCallReportAttendees;
		
		// Create Call ReportCompany Record
		List<Call_Report_Company__c> lstCallReportCompany = new List<Call_Report_Company__c>
			{new Call_Report_Company__c(Call_Report__c = objCallReport.Id , Relevant_Company__c = lstAccount[0].Id),
			 new Call_Report_Company__c(Call_Report__c = objCallReport.Id , Relevant_Company__c = lstAccount[1].Id),
			 new Call_Report_Company__c(Call_Report__c = objCallReport.Id , Relevant_Company__c = lstAccount[2].Id)};
		insert lstCallReportCompany;
		
		ApexPages.StandardController sc = new ApexPages.standardController(objCallReport);  
		
		Apexpages.currentPage().getParameters().put('objId', lstAccount[0].Id);
		Apexpages.currentPage().getParameters().put('ActId', lstTask[0].Id);
		
		SL_CallReportInlineVFController objController = new SL_CallReportInlineVFController(sc);
		//objController.createCallReport();
		
		/*	Call Report Attendees	*/
		objController.addAttendee();
		objController.strObjectName = 'Call Report Attendee';
		objController.lstWrapperAttendee[0].objAttendee.Call_Report_Attendee__c = lstContact[0].Id;
		objController.saveAll();
		objController.strAttendeeId = objController.lstWrapperAttendee[0].objAttendee.Id;
		objController.editAttendee();
		objController.lstWrapperAttendee[0].isCancelRecord = true;
		objController.cancelAttendeeRecord();
		objController.delAttendee();
		objController.lstWrapperAttendee[0].isSelected = true;
		objController.editRecords();
		
		objController.addCompany();
		objController.strObjectName = 'Call Report Company';
		objController.lstWrapperCompany[0].objCompany.Relevant_Company__c = lstAccount[0].Id;
		objController.saveAll();
		objController.strCompanyId = objController.lstWrapperCompany[0].objCompany.Id;
		objController.editCompany();
		objController.lstWrapperCompany[0].isCancelRecord = true;
		objController.cancelCompanyRecord();
		objController.delCompany();
		objController.deleteRecords();
		objController.lstWrapperCompany[0].isSelected = true;
		objController.editRecords();
    }
}