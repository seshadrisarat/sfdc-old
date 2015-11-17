@isTest 
public with sharing class SL_Test_Equipment_Handler 
{
	 //Test method for class SL_Equipment_Handler
    static testmethod void test_SL_Equipment_Handler()     
    {
    	List<Equipment__c> lstEquipment = new List<Equipment__c>();
    	RecordType objRecordType = [Select Id From RecordType where SobjectType='Account' LIMIT 1];
    	RecordType objRecordType1 = [Select Id From RecordType where SobjectType='Opportunity' LIMIT 1];
    	
    	Account objAccount = new Account(Name = 'Test', RecordTypeId = objRecordType.Id);
    	insert objAccount;
    	System.assertNotEquals(objAccount.Id, null);
    	
    	List<Location__c> lstLocationToInsert = new List<Location__c>{
    																 	new Location__c(Account__c = objAccount.Id, Location_Number__c = '123', City__c = 'NY'),
    																 	new Location__c(Account__c = objAccount.Id, Location_Number__c = '200', City__c = 'NY'),
    																 	new Location__c(Account__c = objAccount.Id, Location_Number__c = '300', City__c = 'NY'),
    																 	new Location__c(Account__c = objAccount.Id, Location_Number__c = '400', City__c = 'NY')
    																 };
   		insert lstLocationToInsert;
    	
    	Opportunity objOpportunity = new Opportunity(AccountId = objAccount.Id, RecordTypeId = objRecordType1.Id, Name = 'TestOpp', CloseDate = Date.today() + 10 , StageName = 'Lost');
    	insert objOpportunity;
    	System.assertNotEquals(objOpportunity.Id, null);
    	
    	Letter_of_Intent__c sObjLOI = new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id, Account__c = objAccount.Id);
    	insert sObjLOI;
    	System.assertNotEquals(sObjLOI.Id, null);
    	
    	Schedule__c sObjSchedule = new Schedule__c(Letter_of_Intent__c = sObjLOI.Id);
    	insert sObjSchedule;
    	System.assertNotEquals(sObjSchedule.Id, null);
    	
    	Schedule__c sObjSchedule2 = new Schedule__c(Letter_of_Intent__c = sObjLOI.Id);
    	insert sObjSchedule2;
    	System.assertNotEquals(sObjSchedule2.Id, null);
    	
    	Equipment__c sObjEquipment = new Equipment__c();
    	sObjEquipment.Serial_Numbers__c = '1,2,3,4,5,6,7';
    	sObjEquipment.Schedule__c = sObjSchedule.Id;
        sObjEquipment.Quantity__c = 7;
    	sObjEquipment.Location_Upload__c = 123;
    	lstEquipment.add(sObjEquipment);
    	
    	Equipment__c sObjEquipment1 = new Equipment__c();
    	sObjEquipment1.Serial_Numbers__c = '1,2,3,4';
        sObjEquipment1.Quantity__c = 4;
    	sObjEquipment1.Schedule__c = sObjSchedule.Id;
    	sObjEquipment1.Location_Upload__c = 200;
    	lstEquipment.add(sObjEquipment1);
    	
    	Equipment__c sObjEquipment2 = new Equipment__c();
    	sObjEquipment2.Serial_Numbers__c = '1,2';
        sObjEquipment2.Quantity__c = 2;
    	sObjEquipment2.Schedule__c = sObjSchedule2.Id;
    	sObjEquipment2.Location__c = lstLocationToInsert[2].Id;
    	lstEquipment.add(sObjEquipment2);
    	
    	Equipment__c sObjEquipment3 = new Equipment__c();
    	sObjEquipment3.Serial_Numbers__c = '';
        sObjEquipment3.Quantity__c = 1;
    	sObjEquipment3.Schedule__c = sObjSchedule2.Id;
    	sObjEquipment3.Location__c = lstLocationToInsert[3].id;
    	lstEquipment.add(sObjEquipment3);
    	
    	insert lstEquipment;
    	System.assertEquals([SELECT Id FROM Equipment_Item__c WHERE Equipment__c = :sObjEquipment.Id].size(),7);
    	System.assertEquals([SELECT Id FROM Equipment_Item__c WHERE Equipment__c = :sObjEquipment1.Id].size(),4);
    	System.assertEquals([SELECT Id FROM Equipment_Item__c WHERE Equipment__c = :sObjEquipment2.Id].size(),2);
    	System.assertEquals([SELECT Id FROM Equipment_Item__c WHERE Equipment__c = :sObjEquipment3.Id].size(),1);
    	
    	lstEquipment[0].Serial_Numbers__c = '1,2\n,3,4,5,6';
    	lstEquipment[1].Serial_Numbers__c = '';
    	lstEquipment[2].Serial_Numbers__c = '1,2,6\r,5';
    	lstEquipment[3].Serial_Numbers__c = '1,2\n,3,4\t,5,6';
    	update lstEquipment;
    }
}