/*
*   DealApproval_TestDataFactory – Test data factory class used by DealApproval test classes
*   Author :  Don Koppel 4/15/2014  
*/

@isTest
public class DealApproval_TestDataFactory {

   // public Deal__c createTestDeal(String name, String leaseDealType, String leaseFormType, Id tenantId, Decimal pctRent, 
     //                           Decimal estSquareFootage, String dealStage, Id recordTypeId) {
     
     public Deal__c createTestDeal(String name, String leaseDealType, String leaseFormType, Id tenantId, Decimal pctRent, 
                               Decimal estSquareFootage, String dealStage, Id recordTypeId ,Date commence) {
        Deal__c deal = new Deal__c(Name = name, NewDeal_Renewal__c = leaseDealType, Lease_Form_Type__c = leaseFormType,
                                    Tenant__c = tenantId, Percentage_Rent__c = pctRent, Estimated_Square_Footage__c = estSquareFootage,
                                    Deal_Stage__c = dealStage, RecordTypeId = recordTypeId,Commencement_Date__c=commence);
        return deal;
    }

    public Deal_Rent__c createTestDealRent(Deal__c leasingDeal, Boolean isOption, Decimal annualRent, String increaseType,
                                            Id recordTypeId) {
        Deal_Rent__c dealRent = new Deal_Rent__c(Leasing_Deal__c = leasingDeal.Id, Is_Option__c = isOption,
                                                Annual_Rent_Amount__c = annualRent, Base_Rent_Increase_Type__c = increaseType,
                                                RecordTypeId = recordTypeId);
        return dealRent;
    }

    public Account createTestTenant(String name) {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 

        Account tenant = new Account(Name = name, recordtypeid=AccountRecordTypeInfo .get('Tenant').getRecordTypeId());
        return tenant;
    }
}