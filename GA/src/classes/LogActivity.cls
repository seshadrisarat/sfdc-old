public with sharing class LogActivity {
    private static final String EXTERNAL = 'EXTERNAL';
    private static final String COMPANY = 'COMPANY';
    private static final String INTERNAL = 'INTERNAL';
    private String inputId;

    public List<Task> externalTasks { get; private set; }
    public List<Task> companyTasks { get; private set; }
    public List<Task> internalTasks { get; private set; }
    public Task detailInput { get; private set; }
    public Enhanced_Call__c externalInput { get; private set; }
    public Enhanced_Call__c companyInput { get; private set; }
    public Enhanced_Call__c internalInput { get; private set; }

    public transient String dmessage { get; set; }

    public LogActivity() {
        externalTasks = new List<Task>();
        companyTasks = new List<Task>();
        internalTasks = new List<Task>();
        detailInput = new Task(
            OwnerId = UserInfo.getUserId(),
            Status = 'Completed'
        );
        externalInput = new Enhanced_Call__c();
        companyInput = new Enhanced_Call__c();
        internalInput = new Enhanced_Call__c();

        try {
            inputId = ApexPages.currentPage().getParameters().get('Id');
            if (inputId.startsWith(Schema.SOBjectType.Account.getKeyPrefix())) {
                detailInput.WhatId = inputId;
            } else if (inputId.startsWith(Schema.SOBjectType.Contact.getKeyPrefix())) {
                Contact c = [SELECT Id, AccountId FROM Contact WHERE Id=:inputId LIMIT 1];
                detailInput.WhoId = inputId;
                detailInput.WhatId = c.AccountId;
                externalInput.Contact__c = c.Id;
                addExternal();
            } else if (inputId.startsWith(Schema.SOBjectType.Deal__c.getKeyPrefix())) {
                detailInput.WhatId = [SELECT Related_Company__c FROM Deal__c WHERE Id=:inputId LIMIT 1].Related_Company__c;
            }
            companyInput.Account__c = detailInput.WhatId;
            addCompany();
        } catch (Exception e) {
        }
    }

    private boolean addTask(String tType, Enhanced_Call__c tInput, List<Task> tasks) {
        for (Task t : tasks) {
            String a;
            String b;
            if(tType == EXTERNAL) {
                a = t.WhoId;
                b = tInput.Contact__c;
            } else if (tType == COMPANY) {
                a = t.WhatId;
                b = tInput.Account__c;
            } else if (tType == INTERNAL) {
                a = t.OwnerId;
                b = tInput.OwnerId;
            }
            if (a.startsWith(b)) {
                if(tType == EXTERNAL) {
                    tInput.Contact__c.addError('Contact already exists');
                } else if (tType == COMPANY) {
                    tInput.Account__c.addError('Company already exists');
                } else if (tType == INTERNAL) {
                    tInput.OwnerId.addError('User already exists');
                }
                // Already exists in list
                return false;
            }
        }
        if (tType == EXTERNAL) {
            tInput.Account__c = [SELECT AccountId FROM Contact WHERE Id=:tInput.Contact__c LIMIT 1].AccountId;
        }
        tasks.add(new Task(
            WhoId = tInput.Contact__c,
            WhatId = tInput.Account__c,
            OwnerId = tInput.OwnerId
        ));
        return true;
    }

    public void addExternal() {
        if (externalInput.Contact__c != null && addTask(EXTERNAL, externalInput, externalTasks)) {
            externalInput = new Enhanced_Call__c();
        }
    }

    public void addCompany() {
        if(companyInput.Account__c != null && addTask(COMPANY, companyInput, companyTasks)) {
            companyInput = new Enhanced_Call__c();
        }
    }

    public void addInternal() {
        if (internalInput.OwnerId != null && addTask(INTERNAL, internalInput, internalTasks)) {
            internalInput = new Enhanced_Call__c();
        }
    }

    private void removeTask(List<Task> tasks) {
        try {
            Integer index = Double.valueOf(ApexPages.currentPage().getParameters().get('index')).intValue();
            tasks.remove(index);
        } catch (Exception e) {
        }
    }

    public void removeExternal() {
        removeTask(externalTasks);
    }

    public void removeCompany() {
        removeTask(companyTasks);
    }

    public void removeInternal() {
        removeTask(internalTasks);
    }

    public PageReference save() {
        String accountId = (detailInput.WhatId == null ? '' : detailInput.WhatId);
        String contactId = (detailInput.WhoId == null ? '' : detailInput.WhoId);
        insert detailInput;
        
        List<Task> tasks = new List<Task>();
        for (Task t : externalTasks) {
            if (!contactId.startsWith(t.WhoId)) {
                tasks.add(new Task(
                    WhoId = t.WhoId,
                    WhatId = t.WhatId,
                    OwnerId = detailInput.OwnerId,
                    Subject = detailInput.Subject,
                    ActivityDate = detailInput.ActivityDate,
                    Completed_Date__c = detailInput.ActivityDate,
                    Type = detailInput.Type,
                    Description = detailInput.Description,
                    Status = 'Completed',
                    ParentId__c = detailInput.Id
                ));
            }
            if (t.Subject != null && t.Description != null && t.ActivityDate != null && t.OwnerId != null) {
                tasks.add(new Task(
                    WhoId = t.WhoId,
                    WhatId = t.WhatId,
                    OwnerId = t.OwnerId,
                    Subject = t.Subject,
                    ActivityDate = t.ActivityDate,
                    Description = t.Description,
                    ParentId__c = detailInput.Id
                ));
            }
        }
        for (Task t : companyTasks) {
            if (!accountId.startsWith(t.WhatId)) {
                tasks.add(new Task(
                    WhatId = t.WhatId,
                    OwnerId = detailInput.OwnerId,
                    Subject = detailInput.Subject,
                    ActivityDate = detailInput.ActivityDate,
                    Completed_Date__c = detailInput.ActivityDate,
                    Type = detailInput.Type,
                    Description = detailInput.Description,
                    Status = 'Completed',
                    ParentId__c = detailInput.Id
                ));
            }
        }
        for (Task t : internalTasks) {
            tasks.add(new Task(
                WhoId = detailInput.WhoId,
                WhatId = detailInput.WhatId,
                OwnerId = t.OwnerId,
                Subject = detailInput.Subject,
                ActivityDate = detailInput.ActivityDate,
                Completed_Date__c = detailInput.ActivityDate,
                Type = detailInput.Type,
                Description = detailInput.Description,
                Status = 'Completed',
                ParentId__c = detailInput.Id
            ));
        }
        if (!tasks.isEmpty()) {
            insert tasks;
        }
        if (inputId.startsWith(Schema.SOBjectType.Deal__c.getKeyPrefix()) && detailInput.Next_Steps__c != null) {
            try {
                update new Deal__c(
                    Id = inputId,
                    Deal_Comments__c = detailInput.Next_Steps__c
                );
            } catch (Exception e) {
            }
        }
        return cancel();
    }

    public PageReference cancel() {
        return new PageReference('/' + (inputId != null ? inputId : 'home/home.jsp'));
    }
}