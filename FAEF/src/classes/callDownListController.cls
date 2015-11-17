public class callDownListController {

    public String campaignID {get; set;}                      //Current Campain ID
    public String leadID {get; set;}                          //Lead ID Passed From completeActionWithMessage and completeActionSuccess ActionFunctions
    public String contactID {get; set;}                       //Contact ID Passed From completeActionWithMessage and completeActionSuccess ActionFunctions
    public String popupRecordID {get; set;}                   //Record ID used for the preview pane
    public String sObjectName {get; set;}                     //Type of record from popupRecordID
    public Lead leadRecord {get; set;}                        //Actual Lead Displayed in preview pane
    public Contact contactRecord {get; set;}                  //Actual Contact Displayed in preview pane
    public Account accountRecord {get; set;}                  //Actual Account Displayed in preview pane
    public List<Schema.FieldSetMember> fsm {get; set;}        //List of fields (Leads + Contacts) used in preview pane
    public List<Schema.FieldSetMember> AccountFsm {get; set;} //List of fields (Account) used in preview pane
    public String contactAccountID {get; set;}                //Contact's Account ID (Used for preview pane)
    public String baseURL {
                            get{ return baseURL; } 
                            set{ baseURL = URL.getSalesforceBaseUrl().toExternalForm(); }   //Get SFDC Base URL 
                          }
 
    public String actionNumberFilterValue {get; set;}              //The Action Count Filter Picklist Value
    public String noAttemptsSinceFilterValue {get; set;}           //The No Attempts Since Filter Picklist Value
    public String campaignMemberSortOrder {get; set;}              //Sort order of campaign members (ASC or DESC) Used in SOQL Query
    
    //Populates the Call Down Picklist
    public List<SelectOption> getCallDownLists(){
        List<SelectOption> selectOptions = new List<SelectOption>();
        List<Campaign> campaigns = [SELECT ID, Name, Status FROM Campaign WHERE Call_Down_List__c = TRUE AND Status != 'Completed;Aborted' AND OwnerId =:UserInfo.getuserid()];
        
        for(Campaign c : campaigns){
            selectOptions.add(new SelectOption(c.id, c.Name + ': ' + c.Status));
        }
        
        return selectOptions;
    }
    
    //Gets the details of the current campaign
    public Campaign getCurrentCampaign(){
        if(campaignID != null){
             return [SELECT ID, Name, NumberOfLeads, NumberOfContacts, Status, Actual_Response_Percent__c, Minimum_Attempts__c FROM Campaign WHERE ID = :campaignID];   
        }else{
            return null;
        }
    }
    
    //Gets a list of campain actions for the current campaign
    public Campaign getCampaignActions(){
        if(campaignID != null){
             return [SELECT 
                     Action_1_Name__c, Action_1_Type__c,
                     Action_2_Name__c, Action_2_Type__c,
                     Action_3_Name__c, Action_3_Type__c,
                     Action_4_Name__c, Action_4_Type__c,
                     Action_5_Name__c, Action_5_Type__c,
                     Action_6_Name__c, Action_6_Type__c,
                     Action_7_Name__c, Action_7_Type__c,
                     Action_8_Name__c, Action_8_Type__c,
                     Action_9_Name__c, Action_9_Type__c,
                     Action_10_Name__c, Action_10_Type__c
                     FROM Campaign WHERE ID = :campaignID];   
        }else{
            return null;
        }
    }
    
    //Returns a list of minimum action steps
    public List<SelectOption> getActionNumberPicklistValues(){
        List<SelectOption> selectOptions = new List<SelectOption>();
        if(campaignID != null){
            System.debug('CampaignID: ' + campaignID);
            Campaign c = [SELECT Minimum_Attempts__c FROM Campaign WHERE ID = :campaignID LIMIT 1];
            integer max = integer.valueOf(c.Minimum_Attempts__c);
            for(integer i = 0; i < max + 1; i++){
               selectOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
        }
        return selectOptions;        
    }
    
    //Sets the campaignMemberSortOrder value (from ActionFunction)
    public void toggleCampaignMemberSortOrder(){
        System.debug('Campaign Sort Order BEFORE: ' + campaignMemberSortOrder);
        if(campaignMemberSortOrder == 'DESC'){
            campaignMemberSortOrder = 'ASC';
        }else if(campaignMemberSortOrder == 'ASC'){
            campaignMemberSortOrder = 'DESC';
        }
        System.debug('Campaign Sort Order AFTER: ' + campaignMemberSortOrder);
    }
    
    //Returns list of campaign members
    public List<CampaignMember> getCampaignMembers(){
        //Set default sort order
        if(campaignMemberSortOrder == null){
            campaignMemberSortOrder = 'DESC';
        }
        
        //Time Literals
        DateTime lastTwoHours = Datetime.now().addHours(-2);
        DateTime lastFourHours = Datetime.now().addHours(-4);
        
        //Set No Attempts Since Filter
        String noAttemptsSinceFilter = '';
        if(noAttemptsSinceFilterValue == '2HRS') noAttemptsSinceFilter = 'AND Last_Action__c < ' + lastTwoHours.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        if(noAttemptsSinceFilterValue == '4HRS') noAttemptsSinceFilter = 'AND Last_Action__c < ' + lastFourHours.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        if(noAttemptsSinceFilterValue == 'TODAY') noAttemptsSinceFilter = 'AND Last_Action__c < TODAY ';
        if(noAttemptsSinceFilterValue == 'THISWEEK') noAttemptsSinceFilter = 'AND Last_Action__c < THIS_WEEK ';
        
        String query = 'SELECT id, Lead.Firstname, Lead.Lastname, Lead.Email, Lead.Phone, Lead.LastActivityDate, Lead.Company, Contact.Account.Name, Contact.Firstname, Contact.Lastname, Contact.Email, Contact.Phone, Contact.LastActivityDate, Contact.Title, ContactId, LeadId, Last_Action__c, Attempts__c, Last_Action_Name__c, Next_Action_Name__c ' +
                    'FROM CampaignMember WHERE CampaignID = \'' + campaignID + '\' AND HasResponded = FALSE ' + noAttemptsSinceFilter + ' ORDER BY Contact.Account.Name ASC, Attempts__c ' + campaignMemberSortOrder;
                    
        System.debug('Campaign Member Query: ' + query);
        
        if(campaignID != null){
            return Database.query(query);
        }else{
            return null;
        }
    }
    
    //Log an action
    public void completeAction(){
        saveActionResult('', 'Executed');
    }
    
    //Log an action with a message
    public void completeActionWithMessage(){
        String message = ApexPages.CurrentPage().getParameters().get('message');
        saveActionResult(message, 'Executed');
    }
    
    //Log a successful action
    public void completeActionSuccess(){
        //String message = ApexPages.CurrentPage().getParameters().get('message');
        saveActionResult('', 'Successful');
    }
    
    //Abandon a campaign member
    public void closeAction(){
        saveActionResult('', 'Abandoned');
    }
    
    /*
    * Creates an action result for the related lead/contact
    * @param message (The message logged on an action)
    * @param result (Type of log entry)
    */
    public void saveActionResult(String message, String result){
        leadID = ApexPages.CurrentPage().getParameters().get('leadID');
        contactID = ApexPages.CurrentPage().getParameters().get('contactID');
        CampaignMember member = null;
        
        System.debug('SAVE ACTION RESULT: ' + message + ', ' + result);
        System.debug('LEAD ID: ' + leadID);
        System.debug('CONTACT ID: ' + contactID);
        
        Action_Result__c ar = new Action_Result__c();
        
        if(leadID != null && leadID != ''){
            ar.lead__c = leadID;
        }else{
            ar.contact__c = contactID;
        }
        
        ar.Action_Result_Date_Time__c = datetime.now();
        ar.Campaign__c = campaignID;
        ar.Result__c = result;
        ar.Message_Note__c = message;
        
        String memberQuery = 'SELECT ID, Campaign.Action_1_Name__c, Campaign.Action_1_Type__c, Campaign.Action_2_Name__c, Campaign.Action_2_Type__c, Campaign.Action_3_Name__c, Campaign.Action_3_Type__c, ' +
                             'Campaign.Action_4_Name__c, Campaign.Action_4_Type__c, Campaign.Action_5_Name__c, Campaign.Action_5_Type__c, Campaign.Action_6_Name__c, Campaign.Action_6_Type__c, ' +
                             'Campaign.Action_7_Name__c, Campaign.Action_7_Type__c, Campaign.Action_8_Name__c, Campaign.Action_8_Type__c, Campaign.Action_9_Name__c, Campaign.Action_9_Type__c, ' +
                             'Campaign.Action_10_Name__c, Campaign.Action_10_Type__c, Attempts__c, Status FROM CampaignMember WHERE CampaignID = \'' + campaignID + '\' AND ';
        
        //Stamp Attempt Number, Action Name, and Type from Campaign
        if(leadID != null && leadID != ''){
               memberQuery += 'LeadID = \'' + LeadID + '\' LIMIT 1';
               member = Database.query(memberQuery);
               ar.Attempt_Number__c = member.Attempts__c + 1;
        }else if(contactID != null && contactID != ''){
               memberQuery += 'ContactID = \'' + contactID + '\' LIMIT 1';
               member = Database.query(memberQuery);
               ar.Attempt_Number__c = member.Attempts__c + 1;
        }
       
        //Records the action name + type from the related campaign
        //Note: 10 = Maximum number of action fields on the campaign
        if(ar.Attempt_Number__c <= 10){
         ar.Action_Name__c = (String)member.Campaign.get('Action_' + ar.Attempt_Number__c + '_Name__c');
         ar.Action_Type__c = (String)member.Campaign.get('Action_' + ar.Attempt_Number__c + '_Type__c');
        }
        
        insert ar;
        
        if(result == 'Successful' || result == 'Abandoned'){
           if(leadID != null && leadID != ''){
               memberQuery = 'SELECT ID, Status FROM CampaignMember WHERE CampaignID = \'' + campaignID + '\' AND LeadID = \'' + LeadID + '\' LIMIT 1';
               member = Database.query(memberQuery);
               member.Status = 'Responded';
                   Database.saveResult sr = Database.update(member);
           }else if(contactID != null && contactID != ''){
               memberQuery = 'SELECT ID, Status FROM CampaignMember WHERE CampaignID = \'' + campaignID + '\' AND ContactID = \'' + ContactID + '\' LIMIT 1';
               member = Database.query(memberQuery);
               member.Status = 'Responded';
               Database.saveResult sr = Database.update(member);
           }
        }
        
        leadID = null;
        contactID = null;
    }
    
    //Saves the recordID variable from the VF page to popupRecordID
    public PageReference updatePopupInfo() {
        popupRecordID = ApexPages.CurrentPage().getParameters().get('recordId');
        return null;
    }
    
    //1.)Return the fieldset for the specific sObject 2.)Query the record 
    public LIST<Schema.FieldSetMember> getFields() {
        
        if(popupRecordID != null){
            System.debug('popup record not blank');
            if(popupRecordID.left(3) == '00Q'){
                System.debug('record is a lead');
                sObjectName = 'Lead';
                fsm = SObjectType.Lead.FieldSets.LeadCallDownFS.getFields();
                leadRecord = getLead();
                system.debug('LEAD NAME ' + leadRecord.Name);
                return fsm;
            }else if(popupRecordID.left(3) == '003'){
                System.debug('record is a contact');
                sObjectName = 'Contact';
                fsm = SObjectType.Contact.FieldSets.ContactCallDownFS.getFields();
                contactRecord = getContact();
                return fsm;
            }else if(popupRecordID.left(3) == '001'){
                System.debug('record is an account');
                sObjectName = 'Account';
                fsm = SObjectType.Account.FieldSets.AccountCallDownFS.getFields();
                accountRecord = getAccount();
                return fsm;
            }else{
                
                return null;
            }
        }else{
            return null;
        }
    }
    
   //1.)Get Account fields 2.)Get account record
   public LIST<Schema.FieldSetMember> getAccountFields() {
       if(popupRecordID != null && popupRecordID.left(3) == '003'){
          contactRecord = getContact();
          contactAccountID = contactRecord.AccountID;
       if(contactAccountID != null){
       AccountFsm = SObjectType.Account.FieldSets.AccountCallDownFS.getFields();
       accountRecord = getAccount();
       return AccountFsm;
       }else{
           return null;
       }
       }else{
           return null;
       }
   }
    
    //Returns Lead record with fields from field set
    public Lead getLead(){
        if(popupRecordID != null){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : this.fsm) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM Lead WHERE Id = \'' + popupRecordID + '\' LIMIT 1';
            System.debug('GET LEAD QUERY: ' + query);
            return Database.query(query);
        }else{
            return null;
        }
    }
    
    //Returns Contact record with fields from field set
    public Contact getContact(){
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.fsm) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, AccountId FROM Contact WHERE Id = \'' + popupRecordID + '\' LIMIT 1';
        System.debug('GET CONTACT QUERY: ' + query);
        Contact returnedContact = Database.query(query);
        contactAccountID = returnedContact.AccountId;
        return returnedContact;
    }
    
    //Returns Account record with fields from field set
    public Account getAccount(){
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.AccountFsm) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Account WHERE Id = \'' + contactAccountID + '\' LIMIT 1';
        System.debug('GET ACCOUNT QUERY: ' + query);
        return Database.query(query);
    }
    
    //Returns Open Tasks depending on popup record ID (Shows in Preview Pane)
    public List<Task> getOpenTasks(){
        List<Task> tasksToReturn = new List<Task>();
        
        if(popupRecordID != null){
           tasksToReturn = [SELECT ActivityDate, Description, Priority, Status, Subject FROM Task WHERE WhoId = :popupRecordID AND IsClosed = FALSE];
        }
        
        return tasksToReturn;
    }
    
    //Returns Open Events depending on popup record ID (Shows in Preview Pane)
    public List<Event> getOpenEvents(){
        List<Event> eventsToReturn = new List<Event>();
        
        if(popupRecordID != null){
           eventsToReturn = [SELECT ActivityDate, Description, Subject, Type FROM Event WHERE WhoId = :popupRecordID AND ActivityDate <= TODAY];
        }
        
        return eventsToReturn;
    }
    
    //Returns activity history depending on the sObject
    public List<ActivityHistory> getActivityHistory(){
        System.debug('Called getActivityHistory()');
        List<Lead> l = null;
        List<Account> a = null;
        List<Contact> c = null;
        
        if(popupRecordID != null){
         System.debug('Popup Record ID: ' + popupRecordID);
         if(popupRecordID.left(3) == '00Q'){
                l = [SELECT id, (SELECT id, ActivityDate, Subject, Status, isTask FROM ActivityHistories ORDER BY ActivityDate DESC NULLS LAST) FROM Lead WHERE id = :popupRecordID];
                if(l.size() > 0){
                    System.debug('Lead Activity History: ' + l.size());
                    return l[0].ActivityHistories;
                }
            }else if(popupRecordID.left(3) == '001'){
                a = [SELECT id, (SELECT id, ActivityDate, Subject, Status, isTask FROM ActivityHistories ORDER BY ActivityDate DESC NULLS LAST) FROM Account WHERE id = :popupRecordID];
                if(a.size() > 0){
                    System.debug('Account Activity History: ' + a.size());
                    return a[0].ActivityHistories;
                }
            }else if(popupRecordID.left(3) == '003'){
                c = [SELECT id, (SELECT id, ActivityDate, Subject, Status, isTask FROM ActivityHistories ORDER BY ActivityDate DESC NULLS LAST) FROM Contact WHERE id = :popupRecordID];
                if(c.size() > 0){
                    System.debug('Contact Activity History: ' + c.size());
                    return c[0].ActivityHistories;
                }
            }
        }
                return null;
          
            
    }
    
    //Returns Action Results depending on the popup record ID (Shows in Preview Pane)
    public List<Action_Result__c> getActionResults(){
        System.debug('Called getActionResults()');
        List<Action_Result__c> results = new List<Action_Result__c>();
        if(popupRecordID != null){
            System.debug('Popup Record ID: ' + popupRecordID);
            if(popupRecordID.left(3) == '00Q'){
                results = [SELECT id, Action_Name__c, Action_Result_Date_Time__c, Action_Step__c, 
                           Action_Type__c, Attempt_Number__c, Message_Note__c, Result__c
                           FROM Action_Result__c WHERE Lead__c = :popupRecordID AND Campaign__c = :campaignID];
            }else if(popupRecordID.left(3) == '003'){
                results = [SELECT Action_Result_Date_Time__c, Action_Step__c, 
                           Action_Type__c, Attempt_Number__c, Message_Note__c, Result__c
                           FROM Action_Result__c WHERE Contact__c = :popupRecordID AND Campaign__c = :campaignID];
            }
        }
        return results;
    }

}