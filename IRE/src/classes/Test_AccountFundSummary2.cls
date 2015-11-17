@IsTest(SeeAllData=false) 
public class Test_AccountFundSummary2{

  static testMethod void testgetAccountFundSummary2()
  {      
      Account ac = new Account(name='ac1');
      insert ac;
      Contact objContact = new Contact(accountid=ac.id,FirstName='Test 1', LastName='User 1');
      insert objContact;
      String i;
      Date myDate = date.newinstance(2008, 2, 17);
      Date NewDate = date.newinstance(2016, 2, 17);
      Fund__c fund = new Fund__c(Name='Test Fund', Availability_Include__c=TRUE, Fund_Acronym__c='IPCC');
      insert fund;
      Daily_Sale__c lstAr  = new Daily_Sale__c(Account__c=ac.id, Contact__c=objContact.id, Fund__c=fund.id, Sales_Date__c = myDate, Amount__c=2500);
      Daily_Sale__c lstAr1 = new Daily_Sale__c(Account__c=ac.id, Contact__c=objContact.id, Fund__c=fund.id, Sales_Date__c = myDate, Amount__c=2500);
      Daily_Sale__c lstAr2 = new Daily_Sale__c(Account__c=ac.id, Contact__c=objContact.id, Fund__c=fund.id, Sales_Date__c = NewDate, Amount__c=2500);
      Daily_Sale__c lstAr3 = new Daily_Sale__c(Account__c=ac.id, Contact__c=objContact.id, Fund__c=fund.id, Sales_Date__c = NewDate, Amount__c=2500);
      insert lstAr; insert lstAr1; insert lstAr2; insert lstAr3;

  
      test.startTest();
//   AccountFundSummary2 aaa = new AccountFundSummary2();
       ApexPages.StandardController sc = new ApexPages.StandardController(ac); 
       String accId = ApexPages.currentPage().getParameters().put('Id',ac.id);
     
       AccountFundSummary2 af = new AccountFundSummary2(sc);
       Map<string,Map<integer,String>>Myap= new Map<string,Map<integer,String>>();
       Map<Integer, String>MyinnerMap=new Map<Integer, String>();
       MyinnerMap.put(integer.valueOf(lstAr.Amount__c),lstAr.Fund__r.Fund_Acronym__c);
       Myap.put('Mytest',MyinnerMap);
       af.MapResults=Myap;
       af.getResults2();  

       AccountFundSummary2.currency(i);  
       test.stopTest();
  }
   
  
}