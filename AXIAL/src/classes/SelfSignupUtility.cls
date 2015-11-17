public with sharing class SelfSignupUtility {
	public SelfSignupUtility() {
		
	}

	public void assignSelfSignups(){
		List<Contact> selfSignups = [SELECT 
										Id, FirstName, LastName, Self_Signup_Date__c 
									 FROM Contact 
									 WHERE Self_Signup_Date__c != null 
									 AND Owner.Name LIKE '%SynchronizationAccount%'];
		
	}
}