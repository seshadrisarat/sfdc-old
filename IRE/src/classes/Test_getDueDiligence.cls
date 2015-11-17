@IsTest(SeeAllData=true) 
public class Test_getDueDiligence{

  static testMethod void testgetDueDiligence()
  {
      
      Account ac = new Account(name='ac1');
      insert ac;
      Contact objContact = new Contact(accountid=ac.id,FirstName='Test 1', LastName='User 1');
      insert objContact ;

      Fund__c fund = new Fund__c(Name='Test Fund', Availability_Include__c=TRUE, Fund_Acronym__c='IPCC');
      insert fund;
      
       List<Due_Diligence__c> listDueDiligence = new List<Due_Diligence__c>();
       Due_Diligence__c b = new Due_Diligence__c(Name='S A', Account__c=ac.id, Fund__c=fund.id,Release_Date__c =system.TODAY().addDays(-4), Received_Approval__c= TRUE);
       listDueDiligence.add(b);
       insert listDueDiligence;
      
          test.startTest();
          ApexPages.StandardController sc = new ApexPages.StandardController(objContact);
          getDueDiligence testDDPlan = new getDueDiligence(sc);
          String conId = ApexPages.currentPage().getParameters().put('Id',objContact.id);
        
          getDueDiligence  gdd = new getDueDiligence(sc);
          gdd.populateDueDiligencedata(conId);
          test.stopTest();
     
  }
}