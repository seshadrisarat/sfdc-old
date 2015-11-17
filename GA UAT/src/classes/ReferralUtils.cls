/**
 * Central utility class for common actions around Referrals.
 *
 * @author Utkrash - original.
 * @author jfavors (Appirio) - polish
 */
public class ReferralUtils {

  public static final String STATUS_COMPLETED = 'Completed';
  public static final String TYPE_REFERRED_TO = 'Refer To';
  public static final String TYPE_REFERRED_FROM = 'Refer From';
  public static final String MEDIUM_EMAIL = 'Email';
  public static final String MEDIUM_CALL = 'Call';
  public static final String CONTACT_PLACEHOLDER = '{!Contact.Name}';
  public static final String ACCOUNT_PLACEHOLDER = '{!Account.Name}';

  /**
   * Factory method for creating Referral record.
   */
  public static Referral__c createReferral(Id companyId, Id contactId,
      String type, String medium) {
    return new Referral__c(
      Company__c = companyId,
      Contact__c = contactId,
      User__c = UserInfo.getUserId(),
      Type__c = type,
      Medium__c = medium);
  }

  /**
   * Factory method for creating Referral record.
   */
  public static Referral__c createReferralFrom(Id companyId, Id contactId) {
    return createReferral(companyId, contactId, TYPE_REFERRED_FROM, null);
  }

  /**
   * Factory method for creating Referral record.
   */
  public static Referral__c createReferralTo(Id companyId, Id contactId,
      String medium) {
    return createReferral(companyId, contactId, TYPE_REFERRED_TO, medium);
  }

  /**
   * Factory method for creating Referral record.
   */
  public static Referral__c createReferralToEmail(Id companyId, Id contactId) {
    return createReferralTo(companyId, contactId, MEDIUM_EMAIL);
  }

  /**
   * Factory method for creating Referral record.
   */
  public static Referral__c createReferralToCall(Id companyId, Id contactId) {
    return createReferralTo(companyId, contactId, MEDIUM_CALL);
  }

  /**
   * Factory method for creating related Activity, intended for tracking
   * outbound referrals (Refer To).
   */
  public static Task createTask(Id companyId, Id contactId, String subject,
      String comments) {
    return new Task(
      Subject = subject,
      WhoId = contactId,
      WhatId = companyId,
      Description = comments,
      Status = STATUS_COMPLETED,
      OwnerId = UserInfo.getUserId(),
      ActivityDate = System.today());
  }
}