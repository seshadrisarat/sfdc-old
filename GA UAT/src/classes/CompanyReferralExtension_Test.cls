/**
 * This class contains unit tests for validating the behavior of Apex class:
 * CompanyReferralExtension.
 *
 * @author Reshma - Company Referrals Polish
 * @author jfavors (Appirio) - polish
 */
@isTest
private class CompanyReferralExtension_Test {

  static Account testAccount;
  static Contact testContact;

  private static void setUpData() {
    testAccount = new Account(Name = 'Test corp');
    insert testAccount;

    testContact = new Contact(
      LastName = 'Lname',
      AccountId = testAccount.Id,
      Email = 'testemail@salesforce.com',
      Phone = '8789456210');
    insert testContact;
  }

  static testMethod void testConstructor() {
    ApexPages.StandardController sc;
    CompanyReferralExtension extension;

    setUpData();

    Test.startTest();

    sc = new ApexPages.StandardController(testAccount);
    extension = new CompanyReferralExtension(sc);

    System.assertNotEquals(null, extension.helpRef);

    Test.stopTest();
  }

  static testMethod void testLogCall() {
    ApexPages.StandardController sc;
    CompanyReferralExtension extension;

    setUpData();

    Test.startTest();

    sc = new ApexPages.StandardController(testAccount);
    extension = new CompanyReferralExtension(sc);

    System.assertNotEquals(null, extension.helpRef);

    extension.helpRef.Contact__c = testContact.Id;
    extension.logCall();

    // TODO: Query Referral record and assert data values.

    System.assertEquals('', extension.errorMsg);
    System.assertEquals(Label.LogCallSuccess, extension.successMsg);

    Test.stopTest();
  }

  static testMethod void testLogReferral() {
    ApexPages.StandardController sc;
    CompanyReferralExtension extension;

    setUpData();

    Test.startTest();

    sc = new ApexPages.StandardController(testAccount);
    extension = new CompanyReferralExtension(sc);

    System.assertNotEquals(null, extension.helpRef);

    extension.helpRef.Contact__c = testContact.id;
    extension.logReferral();

    // TODO: Query Referral record and assert data values.

    System.assertEquals('', extension.errorMsg);
    System.assertEquals(Label.LogCallSuccess, extension.successMsg);

    Test.stopTest();
  }
}