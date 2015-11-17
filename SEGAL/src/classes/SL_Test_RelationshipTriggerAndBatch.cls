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
public  class SL_Test_RelationshipTriggerAndBatch 
{
	static testMethod void testRelationshipTriggerAndBatch()
	{
	    Id ENTITY_TO_ENTITY_RECORDTYPEID = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationships__c' AND DeveloperName ='Entity_to_Entity'].ID;
	    
		///Insert account records
		Account objAccount1 = new Account(Name = 'Test Account 1');
		insert objAccount1;
		
		Account objAccount2 = new Account(Name = 'Test Account 2');
		insert objAccount2;
		
		Account objAccount3 = new Account(Name = 'Test Account 3');
		insert objAccount3;
		
		test.startTest();
		///Insert relationship record
		Relationships__c objRelationships = new Relationships__c(RecordTypeId = ENTITY_TO_ENTITY_RECORDTYPEID, Entity1__c = objAccount1.Id, Entity2__c = objAccount2.Id);
		insert objRelationships;
		
		///Check if a reciprocal relationship record is created
		system.assertEquals([SELECT ID FROM Relationships__c WHERE Entity1__c =: objRelationships.Entity2__c AND Entity2__c =: objRelationships.Entity1__c].size(), 1);
		
		///Check if the recordtype of the created reciprocal record is same as the one from which it is created
		system.assertEquals([SELECT RecordTypeId FROM Relationships__c WHERE Entity1__c =: objRelationships.Entity2__c AND Entity2__c =: objRelationships.Entity1__c].RecordTypeId, ENTITY_TO_ENTITY_RECORDTYPEID);
	
		///Check if Primary_Reciprocal_Relationship_Id__c field is populated correctly 
		system.assertEquals([SELECT Primary_Reciprocal_Relationship_Id__c FROM Relationships__c WHERE Entity1__c =: objRelationships.Entity2__c AND Entity2__c =: objRelationships.Entity1__c].Primary_Reciprocal_Relationship_Id__c, objRelationships.Id);
	
		objRelationships.Entity1__c = objAccount3.Id;
		update  objRelationships;
		
		delete objRelationships;
		
		///Check if a reciprocal relationship record is deleted
		system.assertEquals([SELECT ID FROM Relationships__c WHERE Entity1__c =: objRelationships.Entity2__c AND Entity2__c =: objRelationships.Entity1__c].size(), 0);
		
		database.executeBatch(new SL_BatchToCreateReciprocalRelationships());
		
		test.stopTest();
	}
}