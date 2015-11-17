public class ScheduleTriggerImpl {

    public static void beforeUpdate(Map<ID, Schedule__c> newMap, Map<ID, Schedule__c> oldMap){
        ifChangedUpdateQuotes(newMap, oldMap);
    }
    
    /**
     * If Total_Equipment_Price__c, Harware_Total_Amount__c, or Software_Total__c have been changed
     * on a schedule, call the update trigger on all associated pricing quotes.
     */
    @TestVisible
    private static void ifChangedUpdateQuotes(Map<ID, Schedule__c> newMap, Map<ID, Schedule__c> oldMap){
        
        List<String> fieldsToCheck = new List<String>{
            'Total_Equipment_Price__c', 'Hardware_Total_Amount__c', 'Software_Total__c'
        };
        List<Schedule__c> schedules = (List<Schedule__c>) getSObjectsWithFieldUpdates(newMap, oldMap, fieldsToCheck);
        execQuoteUpdateTrigger(schedules);
    }
    
    /**
     * Checks the fields in the passed in list and checks if any of them are different comparing the
     * passed in oldMap to the passed in newMap.  Any objects with fields that have been changed are
     * returned.
     */
    @TestVisible
    private static List<sObject> getSObjectsWithFieldUpdates(Map<ID, sObject> newMap, Map<ID, sObject> oldMap, List<String> fieldsToCheck){
        List<sObject> changedObjects = new List<sObject>();
        for (sObject obj : newMap.values()){
            for (String fieldName : fieldsToCheck){
                if (obj.get(fieldName) != oldMap.get(obj.ID).get(fieldName)){
                    changedObjects.add(obj);
                    break;
                }
            }
        }
        return changedObjects;
    }
    
    /**
     * Queries all the quotes associated with the passed in schedules and executes
     * a DML update operations so the update trigger fires for all the quotes.  The quotes
     * have formula references to schedule fields and calling the update trigger allows the
     * quotes to synchronize their PRM data with the Salesforce fields that were just updated.
     * Otherwise, the calculations in the detail for each pricing quote may be incorrect.
     * 
     * NOTE: If any schedule has more than 10 quotes, this update will FAIL because the callout
     * limit will be hit.  Ivory Consulting has been informed that this is a use case that 
     * will never happen, but it's being documented just in case.
     * 
     */
    @TestVisible
    private static void execQuoteUpdateTrigger(List<Schedule__c> schedules){
        System.assertNotEquals(null, schedules);
        
        if (schedules.size() == 0) return;
        // Roll-ups fields that need to be copied have changed, get the quotes that need to be updated
        List<Operations_Pricing_Quote__c> quotes = [SELECT ID, Schedule__c
                                                    FROM Operations_Pricing_Quote__c
                                                    WHERE Schedule__c IN :schedules];
        if (quotes.size() == 0) return;
        
        // Cause the update triggers to fire for quotes so they can use their
        // formula fields that reference the schedule 
        update quotes;
    }
}