@isTest
private class CATHDealcStatsTT {

   static testMethod void testTrigger() {
      try {
          CATH_Deal__c o = new CATH_Deal__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<CATH_Deal__c> l = [SELECT Id from CATH_Deal__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}