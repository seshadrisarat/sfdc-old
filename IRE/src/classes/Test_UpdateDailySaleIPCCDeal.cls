@isTest
public class Test_UpdateDailySaleIPCCDeal {
    public static String CRON_EXP = '0 0 6 * * ?';
    static testMethod void mytest() {
       
        test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',
                            CRON_EXP, 
                            new scheduledIPCCFlag_DailySales());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         		NextFireTime
         		FROM CronTrigger WHERE id = :jobId];

        test.stopTest();
        //To run this test you'll need to wipe all the fla... oh nevermind i'll do it below
        //list<Daily_Sale__c> lSalestoUpdate = [Select id, IPCC_Deal__c from Daily_sale__c where Fund__r.Fund_Acronym__c = 'IPCC' and IPCC_Deal__c = TRUE limit 500];
        //list<Daily_Sale__c> lUpdatedSales = new list<Daily_Sale__c>();
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
        
        fund__c fundIPCC = new fund__c();
        fundIPCC.name = 'testfund';
        fundIPCC.Fund_Acronym__c = 'IPCC';
        insert fundIPCC;
       	Daily_Sale__c dasa = new Daily_Sale__c();
        dasa.Amount__c = 100;
        dasa.Contact__c = con.Id;
        dasa.Account__c = acc.id;
        dasa.Fund__c = fundIPCC.Id;
        
        insert dasa;
        
        //daily_sale__c oDailySale = new daily_sale__c();
        //oDailySale.Contact__c;
        //daily_sale__c[] DailySaleOut = new list<daily_sale__c>();
		//DailySaleOut.add(new daily_sale__c(Contact__c = ));
        
        UpdateDailySaleIPCCDeal updatetools = new UpdateDailySaleIPCCDeal();
		UpdateTools.UpdateIPCC();
    }
}