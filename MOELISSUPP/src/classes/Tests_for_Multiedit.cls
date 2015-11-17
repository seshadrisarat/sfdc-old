@isTest
private class Tests_for_Multiedit 
{
    public static testMethod void DealContacts_AddMultiple_Test()
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

        Contact testContact = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact;

        Contact testContact2 = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact2;

        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='AnalystNY', Group__c='Capital Markets', First_Name__c='', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
        
        Employee_Profile__c emplObj2 = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNYKK', Last_Name__c='AnalystNYKK', Group__c='Capital Markets', First_Name__c='', Business_Function__c='Analyst');
        emplObj2.User_ID__c = UserID;
        insert emplObj2;
        
        String curEmployeeIDtest = ''+TimeTracker.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        //IbankProjObj = [Select Referral_Source__c, i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c,  i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;

        IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';
        
        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';
        IbankProjObj.Engagement_Date__c = Date.today();
        IbankProjObj.Est_Transaction_Size__c = 100;
        IbankProjObj.Reason__c = 'test';
        IbankProjObj.Target__c = 'test';
        IbankProjObj.Transaction_Completion_Date__c = Date.today();

        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Referral_Source__c = 'test';
        update IbankProjObj;        
        
        Test.StartTest();

        System.currentPageReference().getParameters().put('did', IbankProjObj.Id);
        DealContacts_AddMultiple dt = new DealContacts_AddMultiple();
        PageReference pageRef = dt.cancel();
        //              
        
        Project_Client_Contact__c cnt = new Project_Client_Contact__c();
        cnt.Moelis_Project__c = IBankProjObj.Id;
        cnt.Client_Contact__c = testContact.Id;
        insert cnt;
        
        String JSText = '{"delList": ["'+cnt.Id+'", "'+cnt.Id+'"]}';
        dt.jsonContent = JSText;
        dt.canDelete = false;
        dt.saveJson();
        
        JSText = '{"rows": ["'+cnt.Id+'", "new_1"], '+
                        '"table": [[{"value": ""}, {"value": "TDO Test"}, {"value": {"lkid": "'+testContact.ID+'"}}, {"value": "Primary"}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}]'+
                                ', [{"value": ""}, {"value": "TDO Test"}, {"value": {"lkid": "'+testContact.ID+'"}}, {"value": "Primary"}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}]],'+
                        ' "delList": []}';
        dt.jsonContent = JSText;
        dt.canDelete = true;
        dt.save();
        
        JSText = '{"rows": ["new_1"], '+
                        '"table": [[{"value": ""}, {"value": "TDO Test"}, {"value": {"lkid": "'+testContact.ID+'"}}, {"value": "Primary"}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}, {"value": ""}]],'+
                        ' "delList": ["'+cnt.Id+'", "'+cnt.Id+'"]}';
        dt.jsonContent = JSText;
        dt.canDelete = true;
        dt.saveJSON();
        
        dt.jsonContent = '';
        dt.save_close();
        Project_Client_Contact__c curPR = [select id from  Project_Client_Contact__c where Moelis_Project__c=:IbankProjObj.id limit 1];
        //JSText = '{"head": ["", "Project Name", "Contact Name", "Role", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Contact Name", "message2": "Invalid Contact Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Primary", "label": "Primary"}, {"value": "Secondary", "label": "Secondary"}, {"value": "Team Member", "label": "Team Member"}], "validator": {"type": "noempty", "message": "Please assign Deal Contact Role", "minChars": "1"}}, {}], "rows": ["new_1"], "newRow": [{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "--None--", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "'+testContact.ID+'", "lkold": "'+testContact.Name+'", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "Primary", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": ["'+curPR.ID+'"]}';
        JSText = '{"head" : ["","Project Name","Contact Name","Company Name","Title","Phone","Email","Business City","Business State/Province","Role","Comments" ],"footer": [{"footer-type" : "tableCells","cells" : [{"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}}, {"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}},{"type" : "caption","data" : {"caption" : ""}}]}],"fields" : [{},{},{"validator" : {"type" : "noempty","message" : "Please enter Contact Name","message2" : "Invalid Contact Name","message4" : "Please use lookup to select a Contact","minChars" : "1"}},{},{},{},{"validator" : {"type" : "checkEmail","message" : "Invalid Email"}},{},{},{"values" :[{ "value" : "", "label" : "--None--"},{ "value" : "Primary", "label" : "Primary"},{ "value" : "Secondary", "label" : "Secondary"},{ "value" : "Team Member", "label" : "Team Member"},{ "value" : "Referral", "label" : "Referral"},{ "value" : "Consultant", "label" : "Consultant"}]},{}],"rows": ["new_1"],"newRow" : [{"value" : "","type" : "boolean",{"value" : "test test PBI","type" : "textO"},{"value" : {"lkid" : "","lkold" : "","lktp" : "003","formid" : "af","obj" : "Contact"},"type" : "lookupO2"},{"value" : "","type" : "textO"},{"value" : "","type" : "textO"},{"value" : "","type" : "textO"},{"value" : "","type" : "textO"},{"value" : "","type" : "textO"},{"value" : "","type" : "textO"},{"value" : "--None--","type" : "smplselectO",{"value" : "","type" : "textareaO"}],"table" : [[{"value" : "","type" : "boolean"},{"value" : "test test PBI","type" : "textO"},{"value" : "Donald Harrington","type" : "textO"},{"value" : "TYBRIN Corporation","type" : "rtextO"},{"value" : "President","type" : "rtextO"},{"value" : "(850)111111111","type" : "rtextO"},{"value" : "donh@tybrin.com","type" : "rtextO"},{"value" : "Fort Walton Beach","type" : "rtextO"},{ "value" : "FL","type" : "rtextO"},{ "value" : "FL","type" : "smplselectO"},{"value" : "FL","type" : "textareaO" }]], "delList": ["'+curPR.ID+'"]}';
        dt.jsonContent = JSText;
        dt.isTest = true;
        ///dt.saveJson();
        dt.canDelete = false;
        //dt.saveJson();
        ///pageRef = dt.save_close();
        curPR = [select id from  Project_Client_Contact__c where Moelis_Project__c=:IbankProjObj.id limit 1];
        JSText = '{"head": ["", "Project Name", "Contact Name", "Role", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Contact Name", "message2": "Invalid Contact Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Primary", "label": "Primary"}, {"value": "Secondary", "label": "Secondary"}, {"value": "Team Member", "label": "Team Member"}], "validator": {"type": "noempty", "message": "Please assign Deal Contact Role", "minChars": "1"}}, {}], "rows": ["'+curPR.ID+'"], "newRow": [{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "--None--", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "'+testContact.ID+'", "lkold": "'+testContact.Name+'", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "Primary", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.jsonContent = JSText;
        dt.canDelete = true;

        Test.stopTest();
        
        
        ///pageRef = dt.save();
        //dt.saveJson();
        
        JSText = '{"head": ["", "Project Name", "Contact Name", "Role", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Contact Name", "message2": "Invalid Contact Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Primary", "label": "Primary"}, {"value": "Secondary", "label": "Secondary"}, {"value": "Team Member", "label": "Team Member"}], "validator": {"type": "noempty", "message": "Please assign Deal Contact Role", "minChars": "1"}}, {}], "rows": ["new_1"], "newRow": [{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "--None--", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "'+testContact.ID+'", "lkold": "'+testContact.Name+'", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "Primary", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.jsonContent = JSText;
        //dt.saveJson();
        ///pageRef = dt.save_close();
    }
    
    public static testMethod void DealContacts_AddMultipleJSON_Test()
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

        Contact testContact = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
        
        String curEmployeeIDtest = ''+TimeTracker.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Acquiror__c = 'test';
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        //IbankProjObj = [Select i.website__c, i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IBankProjObj.Acquiror__c = 'test';
        IbankProjObj.Client__c = accObj1.ID;

        IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        IbankProjObj.Stage__c = 'TTTEST!';
        IbankProjObj.Engagement_Date__c = Date.today();
        IbankProjObj.Est_Transaction_Size__c = 100;
        IbankProjObj.Reason__c = 'test';
        IbankProjObj.Target__c = 'test';
        IbankProjObj.Transaction_Completion_Date__c = Date.today();

        //IbankProjObj.Staffer__c = emplObj.ID;
        update IbankProjObj;
        
        System.currentPageReference().getParameters().put('did', IbankProjObj.Id);
        DealContacts_AddMultipleJSON testClass = new DealContacts_AddMultipleJSON();
    }
    
    public static testMethod void DealContacts_AddMultiple_pages_Test()
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

        Contact testContact = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact;

        Contact testContact2 = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact2;

        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='AnalystNY', Group__c='Capital Markets', First_Name__c='', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
        
        Employee_Profile__c emplObj2 = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNYKK', Last_Name__c='AnalystNYKK', Group__c='Capital Markets', First_Name__c='', Business_Function__c='Analyst');
        emplObj2.User_ID__c = UserID;
        insert emplObj2;
        
        String curEmployeeIDtest = ''+TimeTracker.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        //IbankProjObj = [Select Referral_Source__c, i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;

        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Referral_Source__c = 'test';
        update IbankProjObj;        
        
        System.currentPageReference().getParameters().put('did', IbankProjObj.Id);
        DealContacts_AddMultiple_pages dt = new DealContacts_AddMultiple_pages();
        PageReference pageRef = dt.cancel();
        //              
        String JSText = '{"head": ["", "Project Name", "Contact Name", "Role", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Contact Name", "message2": "Invalid Contact Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Primary", "label": "Primary"}, {"value": "Secondary", "label": "Secondary"}, {"value": "Team Member", "label": "Team Member"}], "validator": {"type": "noempty", "message": "Please assign Deal Contact Role", "minChars": "1"}}, {}], "rows": ["new_1"], "newRow": [{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "--None--", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "'+testContact.ID+'", "lkold": "'+testContact.Name+'", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "Primary", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.jsonContent = JSText;
        dt.saveJson();
        dt.jsonContent = '';
        dt.saveJson();
        Project_Client_Contact__c curPR = [select id from  Project_Client_Contact__c where Moelis_Project__c=:IbankProjObj.id limit 1];
        JSText = '{"head": ["", "Project Name", "Contact Name", "Role", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Contact Name", "message2": "Invalid Contact Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Primary", "label": "Primary"}, {"value": "Secondary", "label": "Secondary"}, {"value": "Team Member", "label": "Team Member"}], "validator": {"type": "noempty", "message": "Please assign Deal Contact Role", "minChars": "1"}}, {}], "rows": ["new_1"], "newRow": [{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "--None--", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "'+testContact.ID+'", "lkold": "'+testContact.Name+'", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "Primary", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": ["'+curPR.ID+'"]}';
        dt.jsonContent = JSText;
        dt.isTest = true;
        dt.saveJson();
        dt.canDelete = false;
        //dt.saveJson();
        pageRef = dt.save_close();
        curPR = [select id from  Project_Client_Contact__c where Moelis_Project__c=:IbankProjObj.id limit 1];
        JSText = '{"head": ["", "Project Name", "Contact Name", "Role", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Contact Name", "message2": "Invalid Contact Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Primary", "label": "Primary"}, {"value": "Secondary", "label": "Secondary"}, {"value": "Team Member", "label": "Team Member"}], "validator": {"type": "noempty", "message": "Please assign Deal Contact Role", "minChars": "1"}}, {}], "rows": ["'+curPR.ID+'"], "newRow": [{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "--None--", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "'+testContact.ID+'", "lkold": "'+testContact.Name+'", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "Primary", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.jsonContent = JSText;
        dt.canDelete = true;
        
        
        pageRef = dt.save();
        //dt.saveJson();
        
        JSText = '{"head": ["", "Project Name", "Contact Name", "Role", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Contact Name", "message2": "Invalid Contact Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Primary", "label": "Primary"}, {"value": "Secondary", "label": "Secondary"}, {"value": "Team Member", "label": "Team Member"}], "validator": {"type": "noempty", "message": "Please assign Deal Contact Role", "minChars": "1"}}, {}], "rows": ["new_1"], "newRow": [{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "--None--", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "TDO Test", "type": "textO"}, {"value": {"lkid": "'+testContact.ID+'", "lkold": "'+testContact.Name+'", "lktp": "003", "formid": "af", "obj": "Contact"}, "type": "lookupO2"}, {"value": "Primary", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.jsonContent = JSText;
        //dt.saveJson();
        pageRef = dt.save_close();
    }
    
    public static testMethod void Deal_Contacts_AddMultipleJSON_pages_Test()
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

        Contact testContact = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
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
        
        //IbankProjObj = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;

        IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        update IbankProjObj;
        
        System.currentPageReference().getParameters().put('did', IbankProjObj.Id);
        DealContacts_AddMultipleJSON_pages testClass = new DealContacts_AddMultipleJSON_pages();        
    }
    
    
    
    public static testMethod void ContactMoelisRelationshipAddMultipleJSON_Test()
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

        Contact testContact = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
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
        
        //IbankProjObj = [Select Referral_Source__c, i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;

        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Referral_Source__c = 'test';
        update IbankProjObj;
        
        System.currentPageReference().getParameters().put('did', testContact.Id);
        ContactMoelisRelationshipAddMultipleJSON testClass = new ContactMoelisRelationshipAddMultipleJSON();
    }
    
    public static testMethod void ContactMoelisRelationship_AddMultiple_Test()
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

        Contact testContact = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact;

        Contact testContact2 = new Contact(AccountId=accObj1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact2;

        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='AnalystNY', Group__c='Capital Markets', First_Name__c='', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
        
        Employee_Profile__c emplObj2 = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNYKK', Last_Name__c='AnalystNYKK', Group__c='Capital Markets', First_Name__c='', Business_Function__c='Analyst');
        emplObj2.User_ID__c = UserID;
        insert emplObj2;
        
        String curEmployeeIDtest = ''+TimeTracker.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        //IbankProjObj = [Select Referral_Source__c, i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;

        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Referral_Source__c = 'test';
        update IbankProjObj;
        
        Employee_Relationships__c empRL = new Employee_Relationships__c(Employee__c=emplObj.id,Contact__c=testContact.id,relationship_notes__c='',Relationship_Type__c='Client', Relationship_Strength__c='Low');
        insert empRL;

        Employee_Relationships__c empRL2 = new Employee_Relationships__c(Employee__c=emplObj.id,Contact__c=testContact.id,relationship_notes__c='',Relationship_Type__c='Client', Relationship_Strength__c='Low');
        insert empRL2;
            
        
        System.currentPageReference().getParameters().put('did', testContact.Id);
        ContactMoelisRelationship_AddMultiple dt = new ContactMoelisRelationship_AddMultiple();
        PageReference pageRef = dt.cancel();
        //dt.isTest = true;
        String JSText = '{"rows": ["new_1"], "table": [[{"value": "", "type": "boolean"}, ';
        JSText += ' {"value" : "CurContactName","type" : "textO"},{"value" : "CurContactName","type" : "textO"},';
        JSText += ' {"value": {"lkid": "'+emplObj.ID+'", "lkold": "'+emplObj.Name+'", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, ';
        JSText += '{"value": "Client", "type": "smplselectO"}, {"value": "High", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], ';
        JSText += '"delList": ['+empRL.Id+']}';
        dt.jsonContent = JSText;
        dt.saveJson();
        //dt.isTest = false;
        dt.jsonContent = '';
        dt.saveJson();
    
        JSText = '{"rows": ["'+empRL2.Id+'"], "table": [[{"value": "", "type": "boolean"}, ';
        JSText += '{"value" : "CurContactName","type" : "textO"},{"value" : "CurContactName","type" : "textO"},';
        JSText += ' {"value" : "CurContactName","type" : "textO"}, ';
        JSText += '{"value": "Client", "type": "smplselectO"}, {"value": "High", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], ';
        JSText += '}';
        dt.jsonContent = JSText;
        //dt.isTest = true;
        dt.save();
        
        
        dt.canDelete = false;
        pageRef = dt.save_close();

        dt.canDelete = true;

        dt.jsonContent = '';
        pageRef = dt.save_close();
    }
    
    public static testMethod void DealTeam_AddMultipleJSON_Test()
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
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
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
        
        //IbankProjObj = [Select Referral_Source__c, i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;

        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Referral_Source__c = 'test';
        update IbankProjObj;
        
        System.currentPageReference().getParameters().put('did', IbankProjObj.Id);
        DealTeam_AddMultipleJSON DealTeamRLClass = new DealTeam_AddMultipleJSON();
        DealTeam_AddMultipleJSON.getHint_Role();
        DealTeam_AddMultipleJSON.getHint_Status();
    }
    
    public static testMethod void DealTeam_AddMultiple_Test()
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
        
        List<Employee_Profile__c> lstEmployeeProfile = new List<Employee_Profile__c>{
                                                                                        new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='AnalystNY', Group__c='Capital Markets', 
                                                                                        First_Name__c='Test', Business_Function__c='Analyst', User_ID__c = UserID),
                                                                                        new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNYKK', Last_Name__c='AnalystNYKK', Group__c='Capital Markets', 
                                                                                        First_Name__c='Test', Business_Function__c='Analyst',  User_ID__c = UserID),
                                                                                        new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='MD',First_Name__c='Test', Last_Name__c='MDNYKK',User_ID__c = UserID)
                                                                                    };
        insert lstEmployeeProfile;
        String curEmployeeIDtest = ''+TimeTracker.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        //IbankProjObj = [Select Referral_Source__c, i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;

        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Referral_Source__c = 'test';
        update IbankProjObj; 
        
        List<Project_Resource__c> lstProjectResource = new List<Project_Resource__c>{
                                                                                        new Project_Resource__c(Role__c='Other', Status__c='Active', Project__c=IbankProjObj.ID, Banker__c=lstEmployeeProfile[2].ID),
                                                                                        new Project_Resource__c(Role__c='Other', Status__c='Active', Project__c=IbankProjObj.ID, Banker__c=lstEmployeeProfile[0].ID)
                                                                                    };
    
        insert lstProjectResource;
        System.currentPageReference().getParameters().put('did', IbankProjObj.Id);
        DealTeam_AddMultiple dt = new DealTeam_AddMultiple();
        PageReference pageRef = dt.cancel();
        String JSText = '{"head": [" ", "Project Name", "Employee Name", "Role", "Status", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Employee Name", "message2": "Invalid Employee Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Senior Sponsor", "label": "Senior Sponsor"}, {"value": "Project Sponsor", "label": "Project Sponsor"}, {"value": "Project Director", "label": "Project Director"}, {"value": "Project Administrator", "label": "Project Administrator"}, {"value": "Industry Banker", "label": "Industry Banker"}, {"value": "Product Banker", "label": "Product Banker"}, {"value": "Regional Banker", "label": "Regional Banker"}, {"value": "Deal Team Member", "label": "Deal Team Member"}, {"value": "Administrative Assistant", "label": "Administrative Assistant"}, {"value": "Other", "label": "Other"}], "validator": {"type": "noempty", "message": "Please assign Deal Team Role", "minChars": "1"}}, {"values": [{"value": "Active", "label": "Active"}, {"value": "Inactive", "label": "Inactive"}]}, {}], "rows": ["new_2"], "newRow": [{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "", "type": "smplselectO"}, {"value": "Active", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "'+lstEmployeeProfile[0].ID+'", "lkold": "AnalystNY", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "Project Director", "type": "smplselectO"}, {"value": "Active", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.jsonContent = JSText;
        dt.isTest = true;
        dt.saveJson();
        dt.jsonContent = '';
        dt.isTest = true;
        dt.saveJson();
        Project_Resource__c curPR11 = [select id from Project_Resource__c where Project__c=:IbankProjObj.id limit 1];
        JSText = '{"head": [" ", "Project Name", "Employee Name", "Role", "Status", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Employee Name", "message2": "Invalid Employee Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Senior Sponsor", "label": "Senior Sponsor"}, {"value": "Project Sponsor", "label": "Project Sponsor"}, {"value": "Project Director", "label": "Project Director"}, {"value": "Project Administrator", "label": "Project Administrator"}, {"value": "Industry Banker", "label": "Industry Banker"}, {"value": "Product Banker", "label": "Product Banker"}, {"value": "Regional Banker", "label": "Regional Banker"}, {"value": "Deal Team Member", "label": "Deal Team Member"}, {"value": "Administrative Assistant", "label": "Administrative Assistant"}, {"value": "Other", "label": "Other"}], "validator": {"type": "noempty", "message": "Please assign Deal Team Role", "minChars": "1"}}, {"values": [{"value": "Active", "label": "Active"}, {"value": "Inactive", "label": "Inactive"}]}, {}], "rows": ["new_2"], "newRow": [{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "", "type": "smplselectO"}, {"value": "Active", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "'+lstEmployeeProfile[0].ID+'", "lkold": "'+lstEmployeeProfile[0].Name+'", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "Project Director", "type": "smplselectO"}, {"value": "Active", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": ["'+curPR11.ID+'"]}';
        dt.jsonContent = JSText;
        dt.isTest = true;
        dt.saveJson();
        dt.canDelete = false;
        dt.isTest = true;
        dt.saveJson();
        pageRef = dt.save_close();
        //curPR = [select id from Project_Resource__c where Project__c=:IbankProjObj.id limit 1];
        JSText = '{"head": [" ", "Project Name", "Employee Name", "Role", "Status", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Employee Name", "message2": "Invalid Employee Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Senior Sponsor", "label": "Senior Sponsor"}, {"value": "Project Sponsor", "label": "Project Sponsor"}, {"value": "Project Director", "label": "Project Director"}, {"value": "Project Administrator", "label": "Project Administrator"}, {"value": "Industry Banker", "label": "Industry Banker"}, {"value": "Product Banker", "label": "Product Banker"}, {"value": "Regional Banker", "label": "Regional Banker"}, {"value": "Deal Team Member", "label": "Deal Team Member"}, {"value": "Administrative Assistant", "label": "Administrative Assistant"}, {"value": "Other", "label": "Other"}], "validator": {"type": "noempty", "message": "Please assign Deal Team Role", "minChars": "1"}}, {"values": [{"value": "Inactive", "label": "Inactive"}, {"value": "Active", "label": "Active"}]}, {}], "rows": ["'+lstProjectResource[0].ID+'"], "newRow": [{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "", "type": "smplselectO"}, {"value": "Active", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "'+lstEmployeeProfile[1].ID+'", "lkold": "'+lstEmployeeProfile[1].Name+'", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "Project Director", "type": "smplselectO"}, {"value": "", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.jsonContent = JSText;
        dt.canDelete = true;

        Test.startTest();
        
        pageRef = dt.save();
        //dt.saveJson();
        JSText = '{"head": [" ", "Project Name", "Employee Name", "Role", "Status", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Employee Name", "message2": "Invalid Employee Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Senior Sponsor", "label": "Senior Sponsor"}, {"value": "Project Sponsor", "label": "Project Sponsor"}, {"value": "Project Director", "label": "Project Director"}, {"value": "Project Administrator", "label": "Project Administrator"}, {"value": "Industry Banker", "label": "Industry Banker"}, {"value": "Product Banker", "label": "Product Banker"}, {"value": "Regional Banker", "label": "Regional Banker"}, {"value": "Deal Team Member", "label": "Deal Team Member"}, {"value": "Administrative Assistant", "label": "Administrative Assistant"}, {"value": "Other", "label": "Other"}], "validator": {"type": "noempty", "message": "Please assign Deal Team Role", "minChars": "1"}}, {"values": [{"value": "Inactive", "label": "Inactive"}, {"value": "Active", "label": "Active"}]}, {}], "rows": ["123"], "newRow": [{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "", "type": "smplselectO"}, {"value": "Active", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "'+lstEmployeeProfile[1].ID+'", "lkold": "'+lstEmployeeProfile[1].Name+'", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "Project Director", "type": "smplselectO"}, {"value": "", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.isTest = true;
        dt.saveJson();
        
        JSText = '{"head": [" ", "Project Name", "Employee Name", "Role", "Status", "Comments"], "footer": [{"footer-type": "tableCells", "cells": [{"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}, {"type": "caption", "data": {"caption": ""}}]}], "fields": [{}, {}, {"validator": {"type": "noempty", "message": "Please enter Employee Name", "message2": "Invalid Employee Name", "minChars": "1"}}, {"values": [{"value": "", "label": "--None--"}, {"value": "Senior Sponsor", "label": "Senior Sponsor"}, {"value": "Project Sponsor", "label": "Project Sponsor"}, {"value": "Project Director", "label": "Project Director"}, {"value": "Project Administrator", "label": "Project Administrator"}, {"value": "Industry Banker", "label": "Industry Banker"}, {"value": "Product Banker", "label": "Product Banker"}, {"value": "Regional Banker", "label": "Regional Banker"}, {"value": "Deal Team Member", "label": "Deal Team Member"}, {"value": "Administrative Assistant", "label": "Administrative Assistant"}, {"value": "Other", "label": "Other"}], "validator": {"type": "noempty", "message": "Please assign Deal Team Role", "minChars": "1"}}, {"values": [{"value": "Active", "label": "Active"}, {"value": "Inactive", "label": "Inactive"}]}, {}], "rows": ["'+lstProjectResource[0].ID+'"], "newRow": [{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "", "type": "smplselectO"}, {"value": "Active", "type": "smplselectO"}, {"value": "", "type": "textareaO"}], "table": [[{"value": "", "type": "boolean"}, {"value": "testPri1", "type": "textO"}, {"value": {"lkid": "", "lkold": "", "lktp": "a0A", "formid": "af", "obj": "EmployeeProfile"}, "type": "lookupO2"}, {"value": "Project Director", "type": "smplselectO"}, {"value": "Active", "type": "smplselectO"}, {"value": "", "type": "textareaO"}]], "delList": []}';
        dt.jsonContent = JSText;
        //dt.saveJson();
        pageRef = dt.save_close();

        Test.stopTest();
    }
}