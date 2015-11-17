/**
* Test methods are in Test_CallLog.cls
**/
public with sharing class CallLog_Deal_new {

	public CallLog_Deal_new() {
		callLog = new Call_Log__c();
		callLogDeal = new Call_Log_Deal__c();
		this.callLogDeal.Deal__c = this.dealId;
		//this.callLog.Date__c = Date.today();
		//this.callLog.Organizer__c = CallLog_Contact_new_logic.getEmployee(UserInfo.getUserId()).Id;
	}
	
	public String ownerName {
		get {
			return UserInfo.getName();
		}
	}
	
	public Call_Log__c callLog {get; set;}
	public Call_Log_Deal__c callLogDeal {get; set;}
	
	/*public Call_Log_Deal__c getCallLogDeal() {
		return callLogDeal;
	}
	public void setCallLogDeal(Call_Log_Deal__c value) {
		this.callLogDeal = value;
	}

	public Call_Log__c getCallLog() {
		return callLog;
	}
	public void setCallLog(Call_Log__c value) {
		this.callLog = value;
	}*/
	
	private Id dealId_p = null;
	public Id dealId {
		get {
			if (dealId_p == null) {
				dealId_p = ApexPages.currentPage().getParameters().get('dealid');
			}
			return dealId_p;
		}
	}
	
	public PageReference save() {
		PageReference pg = new PageReference('/'+dealId);
		
		insert this.callLog;
		this.callLogDeal.Call_Log__c = this.callLog.Id;
		insert this.callLogDeal;
		
		pg.setRedirect(true);
		return pg;
	}
	
	public PageReference save_new() {
		PageReference pg = new PageReference('/apex/CallLog_Deal_new?dealid='+dealId);

		this.callLog.Date__c = Date.today();
		insert this.callLog;
		this.callLogDeal.Call_Log__c = this.callLog.Id;
		insert this.callLogDeal;
		
		this.callLog = new Call_Log__c();
		this.callLogDeal = new Call_Log_Deal__c();
		this.callLogDeal.Deal__c = this.dealId;
		//this.callLog.Date__c = Date.today();
		
		pg.setRedirect(true);
		return pg;
	}
	
	public PageReference cancel() {
		PageReference pg = new PageReference('/'+dealId);
		pg.setRedirect(true);
		return pg;
	}
	
	public String errBlock {
		get {
			String res = '0';
			if (dealId == null) {
				res = '1';
			}
			return res;
		}
	}
	
}