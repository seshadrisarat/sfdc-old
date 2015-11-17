global class SL_dupeContactAddressCleanup implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	
	global SL_dupeContactAddressCleanup() {
		
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		List<Contact> contacts = [SELECT ID,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,Other_Street__c,Other_City__c,Other_State_Province__c,Other_Zip_Postal_Code__c,Other_Country__c from Contact];
		return contacts;
	}

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
		for(Contact c:scope)
		{
			if(c.MailingStreet!=null && c.MailingStreet==c.OtherStreet)
			{
				c.OtherStreet = '';
				c.OtherCity = '';
				c.OtherState = '';
				c.OtherPostalCode='';
				c.OtherCountry = '';
			}
			if(c.MailingStreet!=null && c.MailingStreet==c.Other_Street__c)
			{
				c.Other_Street__c = '';
				c.Other_City__c = '';
				c.Other_State_Province__c = '';
				c.Other_Zip_Postal_Code__c='';
				c.Other_Country__c = '';
			}
			if(c.OtherStreet!=null && c.OtherStreet==c.Other_Street__c)
			{
				c.Other_Street__c = '';
				c.Other_City__c = '';
				c.Other_State_Province__c = '';
				c.Other_Zip_Postal_Code__c='';
				c.Other_Country__c = '';
			}
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}