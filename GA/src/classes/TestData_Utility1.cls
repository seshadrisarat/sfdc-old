//S-179420 - Created by Kanchan Palhora on 1/8/2014
//Created to to reutilize this to create test data for various obejcts

@isTest
public class TestData_Utility1 {
  
  private static Map<String, Id> profileNameToIdMap;
  private static Id DEFAULT_PROFILE_ID;

  public static User createUserUnsaved(String profileName) {
    User us = new User();
    String randomValue = getRandomStrValue();
    us.alias = 'usr';
    us.email = 'AA-' + randomValue + '@vmail.com.test';
    us.firstName = 'TestUser_ZZ';
    us.lastname = 'randomValue';
    us.username = us.email;
    us.emailencodingkey = 'UTF-8';
    us.lastname = 'Testing@123xyz'; 
    us.languagelocalekey = 'en_US'; 
    us.localesidkey = 'en_US';    
    us.timezonesidkey = 'America/New_York'; 
    us.Active_Deals__c = 0;

    us.profileid = getProfileId(profileName);
    if (us.profileid == null) {
      us.profileid = DEFAULT_PROFILE_ID;
    }

    return us;
  }
  
  public static Deal__c createDealUnsaved(String acctId, String status) {
    Deal__c d = new Deal__c();
    d.Name = 'Deal-' + getRandomStrValue();
    
    if (status == null) {
      d.Status__c = 'Auction';
    } else {
      d.Status__c = status;
    }
    
    
    if (acctId != null) {
      d.Related_Company__c = acctId; 
    } else {
      Account a = createAccountUnsaved();
      insert a;
      d.Related_Company__c = a.Id;
    }
    
    d.CurrencyIsoCode = 'USD';

    return d;
  }
  
  public static Team_Member__c createTeamMemberUnsaved(String userId, String dealId) {
    Team_Member__c tm = new Team_Member__c();
    tm.Deal__c = dealId;
    tm.User__c = userId;
    return tm;
  }
  
  public static String getProfileId(String profileName) {
    if (profileNameToIdMap == null || profileNameToIdMap.isEmpty()) {
      profileNameToIdMap = new Map<String, Id>();
      for (Profile p : [select Id, Name from Profile]) {
        profileNameToIdMap.put(p.Name, p.Id);
      }
      DEFAULT_PROFILE_ID = profileNameToIdMap.get('System Administrator');
    }
    return profileNameToIdMap.get(profileName);
  }
  
  public static Account createAccountUnsaved() {
    Account acc = new Account(Name = 'Acct - ' + getRandomStrValue(), 
      Source__c = 'LinkedIn', 
      Description = 'abc@123qwerty',
      Nearest_Metropolitan_City__c = 'City@123', 
      Industry = 'Finance');

    return acc;
  }

   public static String getRandomStrValue() {
     return String.valueOf(Math.random());
   }

}