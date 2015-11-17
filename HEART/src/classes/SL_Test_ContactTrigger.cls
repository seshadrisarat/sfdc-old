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
private class SL_Test_ContactTrigger {

    static testMethod void SL_ContactTriggerHandler() {
        
        Id idRecTypeId = [select Name,Id From RecordType where Name = 'Private Clients and Prospects'].Id;
        
        list<Contact> lstContacttoInsert = new List<Contact>();
        
        
        // Start of Preparing test data
        Account objAcc = new Account(LastName = 'Test Account Name - 1', RecordTypeId = idRecTypeId);
        insert  objAcc;
        system.assert(objAcc.Id != null);
        
        Contact objCon1 = new Contact(Account = objAcc, LastName = 'Test Contact Name -1', Phone__c = true , Meeting__c = true);
        lstContacttoInsert.add(objCon1);
        Contact objCon2 = new Contact(Account = objAcc, LastName = 'Test Contact Name -2', Meeting__c = true);
        lstContacttoInsert.add(objCon2);
        Contact objCon3 = new Contact(Account = objAcc, LastName = 'Test Contact Name -3', Meeting__c = false , Phone__c = true);
        lstContacttoInsert.add(objCon3);
        Contact objCon4 = new Contact(Account = objAcc, LastName = 'Test Contact Name -4', Phone__c = true , Meeting__c = true);
        lstContacttoInsert.add(objCon4);
        Contact objCon5 = new Contact(Account = objAcc, LastName = 'Test Contact Name -5', Phone__c = true);
        lstContacttoInsert.add(objCon5);
        Contact objCon6 = new Contact(Account = objAcc, LastName = 'Test Contact Name -6', Meeting__c = true , Phone__c = false);
        lstContacttoInsert.add(objCon6);
        Contact objCon7 = new Contact(Account = objAcc, LastName = 'Test Contact Name -7', Meeting__c = false , Phone__c = true);
        lstContacttoInsert.add(objCon7);
        Contact objCon8 = new Contact(Account = objAcc, LastName = 'Test Contact Name -8',Last_phone_material_update__c = Date.Today(),CommFreq_Phone__c = 'Quarterly');
        lstContacttoInsert.add(objCon8);
        Contact objCon9 = new Contact(Account = objAcc, LastName = 'Test Contact Name -9',Last_meeting_material_update__c = Date.Today());
        lstContacttoInsert.add(objCon9);
        
        insert lstContacttoInsert;  // Inserting all Contacts

        list<Task> lstTasktoInsert = new List<Task>();
        
        Task objtask1 = new Task(Subject = 'call', Status = 'In Progress', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(2), Priority = 'Normal', WhoId = lstContacttoInsert[0].Id);
        lstTasktoInsert.add(objtask1);
        
        Task objtask2 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[1].Id);
        lstTasktoInsert.add(objtask2);
        
        Task objtask3 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Phone', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[2].Id);
        lstTasktoInsert.add(objtask3);
        
        Task objtask4 = new Task(Subject = 'call', Status = 'In Progress', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(2), Priority = 'Normal', WhoId = lstContacttoInsert[3].Id);
        lstTasktoInsert.add(objtask4);
        
        Task objtask5 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[4].Id);
        lstTasktoInsert.add(objtask5);
        
        Task objtask6 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[5].Id);
        lstTasktoInsert.add(objtask6);
        
        Task objtask7 = new Task(Subject = 'call', Status = 'Not Started', Type = 'Material Update- Meeting', OwnerId = Userinfo.getUserId(), ActivityDate = Date.Today().addDays(3), Priority = 'Normal', WhoId = lstContacttoInsert[6].Id);
        lstTasktoInsert.add(objtask7);
        
        insert lstTasktoInsert;
        
        // End of preparing test Data
        
        // Start of Executing functionality     
        test.startTest();
            lstContacttoInsert[0].Upcoming_meeting_material_update__c = Date.Today().addDays(4);
            update lstContacttoInsert[0];
            lstContacttoInsert[0].Upcoming_meeting_material_update__c = null;
            update lstContacttoInsert[0];
            lstContacttoInsert[1].Upcoming_meeting_material_update__c = Date.Today().addDays(4);
            update lstContacttoInsert[1];
            lstContacttoInsert[1].Upcoming_meeting_material_update__c = null;
            update lstContacttoInsert[1];
            lstContacttoInsert[2].Upcoming_meeting_material_update__c = Date.Today().addDays(4);
            update lstContacttoInsert[2];
            lstContacttoInsert[3].Upcoming_meeting_material_update__c = Date.Today().addDays(4);
            update lstContacttoInsert[3];
            lstContacttoInsert[3].Upcoming_meeting_material_update__c = null;
            update lstContacttoInsert[3];
            lstContacttoInsert[4].Upcoming_phone_material_update__c = Date.Today().addDays(4);
            update lstContacttoInsert[4];
            lstContacttoInsert[5].Upcoming_meeting_material_update__c = Date.Today().addDays(4);
            update lstContacttoInsert[5];
            lstContacttoInsert[5].Upcoming_meeting_material_update__c = null;
            update lstContacttoInsert[5];
            lstContacttoInsert[6].Upcoming_phone_material_update__c = Date.Today().addDays(4);
            update lstContacttoInsert[6];
            lstContacttoInsert[6].Upcoming_phone_material_update__c = null;
            update lstContacttoInsert[6];
            lstContacttoInsert[7].Phone__c = true;
            update lstContacttoInsert[7];
            lstContacttoInsert[8].Phone__c = true;
            update lstContacttoInsert[8];
        test.stopTest();
       // End of executing functionality
        
       // Verifying expected results
       system.assert(true);
    }
    
    private static testMethod void testContactPrefHistory() 
	{
        Account objAccount = new Account(Name = 'Test Account');
        insert objAccount;
        Contact objContact = new Contact(LastName ='test', AccountId = objAccount.Id, HAI_Communications__c = 'Test 1');
        insert objContact;
        
        insert new Contact_Trigger_Status__c(SetupOwnerId=UserInfo.getOrganizationId(), isActive__c=true);
        
        objContact.HAI_Communications__c = 'Test 3';
        update objContact;
        
        system.assertEquals([SELECT Id FROM Contact_Preferences_History__c WHERE Contact_Name__c =: objContact.Id].size(), 1);
        system.assertEquals([SELECT New_Value_HAI_Opt_Out__c FROM Contact_Preferences_History__c WHERE Contact_Name__c =: objContact.Id].New_Value_HAI_Opt_Out__c, 'Test 3');
        system.assertEquals([SELECT Prior_Value_HAI_Opt_Out__c FROM Contact_Preferences_History__c WHERE Contact_Name__c =: objContact.Id].Prior_Value_HAI_Opt_Out__c, 'Test 1');
	}
}