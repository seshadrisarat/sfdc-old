/**
 * \author Vika Osmak 
 * \date 06/23/11
 * \see http://silverline.jira.com/browse/MC-2
 * \brief Test Class for trigger SL_CallLogContact on Call_Log_Contact__c
 */
@isTest
private class SL_Test_CallLogContact_Trigger_Handler 
{
	static testMethod void SL_Test_CallLogContact_Trigger_Handler_coverage()  
    {
     	Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		Call_Log_Contact__c clc_del = new Call_Log_Contact__c();
		clc_del.Call_Log__c = cl.Id;
		clc_del.Contact__c = cntct.Id;
		insert clc_del;
		update clc_del;
		delete clc_del;
    }
}