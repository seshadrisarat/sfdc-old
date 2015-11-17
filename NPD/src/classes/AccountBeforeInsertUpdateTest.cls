@isTest (seeAlldata=true)
private class AccountBeforeInsertUpdateTest {
  
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
  }
}