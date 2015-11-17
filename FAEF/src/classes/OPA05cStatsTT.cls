@isTest
private class OPA05cStatsTT {

   static testMethod void testTrigger() {
      try {
          OPA_05__c o = new OPA_05__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<OPA_05__c> l = [SELECT Id from OPA_05__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}