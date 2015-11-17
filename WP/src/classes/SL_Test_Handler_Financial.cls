/**
 * This class contains unit tests for validating the behavior off trigger on Financial
 * author Sergey Karnyushin
 * date 17/10/2012
 * see https://silverline.jira.com/browse/WP-9
 * Test for Trigger on Financial after change data operations
 */

@isTest
private class SL_Test_Handler_Financial {

    static testMethod void test_Handler_Financial() {

		Test.startTest();
		
		Account anyCompany = new Account(
			Name = 'Test Test',
			CurrencyIsoCode = 'USD'
		);
		insert anyCompany;
		
		List<Financial__c> financials = new List<Financial__c>();
		Financial__c f = new Financial__c(
			Company__c = anyCompany.ID,
			EBITDA__c = 10,
			Enterprise_Value__c = 20,
			Net_Income__c = 30,
			Period_Ended__c = Date.valueOf('2012-10-12'),
			Period_Type__c = 'LTM'
		);
		financials.add(f);
		f = new Financial__c(
			Company__c = anyCompany.ID,
			EBITDA__c = 40,
			Enterprise_Value__c = 50,
			Net_Income__c = 60,
			Period_Ended__c = Date.valueOf('2012-05-10'),
			Period_Type__c = 'LTM'
		);
		financials.add(f);
		
		insert financials;
		
		anyCompany = [SELECT ID,EBITDA__c,Enterprise_Value__c,Net_Income__c FROM Account WHERE ID=:anyCompany.Id];
		//System.assert(anyCompany.EBITDA__c == 10);
		//System.assert(anyCompany.Enterprise_Value__c == 20);
		//System.assert(anyCompany.Net_Income__c == 30);
		
		financials[0].EBITDA__c = 100;
		financials[1].Enterprise_Value__c = 200;
		
		update financials;
		
		anyCompany = [SELECT ID,EBITDA__c,Enterprise_Value__c,Net_Income__c FROM Account WHERE ID=:anyCompany.Id];
		//System.assert(anyCompany.EBITDA__c == 100);
		//System.assert(anyCompany.Enterprise_Value__c == 20);
		//System.assert(anyCompany.Net_Income__c == 30);
		
		delete financials;
		
		anyCompany = [SELECT ID,EBITDA__c,Enterprise_Value__c,Net_Income__c FROM Account WHERE ID=:anyCompany.Id];
		//System.assert(anyCompany.EBITDA__c == null);
		//System.assert(anyCompany.Enterprise_Value__c == null);
		//System.assert(anyCompany.Net_Income__c == null);
		
		undelete financials;
		
		anyCompany = [SELECT ID,EBITDA__c,Enterprise_Value__c,Net_Income__c FROM Account WHERE ID=:anyCompany.Id];
		//System.assert(anyCompany.EBITDA__c == 100);
		//System.assert(anyCompany.Enterprise_Value__c == 20);
		//System.assert(anyCompany.Net_Income__c == 30);
		
		delete financials;
		delete anyCompany;
		
		Test.stopTest();

    }
}