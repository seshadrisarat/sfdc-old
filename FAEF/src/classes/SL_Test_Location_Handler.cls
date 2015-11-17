@isTest 
public with sharing class SL_Test_Location_Handler 
{
	 //Test method for class SL_Location_Handler
    static testmethod void SL_Test_Location_Handler()     
    {
    	List<Equipment__c> lstEquipment = new List<Equipment__c>();
    	RecordType objRecordType = [Select Id From RecordType where SobjectType='Account' LIMIT 1];
    	RecordType objRecordType1 = [Select Id From RecordType where SobjectType='Opportunity' LIMIT 1];
    	
    	Account objAccount = new Account(Name = 'Test', RecordTypeId = objRecordType.Id);
    	insert objAccount;
    	System.assertNotEquals(objAccount.Id, null);
        
        Location__c objLocation1 = new Location__c(Name = 'Test', Tax_Rate__c=2.5, Location_Number__c = '1', Account__c = objAccount.Id, 
        										   Street__c='Test Street', City__c = 'Test Cityhriwqehkfqwghiufrqwhfkwqhfoiuqwfqwkfqwoigrfiqwugrfbwqrgfiuqwgiurwqgqfdasbfdiasgfdisgafsaigfiasugfigqarfqwigrqwigrwqfiqwgofwqgfiqwfigwqfrqwgi', State__c ='Test State', Zip__c = '6812416');
    	insert objLocation1;
    	System.assertNotEquals(objLocation1.Id, null);
        
        Location__c objLocation2 = new Location__c(Name = 'Test', Tax_Rate__c=3.0, Location_Number__c = '2', Account__c = objAccount.Id);
    	insert objLocation2;
    	System.assertNotEquals(objLocation2.Id, null);
    	
    	Location__c objLocation3 = new Location__c(Name = 'Test', Tax_Rate__c=3.5, Location_Number__c = '3', Account__c = objAccount.Id, 
        										   Street__c='Test Street', City__c = 'Test City', State__c ='Test State', Zip__c = '6812416');
    	insert objLocation3;
    	System.assertNotEquals(objLocation3.Id, null);
        
        Location__c objLocation4 = new Location__c(Name = 'Test', Tax_Rate__c=4.0, Location_Number__c = '4', Account__c = objAccount.Id);
    	insert objLocation4;
    	System.assertNotEquals(objLocation4.Id, null);
    	
    	Opportunity objOpportunity = new Opportunity(AccountId = objAccount.Id, RecordTypeId = objRecordType1.Id, Name = 'TestOpp', CloseDate = Date.today() + 10 , StageName = 'Lost');
    	insert objOpportunity;
    	System.assertNotEquals(objOpportunity.Id, null);
    	
    	Letter_of_Intent__c sObjLOI = new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id);
    	insert sObjLOI;
    	System.assertNotEquals(sObjLOI.Id, null);
    	
    	Schedule__c sObjSchedule1 = new Schedule__c(Letter_of_Intent__c = sObjLOI.Id,Stage__c='Submit to Credit');
    	insert sObjSchedule1;
    	System.assertNotEquals(sObjSchedule1.Id, null);
    	
    	Schedule__c sObjSchedule2 = new Schedule__c(Letter_of_Intent__c = sObjLOI.Id,Stage__c='Submit to Credit');
    	insert sObjSchedule2;
    	System.assertNotEquals(sObjSchedule2.Id, null);
    	
        
    	Equipment__c sObjEquipment1 = new Equipment__c();
    	sObjEquipment1.Serial_Numbers__c = '1,2,3,4,5,6,7';
    	sObjEquipment1.Tax_Rate_Actual__c = 10;
        sObjEquipment1.Quantity__c= 7;
    	sObjEquipment1.Schedule__c = sObjSchedule1.Id;
        sObjEquipment1.Location__c = objLocation1.Id;
    	lstEquipment.add(sObjEquipment1);
    	
    	Equipment__c sObjEquipment2 = new Equipment__c();
    	sObjEquipment2.Serial_Numbers__c = '1,2,3,4';
    	sObjEquipment2.Tax_Rate_Actual__c = 20;
        sObjEquipment2.Quantity__c= 4;
    	sObjEquipment2.Schedule__c = sObjSchedule2.Id;
        sObjEquipment2.Location__c = objLocation2.Id;
    	lstEquipment.add(sObjEquipment2);
    	
    	Equipment__c sObjEquipment3 = new Equipment__c();
    	sObjEquipment3.Serial_Numbers__c = '1,2';
        sObjEquipment3.Quantity__c= 2;
    	sObjEquipment3.Tax_Rate_Actual__c = 30;
    	sObjEquipment3.Schedule__c = sObjSchedule2.Id;
    	sObjEquipment3.Location__c = objLocation3.Id;
    	lstEquipment.add(sObjEquipment3);
    	
    	Equipment__c sObjEquipment4 = new Equipment__c();
    	sObjEquipment4.Serial_Numbers__c = '';
        sObjEquipment4.Quantity__c= 1;
    	sObjEquipment4.Schedule__c = sObjSchedule2.Id;
    	sObjEquipment4.Location__c = objLocation4.Id;
    	sObjEquipment4.Tax_Rate_Actual__c = 40;
    	lstEquipment.add(sObjEquipment4);
    	
        Test.startTest();
    	insert lstEquipment;
    	System.assertEquals([SELECT Id FROM Equipment_Item__c WHERE Equipment__c = :sObjEquipment1.Id].size(),7);
    	System.assertEquals([SELECT Id FROM Equipment_Item__c WHERE Equipment__c = :sObjEquipment2.Id].size(),4);
    	System.assertEquals([SELECT Id FROM Equipment_Item__c WHERE Equipment__c = :sObjEquipment3.Id].size(),2);
    	System.assertEquals([SELECT Id FROM Equipment_Item__c WHERE Equipment__c = :sObjEquipment4.Id].size(),1);
        
        // testing insert of equipment tax rates.
    	System.assertEquals([SELECT Id,Tax_Rate_Actual__c FROM Equipment__c WHERE Id = :sObjEquipment1.Id].Tax_Rate_Actual__c,2.5);
        System.assertEquals([SELECT Id,Tax_Rate_Actual__c FROM Equipment__c WHERE Id = :sObjEquipment2.Id].Tax_Rate_Actual__c,3.0);

        sObjSchedule2.Stage__c='Due to Fund';
        update sObjSchedule2;
        objLocation1.Tax_Rate__c = 5.5;
        update objLocation1;
    	objLocation2.Tax_Rate__c = 3.5;
        update objLocation2;
        objLocation3.Tax_Rate__c = 4.5;
        update objLocation3;
        objLocation4.Tax_Rate__c = 6.5;
        update objLocation4;
        System.assertEquals([SELECT Id,Tax_Rate_Actual__c FROM Equipment__c WHERE Id = :sObjEquipment2.Id].Tax_Rate_Actual__c,3.0);
    }
}