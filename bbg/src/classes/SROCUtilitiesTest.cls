@isTest(seeAllData=true)
private class SROCUtilitiesTest {

    static testMethod void myUnitTest() 
    {
        Id ownerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        Account objAccount= new Account(Name ='Account', ShippingCity  = 'Test');
        insert objAccount;
        Account objAccount1= new Account(LastName ='Account', ShippingCity  = 'Test', HIN_Number__c = '123', RecordtypeId = ownerRecordTypeId, Brand__c = 'BC');
        insert objAccount1;
        
        Contact objContact = new Contact(LastName='Test Contact - 01', AccountId= objAccount.Id); 
        insert objContact;
        
        Boat__c objBoat = new Boat__c(Name = '123', Status__c = 'Active');
        insert objBoat;
        
        Owner_Boat_Relationship__c objBoatRelationship = new Owner_Boat_Relationship__c(HIN_Number__c = objBoat.Id, Owner__c = objAccount1.Id);
        insert objBoatRelationship;
        
        Id devRecordTypeId = Schema.SObjectType.Boat_Component__c.getRecordTypeInfosByName().get('Engine Record Type').getRecordTypeId();
        Boat_Component__c objBoatComponent = new Boat_Component__c(Name = 'Test Component', Boat__c = objBoat.Id, Engine_Number__c = '12t345ewt');
        insert objBoatComponent;
        
        
        FAQ__kav objFAQ = new FAQ__kav(Title = 'faqtitle', Summary = 'Test Summary-01', URLName = 'faqtitle');
        insert objFAQ;
        objFAQ  = [Select Id, Title, Summary, URLName, KnowledgeArticleId from FAQ__kav where Id = :objFAQ.Id LIMIT 1];
        
        KbManagement.PublishingService.publishArticle(objFAQ.KnowledgeArticleId, true);
        
        
        Owner_Boat_Relationship__c objRelationship = SROCUtilities.queryOwnerBoatRelationship();
        List<Boat_Component__c> lstBoatComponent = SROCUtilities.queryBoatEngineComponents(objBoat.Id);
        Geocode_Data_Row__c objGeoDataRow = SROCUtilities.postalCodeToGeocodeData('98001');
        objGeoDataRow = SROCUtilities.postalCodeToGeocodeData('');
        
        List<Geocode_Data_Row__c> lstGeocodeDataRow = new List<Geocode_Data_Row__c>{
                                                                                        new Geocode_Data_Row__c(Name = 'Geocode-01',
                                                                                                                Postal_Code__c = '98001',
                                                                                                                Geocode__Latitude__s = 47.3037,
                                                                                                                Geocode__Longitude__s = 122.2660),
                                                                                        new Geocode_Data_Row__c(Name = 'Geocode-01',
                                                                                                                Postal_Code__c = '98002',
                                                                                                                Geocode__Latitude__s = 47.3042,
                                                                                                                Geocode__Longitude__s = 122.2160),
                                                                                        new Geocode_Data_Row__c(Name = 'Geocode-01',
                                                                                                                Postal_Code__c = '98071',
                                                                                                                Geocode__Latitude__s = 47.3037,
                                                                                                                Geocode__Longitude__s = 122.2660),
                                                                                        new Geocode_Data_Row__c(Name = 'Geocode-01',
                                                                                                                Postal_Code__c = '98092',
                                                                                                                Geocode__Latitude__s = 47.3037,
                                                                                                                Geocode__Longitude__s = 122.2660)};
        insert lstGeocodeDataRow;
        
        objGeoDataRow = SROCUtilities.postalCodeToGeocodeData('98001');
        ApexPages.StandardSetController stdController = SROCUtilities.queryDealersNear('98001', 3);
        Map<String,String> mapLinkIcons = SROCUtilities.queryLinkIcons();
        Boolean isOwner = SROCUtilities.isOwner();
        Boolean isUserOwner = SROCUtilities.isOwner(UserInfo.getUserId());
        Boolean isDealer = SROCUtilities.isDealer();
        Boolean isUserDealer = SROCUtilities.isDealer(UserInfo.getUserId());
        Boolean isCCU = SROCUtilities.isCCU();
        System.assertEquals(isCCU, false);
        Boolean isUserCCU = SROCUtilities.isCCU(UserInfo.getUserId());
        System.assertEquals(isUserCCU, false);
        Boolean isCCL = SROCUtilities.isCCL();
        System.assertEquals(isCCL, false);
        Boolean isUserCCL = SROCUtilities.isCCL(UserInfo.getUserId());
        System.assertEquals(isUserCCL, false);
        Map<String,String> describeMap = SROCUtilities.createDescribeMap();
        Map<String,String> describeLabelMap = SROCUtilities.createDescribeMapLabel();
        String articleType = SROCUtilities.retrieveArticleType(objFAQ.KnowledgeArticleId);
        String articleLabel = SROCUtilities.retrieveArticleTypeLabel(objFAQ.KnowledgeArticleId);
        SROCUtilities.deleteContentDocuments(new List<ContentDocument>());
        String strMessage = SROCUtilities.bookmarkArticle(objFAQ.KnowledgeArticleId);
        Integer count = SROCUtilities.queryBookmarkItem(objFAQ.KnowledgeArticleId, 'faqtitle');
        
        Profile p = [SELECT Id, UserLicense.LicenseDefinitionKey FROM Profile WHERE UserLicense.LicenseDefinitionKey = 'PID_Customer_Community_Login' LIMIT 1];

        User u = new User( ProfileId = p.Id,
                           UserName='stand1112211arduser@testorg.com',
                           Email='standarduser@testorg.com',
                           EmailEncodingKey='UTF-8',
                           LocaleSidKey='en_US',
                           LanguageLocaleKey='en_US',
                           TimeZoneSidKey='America/Los_Angeles', 
                           Alias = 'standt',
                           LastName='Testing',
                           ContactId = objContact.Id);
        insert u;                  
        System.runAs(u)
        {                  
            isCCU = SROCUtilities.isCCU();
            isUserCCU = SROCUtilities.isCCU(u.Id);
            isCCL = SROCUtilities.isCCL();
            isUserCCL = SROCUtilities.isCCL(u.Id);
        }
    }
}