/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CSCIntegrationTest {

  public static testMethod void testMyController() {


    // Csc.buildRequest('test');
    //  String nextPage = controller.save().getUrl();
    Profile p = [select id from profile where name = 'Standard User'];
    Account a = new Account(Name = 'Test Account');
    a.State_of_Incorporation__c = 'CA';
    a.ucc_name_search__c = 'TCBY';
    a.CSC_Order_Number__c = '74877477';
    insert a;
    User u = new User(alias = 'sta23', email = 'standarduser123@testorg.com',

      emailencodingkey = 'UTF-8', lastname = 'Testing',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p.Id,
      timezonesidkey = 'America/Los_Angeles', username = 'standard123user@testorg.com');

    insert u;

    CSC_Integration__c cs = new CSC_Integration__c();
    cs.Name = 'csc';
    cs.endpoint__c = 'endpoint';
    cs.login__c = 'login';
    cs.contact__c = '123';
    insert cs;
    System.debug('log');
    System.debug(a.id);
    System.debug('log');
    //SubmitOnlineSearch(a.id);
    GetDetailResults(a.id);

  }
  
  @future(callout = true)
  private static void SubmitOnlineSearch(String id) {


    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('CSC_SubmitOnlineSearch');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/xml');

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);
	System.debug('ilog');
    Account a = [Select id, Account.BillingState, Account.ucc_name_search__c from Account limit 1][0];

    System.debug('ilog');
    PageReference pageRef = Page.ucc_integration;
    Test.setCurrentPage(pageRef);
    // Add parameters to page URL
    ApexPages.currentPage().getParameters().put('id', a.id);
    ApexPages.currentPage().getParameters().put('debtor', 'TCBY');
    System.debug('xlog');
    UccController controller = new ucccontroller();
    System.debug('xlog');
    Ucc ucc = new Ucc();
    System.debug('ilog');
    //controller.submitUccSearch();
 
  }
  
  
   @future(callout = true)
  private static void GetDetailResults(String id) {

    
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();

    mock.setStaticResource('CSC_GetDetailResults');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/xml');
    Test.setMock(HttpCalloutMock.class, mock);
    Account a = [Select id, Account.BillingState, Account.ucc_name_search__c from Account limit 1][0];
    PageReference pageRef = Page.ucc_integration;
    Test.setCurrentPage(pageRef);
    // Add parameters to page URL
    ApexPages.currentPage().getParameters().put('id', a.id);
    ApexPages.currentPage().getParameters().put('debtor', 'TCBY');
    UccController controller = new ucccontroller();



    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);
    controller.setDebtor('TCBY');
    controller.getDebtor();
    System.debug('cp1');
    controller.submitOrder();
    System.debug('cp2');
    Ucc ucc1 = controller.uccItems[0];
    System.debug('cp3');
    ucc1.isSelected = true;
    System.debug('cp4');
    controller.uccItems[0] = ucc1;
    System.debug('cp5');
    controller.getItems();
    System.debug('cp6');
    controller.createUcs();
    controller.Cancel();

  }
  

  
  
  
  
  
}