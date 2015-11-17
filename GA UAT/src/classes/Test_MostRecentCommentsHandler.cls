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
private class Test_MostRecentCommentsHandler {

    static testMethod void myUnitTest()
    {
    	MostRecentCommentsHandler objHandler = new MostRecentCommentsHandler();
		
		Account objAccount = new Account();
		objAccount.Name = 'TestAccount';
		objAccount.Status__c = 'Monitor';
		objAccount.Source__c = 'Other';
		objAccount.Description = 'TestAccount';
		objAccount.Nearest_Metropolitan_City__c = 'Bangalore';
		insert objAccount;
		
		Event objEvent1 = new Event();
		objEvent1.Subject = 'TestEvent-02';
		objEvent1.Type = 'Other';
		objEvent1.StartDateTime = Date.today();
		objEvent1.EndDateTime = Date.today()+1;
		objEvent1.WhatId = objAccount.Id;
		objEvent1.Description = 'TestEvent-02';
		insert objEvent1;
		
		Task objTask1 = new Task();
		objTask1.Subject = 'TestTask-02';
		objTask1.Type = 'Status Note';
		objTask1.Status = 'Completed';
		objTask1.Priority = 'Normal';
		objTask1.ActivityDate = Date.today()-1;
		objTask1.WhatId = objAccount.Id;
		objTask1.Description = 'TestTask-02';
		insert objTask1;
		
		objEvent1.Description = 'Test1';
		objEvent1.ActivityDate = Date.today()+4;
		update objEvent1;
		
		objTask1.ActivityDate = date.today()+5;
		update objTask1;
		
		delete objTask1;
		delete objEvent1;
    }
}