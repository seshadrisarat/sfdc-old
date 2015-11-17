@isTest
private class TerritoryTriggerTest {
	
	private static Id dealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Dealer'].Id;
    private static Id subDealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Sub_Dealers'].Id;

    static testMethod void test() {
        AccountBoatCategoryUpdateJob.isBulkAccountUpdate = true; 
        Test.startTest();
        
        Account dealer = new Account(Name = 'SeaRayDealer', Dealer_Number__c = '999.00', RecordTypeId = dealerRecordTypeId, ShippingCity = 'Test', ShippingState = 'TN');
        insert dealer;
        
        Dealer_Brand__c seaRayDealerBrand = new Dealer_Brand__c(Dealer__c = dealer.Id, Brand__c = 'SR', Status__c = 'Active', Name = 'SeaRay ' + dealer.Id);
        insert seaRayDealerBrand;
        
        Territory__c seaRayDealerBrandTerritory = new Territory__c(Dealer__c = dealer.Id, Dealer_Brand__c = seaRayDealerBrand.Id, Boat_Class__c = 'Sport Yacht', Zipcode_Postal_Code__c = '37918');
        insert seaRayDealerBrandTerritory;
        
        //Update without class (category) change
        seaRayDealerBrandTerritory.Boat_Class__c = 'Sport Yacht';
		update seaRayDealerBrandTerritory;
        
        //Update with class change
		seaRayDealerBrandTerritory.Boat_Class__c = 'Sport Cruiser';
		update seaRayDealerBrandTerritory;
		
		//Delete 
		delete seaRayDealerBrandTerritory;
		
		//Undelete
		undelete seaRayDealerBrandTerritory;
        
        Test.stopTest();
        
    }

}