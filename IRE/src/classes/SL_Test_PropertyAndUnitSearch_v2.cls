/**
* \arg ClassName      : SL_Test_PropertyAndUnitSearch_v2
* \arg JIRATicket     : IRE-165
* \arg CreatedOn      : 10/SEPT/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_PropertyAndUnitSearchController_v2 class for checking the functionality of search filters.
*/
@isTest
private class SL_Test_PropertyAndUnitSearch_v2 
{
    static testMethod void test_FilterElements() 
    {
        Test.startTest();
        SL_PropertyAndUnitSearchController_v2 objPropertyAndUnitSearchController_v2 = new SL_PropertyAndUnitSearchController_v2();
        Test.stopTest();
        
        System.assertEquals(13,objPropertyAndUnitSearchController_v2.lstFilterElements.size());
    }
    
    static testMethod void test_PicklistValues()
    {
    	Test.startTest();
        new SL_PropertyAndUnitSearchController_v2().getPicklistOptions();
        Test.stopTest();
    }
}