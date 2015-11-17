public with sharing class QuickAddController {
    public Account aInput { get; private set; }
    public Contact cInput { get; private set; }
    public Deal__c dInput { get; private set; }
    public Task tInput { get; private set; }
    public Task tStatus { get; private set; }
    public Boolean tagThemes { get; set; }
    public List<ManageCompanyThemes.Theme> themes { get; private set ; }
    public Map<Id,String> roleMap { get; set; }

    public QuickAddController() {
        roleMap = new Map<Id,String>();
        for (UserRole u : [SELECT Name, Id FROM UserRole]) {
            roleMap.put(u.Id, u.Name);
        }
        
        aInput = new Account(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='DealCompany' AND IsActive=TRUE LIMIT 1].Id,
            OwnerId = UserInfo.getUserId(),
            Industry = getGaTeam(UserInfo.getUserRoleId())
        );
        
        cInput = new Contact();
        dInput = new Deal__c(
            Status__c = 'Evaluating'
        );
        tInput = new Task();
        tStatus = new Task();
        
        tagThemes = false;

        themes = new List<ManageCompanyThemes.Theme>();
        for (Theme__c t : [SELECT Name, Description__c, Active__c FROM Theme__c WHERE Active__C != 'Inactive' AND IsDeleted=FALSE ORDER BY Name]) {
            themes .add(new ManageCompanyThemes.Theme(new Company_Theme__c(
                Theme__c = t.Id,
                Theme__r = t
            )));
        }
    }

    public PageReference save() {
        PageReference ref;

        SavePoint sp = Database.setSavePoint();
        try {
            // Account
            if ((aInput.Status__c == 'Live Deal' || aInput.Status__c == 'Top Prospect') && aInput.Source__c == null) {
                aInput.Source__c.addError('A value is required for the selected Status');
                return null;
            }
            insert aInput;
            ref = new PageReference('/' + aInput.Id);
            
            // Contact
            if (cInput.LastName != null) {
                cInput.AccountId = aInput.Id;
                insert cInput;
            }

            if (dInput.Name != null) {
                // Deal
                dInput.Related_Company__c = aInput.Id;
                dInput.Source__c = aInput.Source__c;
                dInput.Source_Name__c = aInput.Source_Contact__c;

                insert dInput;
                // Deal contact
                if (cInput.Id != null) {
                    insert new Deal_Contact__c(
                        Contact_Name__c = cInput.Id,
                        Deal__c = dInput.Id
                    );
                }
                // Team member
                if (aInput.SecondaryOwner__c != null) {
                    try {
                        insert new Team_Member__c(
                            Deal__c = dInput.Id,
                            Name__c = [SELECT Id FROM Employee__c WHERE SalesforceUser__c=:aInput.SecondaryOwner__c AND IsDeleted=FALSE LIMIT 1].Id
                        );
                    } catch (Exception e) {
                    }
                }

                ref = new PageReference('/' + dInput.Id);
            }
            
            if (tStatus != null && (tStatus.Description != null || tStatus.Next_Steps__c != null)) {
                tStatus.WhatId = aInput.Id;
                tStatus.OwnerId = UserInfo.getUserId();
                tStatus.Subject = 'Status Note';
                tStatus.Type = 'Prospect Call';
                tStatus.ActivityDate = System.today();
                tStatus.Completed_Date__c = System.today();
                tStatus.Status = 'Completed';
                
                insert tStatus;
            }

            if (tInput != null && (tInput.Reminder__c == 'One Time' || tInput.Reminder__c == 'Recurring')) {
                tInput.WhatID = aInput.Id;
                tInput.Subject = 'Reminder: Check in with company ' + aInput.Name;
                tInput.Type = 'Reminder';

                Integer interval = 0;
                if (tInput.Interval__c == '3 months') {
                    interval = 3;
                } else if (tInput.Interval__c == '6 months') {
                    interval = 6;
                } else if (tInput.Interval__c == '12 months') {
                    interval = 12;
                } else if (tInput.Interval__c == '24 months') {
                    interval = 24;
                }

                if (tInput.Reminder__c == 'One Time') {
                    tInput.ActivityDate = System.today().addMonths(interval);
                } else {
                    tInput.RecurrenceType = 'RecursMonthly';
                    tInput.isRecurrence = true;
                    tInput.RecurrenceInterval = interval;
                    tInput.RecurrenceStartDateOnly = System.today().addMonths(interval);
                    tInput.RecurrenceEndDateOnly = System.today().addYears(10);
                    if (System.today().Day() <=28) {
                        tInput.RecurrenceDayOfMonth = System.today().Day();
                    } else {
                        tInput.RecurrenceDayOfMonth = 28;
                    }
                }
                insert tInput;
            }

            if (tagThemes) {
                List<SObject> relatedThemes = new List<SObject>();
                for (ManageCompanyThemes.Theme t : themes) {
                    if (t.selected) {
                        relatedThemes.add(new Company_Theme__c(
                            Theme__c = t.record.Theme__r.Id,
                            Company__c = aInput.Id
                        ));
                        if (dInput.Id != null) {
                            relatedThemes.add(new Deal_Theme__c(
                                Theme__c = t.record.Theme__r.Id,
                                Deal__c = dInput.Id
                            ));
                        }
                    }
                }
                if (!relatedThemes.isEmpty()) {
                    insert relatedThemes;
                }
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }
        return ref;
    }
    
    public String getGaTeam(Id roleId) {
        String retVal = 'Other';
        if (roleId != null && roleMap.get(roleId) != null) {
            String role = roleMap.get(roleId);
            if (role.startsWith('Financial Services')) {
                retVal = 'Finance';
            } else if (role.startsWith('Healthcare') || role == 'Investment Professional') {
                retVal = 'Healthcare';
            } else if (role.startsWith('BS&T') || role == 'Business Services') {
                retVal = 'Business Services';
            } else if (role.startsWith('Energy & Resources')) {
                retVal = 'Energy & Resources';
            } else if (role.startsWith('Media & Consumer') || role.startsWith('Internet & Technology')) {
                retVal = 'Internet & Technology';
            } else if (role.startsWith('Brazil') || role.startsWith('Sao Paulo')) {
                retVal = 'Sao Paulo';
            } else if (role.startsWith('China')) {
                retVal = 'China';
            } else if (role.startsWith('Europe')) {
                retVal = 'Europe';
            } else if (role.startsWith('India') || role.startsWith('Mumbai')) {
                retVal = 'Mumbai';
            } else if (role.startsWith('Palo Alto')) {
                retVal = 'Palo Alto';
            }else if (role.startsWith('Singapore')) {
                retVal = 'Singapore';
            } else {
                retVal = 'Other';
            }
        }
        
        return retVal;
    }

        static testMethod void testQuickAdd() {
        Campaign c = new Campaign(Name='Campaign');
        insert c;
        
        Theme__c t = new Theme__c(Name='testTheme', Description__c='test case theme', Active__c='Active');
        insert t;
        
        Employee__c e = new Employee__c(SalesforceUser__c=UserInfo.getUserId(),Initials__c='ts999999999');
        insert e;
        QuickAddController controller = new QuickAddController();
        controller.aInput.Name = 'Name';
        controller.cInput.LastName = 'Last Name';
        controller.cInput.Campaign__c = c.Id;
        controller.dInput.Name = 'Name';
        controller.aInput.SecondaryOwner__c = e.Id;
        controller.tStatus = new Task(Description = 'task status description',Next_Steps__c = 'next steps');
        controller.tInput = new Task(Reminder__c = 'Recurring',Interval__c='24 Months');
        controller.save();

        controller.aInput.Name = null;
        controller.save();
        
        controller.aInput.Status__c = 'Live Deal';
        controller.aInput.Source__c = null;
        controller.save();
        
        for (UserRole u : [SELECT Name, Id FROM UserRole]) {
            controller.getGaTeam(u.Id);
        }
        
        Account acc = new Account(Name = 'Test Acc');
        Contact cont = new Contact(LastName = 'Test Last Name');
        controller.aInput = acc;
        controller.cInput = cont;
        controller.tInput = new Task(Reminder__c = 'One Time',Interval__c='24 Months');
        controller.tagThemes = true;
        controller.save();
    }
}