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
private class SL_Test_EventHandler 
{

    static testMethod void myUnitTest() 
    {   
        
		Division__c objDivision = new Division__c(Name='test');
		insert objDivision;
        
        Territory__c objTerritory = new Territory__c(Name='TestTerriority', Division__c = objDivision.Id);
		insert objTerritory;
        
        Account objAccount = new Account(LastName = 'Test Account', Territory__c = objTerritory.Id);
        insert objAccount;
        
        List<Opportunity> lstOpportunity = new List<Opportunity>{
        															new Opportunity(Name = 'Test Opportunity1', CloseDate = Date.today(), StageName='Open', AccountId = objAccount.Id, Territory__c = objTerritory.Id, HHAU__c = 'Email'),
        															new Opportunity(Name = 'Test Opportunity2', CloseDate = Date.today(), StageName='Open', AccountId = objAccount.Id, Territory__c = objTerritory.Id, HHAU__c = 'Email')
        														};
        insert lstOpportunity;
        
        List<Event> lstEvent = new List<Event>{
        											new Event(Subject = 'Call', ActivityDate = Date.today(), StartDateTime = Date.today(), EndDateTime = Date.today() + 1, WhatId = lstOpportunity[0].Id, Meeting_Type__c = 'Customer Appointment'),
        											new Event(Subject = 'Email', ActivityDate = Date.today(), StartDateTime = Date.today(), EndDateTime = Date.today() + 1, WhatId = lstOpportunity[0].Id, Meeting_Type__c = 'Customer Appointment'),
        											new Event(Subject = 'Call', ActivityDate = Date.today(), StartDateTime = Date.today(), EndDateTime = Date.today() + 1, WhatId = lstOpportunity[1].Id, Meeting_Type__c = 'Customer Appointment'),
        											new Event(Subject = 'Email', ActivityDate = Date.today(), StartDateTime = Date.today(), EndDateTime = Date.today(), WhatId = lstOpportunity[1].Id, Meeting_Type__c = 'Customer Appointment')
        									  };
        insert lstEvent;
        
        List<Event> lstEventToUpdate = new List<Event>{
        											  	 new Event(Id = lstEvent[0].Id, Subject = 'Meeting'),
        											  	 new Event(Id = lstEvent[2].Id, Subject = 'Other')
        											  };
        update lstEventToUpdate;
        
        List<Event> lstEventToDelete = new List<Event>{
        											  	 new Event(Id = lstEvent[0].Id),
        											  	 new Event(Id = lstEvent[2].Id)
        											  };
        delete lstEventToDelete;
        
        lstEvent[3].Appointment_Status__c='Canceled';
        update lstEvent[3];
    }
}