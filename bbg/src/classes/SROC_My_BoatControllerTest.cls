@isTest(seeAllData=true)
private class SROC_My_BoatControllerTest 
{

    static testMethod void myUnitTest() 
    {
        Id ownerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        Account objAccount= new Account(LastName ='Account', ShippingCity  = 'Test', HIN_Number__c = '123', RecordtypeId = ownerRecordTypeId, Brand__c = 'BC');
        insert objAccount;
        Geocode_Data_Row__c objGDR = new Geocode_Data_Row__c(Name = 'Geocode-01', Postal_Code__c = '98001',  Geocode__Latitude__s = 47.3037,Geocode__Longitude__s = 122.2660);
        insert objGDR;                        
        
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account objAccount1= new Account(Name ='Account', ShippingCity  = 'Test', HIN_Number__c = '123', RecordtypeId = dealerRecordTypeId, Brand__c = 'BC',
                                         GeoLocation__Latitude__s = 47.3037, GeoLocation__Longitude__s = 122.2660);
        insert objAccount1;
        
        Boat__c objBoat = new Boat__c(Name = '123', Status__c = 'Active');
        insert objBoat;
        
        Owner_Boat_Relationship__c objBoatRelationship = new Owner_Boat_Relationship__c(HIN_Number__c = objBoat.Id, Owner__c = objAccount.Id);
        insert objBoatRelationship;
        Attachment objAttachment =  new Attachment(Name='Unit Test Attachment', Body =Blob.valueOf('Unit Test Attachment Body'), ParentId=objAccount1.Id);
        insert objAttachment;
        
        Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('Support Documentation').getRecordTypeId();
        
        List<CORECONNECT__CC_Personal_Item__c> lstPersonalItem = new List<CORECONNECT__CC_Personal_Item__c>{
                                                                                                                new CORECONNECT__CC_Personal_Item__c(Name = 'Test-01', 
                                                                                                                                                     CORECONNECT__My_Links_Title__c = 'Test-01',
                                                                                                                                                     CORECONNECT__My_Links_URL__c ='Test-01',
                                                                                                                                                     RecordtypeId = devRecordTypeId),
                                                                                                                new CORECONNECT__CC_Personal_Item__c(Name = 'Test-02', 
                                                                                                                                                     CORECONNECT__My_Links_Title__c = 'Test-02',
                                                                                                                                                     CORECONNECT__My_Links_URL__c ='Test-02',
                                                                                                                                                     RecordtypeId = devRecordTypeId),
                                                                                                                new CORECONNECT__CC_Personal_Item__c(Name = 'Test-03', 
                                                                                                                                                     CORECONNECT__My_Links_Title__c = 'Test-03',
                                                                                                                                                     CORECONNECT__My_Links_URL__c ='Test-03',
                                                                                                                                                     RecordtypeId = devRecordTypeId),
                                                                                                                new CORECONNECT__CC_Personal_Item__c(Name = 'Test-04', 
                                                                                                                                                     CORECONNECT__My_Links_Title__c = 'Test-04',
                                                                                                                                                     CORECONNECT__My_Links_URL__c ='Test-04',
                                                                                                                                                     RecordtypeId = devRecordTypeId),
                                                                                                                new CORECONNECT__CC_Personal_Item__c(Name = 'Test-05', 
                                                                                                                                                     CORECONNECT__My_Links_Title__c = 'Test-05',
                                                                                                                                                     CORECONNECT__My_Links_URL__c ='Test-05',
                                                                                                                                                     RecordtypeId = devRecordTypeId)};
        insert lstPersonalItem;
        PageReference pageRef = Page.SROC_My_Boat;
        Test.setCurrentPage(pageRef);
        SROC_My_BoatController objBoatController = new SROC_My_BoatController();
        String defaultBannerURL = objBoatController.defaultBannerURL;
        objBoatController.BannerImageAttachment = objAttachment;
        objBoatController.clearMyBoatImage();
        objBoatController.dealerPostalCodeSearch = '98001';
        objBoatController.withinDistance = 10;
        objBoatController.doDealerSearch();
        objBoatController.forwardToLogin();
        objBoatController.getManualList();
        objBoatController.GoToPage();
        objBoatController.selectedPreferredDealer = objAccount.Id;
        objBoatController.BannerImageAttachment = objAttachment;
        objBoatController.NewBannerImageAttachment = new Attachment(Name='Unit Test Attachment', Body =Blob.valueOf('Unit Test Attachment Body'));
        objBoatController.saveMyBoatInfo();
        objBoatController.piIdToDelete = lstPersonalItem[0].Id;
        objBoatController.deleteBookmark();
        objBoatController.nextSet();
        objBoatController.prevSet();
        Integer totalpage = objBoatController.TotalPages;
        System.assertEquals(totalpage, 0);
        Integer pageNo = objBoatController.PageNumber;
        System.assertEquals(pageNo,1);
        Boolean hasPrevSet = objBoatController.hasPrevSet;
        System.assertEquals(hasPrevSet, false);
        Boolean hasNextSet = objBoatController.hasNextSet;
        System.assertEquals(hasNextSet, false);
        objBoatController.piIdToDelete = null;
        objBoatController.deleteBookmark();
        objBoatController.SpecifiedPageNumber = 1;
        objBoatController.GoToPage();
        Boolean isError = objBoatController.isError;
    }
}