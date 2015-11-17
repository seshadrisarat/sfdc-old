/**
* \arg ClassName      : SL_Test_CustomSearchFeature
* \arg JIRATicket     : STARGAS-30
* \arg CreatedOn      : 27/Oct/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class used to check the functionality of SL_CustomSearchFeature controller.
*/
@isTest
private class SL_Test_CustomSearchFeature 
{
    static final String strOilRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Oil' AND SobjectType =: 'Price_Table__c' LIMIT 1].Id;
    static Division__c objDivision;
    static List<Territory__c> lstTerritory;
    static List<Price_Table__c> lstPriceTable;
    static List<Services_by_Location__c> lstServiceChart;
    
    //method to prepare test data
    static void createTestData()
    {
    	DivOilPriceGrp__c objDivOilPriceGrp = new DivOilPriceGrp__c(Name = 'Test Div Oil');
    	insert objDivOilPriceGrp;
    	
    	objDivision = new Division__c(Name='test', Division__c ='41', Database__c = '10',State__c = 'CT', Division_Oil_Pricing_Group__c = '1', Service_Company__c = 'Burke Heat', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id);
    	insert objDivision;
    	
    	lstTerritory = new List<Territory__c>{	
    												new Territory__c(Name='TestTerriority1', Division__c = objDivision.Id, Zip_Postal_Code__c = '11401',City__c = 'New York'),
    												new Territory__c(Name='TestTerriority2', Division__c = objDivision.Id, Zip_Postal_Code__c = '11401',City__c = 'Los Angeles')
    										 };
        insert lstTerritory;
        
        lstPriceTable = new List<Price_Table__c>{
        											new Price_Table__c(Price_Type__c = '12 Mo - Fixed', Fixed_Price__c = 1200, Division_Group__c = '1', RecordTypeId = strOilRecordTypeId, Service_Company__c = 'Burke Heat'),
        											new Price_Table__c(Price_Type__c = 'Min Ceiling', Ceiling_Limit__c = 1100, Division_Group__c = '1', RecordTypeId = strOilRecordTypeId, Service_Company__c = 'Burke Heat'),
        											new Price_Table__c(Price_Type__c = 'Ceiling with fee', Ceiling_Fee__c = 1000, Division_Group__c = '1', RecordTypeId = strOilRecordTypeId, Service_Company__c = 'Burke Heat'),
        											new Price_Table__c(Price_Type__c = 'Min Ceiling', Ceiling_Initial__c = 900, Division_Group__c = '1', RecordTypeId = strOilRecordTypeId, Service_Company__c = 'Burke Heat'),
        											new Price_Table__c(Price_Type__c = 'Variable', Variable_Price__c = 800, Division_Group__c = '1', RecordTypeId = strOilRecordTypeId, Service_Company__c = 'Burke Heat')
        										};
        insert lstPriceTable;
        
        lstServiceChart = new List<Services_by_Location__c>{
        														new Services_by_Location__c(Name = 'Test 1', A_C_Service__c = 'Yes', State__c = 'CT'),
        														new Services_by_Location__c(Name = 'Test 1', Security__c = 'Meenan', State__c = 'CT')
        												   };
        insert lstServiceChart;
    }
    
    //Method to check the functionality of company division - city picklist
    static testMethod void checkForPicklistValues() 
    {
       createTestData();
       SL_CustomSearchFeature objCustomSearchFeature = new SL_CustomSearchFeature();
       objCustomSearchFeature.strZipCode = '11401';
       
       Test.startTest();
       SL_CustomSearchFeature.getDivision('11401');
       Test.stopTest();
    }
    
    //Method to check the functionality of search functionality
    static testmethod void checkForsearch()
    {
    	createTestData();
        SL_CustomSearchFeature objCustomSearchFeature = new SL_CustomSearchFeature();
        objCustomSearchFeature.strZipCode = '11401';
        objCustomSearchFeature.strDivisionCity = 'Burke Heat ### test ### New York ### CT';
        
        Test.startTest();
        objCustomSearchFeature.searchRecords();
        Test.stopTest();
        
        System.assertEquals(objCustomSearchFeature.lstServicesbyLocation.size(), 2);
        System.assertEquals(objCustomSearchFeature.objPriceTable.Variable_Price__c, 800);
        System.assertEquals(objCustomSearchFeature.objPriceTable.Fixed_Price__c, 1200);
        System.assertEquals(objCustomSearchFeature.objPriceTable.Ceiling_Limit__c, 1100);
    }
    
    //Method to check the functionality of blank zip code
    static testMethod void checkForBlankZipCode()
    {
    	createTestData();
    	SL_CustomSearchFeature objCustomSearchFeature = new SL_CustomSearchFeature();
        objCustomSearchFeature.strZipCode = '';
        
        Test.startTest();
        objCustomSearchFeature.searchRecords();
        Test.stopTest();
        
        System.assertEquals(objCustomSearchFeature.lstServicesbyLocation.size(), 0);
    }
}