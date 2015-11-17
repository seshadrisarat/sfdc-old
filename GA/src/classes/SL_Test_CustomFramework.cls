/**
* @date 11/9/2014
* @description This class provides unit tests for the framework.
*/
@isTest (oninstall=true seealldata=false)
public with sharing class SL_Test_CustomFramework { 
	/** 
	* @date 11/9/2014
	* @description This method tests the framework using the sample account trigger. 
	*/
	@isTest (oninstall=true seealldata=false)
	public static void testAccountTrigger() {
		Account acct = new Account();
		acct.Name = 'testacct1';
		insert acct;

		Account acct2 = [SELECT Id, Name FROM Account WHERE Name = 'testacct1'];
		acct2.Name = 'testacct2';
		update acct2;
		//KillSwitch
		SL_TriggerFactory.KillSwitchEnabled = true;
		update acct2;
		SL_TriggerFactory.KillSwitchEnabled = false;
		//Fake Exception
		SL_TriggerFactory.FakeException = true;
		//DebugInfo Log
		SL_DiagnosticsInstrumentation.EmailDebugInfoEnabled = true;
		SL_DiagnosticsInstrumentation.DebugInfoMaxAge = 7;
		SL_DiagnosticsInstrumentation.DebugInfoEmailRecipients = 'test@test.com';
		update acct2;
		SL_TriggerFactory.FakeException = false;
		update acct2;
		acct2 = [SELECT Id, Name, Website FROM Account WHERE Name = 'testacct2'];
		delete acct2;
		List<Account> allAccounts = [SELECT Id FROM Account];
		System.assert(allAccounts.isEmpty(),'Error in testAccountTrigger. Stacktrace: ' + SL_DiagnosticsInstrumentation.ExceptionTrace);
		allAccounts = [SELECT Id FROM Account ALL ROWS];
		undelete allAccounts;
		allAccounts = [SELECT Id FROM Account];
		System.assert(!allAccounts.isEmpty(),'Error in testAccountTrigger. Stacktrace: ' + SL_DiagnosticsInstrumentation.ExceptionTrace);
	}
}