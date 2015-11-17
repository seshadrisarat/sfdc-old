@isTest
private class SL_Test_DiffRecordUtil
{
	@isTest
	static void testDiffRecords()
	{
		Set<String> allAccountFieldNames = Schema.SObjectType.Account.fields.getMap().keySet();
		List<Account> accounts = new List<Account>{
			new Account(Name='a', AccountNumber='100', AnnualRevenue=10000),
			new Account(Name='b', AccountNumber='200', AnnualRevenue=20000)
		};

		insert accounts;

		Map<Id, Account> mapIdToAccount = new Map<Id, Account>(accounts);
		List<Account> accountsToCompare = new List<Account>();
        for (Account testAccount: accounts){
            accountsToCompare.add(testAccount.clone(true,true,true,true));
        }
		accountsToCompare[0].AccountNumber='1000';
		Map<Id, Account> mapIdToAccountsToCompare = new Map<Id, Account>(accountsToCompare);

		List<Account> accountsWithDifference = 
			SL_util_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, 'Name');
		System.assert(accountsWithDifference.isEmpty(), 'Expected no differences, found ' + accountsWithDifference.size());

		accountsWithDifference = 
			SL_util_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, 'AccountNumber');
		System.assertEquals(1, accountsWithDifference.size());
		System.assertEquals('1000', accountsWithDifference[0].AccountNumber);

		accountsWithDifference = 
			SL_util_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, new Set<String>{'Name', 'AnnualRevenue'});
		System.assert(accountsWithDifference.isEmpty(), 'Expected no differences, found ' + accountsWithDifference.size());

		accountsWithDifference = 
			SL_util_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, new Set<String>{'Name', 'AccountNumber'});
		System.assertEquals(1, accountsWithDifference.size());
		System.assertEquals('1000', accountsWithDifference[0].AccountNumber);

        try {
            SL_util_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, 'Test');
            System.assert(false, 'Did not throw exception for invalid field name.');
        }
        catch(Exception e){}
        
        accounts.remove(0);
        try {
            SL_util_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, 'Name');
            System.assert(false, 'Did not throw exception for lists of different sizes.');
        }
        catch(Exception e){}
        List <Contact> contacts = new List<Contact>{new Contact(LastName='Test')};
        try {
            SL_util_DiffRecord.getRecordsWithDiff(accounts, contacts, 'Name');
            System.assert(false, 'Did not throw exception for lists of different types.');
        }
        catch(Exception e){} 
   
		// maps

		Map<Id, SObject> mapAccountsWithDifference = 
            SL_util_DiffRecord.getRecordsWithDiff(mapIdToAccount, mapIdToAccountsToCompare, 'Name');
		System.assert(mapAccountsWithDifference.isEmpty(),
						'Expected no differences, found ' + mapAccountsWithDifference.size());

		mapAccountsWithDifference = 
			SL_util_DiffRecord.getRecordsWithDiff(mapIdToAccount, mapIdToAccountsToCompare, 'AccountNumber');
		System.assertEquals(1, mapAccountsWithDifference.size());
		System.assertEquals('1000', mapAccountsWithDifference.values()[0].get('AccountNumber'));

		mapAccountsWithDifference = 
			SL_util_DiffRecord.getRecordsWithDiff(mapIdToAccount, mapIdToAccountsToCompare, new Set<String>{'Name', 'AnnualRevenue'});
		System.assert(mapAccountsWithDifference.isEmpty(), 'Expected no differences, found ' + mapAccountsWithDifference.size());

		mapAccountsWithDifference = 
			SL_util_DiffRecord.getRecordsWithDiff(mapIdToAccount, mapIdToAccountsToCompare, new Set<String>{'Name', 'AccountNumber'});
		System.assertEquals(1, mapAccountsWithDifference.size());
		System.assertEquals('1000', mapAccountsWithDifference.values()[0].get('AccountNumber'));        
	}
    @isTest
    static void testGetSObjectName(){
        List<Account> accounts = new List<Account>{
			new Account(Name='a', AccountNumber='100', AnnualRevenue=10000),
			new Account(Name='b', AccountNumber='200', AnnualRevenue=20000)
		};
		SL_util_DiffRecord.getSObjectTypeName(accounts[0]);
        SL_util_DiffRecord.getSObjectTypeName(accounts[1]);
        SL_util_DiffRecord.getSObjectTypeName(new Contact(LastName='test'));
    }
}