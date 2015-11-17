/**
 * Extension for the CompanyReferToInline and CompanyReferFromInline inline VF
 * pages.  Supports logging a "Refer To" or a "Refer From" referral record,
 * exposing a Referral prototype for input.
 *
 * @author Reshma - Company Referrals Polish
 * @author jfavors (Appirio) - polish
 */
public class ContactReferralExtension {
  public Referral__c helpRef { get; private set; }
  public String errorMsg { get; private set; }
  public String successMsg { get; private set; }

  private static final String ERROR_NO_COMPANY = 'Please select company.';
  private static final String DEFAULT_CALL_SUBJECT = 'Referral Call';

  private Contact contact;

  public ContactReferralExtension(ApexPages.StandardController stdController) {
    this.contact = (Contact) stdController.getRecord();

    this.helpRef = new Referral__c();
  }

  public void logCall() {
    if (this.helpRef.Company__c == null) {
      this.errorMsg = ERROR_NO_COMPANY;
      return;
    }

    Task activity;
    Referral__c referral;

    this.successMsg = '';
    this.errorMsg = '';

    // Create task (for activity history)
    activity = ReferralUtils.createTask(this.helpRef.Company__c,
      this.contact.Id, DEFAULT_CALL_SUBJECT, null);

    // Create Referral Record
    referral = ReferralUtils.createReferralToCall(this.helpRef.Company__c,
      this.contact.Id);

    try {
      insert activity;
      insert referral;
    } catch (Exception e) {
      errorMsg = e.getMessage();
    }

    if (String.isBlank(errorMsg)) {
      successMsg = Label.LogCallSuccess;
    }
  }

  public void logReferral() {
    if (this.helpRef.Company__c == null) {
      this.errorMsg = ERROR_NO_COMPANY;
      return;
    }

    Referral__c referral;

    this.successMsg = '';
    this.errorMsg = '';

    // Create Referral Record
    referral = ReferralUtils.createReferralFrom(this.helpRef.Company__c,
      this.contact.Id);

    try {
      insert referral;
    } catch (Exception e) {
      errorMsg = e.getMessage();
    }

    if (String.isBlank(errorMsg)) {
      successMsg = Label.LogCallSuccess;
    }
  }
}