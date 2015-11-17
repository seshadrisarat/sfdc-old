@isTest
public class testSL_ngForceController_Mobile{
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

        system.debug('$$$$$$$$$$$$$$$$$$$$\n\n' + jsonResult);

        List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(jsonResult);
        
        System.assertNotEquals(null, errorArray, 
                               'error array missing from '+method+' result');
        System.assertNotEquals(0, errorArray.size(), 
                               'error array is empty in '+method+' result');
        
        Map<String, Object> error = (Map<String, Object>)errorArray[0];
        String errorCode = (String)error.get('errorCode');
        System.assertNotEquals(null, errorCode, 
                               'errorCode property missing from '+method+' result'); 
        System.assertEquals(expectedError, errorCode, 
                               'errorCode should be '+expectedError+' in '+method+' result');
    }
    
    static testMethod void testDescribe() {
        // Assume we have accounts
        String jsonResult = SL_ngForceController_Mobile.describe('Account');
        
        System.assertNotEquals(null, jsonResult, 
                               'SL_ngForceController_Mobile.describe returned null');
                      
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        System.assertNotEquals(null, result.get('fields'), 
                               'fields property missing from SL_ngForceController_Mobile.describe result');

        // TODO - more assertions on describe results
        
        // Invalid object type
        // Hope there isn't a QXZXQZXZQXZQ object type!
        jsonResult = SL_ngForceController_Mobile.describe('QXZXQZXZQXZQ');
        assertError(jsonResult, 'NOT_FOUND', 'SL_ngForceController_Mobile.describe');        
    }
    
    static private void assertRecord(Map<String, Object> record, String accName, String accNumber, String method) {
        Map<String, Object> attributes = (Map<String, Object>)record.get('attributes');
        System.assertNotEquals(null, attributes, 
                               'attributes property missing from '+method+' result');
        System.assertNotEquals(0, attributes.keySet().size(), 
                               'empty attributes object in '+method+' result');
        
        String type = (String)attributes.get('type');
        System.assertNotEquals(null, type, 
                               'type property missing from '+method+' result');
        System.assertEquals('Account', type, 
                               'Wrong type in '+method+' result');
        
        String url = (String)attributes.get('url');
        System.assertNotEquals(null, url, 
                               'url property missing from '+method+' result');
       
        Id id = (Id)record.get('Id');
        System.assertNotEquals(null, id, 
                               'Id property missing from '+method+' result');
        Account account = [SELECT Id, Name FROM Account WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record identified by '+method+' result');
        System.assertEquals(accName, account.Name, 
                               'Account name doesn\'t match in '+method+' result');
        
        String name = (String)record.get('Name');
        System.assertNotEquals(null, name, 
                               'Name property missing from '+method+' result');
        System.assertEquals(accName, name, 
                               'Wrong account name in '+method+' result');
   
        String accountNumber = (String)record.get('AccountNumber');
        System.assertNotEquals(null, name, 
                               'AccountNumber property missing from '+method+' result');
        System.assertEquals(accNumber, accountNumber, 
                               'Wrong account number in '+method+' result');
    }

    static private void testRetrieve(String accName, String accNumber, Id id) {
        String jsonResult = SL_ngForceController_Mobile.retrieve('Account', id, 'id, Name, AccountNumber');
        System.assertNotEquals(null, jsonResult,'SL_ngForceController_Mobile.retrieve returned null');

        jsonResult = SL_ngForceController_Mobile.retrieve('Account', id, 'Name, AccountNumber');
        System.assertNotEquals(null, jsonResult,'SL_ngForceController_Mobile.retrieve returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        assertRecord(result, accName, accNumber, 'SL_ngForceController_Mobile.retrieve');       

        jsonResult = SL_ngForceController_Mobile.retrieve('YYYYY', id, 'Name, AccountNumber'); 
        
        // TODO - test negative paths for retrieve
    } 

    static private void testQuery(String accName, String accNumber) {
        String jsonResult = SL_ngForceController_Mobile.query('SELECT Id, Name, AccountNumber FROM Account WHERE Name = \''+accName+'\'');
        
        System.assertNotEquals(null, jsonResult,'SL_ngForceController_Mobile.query returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        List<Object> records = (List<Object>)result.get('records');
        System.assertNotEquals(null, records, 
                               'records property missing from SL_ngForceController_Mobile.query result');
        System.assertEquals(1, records.size(), 
                               'records array should have single record in SL_ngForceController_Mobile.query result');
        
        Map<String, Object> record = (Map<String, Object>)records[0];
        
        assertRecord(record, accName, accNumber, 'SL_ngForceController_Mobile.query');        
                
        Integer totalSize = (Integer)result.get('totalSize');
        System.assertNotEquals(null, totalSize, 
                               'totalSize property missing from SL_ngForceController_Mobile.query result');
        System.assertEquals(1, totalSize, 
                               'totalSize should be 1 in SL_ngForceController_Mobile.query result');

        Boolean done = (Boolean)result.get('done');
        System.assertNotEquals(null, done, 
                               'done property missing from SL_ngForceController_Mobile.query result');
        System.assertEquals(true, done, 
                            'done should be true in SL_ngForceController_Mobile.query result');
        
        jsonResult = SL_ngForceController_Mobile.query('SELECT Ids, Name FROM Account WHERE Name = \''+accName+'\'');
        assertError(jsonResult, 'INVALID_QUERY', 'SL_ngForceController_Mobile.query');
    }

    static private void testSearch(String accName, String accNumber, Id id) {
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = id;
        Test.setFixedSearchResults(fixedSearchResults);
        String jsonResult = SL_ngForceController_Mobile.search('FIND {'+accName+'} IN ALL FIELDS RETURNING Account (Id, Name, AccountNumber)');
        
        System.assertNotEquals(null, jsonResult, 
                               'SL_ngForceController_Mobile.search returned null');
        
        List<Object> result = (List<Object>)JSON.deserializeUntyped(jsonResult);
        
        List<Object> records = (List<Object>)result[0];
        
        Map<String, Object> record = (Map<String, Object>)records[0];
        
        assertRecord(record, accName, accNumber, 'SL_ngForceController_Mobile.search'); 
        
    }

    static private void testUpdate(String accName, String accNumber, Id id, String fields) {
        String jsonResult = SL_ngForceController_Mobile.updat('Account', id, '{"Name":"'+accName+'", "AccountNumber":"'+accNumber+'"}'); 
        
        Account account = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record after SL_ngForceController_Mobile.updat');
        System.assertEquals(accName, account.Name, 
                               'Account name doesn\'t match after SL_ngForceController_Mobile.updat');
        System.assertEquals(accNumber, account.AccountNumber, 
                               'Account number doesn\'t match after SL_ngForceController_Mobile.updat');
        
        jsonResult = SL_ngForceController_Mobile.updat('QXZXQZXZQXZQ', id, '{"Name":"'+accName+'"}');
        assertError(jsonResult, 'NOT_FOUND', 'SL_ngForceController_Mobile.updat');
        
        jsonResult = SL_ngForceController_Mobile.updat('Account', id, '{"XQZXQZXQZXQZ" : "'+accName+'"}');
        assertError(jsonResult, 'INVALID_FIELD', 'SL_ngForceController_Mobile.updat');

        jsonResult = SL_ngForceController_Mobile.updat('Account', id, '{"Name" "'+accName+'"}');
        system.debug('###############\n\n' + jsonResult + '\n\n');
        assertError(jsonResult, 'JSON_PARSER_ERROR', 'SL_ngForceController_Mobile.updat');
                
        jsonResult = SL_ngForceController_Mobile.updat('Account', id, '{"Name" : "'+tooLongAccName+'"}');
        assertError(jsonResult, 'STRING_TOO_LONG', 'SL_ngForceController_Mobile.updat');
    }

    static private void testUpsert(String accName, String accNumber, Id id, String fields) {
        String jsonResult = SL_ngForceController_Mobile.upser('Account', 
                                                     'Id', 
                                                     (String)id, 
                                                     '{"Name":"'+accName+'", '+
                                                     '"AccountNumber":"'+accNumber+'",'+
                                                     fields+'}');
        System.assertEquals(null, jsonResult, 
                               'Non-null result from SL_ngForceController_Mobile.upser');
        Account account = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record after SL_ngForceController_Mobile.upser');
        System.assertEquals(accName, account.Name, 
                               'Account name doesn\'t match after SL_ngForceController_Mobile.upser');
        System.assertEquals(accNumber, account.AccountNumber, 
                               'Account number doesn\'t match after SL_ngForceController_Mobile.upser');
    }

    static private void testDelete(Id id) {
        String jsonResult = SL_ngForceController_Mobile.del('QXZXQZXZQXZQ', id);
        assertError(jsonResult, 'NOT_FOUND', 'SL_ngForceController_Mobile.del');

        jsonResult = SL_ngForceController_Mobile.del('Account', id); 
        System.assertEquals(null, jsonResult, 
                               'Non-null result from SL_ngForceController_Mobile.del');
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :id];
        System.assertEquals(0, accounts.size(), 
                               'Account record was not deleted by SL_ngForceController_Mobile.del');

        jsonResult = SL_ngForceController_Mobile.del('Account', id); 
        assertError(jsonResult, 'ENTITY_IS_DELETED', 'SL_ngForceController_Mobile.del');
    }
    
    static private Id testCreate(String accName, String accNumber, String fields) {
        // Assume we can create an account

        // Try with data in correct types
        String jsonResult = SL_ngForceController_Mobile.create('Account','{"Name": "'+accName+'", '+'"AccountNumber" : "'+accNumber+'",'+fields+'}');
        
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.create returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        Boolean success = (Boolean)result.get('success');

        System.assertNotEquals(null, success, 'success property missing from SL_ngForceController_Mobile.create result');

        System.assertNotEquals(false, success, 'success is false in SL_ngForceController_Mobile.create result');
        
        List<Object> errors = (List<Object>)result.get('errors');

        System.assertNotEquals(null, errors, 'errors property missing from SL_ngForceController_Mobile.create result');

        System.assertEquals(0, errors.size(), 'errors array is not empty in SL_ngForceController_Mobile.create result');
        
        Id id = (Id)result.get('id');

        System.assertNotEquals(null, id, 'id property missing from SL_ngForceController_Mobile.create result');

        Account account = [SELECT Id, Name, AccountNumber FROM Account LIMIT 1];

        System.assertNotEquals(null, account, 'Couldn\'t find account record created by SL_ngForceController_Mobile.create result');

        System.assertEquals(accName, account.Name, 'Account name doesn\'t match in SL_ngForceController_Mobile.create result');

        System.assertEquals(accNumber, account.AccountNumber, 'Account number doesn\'t match in SL_ngForceController_Mobile.create result');
        
        jsonResult = SL_ngForceController_Mobile.create('QXZXQZXZQXZQ', '{"Name": "'+accName+'"}');

        assertError(jsonResult, 'NOT_FOUND', 'SL_ngForceController_Mobile.create');
                
        jsonResult = SL_ngForceController_Mobile.create('Account', '{"Name" "'+accName+'"}');

        assertError(jsonResult, 'JSON_PARSER_ERROR', 'SL_ngForceController_Mobile.create');
                
        jsonResult = SL_ngForceController_Mobile.create('Account', '{"XQZXQZXQZXQZ" : "'+accName+'"}');

        assertError(jsonResult, 'INVALID_FIELD', 'SL_ngForceController_Mobile.create');

        jsonResult = SL_ngForceController_Mobile.create('Account', '{"Name" : "'+tooLongAccName+'"}');
        
        assertError(jsonResult, 'STRING_TOO_LONG', 'SL_ngForceController_Mobile.create');

        return id;
    }

    static testMethod void testCRUD() {
        String accName = 'Test1';
        String accNumber = '1234';
        
        // String field values
        Id id = testCreate(accName, accNumber, '"AnnualRevenue" : "1000000",'+
             '"NumberOfEmployees" : "1000",'+
             '"Phone" : "(111) 222-3333"');

        testDelete(id);
        
        // Integer field values
        id = testCreate(accName, accNumber, '"AnnualRevenue" : 1000000,'+
             '"NumberOfEmployees" : 1000,'+
             '"Phone" : "(111) 222-3333"');
        testRetrieve(accName, accNumber, id);
        testQuery(accName, accNumber);
        testSearch(accName, accNumber, id);
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

        String jsonResult = SL_ngForceController_Mobile.describeFieldSet('Task', 'SL_TaskMobileCard');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.describeFieldSet returned null');

        jsonResult = SL_ngForceController_Mobile.soqlFromFieldSet('Task', 'SL_TaskMobileCard');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.soqlFromFieldSet returned null');
        
        jsonResult = SL_ngForceController_Mobile.getPicklistValues('Task', 'Type');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.getPicklistValues returned null');

        jsonResult = SL_ngForceController_Mobile.getObjType(id);
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.getObjType returned null');

        jsonResult = SL_ngForceController_Mobile.bulkCreate('Account', '"AnnualRevenue" : 1000000,'+'"NumberOfEmployees" : 1000,'+'"Phone" : "(111) 222-3333"');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.bulkCreate returned null');

        jsonResult = SL_ngForceController_Mobile.bulkCreate('YYYY', '"AnnualRevenue" : 1000000,'+'"NumberOfEmployees" : 1000,'+'"Phone" : "(111) 222-3333"');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.bulkCreate returned null');

        Contact objContact = new Contact(LastName='Test Contact');

        Task objTask = new Task(isParent__c=true);
        insert objTask;
        
        Task objTask2 = new Task(ParentId__c=objTask.Id, OwnerId=UserInfo.getUserId());
        insert objTask2;

        Task objTask3 = new Task(isParent__c=true);
        insert objTask3;

        Task objTask4 = new Task(isParent__c=true);
        insert objTask4;

        Account objAccount = new Account(Name='Test');
        insert objAccount;

        Attachment objAttachment = new Attachment(Name='Test Attachment', Body=Blob.valueOf('Test Data'), ParentId=objTask2.Id);
        insert objAttachment;
        
        jsonResult = SL_ngForceController_Mobile.bulkCreate('TaskRelation', '[{"RelationId":\"'+ objContact.Id +'\","TaskId":\"'+ objTask.Id +'\"}]');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.bulkCreate returned null');
        
        jsonResult = SL_ngForceController_Mobile.bulkDelete('Account', '"AnnualRevenue" : 1000000,'+'"NumberOfEmployees" : 1000,'+'"Phone" : "(111) 222-3333"');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.bulkDelete returned null');

        jsonResult = SL_ngForceController_Mobile.bulkDelete('TTTT', '"AnnualRevenue" : 1000000,'+'"NumberOfEmployees" : 1000,'+'"Phone" : "(111) 222-3333"');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.bulkDelete returned null');
        
        jsonResult = SL_ngForceController_Mobile.bulkDelete('Task', '[{"Id":\"'+ objTask3.Id +'\"},{"Id":\"'+ objTask4.Id +'\"}]');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.bulkDelete returned null');
    
        jsonResult = SL_ngForceController_Mobile.query('SELECT Subject FROM Event WHERE WhatId = \''+objAccount.Id+'\' AND isDeleted = false PLACEHOLDER-OPENACTIVITY');

        jsonResult = SL_ngForceController_Mobile.query('SELECT Subject FROM Event WHERE WhatId = \''+objAccount.Id+'\' AND isDeleted = false PLACEHOLDER-CLOSEDACTIVITY');

        jsonResult = SL_ngForceController_Mobile.queryFromFieldSet(objTask.Id, 'SL_TaskMobileCard');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.queryFromFieldSet returned null');

        jsonResult = SL_ngForceController_Mobile.getPicklistValuesCustom('Task','Status'); 
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.getPicklistValuesCustom returned null');
        
        jsonResult = SL_ngForceController_Mobile.uploadAttachment(objTask2.ParentId__c, objAttachment.Body.toString(), objAttachment.Name, (String) UserInfo.getUserId(), objAttachment.Id);
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.uploadAttachment returned null');
    
        jsonResult = SL_ngForceController_Mobile.uploadAttachment(objTask2.ParentId__c, objAttachment.Body.toString(), objAttachment.Name, (String) UserInfo.getUserId(), null);
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.uploadAttachment returned null');

        jsonResult = SL_ngForceController_Mobile.uploadAttachment(objTask2.ParentId__c, null, objAttachment.Name, (String) UserInfo.getUserId(), objAttachment.Id);
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.uploadAttachment returned null');

        jsonResult = SL_ngForceController_Mobile.uploadAttachment(null, null, objAttachment.Name, (String) UserInfo.getUserId(), objAttachment.Id);
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.uploadAttachment returned null');
        
        jsonResult = SL_ngForceController_Mobile.getDefaultRecordType('Account');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.getDefaultRecordType returned null');

        jsonResult = SL_ngForceController_Mobile.getExistingRecords('Select Id, Subject from Event', 'Event', 'External', 'Id', 'Contact');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.getExistingRecords returned null');

        jsonResult = SL_ngForceController_Mobile.getCreatableFieldsSOQL('Event');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.getCreatableFieldsSOQL returned null');

        jsonResult = SL_ngForceController_Mobile.describeFieldSet('XXXX', 'SL_TaskMobileCard');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.describeFieldSet returned null');

        jsonResult = SL_ngForceController_Mobile.describeField('Account', 'Name');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController_Mobile.describeField returned null');

        testDelete(id);       
    }
}