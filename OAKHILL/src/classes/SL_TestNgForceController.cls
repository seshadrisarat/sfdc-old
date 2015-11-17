@isTest
public class SL_TestNgForceController{

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
        String jsonResult = SL_ngForceController.describe('Account');
        
        System.assertNotEquals(null, jsonResult, 
                               'SL_ngForceController.describe returned null');
                      
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        System.assertNotEquals(null, result.get('fields'), 
                               'fields property missing from SL_ngForceController.describe result');

        // TODO - more assertions on describe results
        
        // Invalid object type
        // Hope there isn't a QXZXQZXZQXZQ object type!
        jsonResult = SL_ngForceController.describe('QXZXQZXZQXZQ');
        assertError(jsonResult, 'NOT_FOUND', 'SL_ngForceController.describe');        
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
        String jsonResult = SL_ngForceController.retrieve('Account', id, 'id, Name, AccountNumber');
        System.assertNotEquals(null, jsonResult,'SL_ngForceController.retrieve returned null');

        jsonResult = SL_ngForceController.retrieve('Account', id, 'Name, AccountNumber');
        System.assertNotEquals(null, jsonResult,'SL_ngForceController.retrieve returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        assertRecord(result, accName, accNumber, 'SL_ngForceController.retrieve');       

        jsonResult = SL_ngForceController.retrieve('YYYYY', id, 'Name, AccountNumber'); 
        
        // TODO - test negative paths for retrieve
    } 

    static private void testQuery(String accName, String accNumber) {
        String jsonResult = SL_ngForceController.query('SELECT Id, Name, AccountNumber FROM Account WHERE Name = \''+accName+'\'');
        
        System.assertNotEquals(null, jsonResult,'SL_ngForceController.query returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        List<Object> records = (List<Object>)result.get('records');
        System.assertNotEquals(null, records, 
                               'records property missing from SL_ngForceController.query result');
        System.assertEquals(1, records.size(), 
                               'records array should have single record in SL_ngForceController.query result');
        
        Map<String, Object> record = (Map<String, Object>)records[0];
        
        assertRecord(record, accName, accNumber, 'SL_ngForceController.query');        
                
        Integer totalSize = (Integer)result.get('totalSize');
        System.assertNotEquals(null, totalSize, 
                               'totalSize property missing from SL_ngForceController.query result');
        System.assertEquals(1, totalSize, 
                               'totalSize should be 1 in SL_ngForceController.query result');

        Boolean done = (Boolean)result.get('done');
        System.assertNotEquals(null, done, 
                               'done property missing from SL_ngForceController.query result');
        System.assertEquals(true, done, 
                            'done should be true in SL_ngForceController.query result');
        
        jsonResult = SL_ngForceController.query('SELECT Ids, Name FROM Account WHERE Name = \''+accName+'\'');
        assertError(jsonResult, 'INVALID_QUERY', 'SL_ngForceController.query');
    }

    static private void testSearch(String accName, String accNumber, Id id) {
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = id;
        Test.setFixedSearchResults(fixedSearchResults);
        String jsonResult = SL_ngForceController.search('FIND {'+accName+'} IN ALL FIELDS RETURNING Account (Id, Name, AccountNumber)');
        
        System.assertNotEquals(null, jsonResult, 
                               'SL_ngForceController.search returned null');
        
        List<Object> result = (List<Object>)JSON.deserializeUntyped(jsonResult);
        
        List<Object> records = (List<Object>)result[0];
        
        Map<String, Object> record = (Map<String, Object>)records[0];
        
        assertRecord(record, accName, accNumber, 'SL_ngForceController.search'); 
        
    }

    static private void testUpdate(String accName, String accNumber, Id id, String fields) {
        String jsonResult = SL_ngForceController.updat('Account', id, '{"Name":"'+accName+'", "AccountNumber":"'+accNumber+'"}'); 
        System.assertEquals(null, jsonResult, 
                               'Non-null result from SL_ngForceController.updat');
        Account account = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record after SL_ngForceController.updat');
        System.assertEquals(accName, account.Name, 
                               'Account name doesn\'t match after SL_ngForceController.updat');
        System.assertEquals(accNumber, account.AccountNumber, 
                               'Account number doesn\'t match after SL_ngForceController.updat');
        
        jsonResult = SL_ngForceController.updat('QXZXQZXZQXZQ', id, '{"Name":"'+accName+'"}');
        assertError(jsonResult, 'NOT_FOUND', 'SL_ngForceController.updat');
        
        jsonResult = SL_ngForceController.updat('Account', id, '{"XQZXQZXQZXQZ" : "'+accName+'"}');
        assertError(jsonResult, 'INVALID_FIELD', 'SL_ngForceController.updat');

        jsonResult = SL_ngForceController.updat('Account', id, '{"Name" "'+accName+'"}');
        system.debug('###############\n\n' + jsonResult + '\n\n');
        assertError(jsonResult, 'JSON_PARSER_ERROR', 'SL_ngForceController.updat');
                
        jsonResult = SL_ngForceController.updat('Account', id, '{"Name" : "'+tooLongAccName+'"}');
        assertError(jsonResult, 'STRING_TOO_LONG', 'SL_ngForceController.updat');
    }

    static private void testUpsert(String accName, String accNumber, Id id, String fields) {
        String jsonResult = SL_ngForceController.upser('Account', 
                                                     'Id', 
                                                     (String)id, 
                                                     '{"Name":"'+accName+'", '+
                                                     '"AccountNumber":"'+accNumber+'",'+
                                                     fields+'}');

        Account account = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record after SL_ngForceController.upser');
        System.assertEquals(accName, account.Name, 
                               'Account name doesn\'t match after SL_ngForceController.upser');
        System.assertEquals(accNumber, account.AccountNumber, 
                               'Account number doesn\'t match after SL_ngForceController.upser');
    }

    static private void testDelete(Id id) {
        String jsonResult = SL_ngForceController.del('QXZXQZXZQXZQ', id);
        assertError(jsonResult, 'NOT_FOUND', 'SL_ngForceController.del');

        jsonResult = SL_ngForceController.del('Account', id); 
        System.assertEquals(null, jsonResult, 
                               'Non-null result from SL_ngForceController.del');
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :id];
        System.assertEquals(0, accounts.size(), 
                               'Account record was not deleted by SL_ngForceController.del');

        jsonResult = SL_ngForceController.del('Account', id); 
        assertError(jsonResult, 'ENTITY_IS_DELETED', 'SL_ngForceController.del');
    }
    
    static private Id testCreate(String accName, String accNumber, String fields) {
        // Assume we can create an account 

        // Try with data in correct types
        String jsonResult = SL_ngForceController.create('Account','{"Name": "'+accName+'", '+'"AccountNumber" : "'+accNumber+'",'+fields+'}');
        
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.create returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        Boolean success = (Boolean)result.get('success');

        System.assertNotEquals(null, success, 'success property missing from SL_ngForceController.create result');

        System.assertNotEquals(false, success, 'success is false in SL_ngForceController.create result');
        
        List<Object> errors = (List<Object>)result.get('errors');

        System.assertNotEquals(null, errors, 'errors property missing from SL_ngForceController.create result');

        System.assertEquals(0, errors.size(), 'errors array is not empty in SL_ngForceController.create result');
        
        Id id = (Id)result.get('id');

        System.assertNotEquals(null, id, 'id property missing from SL_ngForceController.create result');

        Account account = [SELECT Id, Name, AccountNumber FROM Account LIMIT 1];

        System.assertNotEquals(null, account, 'Couldn\'t find account record created by SL_ngForceController.create result');

        System.assertEquals(accName, account.Name, 'Account name doesn\'t match in SL_ngForceController.create result');

        System.assertEquals(accNumber, account.AccountNumber, 'Account number doesn\'t match in SL_ngForceController.create result');
        
        jsonResult = SL_ngForceController.create('QXZXQZXZQXZQ', '{"Name": "'+accName+'"}');

        assertError(jsonResult, 'NOT_FOUND', 'SL_ngForceController.create');
                
        jsonResult = SL_ngForceController.create('Account', '{"Name" "'+accName+'"}');

        assertError(jsonResult, 'JSON_PARSER_ERROR', 'SL_ngForceController.create');
                
        jsonResult = SL_ngForceController.create('Account', '{"XQZXQZXQZXQZ" : "'+accName+'"}');

        assertError(jsonResult, 'INVALID_FIELD', 'SL_ngForceController.create');

        jsonResult = SL_ngForceController.create('Account', '{"Name" : "'+tooLongAccName+'"}');
        
        assertError(jsonResult, 'STRING_TOO_LONG', 'SL_ngForceController.create');

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


        MN_UserOption__c objMN_UserOption = new MN_UserOption__c(Open_Activities__c='Test_OA', Closed_Activities__c='Test_CA', User__c=UserInfo.getUserId());
        insert objMN_UserOption;

        Account objAccount = new Account(Name='Test');
        insert objAccount;

        Contact objContact = new Contact(FirstName='Test', LastName='Contact');
        insert objContact;

        Task objTask = new Task(isParent__c=true, WhatId=objAccount.Id);
        insert objTask;

        Task objTask2 = new Task(isParent__c=false, WhatId=objAccount.Id, ParentId__c=objTask.Id);
        insert objTask2;

        Task objTask3 = new Task(isParent__c=true, WhatId=objAccount.Id, Status='Completed'); 
        insert objTask3;

        Task objTask4 = new Task(isParent__c=false, WhatId=objAccount.Id, Status='Completed', ParentId__c=objTask3.Id); 
        insert objTask4;

        Event objEvent = new Event(WhatId=objAccount.Id, StartDateTime=Datetime.Now(), EndDateTime=Datetime.Now(), isParent__c=true);
        insert objEvent;

        Event objEvent2 = new Event(WhatId=objAccount.Id, StartDateTime=Datetime.Now(), EndDateTime=Datetime.Now(), ParentId__c=objEvent.Id, isParent__c=false);
        insert objEvent2;

        Event objEvent3 = new Event(WhatId=objAccount.Id, StartDateTime=Datetime.Now()-10, EndDateTime=Datetime.Now(), isParent__c=true);
        insert objEvent3;

        Event objEvent4 = new Event(WhatId=objAccount.Id, StartDateTime=Datetime.Now()-8, EndDateTime=Datetime.Now(), ParentId__c=objEvent3.Id, isParent__c=false);
        insert objEvent4;

        Attachment objAttachmentTask = new Attachment(Name='Test Attachment', Body=Blob.valueOf('Test Data'), ParentId=objTask.Id);
        insert objAttachmentTask;

        Attachment objAttachmentEvent = new Attachment(Name='Test Attachment2', Body=Blob.valueOf('Test Data2'), ParentId=objEvent.Id);
        insert objAttachmentEvent;

        PageReference pageRefAccount = Page.SL_AccountActivityRelatedList;

        Test.setCurrentPage(pageRefAccount);    

        ApexPages.currentPage().getParameters().put('Id', objAccount.Id);
        
        SL_ngForceController objAcc = new SL_ngForceController(); 

        delete  objMN_UserOption;

        PageReference pageRefContact = Page.SL_ContactActivityRelatedList;

        Test.setCurrentPage(pageRefContact);    

        ApexPages.currentPage().getParameters().put('Id', objContact.Id);
        
        SL_ngForceController objCont = new SL_ngForceController(); 
    
        List<Schema.FieldSetMember> jsonResultFieldSet = SL_ngForceController.describeFieldSet('Task', 'SL_ActivityRelatedListTaskFieldSet');
        System.assertNotEquals(null, jsonResultFieldSet, 'SL_ngForceController.describeFieldSet returned null');

        String jsonResult = SL_ngForceController.query('SELECT Subject FROM Event WHERE WhatId = \''+objAccount.Id+'\' AND isDeleted = false PLACEHOLDER-OPENACTIVITY');

        jsonResult = SL_ngForceController.query('SELECT Subject FROM Event WHERE WhatId = \''+objAccount.Id+'\' AND isDeleted = false PLACEHOLDER-CLOSEDACTIVITY');

        jsonResult = SL_ngForceController.queryFromFieldSet(objTask.Id, 'SL_ActivityRelatedListTaskFieldSet');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.queryFromFieldSet returned null');
        
        jsonResult = SL_ngForceController.soqlFromFieldSet('Task', 'SL_ActivityRelatedListTaskFieldSet');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.soqlFromFieldSet returned null');
        
        jsonResult = SL_ngForceController.getPicklistValues('Task', 'Type');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.getPicklistValues returned null');

        jsonResult = SL_ngForceController.getObjType(id);
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.getObjType returned null');

        jsonResultFieldSet = SL_ngForceController.describeFieldSet('XXXX', 'SL_FollowUpActivitiesFieldSet');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.describeFieldSet returned null');

        jsonResult = SL_ngForceController.describeField('Account', 'Name');
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.describeField returned null');

        Set<String> jsonResultPicklistValues = SL_ngForceController.getPicklistValuesWithFieldName('Task', 'Type');
        System.assertNotEquals(null, jsonResultPicklistValues, 'SL_ngForceController.getPicklistValuesWithFieldName returned null');

        /*jsonResult = SL_ngForceController.getCurrencySymbol();
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.getCurrencySymbol returned null');*/

        jsonResult = SL_ngForceController.getDateFormat();
        System.assertNotEquals(null, jsonResult, 'SL_ngForceController.getDateFormat returned null');

        testDelete(id);     
    }
}