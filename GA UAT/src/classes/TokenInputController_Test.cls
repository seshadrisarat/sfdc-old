/**
 * This class contains unit tests for validating the behavior of Apex class:
 * TokenInputController.
 *
 * @author Reshma
 */
@isTest
private class TokenInputController_Test {

  static Account testAccount;

  private static void createBulkAccounts() {
    Account testAcc;
    List<Account> bulkAccountList = new List<Account>();

    for (Integer i = 0; i <= 10; i++) {
      testAcc = new Account(Name = 'Test Acc' + i);
      bulkAccountList.add(testAcc);
    }

    insert bulkAccountList;
  }

  private static void createAccount() {
    testAccount = new Account(Name = 'Sample Test Acc');
    insert testAccount;
  }

  private static void createBulkContacts() {
    Contact testContact;
    list<Contact> bulkContactList = new List<Contact>();

    for (Integer i = 0; i <= 10; i++) {
      testContact = new Contact(LastName = 'Test LastName' + i,
            AccountId = testAccount.Id,
            Email = 'testemail@salesforce.com',
            Phone = '8789456210');
      bulkContactList.add(testContact);
    }

    insert bulkContactList;
  }

  static testMethod void testGetCompanySearchString() {
    TokenInputController controller;

    createBulkAccounts();

    Test.startTest();

    ApexPages.currentPage().getParameters().put('for','Company');
    ApexPages.currentPage().getParameters().put('q','test');

    controller = new TokenInputController();

    // TODO: More assertions, please
    System.assertNotEquals(null, controller.jsonOutput);

    Test.stopTest();
  }

  static testMethod void testGetContactSearchString() {
    TokenInputController controller;

    createAccount();
    createBulkContacts();

    Test.startTest();

    ApexPages.currentPage().getParameters().put('for','Contact');
    ApexPages.currentPage().getParameters().put('q','test');

    controller = new TokenInputController();

    // TODO: More assertions, please
    System.assertNotEquals(null, controller.jsonOutput);

    Test.stopTest();
  }
}