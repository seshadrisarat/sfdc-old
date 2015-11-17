public without sharing class GlobalSearchController {
    public String searchString {get; set;} //Search Input From User
    public boolean renderSearch {get; set;} //Renders search result component
    public Integer accountRecordCount {get; set;} //Stores the record count
    public Integer contactRecordCount {get; set;} //Stores the record count
    public Id RecordPreviewID {get; set;}
    public List<cAccount> accountList {get; set;}
    public List<cContact> contactList {get; set;}
    public ID userId {get; set;}  //Stores the current user id
    public Map<Id, User> userMap {get; set;} 
    public Map<Id, RecordType> recordTypeMap {get; set;}
    
    public GlobalSearchController() {
        userMap = new Map<Id, User>([SELECT Id, Name FROM User]);
        recordTypeMap = new Map<ID, RecordType>([SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account']);
    }
    
    public PageReference search(){
        if(searchString != null && searchString != ''){
           searchString = searchString + '*';
           
           this.userId = UserInfo.getUserId();
           
           List<List<Sobject>> results = [FIND :searchString IN NAME FIELDS RETURNING 
                                          Account(id, Name, C_Classification__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Prospect_Status__c, Account_Type__c, Type, OwnerId, RecordTypeId ORDER BY Name), 
                                          Contact(id, Name, Account.Name, Account.id, Phone, Email, OwnerId ORDER BY Name) LIMIT 90 ];
           Account [] accounts = ((Account[])results[0]);
           Contact [] contacts = ((Contact[])results[1]); 
           contactRecordCount = contacts.size();
           accountRecordCount = accounts.size();
           List<cAccount> cAccounts = new List<cAccount>();
           List<cContact> cContacts = new List<cContact>();
           
           if(accounts.size() > 0){
               for(Account a : accounts){
                   cAccount acct = new cAccount(a, userId, userMap, recordTypeMap);
                   cAccounts.add(acct);
               }
           }
           
           if(contacts.size() > 0){
               for(Contact c : contacts){
                   cContact con = new cContact(c, userId, userMap);
                   cContacts.add(con);
               }
           }
           
           renderSearch = true;
           searchString = null;
           this.accountList = cAccounts;
           this.contactList = cContacts;
       }
       return null;
    }
    
    public PageReference populateRecordPreviewID(){
        if(ApexPages.currentPage().getParameters().get('recordPreviewID') != null && ApexPages.currentPage().getParameters().get('recordPreviewID') != '' && ApexPages.currentPage().getParameters().get('recordPreviewID') != 'null'){
            this.RecordPreviewID = ApexPages.currentPage().getParameters().get('recordPreviewID');
        }
        return null;
    } 
    
    public class cAccount {
        public boolean hasReadAccess {get; set;}
        public Account account {get; set;}
        public User owner {get; set;}
        public String recordType {get; set;}
        
        public cAccount(Account aParam, ID userIDParam, Map<Id, User> userMapParam, Map<Id, RecordType> recordTypeMapParam) {
            this.account = aParam;
            UserRecordAccess accessLevel = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :userIDParam AND RecordId = :account.id LIMIT 1];
            this.hasReadAccess = accessLevel.HasReadAccess;
            this.owner = userMapParam.get(aParam.OwnerId);
            RecordType rt = recordTypeMapParam.get(aParam.RecordTypeId);
            this.recordType = rt.Name;
        }
    }
    
    public class cContact {
        public boolean hasReadAccess {get; set;}
        public Contact contact {get; set;}
        public User owner {get; set;}
        
        public cContact (Contact aParam, ID userIDParam, Map<Id, User> userMapParam) {
            this.contact = aParam;
            UserRecordAccess accessLevel = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :userIDParam AND RecordId = :contact.id LIMIT 1];
            this.hasReadAccess = accessLevel.HasReadAccess;
            this.owner = userMapParam.get(aParam.OwnerId);
        }
    }
   
}