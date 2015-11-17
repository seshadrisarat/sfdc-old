/**
 * Controller for the CompanyReferralsFrom page. This page performs all the
 * functionality required to enter a referral from a contact.
 *
 * aId => account id
 * uId => user id
 * cId => contact id
 *
 * @author ForceLogic - original (Company Referrals - Referred From)
 * @author jfavors (Appirio) - polish
 */
public with sharing class CompanyReferralsFromController {
  public Referral__c helpRef { get; set; }

  public String selAccounts { get; set; }
  public String selUsers { get; set; }
  public String selContacts { get; set; }

  public List<SelectOption> selOptAccounts { get; set; }
  public List<SelectOption> selOptUsers { get; set; }
  public List<SelectOption> selOptContacts { get; set; }

  public String retURL { get; set; }
  public String aId { get; set; }
  public String cId { get; set; }
  public String uId { get; set; }

  public CompanyReferralsFromController() {

    //init ui objects
    this.helpRef = new Referral__c();
    this.selAccounts = null;
    this.selUsers = null;
    this.selContacts = null;

    //search, if any, for the given user/account/contact
    this.aId = ApexPages.currentPage().getParameters().get('aId');
    this.uId = ApexPages.currentPage().getParameters().get('uId');
    this.cId = ApexPages.currentPage().getParameters().get('cId');
    this.retURL = ApexPages.currentPage().getParameters().get('retURL');

    if (String.isBlank(this.retURL)) {
      this.retURL = '/';
    }

    String infoMessage = ApexPages.currentPage().getParameters().get('info');

    if (String.isNotBlank(infoMessage)) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.CONFIRM, infoMessage));
    }

    initSelectLists(new List<String>{this.cId},
      new List<String>{this.uId, UserInfo.getUserId()},
      new List<String>{this.aId});
  }

  private PageReference saveLists(Boolean back) {

    if (String.isBlank(selAccounts) || String.isBlank(selUsers) ||
        String.isBlank(selContacts)) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'Select at least one Company, User and Contact.'));
      initSelectLists(new List<String>(), new List<String>(),
        new List<String>());

      return null;
    }

    List<String> aList = (List<String>)JSON.deserialize(selAccounts,
      List<String>.class);
    List<String> uList = (List<String>)JSON.deserialize(selUsers,
      List<String>.class);
    List<String> cList = (List<String>)JSON.deserialize(selContacts,
      List<String>.class);

    if (aList.isEmpty() || uList.isEmpty() || cList.isEmpty()) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'Select at least one Company, User and Contact.'));
      initSelectLists(cList, uList, aList);

      return null;
    }

    //checkes to avoid duplicates
    //creates the query
    List<String> keys = new List<String>();

    for (String aId : aList) {
      for (String uId : uList) {
        for (String cId : cList) {
          keys.add(cId + uId + aId);
        }
      }
    }

    Set<String> alreadyPresentKeys = new Set<String>();
    for (Referral__c r :
        [Select Key__c From Referral__c Where Key__c IN :keys]) {
      alreadyPresentKeys.add(r.Key__c);
    }

    //creates objects
    List<Referral__c> newObjects = new List<Referral__c>();
    for (String aId : aList) {
      for (String uId : uList) {
        for (String cId : cList) {
          if (alreadyPresentKeys.contains(cId + uId + aId)) {
            continue;
          }
          newObjects.add(new Referral__c(
            Company__c = String.valueOf(aId),
            User__c = String.valueOf(uId),
            Contact__c = String.valueOf(cId),
            Type__c = 'Referred From'));
        }
      }
    }

    try {
      insert newObjects;
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'Unexpected error: ' + e.getMessage() +
        ((Test.isRunningTest()) ? '' + newObjects : '')));

      initSelectLists(aList, uList, cList);

      return null;
    }

    PageReference page;

    if (back) {
      page = new PageReference(this.retURL);
    } else {
      page = new PageReference('/apex/CompanyReferralsFrom');
      page.getParameters().put('aId', this.aId);
      page.getParameters().put('uId', this.uId);
      page.getParameters().put('cId', this.cId);
      page.getParameters().put('retURL', this.retURL);
      page.getParameters().put('info', 'Successfully created ' +
        (aList.size() * uList.size() * cList.size()) + ' referrals.' +
        ' If they already exists, they have not been created again.');
    }

    page.setRedirect(true);

    return page;
  }

  /* Inits options  */
  private void initSelectLists(List<String> cList, List<String> uList,
      List<String> aList) {
    this.selOptAccounts = new List<SelectOption>();
    this.selOptUsers = new List<SelectOption>();
    this.selOptContacts = new List<SelectOption>();

    for (Contact c : [Select Id, Name From Contact Where Id IN :cList]) {
      this.selOptContacts.add(new SelectOption(c.Id, c.Name));
    }

    for (User c : [Select Id, Name From User Where Id IN :uList]) {
      this.selOptUsers.add(new SelectOption(c.Id, c.Name));
    }

    for (Account c : [Select Id, Name From Account Where Id IN :aList]) {
      this.selOptAccounts.add(new SelectOption(c.Id, c.Name));
    }
  }

  public PageReference saveAndBack() {
    return saveLists(true);
  }

  public PageReference saveAndNew() {
    return saveLists(false);
  }

  public pageReference back() {
    PageReference page = new PageReference(this.retURL);
    page.setRedirect(true);

    return page;
  }

  public class CustomException extends Exception {}
}