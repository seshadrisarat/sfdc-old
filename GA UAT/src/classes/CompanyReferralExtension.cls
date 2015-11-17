/**
 * Extension for the CompanyReferToInline and CompanyReferFromInline inline VF
 * pages.  Supports logging a "Refer To" or a "Refer From" referral record
 * from Company page, exposing a Referral prototype for Contact input.
 *
 * @author Reshma - Company Referrals Polish
 * @author jfavors (Appirio) - polish
 */
public class CompanyReferralExtension {
  public Referral__c helpRef { get; private set; }
  public String errorMsg { get; private set; }
  public String successMsg { get; private set; }

  private static final String ERROR_NO_CONTACT = 'Please select contact.';
  private static final String DEFAULT_CALL_SUBJECT = 'Referral Call';

  private Account company;

  public CompanyReferralExtension(ApexPages.StandardController stdController) {
    this.company = (Account) stdController.getRecord();

    this.helpRef = new Referral__c();
  }

  public void logCall() {
    if (this.helpRef.Contact__c == null) {
      this.errorMsg = ERROR_NO_CONTACT;
      return;
    }

    Task activity;
    Referral__c referral;

    this.successMsg = '';
    this.errorMsg = '';

    // Create task (for activity history)
    activity = ReferralUtils.createTask(this.company.Id,
      this.helpRef.Contact__c, DEFAULT_CALL_SUBJECT, null);

    // Create Referral Record
    referral = ReferralUtils.createReferralToCall(this.company.Id,
      this.helpRef.Contact__c);

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
    if (this.helpRef.Contact__c == null) {
      this.errorMsg = ERROR_NO_CONTACT;
      return;
    }

    Referral__c referral;

    this.successMsg = '';
    this.errorMsg = '';

    // Create Referral Record
    referral = ReferralUtils.createReferralFrom(this.company.Id,
      this.helpRef.Contact__c);

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