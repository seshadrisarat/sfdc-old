/*

Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 04/07/2010 - Task #10220 #10249 -- can be deleted now :)
*/
public class SSearch_Test_DealIdea {

    /*static testMethod void myUnitTest() {
        Account newAccount1 = new Account(Name='test', Industry='Media', Type='Other', Public_Private__c='Public', CurrencyIsoCode='USD', Status__c='Active', Client_Code__c='00000', TickerSymbol='qwe', Website='test.com');
        Account newAccount2 = new Account(Name='test2', Industry='Media', Type='Other', Public_Private__c='Public', CurrencyIsoCode='USD', Status__c='Active', Client_Code__c='00001', TickerSymbol='qwe', Website='test.com');
        insert newAccount1;
        insert newAccount2;
        
        Profile newProfile = [select Id from Profile limit 1];
        
        User newUser = new User(Username='test@yandex.ru',LastName='testName',Email='test@yandex.ru',Alias='EuKr',CommunityNickname='EugenKr',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id);
        insert newUser;
        
        Employee_Profile__c newEmployeeProfile1 = new Employee_Profile__c(First_Name__c='testFirstName', Last_Name__c='testLastName',User_Id__c=newUser.Id);
        Employee_Profile__c newEmployeeProfile2 = new Employee_Profile__c(First_Name__c='testFirstName', Last_Name__c='testLastName',User_Id__c=newUser.Id);
        insert newEmployeeProfile1;
        insert newEmployeeProfile2;

        Date aaDate = date.newInstance(2009,01,01);
        Ibanking_Project__c newDeal1 = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c,  i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.Deal_Idea__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        newDeal1.Name='test';
        newDeal1.Client__c = newAccount1.Id;
        newDeal1.EmailTriggerParams__c='STAFFER, ProjectStaffRequest';
        newDeal1.Est_Transaction_Size__c=12.4;
        newDeal1.Full_Description_of_Transaction__c='descr';
        newDeal1.Stage__c='Expense Code Request';
        //newDeal1.Staffer__c=newEmployeeProfile1.Id;
        newDeal1.Milestone_Agreements_Received_Date__c = aaDate;
        newDeal1.Milestone_AML_OFAC_Cleared_Date__c = aaDate;
        newDeal1.Milestone_DealTeamConflictCheckCleared__c = aaDate;
        newDeal1.Milestone_Expense_Code_Date__c = aaDate;
        newDeal1.Milestone_FINCEN_Cleared_Date__c = aaDate;
        newDeal1.Milestone_KYC_Cleared_Date__c = aaDate;
        newDeal1.Milestone_NBRC_Approved_Date__c = aaDate;
        newDeal1.Milestone_NBRC_Committee_Date__c = aaDate;
        //newDeal1.Milestone_Staffing_Date__c = aaDate;
        update newDeal1;
        
        Ibanking_Project__c newDeal2 = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c,  i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.Deal_Idea__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i where i.ID != :newDeal1.ID order by i.CreatedDate desc limit 1];
        newDeal2.Name='test';
        newDeal2.Client__c = newAccount1.Id;
        newDeal2.EmailTriggerParams__c='STAFFER, ProjectStaffRequest';
        newDeal2.Est_Transaction_Size__c=12.4;
        newDeal2.Full_Description_of_Transaction__c='descr';
        newDeal2.Stage__c='Expense Code Request';
        //newDeal2.Staffer__c=newEmployeeProfile1.Id;
        newDeal2.Milestone_Agreements_Received_Date__c = aaDate;
        newDeal2.Milestone_AML_OFAC_Cleared_Date__c = aaDate;
        newDeal2.Milestone_DealTeamConflictCheckCleared__c = aaDate;
        newDeal2.Milestone_Expense_Code_Date__c = aaDate;
        newDeal2.Milestone_FINCEN_Cleared_Date__c = aaDate;
        newDeal2.Milestone_KYC_Cleared_Date__c = aaDate;
        newDeal2.Milestone_NBRC_Approved_Date__c = aaDate;
        newDeal2.Milestone_NBRC_Committee_Date__c = aaDate;
        //newDeal2.Milestone_Staffing_Date__c = aaDate;
        update newDeal2; 


        Contact newContact1 = new Contact(LastName='test', FirstName='test');
        Contact newContact2 = new Contact(LastName='test', FirstName='test');
        insert newContact1;
        insert newContact2;
        
        DealIdea__c testDI1 = new DealIdea__c();
        DealIdea__c testDI2 = new DealIdea__c();
        insert testDI1;
        insert testDI2;
        
        Target_Buyers__c testTB1 = new Target_Buyers__c(Name='test');
        testTB1.Project__c = newDeal1.ID;
        Target_Buyers__c testTB2 = new Target_Buyers__c(Name='test');
        testTB2.Project__c = newDeal2.ID;
        insert testTB1;
        insert testTB2;

        





        Financial_Sponsors__c testFS1 = new Financial_Sponsors__c(Company_Name__c=newAccount1.Id,Financial_Sponsor_Name__c=newAccount2.Id);
        Financial_Sponsors__c testFS2 = new Financial_Sponsors__c(Company_Name__c=newAccount2.Id,Financial_Sponsor_Name__c=newAccount1.Id);
        insert testFS1;
        insert testFS2;
        
        Project_Client_Contact__c testPCC1 = new Project_Client_Contact__c(Client_Contact__c=newContact1.Id, Moelis_Project__c=newDeal1.Id);
        Project_Client_Contact__c testPCC2 = new Project_Client_Contact__c(Client_Contact__c=newContact2.Id, Moelis_Project__c=newDeal2.Id);
        insert testPCC1;
        insert testPCC2;
        /*
        Project_Resource__c testPR1 = new Project_Resource__c(Banker__c=newEmployeeProfile1.Id);
        Project_Resource__c testPR2 = new Project_Resource__c(Banker__c=newEmployeeProfile2.Id);
        insert testPR1;
        insert testPR2;
        *//*
        Deal_Related_Parties__c testDRP1 = new Deal_Related_Parties__c(Company__c=newAccount1.Id);
        Deal_Related_Parties__c testDRP2 = new Deal_Related_Parties__c(Company__c=newAccount2.Id);
        testDRP1.Deal__c = newDeal1.ID;
        testDRP2.Deal__c = newDeal2.ID;
        insert testDRP1;
        insert testDRP2;
        
        /*Key_Constituents__c testKC1 = new Key_Constituents__c(KC_Contact__c=newContact1.Id, Moelis_Project__c=newDeal1.Id);
        Key_Constituents__c testKC2 = new Key_Constituents__c(KC_Contact__c=newContact2.Id, Moelis_Project__c=newDeal2.Id);
        insert testKC1;
        insert testKC2;*//*
        
        Target_Buyer_Contacts__c testTBC1 = new Target_Buyer_Contacts__c(Contact__c=newContact1.Id, Target_Buyer__c=testTB1.Id);
        Target_Buyer_Contacts__c testTBC2 = new Target_Buyer_Contacts__c(Contact__c=newContact2.Id, Target_Buyer__c=testTB2.Id);
        insert testTBC1;
        insert testTBC2;
        
        Research_Client_Contact__c testRCC1 = new Research_Client_Contact__c(Client_Contact__c=newContact1.Id, Deal_Idea__c=testDI1.Id);
        Research_Client_Contact__c testRCC2 = new Research_Client_Contact__c(Client_Contact__c=newContact2.Id, Deal_Idea__c=testDI2.Id);
        insert testRCC1;
        insert testRCC2;
        
        Employee_Relationships__c testER1 = new Employee_Relationships__c(Contact__c=newContact1.Id,Employee__c=newEmployeeProfile1.Id);
        Employee_Relationships__c testER2 = new Employee_Relationships__c(Contact__c=newContact2.Id,Employee__c=newEmployeeProfile2.Id);
        insert testER1;
        insert testER2;
        
        
        Test.startTest();
         
        SSearch ss = new SSearch();


        ss.isTest = true;
        ss.searchStr = 'test';
        ss.setElemInBlock('1');
        String str1 = ss.getElemInBlock();
        ss.renderMode = '';
        String str2 = ss.getChooserender();
        String str3 = ss.getChooserender2();
        ss.renderMode = 'pdf';
        str2 = ss.getChooserender();
        str3 = ss.getChooserender2();
        List<String> strList = ss.getLinkPanel();
        List<SelectOption> soList = ss.getElemInBlockItems();
        Pagereference pr1 = ss.printPDF();
        Pagereference pr2 = ss.printExcel();
        Pagereference pr3 = ss.toSearch();
        String str4 = ss.getTraceInfo();

        
        
        ss.initList(); 
        
        
        
        
        SSearch.CommDetailObj test_sLastElemID = new SSearch.CommDetailObj();
        SSearch.CommDetailObj test_sFirstElemID = new SSearch.CommDetailObj();

        test_sLastElemID.DealIdeaObj = testDI1.Id;
        test_sFirstElemID.DealIdeaObj = testDI1.Id;
        ss.setSLastElemID(test_sLastElemID);
        ss.setSFirstElemID(test_sLastElemID);
        ss.setSortExpression('DealIdea');
        ss.PagindDirection = 'Prev';
        ss.ViewPagingData();
        ss.PagindDirection = 'Next';
        ss.ViewPagingData();

        
        
        Test.stopTest();
        
    }*/
}