@isTest
public class Test_Nightly_Jobs {
    static testMethod void mytest() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact[] ContactOut = new list<Contact>();
        ContactOut.add(new contact(FirstName = 'Test', LastName='LastName', AccountId = acc.Id, Sales_Rating__c='4', status__c = 'inactive'));
        Contact c5 = new contact(FirstName = 'Test', LastName='LastName', AccountId = acc.Id, Sales_Rating__c='6', status__c = 'active');
        Contact c4 = new contact(FirstName = 'Test', LastName='LastName', AccountId = acc.Id, Sales_Rating__c='5', status__c = 'active');
        Contact c3 = new contact(FirstName = 'Test', LastName='LastName', AccountId = acc.Id, Sales_Rating__c='5', status__c = 'active');
        Contact c2 = new contact(FirstName = 'Test', LastName='LastName', AccountId = acc.Id, Sales_Rating__c='5', status__c = 'active');
        Contact c1 = new contact(FirstName = 'Test', LastName='LastName', AccountId = acc.Id, Sales_Rating__c='5', status__c = 'active');
        ContactOut.add(c5);
        ContactOut.add(c4);
        ContactOut.add(c3);
        ContactOut.add(c2);
        ContactOut.add(c1);
        insert(ContactOut);
        
        Daily_sale__C[] DailySaleOut = new list<Daily_sale__C>();
        DailySaleOut.add(new Daily_sale__C(fund_reference_code__c='3873', account__c=acc.Id, contact__c=c4.id, amount__c=2));
        DailySaleOut.add(new Daily_sale__C(fund_reference_code__c='3873', account__c=acc.Id, contact__c=c3.id, amount__c=250001));
        DailySaleOut.add(new Daily_sale__C(fund_reference_code__c='3873', account__c=acc.Id, contact__c=c2.id, amount__c=500001));
        DailySaleOut.add(new Daily_sale__C(fund_reference_code__c='3873', account__c=acc.Id, contact__c=c1.id, amount__c=1000001));
        insert(DailySaleOut);
        
        list<Contact> contactMap = new list<Contact>([select id from contact]);
        list<id> idOut = new list<id>();
        for (contact c: contactMap){
            idOut.add(c.id);
        }
        
        nightly_jobs nightlyJobs = new nightly_jobs();
        nightlyJobs.Sales_Rating(idOut);
        nightlyJobs.Update_Recent_Sales_Rating(date.parse('04/02/2015'));
        Batch_Nightly_Jobs myBatch = new Batch_Nightly_Jobs();
        database.executeBatch(myBatch);
    }
}