/**
 * Name         : UserUpdateWithContactTest
 * Created By   : Mohit
 * Created Date : Apr 4,2013
 * Description  : This class contains unit tests for validating the behavior of UserUpdateWithContact trigger.
 *
 */
@isTest
private class UserUpdateWithContactTest {

    static testMethod void insertUpdateContactTest() {
    	
    	Test.startTest();
        Profile prof = [select id from profile where name = 'System Administrator'];
        Account account = new Account (Name='testName');
        insert account;
        // Insert the User
        User u = new User(alias = 'standt', email = 'testFeedItemDelete@testorg.com', emailencodingkey = 'UTF-8', FirstName = 'Sample', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete@testorg.com',Title='TestTitle');
        insert u;
        
        //Create the Contact
        Contact c = new Contact(FirstName='Test',LastName='Contact',User__c = u.Id);
        insert c;
        
        // Update the User information
        u.Phone = '123456';
        update u;
        
        // Update the User Company name
        u.CompanyName = account.Name;
        update u; 
        Test.stopTest();
        Contact con = [Select Id,Phone,AccountId,User__c,Email from Contact where User__c =: u.Id limit 1];
     //   system.assertEquals(con.Email,u.Email);
     // 	system.assertEquals(con.AccountId,account.Id);
    }
      
}