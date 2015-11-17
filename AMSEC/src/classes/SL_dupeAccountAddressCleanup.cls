global class SL_dupeAccountAddressCleanup implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	
	global SL_dupeAccountAddressCleanup() {
		
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		List<Account> accounts = [SELECT ID,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry from Account];
		return accounts;
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		for(Account a:scope)
		{
			if(a.BillingStreet==a.ShippingStreet)
			{
				a.ShippingStreet = '';
				a.ShippingCity = '';
				a.ShippingState = '';
				a.ShippingPostalCode = '';
				a.ShippingCountry = '';              
			}
		}
		update scope;
	}
	global void finish(Database.BatchableContext BC) {
		
	}
	
}