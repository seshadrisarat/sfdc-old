@isTest
private class bulkEditBurnReport_test {

  public static testMethod void testbulkEditBurnReport() {

      pageReference p = Page.bulkEditBurnReport;

      p.getParameters().put('id', [select id from Projects__c LIMIT 1].id );

      test.setCurrentPage( p );  

      bulkEditBurnReport bem = new bulkEditBurnReport();
      Projects__c ProjTest= bem.Proj;
      Burn_Report__c[] BRtest = bem.burn;
     
      bem.save();
      bem.cancel();

  }

}