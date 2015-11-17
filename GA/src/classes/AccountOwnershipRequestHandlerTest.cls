/*S-179420 - Created by Kanchan Palhora on 1/8/2014
 *Created to cover class AccountOwnershipRequestHandler
*/
@isTest
private class AccountOwnershipRequestHandlerTest {

    static testMethod void myUnitTest() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.Inboundenvelope env = new Messaging.Inboundenvelope();   
        
        Profile prof = [select Id from profile where Name = 'System Administrator']; 
        User u1 = new User (alias = 'usre',email = 'testABC@gmail.com', firstName = 'TestUser__123', lastName = 'RandomValue', username = 'testUser123@vamil.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/New_York', ProfileId = prof.Id); 
        insert u1;
        AccountRequestSettings__c  settings = new AccountRequestSettings__c();
        settings.Is_Test_Mode__c = false;
        settings.Approver_email__c = u1.email;
        insert settings;
                             
        email.subject  = 'Company accountt Information';
        email.fromAddress = 'testUser123@vamil.com';

        Account acc1 = new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
        String strRecordTypeId = [select Id from Recordtype where sobjectType = 'Account' and Name = 'Company'].Id;
        acc1.RecordTypeId = strRecordTypeId;
        Insert acc1;     
        
        CompanyName__c camp = new CompanyName__c(Name = acc1.id);
        insert camp;
        
        AccountOwnershipRequestHandler accHandlerObject = new AccountOwnershipRequestHandler();
        accHandlerObject.handleInboundEmail(email, env);
    }
    
        static testMethod void myUnitTest1() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.Inboundenvelope env = new Messaging.Inboundenvelope();   
        
        Profile prof = [select Id from profile where Name = 'System Administrator']; 
        User u1= new User (alias = 'usre',email = 'testABC@gmail.com', firstName = 'TestUser__123', lastName = 'RandomValue', username = 'testUser123@vamil.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/New_York', ProfileId = prof.Id); 
        insert u1;
        AccountRequestSettings__c  settings = new AccountRequestSettings__c();
        settings.Is_Test_Mode__c = false;
        settings.Approver_email__c = u1.email;
        insert settings;
                             
        email.subject  = 'Company accountt Information';
        email.fromAddress = 'testUser123@vamil.com';

        Account acct1 = new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
        String strRecordTypeId = [select Id from Recordtype where sobjectType = 'Account' and Name = 'Company'].Id;
        acct1.RecordTypeId = strRecordTypeId;
        Insert acct1; 
       
        Account acct2= new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
        acct2.RecordTypeId = strRecordTypeId;
        Insert acct2;    
       
        CompanyName__c camp = new CompanyName__c(Name = acct1.id);
        insert camp;
        AccountOwnershipRequestHandler accHandlerObject = new AccountOwnershipRequestHandler();
        accHandlerObject.handleInboundEmail(email, env);
    }
        static testMethod void myUnitTest2() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.Inboundenvelope env = new Messaging.Inboundenvelope();   
        
        Profile prof = [select Id from profile where Name = 'System Administrator']; 
        User u1= new User (alias = 'usre',email = 'testABC@gmail.com', firstName = 'TestUser__123', lastName = 'RandomValue', username = 'testUsertest123@vamil.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/New_York', ProfileId = prof.Id); 
        insert u1;
        AccountRequestSettings__c  settings = new AccountRequestSettings__c();
        settings.Is_Test_Mode__c = false;
        settings.Approver_email__c = u1.email;
        insert settings;
                             
        email.subject  = 'Company accountt Information';
        email.fromAddress = 'testUser123@vamil.com';

        Account acct1 = new Account(Name = 'accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
        String strRecordTypeId = [select Id from Recordtype where sobjectType = 'Account' and Name = 'Company'].Id;
        acct1.RecordTypeId = strRecordTypeId;
        Insert acct1; 

       
        CompanyName__c camp = new CompanyName__c(Name = acct1.id);
        insert camp;
        AccountOwnershipRequestHandler accHandlerObject = new AccountOwnershipRequestHandler();
        accHandlerObject.handleInboundEmail(email, env);
    }
    
}