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
public with sharing class ngForceController_Test 
{
    private static String tooLongAccName = 'LOTS OF '+
    'CHARACTERS XXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
    'XXXXXXXXXXXXXXXX';

    static private void assertError(String jsonResult, String expectedError, String method) {
        List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(jsonResult);
        Map<String, Object> error = (Map<String, Object>)errorArray[0];
        String errorCode = (String)error.get('errorCode');
    }

    static testMethod void testDescribe() {
        // Assume we have accounts
        String jsonResult = ngForceController.describe('Account');
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        // Invalid object type
        // Hope there isn't a QXZXQZXZQXZQ object type!
        jsonResult = ngForceController.describe('QXZXQZXZQXZQ');
    }

    static private void assertRecord(Map<String, Object> record, String accName, String accNumber, String method) {
        Map<String, Object> attributes = (Map<String, Object>)record.get('attributes');
        String type = (String)attributes.get('type');
        String url = (String)attributes.get('url');
        Id id = (Id)record.get('Id');
        Account account = [SELECT Id, Name FROM Account WHERE Id = :id LIMIT 1];
        String name = (String)record.get('Name');
        String accountNumber = (String)record.get('AccountNumber');
    }

    static private Id testCreate(String accName, String accNumber, String fields) {
        // Assume we can create an account
        ngForceController.QueryString obj = new ngForceController.QueryString();
        // Try with data in correct types
        String jsonResult = ngForceController.create('Account', 
            '{"Name": "'+accName+'", '+
            '"AccountNumber" : "'+accNumber+'",'+
            fields+'}');

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);

        Boolean success = (Boolean)result.get('success');
        List<Object> errors = (List<Object>)result.get('errors');
        Id id = (Id)result.get('id');
        Account account = [SELECT Id, Name, AccountNumber FROM Account LIMIT 1];
        jsonResult = ngForceController.create('QXZXQZXZQXZQ', '{"Name": "'+accName+'"}');
        jsonResult = ngForceController.create('Account', '{"Name" "'+accName+'"}');
        jsonResult = ngForceController.create('Account', '{"XQZXQZXQZXQZ" : "'+accName+'"}');
        jsonResult = ngForceController.create('Account', '{"Name" : "'+tooLongAccName+'"}');
        return id;
    }

    static private void testRetrieve(String accName, String accNumber, Id id) {
        String jsonResult = ngForceController.retrieve('Account', id, 'Name, AccountNumber');
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
    }

    static private void testQuery(String accName, String accNumber) {
        String jsonResult = ngForceController.query('SELECT Id, Name, AccountNumber FROM Account WHERE Name = \''+accName+'\'');
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        List<Object> records = (List<Object>)result.get('records');
        Map<String, Object> record = (Map<String, Object>)records[0];
        Integer totalSize = (Integer)result.get('totalSize');
        Boolean done = (Boolean)result.get('done');
        jsonResult = ngForceController.query('SSSSSS Id, Name FROM Account WHERE Name = \''+accName+'\'');
    }

    static private void testSearch(String accName, String accNumber, Id id) {
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = id;
        Test.setFixedSearchResults(fixedSearchResults);
        String jsonResult = ngForceController.search('FIND {'+accName+'} IN ALL FIELDS RETURNING Account (Id, Name, AccountNumber)');
        List<Object> result = (List<Object>)JSON.deserializeUntyped(jsonResult);
        List<Object> records = (List<Object>)result[0];
        Map<String, Object> record = (Map<String, Object>)records[0];
        jsonResult = ngForceController.search('FFFF {'+accName+'} IN ALL FIELDS RETURNING Account (Id, Name)');
    }

    static private void testUpdate(String accName, String accNumber, Id id, String fields) {
        String jsonResult = ngForceController.updat('Account', id, '{"Name":"'+accName+'", "AccountNumber":"'+accNumber+'"}'); 
        Account account = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :id LIMIT 1];
        jsonResult = ngForceController.updat('QXZXQZXZQXZQ', id, '{"Name":"'+accName+'"}');
        jsonResult = ngForceController.updat('Account', id, '{"XQZXQZXQZXQZ" : "'+accName+'"}');
    }

    static private void testUpsert(String accName, String accNumber, String id, String fields) {
        String jsonResult = ngForceController.upser('Account', 
            'Id', 
            (String)id, 
            '{"Name":"'+accName+'", '+
            '"AccountNumber":"'+accNumber+'",'+
            fields+'}');
        Account account = [SELECT Id, Name, AccountNumber FROM Account WHERE id = :id LIMIT 1];
    } 

    static private void testDelete(Id id) {
        String jsonResult = ngForceController.del('QXZXQZXZQXZQ', id);
        jsonResult = ngForceController.del('Account', id); 
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :id];
        jsonResult = ngForceController.del('Account', id); 
    }

    static testMethod void testGetObjType() {
        Account a = New Account(Name = 'Test Account');
        insert a;
        String jsonResult = ngForceController.getObjType(a.id);
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
    }
    
    @istest(seeAllData=true)
    static void testDescribeFieldSet() {
        //warning this test is un-optimal and fragile
        //I cannot create a fieldset via apex, so this test relies
        //on a given object and a given fieldset existing!!!
        //String jsonResult = ngForceController.describeFieldSet('LABJS_Mo_Tester_2__c', 'details');
        String jsonResult = ngForceController.describeFieldSet('Apartment__c', 'Search_Page_Columns');
        String jsonFailureQuery = ngForceController.describeFieldSet('Test__c','Test');   
    }
    
    static testMethod void testUploadAttachments() {
        Id objUserId  = UserInfo.getUserId();
        String jsonResult = ngForceController.uploadAttachments('{\"file\": [{\"type\": \"text/plain\",\"name\": \"dahut.txt\",\"OwnerId\": \"'+objUserId+'\"}}}');
    }
    static testMethod void testdescribeField(){
        String jsonResult = ngForceController.describeField('Account', 'Name');
    }
    
    static testMethod void testGetPicklistValues() {
        String jsonResult = ngForceController.getPicklistValues('Opportunity', 'StageName');
        List<Object> result = (List<Object>)JSON.deserializeUntyped(jsonResult);
    }
    
    static testMethod void testGetDefaultRecordType() {
        String jsonResult = ngForceController.getDefaultRecordType('Opportunity');
    }
    
    static testMethod void testGetCreatableFieldsSOQL() {
        String jsonResult = ngForceController.getCreatableFieldsSOQL('Opportunity');
    }
    
    /*static testMethod void testGetsoqlFromFieldSet() {
        String jsonResult1 = ngForceController.soqlFromFieldSet('Opportunity','');
    }*/
    
    @isTest(seeAllData=true)
    static void testGetsoqlFromFieldSet() {
        String jsonResult1 = ngForceController.soqlFromFieldSet('Apartment__c', 'Search_Page_Columns');
    }
    
    static testMethod void testBulkCreate(){
        Map<Integer,Account> js = new Map<Integer,Account>();
        String fields = '[{"0":{"Name":"foo company 1368751413359"},"1":{"Name":"foo company 1368751413440"},"2":{"Name":"foo company 1368751413459"},"3":{"Name":"foo company 1368751413479"},"4":{"Name":"foo company 1368751413497"},"5":{"Name":"foo company 1368751413517"},"6":{"Name":"foo company 1368751413540"},"7":{"Name":"foo company 1368751413559"},"8":{"Name":"foo company 1368751413577"},"9":{"Name":"foo company 1368751413597"}}]';
        String jsonResult = ngForceController.bulkCreate('Account', fields);
        //List<Object> result = (List<Object>)JSON.deserializeUntyped(jsonResult);
    }

    static testMethod void testCRUD() {
        String accName = 'Test1';
        String accNumber = '1234';

        // String field values
        Id id1 = testCreate(accName, accNumber, '"AnnualRevenue" : "10000.00",'+
            '"NumberOfEmployees" : "1000",'+
            '"Phone" : "(111) 222-3333"');
        testDelete(id1);
        Id id = testCreate(accName, accNumber, '"AnnualRevenue" : "10000.00",'+
            '"NumberOfEmployees" : "1000",'+
            '"Phone" : "(111) 222-3333"');
        testRetrieve(accName, accNumber, id);
        testQuery(accName, accNumber);
        //testSearch(accName, accNumber, id);
        testUpdate(accName+'1', accNumber+'1', id, '"AnnualRevenue" : "1100000",'+
             '"NumberOfEmployees" : "1100",'+
             '"Phone" : "(112) 222-3333"');
        testUpdate(accName+'2', accNumber+'2', id, '"AnnualRevenue" : "2000000",'+
             '"NumberOfEmployees" : "2000",'+
             '"Phone" : "(222) 222-3333"');
        testUpsert(accName+'3', accNumber+'3', id, '"AnnualRevenue" : 3000000,'+
             '"NumberOfEmployees" : 3000,'+
             '"Phone" : "(333) 222-3333"');
        testUpsert(accName+'4', accNumber+'4', id, '"AnnualRevenue" : 4000000,'+
             '"NumberOfEmployees" : 4000,'+
             '"Phone" : "(444) 222-3333"');
        testDelete(id);
    }
    
    static testMethod void testgetExistingRecords()
    {
        Account objAcc = new Account(Name='Test Account');
        insert objAcc;
        
        Contact objContact1 = new Contact(LastName='Test Contact1' , AccountId=objAcc.Id);
        insert objContact1;
        
        Contact objContact2 = new Contact(LastName='Test Contact2' , AccountId=objAcc.Id);
        insert objContact2;
        
        Task objTask = new Task(Subject='Other');
        insert objTask;
        
        TaskRelation objTskRel1 = new TaskRelation(TaskId=objTask.Id,RelationId=objContact1.Id);
        insert objTskRel1;
        
        TaskRelation objTskRel2 = new TaskRelation(TaskId=objTask.Id,RelationId=objContact2.Id);
        insert objTskRel2;
        
        String JSONresult = ngForceController.getExistingRecords('Select Task.Subject, RelationId from TaskRelation' , 'TaskRelation' , NULL , 'LastName,ID' , 'Contact');
        String JSONResult1 = ngForceController.getExistingRecords('Select Id,WhatId from Task' , 'Task' , NULL , 'LastName,ID' , 'Contact');
    }
    
    static testMethod void testBulkDelete()
    {
        List<Account> lstAccount = new List<Account>();
        for(integer index=0;index<100;index++)
        {
            String strName = 'Test Account' + index;
            lstAccount.add(new Account(Name=strName));
        }
    }
    
    @isTest(seeAllData=true)
    static void testqueryFromFieldSet() {
        ///Create a Building record
	    Building__c objBuilding = new Building__c(Name='Test Building 1', Street_Address__c = 'Test Address New',
                                                   Zip_Code__c = '1232123'); 
        insert objBuilding;
      
      	///Create an Apartment record
        Apartment__c objApartment = new Apartment__c(Name = 'Test Property',Building__c = objBuilding.Id );
        insert objApartment;
        
        String jsonResult1 = ngForceController.queryFromFieldSet(objApartment.Id, 'Search_Page_Columns');
    }
}