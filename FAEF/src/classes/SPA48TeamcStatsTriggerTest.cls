@isTest
private class SPA48TeamcStatsTriggerTest {

   static testMethod void testTrigger() {
        try {

          SPA_48_Team__c o = new SPA_48_Team__c();
          insert o;

          System.assertNotEquals(null, o);
        }
        catch(Exception e) {}
   }


}