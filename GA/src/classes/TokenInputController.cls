/**
 * Controller for TokenInputHelper VF page to construct JSON results of
 * Contacts or Accounts based on a query term ('q').
 *
 * @author Reshma - Company Referrals Polish
 * @author jfavors (Appirio) - polish
 */
public class TokenInputController {

  public String jsonOutput { get; private set; }

  public TokenInputController() {
    String forObject = ApexPages.currentPage().getParameters().get('for');

    if (forObject.equalsIgnoreCase('Company')) {
      jsonOutput = getCompanySearchString();
    } else if (forObject.equalsIgnoreCase('Contact')) {
      jsonOutput = getContactSearchString();
    }
  }

  private String getCompanySearchString() {
    String searchText = ApexPages.currentPage().getParameters().get('q');
    String companySearchString = '[';
    List<Account> accList =
      LookupAutocompleteController.findSObjects('Account', searchText,
        'Billingcity, BillingState, BillingPostalCode');

    for (Account acc : accList) {
      companySearchString += '{"id":"' + acc.Id +
        '","name":"' + escapeDoubleQuotes(acc.Name) +
        '","city":"' + acc.BillingCity + '","state":"' + acc.BillingState +
        '","code":"' + acc.BillingPostalCode + '"},';
    }

    companySearchString = companySearchString.removeEnd(',');
    companySearchString += ']';

    return companySearchString;
  }

  private String getContactSearchString() {
    String searchText = ApexPages.currentPage().getParameters().get('q');
    String contactSearchString = '[';

    List<Contact> contactList =
      LookupAutocompleteController.findSObjects('Contact', searchText,
        'Email, Account.Name');

    for (Contact cont : contactList) {
      contactSearchString += '{"id":"' + cont.Id +
        '","name":"' + escapeDoubleQuotes(cont.Name) +
        '","email":"' + cont.Email +
        '","company":"' + escapeDoubleQuotes(cont.Account.Name) + '"},';
    }

    contactSearchString = contactSearchString.removeEnd(',');
    contactSearchString += ']';

    return contactSearchString;
  }

  private static String escapeDoubleQuotes(String value) {
    return (value == null) ? null : value.replace('"', '\\"');
  }
}