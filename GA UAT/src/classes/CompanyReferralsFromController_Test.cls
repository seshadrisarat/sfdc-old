/**
 * This class contains unit tests for validating the behavior of Apex class:
 * CompanyReferralsFromController.
 *
 * @author ForceLogic - original (Company Referrals - Referred From)
 * @author jfavors (Appirio) - polish
 */
@isTest
private class CompanyReferralsFromController_Test {

  static testMethod void unitTest1() {
    PageReference page = new PageReference('/');
    page.getParameters().put('info','message');

    Account acc = new Account(Name = 'x');
    Contact contact = new Contact(LastName = 'x');
    insert acc;
    insert contact;

    page.getParameters().put('aId',acc.Id);
    page.getParameters().put('cId',contact.Id);

    Test.setCurrentPage(page);

    Test.startTest();

    CompanyReferralsFromController controller =
      new CompanyReferralsFromController();

    System.assertEquals(1, controller.selOptAccounts.size(),
      'Why not 1 account selected by default?');
    System.assertEquals(1, controller.selOptContacts.size(),
      'Why not 1 contact selected by default?');
    System.assertEquals(1, controller.selOptUsers.size(),
      'Why not 1 user selected by default?');

    //nothing selected (selection text inputs are null)
    controller.saveAndNew();

    System.assertEquals(2, ApexPages.getMessages().size(),
      'Why not error message?' + ApexPages.getMessages());

    //nothing selected (selection text inputs are void arrays)
    controller.selAccounts = '[]';
    controller.selContacts = '[]';
    controller.selUsers = '[]';
    controller.saveAndNew();

    System.assertEquals(2, ApexPages.getMessages().size(),
      'Why not another error message? ' + ApexPages.getMessages());

    controller.selAccounts = '["' + acc.Id + '"]';
    controller.selContacts = '["' + contact.Id + '"]';
    controller.selUsers = '["' + UserInfo.getUserId() + '"]';
    controller.saveAndNew();

    System.assertEquals(2, ApexPages.getMessages().size(),
      'Why other error messages? ' + ApexPages.getMessages());
    System.assertEquals(1, [Select count() from Referral__c],
      'Why not 1 referrals on db?');

    //avoids duplicates
    controller.selAccounts = '["' + acc.Id + '"]';
    controller.selContacts = '["' + contact.Id + '"]';
    controller.selUsers = '["' + UserInfo.getUserId() + '"]';
    controller.saveAndBack();

    System.assertEquals(1, [Select count() from Referral__c],
      'Why not 1 referrals on db?');

    Test.stopTest();
  }

  static testMethod void lookupComponentTest() {
    Test.startTest();

    LookupAutocompleteController controller =
      new LookupAutocompleteController();
    insert new Account(Name = 'test', Phone='1234');

    List<Account> accounts =
      (List<Account>)LookupAutocompleteController.findSObjects(
        null, 'test', 'Phone');

    System.assertEquals(null, accounts, 'Why not null?');

    accounts = (List<Account>)LookupAutocompleteController.findSObjects(
      'Account', 'test', 'Phone');

    System.assertEquals(1, accounts.size(), 'Why not 1 account?');

    Test.stopTest();
  }
}