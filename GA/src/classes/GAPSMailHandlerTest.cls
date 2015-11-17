/*S-179420 - Created by Kanchan Palhora on 1/20/2014
 *Created to cover classes 
 *GAPSMailHandler and
 *GAPSMailHandlerBase
*/
@isTest
private class GAPSMailHandlerTest {
    static testMethod void myUnitTest() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.Inboundenvelope env = new Messaging.Inboundenvelope();  
        
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        User u1 = new User (alias = 'usre',email = 'testUser123@vamil.com', firstName = 'TestUser__123', lastName = 'RandomValue', username = 'testUser123@vamil.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/New_York', ProfileId = prof.Id); 
        insert u1;
        
        GAPS_Settings__c settings = new GAPS_Settings__c();
        settings.Name = 'test GAPS' ;        
        settings.Is_Test_Mode__c = false;
        settings.Approver_Email__c = u1.email;
        settings.End_of_Note_Token__c = 'test token';
        settings.Next_Steps_Token__c = 'test next step token';
        settings.Sending_Email__c = u1.email;
        insert settings ;
                
        email.fromAddress = u1.email;
        email.subject = 'help: test subject data';
        email.plainTextBody = 'help: test subject data';        
        
        Account acc1 = new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
       	String strRecordTypeId = [select Id from Recordtype where sobjectType = 'Account' and Name = 'Company'].Id;
        acc1.RecordTypeId = strRecordTypeId;        
        Insert acc1;
        
        Account acc2 = new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
        acc2.RecordTypeId = strRecordTypeId;        
        Insert acc2;  
        
        CompanyName__c camp = new CompanyName__c(Name = acc1.id);
        insert camp;

        GAPSMailHandler gapsTestObject = new GAPSMailHandler();
        gapsTestObject.handleInboundEmail(email, env);      
    }
 	static testMethod void myUnitTest3() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.Inboundenvelope env = new Messaging.Inboundenvelope();  
        
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        User u1 = new User (alias = 'usre',email = 'testUser123@vamil.com', firstName = 'TestUser__123', lastName = 'RandomValue', username = 'testUser123@vamil.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/New_York', ProfileId = prof.Id); 
        insert u1;
        
        GAPS_Settings__c settings = new GAPS_Settings__c();
        settings.Name = 'test GAPS' ;        
        settings.Is_Test_Mode__c = false;
        settings.Approver_Email__c = u1.email;
        settings.End_of_Note_Token__c = 'test token';
        settings.Next_Steps_Token__c = 'test next step token';
        settings.Sending_Email__c = u1.email;
        insert settings ;        
        email.fromAddress = u1.email;
        email.subject = 'statusnote:    ';
        email.plainTextBody = 'statusnote:    ';        
        
        Account acc1 = new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
       	String strRecordTypeId = [select Id from Recordtype where sobjectType = 'Account' and Name = 'Company'].Id;
        acc1.RecordTypeId = strRecordTypeId;        
        Insert acc1;
        /*
        Account acc2 = new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
        acc2.RecordTypeId = strRecordTypeId;        
        Insert acc2;  
        */ 
        CompanyName__c camp = new CompanyName__c(Name = acc1.id);
        insert camp;
		
        GAPSMailHandler gapsTestObject = new GAPSMailHandler();
        gapsTestObject.handleInboundEmail(email, env);      
    }
    static testMethod void myUnitTest1() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.Inboundenvelope env = new Messaging.Inboundenvelope();  
        
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        User u1 = new User (alias = 'usre',email = 'testUser123@vamil.com', firstName = 'TestUser__123', lastName = 'RandomValue', username = 'testUser123@vamil.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/New_York', ProfileId = prof.Id); 
        insert u1;
        
        GAPS_Settings__c settings = new GAPS_Settings__c();
        settings.Name = 'test GAPS' ;        
        settings.Is_Test_Mode__c = false;
        settings.Approver_Email__c = u1.email;
        settings.End_of_Note_Token__c = 'test token';
        settings.Next_Steps_Token__c = 'test next step token';
        settings.Sending_Email__c = u1.email;
        insert settings ;        
        email.fromAddress = u1.email;
        email.subject = 'ownership:     ';
        email.plainTextBody = 'ownership:     ';        
        
        Account acc1 = new Account(Name = 'ownership : test subject data',ownerId = u1.Id, Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
       	String strRecordTypeId = [select Id from Recordtype where sobjectType = 'Account' and Name = 'Company'].Id;
        acc1.RecordTypeId = strRecordTypeId;        
        Insert acc1;
        /*
        Account acc2 = new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
        acc2.RecordTypeId = strRecordTypeId;        
        Insert acc2;  
        */   
        CompanyName__c camp = new CompanyName__c(Name = acc1.id);
        insert camp;
		
        GAPSMailHandler gapsTestObject = new GAPSMailHandler();
        gapsTestObject.handleInboundEmail(email, env);      
    }
    static testMethod void myUnitTest6() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.Inboundenvelope env = new Messaging.Inboundenvelope();  
        
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        User u1 = new User (alias = 'usre',email = 'testUser123@vamil.com', firstName = 'TestUser__123', lastName = 'RandomValue', username = 'testUser123@vamil.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/New_York', ProfileId = prof.Id); 
        insert u1;
        
        GAPS_Settings__c settings = new GAPS_Settings__c();
        settings.Name = 'test GAPS' ;        
        settings.Is_Test_Mode__c = false;
        settings.Approver_Email__c = u1.email;
        settings.End_of_Note_Token__c = 'test token';
        settings.Next_Steps_Token__c = 'test next step token';
        settings.Sending_Email__c = u1.email;
        insert settings ;        
        email.fromAddress = u1.email;
        email.subject = 'getstatus:     ';
        email.plainTextBody = 'getstatus:     ';        
        
        Account acc1 = new Account(Name = 'ownership : test subject data',ownerId = u1.Id, Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
       	String strRecordTypeId = [select Id from Recordtype where sobjectType = 'Account' and Name = 'Company'].Id;
        acc1.RecordTypeId = strRecordTypeId;        
        Insert acc1;
        /*
        Account acc2 = new Account(Name = 'Company accountt Information', Source__c = 'LinkedIn', Description = 'abc@123qwerty', Nearest_Metropolitan_City__c = 'City@123', Industry = 'Finance');
        acc2.RecordTypeId = strRecordTypeId;        
        Insert acc2;  
        */   
        CompanyName__c camp = new CompanyName__c(Name = acc1.id);
        insert camp;
	
        GAPSMailHandler gapsTestObject = new GAPSMailHandler();
        gapsTestObject.handleInboundEmail(email, env);      
    }    
}