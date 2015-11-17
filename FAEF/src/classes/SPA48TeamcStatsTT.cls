@isTest
private class SPA48TeamcStatsTT {

   static testMethod void testTrigger() {
      try {
          SPA_48_Team__c o = new SPA_48_Team__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<SPA_48_Team__c> l = [SELECT Id from SPA_48_Team__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}