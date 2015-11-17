/**
 * Trigger Name :   ContactRecordHandler   
 * Created By   :   Mohit
 * Date         :   April 26, 2013
 * Description  :   This class is used to insert/update the contact records.
 */
public with sharing class ContactRecordHandler {
  
  @future
    public static void createContactRecords(Set<String> setofEmail) {
    
      List<Contact> conList = new List<Contact>();
      Map<String,List<Contact>> userContactInfo = new Map<String,List<Contact>>();
      
      //List<User,Contact> userContactInfo = new List<Id,Contact>();
      Map<String, User> userMap = new Map<String, User>([Select u.Id, u.Title, u.CompanyName, u.Street, u.State, u.PostalCode, u.Phone, u.MobilePhone, u.LastName, u.FirstName, u.Email, u.Country, u.City From User u where u.Email in :setofEmail ]);
      // CompanyName__c : It's a custom setting in which the default Company/account Id is set.
      CompanyName__c accountId = CompanyName__c.getAll().values();
      String strRecordTypeId = [Select Id From RecordType Where Name = 'Employee'].Id;
      List<Contact> contactInfo;
      List<Contact> contactLst = [select Id,User__c, Email, AccountId from Contact where Email in :setofEmail];
      for(Contact contact : contactLst){
        system.debug('-------------contact--------'+contact+'!!!!!contact.UserData__c!!!!!!'+contact.Email);
         if(userContactInfo.containsKey(contact.Email )){
                contactInfo = userContactInfo.get(contact.Email);
                contactInfo.add(contact);
                userContactInfo.put(contact.Email, contactInfo);
            } else {
              list<Contact> tempContactList = new list<Contact>();
              tempContactList.add(contact); 
                userContactInfo.put(contact.Email,tempContactList);
            }
        }
        system.debug('-----------userContactInfo.values()------'+userContactInfo.values());
        map<Id, Id> accExistsForUser = new map<Id, Id>();
        map<Id,string> mapCompanyNames = new map<Id, String>();
        for(User userData : userMap.values()){
            mapCompanyNames.put(userData.id, userData.CompanyName);
        }
        
        list<Account> lstAcct = [select Id, Name from account where Name =: mapCompanyNames.values()];
        map<String, String> mapStr = new map<String, String>();
        
        for(Account acct : lstAcct){
            for(User userData : userMap.values()){
                if(userData.CompanyName == acct.Name){
                    accExistsForUser.put(userData.id, acct.Id);
                    break;
                }
            }
        }
        system.debug('*******userMap.values()***'+userMap.values().size());
        for(User userData : userMap.values()){
            //if(userContactInfo.get(userData.Id).size()>0){
            if(userContactInfo.values().size()>0){
                conList = userContactInfo.get(userData.Email); 
            } else {
                Contact con = new contact();
                con.User__c = userData.Id;
                con.Email = userData.Email;
                con.RecordTypeId = strRecordTypeId;
                conList.add(con);
            }
            for (Contact cnt : conList){
                cnt.FirstName = userData.FirstName;
                cnt.LastName = userData.LastName;
                cnt.Email = userData.Email;
                cnt.Title = userData.Title;
                cnt.Phone = userData.Phone; 
                cnt.MobilePhone = userData.MobilePhone;
                cnt.MailingCity = userData.City;
                cnt.MailingCountry = userData.Country;
                cnt.MailingPostalCode = userData.PostalCode;
                cnt.MailingState = userData.State;
                cnt.MailingStreet = userData.Street;
                
                
                // Check if Company Name from the User is null then it set the default Company Name
                system.debug('----userData.CompanyName----'+userData.CompanyName+'****'+accountId.name); 
                if(userData.CompanyName == null || userData.CompanyName == ''){
                    cnt.AccountId = accountId.name;
                }else{
                    system.debug('-----------------accExistsForUser.get(userData.id)----------'+accExistsForUser.get(userData.id));
                    if(accExistsForUser.get(userData.id) != null)
                        cnt.AccountId = accExistsForUser.get(userData.id);
                    else    
                        cnt.AccountId = accountId.name;
                }
            }
        }
        if(conList.size() > 0){
            upsert conList;
        } 
    }
        
}