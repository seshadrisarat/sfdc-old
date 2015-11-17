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
private class TestAnnualGoalsTriggerHandler {

    static testMethod void testName() 
    {
        AnnualGoals__c ag = new AnnualGoals__c();
        
        ag.Name = 'x';
        ag.Year__c = '2014';
        ag.User__c = UserInfo.getUserId();
        
        insert ag;
        
        ag = [Select Id, Name FROM AnnualGoals__c where Id =: ag.Id];
        
        System.assertEquals('2014 - ' + UserInfo.getName(), ag.Name);
        
    }
    
    static testMethod void testDuplicateRecord()
    {
    	AnnualGoals__c ag = new AnnualGoals__c();
        AnnualGoals__c ag1 = new AnnualGoals__c();
        List<AnnualGoals__c> ags = new List<AnnualGoals__c>();
        
        ag1.Name = ag.Name = 'x';
        ag1.Year__c = ag.Year__c = '2014';
        ag1.User__c = ag.User__c = UserInfo.getUserId();
        
        ags.add(ag);
        ags.add(ag1);
        
        try
    	{
    		insert ags;
			System.assert(false);
    	}
		catch(Exception ex)
		{
			System.assert(true);
		}
		
		insert ag;
		delete ag;
		insert ag1;
		
		try
    	{
    		undelete ag;
			System.assert(false);
    	}
		catch(Exception ex)
		{
			System.assert(true);
		}
    }
}