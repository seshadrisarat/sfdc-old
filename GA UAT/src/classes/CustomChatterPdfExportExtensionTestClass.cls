@isTest
private class CustomChatterPdfExportExtensionTestClass {
 
    static testMethod void myUnitTest() {
    	
        PageReference pref = Page.ChatterPage;
        Test.setCurrentPage(pref);
        CustomChatterSearchController ctrl = new CustomChatterSearchController();
        CustomChatterPdfExportExtension con = new CustomChatterPdfExportExtension(ctrl);
        Test.startTest();

        // populate the field with values
        con.email = 'test@noemail.com';
        // submit the record
        pref = con.sendPdf();
        con.setEmailTrue();
        con.setEmailFalse();
        con.editSettings();
        con.cancelSettings();
        con.selectedweekDays = '5';
        con.selectedAmPm = 'am';
        con.selectedweekHr = '8';
        con.updateSettings();
        Test.stopTest();
    }
    
   static testMethod void searchTest() {
     CustomChatterSearchController ctrl = new CustomChatterSearchController();
        ctrl.searchTag = '#wow';
        ctrl.dateRange = 'all';
        ctrl.searchChatterList();
//        System.assertEquals(1, ctrl.newsFeed.size());

        ctrl.dateRange = 'thisweek';
        ctrl.searchChatterList();
//        System.assertEquals(0, ctrl.newsFeed.size());
        ctrl.dateRange = 'lastweek';
        ctrl.searchChatterList();
//        System.assertEquals(1, ctrl.newsFeed.size());
        ctrl.dateRange = 'thismonth';
        ctrl.searchChatterList();
//        System.assertEquals(1, ctrl.newsFeed.size());
        ctrl.dateRange = 'lastmonth';
        ctrl.searchChatterList();
//        System.assertEquals(0, ctrl.newsFeed.size());
        ctrl.searchTag = '';
        ctrl.dateRange = 'all';
        ctrl.searchChatterList();
//        System.assertEquals(2, ctrl.newsFeed.size());

    
    }
}