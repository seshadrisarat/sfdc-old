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
private class SL_Test_BidHandler {

    static testMethod void  createProceedAndUpdateEquipments() {
    	// Model is as below :
/***********
    			   Bid1   													
                    ||
           BidItem2    BidItem3 
             |              |
          LoTItem4       LotItem5
             |              |
        Equipment6    Equipment7
             |              | 
         Schedule-8     Schedule-9
             |              |
          Proceed1       Proceed2	===> Will create
          
=========================================================================		  
		  
				   Bid2   
                    ||
           BidItem4    BidItem5
             |              |
          LoTItem6       LotItem7
             |              |
        Equipment8    Equipment9
             |              | 
  			  Schedule-10     
				   |              
			   Proceed3 			===> Will create
    	
********/
    	Account objAcc = new Account(Name = 'Test Acc - 1');
        insert objAcc ;
        system.assert(objAcc.Id != NULL);
        
        Letter_of_Intent__c objLetterofIntent = new Letter_of_Intent__c(Facility_Rating__c = '5', Account__c = objAcc.Id);
        insert objLetterofIntent ;
        system.assert(objLetterofIntent.Id != NULL);
        
    	
        List<Schedule__c> lstScheduleToInsert = new List<Schedule__c>{new Schedule__c(Letter_of_Intent__c = objLetterofIntent.Id, Project_Manager__c = Userinfo.getUserId(), Name = 'Schedule-8', Count_for_A_A__c = 'Yes'),
        															  new Schedule__c(Letter_of_Intent__c = objLetterofIntent.Id, Project_Manager__c = Userinfo.getUserId(), Name = 'Schedule-9', Count_for_A_A__c = 'Yes'),
        															  new Schedule__c(Letter_of_Intent__c = objLetterofIntent.Id, Project_Manager__c = Userinfo.getUserId(), Name = 'Schedule-10', Count_for_A_A__c = 'Yes')};
        insert lstScheduleToInsert;
        system.assert(lstScheduleToInsert[0].Id != NULL);
		system.assert(lstScheduleToInsert[1].Id != NULL);
		system.assert(lstScheduleToInsert[2].Id != NULL);
		
		List<Equipment__c> lstEqpToInsert = new List<Equipment__c> {new Equipment__c(Name = 'Equipment6', Quantity__c = 1, Schedule__c = lstScheduleToInsert[0].Id),
																	new Equipment__c(Name = 'Equipment7', Quantity__c = 2, Schedule__c = lstScheduleToInsert[1].Id),
																	new Equipment__c(Name = 'Equipment8', Quantity__c = 3, Schedule__c = lstScheduleToInsert[2].Id),
																	new Equipment__c(Name = 'Equipment9', Quantity__c = 4, Schedule__c = lstScheduleToInsert[2].Id)};
		insert lstEqpToInsert;
		system.assert(lstEqpToInsert[3].Id != NULL);
		
		Test.startTest();
		
		// Insert Auctions 
		Auction__c objAuction1 = new Auction__c(Name = 'Test Auction - 01', Status__c = 'Open');
		insert objAuction1;
		
		Lot__c objLot1 = new Lot__c(Auction__c = objAuction1.Id, Name = 'Test Lot-1');
		insert objLot1;
		
		List<Lot_Item__c> lstLotItemToInsert = new List<Lot_Item__c>{new Lot_Item__c(Lot__c = objLot1.Id, Equipment__c = lstEqpToInsert[0].Id, Quantity__c = 1),
																	new Lot_Item__c(Lot__c = objLot1.Id, Equipment__c = lstEqpToInsert[1].Id, Quantity__c = 1),
																	new Lot_Item__c(Lot__c = objLot1.Id, Equipment__c = lstEqpToInsert[2].Id, Quantity__c = 1),
																	new Lot_Item__c(Lot__c = objLot1.Id, Equipment__c = lstEqpToInsert[3].Id, Quantity__c = 1)};
		
		insert lstLotItemToInsert;
		system.assert(lstLotItemToInsert[3].Id != NULL);
		
		
		List<Bid__c> lstBidToInsertAndUpdate = new List<Bid__c>{new Bid__c(Lot__c = objLot1.Id, Bidder_Account__c = objAcc.Id, Status__c = 'Submitted'),
													   		    new Bid__c(Lot__c = objLot1.Id, Bidder_Account__c = objAcc.Id, Status__c = 'Submitted')};
		insert lstBidToInsertAndUpdate ;
		system.assert(lstBidToInsertAndUpdate [0].Id != NULL);
		
		
		List<Bid_Item__c> lstBidItemsToInsert = new List<Bid_Item__c>{new Bid_Item__c(Bid__c = lstBidToInsertAndUpdate [0].Id, Lot_Item__c = lstLotItemToInsert[0].Id),
																	  new Bid_Item__c(Bid__c = lstBidToInsertAndUpdate [0].Id, Lot_Item__c = lstLotItemToInsert[1].Id),
																	  new Bid_Item__c(Bid__c = lstBidToInsertAndUpdate [1].Id, Lot_Item__c = lstLotItemToInsert[2].Id),
																	  new Bid_Item__c(Bid__c = lstBidToInsertAndUpdate [1].Id, Lot_Item__c = lstLotItemToInsert[3].Id)};
		insert lstBidItemsToInsert;
		system.assert(lstBidItemsToInsert[3].Id != NULL);
		
		// Updating the Bid records status to WON
		lstBidToInsertAndUpdate [0].Status__c = lstBidToInsertAndUpdate [1].Status__c = 'Won';
		update lstBidToInsertAndUpdate ;
		
		// There are 3 proceed records will get create 
		List<Proceeds__c> lstProceedsCreated = new List<Proceeds__c>();
		lstProceedsCreated.addAll([Select Id, Type__c From Proceeds__c WHERE Schedule__c IN : lstScheduleToInsert]);
		system.assertEquals(lstProceedsCreated.size(), 3);
		
		Proceeds__c objProceed = [Select Id, Schedule__c, Bid__c from Proceeds__c where Schedule__c =: lstScheduleToInsert[2].Id limit 1];
		
		system.assertEquals(objProceed.Bid__c, lstBidToInsertAndUpdate[1].Id);
		
		// Checking that the Equipment8 and Equipment9 has same ProceedId as thery have same schedule only
		for(Equipment__c objEqup : [Select Id, Proceed_For_Won_Auction__c, Schedule__c from Equipment__c where Schedule__c =: lstScheduleToInsert[2].Id])
		{
			system.assertEquals(objEqup.Proceed_For_Won_Auction__c, objProceed.Id);
		}
		
		Test.stopTest();
    }
}