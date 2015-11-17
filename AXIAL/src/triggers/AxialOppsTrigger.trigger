trigger AxialOppsTrigger on CATH_Deal__c (before insert, before update) {
	if(trigger.isBefore){
		List<Decimal> slugs = new List<Decimal>();
		for(CATH_Deal__c c :trigger.new){
			if(c.Assigned_To_Axial_Account_Unique_Slug__c != null){
				slugs.add(c.Assigned_To_Axial_Account_Unique_Slug__c);
			}
		}
		List<Account> relatedAccounts = [SELECT Id, AXM_Unique_Slug_Id__c 
											 FROM Account 
											 WHERE AXM_Unique_Slug_Id__c in :slugs];

		Map<Decimal, Account> acctsBySlug = new Map<Decimal, Account>();
		for(Account a :relatedAccounts){ acctsBySlug.put(a.AXM_Unique_Slug_ID__c, a); }

		Map<Id, Contact> relatedContacts = new Map<Id, Contact>([SELECT Id, AccountId
										 FROM Contact
										 WHERE Id in
										   (SELECT Assigned_User__c 
										   	FROM CATH_Deal__c 
										   	WHERE id in :trigger.new)]);

		for (CATH_Deal__c so : Trigger.new) {
			Account relatedAccount = acctsBySlug.get(so.Assigned_To_Axial_Account_Unique_Slug__c);
			if(relatedAccount != null){
				Id acctId = relatedAccount.Id;
				if(acctid != null){
					so.Seller__c = acctId;
				}
			}else{
				Contact relatedContact = relatedContacts.get(so.Assigned_User__c);
				if(relatedContact != null){
					Id acctId = relatedContact.AccountId;
					if(acctId != null){
						so.Seller__c = relatedContacts.get(so.Assigned_User__c).AccountId;
					}
				}
			}
		}
	}
}