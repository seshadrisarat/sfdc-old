@isTest
private class SL_Test_AffiliationHandler 
{
	private static testMethod void SL_Test_AffiliationHandler() 
	{
	    test.starttest();
    	list<Account> lstAccounts = new list<Account>{new Account(Name = 'TestAccount'),
    												  new Account(Name = 'TestAccount-01'),
    												  new Account(Name = 'TestAccount-02'),
    	                                              new Account(Name = 'TestAccount-023') 
    	};
    	insert lstAccounts; 
    	
    	list<Contact> lstContact = new list<Contact>{new Contact(LastName = 'TestContact', AccountId=lstAccounts[2].Id),
    												  new Contact(LastName = 'TestContact-01'),
    												  new Contact(LastName = 'TestContact-02'),
    	                                              new Contact(LastName = 'TestContact-023') 
    	};
    	insert lstContact; 
    	
    	Affiliation__c objAff = new Affiliation__c(Company__c = lstAccounts[0].Id, To_Company__c = lstAccounts[1].Id);
    	insert objAff;
    	
    	Affiliation__c objAff2 = new Affiliation__c(To_Company__c = lstAccounts[1].Id, Contact__c = lstContact[0].Id );
    	insert objAff2;
    	
    	//Querying Created Inverse connection through trigger
    	Affiliation__c objInverseAffiliation = [Select Company__c,To_Company__c,Related_Affiliaton__c from Affiliation__c where Related_Affiliaton__c =: objAff.Id ];
    	
    	// Verifying expected results for creation of Inverse connection record.
    	system.assertEquals(objAff.Company__c,objInverseAffiliation.To_Company__c);
    	system.assertEquals(objAff.To_Company__c,objInverseAffiliation.Company__c);
    	
    	
    	objAff.Company__c = lstAccounts[3].Id;
    	update objAff;
    	
    	objAff2.Company__c = lstAccounts[0].Id;
    	update objAff2;
    	
    	//Querying Created Inverse connection through trigger
    	Affiliation__c objUpdatedInverseAffiliation = [Select Company__c,To_Company__c,Related_Affiliaton__c from Affiliation__c where Id =: objInverseAffiliation.Id ];
    	
    	
    	// Verifying expected results for creation of Inverse connection record.
    	system.assertEquals(objUpdatedInverseAffiliation.Company__c,objAff.To_Company__c);
    	system.assertEquals(objUpdatedInverseAffiliation.To_Company__c,objAff.Company__c);
    	
    	delete objAff;
    	
    	undelete objAff;
    	
    	delete objAff2;
    	undelete objAff2;
    	test.stoptest();
	}

}