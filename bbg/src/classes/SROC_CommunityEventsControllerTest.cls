@isTest
private class SROC_CommunityEventsControllerTest {

    static testMethod void myUnitTest() 
    {
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
        List<CORECONNECT__CC_Community_Content__c> lstCommunityContent = new List<CORECONNECT__CC_Community_Content__c>{
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-01',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98001 Test',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today().addDays(-10),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-02',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98001',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-03',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98002',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-04',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98002',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-05',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-06',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-07',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-08',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-09',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent'),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-10',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10),
                                                                                                                                                                     CORECONNECT__Community_Content_Status__c = 'Approved',
                                                                                                                                                                     CORECONNECT__ScheduledContent_Type__c = 'DemoEvent')};
        insert lstCommunityContent;     
        SROC_CommunityEventsController objCommunityEvents = new SROC_CommunityEventsController(); 
        List<CORECONNECT.CC_CommunityContentWrapper> lst = objCommunityEvents.ListOfMoreScheduledContent;
        ApexPages.StandardSetController setController = objCommunityEvents.setController;
        List<SelectOption> lstSelectOption = objCommunityEvents.getScheduledContentTypeValues();
        Boolean hasNext = objCommunityEvents.hasNextSet;
        System.assertEquals(hasNext, false);
        Boolean hasPreviousSet = objCommunityEvents.hasPrevSet;
        System.assertEquals(hasPreviousSet, false);
        Integer pageNum = objCommunityEvents.PageNumber;
        System.assertEquals(pageNum, 1);
        Integer intTotPages = objCommunityEvents.TotalPages;
        System.assertEquals(intTotPages, 0);
        Integer SpecifiedPageNumber = 1;  
        objCommunityEvents.prevSet();
        objCommunityEvents.nextSet();
        objCommunityEvents.GoToPage();
        String TodayString = objCommunityEvents.TodayString;
        objCommunityEvents.SaveCurrentToCookie();
        Integer withinDistance  = objCommunityEvents.withinDistance;
        String FilterString = objCommunityEvents.FilterString;
        objCommunityEvents.ScheduledContentType = 'DemoEvent';
        objCommunityEvents.locationString = '98092';
        objCommunityEvents.withinDistance = 10;
        objCommunityEvents.Filter();
        objCommunityEvents.SpecifiedPageNumber = 1;
        objCommunityEvents.GoToPage();
        objCommunityEvents.setController = null; 
        setController = objCommunityEvents.setController;
    }
}