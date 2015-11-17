/** 
* \author Vladimir Prishlyak
* \date 10/09/2012
* \see https://silverline.jira.com/browse/WP-4
* \details Expense Code Generation Trigger logic 
* \
*/
@isTest(SeeAllData=true)
private class SL_test_Util_Generator
{
	static testMethod void test_SL_Util_Generator_P1()
	{
		Test.startTest();
		
		String retCode =  SL_Util_Generator.getNextExpenseCode(null);
		System.assert( retCode == 'AAAAAA', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('AA');
		System.assert( retCode == 'AAAAAA', 'incorrect ExpenseCode!' );

		retCode =  SL_Util_Generator.getNextExpenseCode('JAAA0');
		System.assert( retCode == 'JAAA1', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JAAA9');
		System.assert( retCode == 'JAAAA', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JAAAH');
		System.assert( retCode == 'JAAAK', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JAAAN');
		System.assert( retCode == 'JAAAP', 'incorrect ExpenseCode!' );

		retCode =  SL_Util_Generator.getNextExpenseCode('JAA0Z');
		System.assert( retCode == 'JAA10', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JAA9Z');
		System.assert( retCode == 'JAAA0', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JAAHZ');
		System.assert( retCode == 'JAAK0', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JAANZ');
		System.assert( retCode == 'JAAP0', 'incorrect ExpenseCode!' );


		retCode =  SL_Util_Generator.getNextExpenseCode('JA0ZZ');
		System.assert( retCode == 'JA100', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JA9ZZ');
		System.assert( retCode == 'JAA00', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JAHZZ');
		System.assert( retCode == 'JAK00', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JANZZ');
		System.assert( retCode == 'JAP00', 'incorrect ExpenseCode!' );

		retCode =  SL_Util_Generator.getNextExpenseCode('J0ZZZ');
		System.assert( retCode == 'J1000', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('J9ZZZ');
		System.assert( retCode == 'JA000', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JHZZZ');
		System.assert( retCode == 'JK000', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('JNZZZ');
		System.assert( retCode == 'JP000', 'incorrect ExpenseCode!' );


		retCode =  SL_Util_Generator.getNextExpenseCode('0ZZZZ');
		System.assert( retCode == '10000', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('9ZZZZ');
		System.assert( retCode == 'A0000', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('HZZZZ');
		System.assert( retCode == 'K0000', 'incorrect ExpenseCode!' );
		retCode =  SL_Util_Generator.getNextExpenseCode('NZZZZ');
		System.assert( retCode == 'P0000', 'incorrect ExpenseCode!' );
		
		Test.stopTest();
	}
	
	static testMethod void test_SL_Util_Generator_P2()
	{
		 Test.startTest();

		RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];

//        Profile Prof1 = [Select id,name FROM Profile WHERE name = 'System Administrator']; 
        	
        // Create dummy account
        Account testAccount = new Account(
          Name='Test 022015 Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;

        Account testAccount2 = new Account(
          Name='Test 2015 Account 002',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,LastName = 'Test 2015 Contact Name'
         ,Title = 'Test Title Contact'
         ,  User_ID__c = UserInfo.getUserId()
        );
        insert testContact;

        Deal__c testDeal = new Deal__c(
             Name = 'Test 2015 Deal 001'
           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           /*, Target_Sectors__c = 'Energy'*/
           , ISOPENSTAGE__c = 1
//           , CurrencyIsoCode =
           , Stage__c = 'Early-Prospect' 
           , Expense_Code__c ='JAAUY'
           , Is_Energy_Opportunity__c = 'No'
        );
        insert testDeal;


		Deal__c testDeal2 = new Deal__c(
             Name = 'Test 201502 Deal 002'
           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           /*, Target_Sectors__c = 'Energy'*/
           , ISOPENSTAGE__c = 1
//           , CurrencyIsoCode =
           , Stage__c = 'Early-Prospect' 
           , Expense_Code__c = null
           , Is_Energy_Opportunity__c = 'No'
        );
        insert testDeal2;
	
		Test.stopTest();
	}
	
	
	
}