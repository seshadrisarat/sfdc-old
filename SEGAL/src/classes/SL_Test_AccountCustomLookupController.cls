/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_Test_AccountCustomLookupController 
{
    static testMethod void myUnitTest() 
    {
    	// Preparing test data
    	List<Account> lstAccts = new List<Account>{new Account(Name = 'Test Account'),
    											   new Account(Name = 'Test Account-01'),
    											   new Account(Name = 'Test Account-02')};
    	insert lstAccts;
    	
    	// Initiating Standard controller
    	ApexPages.StandardController  controller = new ApexPages.StandardController(lstAccts[0]);
        SL_AccountCustomLookUpController objAccountCustLookUp = new SL_AccountCustomLookUpController(controller);
        objAccountCustLookUp.strSearchText = 'Test';
        objAccountCustLookUp.searchResult();
        // Verifying expected results.
        system.assertEquals(objAccountCustLookUp.lstAccounts.size(),3);
    }
}