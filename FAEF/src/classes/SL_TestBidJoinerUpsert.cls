/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_TestBidJoinerUpsert {

    static testMethod void BidJoinerUpsert_Test() {
        // TO DO: implement unit test
        
        // Start of Creating test data
        
        Auction__c objAuction = new Auction__c(Name='Test-Auction-01');
		insert objAuction; 
		
        Lot__c objLot = new Lot__c(Name = 'Test Lot-01',Auction__c = objAuction.Id );
        insert objLot;
        
        Lot_Item__c objLotItem = new Lot_Item__c( Lot__c = objLot.Id);
        insert objLotItem;
        
        Bid__c objBid = new Bid__c(Lot__c = objLot.Id);
        insert objBid;
        
        Bid_Item__c objBidItem = new Bid_Item__c( Bid__c = objBid.Id,Lot_Item__c = objLotItem.Id);
        insert objBidItem; 
        
        // End of Creating test data
        
        ApexPages.StandardController controller = new ApexPages.StandardController(objLot);
        SL_BidJoinerUpsertPageController objBidjoiner = new SL_BidJoinerUpsertPageController(controller);
        
        system.assert( objBidjoiner.lstLotWrapper.size() == 1);
        
        objBidjoiner.lstLotWrapper[0].bidItem.Bid_Item_Unit_Price__c = 10.0;
        objBidjoiner.upsertBidAndBidItemsassociatedwithLot();
        
        Bid_Item__c objBidItem1 = [ select Bid_Item_Unit_Price__c 
        							from Bid_Item__c 
        							where Id =: objBidItem.Id
        							];
        
        							
        system.assert( objBidItem1.Bid_Item_Unit_Price__c == 10.0);
    }
}