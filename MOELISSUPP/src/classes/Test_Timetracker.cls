@isTest
private class Test_Timetracker {

    public static testMethod void TimeTrackerJSON_Test()
    {
        
        ID iCompanyRT = null;
        ID iDealRT = null;
        RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
        for(RecordType rtItem: recTypeIDs)
        {
            iCompanyRT = rtItem.ID;
        }

        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        Account accObj1 = new Account(Name='Company1');
        insert accObj1;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;

        //Test.startTest();
    Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        //Ibanking_Project__c IbankProjObj = [Select Referral_Source__c, i.website__c, i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c,  i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;
        IbankProjObj.Referral_Source__c = 'test';
        insert IbankProjObj;
        //IbankProjObj.Staffer__c = emplObj.ID;
        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Status__c = 'Active';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';       
        update IbankProjObj;
        
        
        Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID,Status__c = 'Active');
        insert ProgResObj;
        
        TimeSheet_Summary__c TSSummary = new TimeSheet_Summary__c(CurrencyIsoCode='USD');
        TSSummary.Name = 'Test TS Summary';
        TSSummary.Employee__c = emplObj.id;
        insert TSSummary;
        

        IbankProjObj.Name = 'Test Name-2';
        update IbankProjObj;
        Date myDate = date.today();
        String curPidIDTest = myDate.month()+'/'+myDate.day()+'/'+myDate.year();
        Time_Tracker__c ttTrack1 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        ttTrack1.Time_Sheet_Summary__c = TSSummary.id;
        insert ttTrack1;
        
        Test.startTest();
        System.currentPageReference().getParameters().put('tssid',TSSummary.Id);
        System.currentPageReference().getParameters().put('pid',curPidIDTest);
        System.currentPageReference().getParameters().put('empid',emplObj.Id);
        TimeTrackerJSON TrackerJSONClass = new TimeTrackerJSON();
        TrackerJSONClass.getTimeTrackers();
        Test.stopTest();
        
    }
    
    public static testMethod void TimeTrackerJSON2_Test()
    {
        
        
        
        ID iCompanyRT = null;
        ID iDealRT = null;
        RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
        for(RecordType rtItem: recTypeIDs)
        {
            iCompanyRT = rtItem.ID;
        }

        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        Account accObj1 = new Account(Name='Company1');
        insert accObj1;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;

        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        //Ibanking_Project__c IbankProjObj = [Select Referral_Source__c, i.website__c, i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c,  i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;
        IbankProjObj.Referral_Source__c = 'test';
        //DELETE FIELD: IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;

        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';

        update IbankProjObj;
        /*
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Sellside', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='FIG', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Client__c = accObj1.ID;
        IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        */
        
        Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other',Status__c = 'Active', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);
        insert ProgResObj;

        IbankProjObj.Name = 'Test Name-2';
        update IbankProjObj;
        
        TimeSheet_Summary__c tss = new TimeSheet_Summary__c(); 
        tss.Text__c = '';
        tss.Overall_Capacity__c = '';
      tss.Stage__c = 'NEW';
      tss.Employee__c = emplObj.Id;
      insert tss;
        
        Date myDate = date.today();
        String curPidIDTest = myDate.month()+'/'+myDate.day()+'/'+myDate.year();
        Time_Tracker__c ttTrack1 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        ttTrack1.Time_Sheet_Summary__c = tss.Id;
        insert ttTrack1;
        System.currentPageReference().getParameters().put('pid',curPidIDTest);
        System.currentPageReference().getParameters().put('empid',emplObj.Id);
        
        Test.startTest();
        TimeTrackerJSON2 TrackerJSONClass = new TimeTrackerJSON2();
        Test.stopTest();
        
    }
    
    
    public static testMethod void TimeTrackerJSON_test_Test()
    {
        ID iCompanyRT = null;
        ID iDealRT = null;
        RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
        for(RecordType rtItem: recTypeIDs)
        {
            iCompanyRT = rtItem.ID;
        }

        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' and Name like 'Capital%' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        Account accObj1 = new Account(Name='Company1',RecordTypeId=iCompanyRT,Type='Other',Industry='Other',Public_Private__c='Public',Client_Code__c='00001',EBITDA__c=2.0,Enterprise_Value__c=3.0,TickerSymbol='CSCO',Total_Revenue__c=10.0,Website='www.mail.ru');
        insert accObj1;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
        
        String curEmployeeIDtest = ''+TimeTracker.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        IbankProjObj = [Select Referral_Source__c, i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;
    IbankProjObj.Referral_Source__c = 'test';
        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        update IbankProjObj;
        
        Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other',Status__c = 'Active', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);
        insert ProgResObj;

        IbankProjObj.Name = 'Non-Deal Project';
        update IbankProjObj;
        
        TimeSheet_Summary__c TSSummary = new TimeSheet_Summary__c(CurrencyIsoCode='USD');
        TSSummary.Name = 'Test TS Summary';
        TSSummary.Employee__c = emplObj.id;
        insert TSSummary;
        

        Date myDate = date.today();
        myDate = TimeTracker.getFirstMondayInWeek(myDate);
        String curPidIDTest = myDate.month()+'/'+myDate.day()+'/'+myDate.year();
        Time_Tracker__c ttTrack1 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        ttTrack1.Time_Sheet_Summary__c = TSSummary.id;
        insert ttTrack1;
        
        myDate.addDays(-7);
        Time_Tracker__c ttTrack2 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        ttTrack2.Time_Sheet_Summary__c = TSSummary.id;
        //insert ttTrack2;
 
        //delete ttTrack2;

        System.currentPageReference().getParameters().put('pid', curPidIDTest);
        System.currentPageReference().getParameters().put('empid', emplObj.Id);
        TimeTrackerJSON_test MTrackerClass = new TimeTrackerJSON_test();
    }
    
    public static testMethod void TimeTracker_Test()
    {
        ID iCompanyRT = null;
        ID iDealRT = null;
        RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
        for(RecordType rtItem: recTypeIDs)
        {
            iCompanyRT = rtItem.ID;
        }

        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' and Name like 'Capital%' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        Account accObj1 = new Account(Name='Company1',RecordTypeId=iCompanyRT,Type='Other',Industry='Other',Public_Private__c='Public',Client_Code__c='00001',EBITDA__c=2.0,Enterprise_Value__c=3.0,TickerSymbol='CSCO',Total_Revenue__c=10.0,Website='www.mail.ru');
        insert accObj1;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
        
        Employee_Profile__c emplObjMD = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='MD', Last_Name__c='Test MD', Group__c='Capital Markets', First_Name__c='test MD');
        emplObjMD.User_ID__c = UserID;
        insert emplObjMD;
        
        String curEmployeeIDtest = ''+TimeTracker.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        //IbankProjObj = [Select i.Referral_source__c, i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;
    IbankProjObj.Referral_Source__c = 'test';
        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        update IbankProjObj;
        
        Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other',Status__c = 'Active', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);
        insert ProgResObj;

        IbankProjObj.Name = 'Non-Deal Project';
        update IbankProjObj;
        
        Date myDate = date.today();
        myDate = TimeTracker.getFirstMondayInWeek(myDate);
        
        TimeSheet_Summary__c TSSummary = new TimeSheet_Summary__c(CurrencyIsoCode='USD');
        TSSummary.Name = 'Test TS Summary';
        TSSummary.Employee__c = emplObj.id;
        TSSummary.Week_Start_Date__c = myDate;
        insert TSSummary;
        

        String curPidIDTest = myDate.month()+'/'+myDate.day()+'/'+myDate.year();
        Time_Tracker__c ttTrack1 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        ttTrack1.Time_Sheet_Summary__c = TSSummary.id;
        insert ttTrack1;
        
        myDate.addDays(-7);
        Time_Tracker__c ttTrack2 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID,Non_Deal_Project__c = 'Sick');
        ttTrack2.Time_Sheet_Summary__c = TSSummary.id;
        insert ttTrack2;
 
        delete ttTrack2;

        Test.startTest();
        
        System.currentPageReference().getParameters().put('pid', curPidIDTest);
        System.currentPageReference().getParameters().put('tssid', TSSummary.Id);
        
        System.currentPageReference().getParameters().put('empid', emplObj.Id);
        System.debug('============================'+System.currentPageReference().getParameters().get('pid'));
        TimeTracker MTrackerClass = new TimeTracker();
        System.debug('============================'+MTrackerClass.SelProjItem);
       

               
        MTrackerClass.isTest = true;
        MTrackerClass.epTestData = emplObj;
        PageReference pageRef = null;

        pageRef = MTrackerClass.selProject();
        pageRef = MTrackerClass.cancel();
        
        MTrackerClass.ErrorMsg = 'Error';
        MTrackerClass.SelWeekDateTT = ttTrack2;
        

        Employee_Profile__c Eprof = TimeTracker.getCurEmployee(curEmployeeIDtest);
     
         
        MTrackerClass.SelProjItem = '';
        List<String> lStr = MTrackerClass.getTBListPanel();
        lStr = MTrackerClass.getTBFormAddPanel();
        MTrackerClass.SelProjItem = 'NewWeek';
        lStr = MTrackerClass.getTBListPanel();
        lStr = MTrackerClass.getTBFormAddPanel();
        MTrackerClass.SelProjItem = curPidIDTest;
        lStr = MTrackerClass.getTBListPanel();
        lStr = MTrackerClass.getTBFormAddPanel();
        List<selectOption> lWeekDates = MTrackerClass.getWeekDatesOpts();
        
        Date dTest = MTrackerClass.parceDate('10/10/2009');
        dTest = MTrackerClass.parceDate('10/1');

        MTrackerClass.jsonContent = '{"rows" : ["'+IbankProjObj.ID+'"],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "Project Route 66","type" : "sflink"},';
        MTrackerClass.jsonContent += '{"value" : "Affinity Group Holding Inc","type" : "text"},';
        MTrackerClass.jsonContent += '{"value" : "'+emplObjMD.Id+'","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "Idea","type" : "text"},';
        MTrackerClass.jsonContent += '{"value" : "10.00","type" : "rtextO"},';
        MTrackerClass.jsonContent += '{"value" : "Heavy Workload","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "123","type" : "textareaO"}';
        MTrackerClass.jsonContent += ']]}';
        
        system.debug('UserTimeSheet_SummaryObj--------------------------->'+MTrackerClass.UserTimeSheet_SummaryObj);
        MTrackerClass.saveJson();
      
       String sss = MTrackerClass.getUserMsg();
       MTrackerClass.curEmployeeID = curEmployeeIDtest;
       Double ddd = MTrackerClass.getTotalHours();
        
           
       Time_Tracker__c var_getTTObj = MTrackerClass.getTTObj();
         
       MTrackerClass.setTTObj(var_getTTObj);
       Time_Tracker__c var_getTTObj2 = MTrackerClass.getSelWeekDateTTForEmpl();
       var_getTTObj2.Employee__c = UserID;
       MTrackerClass.SelWeekDateTT.Week_Start_Date__c = date.newinstance(2009, 10, 17);
       PageReference pr1 = MTrackerClass.createNewWeek();
             
       MTrackerClass.setSelWeekDateTTForEmpl(var_getTTObj2);
       Boolean sh_render = MTrackerClass.getShareRenderer();
       MTrackerClass.setUserMsg('TEST msg');
       
       System.currentPageReference().getParameters().put('sfdc.tabName','/index');
       PageReference pr2 = MTrackerClass.selectEmployee();
       
       emplObj = MTrackerClass.getCurEmployeeNew();
       List<String> llist =  MTrackerClass.getTBWeekFormPanel();
       List<String> llist2 =  MTrackerClass.getTBEmployeeFormPanel();
      
      // PageReference pr3 = MTrackerClass.save_and_new();
       
       
        MTrackerClass.jsonContent2 = '{"rows" : ["'+IbankProjObj.ID+'"],';
        MTrackerClass.jsonContent2 += '"table" : [[';
        MTrackerClass.jsonContent2 += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent2 += '{"value" : "Recruiting","type" : "text"},';
        MTrackerClass.jsonContent2 += '{"value" : "'+emplObj.Id+'","type" : "smplselectO"},';
        MTrackerClass.jsonContent2 += '{"value" : "25.00","type" : "rtextO2"},';
        MTrackerClass.jsonContent2 += '{"value" : "123","type" : "textareaO"}';
        MTrackerClass.jsonContent2 += ']]}';
        MTrackerClass.saveJson();
        

        
        MTrackerClass.jsonContent = '{"rows" : ["'+ttTrack1.ID+'"],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "Project Route 66","type" : "sflink"},';
        MTrackerClass.jsonContent += '{"value" : "Affinity Group Holding Inc","type" : "text"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "Idea","type" : "text"},';
        MTrackerClass.jsonContent += '{"value" : "10.00","type" : "rtextO2"},';
        MTrackerClass.jsonContent += '{"value" : "Heavy Workload","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "123","type" : "textareaO"}';
        MTrackerClass.jsonContent += ']]}';
        MTrackerClass.saveJson();
        //PageReference pr4 = MTrackerClass.saveDataTwo('Submitted');
        

    MTrackerClass.getOverallCapacity();
    MTrackerClass.getCapacity();  
    
    String s = MTrackerClass.selProjDate;
    MTrackerClass.setOverallCapacity('');
    MTrackerClass.getIsSubmited();
    boolean isTest = true;
    MTrackerClass.clearDuplicates();
    MTrackerClass.clearNewTimesheets(); 
        
       TimeTracker_logic.getTimeTrackerList(TSSummary.Id);
       TimeTracker_logic.getTimeTrackerList_nonDeal(TSSummary.Id);
       Test.stopTest();
    }    
    
    static testmethod void TrackerTest_Test() {
      Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cntct = new Contact();
    cntct.AccountId = acc.Id;
    cntct.FirstName = 'Test';
    cntct.LastName = 'Test';
    insert cntct;
        Ibanking_Project__c proj = new Ibanking_Project__c();
        proj.Transaction_Sub_Type__c = 'Other';
        proj.Transaction_Feature__c = 'Other';
        proj.Client__c = acc.Id;
        insert proj;
        
        Potential_Buyer_Investor__c pbi = new Potential_Buyer_Investor__c();
        pbi.Project__c = proj.Id;
        pbi.Type__c = 'Credit';
        pbi.TargetBuyer__c = acc.Id;
        
        insert pbi;
      Test.startTest();
      ApexPages.currentPage().getParameters().put('pid', proj.Id);
      TrackerTest cls = new TrackerTest();
      cls.getCurrDealObj();
      cls.cancel();
      TrackerTest.parceDate('16/02/1990');
      cls.rowsString = 'new_0:'+pbi.Id;
      cls.tableString = '|'+acc.Id+'||||||||||||||||||||||||||||'
              +':|'+acc.Id+'|||16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|16/02/1990|';
      cls.save();
      cls.save_close();
      cls.deleleString = ''+pbi.Id;
      cls.deleteObj();
      Test.stopTest();
    }
}