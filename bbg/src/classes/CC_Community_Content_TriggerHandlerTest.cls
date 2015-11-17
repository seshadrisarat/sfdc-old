@isTest
private class CC_Community_Content_TriggerHandlerTest {

    static testMethod void myUnitTest() {
        
      
        List<CORECONNECT__CC_Community_Content__c> lstCommunityContent = new List<CORECONNECT__CC_Community_Content__c>{
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-01',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98001 Test',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-02',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98001',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-03',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98002',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-04',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98002',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-05',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-06',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-07',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98071',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-08',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-09',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10)),
                                                                                                                            new CORECONNECT__CC_Community_Content__c(Name = 'CommunityContent-10',
                                                                                                                                                                     CORECONNECT__Location__c = 'Auburn',
                                                                                                                                                                     CORECONNECT__Location_Postal_Code__c = '98092',
                                                                                                                                                                     CORECONNECT__Location_Country__c = 'King',
                                                                                                                                                                     CORECONNECT__Location_State_Province__c = 'Washington',
                                                                                                                                                                     CORECONNECT__Start_Date__c = Date.today(),
                                                                                                                                                                     CORECONNECT__End_Date__c = Date.today().addDays(10))};
        insert lstCommunityContent;   
        System.assertEquals(lstCommunityContent.size(),10);
        
        lstCommunityContent[0].CORECONNECT__Location_Postal_Code__c = '98092 Test';
        lstCommunityContent[1].CORECONNECT__Location_Postal_Code__c = '98002';
        lstCommunityContent[2].CORECONNECT__Location_Postal_Code__c = '';
        lstCommunityContent[3].CORECONNECT__Location_Postal_Code__c = '98092';
        lstCommunityContent[4].CORECONNECT__Location_Postal_Code__c = '98092';
        lstCommunityContent[5].CORECONNECT__Location_Postal_Code__c = '98002';
        lstCommunityContent[6].CORECONNECT__Location_Postal_Code__c = '98002';
        lstCommunityContent[7].CORECONNECT__Location_Postal_Code__c = '98071';
        lstCommunityContent[8].CORECONNECT__Location_Postal_Code__c = '98071';
        lstCommunityContent[9].CORECONNECT__Location_Postal_Code__c = '98071';
        
        update lstCommunityContent;
        
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
        
        lstCommunityContent[0].CORECONNECT__Location_Postal_Code__c = '98001';
        lstCommunityContent[1].CORECONNECT__Location_Postal_Code__c = '98001';
        lstCommunityContent[2].CORECONNECT__Location_Postal_Code__c = '98092';
        lstCommunityContent[3].CORECONNECT__Location_Postal_Code__c = '98002';
        lstCommunityContent[4].CORECONNECT__Location_Postal_Code__c = '98002';
        lstCommunityContent[5].CORECONNECT__Location_Postal_Code__c = '98092';
        lstCommunityContent[6].CORECONNECT__Location_Postal_Code__c = '98002';
        lstCommunityContent[7].CORECONNECT__Location_Postal_Code__c = '98071';
        lstCommunityContent[8].CORECONNECT__Location_Postal_Code__c = '98071';
        lstCommunityContent[9].CORECONNECT__Location_Postal_Code__c = '98092';
        
        update lstCommunityContent;
        
        
        System.assertEquals([SELECT Id FROM CORECONNECT__CC_Community_Content__c WHERE CORECONNECT__Location_Geocode__Latitude__s != null].size(), 10);
    }
}