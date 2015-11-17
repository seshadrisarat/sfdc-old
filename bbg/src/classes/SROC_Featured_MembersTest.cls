@isTest(SeeAllData=true)
private class SROC_Featured_MembersTest {

    static testMethod void myUnitTest() 
    {
        Profile p = [SELECT Id, UserLicense.LicenseDefinitionKey FROM Profile WHERE UserLicense.LicenseDefinitionKey = 'PID_Customer_Community_Login' LIMIT 1];
        Account objAccount= new Account(Name ='Account', ShippingCity  = 'Test');
        insert objAccount;
        
        Contact objContact1 = new Contact(LastName='Test Contact - 01', AccountId= objAccount.Id); 
        insert objContact1;
        Contact objContact2 = new Contact(LastName='Test Contact - 02', AccountId= objAccount.Id); 
        insert objContact2;
        
        List<User> lstUser = new List<User>{
                                                new User(CORECONNECT__Classification1__c = 'Dealers',CORECONNECT__CC_List_In_Directory__c = true,
                                                         contactId = objContact1.id,
                                                         Alias = 'standt', Email='standarduser@testorg.com',
                                                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                                         LocaleSidKey='en_US', ProfileId = p.Id,
                                                         TimeZoneSidKey='America/Los_Angeles', UserName='TestDealer@testorg.com'),
                                                new User(CORECONNECT__Classification1__c = 'Owners', CORECONNECT__CC_List_In_Directory__c = true,
                                                         contactId = objContact2.id,
                                                         Alias = 'standt', Email='standarduser@testorg.com',
                                                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                         LocaleSidKey='en_US', ProfileId = p.Id,
                                                         TimeZoneSidKey='America/Los_Angeles', UserName='TestOwner@testorg.com')    
        };
        
        insert lstUser;
        
        List<CORECONNECT__CC_Home_Page_Item__c> lstPageItem = new List<CORECONNECT__CC_Home_Page_Item__c>{
                                                                                                            new CORECONNECT__CC_Home_Page_Item__c(CORECONNECT__Featured_Member__c = lstUser[0].Id),
                                                                                                            new CORECONNECT__CC_Home_Page_Item__c(CORECONNECT__Featured_Member__c = lstUser[1].Id),
                                                                                                            new CORECONNECT__CC_Home_Page_Item__c(CORECONNECT__Featured_Member__c = lstUser[0].Id),
                                                                                                            new CORECONNECT__CC_Home_Page_Item__c(CORECONNECT__Featured_Member__c = lstUser[1].Id),
                                                                                                            new CORECONNECT__CC_Home_Page_Item__c(CORECONNECT__Featured_Member__c = lstUser[0].Id)
                                                                                                            
        };
        insert lstPageItem;
        
        SROC_Featured_Members objFeatured_Members = new SROC_Featured_Members();
        String ambassadorIndicatorImage = objFeatured_Members.ambassadorIndicatorImage;
        List<CORECONNECT.CC_CommunityContentWrapper> listOfMembers = objFeatured_Members.ListOfMembers;
        System.assertNotEquals(listOfMembers.size(), 0);
        objFeatured_Members.numOfMembers = 10;
        objFeatured_Members.ownersOrDealers = 'dealers';
        listOfMembers = objFeatured_Members.ListOfMembers;
        System.assertNotEquals(listOfMembers.size(), 0);
    }
    
}