@isTest
private class AccountBoatCategoryUpdateJobTest {

    private static Id dealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Dealer'].Id;
    private static Id subDealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Sub_Dealers'].Id;

    static testMethod void test() {
        AccountBoatCategoryUpdateJob.isBulkAccountUpdate = true; 
        Test.startTest();
        
        Account dealer = new Account(Name = 'SeaRayDealer', Dealer_Number__c = '999.00', RecordTypeId = dealerRecordTypeId, ShippingCity = 'Test', ShippingState = 'TN');
        
        insert dealer;
        system.debug('****************************** Dealer id: ' + dealer.Id);
        
        Dealer_Brand__c seaRayDealerBrand = new Dealer_Brand__c(Dealer__c = dealer.Id, Brand__c = 'SR', Status__c = 'Active', Name = 'SeaRay ' + dealer.Id);
        
        insert seaRayDealerBrand;
        system.debug('****************************** Dealer Brand id: ' + seaRayDealerBrand.Id);
        
        Territory__c seaRayDealerBrandTerritory = new Territory__c(Dealer__c = dealer.Id, Dealer_Brand__c = seaRayDealerBrand.Id, Boat_Class__c = 'Sport Yacht', Zipcode_Postal_Code__c = '37918');
        
        insert seaRayDealerBrandTerritory;
        system.debug('****************************** Dealer Brand Territory id: ' + seaRayDealerBrandTerritory.Id);
        
        Id batchJobId = Database.executeBatch(new AccountBoatCategoryUpdateJob(), 2);
        
        Account updatedDealer = [Select a.Id, a.Sea_Ray_Boat_Categories__c From Account a Where Id = :dealer.Id];
        system.debug('****************************** Updated dealer Sea Ray boat category: ' + updatedDealer.Sea_Ray_Boat_Categories__c);
        
        Test.stopTest();
        
    }

}