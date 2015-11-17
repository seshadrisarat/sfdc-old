@isTest (seeAlldata=true)
private class SalesOrderCreatedDateInsertTest {
  
  static testMethod void myUnitTest(){
  
      Account acc = new Account();
      acc.Name='Test';
      acc.Account_Owner_2__c= acc.OwnerId;
      acc.netsuite_conn__Celigo_Update__c = true;
      
      acc.Type = 'NPD Customer';    
      acc.Industry = 'Automotive'; 
      acc.CurrencyIsoCode = 'USD';
      acc.AccountClass__c = 'Automotive Services';
      acc.AccountBU__c = 'U.S. Automotive';
      acc.Account_Sector__c = 'U.S. Hardlines';
      acc.BillingCountry = 'United States';
      acc.BillingStreet = '25 Main St';
      acc.BillingCity = 'Dallas';
      acc.BillingState = 'Texas';
      acc.BillingPostalCode = '75201';
      acc.Fiscal_Code_Italy__c = null;
     // acc.Parent.type= null;
      acc.VAT_Number__c  = null;
                 
      insert acc;
      
      Order ord = new Order();
      ord.Accountid = acc.id;
      ord.netsuite_conn__NetSuite_Order_Date__c = date.today();
      ord.EffectiveDate = date.today();
      ord.Status = 'Draft';
      
      insert ord;
      
      Opportunity opp = new Opportunity(  LOB_Summary__c='/USA - 2500/USA - 3100', 
            Sales_Order_Created_Date__c = date.today(),
            TotalOpportunityQuantity=3.00, 
            SubscriptionAmount__c=375200, 
            CloseDate=Date.today(),
            TotalContractAmount__c=490755, 
            MasterOpportunityDept__c='USA - 2500 - NET', 
            Opportunity_Brief_Description__c='Template', 
            Probability=99, 
            Amount=490755.00, 
            CurrencyIsoCode='USD', 
            Cash_or_Barter__c='Cash', 
            Name='Template Opp-USA - 2500-Cloned-USD', 
            StageName='Renew',
            MasterOpportunityBU__c='FBS',
            Master_Opportunity_Sector__c = 'U.S. Hardlines',
            AccountId = acc.Id,
            Type = 'Existing Customer');

        insert opp;
  }
}