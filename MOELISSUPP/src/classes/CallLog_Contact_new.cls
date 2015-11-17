/**
* Test methods are in Test_CallLog.cls
**/
public with sharing class CallLog_Contact_new {
	
	public CallLog_Contact_new() {
		callLog = new Call_Log__c();
		callLogContact = new Call_Log_Contact__c();
		this.callLogContact.Contact__c = this.contactId;
		//this.callLog.Date__c = Date.today();
		//this.callLog.Organizer__c = CallLog_Contact_new_logic.getEmployee(UserInfo.getUserId()).Id;
	}
	
	public String ownerName {
		get {
			return UserInfo.getName();
		}
	}
	
	public Call_Log__c callLog {get; set;}
	public Call_Log_Contact__c callLogContact {get; set;}
	
	/*public Call_Log_Contact__c getCallLogContact() {
		return callLogContact;
	}
	public void setCallLogContact(Call_Log_Contact__c value) {
		this.callLogContact = value;
	}

	public Call_Log__c getCallLog() {
		return callLog;
	}
	public void setCallLog(Call_Log__c value) {
		this.callLog = value;
	}*/
	
	private Id contactId_p = null;
	public Id contactId {
		get {
			if (contactId_p == null) {
				contactId_p = ApexPages.currentPage().getParameters().get('contactid');
			}
			return contactId_p;
		}
	}
	
	public PageReference save() {
		PageReference pg = new PageReference('/'+contactId);
		
		insert this.callLog;
		this.callLogContact.Call_Log__c = this.callLog.Id;
		insert this.callLogContact;
		
		pg.setRedirect(true);
		return pg;
	}
	
	public PageReference save_new() {
		PageReference pg = new PageReference('/apex/CallLog_Contact_new?contactid='+contactId);

		this.callLog.Date__c = Date.today();
		insert this.callLog;
		this.callLogContact.Call_Log__c = this.callLog.Id;
		insert this.callLogContact;
		
		this.callLog = new Call_Log__c();
		this.callLogContact = new Call_Log_Contact__c();
		this.callLogContact.Contact__c = this.contactId;
		//this.callLog.Date__c = Date.today();
		
		pg.setRedirect(true);
		return pg;
	}
	
	public PageReference cancel() {
		PageReference pg = new PageReference('/'+contactId);
		pg.setRedirect(true);
		return pg;
	}
	
	public String errBlock {
		get {
			String res = '0';
			if (contactId == null) {
				res = '1';
			}
			return res;
		}
	}

}