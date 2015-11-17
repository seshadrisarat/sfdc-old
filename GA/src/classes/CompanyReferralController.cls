/**
 * Controller for the CompanyReferral page. This page performs all the
 * functionality required to refer a company to a contact.
 *
 * @author ForceDeveloper - original (Visualforce Company Referrals)
 * @author Reshma - Extending Company Referrals
 * @author Karanraj - Company Referrals - UX Enhancements
 * @author Thiyagarajan Selvaraj - Company Referrals - UX Enhancements
 * @author Reshma - Company Referrals Polish
 * @author sfdcdev11981 - Company Referrals Polish: Part II
 * @author jfavors (Appirio) - polish
 */
public with sharing class CompanyReferralController {

  public Account currentCompany { get; private set; }
  public Contact currentContact { get; private set; }

  public Set<String> selectedCompanyIds { get; private set; }
  public Set<String> selectedContactIds { get; private set; }
  public List<Account> selectedCompanies { get; private set; }
  public List<Contact> selectedContacts { get; private set; }
  public String selectedCompaniesParam { get; set;}
  public String selectedContactsParam { get; set; }

  public transient List<Messaging.SendEmailResult> lastEmailResults {
    get; private set;
  }
  public String redirectUrl { get; private set; }

  public String ccString { get; set; }
  public String emailSubject { get; set; }
  public String emailBody { get; set; }

  private String companyId;
  private String contactId;
  private CompanyReferral__c companyReferral;

  // Constants
  private static final String ERROR_BLANK_CONTACT = 'Please select a Contact';
  private static final String ERROR_BLANK_COMPANY = 'Please select a Company';
  private static final Integer MAX_EMAIL_LIMIT = 10;
  private static final String SIGNATURE_NOTE =
    'Note: To view the detail of the referral, visit the link below:';

  /**
   * Constructor for initialization of variables
   */
  public CompanyReferralController() {
    List<Account> matchingCompanies;
    List<Contact> matchingContacts;

    // Init
    this.selectedCompanyIds = new Set<String>();
    this.selectedContactIds = new Set<String>();
    this.selectedCompanies = new List<Account>();
    this.selectedContacts = new List<Contact>();

    // Pre-load default subject and email body
    this.emailSubject = Label.Email_Subject;
    this.emailBody = String.format('{0}\n\n{1}\n\n{2}\n{3}', new String[] {
      Label.Referral_Greeting, Label.Referral_Body, Label.Referral_Closing,
      UserInfo.getName()
    });

    // Build current contact/company context and redirect URL
    this.companyId = ApexPages.currentPage().getParameters().get('companyId');
    this.contactId = ApexPages.currentPage().getParameters().get('contactId');
    this.redirectUrl = ApexPages.currentPage().getParameters().get('retURL');

    if (String.isNotBlank(this.companyId)) {
      matchingCompanies = [select Name
                          from Account
                          where Id = :this.companyId];
      if (!matchingCompanies.isEmpty()) {
        this.currentCompany = matchingCompanies[0];
      }
    }

    if (String.isNotBlank(this.contactId)) {
      matchingContacts = [select Name, Email
                          from Contact
                          where Id = :this.contactId];
      if (!matchingContacts.isEmpty()) {
        this.currentContact = matchingContacts[0];
      }
    }

    if (String.isBlank(this.redirectUrl)) {
      // Redirect home, if return URL not provided.
      this.redirectUrl = '/';
    }

    this.companyReferral = CompanyReferral__c.getInstance();
  }

  /**
   * This method handles the functionality for cancel link
   * If an Account Id was passed as a parameter, redirects to Account detail.
   * Otherwise, redirects to the home page.
   */
  public PageReference cancel() {
    return new PageReference(this.redirectUrl);
  }

  /**
   * This method is called from action function when log call button is clicked.
   * This method only fetches the parameters. Rest of the functionality is
   * delegated to other functions.
   */
  public PageReference logCall() {
    try {
      formSelectedLists();

      return createCallData();
    } catch (Exception e) {
      ApexPages.addMessages(e);

      return null;
    }
  }

  /**
   * This method is called from action function when send email button is
   * clicked. This method only fetches the parameters. Rest of the functionality
   * is delegated to other functions.
   */
  public PageReference sendEmail() {
    try {
      formSelectedLists();

      return createEmailData();
    } catch (Exception e) {
      ApexPages.addMessages(e);

      return null;
    }
  }

  private void formSelectedLists() {
    // Build list of selected company and contact Ids
    if (String.isNotBlank(selectedCompaniesParam)) {
      this.selectedCompanyIds.addAll(selectedCompaniesParam.split(','));
    }

    if (this.currentCompany != null) {
      this.selectedCompanyIds.add(this.currentCompany.Id);
    }

    if (String.isNotBlank(selectedContactsParam)) {
      this.selectedContactIds.addAll(selectedContactsParam.split(','));
    }

    if (this.currentContact != null) {
      this.selectedContactIds.add(this.currentContact.Id);
    }

    // Build list of the related company and contact records
    if (!this.selectedCompanyIds.isEmpty()) {
      this.selectedCompanies = [SELECT Id, Name
                                FROM Account
                                WHERE Id IN :this.selectedCompanyIds];
    }
    if (!this.selectedContactIds.isEmpty()) {
      this.selectedContacts = [SELECT Id, Name, Email
                               FROM Contact
                               WHERE Id IN :this.selectedContactIds];
    }
  }

  private PageReference createEmailData() {
    return createData(true);
  }

  private PageReference createCallData() {
    return createData(false);
  }

  /**
   * This method performs all the core functionality.
   * It sends emails in case of send email functionality.
   * Creates data for referral and activity history.
   */
  private PageReference createData(Boolean isEmail) {
    String subject, body;
    Task activity;
    Referral__c referral;
    List<Task> activityList = new List<Task>();
    List<Referral__c> referralList = new List<Referral__c>();
    List<String> ccRecipients = new List<String> ();
    Map<String, String> uniqueCCcheck = new Map<String, String>();
    List<Messaging.SingleEmailMessage> messages =
      new List<Messaging.SingleEmailMessage>();

    // Validate & build ccRecipients
    if (String.isNotBlank(this.ccString)) {
      for (String ccEmail : this.ccString.split('\\;')) {
        if (String.isBlank(ccEmail)) {
          continue;
        }

        if (uniqueCCcheck.get(ccEmail) == null) {
          ccRecipients.add(ccEmail);
          uniqueCCcheck.put(ccEmail, ccEmail);
        }
      }
    }

    // Empty checks for company & contact
    if (this.selectedContacts.isEmpty()) {
      ApexPages.Message errorMsg =
        new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_BLANK_CONTACT);
      ApexPages.addMessage(errorMsg);
      return null;
    }

    if (this.selectedCompanies.isEmpty()) {
      ApexPages.Message errorMsg =
        new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_BLANK_COMPANY);
      ApexPages.addMessage(errorMsg);
      return null;
    }

    // checking the size for salesforce limit & requirement allowing only 10
    // it can be set to 100 if required
    if (isEmail && isEmailAllowed() &&
        this.selectedContacts.size() * this.selectedCompanies.size() >=
          MAX_EMAIL_LIMIT) {
      ApexPages.Message errorMsg =
        new ApexPages.Message(ApexPages.Severity.ERROR,
          Label.Max_Email_Limit_Error);
      ApexPages.addMessage(errorMsg);
      return null;
    }

    for (Contact contact : this.selectedContacts) {
      for (Account company : this.selectedCompanies) {
        // Form email subject
        subject = this.emailSubject.replace(ReferralUtils.ACCOUNT_PLACEHOLDER,
          company.Name);

        // Form email body
        body = this.emailBody.replace(ReferralUtils.CONTACT_PLACEHOLDER,
          contact.Name);
        body = body.replace(ReferralUtils.ACCOUNT_PLACEHOLDER, company.Name);

        // Add SFDC link to internal/approved-domain contacts only
        if (String.isNotBlank(contact.Email) &&
            String.isNotBlank(Label.Approved_Referral_Domains) &&
            Label.Approved_Referral_Domains.contains(
              contact.Email.substringAfter('@'))) {
          body += String.format('\n\n\n{0}\n{1}/{2}', new String[] {
            SIGNATURE_NOTE,
            URL.getSalesforceBaseUrl().toExternalForm(),
            company.Id
          });
        }

        if (isEmail && isEmailAllowed()) {
          // Form the email object
          Messaging.SingleEmailMessage message =
            new Messaging.SingleEmailMessage();
          //message.setBccAddresses(new List<String>{ UserInfo.getUserEmail() });
          //message.setBccSender(true);
          message.setCcAddresses(ccRecipients);
          message.setSubject(subject);
          message.setSaveAsActivity(true);
          message.setPlainTextBody(body);
          message.setSenderDisplayName(UserInfo.getName());
          message.setTargetObjectId(contact.Id);
          message.setUseSignature(true);
          messages.add(message);
        }

        // Create task (for activity history)
        activity =
          ReferralUtils.createTask(company.Id, contact.Id, subject, body);
        activityList.add(activity);

        // Create Referral Record
        if (isEmail) {
          referral =
            ReferralUtils.createReferralToEmail(company.Id, contact.Id);
        } else {
          referral = ReferralUtils.createReferralToCall(company.Id, contact.Id);
        }

        referralList.add(referral);
      }
    }

    try {
      if (isEmail && isEmailAllowed()) {
        this.lastEmailResults = Messaging.sendEmail(messages);
      }

      insert activityList;
      insert referralList;
    } catch (Exception e) {
      ApexPages.addMessages(e);

      return null;
    }

    return new PageReference(this.redirectUrl);
  }

  private Boolean isEmailAllowed() {
    return this.companyReferral != null &&
      this.companyReferral.Allow_Email__c != null &&
      companyReferral.Allow_Email__c;
  }
}