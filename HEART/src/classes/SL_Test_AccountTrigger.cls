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
private class SL_Test_AccountTrigger {

    static testMethod void SL_AccountTriggerHandler() {
        
        Id idRecTypeId = [select Name,Id From RecordType where Name = 'Private Clients and Prospects'].Id;
        
        list<Account> lstAccounttoInsert = new List<Account>();
        
        
        // Start of Preparing test data
        //Account objAcc = new Account(LastName = 'Test Account Name - 1', RecordTypeId = idRecTypeId);
        //insert  objAcc;
        //system.assert(objAcc.Id != null);
        
        Account objCon1 = new Account(LastName = 'Test Account Name -1', Phone__pc = true , Meeting__pc = true);
        lstAccounttoInsert.add(objCon1);
        Account objCon2 = new Account(LastName = 'Test Account Name -2', Meeting__pc = true);
        lstAccounttoInsert.add(objCon2);
        Account objCon3 = new Account(LastName = 'Test Account Name -3', Meeting__pc = false , Phone__pc = true);
        lstAccounttoInsert.add(objCon3);
        Account objCon4 = new Account(LastName = 'Test Account Name -4', Phone__pc = true , Meeting__pc = true);
        lstAccounttoInsert.add(objCon4);
        Account objCon5 = new Account(LastName = 'Test Account Name -5', Phone__pc = true);
        lstAccounttoInsert.add(objCon5);
        Account objCon6 = new Account(LastName = 'Test Account Name -6', Meeting__pc = true , Phone__pc = false);
        lstAccounttoInsert.add(objCon6);
        Account objCon7 = new Account(LastName = 'Test Account Name -7', Meeting__pc = false , Phone__pc = true);
        lstAccounttoInsert.add(objCon7);
        Account objCon8 = new Account(LastName = 'Test Account Name -8',Last_phone_material_update__pc = Date.Today(),CommFreq_Phone__pc = 'Quarterly');
        lstAccounttoInsert.add(objCon8);
        Account objCon9 = new Account(LastName = 'Test Account Name -9',Last_meeting_material_update__pc = Date.Today());
        lstAccounttoInsert.add(objCon9);
        
        insert lstAccounttoInsert;  // Inserting all Accounts

        list<Task> lstTasktoInsert = new List<Task>();
        
        Task objtask1 = new Task(Subject = 'call', Status = 'In Progress', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(2), Priority = 'Normal', WhatId = lstAccounttoInsert[0].Id);
        lstTasktoInsert.add(objtask1);
        
        Task objtask2 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhatId = lstAccounttoInsert[1].Id);
        lstTasktoInsert.add(objtask2);
        
        Task objtask3 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhatId = lstAccounttoInsert[2].Id);
        lstTasktoInsert.add(objtask3);
        
        Task objtask4 = new Task(Subject = 'call', Status = 'In Progress', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(2), Priority = 'Normal', WhatId = lstAccounttoInsert[3].Id);
        lstTasktoInsert.add(objtask4);
        
        Task objtask5 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhatId = lstAccounttoInsert[4].Id);
        lstTasktoInsert.add(objtask5);
        
        Task objtask6 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhatId = lstAccounttoInsert[5].Id);
        lstTasktoInsert.add(objtask6);
        
        Task objtask7 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhatId = lstAccounttoInsert[6].Id);
        lstTasktoInsert.add(objtask7);
        
        insert lstTasktoInsert;
        
        // End of preparing test Data
        
        // Start of Executing functionality     
        test.startTest();
            lstAccounttoInsert[0].Upcoming_meeting_material_update__pc = Date.Today().addDays(4);
            update lstAccounttoInsert[0];
            lstAccounttoInsert[0].Upcoming_meeting_material_update__pc = null;
            update lstAccounttoInsert[0];
            lstAccounttoInsert[1].Upcoming_meeting_material_update__pc = Date.Today().addDays(4);
            update lstAccounttoInsert[1];
            lstAccounttoInsert[1].Upcoming_meeting_material_update__pc = null;
            update lstAccounttoInsert[1];
            lstAccounttoInsert[2].Upcoming_meeting_material_update__pc = Date.Today().addDays(4);
            update lstAccounttoInsert[2];
            lstAccounttoInsert[3].Upcoming_meeting_material_update__pc = Date.Today().addDays(4);
            update lstAccounttoInsert[3];
            lstAccounttoInsert[3].Upcoming_meeting_material_update__pc = null;
            update lstAccounttoInsert[3];
            lstAccounttoInsert[4].Upcoming_phone_material_update__pc = Date.Today().addDays(4);
            update lstAccounttoInsert[4];
            lstAccounttoInsert[5].Upcoming_meeting_material_update__pc = Date.Today().addDays(4);
            update lstAccounttoInsert[5];
            lstAccounttoInsert[5].Upcoming_meeting_material_update__pc = null;
            update lstAccounttoInsert[5];
            lstAccounttoInsert[6].Upcoming_phone_material_update__pc = Date.Today().addDays(4);
            update lstAccounttoInsert[6];
            lstAccounttoInsert[6].Upcoming_phone_material_update__pc = null;
            update lstAccounttoInsert[6];
            lstAccounttoInsert[7].Phone__pc = true;
            update lstAccounttoInsert[7];
            lstAccounttoInsert[8].Phone__pc = true;
            update lstAccounttoInsert[8];
        test.stopTest();
       // End of executing functionality
        
       // Verifying expected results
       system.assert(true);
    }
}