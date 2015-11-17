@isTest
private class Test_Sharing {

    /*
    public static testMethod void testIt1() {
        //User testUser = [SELECT id, name, isActive FROM User WHERE isActive=false and lastname='test_sharing' LIMIT 1].get(0);
        Profile newProfile = [select Id from Profile limit 1];

        User testUser = new User(isActive=false, Username='ek@yandex.ru', LastName='test_sharing', Email='ek@yandex.ru', Alias='EuKr', CommunityNickname='EuKr', TimeZoneSidKey='Pacific/Fiji', LocaleSidKey='ar', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=newProfile.Id);
        insert testUser;
        
        testUser.isActive = false;
        update testUser;
        Account acc = new Account();
        acc.Client_Code__c = '12365';
        acc.Name = 'Test';
        insert acc;
        Employee_Profile__c testEmployee = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployee.User_ID__c = testUser.Id;
        insert testEmployee;

        Ibanking_Project__c testDeal = new Ibanking_Project__c(Client__c = acc.Id,Business_Type__c='TBD', Stage__c='New', Co_Advisors__c='qwe', Competitive_Landscape__c='qwe', Google_Internet_Check_Date__c=date.newInstance(2010,1,1), Google_Internet_Check_Results__c='asd', Estimated_Fee_Revenue__c=10, Expected_Close_Date__c='2011 Q2', Moelis_Role__c='Other', Expense_Code__c='123654376597', Proposed_Fee_Structure__c='zcs', Relationship_History__c='fgde', Description__c='asdf', Milestone_DealTeamConflictCheckCleared__c=date.newInstance(2010,1,1), Industry__c='Other', Region__c='EMEA', Sector__c='Cable', Transaction_Feature__c='Other', Transaction_Sub_Type__c='Other', Transaction_Type__c='Other',
            count_DealTeamMD__c = 3);
        insert testDeal;
        
        Project_Resource__c testResource = new Project_Resource__c(Project__c=testDeal.Id,Status__c='Active', Banker__c=testEmployee.Id);
        insert testResource;
        
        User_SharingRules_Update.updateSharingRules(testUser.Id);
        
        //testUser.isActive = true;
        //update testUser;
        Map<Id, Employee_Profile__c> Map_epId_ep = new Map<Id, Employee_Profile__c>();
        Map_epId_ep.put(testEmployee.id, testEmployee);
        Test.startTest();
        
        //User_SharingRules_Update.updateSharingRules(testUser.Id);
        //User_SharingRules_Update.updateSharingRules_Bulk(Map_epId_ep);
        Test.stopTest();
    }
    
    public static testMethod void testIt2() {
        //User testUser = [SELECT id, name, isActive FROM User WHERE isActive=false LIMIT 1].get(0);
        Profile newProfile = [select Id from Profile limit 1];

        User testUser = new User(isActive=false, Username='ek@yandex.ru', LastName='test_sharing', Email='ek@yandex.ru', Alias='EuKr', CommunityNickname='EuKr', TimeZoneSidKey='Pacific/Fiji', LocaleSidKey='ar', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=newProfile.Id);
        insert testUser;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Client_Code__c = '12365';
        insert acc;
        testUser.isActive = false;
        update testUser;
        
        Employee_Profile__c testEmployee = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployee.User_ID__c = testUser.Id;
        insert testEmployee;

        Ibanking_Project__c testDeal = new Ibanking_Project__c(Client__c = acc.Id,Business_Type__c='TBD', Stage__c='New', Co_Advisors__c='qwe', Competitive_Landscape__c='qwe', Google_Internet_Check_Date__c=date.newInstance(2010,1,1), Google_Internet_Check_Results__c='asd', Estimated_Fee_Revenue__c=10, Expected_Close_Date__c='2011 Q2', Moelis_Role__c='Other', Expense_Code__c='123654376597', Proposed_Fee_Structure__c='zcs', Relationship_History__c='fgde', Description__c='asdf', Milestone_DealTeamConflictCheckCleared__c=date.newInstance(2010,1,1), Industry__c='Other', Region__c='EMEA', Sector__c='Cable', Transaction_Feature__c='Other', Transaction_Sub_Type__c='Other', Transaction_Type__c='Other'
                , Engagement_Date__c=Date.today(), Est_Transaction_Size__c=300, Reason__c='test', Revenue_Probability__c='70', Transaction_Completion_date__c=Date.today(),
                count_DealTeamMD__c = 3);
        insert testDeal;
        
        Project_Resource__c testResource = new Project_Resource__c(Project__c=testDeal.Id, Status__c='Active',Banker__c=testEmployee.Id);
        insert testResource;
        
        //User_SharingRules_Update.updateSharingRules(testUser.Id);
        
        //testUser.isActive = true;
        //update testUser;
        Map<Id, Employee_Profile__c> Map_epId_ep = new Map<Id, Employee_Profile__c>();
        Map_epId_ep.put(testEmployee.id, testEmployee);
        Test.startTest();
        User_SharingRules_Update.updateSharingRules(testUser.Id);
        //User_SharingRules_Update.updateSharingRules_Bulk(Map_epId_ep);
        Test.stopTest();
    }
    
    public static testMethod void testIt3() {
        //User testUser = [SELECT id, name, isActive FROM User WHERE isActive=false LIMIT 1].get(0);
        Profile newProfile = [select Id from Profile limit 1];

        User testUser = new User(isActive=false, Username='ek@yandex.ru', LastName='test_sharing', Email='ek@yandex.ru', Alias='EuKr', CommunityNickname='EuKr', TimeZoneSidKey='Pacific/Fiji', LocaleSidKey='ar', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=newProfile.Id);
        insert testUser;
        
        Group testGroup = [SELECT id, name FROM Group LIMIT 1].get(0);
        
        //testUser.isActive = true;
        //update testUser;
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Client_Code__c = '12365';
        insert acc;
        Employee_Profile__c testEmployee = new Employee_Profile__c(Status__c='', Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployee.User_ID__c = testUser.Id;
        insert testEmployee;

        Ibanking_Project__c testDeal = new Ibanking_Project__c(Client__c = acc.Id,Business_Type__c='TBD', Stage__c='New', Co_Advisors__c='qwe', Competitive_Landscape__c='qwe', Google_Internet_Check_Date__c=date.newInstance(2010,1,1), Google_Internet_Check_Results__c='asd', Estimated_Fee_Revenue__c=10, Expected_Close_Date__c='2011 Q2', Moelis_Role__c='Other', Expense_Code__c='123654376597', Proposed_Fee_Structure__c='zcs', Relationship_History__c='fgde', Description__c='asdf', Milestone_DealTeamConflictCheckCleared__c=date.newInstance(2010,1,1), Industry__c='Other', Region__c='EMEA', Sector__c='Cable', Transaction_Feature__c='Other', Transaction_Sub_Type__c='Other', Transaction_Type__c='Other'
                , Engagement_Date__c=Date.today(), Est_Transaction_Size__c=300, Reason__c='test', Revenue_Probability__c='70', Transaction_Completion_date__c=Date.today(),
                count_DealTeamMD__c = 3);
        insert testDeal;
        
        Project_Resource__c testResource = new Project_Resource__c(Project__c=testDeal.Id,Status__c='Active', Banker__c=testEmployee.Id);
        insert testResource;
        
        //User_SharingRules_Update.updateSharingRules(testUser.Id);
        
        //testUser.isActive = true;
        //update testUser;
        Ibanking_Project__Share ps = new Ibanking_Project__Share();
        ps.ParentId = testDeal.Id;
        ps.UserOrGroupId = testGroup.Id;
        ps.AccessLevel = 'Edit';
        ps.RowCause = 'Manual';
        insert ps;
        
        Call_Log__c cl = new Call_Log__c();
        cl.Date__c = Date.today();
        cl.Organizer__c = testEmployee.Id;
        insert cl;
        
        //Project_Resource__c pr = new Project_Resource__c();
        //pr.Project__c = testDeal.Id;
        //pr.Banker__c = testEmployee.Id;
        //insert pr;
        
        Map<Id, Employee_Profile__c> Map_epId_ep = new Map<Id, Employee_Profile__c>();
        Map_epId_ep.put(testEmployee.id, testEmployee);
        Test.startTest();
        //User_SharingRules_Update.updateSharingRules(testUser.Id);
        User_SharingRules_Update.updateSharingRules_Bulk(Map_epId_ep);
        User_SharingRules_Update.updateCallLogSharingRules(testUser.Id);
        User_SharingRules_Update.updatePBISharingRules(testUser.Id);
        testEmployee.Status__c = 'Active';
        update testEmployee;
        User_SharingRules_Update.updateSharingRules_Bulk(Map_epId_ep);
        User_SharingRules_Update.updateCallLogSharingRules(testUser.Id);
        User_SharingRules_Update.updatePBISharingRules(testUser.Id);
        Test.stopTest();
    }
    */

    public static testmethod void testBatchDelete(){
        Profile newProfile = [select Id from Profile limit 1];

        User testUser = new User(isActive=false, Username='ek@yandex.ru', LastName='test_sharing', Email='ek@yandex.ru', Alias='EuKr', CommunityNickname='EuKr', TimeZoneSidKey='Pacific/Fiji', LocaleSidKey='ar', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=newProfile.Id);
        insert testUser;
        
        Group testGroup = [SELECT id, name FROM Group LIMIT 1].get(0);
        
        /*testUser.isActive = true;
        update testUser;*/
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Client_Code__c = '12365';
        insert acc;
        Employee_Profile__c testEmployee = new Employee_Profile__c(Status__c='', Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployee.User_ID__c = testUser.Id;
        insert testEmployee;

        Ibanking_Project__c testDeal = new Ibanking_Project__c(Client__c = acc.Id,Business_Type__c='TBD', Stage__c='New', Co_Advisors__c='qwe', Competitive_Landscape__c='qwe', Google_Internet_Check_Date__c=date.newInstance(2010,1,1), Google_Internet_Check_Results__c='asd', Estimated_Fee_Revenue__c=10, Expected_Close_Date__c='2011 Q2', Moelis_Role__c='Other', Expense_Code__c='123654376597', Proposed_Fee_Structure__c='zcs', Relationship_History__c='fgde', Description__c='asdf', Milestone_DealTeamConflictCheckCleared__c=date.newInstance(2010,1,1), Industry__c='Other', Region__c='EMEA', Sector__c='Cable', Transaction_Feature__c='Other', Transaction_Sub_Type__c='Other', Transaction_Type__c='Other'
                , Engagement_Date__c=Date.today(), Est_Transaction_Size__c=300, Reason__c='test', Revenue_Probability__c='70', Transaction_Completion_date__c=Date.today());
        insert testDeal;

        Schedule_Data__c testSched =  new Schedule_Data__c(Name = 'testsched', Object_Id__c = testDeal.Id, Type__c = 'Deal');
        SL_Batch_DeleteScheduleData batchDelete = new SL_Batch_DeleteScheduleData(new list<Id>{testSched.Id});
        Database.executeBatch(batchDelete, 200);
    }
    
    public static testmethod void SharingScheduler_Test(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c();
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = acc.Id;
        insert IbankProjObj;
        Schedule_Data__c sd = new Schedule_Data__c();
        sd.Object_Id__c = IbankProjObj.Id;
        sd.Type__c = 'Deal';
        insert sd;
        Call_Log__c cl = new Call_Log__c();
        cl.Date__c = Date.today();
        insert cl;
        Schedule_Data__c sd2 = new Schedule_Data__c();
        sd2.Object_Id__c = cl.Id;
        sd2.Type__c = 'Call Log';
        insert sd2;
        Potential_Buyer_Investor__c pbi = new Potential_Buyer_Investor__c(TargetBuyer__c = acc.Id);
        pbi.Project__c = IbankProjObj.Id;
        insert pbi;
        Schedule_Data__c sd3 = new Schedule_Data__c();
        sd3.Object_Id__c = pbi.Id;
        sd3.Type__c = 'PBI';
        insert sd3;
        Test.startTest();
        SharingScheduler sch = new SharingScheduler();
        String jobId = System.schedule('test SharingScheduler.cls',
            '0 0 0 3 9 ? 2022', sch);
        Test.stopTest();
    }
    
    /*
    public static testmethod void Batch_CallLogShareUPD_Test(){
        Test.startTest();
        Batch_CallLogShareUPD cls = new Batch_CallLogShareUPD(new List<Id>{});
        ID batchprocessid = Database.executeBatch(cls);
        cls.execute(null, new List<Id>{});
        Test.stopTest();
    }
    
    public static testmethod void Batch_DealShareUPD_Test(){
        Test.startTest();
        Batch_DealShareUPD cls = new Batch_DealShareUPD(new List<Id>{});
        ID batchprocessid = Database.executeBatch(cls);
        cls.execute(null, new List<Id>{});
        Test.stopTest();
    }
    
    public static testmethod void Batch_PBIShareUPD_Test(){
        Test.startTest();
        Batch_PBIShareUPD cls = new Batch_PBIShareUPD(new List<Id>{});
        ID batchprocessid = Database.executeBatch(cls);
        cls.execute(null, new List<Id>{});
        Test.stopTest();
    }
    */
    
    public static testmethod void CallLogSharingRules_Test(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cntct = new Contact();
        cntct.AccountId = acc.Id;
        cntct.FirstName = 'Test';
        cntct.LastName = 'Test';
        insert cntct;
        User newUser = [SELECT id, name FROM User WHERE isActive=true LIMIT 1].get(0);
        Employee_Profile__c empl = new Employee_Profile__c();
        empl.First_Name__c = 'Test';
        empl.Last_Name__c = 'Test';
        empl.User_ID__c = newUser.Id;
        insert empl;
        Call_Log__c cl = new Call_Log__c();
        cl.Date__c = Date.today();
        cl.Organizer__c = empl.Id;
        insert cl;
        Call_Log_Contact__c clc = new Call_Log_Contact__c();
        clc.Call_Log__c = cl.Id;
        clc.Contact__c = cntct.Id;
        insert clc;
        Call_Log_Moelis_Attendee__c cla = new Call_Log_Moelis_Attendee__c();
        cla.Employee__c = empl.Id;
        cla.Call_Log__c = cl.Id;
        insert cla;
        Test.startTest();
        CallLogSharingRules.UpdateShare(new List<Id>{cl.Id});
        Test.stopTest();
    }
}