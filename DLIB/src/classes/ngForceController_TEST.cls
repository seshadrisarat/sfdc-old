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
private class ngForceController_TEST
{
    static testMethod void testDescribe() 
    {
        //  Tests with Invalid input
        //String describeResult_JSON = ngForceController3.describe('XXXXXXXXXX');
        //List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
        Map<String, Object> errorMap;
        // = (Map<String, Object>)errorArray[0];
        
        //system.assertEquals(errorMap.get('message'), 'The requested resource does not exist');
        //system.assertEquals(errorMap.get('errorCode'), 'NOT_FOUND');
        
        //  Tests with Valid input
        String describeResult_JSON = ngForceController3.describe('Account');
        errorMap = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
        
        system.assertNotEquals(null, errorMap.get('fields'));
    }
    
    static testMethod void testdescribeFieldSet()
    {
      //  Tests with Invalid input
        //String describeResult_JSON = ngForceController3.describeFieldSet('Account', 'ngForceTEST');
        //List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
        //Map<String, Object> errorMap = (Map<String, Object>)errorArray[0];
        
        //system.assertEquals(errorMap.get('message'), 'Inavalid input/No such fieldset on the object');
        //system.assertEquals(errorMap.get('errorCode'), 'INVALID_INPUT');
        
        //  Valid input
        String describeResult_JSON = ngForceController3.describeFieldSet('Account', 'ngForceTEST');
        List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
        Map<String, Object> errorMap = (Map<String, Object>)errorArray[0];
        
        //system.assertEquals(errorMap.get('message'), null);
        //system.assertEquals(errorMap.get('errorCode'), null);
    }
    
    static testMethod void testdescribeField()
    {
      //  Tests with Invalid input
        String describeResult_JSON; //= ngForceController3.describeField('XXXXXXXXXX', 'YYYYYYY');
        //List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
        //Map<String, Object> errorMap = (Map<String, Object>)errorArray[0];
        
        //system.assertEquals(errorMap.get('message'), 'Inavalid input');
        //system.assertEquals(errorMap.get('errorCode'), 'INVALID_INPUT');
        
        //  Tests with Valid input
        describeResult_JSON = ngForceController3.describeField('Account', 'Id');
       Map<String, Object> errorMap = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
        
        system.assertEquals(false, errorMap.get('createable'));
        system.assertEquals(false, errorMap.get('autoNumber'));
        system.assertEquals('Id', errorMap.get('name'));
    }
    
    static testMethod void testsoqlFromFieldSet()
    {
    //  Valid input
        String describeResult_JSON = ngForceController3.soqlFromFieldSet('Account', 'ngForceTEST');
        Map<String, Object> errorMap = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
        
        //system.assertEquals(errorMap.get('message'), null);
        //system.assertEquals(errorMap.get('errorCode'), null);
    }
    
    static testMethod void testqueryFromFieldSet()
    {
    Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Valid input
        String describeResult_JSON = ngForceController3.queryFromFieldSet((String)objAccount.Id, 'ngForceTEST');
        List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
        Map<String, Object> errorMap = (Map<String, Object>)errorArray[0];
        
        //system.assertEquals(errorMap.get('Id'), objAccount.Id);
        //system.assertEquals(errorMap.get('Name'), objAccount.Name);
    }
    
    static testMethod void testgetPicklistValues()
    {
    ////  Tests with Invalid input
        //String describeResult_JSON = ngForceController3.getPicklistValues('XXXXXXXXXX', 'YYYYYYY');
    //    List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
    //    Map<String, Object> errorMap = (Map<String, Object>)errorArray[0];
        
    //    system.assertEquals(errorMap.get('message'), 'Inavalid input');
    //    system.assertEquals(errorMap.get('errorCode'), 'INVALID_INPUT');
        
        //  Tests with Valid input
        String describeResult_JSON = ngForceController3.getPicklistValues('Account', 'Type');
        List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
        system.assertNotEquals(null, errorArray);
    }
    
    static testMethod void testgetQueryResultsAsSelect2Data()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      ////  Tests with Invalid input
      //String strQuery = 'SELECT Id, Name FROMAccount LIMIT1';
      //String describeResult_JSON = ngForceController3.getQueryResultsAsSelect2Data(strQuery);
      //  List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //  Map<String, Object> errorMap = (Map<String, Object>)errorArray[0];
        
      //  system.assertEquals(errorMap.get('errorCode'), 'INVALID_QUERY');
      
      //  Tests with Valid input
      String strQuery = 'SELECT Id, Name FROM Account';
      ngForceController3.Select2Data objSelect2Data = new ngForceController3.Select2Data();
      String describeResult_JSON = ngForceController3.getQueryResultsAsSelect2Data(strQuery);
      List<Object>  errorArray = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      
      system.assertEquals(2, errorArray.size());
    }
    
    static testMethod void testsObjectKlone()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      ////  Tests with Invalid input
      //String describeResult_JSON = ngForceController3.sObjectKlone(((String)(objAccount.Id)).subString(0,10));
      //List<Object> errorMessage = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //Map<String, Object> errorMap = (Map<String, Object>)errorMessage[0];
      //system.assertEquals(errorMap.get('errorCode'), 'INVALID_DATA');
      //system.assertEquals(errorMap.get('message'), 'DML Failed');
      
      //  Tests with Valid input
      system.assertEquals(1, [Select Id, Name From Account Where Name = 'Test Account'].size());
      String describeResult_JSON = ngForceController3.sObjectKlone(objAccount.Id);
      system.debug('---------------------'+JSON.deserializeUntyped(describeResult_JSON));
      Id recordId = (Id)JSON.deserializeUntyped(describeResult_JSON);
        
        system.assertNotEquals(null, recordId);
        system.assertNotEquals(objAccount.Id, recordId);
        system.assertEquals('Test Account', [Select Id, Name From Account Where Id =: recordId].Name);
        system.assertEquals(2, [Select Id, Name From Account Where Name = 'Test Account'].size());
    }
    
    static testMethod void testgetObjType()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Tests with Invalid input
      //String describeResult_JSON = ngForceController3.getObjType(((String)(objAccount.Id)).subString(0,10));
      //List<Object> errorMessage = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      Map<String, Object> resultMap;
      // resultMap = (Map<String, Object>)errorMessage[0];
      //system.assertEquals(resultMap.get('errorCode'), 'INVALID_ID');
      //system.assertEquals(resultMap.get('message'), 'Operation failed');
      
      //  Tests with Valid input
      system.assertEquals(1, [Select Id, Name From Account Where Name = 'Test Account'].size());
      String describeResult_JSON = ngForceController3.getObjType(objAccount.Id);
      resultMap = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
        
        system.assertEquals('Account', resultMap.get('type'));
    }
    
    static testMethod void testcreate()
    {
      //  Invalid input
      //String describeResult_JSON = ngForceController3.create('Acount', JSON.serialize(new Map<String, String>{'Name'=>'Test Account2'}));
      //List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      Map<String, Object> mapResult;
       //(Map<String, Object>)lstResponse[0];
      
      //system.assertEquals(mapResult.get('errorCode'), 'NOT_FOUND');
      //system.assertEquals(mapResult.get('message'), 'The requested resource does not exist');
      
      //  Valid input
      String describeResult_JSON = ngForceController3.create('Account', JSON.serialize(new Map<String, String>{'Name'=>'Test Account2'}));
      mapResult = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
      
      system.assertNotEquals(null, mapResult.get('id'));
      //system.assertEquals(true, mapResult.get('success'));
      
      ////  Invalid input
      //describeResult_JSON = ngForceController3.create('Account', JSON.serialize(new Map<String, String>{'Name'=>''}));
      //lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertNotEquals(mapResult.get('errorCode'), null);
    }
    
    static testMethod void testbulkCreate()
    {
      //  Invalid input
      //String describeResult_JSON = ngForceController3.bulkCreate('Acount', JSON.serialize(new Map<String, String>{'Name'=>'Test Account2'}));
      //List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //Map<String, Object> mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertEquals(mapResult.get('errorCode'), 'NOT_FOUND');
      //system.assertEquals(mapResult.get('message'), 'The requested resource does not exist');
      
      //  Valid input
      Map<String, Map<String, String>> mapDataForBulkAccountCreate = new Map<String, Map<String, String>>();
      mapDataForBulkAccountCreate.put('1', new Map<String, String>{'Name'=>'Test Account11'});
      mapDataForBulkAccountCreate.put('2', new Map<String, String>{'Name'=>'Test Account12'});
      mapDataForBulkAccountCreate.put('3', new Map<String, String>{'Name'=>'Test Account13'});
      mapDataForBulkAccountCreate.put('4', new Map<String, String>{'Name'=>'Test Account14'});
      mapDataForBulkAccountCreate.put('5', new Map<String, String>{'Name'=>'Test Account15'});
      mapDataForBulkAccountCreate.put('6', new Map<String, String>{'Name'=>'Test Account16'}); 
      String describeResult_JSON = ngForceController3.bulkCreate('Account', JSON.serialize(mapDataForBulkAccountCreate));
      //lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
      
      system.assertNotEquals(null, mapResult.get('id'));
      system.assertEquals(6, ((List<Object>)mapResult.get('id')).size());
      //system.assertEquals(true, mapResult.get('success'));
      
      ////  Invalid input
      //mapDataForBulkAccountCreate = new Map<String, Map<String, String>>();
      //mapDataForBulkAccountCreate.put('1', new Map<String, String>{'Name'=>''});
      //mapDataForBulkAccountCreate.put('2', new Map<String, String>{'Name'=>''});
      //mapDataForBulkAccountCreate.put('3', new Map<String, String>{'Name'=>''});
      //mapDataForBulkAccountCreate.put('4', new Map<String, String>{'Name'=>''});
      //mapDataForBulkAccountCreate.put('5', new Map<String, String>{'Name'=>''});
      //mapDataForBulkAccountCreate.put('6', new Map<String, String>{'Name'=>''}); 
      //describeResult_JSON = ngForceController3.bulkCreate('Account', JSON.serialize(mapDataForBulkAccountCreate));
      //lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertNotEquals(mapResult.get('errorCode'), null);
    }
    
    static testMethod void testretrieve()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Valid input
      String describeResult_JSON = ngForceController3.retrieve('Account', objAccount.Id, 'Id, Name');
      Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
      
      system.assertEquals(mapResult.get('Id'), objAccount.Id);
      system.assertEquals(mapResult.get('Name'), objAccount.Name);
      
      //// Invalid input
      //describeResult_JSON = ngForceController3.retrieve('Acount', ((String)objAccount.Id).subString(0,10), 'Id, Name');
      //List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertEquals(mapResult.get('errorCode'), 'INVALID_QUERY');
    }
    
    static testMethod void testupsertData()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Valid input
      Map<String, String> mapFieldMappings = new Map<String, String>();
      mapFieldMappings.put('Name', 'Test Account modified');
      String describeResult_JSON = ngForceController3.upser('Account', 'Id', (String)objAccount.Id, JSON.serialize(mapFieldMappings));
      
      //system.assertEquals(describeResult_JSON, 'Success');
      
      //  Invalid input
      //mapFieldMappings = new Map<String, String>();
      //mapFieldMappings.put('Name', '');
      //describeResult_JSON = ngForceController3.upser('Account', 'Id', (String)objAccount.Id, JSON.serialize(mapFieldMappings));
      //List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //Map<String, Object> mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertEquals(mapResult.get('message'), 'DML Failed');
      //system.assertEquals(mapResult.get('errorCode'), 'DML_EXCEPTION');
    }
    
    static testMethod void testupdateData()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Valid input
      Map<String, String> mapFieldMappings = new Map<String, String>();
      mapFieldMappings.put('Name', 'Test Account modified');
      String describeResult_JSON = ngForceController3.updat('Account', (String)objAccount.Id, JSON.serialize(mapFieldMappings));
      
      //system.assertEquals(describeResult_JSON, 'Success');
      
      ////  Invalid input
      //mapFieldMappings = new Map<String, String>();
      //mapFieldMappings.put('Name', '');
      //describeResult_JSON = ngForceController3.updat('Account', (String)objAccount.Id, JSON.serialize(mapFieldMappings));
      //List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //Map<String, Object> mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertNotEquals(mapResult.get('message'), null);
      //system.assertNotEquals(mapResult.get('errorCode'), null);
    } 
    
    static testMethod void testdeleteData()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Invalid input : Facing intenal salesforce error while attempting to delete an Account record witout passing it's Id
      /*String describeResult_JSON = ngForceController3.deleteData('Account', '');
      List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      Map<String, Object> mapResult = (Map<String, Object>)lstResponse[0];
      
      system.assertNotEquals(mapResult.get('message'), null);
      system.assertNotEquals(mapResult.get('errorCode'), null);*/
      
      //  Valid input
      String describeResult_JSON = ngForceController3.del('Account', (String)objAccount.Id);
      
      //system.assertEquals(describeResult_JSON, 'Success');
    }
    
    static testMethod void testquery()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Valid input
      String describeResult_JSON = ngForceController3.query('Select Id From Account');
      Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
      
      ////  Invalid input
      //describeResult_JSON = ngForceController3.query('Select Id FromAccount');
      //List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertNotEquals(mapResult.get('message'), null);
      //system.assertNotEquals(mapResult.get('errorCode'), null);
    }
    
    static testMethod void test()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Valid input
      String describeResult_JSON = ngForceController3.query('Select Id From Account');
      Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(describeResult_JSON);
      
      system.assertEquals(mapResult.get('totalSize'), 2);
      
      ////  Invalid input
      //describeResult_JSON = ngForceController3.query('Select Id FromAccount');
      //List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertNotEquals(mapResult.get('message'), null);
      //system.assertNotEquals(mapResult.get('errorCode'), null);
    }
    
    static testMethod void testsearch()
    {
      Account objAccount = new Account(Name = 'Test Account');
      Account objAccount1 = new Account(Name = 'Test Account1');
      List<Account> lstAccounts = new List<Account>{objAccount, objAccount1};
      insert lstAccounts;
      
      //  Valid input
      String describeResult_JSON = ngForceController3.search('FIND {Test Account} IN Name Fields RETURNING Account');
      List<Object> lstResult = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      
      system.assertNotEquals(lstResult, null);
      
      ////  Invalid input
      //describeResult_JSON = ngForceController3.search('Select Id FromAccount');
      //List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(describeResult_JSON);
      //Map<String, Object> mapResult = (Map<String, Object>)lstResponse[0];
      
      //system.assertNotEquals(mapResult.get('message'), null);
      //system.assertNotEquals(mapResult.get('errorCode'), null);
    }
}