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
public with sharing class SL_TestLeadHandler 
{
    static testMethod void testLeadHandler() 
    {
    	///Create a lead record
		Lead objLead = new Lead
    	(
    		LastName = 'Test Lead 1',
    		Email = 'test@testLead1.com',
    		Applicant_1_Last_Name__c = 'Applicant-1',
    		Applicant_2_Last_Name__c = 'Applicant-2',
    		Applicant_3_Last_Name__c = 'Applicant-3',
    		Applicant_4_Last_Name__c = 'Applicant-4'
    	);
    	
    	///Insert Lead record
    	insert objLead;
    	
    	///Convert the lead
    	test.StartTest();
    	Database.LeadConvert objLeadConvert = new database.LeadConvert();
   		objLeadConvert.setLeadId(objLead.Id);
   		LeadStatus objLeadConvertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
   		objLeadConvert.setConvertedStatus(objLeadConvertStatus.MasterLabel);
   		Database.LeadConvertResult objLeadConvertResult = Database.convertLead(objLeadConvert);
   		test.StopTest();
   		
   		///Get the id of converted opportunity
   		Id convertedOpportunityId = objLeadConvertResult.getOpportunityId();
   		
   		///Get the id of converted contact
   		Id convertedContactId = objLeadConvertResult.getContactId();
   		
   		///Check if a new contact role record is created linking converted opportunity and conatct
    	/*  AND Contact__c =: convertedContactId */
    	system.assertEquals([SELECT Id FROM Contact_Role__c WHERE Opportunity__c =: convertedOpportunityId].size(), 5);
    }
}