/**
 * This class contains unit tests for validating the behavior of Apex class:
 * CompanyReferralController.
 *
 * @author ForceDeveloper - original (Visualforce Company Referrals)
 * @author Reshma - Extending Company Referrals
 * @author Karanraj - Company Referrals - UX Enhancements
 * @author Reshma - Company Referrals Polish
 * @author jfavors (Appirio) - polish
 * @author sfdcdev11981 - Update test methods to support changes done to CompanyReferralController class : topcoder:30039057
 */
@isTest
private class CompanyReferralController_Test {

  static Account testAccount;
  static Contact testContact;
  static List<Account> bulkAccountList;

  private static void setUpData() {
    Account testAccount1;
    CompanyReferral__c companyReferral;
    List<Account> testAccounts = new List<Account>();

    testAccount = new Account(Name = 'Test corp');
    testAccounts.add(testAccount);

    testAccount1 = new Account(Name = 'Xyz corp');
    testAccounts.add(testAccount1);

    insert testAccounts;

    testContact = new Contact(
      LastName = 'Lname',
      AccountId = testAccount.Id,
      Email = 'jason+test.contact@cloudspokes.com',
      Phone = '8789456210');
    insert testContact;

    companyReferral = new CompanyReferral__c(Allow_Email__c = true);
    insert companyReferral;
  }

  private static void createBulkAccounts() {
    Account testAcc;
    bulkAccountList = new List<Account>();

    for (Integer i = 0; i <= 10; i++) {
      testAcc = new Account(Name = 'Test Acc' + i);
      bulkAccountList.add(testAcc);
    }
    insert bulkAccountList;
  }

  static testMethod void testConstructor() {
    CompanyReferralController controller;

    setUpData();

    Test.startTest();

    controller = new CompanyReferralController();

    System.assertNotEquals(null, controller.selectedCompanyIds);
    System.assertNotEquals(null, controller.selectedContactIds);
    System.assertNotEquals(null, controller.selectedCompanies);
    System.assertNotEquals(null, controller.selectedContacts);
    System.assertEquals(0, controller.selectedCompanyIds.size());
    System.assertEquals(0, controller.selectedContactIds.size());
    System.assertEquals(0, controller.selectedCompanies.size());
    System.assertEquals(0, controller.selectedContacts.size());
    System.assertEquals(null, controller.currentCompany);
    System.assertEquals(null, controller.currentContact);

    ApexPages.currentPage().getParameters().put('companyId',
      String.valueOf(testAccount.Id));

    controller = new CompanyReferralController();

    System.assertNotEquals(null, controller.currentCompany);
    System.assertEquals(testAccount.Id, controller.currentCompany.Id);
    System.assertEquals(null, controller.currentContact);

    ApexPages.currentPage().getParameters().put('contactId',
      String.valueOf(testContact.Id));

    controller = new CompanyReferralController();
    System.assertNotEquals(null, controller.currentCompany);
    System.assertEquals(testAccount.Id, controller.currentCompany.Id);
    System.assertNotEquals(null, controller.currentContact);
    System.assertEquals(testContact.Id, controller.currentContact.Id);

    Test.stopTest();
  }

  static testMethod void testCancel() {
    CompanyReferralController controller;
    PageReference cancelPage;

    setUpData();

    Test.startTest();

    controller = new CompanyReferralController();

    System.assertEquals(null, controller.currentCompany);

    cancelPage = controller.cancel();

    System.assertNotEquals(null, cancelPage);
    System.assertEquals('/', cancelPage.getUrl());

    ApexPages.currentPage().getParameters().put('companyId',
      String.valueOf(testAccount.Id));
    //topcoder:30039057 - added this parameter to set retURL 
    ApexPages.currentPage().getParameters().put('retURL', '/'+ testAccount.Id);

    controller = new CompanyReferralController();

    System.assertNotEquals(null, controller.currentCompany);
    System.assertEquals(testAccount.Id, controller.currentCompany.Id);

    cancelPage = controller.cancel();

    System.assertNotEquals(null, cancelPage);
    System.assertEquals('/' + testAccount.Id, cancelPage.getUrl());

    Test.stopTest();
  }

  static testMethod void testSendEmail() {
    CompanyReferralController controller;
    PageReference sendPage;
    List<Referral__c> referrals;
    Map<String, String> currentParams;

    setUpData();

    Test.startTest();

    currentParams = ApexPages.currentPage().getParameters();
    currentParams.put('companyId', String.valueOf(testAccount.Id));
    currentParams.put('contactId', String.valueOf(testContact.Id));
    
    //topcoder:30039057 - added this parameter to set retURL 
    currentParams.put('retURL', '/'+ testAccount.Id);

    controller = new CompanyReferralController();
    controller.ccString = 'jason+cc@cloudspokes.com;jason+cc2@cloudspokes.com';

    sendPage = controller.sendEmail();

    System.assertNotEquals(null, sendPage, ApexPages.getMessages());
    System.assertEquals('/' + testAccount.Id, sendPage.getUrl());
    System.assertEquals(1, controller.selectedCompanyIds.size());
    System.assertEquals(1, controller.selectedContactIds.size());
    System.assertNotEquals(null, controller.lastEmailResults);
    System.assertEquals(1, controller.lastEmailResults.size());
    System.assertEquals(true, controller.lastEmailResults[0].success);

    referrals = [select Contact__c,
                        Company__c,
                        Medium__c
                 from Referral__c];

    System.assertEquals(1, referrals.size());
    System.assertEquals(testAccount.Id, referrals[0].Company__c);
    System.assertEquals(testContact.Id, referrals[0].Contact__c);
    System.assertEquals('Email', referrals[0].Medium__c);

    Test.stopTest();
  }

  static testMethod void testSendEmailLimitError() {
    CompanyReferralController controller;
    PageReference sendPage;
    String companyIds = '';
    List<Referral__c> referrals;
    Map<String, String> currentParams;

    setUpData();
    createBulkAccounts();

    Test.startTest();

    currentParams = ApexPages.currentPage().getParameters();
    currentParams.put('companyId', String.valueOf(testAccount.Id));
    currentParams.put('contactId', String.valueOf(testContact.Id));

    controller = new CompanyReferralController();

    for (Account acc : bulkAccountList) {
      controller.selectedCompanyIds.add(acc.Id);
    }

    sendPage = controller.sendEmail();

    System.assertEquals(12, controller.selectedCompanyIds.size());
    System.assertEquals(1, controller.selectedContactIds.size());
    System.assertEquals(null, sendPage);
    System.assertEquals(1, ApexPages.getMessages().size());
    System.assertEquals(Label.Max_Email_Limit_Error,
      ApexPages.getMessages()[0].getSummary());

    Test.stopTest();
  }

  static testMethod void testSendEmailNoContact() {
    CompanyReferralController controller;
    PageReference sendPage;
    List<Referral__c> referrals;
    Map<String, String> currentParams;

    setUpData();

    Test.startTest();

    currentParams = ApexPages.currentPage().getParameters();
    currentParams.put('companyId', String.valueOf(testAccount.Id));

    controller = new CompanyReferralController();

    sendPage = controller.sendEmail();

    System.assertEquals(null, sendPage);
    System.assertEquals(1, controller.selectedCompanyIds.size());
    System.assertEquals(0, controller.selectedContactIds.size());
    System.assertEquals(1, ApexPages.getMessages().size());
    System.assertEquals('Please select a Contact',
      ApexPages.getMessages()[0].getSummary());

    Test.stopTest();
  }

  static testMethod void testSendEmailNoCompany() {
    CompanyReferralController controller;
    PageReference sendPage;
    List<Referral__c> referrals;
    Map<String, String> currentParams;

    setUpData();

    Test.startTest();

    currentParams = ApexPages.currentPage().getParameters();
    currentParams.put('contactId', String.valueOf(testContact.Id));

    controller = new CompanyReferralController();

    sendPage = controller.sendEmail();

    System.assertEquals(null, sendPage);
    System.assertEquals(0, controller.selectedCompanyIds.size());
    System.assertEquals(1, controller.selectedContactIds.size());
    System.assertEquals(1, ApexPages.getMessages().size());
    System.assertEquals('Please select a Company',
      ApexPages.getMessages()[0].getSummary());

    Test.stopTest();
  }

  static testMethod void testLogCall() {
    CompanyReferralController controller;
    PageReference logCallPage;
    List<Referral__c> referrals;
    Map<String, String> currentParams;

    setUpData();

    Test.startTest();

    currentParams = ApexPages.currentPage().getParameters();
    currentParams.put('companyId', String.valueOf(testAccount.Id));
    currentParams.put('contactId', String.valueOf(testContact.Id));
    //topcoder:30039057 - added this parameter to set retURL 
    currentParams.put('retURL', '/'+ testAccount.Id);

    controller = new CompanyReferralController();

    logCallPage = controller.logCall();

    System.assertNotEquals(null, logCallPage, ApexPages.getMessages());
    System.assertEquals('/' + testAccount.Id, logCallPage.getUrl());
    System.assertEquals(1, controller.selectedCompanyIds.size());
    System.assertEquals(1, controller.selectedContactIds.size());

    referrals = [select Contact__c,
                        Company__c,
                        Medium__c
                 from Referral__c];

    System.assertEquals(1, referrals.size());
    System.assertEquals(testAccount.Id, referrals[0].Company__c);
    System.assertEquals(testContact.Id, referrals[0].Contact__c);
    System.assertEquals('Call', referrals[0].Medium__c);

    Test.stopTest();
  }
}