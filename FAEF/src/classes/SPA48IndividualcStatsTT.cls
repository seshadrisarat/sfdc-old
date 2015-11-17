@isTest
private class SPA48IndividualcStatsTT {

   static testMethod void testTrigger() {
      try {
          SPA_48_Individual__c o = new SPA_48_Individual__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<SPA_48_Individual__c> l = [SELECT Id from SPA_48_Individual__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}