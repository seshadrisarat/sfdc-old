/**
 
* \author Volodymyr Babin
 
* \date 08/12/2014
 
* \see http://silverline.jira.com/browse/LIB-226
 
* \brief Tests SL_GenUtils.cls
 
*/
@isTest
public with sharing class SL_Test_GenUtils {
    static testMethod void testFieldSets() {
        Test.startTest();
        
        // Test getFieldSetFlds()
        System.assertEquals(null, SL_GenUtils.getFieldSetFlds('NoSuchFieldSet', 'Account'));
        
        Test.stopTest();
    }
}