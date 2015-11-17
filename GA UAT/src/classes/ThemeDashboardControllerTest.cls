//S-179420 - Created by Kanchan Palhora on 1/8/2014
//Created to cover class ThemeDashboardController

@isTest 
private class ThemeDashboardControllerTest {

  private static testMethod void themeDashboardControllerTest() {
    
    Test.StartTest();
    ThemeDashboardController tdc = new ThemeDashboardController();

    List<ThemeDashboardController.LineItem> lineItems = tdc.getLineItems();
    ThemeDashboardController.LineItem li1 = new ThemeDashboardController.LineItem();
    ThemeDashboardController.LineItem li2 = new ThemeDashboardController.LineItem('TestName', 'Active', 'High');
    
    Test.StopTest();
  }
}