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
private class CSCServiceTest {

  public static testMethod void submitSearchTest() {

    CSC_Integration__c cs = new CSC_Integration__c();
    cs.Name = 'csc';
    Account a = new Account(Name = 'Test Account');
    //a.BillingState = 'pa';
    a.State_of_Incorporation__c = 'CA';
    a.ucc_name_search__c = 'TCBY';
    a.CSC_Order_Number__c = '74877477';
    insert a;

    cs.endpoint__c = 'endpoint';
    cs.login__c = 'login';
    cs.contact__c = '123';
    insert cs;
    SubmitOnlineSearch(a.id);
    GetDetailResults();

  }

  @future(callout = true)
  private static void SubmitOnlineSearch(String id) {

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('CSC_SubmitOnlineSearch');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/xml');

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    // Call the method that performs the callout
    CSC.updateUCCRecord(id);
    //submitOnlineSearch('CA', 'TCBY', '123');

    //System.assertEquals(order_id, '74877477');
  }
  @future(callout = true)
  private static void GetDetailResults() {

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('CSC_GetDetailResults');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/xml');

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    // Call the method that performs the callout

    String xml = CSC.getDetailResults('74877477');
    CSC.getSecuredNames(xml, 'TCBY');
    //System.assertEquals(order_id,'88795499');
  }

}