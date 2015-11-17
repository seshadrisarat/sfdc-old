global class EmployeeMetricBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private Date dInput;

    global EmployeeMetricBatchable(Date dInput) {
        this.dInput = dInput;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, SalesforceUser__c FROM Employee__c WHERE IsDeleted=FALSE]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
        for (Employee__c e : (List<Employee__c>) batch) {
            Employee_Metrics__c metric = new Employee_Metrics__c(
                Employee__c = e.Id,
                Date__c = dInput,
                ExternalId__c = e.Id + '-' + dInput.year() + '-' + dInput.month() + '-' + dInput.day(),
                Company_Calls__c = 0,
                Intermediary_Calls__c = 0,
                Deals_Closed__c = 0,
                Deals_Worked__c = 0,
                Themes_Managed__c = 0,
                Value_of_Deals_Closed__c = 0,
                New_Companies_Added__c = 0,
                New_Contacts_Added__c = 0
            );

            // Get list of activities
            List<Task> tasks = [SELECT Id, WhatId FROM Task WHERE OwnerId=:e.SalesforceUser__c AND ActivityDate=:dInput AND What.Type IN ('Account') AND IsDeleted=FALSE];


            Map<Id, String> accountTypeMap = new Map<Id, String>();
            for (Task t : tasks) {
                accountTypeMap.put(t.WhatId, null);
            }

            for (Account a : [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN :accountTypeMap.keySet() AND IsDeleted=FALSE]) {
                accountTypeMap.put(a.Id, a.RecordType.DeveloperName);
            }

            Map<Id, Deal__c> deals = new Map<Id, Deal__c>();
            for (Deal__c d : [SELECT Id, CreatedDate, Close_Date__c, Status__c, Deal_Size_MM__c FROM Deal__c WHERE ((CreatedDate>=:dInput AND CreatedDate<:dInput.addDays(1)) OR Close_Date__c=:dInput) AND IsDeleted=FALSE]) {
                deals.put(d.Id, d);
            }
            for (Team_Member__c tm : [SELECT Deal__r.CreatedDate, Deal__r.Close_Date__c, Deal__r.Status__c, Deal__r.Deal_Size_MM__c FROM Team_Member__c WHERE ((Deal__r.CreatedDate>=:dInput AND Deal__r.CreatedDate<:dInput.addDays(1)) OR Deal__r.Close_Date__c=:dInput) AND IsDeleted=FALSE]) {
                deals.put(tm.Deal__c, tm.Deal__r);
            }


            // Summary: Tasks
            for (Task t : tasks) {
                String accountType = accountTypeMap.get(t.WhatId);
                if (accountType == 'DealCompany') {
                    metric.Company_Calls__c++;
                } else if (accountType == 'Intermediary') {
                    metric.Intermediary_Calls__c++;
                }
            }
            // Summary: Deals
            for (Deal__c d : deals.values()) {
                if (d.Status__c == 'Deal Won' && d.Close_Date__c >= dInput && d.Close_Date__c < dInput.addDays(1)) {
                    metric.Deals_Closed__c++;
                    try {
                        metric.Value_of_Deals_Closed__c += d.Deal_Size_MM__c;
                    } catch (Exception ex) {
                    }
                }
                if (d.CreatedDate >= dInput && d.CreatedDate < dInput.addDays(1)) {
                    metric.Deals_Worked__c++;
                }
            }
            // Summary: Themes
            for (Theme__c t : [SELECT Id FROM Theme__c WHERE OwnerId=:e.SalesForceUser__c AND (CreatedDate>=:dInput AND CreatedDate<:dInput.addDays(1)) AND IsDeleted=FALSE]) {
                metric.Themes_Managed__c++;
            }
            // Summary: Accounts
            for (Account a : [SELECT Id FROM Account WHERE (CreatedDate>=:dInput AND CreatedDate<:dInput.addDays(1)) AND RecordType.DeveloperName='DealCompany' AND IsDeleted=FALSE]) {
                metric.New_Companies_Added__c++;
            }
            // Summary: Contacts
            for (Contact c : [SELECT Id FROM Contact WHERE (CreatedDate>=:dInput AND CreatedDate<:dInput.addDays(1)) AND IsDeleted=FALSE]) {
                metric.New_Contacts_Added__c++;
            }

            if (metric.Company_Calls__c != 0 ||
                metric.Intermediary_Calls__c != 0 ||
                metric.Deals_Closed__c != 0 ||
                metric.Deals_Worked__c != 0 ||
                metric.Themes_Managed__c != 0 ||
                metric.Value_of_Deals_Closed__c != 0 ||
                metric.New_Companies_Added__c != 0 ||
                metric.New_Contacts_Added__c != 0) {

                Database.upsert(metric, Employee_Metrics__c.Fields.ExternalId__c, false);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {}
    
    static testMethod void testEmployeeMetricBatchable() {
        RecordType intermediary = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Intermediary' LIMIT 1];
    	
    	Account a = new Account(name='Test Deal Company',RecordTypeId=intermediary.Id);
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;
        
        Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
        insert d;
        
        Employee__c e = new Employee__c(SalesforceUser__c=UserInfo.getUserId(),Initials__c='!TL');
        insert e;

        Employee_Metrics__c em = new Employee_Metrics__c(Employee__c=e.id,Date__c=Date.today());
        insert em;
		
		Task t = new Task(OwnerId=UserInfo.getUserId(), ActivityDate=System.today(),WhatId=a.Id);
		insert t;

        Team_Member__c tm = new Team_Member__c(Deal__c=d.Id,Name__c=e.Id);
        insert tm;

        Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
        insert thm;

        thm.Name = 'Test Theme 2';
        update tm;

        Deal_Theme__c dt = new Deal_Theme__c(Deal__c=d.Id,Theme__c=thm.Id);
        insert dt;

        Test.startTest();
        Database.executeBatch(new EmployeeMetricBatchable(System.today()));
        Test.stopTest();
    }
}