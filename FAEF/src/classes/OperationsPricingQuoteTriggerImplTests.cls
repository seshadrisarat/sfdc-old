@IsTest
private with sharing class OperationsPricingQuoteTriggerImplTests {

    // this is used to create fake ids so we don't have interact with the database to get an id
    static Integer fakeIdNumber = 0;
    
    static testMethod void testCollectStringField(){
        List<Account> accounts = new List<Account>{
            new Account(Name = 'John Doe')
            , new Account(Name = 'Jane Doe')
            , new Account(Name = 'John Hancock')
            , new Account(Name = 'Anonymous')
        };
        Test.startTest();
        String[] names = OperationsPricingQuoteTriggerImpl.collectStringField(accounts, 'Name');
        Test.stopTest();
        
        System.assertEquals (accounts.size(), names.size());
        for (Integer i = 0; i < accounts.size(); i++){
            System.assertEquals(accounts[i].Name, names[i]);
        }
    }
    
    static testMethod void testCollectStringField_NullValues(){
        
        List<Account> accounts = new List<Account>{
            new Account(Name = null)
            , new Account(Name = 'Jane Doe')
            , new Account(Name = 'John Hancock')
            , new Account(Name = 'Anonymous')
        };
        
        Test.startTest();
        String[] names = OperationsPricingQuoteTriggerImpl.collectStringField(accounts, 'Name');
        Test.stopTest();
        
        System.assertEquals(accounts.size() - 1, names.size());
        for (Integer i = 1; i < accounts.size(); i++){
            System.assertEquals(accounts[i].Name, names[i - 1]);
        }
    }
    
    static testMethod void testSetAsNotSynchedIfFieldsChanged(){
        sObjectType objType = Schema.sObjectType.Operations_Pricing_Quote__c.getSObjectType();
        List<Operations_Pricing_Quote__c> oldQuotes = new List<Operations_Pricing_Quote__c>{
            new Operations_Pricing_Quote__c(ID = getFakeId(objType), Lessee__c = 'Test 1', Prepared_By__c = 'John', Is_Synchronized__c = true)
            , new Operations_Pricing_Quote__c(ID = getFakeId(objType), Lessee__c = 'Test 2', Prepared_By__c = 'James', Is_Synchronized__c = true)
            , new Operations_Pricing_Quote__c(ID = getFakeId(objType), Lessee__c = 'Test 3', Prepared_By__c = 'Jacob', Is_Synchronized__c = true)
        };
        List<Operations_Pricing_Quote__c> newQuotes = new List<Operations_Pricing_Quote__c>();
        for (Operations_Pricing_Quote__c oldAccount : oldQuotes){
            newQuotes.add(oldAccount.clone(true, true, true, true));
        }
        Map<ID, Operations_Pricing_Quote__c> oldMap = new Map<ID, Operations_Pricing_Quote__c>(oldQuotes);
        Map<ID, Operations_Pricing_Quote__c> newMap = new Map<ID, Operations_Pricing_Quote__c>(newQuotes);
        
        newQuotes[0].Lessee__c = 'Testing 1';
        newQuotes[1].Prepared_By__c = 'Jim';
        List<String> fieldsToCheck = new List<String>{ 'Lessee__c', 'Prepared_By__c' };
        
        for (Operations_Pricing_Quote__c quote : newQuotes){
            System.assertEquals(true, quote.Is_Synchronized__c);
        }
        
        Test.startTest();
        OperationsPricingQuoteTriggerImpl.setAsNotSynchedIfFieldsChanged(newMap, oldMap, fieldsToCheck);
        Test.stopTest();
        
        System.assertEquals(false, newQuotes[0].Is_Synchronized__c);
        System.assertEquals(false, newQuotes[1].Is_Synchronized__c);
        System.assertEquals(true, newQuotes[2].Is_Synchronized__c);
    }
    
    static testMethod void testSetIfNeedsSynchronization_NeedsSync(){
        DescribeSObjectResult quoteDescribe = Schema.sObjectType.Operations_Pricing_Quote__c;
        Map<String, sObjectField> quoteFields = quoteDescribe.fields.getMap();
        List<IST__SuperTRUMP_Mapping__c> mappings = new List<IST__SuperTRUMP_Mapping__c>{
            new IST__SuperTRUMP_Mapping__c(IST__SF_Object_Name__c = quoteDescribe.getName(),
                IST__SF_Field_Name__c = quoteFields.get('Structure__c').getDescribe().getName(),
                IST__ST_Field_Name__c = 'Opportunity.Quotes.Quote[].Transaction.FAEFData.LeaseType',
                IST__SF_Object_Level__c = '1',
                IST__IsSynch__c = true,
                IST__IsSynch_In__c = false,
                IST__SOR__c = 'ST',
                IST__SF_Master_Object_Name__c = quoteDescribe.getName())
        };
        insert mappings;
        
        Schedule__c schedule = createNewSchedule();
        Operations_Pricing_Quote__c oldQuote = new Operations_Pricing_Quote__c(Schedule__c = schedule.ID,
            Is_Synchronized__c = true,
            Structure__c = 'FMV'
        );
        oldQuote.ID = getFakeId(Schema.sObjectType.Operations_Pricing_Quote__c.getSObjectType());
        Operations_Pricing_Quote__c newQuote = oldQuote.clone(true, true, true, true);
        
        newQuote.Structure__c = 'FMA';
        System.assertNotEquals(oldQuote.Structure__c, newQuote.Structure__c);
        
        Map<ID, Operations_Pricing_Quote__c> newMap = new Map<ID, Operations_Pricing_Quote__c>{ newQuote.ID => newQuote };
        Map<ID, Operations_Pricing_Quote__c> oldMap = new Map<ID, Operations_Pricing_Quote__c>{ oldQuote.ID => oldQuote };
        
        System.assert(oldQuote.Is_Synchronized__c);
        System.assert(newQuote.Is_Synchronized__c);
        
        Test.startTest();
        OperationsPricingQuoteTriggerImpl.setIfNeedsSynchronization(newMap, oldMap);
        Test.stopTest();
        
        System.assert(oldQuote.Is_Synchronized__c);
        System.assert(!newQuote.Is_Synchronized__c);
    }
    
    static testMethod void testSetIfNeedsSynchronization_NoSync(){
        DescribeSObjectResult quoteDescribe = Schema.sObjectType.Operations_Pricing_Quote__c;
        Map<String, sObjectField> quoteFields = quoteDescribe.fields.getMap();
        List<IST__SuperTRUMP_Mapping__c> mappings = new List<IST__SuperTRUMP_Mapping__c>{
            new IST__SuperTRUMP_Mapping__c(IST__SF_Object_Name__c = quoteDescribe.getName(),
                IST__SF_Field_Name__c = quoteFields.get('Structure__c').getDescribe().getName(),
                IST__ST_Field_Name__c = 'Opportunity.Quotes.Quote[].Transaction.FAEFData.LeaseType',
                IST__SF_Object_Level__c = '1',
                IST__IsSynch__c = true,
                IST__IsSynch_In__c = false,
                IST__SOR__c = 'ST',
                IST__SF_Master_Object_Name__c = quoteDescribe.getName())
        };
        insert mappings;
        
        Schedule__c schedule = createNewSchedule();
        Operations_Pricing_Quote__c oldQuote = new Operations_Pricing_Quote__c(Schedule__c = schedule.ID,
            Is_Synchronized__c = true,
            Structure__c = 'FMV'
        );
        oldQuote.ID = getFakeId(Schema.sObjectType.Operations_Pricing_Quote__c.getSObjectType());
        Operations_Pricing_Quote__c newQuote = oldQuote.clone(true, true, true, true);
        
        newQuote.Approval_Date__c = Date.today();
        
        Map<ID, Operations_Pricing_Quote__c> newMap = new Map<ID, Operations_Pricing_Quote__c>{ oldQuote.ID => oldQuote };
        Map<ID, Operations_Pricing_Quote__c> oldMap = new Map<ID, Operations_Pricing_Quote__c>{ newQuote.ID => newQuote };
        
        System.assert(oldQuote.Is_Synchronized__c);
        System.assert(newQuote.Is_Synchronized__c);
        
        Test.startTest();
        OperationsPricingQuoteTriggerImpl.setIfNeedsSynchronization(newMap, oldMap);
        Test.stopTest();
        
        System.assert(oldQuote.Is_Synchronized__c);
        System.assert(newQuote.Is_Synchronized__c);
    }
    
    static testMethod void testSynchronizeSuperTrumpData(){
        // We can't actually test the synchronization part, because that is in the managed packaged
        // and we don't want to test the managed package, so we will test the case when
        // synchronization is not required
        
        List<Operations_Pricing_Quote__c> quotes = new List<Operations_Pricing_Quote__c>{
            new Operations_Pricing_Quote__c(Is_Synchronized__c = true)
        };
        
        OperationsPricingQuoteTriggerImpl.synchronizeSuperTrumpData(quotes);
        
        System.assert(quotes[0].Is_Synchronized__c);
    }
    
    static testMethod void testUpdateTriggers_NoScheduleCopy_NoSync(){
        Schedule__c schedule = createNewSchedule();
        
        // we query to get the value of the roll-ups
        schedule = [SELECT ID, Name, Total_Equipment_Price__c, Hardware_Percent__c, Software_Percent__c
                    FROM Schedule__c WHERE ID = :schedule.ID];
        
        Operations_Pricing_Quote__c quote = getNewOpsQuote(schedule);
        quote.Is_Synchronized__c = true;
        quote.Equipment_Cost_Override__c = true;
        quote.Equipment_Cost__c = 1000000;
        quote.Hardware_Software_Override__c = true;
        quote.Hardware_Percent__c = 100;
        quote.Software_Percent__c = 0;
        
        System.assertNotEquals(quote.Equipment_Cost__c, schedule.Total_Equipment_Price__c);
        System.assertNotEquals(quote.Hardware_Percent__c, schedule.Hardware_Percent__c);
        System.assertNotEquals(quote.Software_Percent__c, schedule.Software_Percent__c);
        
        Test.startTest();
        insert quote;
        
        // we query to get the value of the roll-ups
        quote = [SELECT ID, Is_Synchronized__c, Schedule_Equipment_Cost__c, Schedule_Hardware_Percent__c,
                 Schedule_Software_Percent__c, Equipment_Cost__c, Hardware_Percent__c, Software_Percent__c
                 FROM Operations_Pricing_Quote__c
                 WHERE ID = :quote.ID];
        
        System.assertEquals(false, IST.SuperTRUMPController.isSuperTrumpUpdate);
        System.assertNotEquals(quote.Equipment_Cost__c, schedule.Total_Equipment_Price__c);
        System.assertNotEquals(quote.Hardware_Percent__c, schedule.Hardware_Percent__c);
        System.assertNotEquals(quote.Software_Percent__c, schedule.Software_Percent__c);
        
        quote.Structure__c = 'FMV';
        
        update quote;
        Test.stopTest();
        
        // we query to get the value of the roll-ups
        quote = [SELECT ID, Is_Synchronized__c, Schedule_Equipment_Cost__c, Schedule_Hardware_Percent__c,
                 Schedule_Software_Percent__c, Equipment_Cost__c, Hardware_Percent__c, Software_Percent__c
                 FROM Operations_Pricing_Quote__c
                 WHERE ID = :quote.ID];
        
        System.assertNotEquals(quote.Equipment_Cost__c, schedule.Total_Equipment_Price__c);
        System.assertNotEquals(quote.Hardware_Percent__c, schedule.Hardware_Percent__c);
        System.assertNotEquals(quote.Software_Percent__c, schedule.Software_Percent__c);
        System.assert(quote.Is_Synchronized__c);
    }

    private static Letter_Of_Intent__c getNewLetterOfIntent(){
        return new Letter_Of_Intent__c();
    }
    
    private static Schedule__c getNewSchedule(){
        Schedule__c schedule =  new Schedule__c(
            Name = 'Test Schedule'
        );
        
        return schedule;
    }
    
    private static Operations_Pricing_Quote__c getNewOpsQuote(Schedule__c schedule){
        System.assertNotEquals(null, schedule.ID);
        
        return new Operations_Pricing_Quote__c(
            Schedule__c = schedule.ID
        );
    }
    
    private static Schedule__c createNewSchedule(){
        Letter_Of_Intent__c loi = getNewLetterOfIntent();
        insert loi;
        Schedule__c s = getNewSchedule();
        s.Letter_of_Intent__c = loi.ID;
        insert s;
        
        return s;
    }
    
    private static Equipment__c getNewEquipment(Double unitPrice, Integer quantity, Schedule__c schedule){
        System.assertNotEquals(null, schedule.ID);
        return new Equipment__c(
            Name = 'Test Equipment',
            Unit_Price__c = unitPrice,
            Quantity__c = quantity,
            Schedule__c = schedule.ID
        );
    }
    
    private static List<Equipment_Item__c> getNewEquipmentItems(Equipment__c equipment){
        System.assertNotEquals(null, equipment, 'Equipment cannot be null.');
        System.assertNotEquals(null, equipment.Quantity__c);
        System.assertNotEquals(null, equipment.Name, 'The equipment must have a name.');
        System.assert(equipment.Quantity__c > 0, 'There must be at least one equipment item.');
        
        List<Equipment_Item__c> items = new List<Equipment_Item__c>();
        
        for (Integer i = 0; i < equipment.Quantity__c; i++){
            items.add(new Equipment_Item__c(
                Equipment__c = equipment.Id
            ));
        }
        return items;
    }
    
    private static Invoice__c getNewInvoice(Schedule__c schedule, Double hardwareCost, Double softwareCost, Double softCost){
        System.assertNotEquals(null, schedule.ID, 'The schedule must have an id to create an invoice.');
        return new Invoice__c(
            Schedule__c = schedule.ID,
            Hardware_Cost__c = hardwareCost,
            Software_Cost__c = softwareCost,
            Soft_Cost__c = softCost
        );
    }
    
    private static ID getFakeId(Schema.sObjectType objType){
        String result = String.valueOf(fakeIdNumber++);
        String fakeId = objType.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
        return ID.valueOf(fakeId);
    }
}