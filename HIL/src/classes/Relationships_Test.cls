/*
    Silverline modified an existing package to fit the business requirements of Hilliard Lyons.
    Code modifications include additions and removal of elements from the following package:
    https://github.com/SalesforceFoundation/Relationships/. See link for details about original code.
*/

/**
* \arg ClassName      		: Relationships_Test
* \arg JIRATicket       	: HIL-9
* \arg CreatedOn        	: 16/DEC/2013
* \arg LastModifiedOn   	: 16/MAR/2015
* \arg CreatededBy      	: -
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description      	: This class serves as test class to check the functionality for Relationship trigger on create, update, delete and undelete events.
*/
@isTest
private class Relationships_Test {
    
    private static Account a1;
    private static Account a2;

    // instantiates test data for relationship type matches, accounts to build relationships between
    private static void setupRelationshipTestData() {

        System.runAs(new User(id = UserInfo.getUserId())) {

            insert new Relationship_Type_Mapping__c(Name = 'Test1', Matching_Type__c = '1Test');
            insert new Relationship_Type_Mapping__c(Name = 'Test2', Matching_Type__c = '2Test');

            a1 = new Account(Name = 'Test Account 1');
            insert a1;
            
            a2 = new Account(Name = 'Test Account 2');
            insert a2;
        }
    }

    static testMethod void testAccountRel() {

        setupRelationshipTestData();

        Relationship__c rel = new Relationship__c(
            Account__c = a1.id,
            Related_Account__c = a2.id,
            Type__c = 'Test Type',
            Status__c = 'Current');

        insert rel;
        
        Relationship__c rel1 = new Relationship__c(
            Account__c = a1.id,
            Type__c = 'Test Type',
            Status__c = 'Current');

        insert rel1;

        List<Relationship__c> relList = new List<Relationship__c>();
        relList = [SELECT Id, Account__c, Related_Account__c, ReciprocalRelationship__c, Type__c, Status__c
                   FROM Relationship__c WHERE Id = :rel.Id LIMIT 1];

        List<Relationship__c> mirrorList = new List<Relationship__c>();
        mirrorList = [SELECT Id, Account__c, Related_Account__c, ReciprocalRelationship__c, Type__c, Status__c
                      FROM Relationship__c WHERE ReciprocalRelationship__c = :relList[0].Id LIMIT 1];

        // ensures that both reference one another via lookup
        System.assertEquals(relList[0].ReciprocalRelationship__c, mirrorList[0].Id);
        System.assertEquals(mirrorList[0].ReciprocalRelationship__c, relList[0].Id);

        // ensures that Type is the same as this is not included in Relationship Type Mapping above
        System.assertEquals(relList[0].Type__c, 'Test Type');
        System.assertEquals(mirrorList[0].Type__c, 'Test Type');

        // change relationship record to test whether the reciprocal Type has changed as well
        relList[0].Type__c = 'Test Type 2';
        relList[0].Status__c = 'Former';

        Test.startTest();
        update relList[0];
        Test.stopTest();

        Relationship__c updatedOriginal = [SELECT Id, Account__c, Related_Account__c, Type__c, Status__c, ReciprocalRelationship__c
                                           FROM Relationship__c WHERE Id = :relList[0].Id LIMIT 1];

        // ensures that relList[0] Type and Status changed accordingly
        System.assertEquals('Test Type 2', updatedOriginal.Type__c);
        System.assertEquals('Former', updatedOriginal.Status__c);

        Relationship__c updatedMirror = [SELECT Id, Account__c, Related_Account__c, Type__c, Status__c, ReciprocalRelationship__c
                                         FROM Relationship__c WHERE ReciprocalRelationship__c = :relList[0].Id LIMIT 1];

        System.assertEquals('Test Type 2', updatedMirror.Type__c);
        System.assertEquals('Former', updatedMirror.Status__c);

        delete updatedOriginal;

        // ensures that reciprocal relationship was deleted due to original relationship deletion
        List<Relationship__c> mirrorDelete = [SELECT Id FROM Relationship__c WHERE ReciprocalRelationship__c = :rel.Id];
        System.assertEquals(0, mirrorDelete.size());

    }

    static testMethod void testRelTypeMatch() {

        setupRelationshipTestData();

        Relationship__c rel = new Relationship__c(
            Account__c = a1.id,
            Related_Account__c = a2.id,
            Type__c = 'Test1',
            Status__c = 'Current');

        insert rel;

        List<Relationship__c> relList = new List<Relationship__c>();
        relList = [SELECT Id, Account__c, Related_Account__c, Type__c, Status__c
                   FROM Relationship__c WHERE Id = :rel.Id LIMIT 1];

        List<Relationship__c> mirrorList = new List<Relationship__c>();
        mirrorList = [SELECT Id, Account__c, Related_Account__c, Type__c, Status__c
                      FROM Relationship__c WHERE ReciprocalRelationship__c = :relList[0].Id LIMIT 1];

        

        relList[0].Type__c = 'Test2';

        Test.startTest();
        update relList[0];
        Test.stopTest();

        Relationship__c updatedOriginal = [SELECT Id, Account__c, Related_Account__c, Type__c, Status__c, ReciprocalRelationship__c
                                           FROM Relationship__c WHERE Id = :relList[0].Id LIMIT 1];


        Relationship__c updatedMirror = [SELECT Id, Account__c, Related_Account__c, Type__c, Status__c, ReciprocalRelationship__c
                                         FROM Relationship__c WHERE ReciprocalRelationship__c = :relList[0].Id LIMIT 1];

        //System.assertEquals('2Test', updatedMirror.Type__c);

    }

    static testMethod void testOrphanedRelDelete() {

        setupRelationshipTestData();

        Relationship__c rel = new Relationship__c(
            Account__c = a1.id,
            Related_Account__c = a2.id,
            Type__c = 'Test Type',
            Status__c = 'Current');

        insert rel;

        Relationship__c[] relOriginal = [SELECT Id, Account__c, Related_Account__c, ReciprocalRelationship__c, Type__c, Status__c FROM Relationship__c WHERE Id = :rel.Id];
        System.assertEquals(relOriginal[0].Type__c, 'Test Type');

        Relationship__c[] relMirror = [SELECT Id, Account__c, Related_Account__c, ReciprocalRelationship__c, Type__c, Status__c FROM Relationship__c WHERE ReciprocalRelationship__c = :relOriginal[0].Id];
        System.assertEquals(relOriginal[0].Id, relMirror[0].ReciprocalRelationship__c);

        Account[] delAccount = [SELECT Id FROM Account WHERE Id = :a2.Id];

        Test.startTest();
        delete delAccount;
        Test.stopTest();

        Relationship__c[] orphan = [SELECT Id FROM Relationship__c WHERE Id = :relOriginal[0].Id];
        System.assertEquals(0, orphan.size());

    }

    static testMethod void testRelDelete() {

        setupRelationshipTestData();

        Relationship__c rel = new Relationship__c(
            Account__c = a1.id,
            Related_Account__c = a2.id,
            Type__c = 'Test Type',
            Status__c = 'Current');

        insert rel;

        Relationship__c[] relOriginal = [SELECT Id, Account__c, Related_Account__c, ReciprocalRelationship__c, Type__c, Status__c FROM Relationship__c WHERE Id = :rel.Id];
        System.assertEquals(relOriginal[0].Type__c, 'Test Type');

        Relationship__c[] relMirror = [SELECT Id, Account__c, Related_Account__c, ReciprocalRelationship__c, Type__c, Status__c FROM Relationship__c WHERE ReciprocalRelationship__c = :relOriginal[0].Id];
        System.assertEquals(relOriginal[0].Id, relMirror[0].ReciprocalRelationship__c);

        Test.startTest();
        delete relOriginal;
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM Relationship__c WHERE Id = :relMirror[0].Id]);

    }
    
    static testMethod void testRelUndelete()
    {
    	 setupRelationshipTestData();
    	 Relationship__c rel = new Relationship__c(Account__c = a1.id, Related_Account__c = a2.id, Type__c = 'Test Type', Status__c = 'Current');
         insert rel;
         
         System.assertEquals(1, [SELECT COUNT() FROM Relationship__c WHERE ReciprocalRelationship__c =:rel.Id]);
         
         delete rel;
         
         System.assertEquals(0, [SELECT COUNT() FROM Relationship__c WHERE ReciprocalRelationship__c =:rel.Id]);
         
         Test.startTest();
         undelete rel;
         Test.stopTest();
         
         System.assertEquals(1, [SELECT COUNT() FROM Relationship__c WHERE ReciprocalRelationship__c =:rel.Id]);
    }
}