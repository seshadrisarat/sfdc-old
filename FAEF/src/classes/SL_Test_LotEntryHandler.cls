/**
* \arg ClassName  : SL_Test_LotEntryHandler
* \arg JIRATicket : FAEF -36
* \arg CreatedOn  : 06/10/2014
* \arg CreatedBy  : Dhanalakshmi
* \arg ModifiedBy : Dhanalakshmi
* \arg Description: Test class for SL_LotEntryHandler
*/
@isTest
private with sharing class SL_Test_LotEntryHandler 
{
	static testMethod void Test_LotEntryHandler() 
	{
		Profile objProfile = [SELECT Name,Id FROM Profile Where Name='Chatter External User'];
		
		User objUser1 = new User(Lastname = 'User-001', Email = 'user001@gmail.com', Username = 'user001@gmail.com',ProfileId = objProfile.Id,  
        						 					 Alias = 'user01', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert objUser1;
        
		Auction__c objAuction = new Auction__c(Name='Test-Auction-01');
		insert objAuction;
		
		Lot__c objLot01 = new Lot__c(Name='Test-Lot-01',Auction__c=objAuction.Id);
		insert objLot01;
		
		Lot__c objLot02 = new Lot__c(Name='Test-Lot-02',Auction__c=objAuction.Id);
		insert objLot02;
		
		Letter_of_Intent__c objLOI = new Letter_of_Intent__c(Facility_Rating__c='1');
		insert objLOI;
		
		Schedule__c objSchedule = new Schedule__c(Name='Test-Schedule-01',Project_Manager__c=objUser1.Id,Count_for_A_A__c='Yes',Letter_of_Intent__c=objLOI.Id);
		insert objSchedule;
		
		Equipment__c objEquipment01 = new Equipment__c(Name='Test-Eq-01',Quantity__c=2,Quantity_Return__c=5,Schedule__c=objSchedule.Id);
		insert objEquipment01;
		
		Equipment__c objEquipment02 = new Equipment__c(Name='Test-Eq-02',Quantity__c=2,Quantity_Return__c=5,Schedule__c=objSchedule.Id);
		insert objEquipment02;
		
		Equipment__c objEquipment03 = new Equipment__c(Name='Test-Eq-03',Quantity__c=2,Quantity_Return__c=5,Schedule__c=objSchedule.Id);
		insert objEquipment03;
		
		Lot_Item__c objLotItem = new Lot_Item__c(Lot__c=objLot02.Id,Equipment__c=objEquipment01.Id,Quantity__c=2);
		insert objLotItem;
		
		
		ApexPages.StandardController objStandardController = new ApexPages.StandardController(objLot01);
		
		SL_LotEntryHandler objLotEntry = new SL_LotEntryHandler(objStandardController);
		
		
		//For inserting new Lot
		objLotEntry.selectedRecordIds=objEquipment01.Id+'~';
		
		objLotEntry.unselectedRecordIds=objEquipment02.Id+'~,'+objEquipment03.Id+'~';
		
		objLotEntry.quantities=objEquipment01.Id+'~____2';
		
		objLotEntry.createLotAndLotItemRecords();
		
		List<Lot_Item__c> lstLotItem = [Select Id From Lot_Item__c Where Lot__c=:objLot01.Id];
		system.assertEquals(lstLotItem.size(), 1);
		
		//For editing a Lot
		
		objLotEntry.selectedRecordIds=objEquipment01.Id+'~'+lstLotItem[0].Id+'=>1';
		
		objLotEntry.unselectedRecordIds=objEquipment02.Id+'~,'+objEquipment03.Id+'~';
		
		objLotEntry.quantities=objEquipment01.Id+'~'+lstLotItem[0].Id+'=>1____2';
		
		objLotEntry.createLotAndLotItemRecords();
		
		objLotEntry.cancel();
	}
}