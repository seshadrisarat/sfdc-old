@IsTest
private class ScheduleTriggerImplTests {
	
    // this is used to create fake ids so we don't have interact with the database to get an id
    static Integer fakeIdNumber = 0;

    static testMethod void triggerQuoteUpdate_NoCopy(){
        Schedule__c schedule = createSchedule();
        
        System.assertEquals(false, IST.SuperTRUMPController.isSuperTrumpUpdate);
        System.assertEquals(null, schedule.Total_Equipment_Price__c);
        System.assertEquals(null, schedule.Hardware_Percent__c);
        System.assertEquals(null, schedule.Software_Percent__c);
        
        Map<ID, Schedule__c> newMap = new Map<ID, Schedule__c>{ schedule.ID => schedule };
        Map<ID, Schedule__c> oldMap = new Map<ID, Schedule__c>{ schedule.ID => schedule };
        
        Integer queryCount = Limits.getAggregateQueries();
        
        Test.startTest();
        ScheduleTriggerImpl.beforeUpdate(newMap, oldMap);
        // There should not be any queries in the test, because none of the schedule fields
        // being checked were changed
        System.assertEquals(0, Limits.getAggregateQueries());
        Test.stopTest();
        
        System.assertEquals(null, schedule.Total_Equipment_Price__c);
        System.assertEquals(null, schedule.Hardware_Percent__c);
        System.assertEquals(null, schedule.Software_Percent__c);
    }
    
    static testMethod void testGetSObjectsWithFieldUpdates_Empty(){
        Map<ID, sObject> newMap = new Map<ID, sObject>();
        Map<ID, sObject> oldMap = new Map<ID, sObject>();
        List<String> fieldsToCheck = new List<String>();
        
        Test.startTest();
        // empty maps and fields
        System.assertEquals(0, ScheduleTriggerImpl.getSObjectsWithFieldUpdates(newMap, oldMap, fieldsToCheck).size());
        
        // empty maps and one field
        fieldsToCheck.add('Name');
        System.assertEquals(0, ScheduleTriggerImpl.getSObjectsWithFieldUpdates(newMap, oldMap, fieldsToCheck).size());
        
        // maps with one object and empty fields
        fieldsToCheck.remove(0);
        Account acc = new Account(ID = getFakeId(Schema.sObjectType.Account), Name = 'Anonymous');
        newMap.put(acc.ID, acc);
        oldMap.put(acc.ID, acc);
        System.assertEquals(0, ScheduleTriggerImpl.getSObjectsWithFieldUpdates(newMap, oldMap, fieldsToCheck).size());
        Test.stopTest();
    }
    
    static testMethod void testGetSObjectsWithFieldUpdates(){
        final Integer NUM_OBJECTS = 5;
        List<sObject> objects = new List<sObject>();
        Map<ID, sObject> newMap = new Map<ID, sObject>();
        Map<ID, sObject> oldMap = new Map<ID, sObject>();
        
        DescribeSObjectResult describeObj = Schema.sObjectType.Account;
        for (Integer i = 0; i < NUM_OBJECTS; i++){
            objects.add(new Account(
                ID = getFakeId(describeObj),
                Name = 'John' + i,
                AccountNumber = String.valueOf(i))
            );
            newMap.put(objects[i].ID, objects[i]);
            oldMap.put(objects[i].ID, objects[i].clone(true, true, true, true));
        }
        List<String> fieldsToCheck = new List<String>{ 'Name' };
        
        Test.startTest();
        for (Integer i = 0; i < NUM_OBJECTS; i++){
            System.assertEquals(i, ScheduleTriggerImpl.getSObjectsWithFieldUpdates(newMap, oldMap, fieldsToCheck).size());
            objects[i].put('Name', 'Jonathan' + String.valueOf(i));
        }
        Test.stopTest();
    }
    
    static testMethod void testExecQuoteUpdateTrigger_NoSchedules(){
        List<Schedule__c> schedules = new List<Schedule__c>();
        //schedules.add(createSchedule());
        
        Test.startTest();
        ScheduleTriggerImpl.execQuoteUpdateTrigger(schedules);
        System.assertEquals(0, Limits.getQueries());
        System.assertEquals(0, Limits.getDMLStatements());
        Test.stopTest();
    }
    
    static testMethod void testExecQuoteUpdateTrigger_NoQuotes(){
        List<Schedule__c> schedules = new List<Schedule__c>();
        schedules.add(createSchedule());
        
        Test.startTest();
        ScheduleTriggerImpl.execQuoteUpdateTrigger(schedules);
        System.assertEquals(1, Limits.getQueries());
        System.assertEquals(0, Limits.getDMLStatements());
        Test.stopTest();
    }
    
    static testMethod void testExecQuoteUpdateTrigger(){
        List<Schedule__c> schedules = new List<Schedule__c>();
        schedules.add(createSchedule());
        Operations_Pricing_Quote__c quote = getNewOpsQuote(schedules[0]);
        quote.Equipment_Cost_Override__c = true;
        quote.Hardware_Software_Override__c = true;
        insert quote;
        
        Test.startTest();
        ScheduleTriggerImpl.execQuoteUpdateTrigger(schedules);
        System.assertEquals(2, Limits.getQueries());
        System.assertEquals(1, Limits.getDMLStatements());
        Test.stopTest();
    }
    
    private static ID getFakeId(DescribeSObjectResult describeObj){
        String result = String.valueOf(fakeIdNumber++);
        String fakeId = describeObj.getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
        return ID.valueOf(fakeId);
    }
    
    private static Letter_Of_Intent__c getNewLetterOfIntent(){
        return new Letter_Of_Intent__c();
    }
    
    private static Schedule__c getNewSchedule(){
        return new Schedule__c(
            Name = 'Test Schedule'
        );
    }
    
    private static Operations_Pricing_Quote__c getNewOpsQuote(Schedule__c schedule){
        System.assertNotEquals(null, schedule.ID);
        
        return new Operations_Pricing_Quote__c(
            Schedule__c = schedule.ID
        );
    }
    
    private static Schedule__c createSchedule(){
        Letter_Of_Intent__c loi = getNewLetterOfIntent();
        insert loi;
        Schedule__c s = getNewSchedule();
        s.Letter_of_Intent__c = loi.ID;
        insert s;
        
        return s;
    }
}