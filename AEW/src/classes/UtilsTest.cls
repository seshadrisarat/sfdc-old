// SL - 2015-08-10 Deeper Clone Utility for AEW Mailings

@isTest(SeeAllData=true)
public without sharing class UtilsTest {

    public static List<Account> createTestOrganizations(Integer count, Id parentId) {
        List<Account> listOf = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            Account toInsert = new Account();
                toInsert.Name = 'Test AEW Mailing Account ' + i;
                toInsert.RecordType = [Select Id From RecordType Where SobjectType = 'Account' and DeveloperName = 'Client'];
                if (parentId != null) toInsert.ParentId = parentId;
             listOf.add(toInsert);
        }
        insert listOf;
        return listOf;
    }
    
        public static List<AEW_Mailing__c> createAEWMailings(Integer count) {
        List<AEW_Mailing__c> listOf = new List<AEW_Mailing__c>();
        for (Integer i = 0; i < count; i++) {
            AEW_Mailing__c toInsert = new AEW_Mailing__c();
                toInsert.Name = 'Test AEW Mailing ' + i;
                toInsert.Mailing_Description__c = 'test' + i;
            listOf.add(toInsert);
        }
        insert listOf;
        return listOf;
    }

        public static List<Fund_Communication__c> createFundCommunications (Integer count, Id contactId, Id mailingId) {
        List<Fund_Communication__c> listOf = new List<Fund_Communication__c>();
        if (contactId == null) contactId = createContacts(1)[0].Id;       
        for (Integer i = 0; i < count; i++) {
            Fund_Communication__c toInsert = new Fund_Communication__c();
                toInsert.Name = 'test';
                toInsert.Investor_Name__c = 'test';
                toInsert.Instructions__c = 'test';
                toInsert.AEW_Mailing__c = mailingId;
                toInsert.Primary_Recipient__c = contactId;
            listOf.add(toInsert);
        }
        insert listOf;
        return listOf;
    }
    
        public static List<Fund_Communication_Recipient__c> createFundCommunicationRecipients (Integer count, Id contactId, Id fundcommunicationId) {
        List<Fund_Communication_Recipient__c> listOf = new List<Fund_Communication_Recipient__c>();
        if (contactId == null) contactId = createContacts(1)[0].Id;       
        for (Integer i = 0; i < count; i++) {
            Fund_Communication_Recipient__c toInsert = new Fund_Communication_Recipient__c();
                toInsert.Fund_Communication__c = fundcommunicationId;
                toInsert.Contact__c = contactId;
                toInsert.To_or_CC__c = 'To';
                toInsert.Method__c = 'Email';
            listOf.add(toInsert);
        }
        insert listOf;
        return listOf;
    }
    
        public static List<Contact> createContacts(Integer count) {
        List<Contact> listOf = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            Contact toInsert = new Contact();
                toInsert.LastName = 'AEW Contact ' + i;
                toInsert.FirstName = 'Test';
             listOf.add(toInsert);
        }
        insert listOf;
        return listOf;
    }    
    
    
}