@isTest
private class SROC_Member_BenefitsControllerTest {

    static testMethod void myUnitTest() 
    {
        List<CORECONNECT__CC_Community_Content__c> lstCommunityContent = new List<CORECONNECT__CC_Community_Content__c>{
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-01',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98001 Test',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today().addDays(-10),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-02',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98001',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-03',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98002',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-04',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98002',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-05',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-06',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-07',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-08',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-09',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-10',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent',
                                                                                                                                                                     CORECONNECT__Classification1__c = 'Event')};
        insert lstCommunityContent;
        SROC_Member_BenefitsController objMemberBenefits = new SROC_Member_BenefitsController();  
        String launchpadImageUrl = objMemberBenefits.launchpadImageUrl;
        String searayLivingImageUrl = objMemberBenefits.searayLivingImageUrl;
        
        List<CORECONNECT.CC_CommunityContentWrapper> ListOfMoreFreeText = objMemberBenefits.ListOfMoreFreeText;
        ApexPages.StandardSetController setController = objMemberBenefits.setController; 
        objMemberBenefits.getClassification1Values();
        objMemberBenefits.Filter();
        objMemberBenefits.Classification1 = 'Event';
        objMemberBenefits.Filter();
        objMemberBenefits.Classification1 = 'All';
        objMemberBenefits.Filter();
        Boolean hasNextSet = objMemberBenefits.hasNextSet;
        System.assertEquals(false, hasNextSet);
        Boolean hasPrevSet = objMemberBenefits.hasPrevSet;
        System.assertEquals(false, hasPrevSet);
        Integer PageNumber = objMemberBenefits.PageNumber;
        System.assertEquals(1, PageNumber);
        Integer TotalPages = objMemberBenefits.TotalPages; 
        System.assertEquals(0, TotalPages);
        Integer SpecifiedPageNumber = objMemberBenefits.SpecifiedPageNumber;
        System.assertEquals(null, SpecifiedPageNumber);
        objMemberBenefits.prevSet();
        objMemberBenefits.nextSet();
        SpecifiedPageNumber = 0;
        objMemberBenefits.GoToPage();
        String todayString = objMemberBenefits.TodayString;
        objMemberBenefits.SaveCurrentToCookie();
    }
}