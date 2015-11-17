// IF(IsTask, '', HYPERLINK( "/apex/GPCallReport?activityId="+Id ,  "GP Call Report"  , "_top"))

public with sharing class GPCallReport {
	public class activity {
		public String Investor {get;set;}
		public Date aDate {get;set;}
		public Contact aContact {get;set;}
		public String aRefferedBy {get;set;}
		public String aDescription {get;set;}
		public String aStatus {get;set;}
	}
	public Event event = null;
	public RECA_Fund_Interests__c fundInterest = null;
	public Contact contact = null;
	private String activityId;
	
	public GPCallReport() {
		activityId = ApexPages.currentPage().getParameters().get('activityId');
	}

	public Event getEvent() {
		if (this.event == null) {
			for(Event item : [SELECT WhoId, WhatId, Description, Opportunity_Status__c, ActivityDate FROM Event WHERE id = :activityId limit 1]) {
				this.event = item;
			}
		}
		this.event.Description = nl2br(this.event.Description);
		return this.event;
	}
	
	public RECA_Fund_Interests__c getFundInteresting() {
		if (this.fundInterest == null) {
			for(RECA_Fund_Interests__c item : [
			 	SELECT Investor__c, Investor__r.Referred_By__c, Investor__r.Name
				FROM RECA_Fund_Interests__c
				WHERE id = :getEvent().WhatId limit 1])
			{
				this.fundInterest = item;
			}
		}
		return this.fundInterest;
	}

	public Contact getContact() {
		if (this.contact == null) {
			for (Contact item : [
				SELECT Title, Phone, Name, MobilePhone, Home_Zip__c, Home_Street__c, Home_State__c, Home_City__c, 
						MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Email 
				FROM Contact 
				WHERE id = :getEvent().WhoId limit 1])
			{
				this.contact = item;
			}
		}
		return this.contact;
	}
	
	private String nl2br(String input) {
		if (input != null) {
			String s = input.replaceAll('\r\n', '</p><p>');
			s = '<p>' + s + '</p>';
			return s; //input.replaceAll('\r\n', '<BR style="mso-special-character: line-break"/>');
		}
		else
			return input;
	}
	
	
	public static testMethod void testThis() {
		RECA_Fund__c testRF = new RECA_Fund__c();
		insert testRF;
		
		Account testAccount = new Account(name='testAccount');
		insert testAccount;
		
		RECA_Fund_Interests__c testFund = new RECA_Fund_Interests__c(RECA_Fund__c=testRF.Id, Investor__c=testAccount.Id);
		insert testFund;
		
		Contact testContact = new Contact(FirstName='testFirst', LastName='testLast'); 
		insert testContact;
		
		Event testEvent = new Event(DurationInMinutes=5, ActivityDateTime=datetime.newInstance(2011,1,1), WhoId=testContact.Id, WhatId=testFund.Id, Description='fdsafds\r\nfdsagdf');
		insert testEvent;
		
		ApexPages.currentPage().getParameters().put('activityId', testEvent.Id);
		
		GPCallReport con = new GPCallReport();
		con.getEvent();
		con.getContact();
		con.getFundInteresting();
	}
}