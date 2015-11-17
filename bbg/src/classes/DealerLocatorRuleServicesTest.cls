@isTest
public class DealerLocatorRuleServicesTest {
	
	
	
	public static testMethod void testGetDealerLocatorRule_NoneFound(){
		
		String countryCode = 'USA';
		String brandCode = 'BL';
		String domesticOrInternational = 'Domestic';
		String boatWebsite = 'http://www.myboats.com';
		
		Test.startTest();
			Dealer_Locator_Rule__c dealerLocatorRule = DealerLocatorRuleServices.getDealerLocatorRule(countryCode, brandCode, domesticOrInternational, boatWebsite);
		Test.stopTest();
		
		System.assertEquals(null, dealerLocatorRule, 'We expect to get back null when no dealer locator rule is found');
		
	}
	
	public static testMethod void testGetDealerLocatorRule_MoreThanOneFound(){
		
		String countryCode = 'USA';
		String countryCode2 = 'France;USA';
		String brandCode = 'BL';
		String domesticOrInternational = 'Domestic';
		String boatWebsite = 'http://www.myboats.com';
		
		Dealer_Locator_Rule__c testDealerLocatorRule = TestUtilities.createDealerLocatorRule(brandCode, countryCode, domesticOrInternational, boatWebsite, false);
		Dealer_Locator_Rule__c testDealerLocatorRule2 = TestUtilities.createDealerLocatorRule(brandCode, countryCode2, domesticOrInternational, boatWebsite, false);
		
		insert new List<Dealer_Locator_Rule__c>{testDealerLocatorRule, testDealerLocatorRule2};
		
		Test.startTest();
			Dealer_Locator_Rule__c dealerLocatorRule = DealerLocatorRuleServices.getDealerLocatorRule(countryCode, brandCode, domesticOrInternational, boatWebsite);
		Test.stopTest();
		
		System.assertEquals(null, dealerLocatorRule, 'We expect to get back null when more than one dealer locator rule is found');
		
	}
	
	public static testMethod void testGetDealerLocatorRule_OneFound(){
		
		String countryCode = 'USA';
		String brandCode = 'BL';
		String domesticOrInternational = 'Domestic';
		String boatWebsite = 'http://www.myboats.com';
		
		Dealer_Locator_Rule__c testDealerLocatorRule = TestUtilities.createDealerLocatorRule(brandCode, countryCode, domesticOrInternational, boatWebsite, false);
		Dealer_Locator_Rule__c testDealerLocatorRule2 = TestUtilities.createDealerLocatorRule('SR', countryCode, domesticOrInternational, boatWebsite, false);
		Dealer_Locator_Rule__c testDealerLocatorRule3 = TestUtilities.createDealerLocatorRule(brandCode, 'Mexico', domesticOrInternational, boatWebsite, false);
		
		insert new List<Dealer_Locator_Rule__c>{testDealerLocatorRule, testDealerLocatorRule2, testDealerLocatorRule3};
		
		Test.startTest();
			Dealer_Locator_Rule__c dealerLocatorRule = DealerLocatorRuleServices.getDealerLocatorRule(countryCode, brandCode, domesticOrInternational, boatWebsite);
		Test.stopTest();
		
		System.assertNotEquals(null, dealerLocatorRule, 'We expect to get back one dealer locator rule');
		System.assertEquals(countryCode, dealerLocatorRule.Country_Code__c, 'We expect the country code on the dealer locator rule to match the api call');
		System.assertEquals(brandCode, dealerLocatorRule.Brand_Code__c, 'We expect the country code on the dealer locator rule to match the api call');
		System.assertEquals(domesticOrInternational, dealerLocatorRule.Domestic_or_International__c, 'We expect the country code on the dealer locator rule to match the api call');
		System.assertEquals(boatWebsite, dealerLocatorRule.Website__c, 'We expect the country code on the dealer locator rule to match the api call');
			
	}
	
	public static testMethod void testGetDealerLocatorRule_AllOtherCountries(){
		
		String countryCode = 'SomeCountryNotDefined';
		String brandCode = 'BL';
		String domesticOrInternational = 'Domestic';
		String boatWebsite = 'http://www.myboats.com';
		
		Dealer_Locator_Rule__c testDealerLocatorRule = TestUtilities.createDealerLocatorRule(brandCode, 'France', domesticOrInternational, boatWebsite, false);
		Dealer_Locator_Rule__c testDealerLocatorRule2 = TestUtilities.createDealerLocatorRule('SR', 'United States', domesticOrInternational, boatWebsite, false);
		Dealer_Locator_Rule__c testDealerLocatorRule3 = TestUtilities.createDealerLocatorRule(brandCode, 'Mexico', domesticOrInternational, boatWebsite, false);
		Dealer_Locator_Rule__c testDealerLocatorRule4 = TestUtilities.createDealerLocatorRule(brandCode, null, domesticOrInternational, boatWebsite, false);
		
		insert new List<Dealer_Locator_Rule__c>{testDealerLocatorRule, testDealerLocatorRule2, testDealerLocatorRule3, testDealerLocatorRule4};
		
		Test.startTest();
			Dealer_Locator_Rule__c dealerLocatorRule = DealerLocatorRuleServices.getDealerLocatorRule(countryCode, brandCode, domesticOrInternational, boatWebsite);
		Test.stopTest();
		
		System.assertNotEquals(null, dealerLocatorRule, 'We expect to get back one dealer locator rule');
		System.assertEquals(testDealerLocatorRule4.Id, dealerLocatorRule.Id, 'We expect to get back one dealer locator rule');
		System.assertEquals(null, dealerLocatorRule.Country_Code__c, 'We expect the country code on the dealer locator rule to match the api call');
		System.assertEquals(brandCode, dealerLocatorRule.Brand_Code__c, 'We expect the country code on the dealer locator rule to match the api call');
		System.assertEquals(domesticOrInternational, dealerLocatorRule.Domestic_or_International__c, 'We expect the country code on the dealer locator rule to match the api call');
		System.assertEquals(boatWebsite, dealerLocatorRule.Website__c, 'We expect the country code on the dealer locator rule to match the api call');
			
	}

}