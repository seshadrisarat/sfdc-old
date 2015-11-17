/****************************************************************************************
Name            : psaTimeOffRequest_Test
Author          : CLD Partners
Created Date    : February 25, 2013
Description     : Test class for the PsaTimeOffRequestBIUD trigger.
******************************************************************************************/
@isTest
private class psaTimeOffRequest_Test {

    static testMethod void myUnitTest() {
       
        //TestUtilities utils = new TestUtilities();  // this class has nice methods for create users, accts, etc
        account acct = new account();
        contact employeeResource = new contact();
        user approver = new user();
        user employeeUser = new user();
        
        // Insert a new Region
        pse__Region__c region = new pse__Region__c();
        region.Name = 'Corporate';
        region.pse__Hierarchy_Depth__c = 0;
        insert region;

        // Insert a temp project with same name as the TOR project
        pse__Proj__c TorProject = new pse__Proj__c();
        TorProject.Name = 'Time Off';
        TorProject.pse__Is_Active__c = True;
        TorProject.pse__Is_Billable__c = False;
        TorProject.pse__Region__c = region.Id;
        insert TorProject;
        
        // Setup user and resource [contact] records
        //acct = utils.createAccount();
        //employeeUser = utils.createUser(approver.Id, true);
        //employeeResource = utils.createContact(employeeUser, approver, acct.Id);
        acct = createAccount();
        approver = createUser();
        employeeUser = createUser();
        employeeResource = createContact(employeeUser, acct.Id);
        
        // set the User.Manager value on the employeeUser (there is TOR validation that the User.Manager must be set)
        employeeUser.ManagerId = approver.Id;
        update employeeUser;
        
        system.debug('*** TOR TEST CLASS: Approver:' + approver);
        system.debug('*** TOR TEST CLASS: employeeUser:' + employeeUser);
        system.debug('*** TOR TEST CLASS: employeeResource:' + employeeResource);
        
        
        // Build a Time Off Request record
        Time_Off_Request__c Tor = new Time_Off_Request__c();
        
        Tor.Employee__c = employeeResource.Id;
        Tor.First_Day_Off__c = date.today();
        Tor.Last_Day_Off__c = date.today();
        Tor.Request_Type__c = 'Time Off';
        Tor.Status__c = 'Requested';
        Tor.OwnerId = employeeUser.Id;
        
        system.debug('*** TOR TEST CLASS: Tor:' + Tor);
        
        // Run test
        test.startTest();
        
        // execute Insert trigger logic
        insert Tor;
        
        // execute Update trigger logic
        Tor.Status__c = 'Approved';
        update Tor;
        
        // execute Delete trigger logic
        delete Tor;
        
        test.StopTest();
        
    }

    /*** HELPER METHODS THAT CAN OFTEN BE FOUND IN UTILITY CLASS (INCLUDED HERE FOR SIMPLIFICATION) ***/
    // Create test account
    private static Account createAccount(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCity = 'New York';
        acc.BillingStreet = '100 Main st';
        acc.BillingState = 'NY';
        acc.BillingPostalCode = '11111';
        acc.BillingCountry = 'US';  
        insert acc;
        return acc;
    }    
   
   // Create test User
   private static User createUser(){
        Integer i = Math.random().intValue();
        Profile pf = [Select id from Profile where  name = 'System Administrator' LIMIT 1];
        
        User u1 = new User();
        u1.firstName = 'test' + i;
        u1.LastName = 'test' + i; 
        u1.Alias = 'tst' + i;
        u1.Email = 'test' + i + '.test@mailinator.com';  
        u1.UserName='test'+ i + '_' + Math.random().format() + System.now().millisecond().format() + 'user1@gmail.com';
        u1.ProfileId = pf.Id;
        u1.EmailEncodingKey ='ISO-8859-1'; 
        u1.LanguageLocaleKey = 'en_US';
        u1.TimeZoneSidKey ='America/New_York';
        u1.LocaleSidKey = 'en_US';  
        u1.IsActive = true;
        u1.Title = 'Title';
        u1.Department = 'TestDepartment';
        insert u1;
        return u1;
    }
    
 
    // Create test Resource
    private static Contact createContact(User SFUser, Id accId){
        Contact contact = new Contact(firstName ='Test Contact',lastName = 'last name' ,email='test@example.com');
        contact.pse__Is_Resource__c = true;
        contact.pse__Is_Resource_Active__c = true;
        contact.pse__Salesforce_User__c = SFUser.Id;
        contact.pse__Start_Date__c = date.today().toStartofWeek().addDays(-15);
        contact.accountId = accId;
        insert contact;
        return contact;
    }
    
    
}