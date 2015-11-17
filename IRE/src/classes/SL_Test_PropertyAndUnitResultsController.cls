/**
* \arg ClassName      : SL_Test_PropertyAndUnitResultsController
* \arg JIRATicket     : IRE-165
* \arg CreatedOn      : 10/SEPT/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_PropertyAndUnitResultsController class for checking the functionality of results that are yielded by performing search operation.
*/
@isTest
private class SL_Test_PropertyAndUnitResultsController 
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
    	SL_PropertyAndUnitResultsController objPropertyAndUnitResults = new SL_PropertyAndUnitResultsController();
    	ApexPages.currentPage().getParameters().putAll(new Map<String,String>{'sortOption'=>'--','selectedVal'=>'PropertyAndUnits','searchparam'=>'test','propertyWhereClause'=>' WHERE DW_City__c like '+'\'%test%' +'\'', 'unitWhereClause'=>' WHERE Name like '+'\'%test%' +'\''});
    	
    	Test.startTest();
    	objPropertyAndUnitResults.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(2,objPropertyAndUnitResults.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForPropertyWithoutFilters()
    {
    	SL_PropertyAndUnitResultsController objPropertyAndUnitResults = new SL_PropertyAndUnitResultsController();
    	ApexPages.currentPage().getParameters().putAll(new Map<String,String>{'sortOption'=>'--','selectedVal'=>'Properties','searchparam'=>'test city00'});
    	
    	Test.startTest();
    	objPropertyAndUnitResults.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(1,objPropertyAndUnitResults.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForUnitsWithoutFilters()
    {
    	SL_PropertyAndUnitResultsController objPropertyAndUnitResults = new SL_PropertyAndUnitResultsController();
    	ApexPages.currentPage().getParameters().putAll(new Map<String,String>{'sortOption'=>'--','selectedVal'=>'Units','searchparam'=>'for Unit 01'});
    	
    	Test.startTest();
    	objPropertyAndUnitResults.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(1,objPropertyAndUnitResults.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForPropertyAndUnitWithFilters()
    {
    	SL_PropertyAndUnitResultsController objPropertyAndUnitResults = new SL_PropertyAndUnitResultsController();
    	Apexpages.currentPage().getParameters().putAll(new Map<String,String>{'propertyWhereClause'=>' WHERE DW_City__c like '+'\'%test%' +'\'', 'unitWhereClause'=>' WHERE Name like '+'\'%test%' +'\'', 'sortOption'=>'--','selectedVal'=>'PropertyAndUnits','searchparam'=>''});
    	
    	Test.startTest();
    	objPropertyAndUnitResults.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(2,objPropertyAndUnitResults.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForPropertyAndUnitWithFiltersForUnits()
    {
    	SL_PropertyAndUnitResultsController objPropertyAndUnitResults = new SL_PropertyAndUnitResultsController();
    	Apexpages.currentPage().getParameters().putAll(new Map<String,String>{'propertyWhereClause'=>'', 'unitWhereClause'=>' WHERE Name like '+'\'%test%' +'\'', 'sortOption'=>'--','selectedVal'=>'PropertyAndUnits','searchparam'=>''});
    	
    	Test.startTest();
    	objPropertyAndUnitResults.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(2,objPropertyAndUnitResults.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForUnitWithFilters()
    {
    	SL_PropertyAndUnitResultsController objPropertyAndUnitResults = new SL_PropertyAndUnitResultsController();
    	Apexpages.currentPage().getParameters().putAll(new Map<String,String>{'propertyWhereClause'=>' WHERE DW_City__c like '+'\'%test%' +'\'', 'unitWhereClause'=>' WHERE Name like '+'\'%test%' +'\'', 'sortOption'=>'--','selectedVal'=>'Units','searchparam'=>''});
    	
    	Test.startTest();
    	objPropertyAndUnitResults.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(4,objPropertyAndUnitResults.lstRecordWrapper.size());
    }
    
    static testMethod void test_SearchForPropertyWithFilters()
    {
    	SL_PropertyAndUnitResultsController objPropertyAndUnitResults = new SL_PropertyAndUnitResultsController();
    	Apexpages.currentPage().getParameters().putAll(new Map<String,String>{'propertyWhereClause'=>' WHERE DW_City__c like '+'\'%test%' +'\'', 'unitWhereClause'=>' WHERE Name like '+'\'%test%' +'\'', 'sortOption'=>'--','selectedVal'=>'Properties','searchparam'=>''});
    	
    	Test.startTest();
    	objPropertyAndUnitResults.fetchRecords();
    	Test.stopTest();
    	
    	System.assertEquals(2,objPropertyAndUnitResults.lstRecordWrapper.size());
    } 
}