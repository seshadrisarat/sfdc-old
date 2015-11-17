@isTest
public class Test_DeleteIPCCSalesOnSunday {
    static testMethod void myUnitTest(){
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Account';
        // add whatever other fields are required for account creation here
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test'; // this assumes firstname is a required field on your contact records
        con.LastName = 'Contact'; // this assumes lastname is a required field on your contact records
        con.AccountId = acc.Id; // this assumes account is a required field on your contact records
        con.Title = 'Test Title'; // this is to validate your trigger
        con.MobilePhone = '1111111111'; // this is to validate your trigger
        // add whatever other fields are required for contact creation here
        insert con;
        
        
        Daily_Sale__c ds = new Daily_Sale__c();
        ds.Account__c = acc.Id;
        ds.Contact__c = con.Id;
        insert ds;
        
        //needed this part just to run the test class, but for the actual scheduling use Setup-->Develop-->Apex Classes 
        DeleteIPCCSalesOnSunday newtest = new DeleteIPCCSalesOnSunday();
        String sch = '0  00 20 ? * 1';
		system.schedule('Test', sch, newtest);
     
        Test.stopTest();
    }
}