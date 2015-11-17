@isTest
private class bulkEditMilestones_test {

  public static testMethod void testBulkEditMilestones() {

      pageReference p = Page.bulkEditMilestone;

      p.getParameters().put('id', [select id from Projects__c LIMIT 1].id );

      test.setCurrentPage( p );  

      bulkEditMilestones bem = new bulkEditMilestones();
      Projects__c ProjTest= bem.Proj;
      Milestones__c[] Mtest = bem.milestone;
     
      bem.save();
      bem.cancel();

  }

}