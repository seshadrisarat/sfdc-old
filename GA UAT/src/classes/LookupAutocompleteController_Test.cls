/**
 * This class contains unit tests for validating the behavior of Apex class:
 * CompanyReferralsFromController.
 *
 * @author Reshma - Company Referrals Polish
 * @author jfavors (Appirio) - polish
 */
@isTest
private class LookupAutocompleteController_Test {

  static testMethod void testFindSObjects() {
    SObject[] lookupResults;
    Account testAccount;
    List<Account> testAccounts;

    testAccounts = createTestData();

    Test.startTest();

    // 1. Test handled appropriately with all null or empty strings
    lookupResults = LookupAutocompleteController.findSObjects(null, null, null);

    System.assertEquals(null, lookupResults);

    lookupResults = LookupAutocompleteController.findSObjects('', '', '');

    System.assertEquals(null, lookupResults);

    // 2. Test with just 'obj'
    lookupResults =
      LookupAutocompleteController.findSObjects('Account', null, null);

    System.assertNotEquals(null, lookupResults);
    System.assertEquals(10, lookupResults.size());

    // 3. Test with 'obj' and 'query'
    lookupResults =
      LookupAutocompleteController.findSObjects('Account', 'searchText', null);

    System.assertNotEquals(null, lookupResults);
    System.assertEquals(0, lookupResults.size());

    lookupResults =
      LookupAutocompleteController.findSObjects('Account', 'Test Account', null);

    System.assertNotEquals(null, lookupResults);
    System.assertEquals(10, lookupResults.size());

    lookupResults =
      LookupAutocompleteController.findSObjects('Account', '2', null);

    System.assertNotEquals(null, lookupResults);
    System.assertEquals(1, lookupResults.size());

    testAccount = ((List<Account>)lookupResults)[0];

    System.assertEquals(testAccounts[2].Name, testAccount.Name);

    // 4. Test with 'obj', 'query', and 'additionalFields'
    lookupResults =
      LookupAutocompleteController.findSObjects('Account', 'searchText',
        'BillingCity, BillingState, BillingPostalCode');

    System.assertNotEquals(null, lookupResults);
    System.assertEquals(0, lookupResults.size());

    lookupResults =
      LookupAutocompleteController.findSObjects('Account', 'City', null);

    System.assertNotEquals(null, lookupResults);
    System.assertEquals(0, lookupResults.size());

    lookupResults =
      LookupAutocompleteController.findSObjects('Account', 'City',
        'BillingCity, BillingState, BillingPostalCode');

    System.assertNotEquals(null, lookupResults);
    System.assertEquals(10, lookupResults.size());

    lookupResults =
      LookupAutocompleteController.findSObjects('Account', '2',
        'BillingCity, BillingState, BillingPostalCode');

    System.assertNotEquals(null, lookupResults);
    System.assertEquals(1, lookupResults.size());

    testAccount = ((List<Account>)lookupResults)[0];

    System.assertEquals(testAccounts[2].Name, testAccount.Name);
    System.assertEquals(testAccounts[2].BillingCity, testAccount.BillingCity);

    Test.stopTest();
  }

  private static List<Account> createTestData() {
    Account testAccount;
    List<Account> testAccounts = new List<Account>();

    for (Integer i = 0; i < 10; i++) {
      testAccount = new Account(
        Name = 'Test Account ' + i,
        BillingCity = 'City ' + i);
      testAccounts.add(testAccount);
    }

    insert testAccounts;

    return testAccounts;
  }
}