public without sharing class TestDataUtil {

    public static ID getOpportunityRecordTypeIdByName(String recTypeName) {
        List<RecordType> recType = 
            [Select Id From RecordType where SobjectType = 'Opportunity' and Name = :recTypeName limit 1];
        return recType != null && recType.size() == 1 ? recType[0].Id : null;
    }

    public static ID getNPDForecastOpportunityRecordTypeId() {
        return getOpportunityRecordTypeIdByName('NPD Forecast');
    }

    public static ID getNPDReconciledOpportunityRecordTypeId() {
        return getOpportunityRecordTypeIdByName('NPD Reconciled');
    }

    public static ID getNPDNotReconciledOpportunityRecordTypeId() {
        return getOpportunityRecordTypeIdByName('NPD Not Reconciled');
    }

    public static ID getBillingRecordTypeIdByName(String recTypeName) {
        List<RecordType> recType = 
            [Select Id From RecordType where SobjectType = 'Billing__c' and Name = :recTypeName limit 1];
        return recType != null && recType.size() == 1 ? recType[0].Id : null;
    }

    public static ID getNPDReconciledBillingRecordTypeId() {
        return getBillingRecordTypeIdByName('Billing NPD Reconciled');
    }

    public static Corporate_Product__c createCorporateProduct() {
        Corporate_Product__c cProd = new Corporate_Product__c(Name = 'Test Corporate Prod', Active__c = true, Corporate_Product_LOB__c = 'USA - 3100 - Foodservice');
        insert cProd;
        return cProd;
    }
}