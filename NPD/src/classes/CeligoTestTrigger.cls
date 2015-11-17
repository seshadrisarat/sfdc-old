@isTest(SeeAllData=true)
private class CeligoTestTrigger {

    static testMethod void myUnitTest() {
        Account a = new Account();
           
        a.Name = 'testAccA';
        a.BillingStreet = '123 Test City';
        a.BillingCity = 'San Jose';
        a.BillingState = 'California';
        a.BillingCountry = 'United States';
        a.netsuite_conn__Celigo_Update__c = true;
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.AccountId = a.Id;
        o.CloseDate = Date.today();
        o.Master_Opportunity_Subsidiary__c = '10 - The NPD Group, Inc.';
        o.StageName = 'Closed - Won';
        o.Billing_Details__c = 'Test';
        o.Billing_Contact_Info_Address__c = 'Test';
        o.Shipping_Contact_Info_Address__c = 'Test';
        insert o;
        
        Opportunity oActual = [SELECT id, StageName, Master_Opportunity_Subsidiary__c, Subsidiary_Customer__c, Subsidiary_Customer_Id__c
                   FROM Opportunity where id = :o.id];
        
        //Subsidiary_Customer__c sub = [select Id, Subsidiary__c, Account__c from Subsidiary_Customer__c where 
		//			id =: oActual.Subsidiary_Customer_Id__c ];
        System.assert(oActual.Subsidiary_Customer__c!= null);
					
		//System.assert(sub.Subsidiary__c == '10 - The NPD Group, Inc.');
        //System.assert(sub.Account__c == a.Id);
    }
}