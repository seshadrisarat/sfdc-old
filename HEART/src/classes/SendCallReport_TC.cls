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
private class SendCallReport_TC {
    static testMethod void SendCallReport_TC() {
        // Create some test data
        Profile pf = [Select Id, Name from Profile where Name = 'HAI Basic'];
        System.assertEquals(pf.Name, 'HAI Basic');
        
        List<User> l = new List<User>();
        for (Integer i = 0; i < 10; i++) {
            User u = new User();
            u.firstName = 'firstName'+i;
            u.lastName = 'lastName'+i;
            u.userName = 'userName'+i+'@heartlandfunds.com';
            u.alias = 'alias'+i;
            u.email = 'email'+i+'@heartlandfunds.com';
            u.profileId = pf.Id; //HAI Basic - profile id
            u.TimeZoneSidKey = 'America/Chicago';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.LanguageLocaleKey = 'en_US';
            l.add(u);
        }
        insert l;
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        Contact c = new Contact();
        c.firstName = 'contactFirstName';
        c.lastName = 'contactLastName';
        c.account = a;
        insert c;
        
        //tsk = [SELECT Id, whoId, who.name, who.type, whatId, what.name, what.type, ownerId, owner.name, activityDate, type, subject, description FROM Task WHERE Id = :taskId];
        
        Task tsk = new Task();
        tsk.whoId = c.Id;
        tsk.ownerId = l.get(0).Id;
        tsk.activityDate = Date.today();
        tsk.type = 'Test Type';
        tsk.subject = 'Test Subject';
        tsk.description = 'Test Description';
        insert tsk;    
        ApexPages.currentPage().getParameters().put('id', tsk.id);
        ApexPages.currentPage().getParameters().put('retURL', tsk.id);
        
        SendCallReport scr = new SendCallReport();
        
        List<User> users = [SELECT Name, Id FROM User];
        //System.assertEquals(scr.toAllContacts.size(), users.size());
        //System.assertEquals(scr.ccAllContacts.size(), users.size());
        
        System.assertEquals(scr.toSelectedContacts.size(), 0);
        System.assertEquals(scr.ccSelectedContacts.size(), 0);
        
        scr.toSelectedContacts.add(new SelectOption('123@yahoo.com', 'Dummy User'));
        scr.ccSelectedContacts.add(new SelectOption('456@yahoo.com', 'Example User'));
        
        System.assertEquals(scr.toSelectedContacts.size(), 1);
        System.assertEquals(scr.ccSelectedContacts.size(), 1);
        
        scr.send();
        
        tsk = [SELECT Id FROM Task WHERE Id = :tsk.Id];
        
        
    }
}