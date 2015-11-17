/****************************************************************************************
Name            : psaMiscAdjustment_Test
Author          : Julia Kolesnik
Created Date    : January 20, 2014
Description     : Test class for psaMiscAdjustment.trigger and psaMiscAdjustmentHandler.cls
******************************************************************************************/
@isTest(SeeAllData=true)
private class psaMiscAdjustment_Test {

    static testMethod void test_Pre_Bill() {
    	pse__Proj__c proj = new pse__Proj__c();
		proj.Name = 'Test';
		proj.JIRA_Project_Name__c = 'TESTaaabcd';
		proj.pse__Is_Active__c = true;
		insert proj;
    	
    	map<string,Id> mapRecordTypeNames2Ids = new map<string,Id>();
		for (RecordType item:[Select Id, DeveloperName FROM RecordType WHERE sObjectType='pse__Miscellaneous_Adjustment__c'])
		{
			mapRecordTypeNames2Ids.put(item.DeveloperName, item.id);
		}
        pse__Miscellaneous_Adjustment__c maPreBill = new pse__Miscellaneous_Adjustment__c();
        maPreBill.RecordTypeId = mapRecordTypeNames2Ids.get('Pre_Bill');
        maPreBill.Name = 'Pre Bill';
        maPreBill.pse__Amount__c = 100;
        maPreBill.pse__Transaction_Category__c = 'Revenue';
        maPreBill.pse__Effective_Date__c = date.today();
        maPreBill.pse__Project__c = proj.Id;
        
        Test.startTest();
        insert maPreBill;
        
        for (pse__Miscellaneous_Adjustment__c item:[Select Id, Name, pse__Amount__c, RecordTypeId FROM pse__Miscellaneous_Adjustment__c
        								WHERE Name='Pre Bill'])
        {
        	if (item.RecordTypeId==mapRecordTypeNames2Ids.get('Pre_Bill')) {
        		system.assertEquals(item.pse__Amount__c, 100);
        	} else {
        		system.assertEquals(item.RecordTypeId, mapRecordTypeNames2Ids.get('Pre_Bill_Adjustment'));
        		system.assertEquals(item.pse__Amount__c, -100);
        	}
        }
        Test.stopTest();
    }
    
    static testMethod void test_Pre_Retainer() {
    	pse__Proj__c proj = new pse__Proj__c();
		proj.Name = 'TestRetainer';
		proj.JIRA_Project_Name__c = 'TESTRetaineraaabcd';
		proj.pse__Is_Active__c = true;
		insert proj;
    	
    	map<string,Id> mapRecordTypeNames2Ids = new map<string,Id>();
		for (RecordType item:[Select Id, DeveloperName FROM RecordType WHERE sObjectType='pse__Miscellaneous_Adjustment__c'])
		{
			mapRecordTypeNames2Ids.put(item.DeveloperName, item.id);
		}
        pse__Miscellaneous_Adjustment__c maPreBill = new pse__Miscellaneous_Adjustment__c();
        maPreBill.RecordTypeId = mapRecordTypeNames2Ids.get('Retainer');
        maPreBill.Name = 'Retaineraaabcd';
        maPreBill.pse__Amount__c = 200;
        maPreBill.pse__Transaction_Category__c = 'Revenue';
        maPreBill.pse__Effective_Date__c = date.today();
        maPreBill.pse__Project__c = proj.Id;
        
        Test.startTest();
        insert maPreBill;
        
        for (pse__Miscellaneous_Adjustment__c item:[Select Id, Name, pse__Amount__c, RecordTypeId FROM pse__Miscellaneous_Adjustment__c
        								WHERE Name='Retaineraaabcd'])
        {
        	if (item.RecordTypeId==mapRecordTypeNames2Ids.get('Retainer')) {
        		system.assertEquals(item.pse__Amount__c, 200);
        	} else {
        		system.assertEquals(item.RecordTypeId, mapRecordTypeNames2Ids.get('Retainer_Adjustment'));
        		system.assertEquals(item.pse__Amount__c, -200);
        	}
        }
        Test.stopTest();
    }
}