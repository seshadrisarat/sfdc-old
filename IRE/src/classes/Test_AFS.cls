@IsTest(SeeAllData=true) 
public class Test_AFS{

  static testMethod void testgetAFS()
  {
      List<String> fundList = new List<String>{'IRESI-A','IRESI-T','IRESI-E','IREIT','IPCC','IDIV','ITP','IOPF','IOPF II','RPAI','IRRETI','IREC','IRC'};
      Account ac = new Account(name='ac1');
      insert ac;
      
      Contact objContact = new Contact(accountid=ac.id,FirstName='Test 1', LastName='User 1');
      insert objContact;
      
      for(String st : fundList){
          String i;
          Date myDate = date.newinstance(2008, 2, 17);
          Date NewDate = date.newinstance(2016, 2, 17);
          Fund__c fund = new Fund__c(Name='Test Fund', Availability_Include__c=TRUE, Fund_Acronym__c=st);
          insert fund;
          Daily_Sale__c lstAr  = new Daily_Sale__c(Account__c=ac.id, Contact__c=objContact.id, Fund__c=fund.id, Sales_Date__c = myDate,  Amount__c=2500);
          Daily_Sale__c lstAr1 = new Daily_Sale__c(Account__c=ac.id, Contact__c=objContact.id, Fund__c=fund.id, Sales_Date__c = myDate,  Amount__c=2500);
          Daily_Sale__c lstAr2 = new Daily_Sale__c(Account__c=ac.id, Contact__c=objContact.id, Fund__c=fund.id, Sales_Date__c = NewDate, Amount__c=2500);
          Daily_Sale__c lstAr3 = new Daily_Sale__c(Account__c=ac.id, Contact__c=objContact.id, Fund__c=fund.id, Sales_Date__c = NewDate, Amount__c=2500);
          insert lstAr;      insert lstAr1;      insert lstAr2;      insert lstAr3;
         
          ApexPages.StandardController sc = new ApexPages.StandardController(ac); 
          String accId = ApexPages.currentPage().getParameters().put('Id',ac.id);
          AFS af = new AFS(sc);
          Map<string,Map<integer,String>>Myap= new Map<string,Map<integer,String>>();
          Map<Integer, String>MyinnerMap=new Map<Integer, String>();
           
          MyinnerMap.put(integer.valueOf(lstAr.Amount__c),lstAr.Fund__r.Fund_Acronym__c);
          //MyinnerMap.put(2,'TBD');  
          Myap.put('Mytest',MyinnerMap);
          //af.MapResults=Myap;
          af.getResults2();  
          AFS.currency(i);  
 
      
      }     
   }
}