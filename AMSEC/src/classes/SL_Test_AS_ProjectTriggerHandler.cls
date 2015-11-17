@isTest
private class SL_Test_AS_ProjectTriggerHandler {

    static Id portFoliRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Portfolio Company').RecordTypeId;
    static Id activeDealRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Active Process').RecordTypeId;

    // Creating Data
    @testSetup static void createData()
    {
        // Inserting Accounts
        List<Account> lstAccount = new List<Account>{ new Account(Name = 'TestAcc - 01', RecordTypeID=portFoliRecTypeId),
                                                      new Account(Name = 'TestAcc - 02', RecordTypeID=activeDealRecTypeId) };            
        insert lstAccount;
        
        List<AS_Project__c> lstAsProjectRecords = new List<AS_Project__c>{ new AS_Project__c(Name = 'TestAS_Project-01', Start_Date__c = Date.Today(), Portfolio_Company__c = lstAccount[0].Id, AS_Project_Team__c = 'Hello, Hello'), 
                                                                            new AS_Project__c(Name = 'TestAS_Project-02', Start_Date__c = Date.Today(), Portfolio_Company__c = lstAccount[1].Id, AS_Project_Team__c = 'New, Test') };
        insert lstAsProjectRecords;
    }
    // Checking values on Account onAfter inerting of Project records. 
    @isTest static void test_checkRollUpForGettingUpdatedValues() {
        // As our Project already inserted with above values so....
        List<Account> lstAccounts = [Select Id, RG_Team_Members__c From Account Where Name Like '%TestAcc%' order By Name limit 2];
        system.assertEquals(lstAccounts[0].RG_Team_Members__c, 'Hello');    // TestAcc - 01
        system.assertEquals(lstAccounts[1].RG_Team_Members__c, 'New,Test'); // TestAcc - 02
    }
    // Updating the Project Records
    @isTest static void test_checkRollUpForGettingUpdatedOnUpdateofProjects() {
        // Updating the 'AS_Project_Team__c' on AS_Project Records...
        List<AS_Project__c> lstASProjectRecs = [Select Id, AS_Project_Team__c From AS_Project__c Where Name Like '%TestAS%' limit 2];
        lstASProjectRecs[0].AS_Project_Team__c = lstASProjectRecs[1].AS_Project_Team__c = '123*';
        update lstASProjectRecs;

        List<Account> lstUpdatedAccounts = [Select Id, RG_Team_Members__c From Account Where Name Like '%TestAcc%' order By Name limit 2];
        system.assertEquals(lstUpdatedAccounts[0].RG_Team_Members__c, '123');       // Removing the end * automatically by rollup handler..
        system.assertEquals(lstUpdatedAccounts[0].RG_Team_Members__c, lstUpdatedAccounts[1].RG_Team_Members__c );
    }
    // Updating of some Other value and it did not do anything on Account...Negative..
    @isTest static void test_checkRollUpNotUpdatingAnything() {
        List<Account> lstUpdatedAccounts = [Select Id, RG_Team_Members__c From Account Where Name Like '%TestAcc%' order By Name limit 2];
        system.assertEquals(lstUpdatedAccounts[0].RG_Team_Members__c, 'Hello');
        system.assertEquals(lstUpdatedAccounts[1].RG_Team_Members__c, 'New,Test');

        // Updating the 'AS_Project_Team__c' on AS_Project Records...
        List<AS_Project__c> lstASProjectRecs = [Select Id, AS_Project_Team__c From AS_Project__c Where Name Like '%TestAS%' limit 2];
        lstASProjectRecs[0].Name = 'TestAS_Project-03';
        lstASProjectRecs[1].Name = 'TestAS_Project-04';
        update lstASProjectRecs;

        lstUpdatedAccounts = [Select Id, RG_Team_Members__c From Account Where Name Like '%TestAcc%' order By Name limit 2];
        // Both value on Account is Intact
        system.assertEquals(lstUpdatedAccounts[0].RG_Team_Members__c, 'Hello');
        system.assertEquals(lstUpdatedAccounts[1].RG_Team_Members__c, 'New,Test'); 
    }   
    // DELETE of Project Records...
    @isTest static void test_checkRollUpForGettingUpdatedOnDeleteofProjects() {
        // deleting all Project records...
        delete [Select Id, AS_Project_Team__c From AS_Project__c Where Name Like '%TestAS%' limit 2];
        // After deleting all Project nothing will be there on any Account records...
        List<Account> lstUpdatedAccounts = [Select Id, RG_Team_Members__c From Account Where Name Like '%TestAcc%' order By Name limit 2];
        system.assertEquals(lstUpdatedAccounts[0].RG_Team_Members__c, NULL);
        system.assertEquals(lstUpdatedAccounts[0].RG_Team_Members__c, lstUpdatedAccounts[1].RG_Team_Members__c );
    }
    
}