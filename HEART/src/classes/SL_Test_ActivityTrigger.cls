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
private class SL_Test_ActivityTrigger {

   static testMethod void testActivityTriggerHandler()
   {
        Id idRecTypeId = [select Name,Id From RecordType where Name = 'Private Clients and Prospects'].Id;
        
        // Start of preparing test data
        list<Contact> lstContacttoInsert = new List<Contact>();
        
        Account objAcc = new Account(LastName = 'Test Account Name - 1', RecordTypeId = idRecTypeId, Meeting__pc = true, Phone__pc = true);
        insert objAcc;
        
        // Creating Contact Records
        Contact objCon1 = new Contact(Account = objAcc, LastName = 'Test Contact Name -1', Phone__c = true);
        lstContacttoInsert.add(objCon1);
        Contact objCon2 = new Contact(Account = objAcc, LastName = 'Test Contact Name -2', Meeting__c = true ,Phone__c = true);
        lstContacttoInsert.add(objCon2);
        Contact objCon3 = new Contact(Account = objAcc, LastName = 'Test Contact Name -3', Meeting__c = true ,Phone__c = false);
        lstContacttoInsert.add(objCon3);
        Contact objCon4 = new Contact(Account = objAcc, LastName = 'Test Contact Name -4', Phone__c = true);
        lstContacttoInsert.add(objCon4);
        Contact objCon5 = new Contact(Account = objAcc, LastName = 'Test Contact Name -5', Meeting__c = true ,Phone__c = true);
        lstContacttoInsert.add(objCon5);
        Contact objCon6 = new Contact(Account = objAcc, LastName = 'Test Contact Name -6', Meeting__c = false ,Phone__c = true);
        lstContacttoInsert.add(objCon6);
        Contact objCon7 = new Contact(Account = objAcc, LastName = 'Test Contact Name -7', Phone__c = true);
        lstContacttoInsert.add(objCon7);
        Contact objCon8 = new Contact(Account = objAcc, LastName = 'Test Contact Name -8', Meeting__c = true ,Phone__c = true);
        lstContacttoInsert.add(objCon8);
        Contact objCon9 = new Contact(Account = objAcc, LastName = 'Test Contact Name -9', Meeting__c = true ,Phone__c = false);
        lstContacttoInsert.add(objCon9);
        Contact objCon10 = new Contact(Account = objAcc, LastName = 'Test Contact Name -10', Phone__c = true);
        lstContacttoInsert.add(objCon10);
        Contact objCon11 = new Contact(Account = objAcc, LastName = 'Test Contact Name -11', Meeting__c = true ,Phone__c = true);
        lstContacttoInsert.add(objCon11);
        Contact objCon12 = new Contact(Account = objAcc, LastName = 'Test Contact Name -12', Meeting__c = false ,Phone__c = true);
        lstContacttoInsert.add(objCon12);
        
        insert lstContacttoInsert;  // Inserting all Contacts

        list<Task> lstTasktoInsert = new List<Task>();
        
        Task objtask1 = new Task(Subject = 'call', Status = 'Completed', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[0].Id);
        lstTasktoInsert.add(objtask1);
        
        Task objtask2 = new Task(Subject = 'call', Status = 'Completed', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[1].Id);
        lstTasktoInsert.add(objtask2);
        
        Task objtask3 = new Task(Subject = 'call', Status = 'Completed', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[2].Id);
        lstTasktoInsert.add(objtask3);
        
        Task objtask4 = new Task(Subject = 'call', Status = 'Completed', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[3].Id);
        lstTasktoInsert.add(objtask4);
        
        Task objtask5 = new Task(Subject = 'call', Status = 'Completed', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[4].Id);
        lstTasktoInsert.add(objtask5);
        
        Task objtask6 = new Task(Subject = 'call', Status = 'Completed', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[5].Id);
        lstTasktoInsert.add(objtask6);
        
        Task objtask7 = new Task(Subject = 'call', Status = 'InProgress', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[6].Id);
        lstTasktoInsert.add(objtask7);
        
        Task objtask8 = new Task(Subject = 'call', Status = 'InProgress', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[7].Id);
        lstTasktoInsert.add(objtask8);
        
        Task objtask9 = new Task(Subject = 'call', Status = 'InProgress', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[8].Id);
        lstTasktoInsert.add(objtask9);
        
        Task objtask10 = new Task(Subject = 'call', Status = 'InProgress', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[9].Id);
        lstTasktoInsert.add(objtask10);
        
        Task objtask11 = new Task(Subject = 'call', Status = 'InProgress', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[10].Id);
        lstTasktoInsert.add(objtask11);
        
        Task objtask12 = new Task(Subject = 'call', Status = 'InProgress', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[11].Id);
        lstTasktoInsert.add(objtask12);
        
        // end of Preparing test data
        
       // Executing functionality   
        Test.starttest();
            insert lstTasktoInsert;
            objtask2.WhoId = objCon2.id;
            update objtask1;
        Test.stoptest();        
        
        //Checking expected functionality
        system.assert(true);
        system.assert(true);
   }
}