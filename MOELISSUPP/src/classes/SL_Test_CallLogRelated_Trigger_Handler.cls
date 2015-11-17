/**
 * \author Vika Osmak 
 * \date 06/24/11
 * \see http://silverline.jira.com/browse/MC-2
 * \brief Test Class for trigger SL_CallLogRelated on Call_Log_related__c
 */
@isTest
private class SL_Test_CallLogRelated_Trigger_Handler 
{
	static testMethod void SL_Test_CallLogRelated_Trigger_Handler_coverage()  
    {
     	Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		Call_Log_related__c clc_del = new Call_Log_related__c();
		clc_del.Call_Log__c = cl.Id;
		clc_del.Account__c = acc.Id;
		insert clc_del;
		update clc_del; 
		delete clc_del;
    }
}