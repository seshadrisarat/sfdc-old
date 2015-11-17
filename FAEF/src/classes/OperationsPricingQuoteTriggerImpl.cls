public with sharing class OperationsPricingQuoteTriggerImpl {

    public static void beforeUpdate(Map<ID, Operations_Pricing_Quote__c> newMap, Map<ID, Operations_Pricing_Quote__c> oldMap){
        System.assertNotEquals(null, newMap);
        System.assertNotEquals(null, oldMap);
        setIfNeedsSynchronization(newMap, oldMap);
    }
    
    public static void afterUpdate(Map<ID, Operations_Pricing_Quote__c> newMap, Map<ID, Operations_Pricing_Quote__c> oldMap){
        System.assertNotEquals(null, newMap);
        System.assertNotEquals(null, oldMap);
        synchronizeSuperTrumpData(newMap.values());
    }

    @TestVisible
    private static void setIfNeedsSynchronization(Map<ID, Operations_Pricing_Quote__c> newMap, Map<ID, Operations_Pricing_Quote__c> oldMap){
        if (!IST.SuperTRUMPController.isSuperTrumpUpdate){
            Boolean needsSync = false;
            for (Operations_Pricing_Quote__c quote : newMap.values()){
                if ((!quote.Equipment_Cost_Override__c && quote.Equipment_Cost__c != quote.Schedule_Equipment_Cost__c)
                        || (!quote.Hardware_Software_Override__c
                            && (quote.Hardware_Percent__c != quote.Schedule_Hardware_Percent__c
                                || quote.Software_Percent__c != quote.Schedule_Software_Percent__c))){
                    quote.Is_Synchronized__c = false;
                    needsSync = true;
                }
            }
            if (needsSync){
                return; // we already know we need to synchronize, so just return
            }
            String objName = Schema.sObjectType.Operations_Pricing_Quote__c.getName();

            IST__SuperTRUMP_Mapping__c[] mappings = [SELECT ID, Name, IST__SF_Field_Name__c
                                                     FROM IST__SuperTRUMP_Mapping__c
                                                     WHERE IST__SF_Object_Name__c = :objName
                                                     AND IST__SF_Master_Object_Name__c = :objName
                                                     AND (IST__IsSynch_In__c = true OR IST__IsSynch__c = true)];

            // if no mappings are found, synching cannot occur so just return
            if (mappings.size() == 0) return;

            String[] fieldNameList = collectStringField(mappings, 'IST__SF_Field_Name__c');
            setAsNotSynchedIfFieldsChanged(newMap, oldMap, fieldNameList);
        }
    }
    
    @TestVisible
    private static List<String> collectStringField(List<sObject> objList, String fieldName){
        List<String> fieldValueList = new List<String>();
        for (sObject obj : objList){
            String fieldValue = String.valueOf(obj.get(fieldName));
            if (fieldValue != null){
                fieldValueList.add(fieldValue);
            }
        }
        return fieldValueList;
    }
    
    @TestVisible
    private static void setAsNotSynchedIfFieldsChanged(Map<ID, Operations_Pricing_Quote__c> newMap,
            Map<ID, Operations_Pricing_Quote__c> oldMap,
            List<String> fieldNameList){
        
        for (Operations_Pricing_Quote__c newQuote : newMap.values()){
            if (!newQuote.Is_Synchronized__c) continue;
            
            for (String fieldName : fieldNameList){
                if (newQuote.get(fieldName) != oldMap.get(newQuote.ID).get(fieldName)){
                    newQuote.Is_Synchronized__c = false;
                    break;
                }
            }
        }
    }

    @TestVisible
    private static void synchronizeSuperTrumpData(List<Operations_Pricing_Quote__c> quotes){
        if (!IST.SuperTRUMPController.isSuperTrumpUpdate){
            for (Operations_Pricing_Quote__c quote : quotes){
                if (!quote.Is_Synchronized__c){
                    IST.SuperTRUMPController.synchSFToST(String.valueOf(quote.ID));
                }
            }
        }
    }
}