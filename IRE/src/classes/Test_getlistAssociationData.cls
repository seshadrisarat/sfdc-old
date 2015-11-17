@IsTest
public class Test_getlistAssociationData {

  static testMethod void testgetlistAssociationData()
  {
       Account ac = new Account(name='ac1');
       insert ac;
       Contact ct1 = new Contact(accountid=ac.id,FirstName='Test 1', LastName='User 1');
       insert ct1;
       Contact ct2 = new Contact(accountid=ac.id,FirstName='Test 2', LastName='User 2');
       insert ct2;

       List<Association__c> listAssociation1 = new List<Association__c>();
       Association__c a = new Association__c(ContactOne__c=ct1.id, Contact_One_Notes__c='Test1', ContactTwo__c=ct2.id, Contact_Two_Notes__c='Test2');
       listAssociation1.add(a);
       insert listAssociation1;
       
       List<Association__c> listAssociation2 = new List<Association__c>();
       Association__c b = new Association__c(ContactOne__c=ct2.id, Contact_One_Notes__c='Test1', ContactTwo__c=ct1.id, Contact_Two_Notes__c='Test2');
       listAssociation2.add(b);
       insert listAssociation2;
       
       test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ct1);
        getlistAssociationData testDDPlan = new getlistAssociationData(sc);
       String conId = ApexPages.currentPage().getParameters().put('Id',ct1.id);
       getlistAssociationData assoc= new getlistAssociationData (sc);
       assoc.populateAssociationdata();
      
       test.stopTest();
  }
}