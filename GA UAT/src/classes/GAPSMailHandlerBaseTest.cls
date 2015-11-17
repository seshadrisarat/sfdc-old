/*S-179420 - Created by Kanchan Palhora on 1/20/2014
 *Created to cover classes GAPSMailHandlerBase
*/
@isTest
private class GAPSMailHandlerBaseTest {
    static testMethod void myUnitTest() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.Inboundenvelope env = new Messaging.Inboundenvelope();
        String userNameStr = 'testABC'+system.currentTimeMillis()+'@gmail.com';
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        User u1 = new User (alias = 'usre',email = 'testABC@gmail.com', firstName = 'TestUser__123', lastName = 'RandomValue', username = userNameStr, emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/New_York', ProfileId = prof.Id); 
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
        Insert acc1;
        CompanyName__c camp = new CompanyName__c(Name = acc1.id);
        insert camp;
        
        Contact con = new Contact(LastName = 'TestContact', email = u1.email);
        String strRecordTypeId = [select Id from Recordtype where sobjectType = 'Contact' and Name = 'Employee'].Id;
        con.RecordTypeId = strRecordTypeId;
        Insert con;
    
    NewProjectHandler  obj = new NewProjectHandler();
    obj.handleInboundEmail(email, env);     

    }
}