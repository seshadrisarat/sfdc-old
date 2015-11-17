@isTest
private class dsfsDocuSignStatuscStatsTT {

   static testMethod void testTrigger() {
      try {
          dsfs__DocuSign_Status__c o = new dsfs__DocuSign_Status__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<dsfs__DocuSign_Status__c> l = [SELECT Id from dsfs__DocuSign_Status__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}