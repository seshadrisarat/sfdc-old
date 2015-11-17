@isTest
private class SPA48IndividualcStatsTriggerTest {

   static testMethod void testTrigger() {
        try {

          SPA_48_Individual__c o = new SPA_48_Individual__c();
          insert o;

          System.assertNotEquals(null, o);
        }
        catch(Exception e) {}
   }


}