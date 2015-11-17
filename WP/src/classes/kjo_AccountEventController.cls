public with sharing class kjo_AccountEventController {
    
    private final Account account;
    List<Task> tasks;
    
    public kjo_AccountEventController(ApexPages.StandardController stdController) {
        this.account = (Account)stdController.getRecord();
    }
    
    @RemoteAction
    public static Contact getCurrentUserContactInformation() {
        Contact contact = [
                SELECT User_ID__c, Name, Id, Full_Name__c,
                EMG_Member__c, Email, Employee_Level__c, 
                ISINVESTMENTPRO__c, Initials__c, Status__c, Title, WP_Group__c FROM Contact         
                WHERE User_ID__c = :UserInfo.getUserId() LIMIT 1];
        return contact;
    }

    @RemoteAction
    public static Contact getContactInformation(ID ContactId) {
        Contact contact = [
                SELECT Id, AccountId, Phone, Fax, Email, Name, Chinese_Name__c, Chinese_Company_Name__c,
                Full_Name__c, Description, Account.Name FROM Contact
                WHERE Id = :ContactId LIMIT 1];
        return contact;
    }
    
    @RemoteAction
    public static Account getAccountInformation(ID AccountId) {
        Account account = [
                SELECT Id, Name, Chinese_Company_Name__c, Company_Stage__c, Company_Type__c, 
                Description, Industry FROM Account
                WHERE Id = :AccountId LIMIT 1];
        return account;
    }
    
    
    public class WPTask {
        String Id {get; set;} 
        String WhatId {get; set;}
        String WhoId {get; set;}
        String FollowupWhatId {get; set;}
        String FollowupWhoId {get; set;}
        String FollowupAuthorId {get; set;}
        String Subject {get; set;}
        String Description {get; set;}
        String Classification {get; set;} 
        String FollowUpClassification {get; set;} 
        String FollowupSubject {get; set;}
        String FollowupDescription {get; set;}
       // String Type {get; set;}
       // String FollowupType {get; set;}
        String ActivityDate {get; set;}
        String FollowupDate {get; set;}
        String Priority {get; set;}
        String Status {get; set;}
        List<String> Contacts {get; set;}
        List<String> FollowUpContacts {get; set;}
    }
    
    @RemoteAction
    public static Task createTask(WPTask atask) {

        boolean followUp = String.isNotBlank(atask.FollowupDate) ? true : false;
         
        Task task = new Task();
        Task followup_task;
        List<TaskRelation> relations = new List<TaskRelation>();
        List<TaskRelation> followupRelations = new List<TaskRelation>();
        
        task.WhatId = atask.WhatId;
        task.WhoId = string.isBlank(atask.WhoId) ? null : atask.WhoId;
        task.Subject = atask.Subject;
        task.Description = atask.Description;
       // task.Type = atask.Type;
        task.ActivityDate = string.isBlank(atask.ActivityDate) ? null : Date.parse(atask.ActivityDate);
        task.Priority = atask.Priority;
        task.Status = atask.Status;  
        task.Classification__c = atask.Classification;       
        
        if ( followUp ) {
            followup_task = new Task();
            followup_task.OwnerId = atask.FollowupAuthorId;
            followup_task.WhatId = atask.FollowupWhatId;
            followup_task.WhoId = string.isBlank(atask.FollowupWhoId) ? null : atask.FollowupWhoId;
            followup_task.Subject = atask.FollowupSubject;
            followup_task.Description = atask.FollowupDescription;
          //  followup_task.Type = atask.FollowupType;
            followup_task.Priority= atask.Priority;
            followup_task.Status = 'Not Started';
            followup_task.ActivityDate = Date.parse(atask.FollowupDate);
            followup_task.Classification__c  = atask.FollowUpClassification;
        }
                        
        insert task;
        if ( followup_task != null ) {
            insert followup_task;
        }
        /*
        if(atask.Contacts != null)
        {
                for(Contact contact : atask.Contacts)
                {
                        system.debug(' Contact Id: ' + contact.Id);
                        TaskRelation newContactRelationship = new TaskRelation();
                        newContactRelationship.TaskId = task.id;
                        newContactRelationship.RelationId =  contact.Id;
                        newContactRelationship.IsWhat = false;          
                        //newContactRelationship.AccountId =  contact.AccountId;                        
                        relations.add(newContactRelationship);
                }
        }*/
        
        if(atask.Contacts != null)
        {
                for(String contactId : atask.Contacts)
                {
                        system.debug(' Contact Id: ' + contactId);
                        TaskRelation newContactRelationship = new TaskRelation();
                        newContactRelationship.TaskId = task.id;
                        newContactRelationship.RelationId =  contactId;
                        newContactRelationship.IsWhat = false;          
                        //newContactRelationship.AccountId =  contact.AccountId;                        
                        relations.add(newContactRelationship);
                }
        }
        
        if(relations.size() > 0) {
                Database.insert(relations);
        }        

                
                if(atask.FollowUpContacts != null)
        {
                for(String contactId : atask.FollowUpContacts)
                {
                        system.debug(' Contact Id: ' + contactId);
                        TaskRelation newContactRelationship = new TaskRelation();
                        newContactRelationship.TaskId = followup_task.id;
                        newContactRelationship.RelationId =  contactId;
                        newContactRelationship.IsWhat = false;          
                        //newContactRelationship.AccountId =  contact.AccountId;                        
                        followupRelations.add(newContactRelationship);
                }
        }
        
        if(followupRelations.size() > 0) {
                Database.insert(followupRelations);
        }  


        return task;
    }
    
    public class ContactPerson {
        String label;
        String contact_id;
        String account_id;
        String title;
        String company_name;
        String chinese_name;
        String chinese_company_name;
        
        
        public ContactPerson(
                String name, String ContactId, String AccountId, 
                String Title, String AccountName, String ChineseName, String ChineseAccountName) {
            this.label = name;
            this.account_id = AccountId;
            this.contact_id = ContactId;
            this.title = Title;
            this.company_name = AccountName;
            this.chinese_name = ChineseName;
            this.chinese_company_name = ChineseAccountName;
        }
    }


    @RemoteAction
    public static List<ContactPerson> getContactsList(String searchterm) {

        String query = 
            'Select Id, AccountId, LastName, FirstName, Name, Title, Full_Name__c, Chinese_Name__c, ' +
            'RecordType.Name, Account.Name, Account.Chinese_Company_Name__c From Contact ';
    
        String restriction = String.isBlank(searchterm) ? '' : ' WHERE LastName LIKE \'' + String.escapeSingleQuotes(searchterm) + '%\'';
        
        List<Contact> people = Database.query( query + restriction + ' ORDER BY LastName, FirstName' );
    
        ContactPerson p;
        List<ContactPerson> lst = new List<ContactPerson>();
        for ( Contact contact : people ) {
            p = new ContactPerson(
                contact.Full_Name__c, 
                contact.Id, 
                contact.AccountId,
                contact.Title,
                contact.Account.Name,
                contact.Chinese_Name__c,
                contact.Account.Chinese_Company_Name__c
            );
            lst.add(p);
        }
        return lst;
    }
    
    @RemoteAction
    public static List<SelectOption> getTaskTypes() {
    
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Task.Classification__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }   
    
    public List<Task> getCompanyAndDealTasks() {
        if ( tasks == null ) {
            tasks = [Select Subject, Account.Name, AccountId, WhatId, What.Name, What.Type From Task 
                        WHERE OwnerId IN (
                            Select c.User_ID__c
                            From Contact c 
                            WHERE c.User_ID__c <> NULL 
                            AND c.User_ID__r.IsActive = true)
                        AND
                            What.Type IN ('Account', 'Deal__c') AND What.Id = '001E000000aQNYf'
            ];
        }
        return tasks;
    }
    
    public class Person {
        String label;
        String user_id;
        String contact_id;
        String title;
        Decimal rank;
        String group_name;
        String initials;
        
        public Person(String name, String UserId, String ContactId, String Title, Decimal Rank, String GroupName) {
            this.label = name;
            this.user_id = UserId;
            this.contact_id = ContactId;
            this.title = Title;
            this.rank = Rank;
            this.group_name = GroupName;
        }
    }
    
    @RemoteAction
    public static List<Person> getProfessionalsList(String searchterm) {

        String query = 
            'Select Id, AccountId, LastName, FirstName, Name, Title, Initials__c, WP_Group__c, Full_Name__c, ' +
            'Employee_Level__r.Name, Employee_Level__r.Rank__c,' +
            'ISINVESTMENTPRO__c, Status__c, RecordType.Name, User_ID__r.Id From Contact ' +
            'WHERE RecordType.Name = \'Employee\' AND Status__c = \'Active\' AND ISINVESTMENTPRO__c = 1 ';
    
        String restriction = String.isBlank(searchterm) ? '' : ' AND LastName LIKE \'' + String.escapeSingleQuotes(searchterm) + '%\'';
        
        List<Contact> people = Database.query( query + restriction + ' ORDER BY LastName, FirstName' );
    
        Person p;
        List<Person> lst = new List<Person>();
        for ( Contact contact : people ) {
            p = new Person(
                contact.Full_Name__c, 
                contact.User_ID__r.Id, 
                contact.Id,
                (contact.Employee_Level__r != null) ? contact.Employee_Level__r.Name : null,
                (contact.Employee_Level__r != null) ? contact.Employee_Level__r.Rank__c : null,
                contact.WP_Group__c
            );
            p.initials = contact.Initials__c;
            lst.add(p);
        }
        return lst;
    }
       
}