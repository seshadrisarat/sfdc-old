public class TestSuite {
    static testMethod void testOverall() {
        //User u = [SELECT Id, LastName FROM User WHERE LastName = 'Fidler' AND isActive = TRUE LIMIT 1];
        User u = [SELECT Id, LastName FROM User WHERE isActive = TRUE LIMIT 1];

        Account a = new Account(name='Test Deal Company');
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
        insert d;

        Deal_Contact__c dc = new Deal_Contact__c(Deal__c=d.Id,Contact_Name__c=c.id);
        insert dc;

        Employee__c e = new Employee__c(SalesforceUser__c=u.Id,Initials__c='!TL');
        insert e;

        e.Initials__c = '!TL2';
        update e;

        Employee_Metrics__c em = new Employee_Metrics__c(Employee__c=e.id,Date__c=Date.today());
        insert em;

        Team_Member__c tm = new Team_Member__c(Deal__c=d.Id,Name__c=e.Id);
        insert tm;

        Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
        insert thm;
        
        thm.Name = 'Test Theme 2';
        update tm;

        Deal_Theme__c dt = new Deal_Theme__c(Deal__c=d.Id,Theme__c=thm.Id);
        insert dt;

        Company_Theme__c ct = new Company_Theme__c(Company__c=a.Id,Theme__c=thm.Id);
        insert ct;

        Task t = new Task(Subject='Test Script',ActivityDate=Date.today(),WhatId=d.Id,Description='TEST',Notify_Deal_Team__c=true);
        insert t;
        Task t2 = new Task(Subject='Test Script',ActivityDate=Date.today(),WhoId=c.Id,Notify_Deal_Team__c=true);
        insert t2;
        Task t3 = new Task(Subject='Prospect Call',Type='Prospect Call',ActivityDate=Date.today(),WhatId=a.Id,Description='TEST');
        insert t3;
        Task t4 = new Task(Subject='Prospect Meeting Notes',Type='Prospect Meeting Notes',ActivityDate=Date.today(),WhatId=a.Id);
        insert t4;

        Event evt = new Event(WhatId=a.Id, Subject='Prospect Meeting',Type='Prospect Meeting',ActivityDateTime=DateTime.now(), DurationInMinutes=1);
        insert evt;
        
        d.Status__c = 'Deal Won';
        d.Close_Date__c = Date.today();
        d.Competitive_Dynamic__c = 'Exclusive';
        update d;

        Utilities.quoteSet(new Set<Id>{'00NT00000012OxX'});
        Test.startTest();
        Utilities.dealReferralRollup(null);
        Utilities.dealsWorkedRollup(null);
        Utilities.employeeRollup(null);
        Utilities.themeRollup(null);
        Utilities.employeeMetric(Date.today());
        Test.stopTest();
    }

    static testMethod void testManageCompanyThemes() {
        Account a = new Account(name='Test Deal Company');
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        Employee__c e = new Employee__c(Initials__c='!TL');
        insert e;

        Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
        insert thm;

        ManageCompanyThemes controller = new ManageCompanyThemes(new ApexPages.StandardController(a));
        controller.newThemes[0].selected = true;
        controller.add();

        controller.oldThemes[0].selected = true;
        controller.remove();
    }

    static testMethod void testManageConferencesAwards() {
        Account a = new Account(name='Test Deal Company');
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        Conference_Award__c ca = new Conference_Award__c(Name='Award');
        insert ca;


        ManageCompanyConferencesAwards controller = new ManageCompanyConferencesAwards(new ApexPages.StandardController(a));
        controller.newConferencesAwards[0].selected = true;
        controller.add();

        controller.oldConferencesAwards[0].selected = true;
        controller.remove();
    }

    static testMethod void testManageDealContacts() {
        Account a = new Account(name='Test Deal Company');
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
        insert d;

        ManageDealContacts controller = new ManageDealContacts(new ApexPages.StandardController(d));
        controller.newContacts[0].record.Contact_Name__c = c.Id;
        controller.add();

        controller.oldContacts[0].selected = true;
        controller.remove();
    }

    static testMethod void testManageDealThemes() {
        Account a = new Account(name='Test Deal Company');
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
        insert d;

        Employee__c e = new Employee__c(Initials__c='!TL');
        insert e;

        Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
        insert thm;

        ManageDealThemes controller = new ManageDealThemes(new ApexPages.StandardController(d));
        controller.newThemes[0].selected = true;
        controller.add();

        controller.oldThemes[0].selected = true;
        controller.remove();
    }

    static testMethod void testManageCompanyFinancials() {
        Account a = new Account(name='Test Deal Company');
        insert a;

        ManageCompanyFinancials controller = new ManageCompanyFinancials(new ApexPages.StandardController(a));
        controller.add();
        controller.financials[0].Year__c = '2009';
        controller.save();

        controller.add();
        controller.financials[1].Year__c = '2008';
        controller.save();

        controller.add();
        controller.financials[2].Year__c = '2007';
        controller.save();

        controller.add();
        controller.financials[3].Year__c = 'year';
        controller.save();
        
        controller.remove();
    }

    static testMethod void testQuickAdd() {
        Campaign c = new Campaign(Name='Campaign');
        insert c;
        
        QuickAddController controller = new QuickAddController();
        controller.aInput.Name = 'Name';
        controller.cInput.LastName = 'Last Name';
        controller.cInput.Campaign__c = c.Id;
        controller.dInput.Name = 'Name';
        controller.save();

        controller.aInput.Name = null;
        controller.save();
    }
    
    static testMethod void testQuickAddContact() {
        
        QuickAddContactController controller = new QuickAddContactController();
        controller.aInput.Name = 'Name';
        controller.cInput.LastName = 'Last Name';
        controller.save();

        controller = new QuickAddContactController();
        controller.aInput.Name = 'Name';
        controller.cInput.LastName = 'Last Name 2';
        controller.save();
    }

    static testMethod void testTimeAllocation() {
        Employee__c e = new Employee__c(SalesforceUser__c=UserInfo.getUserId(),Initials__c='!U');
        insert e;

        Account a = new Account(name='Test Deal Company');
        insert a;

        Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
        insert d;

        Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
        insert thm;


        System.CurrentPageReference().getParameters().put('eid', e.Id);
        TimeAllocationController controller = new TimeAllocationController();
        controller.addLiveDeal();
        controller.addTheme();
        controller.addPortfolioCompany();
        controller.liveDealList.get(0).Related_Deal__c = d.Id;
        controller.liveDealList.get(0).Allocation__c = 1;
        controller.themeList.get(0).Related_Theme__c = thm.Id;
        controller.themeList.get(0).Allocation__c = 1;
        controller.portfolioCompanyList.get(0).Related_Company__c = a.Id;
        controller.portfolioCompanyList.get(0).Allocation__c = 1;       
        controller.prospectingList.get(0).Allocation__c = 1;
        controller.liveDealList.get(1).Related_Deal__c = d.Id;
        controller.liveDealList.get(1).Allocation__c = 1;
        controller.themeList.get(1).Related_Theme__c = thm.Id;
        controller.themeList.get(1).Allocation__c = 1;
        controller.portfolioCompanyList.get(1).Related_Company__c = a.Id;
        controller.portfolioCompanyList.get(1).Allocation__c = 1;       
        controller.saveAllocations();

        controller = new TimeAllocationController();
        System.CurrentPageReference().getParameters().put('category', TimeAllocationController.LIVE_DEALS);
        System.CurrentPageReference().getParameters().put('index', '0');
        for (Integer i=0; i<10; i++) {
            controller.deleteAllocation();
        }
        controller.saveAllocations();
        controller.previous();
        controller.next();
    }

    static testMethod void testInitializeDealBatchable() {
        try
        {
            User u = [SELECT Id, LastName FROM User WHERE LastName = 'Fidler' AND isActive = TRUE LIMIT 1];
    
            Account a = new Account(name='Test Deal Company');
            insert a;
    
            Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
            insert c;
    
            Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
            insert d;
    
            Deal_Contact__c dc = new Deal_Contact__c(Deal__c=d.Id,Contact_Name__c=c.id);
            insert dc;
    
            Employee__c e = new Employee__c(SalesforceUser__c=u.Id,Initials__c='!TL');
            insert e;
    
            Employee_Metrics__c em = new Employee_Metrics__c(Employee__c=e.id,Date__c=Date.today());
            insert em;
    
            Team_Member__c tm = new Team_Member__c(Deal__c=d.Id,Name__c=e.Id);
            insert tm;
    
            Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
            insert thm;
    
            thm.Name = 'Test Theme 2';
            update tm;
    
            Deal_Theme__c dt = new Deal_Theme__c(Deal__c=d.Id,Theme__c=thm.Id);
            insert dt;
    
            Test.startTest();
            Utilities.initializeDeal(null);
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug(e);
        }
    }

    static testMethod void testInitializeThemeBatchable() 
    {
        try
        {
            User u = [SELECT Id, LastName FROM User WHERE LastName = 'Fidler' AND isActive = TRUE LIMIT 1];
    
            Account a = new Account(name='Test Deal Company');
            insert a;
    
            Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
            insert c;
    
            Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
            insert d;
    
            Deal_Contact__c dc = new Deal_Contact__c(Deal__c=d.Id,Contact_Name__c=c.id);
            insert dc;
    
            Employee__c e = new Employee__c(SalesforceUser__c=u.Id,Initials__c='!TL');
            insert e;
    
            Employee_Metrics__c em = new Employee_Metrics__c(Employee__c=e.id,Date__c=Date.today());
            insert em;
    
            Team_Member__c tm = new Team_Member__c(Deal__c=d.Id,Name__c=e.Id);
            insert tm;
    
            Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
            insert thm;
    
            thm.Name = 'Test Theme 2';
            update tm;
    
            Deal_Theme__c dt = new Deal_Theme__c(Deal__c=d.Id,Theme__c=thm.Id);
            insert dt;
    
            Test.startTest();
            Utilities.initializeTheme(null);
            
            Utilities.themeRollup(null);
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug(e);
        }        
    }

    static testMethod void testInitializeEmployeeBatchable() 
    {
        try
        {
            User u = [SELECT Id, LastName FROM User WHERE LastName = 'Fidler' AND isActive = TRUE LIMIT 1];
    
            Account a = new Account(name='Test Deal Company');
            insert a;
    
            Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
            insert c;
    
            Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
            insert d;
    
            Deal_Contact__c dc = new Deal_Contact__c(Deal__c=d.Id,Contact_Name__c=c.id);
            insert dc;
    
            Employee__c e = new Employee__c(SalesforceUser__c=u.Id,Initials__c='!TL');
            insert e;
    
            Employee_Metrics__c em = new Employee_Metrics__c(Employee__c=e.id,Date__c=Date.today());
            insert em;
    
            Team_Member__c tm = new Team_Member__c(Deal__c=d.Id,Name__c=e.Id);
            insert tm;
    
            Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
            insert thm;
    
            thm.Name = 'Test Theme 2';
            update tm;
    
            Deal_Theme__c dt = new Deal_Theme__c(Deal__c=d.Id,Theme__c=thm.Id);
            insert dt;
    
            Test.startTest();
            Utilities.initializeEmployee(null);
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug(e);
        }        
    }

    static testMethod void testInitializeAccountBatchable() 
    {
        try
        {
            User u = [SELECT Id, LastName FROM User WHERE LastName = 'Fidler' AND isActive = TRUE LIMIT 1];
    
            Account a = new Account(name='Test Deal Company');
            insert a;
    
            Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
            insert c;
    
            Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
            insert d;
    
            Deal_Contact__c dc = new Deal_Contact__c(Deal__c=d.Id,Contact_Name__c=c.id);
            insert dc;
    
            Employee__c e = new Employee__c(SalesforceUser__c=u.Id,Initials__c='!TL');
            insert e;
    
            Employee_Metrics__c em = new Employee_Metrics__c(Employee__c=e.id,Date__c=Date.today());
            insert em;
    
            Team_Member__c tm = new Team_Member__c(Deal__c=d.Id,Name__c=e.Id);
            insert tm;
    
            Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
            insert thm;
    
            thm.Name = 'Test Theme 2';
            update tm;
    
            Deal_Theme__c dt = new Deal_Theme__c(Deal__c=d.Id,Theme__c=thm.Id);
            insert dt;
    
            Test.startTest();
            Utilities.initializeAccount(null);
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug(e);
        }           
    }

    static testMethod void testLogActivity() {
        Account a = new Account(name='Test Deal Company');
        insert a;
        Contact c1 = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c1;
        Contact c2 = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c2;

        ApexPages.currentPage().getParameters().put('Id', c1.Id);
        LogActivity controller = new LogActivity();
        controller.companyInput.Account__c = a.Id;
        controller.addCompany();
        controller.externalInput.Contact__c = c1.Id;
        controller.addExternal();
        controller.externalInput.Contact__c = c2.Id;
        controller.addExternal();
        controller.internalInput.OwnerId = UserInfo.getUserId();
        controller.addInternal();
        controller.internalInput.OwnerId = UserInfo.getUserId();
        controller.addInternal();
        controller.externalTasks[0].Subject = 'Subject';
        controller.externalTasks[0].Description = 'Description';
        controller.externalTasks[0].ActivityDate = Date.today();
        controller.externalTasks[0].OwnerId = UserInfo.getUserId();        
        controller.save();
        ApexPages.currentPage().getParameters().put('index', '0');
        controller.removeCompany();
        controller.removeExternal();
        controller.removeInternal();       
    }

    static testMethod void testRecentActivities() {
        Account a = new Account(name='Test Deal Company');
        insert a;
        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        ApexPages.currentPage().getParameters().put('Id', c.Id);
        LogActivity controller1 = new LogActivity();
        controller1.save();        
        RecentActivities controller2 = new RecentActivities(new ApexPages.standardController(a));
    }
}