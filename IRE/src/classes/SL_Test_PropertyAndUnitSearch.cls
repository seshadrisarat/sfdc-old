/**
* \arg ClassName      : SL_Test_PropertyAndUnitSearch
* \arg JIRATicket     : IRE-120
* \arg CreatedOn      : 10/AUG/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_PropertyAndUnitSearchController class to check the functionality.
*/
@isTest
private class SL_Test_PropertyAndUnitSearch 
{
    @testSetup
    static void setupDate() 
    {
        List<Property__c> lstProperty = new List<Property__c>{
        														 new Property__c(Name = 'Test Property 01', Comments__c = 'Test Comments 01', DW_City__c = 'Test City00', Property_Image__c = '<img href="test11"/>'),
        														 new Property__c(Name = 'Test Property 02', Comments__c = 'Test Comments 02', DW_City__c = 'Test City', Property_Image__c = '<img href="test23"/>')
        													 };
    	insert lstProperty;
    	
    	List<Unit__c> lstUnit = new List<Unit__c>{
    												 new Unit__c(Name = 'Test Unit 01', Property__c = lstProperty[0].Id, Comments__c = 'Test Comments for Unit 01', Unit_Image__c = '<img href="test"/>'),
    												 new Unit__c(Name = 'Test Unit 02', Property__c = lstProperty[0].Id, Comments__c = 'Test Comments for Unit 02', Unit_Image__c = '<img href="test1"/>'),
    												 new Unit__c(Name = 'Test Unit 01', Property__c = lstProperty[1].Id, Comments__c = 'Test Comments for Unit 03', Unit_Image__c = '<img href="test2"/>'),
    												 new Unit__c(Name = 'Test Unit 02', Property__c = lstProperty[1].Id, Comments__c = 'Test Comments for Unit 04', Unit_Image__c = '<img href="test3"/>')
    											 };
    	insert lstUnit;
    }
    
    static testMethod void test_SearchForPropertyAndUnitWithoutFilters()
    {
    	SL_PropertyAndUnitSearchController objController = new SL_PropertyAndUnitSearchController();
    	 	
    	Test.startTest();
    	objController.getPicklistOptions();
    	Test.stopTest();
    }
    
    /*static testMethod void test_SearchForPropertyWithoutFilters()
    {
    	SL_PropertyAndUnitSearchController objController = new SL_PropertyAndUnitSearchController();
    	
    	objController.strSearchTerm = 'test city00';
    	objController.strSelectedValue = 'Properties';
    	
    	Test.startTest();
    	objController.getPicklistOptions();
    	objController.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(1,objController.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForUnitsWithoutFilters()
    {
    	SL_PropertyAndUnitSearchController objController = new SL_PropertyAndUnitSearchController();
    	
    	objController.strSearchTerm = 'for Unit 01';
    	objController.strSelectedValue = 'Units';
    	
    	Test.startTest();
    	objController.getPicklistOptions();
    	objController.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(1,objController.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForPropertyAndUnitWithFilters()
    {
    	Apexpages.currentPage().getParameters().putAll(new Map<String,String>{'propertyWhereClause'=>' WHERE DW_City__c like '+'\'%test%' +'\'', 'unitWhereClause'=>' WHERE Name like '+'\'%test%' +'\''});
    	SL_PropertyAndUnitSearchController objController = new SL_PropertyAndUnitSearchController();
    	
    	objController.strSearchTerm = '';
    	objController.strSelectedValue = 'PropertyAndUnits';
    	
    	Test.startTest();
    	objController.getPicklistOptions();
    	objController.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(2,objController.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForUnitWithFilters()
    {
    	Apexpages.currentPage().getParameters().putAll(new Map<String,String>{'propertyWhereClause'=>' WHERE DW_City__c like '+'\'%test%' +'\'', 'unitWhereClause'=>' WHERE Name like '+'\'%test%' +'\''});
    	SL_PropertyAndUnitSearchController objController = new SL_PropertyAndUnitSearchController();
    	
    	objController.strSearchTerm = '';
    	objController.strSelectedValue = 'Units';
    	
    	Test.startTest();
    	objController.getPicklistOptions();
    	objController.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(4,objController.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForPropertyWithFilters()
    {
    	Apexpages.currentPage().getParameters().putAll(new Map<String,String>{'propertyWhereClause'=>' WHERE DW_City__c like '+'\'%test%' +'\'', 'unitWhereClause'=>' WHERE Name like '+'\'%test%' +'\''});
    	SL_PropertyAndUnitSearchController objController = new SL_PropertyAndUnitSearchController();
    	
    	objController.strSearchTerm = '';
    	objController.strSelectedValue = 'Properties';
    	
    	Test.startTest();
    	objController.getPicklistOptions();
    	objController.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(2,objController.lstRecordWrapper.size());
    }   */ 
}