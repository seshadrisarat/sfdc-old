@isTest (seeAllData=false)
public class Test_getIPCCAvailability {
    static testMethod void testgetIPCCAvailability()
    {
        /*Account ac = new Account();
        ac.Name='myac';
        insert ac;*/
         Account acc = new Account(Name = 'test');
        insert acc;
        
        Contact objContact = new Contact(Accountid=acc.id, FirstName='test 1', LastName='User 1');
        insert objContact;
        
        Fund__c fund = new Fund__c(Name='Test Fund', Availability_Include__c=TRUE, Fund_Acronym__c='IPCC');
        insert fund;
        
        List<Due_Diligence__c> listDueDiligence = new List<Due_Diligence__c>();
        Due_Diligence__c b = new Due_Diligence__c(Name='S A', Account__c=acc.Id, Fund__c=fund.Id, Release_Date__c=system.today().addDays(-4), Received_Approval__c=TRUE);
        listDueDiligence.add(b);
        insert listDueDiligence;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        getIPCCAvailability testIPCCPlan = new getIPCCAvailability(sc);
        String conId = ApexPages.currentPage().getParameters().put('Id',objContact.id);
        
        getIPCCAvailability gIPCC = new getIPCCAvailability(sc);
        gIPCC.populateDueDiligencedata(conId);
        test.stopTest();
    }
}