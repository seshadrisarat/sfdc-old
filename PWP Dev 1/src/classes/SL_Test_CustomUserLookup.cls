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
private class SL_Test_CustomUserLookup {

    static testMethod void myUnitTest() 
    {
    	Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
    	List<User> lstUser = new List<User>{
	    						new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing', 
	    								 LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
	    								 TimeZoneSidKey='America/Los_Angeles', UserName='use12121r211.79874@user.com'),
	    						new User(Alias = 'User2', Email='user3424@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', 
	    								 LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
	    								 TimeZoneSidKey='America/Los_Angeles', UserName='user5461wwerer.79874@user.com')
    							};		 
        insert lstUser;
    	Account objAccount = new Account(Name='TestAccount');
    	insert objAccount;
    	
    	ApexPages.StandardController  controller = new ApexPages.StandardController(lstUser[0]);
        SL_UserCustomLookupController objStoneCustLook = new SL_UserCustomLookupController(controller);
        objStoneCustLook.strSearchText = 'Test';
        objStoneCustLook.searchResult();
    }
}