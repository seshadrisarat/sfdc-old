@isTest
private class SL_Test_CurrencyStamp
{
	static Map<String, Double> conversionRates;
	static void setup(){
		conversionRates = new Map<String, Double>();
		for (CurrencyType dcr: [        SELECT  ConversionRate, 
	                                            IsoCode 
	                                    FROM    CurrencyType
	                            ]){
	        conversionRates.put(dcr.IsoCode, dcr.ConversionRate);
	    }
	}

	static List<Deal__c> dealQuery(){
		return [SELECT Id, Capture_Local_Currency_Formula__c, Capture_Local_CurrencyISOCode__c, Capture_Local_Currency_Amount_USD__c, Capture_Local_Currency_Conversion_Rate__c, Amount__c FROM Deal__c];
	}

	@isTest
	static void testInsertFunctionality()
	{
		setup();
		List<Deal__c> deals = SL_util_TestSetup.createRecords('Deal__c', 10);
		for (Deal__c deal: deals){
			deal.Status__c = 'Won';
			deal.CurrencyIsoCode = 'EUR';
			deal.Amount__c = 100.0;
			deal.Reason__c = 'Test';
			deal.Actual_Close_Date__c = System.today();
		}
		deals[0].Status__c = 'Test';
		insert deals;
		// testing positive case
		deals = dealQuery();
		Boolean negative = true;
		for (Deal__c deal: deals){
			if (!negative){
				System.assertEquals(deal.Amount__c / conversionRates.get('EUR'), deal.Capture_Local_Currency_Amount_USD__c);
				System.assertEquals('EUR', deal.Capture_Local_CurrencyISOCode__c);
				System.assertEquals(conversionRates.get('EUR'), deal.Capture_Local_Currency_Conversion_Rate__c);
			}
			else {
				negative = false;
			}
		}
		// testing negative case
		System.assertEquals(null, deals[0].Capture_Local_Currency_Amount_USD__c);
		System.assertEquals(null, deals[0].Capture_Local_CurrencyISOCode__c);
		System.assertEquals(null, deals[0].Capture_Local_Currency_Conversion_Rate__c);
		for (Deal__c deal: deals){
			deal.Amount__c = 200;
			deal.CurrencyIsoCode = 'USD';
		}
		update deals;
		deals = dealQuery();
		negative = true;
		for (Deal__c deal: deals){
			if (!negative){
				System.assertNotEquals(200, deal.Capture_Local_Currency_Amount_USD__c);
				System.assertEquals('EUR', deal.Capture_Local_CurrencyISOCode__c);
			}
			else {
				negative = false;
			}
		}
	}

	@isTest
	static void testUpdateFunctionality()
	{
		setup();
		List<Deal__c> deals = SL_util_TestSetup.createRecords('Deal__c', 10);
		insert deals;
		for (Deal__c deal: deals){
			deal.Status__c = 'Won';
			deal.CurrencyIsoCode = 'EUR';
			deal.Amount__c = 100.0;
			deal.Reason__c = 'Test';
			deal.Actual_Close_Date__c = System.today();
		}
		deals[0].Status__c = 'Test';
		update deals;
		deals = dealQuery();
		// testing positive case
		Boolean negative = true;
		for (Deal__c deal: deals){
			if (!negative){
				System.assertEquals(deal.Amount__c / conversionRates.get('EUR'), deal.Capture_Local_Currency_Amount_USD__c);
				System.assertEquals('EUR', deal.Capture_Local_CurrencyISOCode__c);
				System.assertEquals(conversionRates.get('EUR'), deal.Capture_Local_Currency_Conversion_Rate__c);
			}
			else {
				negative = false;
			}
		}
		// testing negative case
		System.assertEquals(null, deals[0].Capture_Local_Currency_Amount_USD__c);
		System.assertEquals(null, deals[0].Capture_Local_CurrencyISOCode__c);
		System.assertEquals(null, deals[0].Capture_Local_Currency_Conversion_Rate__c);
		for (Deal__c deal: deals){
			deal.Amount__c = 200;
			deal.CurrencyIsoCode = 'USD';
		}
		update deals;
		deals = dealQuery();
		negative = true;
		for (Deal__c deal: deals){
			if (!negative){
				System.assertNotEquals(200, deal.Capture_Local_Currency_Amount_USD__c);
				System.assertEquals('EUR', deal.Capture_Local_CurrencyISOCode__c);
			}
			else {
				negative = false;
			}
		}
	}

	@isTest
	static void testTriggerFunctionality()
	{
		List<Deal__c> deals = SL_util_TestSetup.createRecords('Deal__c', 10);
		// just confirming that trigger throws no errors
		insert deals;
		update deals;
		delete deals;
		undelete deals;
	}
}