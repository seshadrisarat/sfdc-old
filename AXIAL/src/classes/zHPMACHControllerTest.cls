@isTest
public class zHPMACHControllerTest{
    static TestMethod void testzHPMACHController() {
        Test.startTest();
        
        zHPMACHController hpmach = new zHPMACHController();
        Account acc = createAccount();
        Contact con = createContact();
        Opportunity opp = createOpportunity(acc);
        zqu__Quote__c quote = createQuote(con, opp);
        
        hpmach.id = quote.Id;
        
        hpmach.getPageRef();
        hpmach.getBackURL();
        hpmach.getNextURL();
        hpmach.navigateBack();
        hpmach.navigateNext();
        hpmach.setQuotePaymentMethod();
        
        Test.stopTest();
        
    }
    
    
	public static Account createAccount(){
        Account testAcc = new Account();
        testAcc.Name = 'testAccount';
        
        insert testAcc;
        return testAcc;
    } 
    public static Contact createContact()
    {
        Contact testcon = new Contact();
        testcon.firstname = 'testconfirst';
        testcon.lastname = 'testconlast';
        testcon.email = 'test@test.com';
        
        insert testcon;
        return testcon;
        
    
    }
    public static Opportunity createOpportunity(Account acc)
    {
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'testopp';
        Date mydate = date.newinstance(2012, 1, 1);
        testOpp.CloseDate = mydate;
        
        testOpp.StageName = '0 - Marketing';
        testOpp.Type = 'New Business';
        

        List<Account> acclist = [select id, name from Account where name = :acc.Name];
        
        testOpp.AccountId = acclist[0].Id;
        
        insert testOpp;
        return testOpp;

    }

    
    public static zqu__Quote__c createQuote(Contact con, Opportunity opp)
    {
        zqu__Quote__c testQuote = new zqu__Quote__c();
        
        testQuote.name = 'testquote';
        testQuote.zqu__Opportunity__c = opp.Id;
        testQuote.zqu__BillToContact__c = con.Id;
        Contact soldTo = createContact();
        
        testQuote.zqu__SoldToContact__c = soldTo.Id;
        testQuote.zqu__PaymentMethod__c = 'Credit Card';
        testQuote.zqu__PaymentTerm__c = 'Due Upon Receipt';
        testQuote.zqu__InitialTerm__c = 12;
        testQuote.zqu__RenewalTerm__c = 12;
        testQuote.zqu__Service_Activation_Date__c = System.today();
        testQuote.zqu__SubscriptionTermStartDate__c = System.today();
        testQuote.zqu__AutoRenew__c = false;
        testQuote.zqu__StartDate__c = System.today();
        testQuote.zqu__ValidUntil__c = System.today();
        
        testQuote.zqu__RecordReadOnly__c = false;
        testQuote.zqu__Status__c = 'Sent to Z-Billing';
        testQuote.zqu__SubscriptionType__c = 'New Subscription';
        testQuote.zqu__ExistSubscriptionID__c = '123';
        testQuote.zqu__StartDate__c = System.today();
        testQuote.zqu__ZuoraAccountID__c = '12345';

        
        testQuote.zqu__Currency__c = 'USD';
        
        insert testQuote;
        return testQuote;
    }
}