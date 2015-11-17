/*
Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 04/07/2010 - Task #10220 #10249
modified: Vika 05/14/2010 - Task #10350
*/
@isTest
public class SSearch_Test_Contact {
	@isTest(SeeAllData=true)
    static void myUnitTest() {
  
        
        
        List<Account> lstAccount = new List<Account>{
        												new Account(Name='test'),
        												new Account(Name='test')
        											};
        insert lstAccount;
        
        String ContactRecordTypeId = [Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType where SobjectType = 'Contact' and IsActive = true LIMIT 1].Id;
        
        Contact objContact = new Contact(LastName = 'Test - contact', AccountId = lstAccount[0].Id, RecordTypeId = ContactRecordTypeId, Email = 'brock@silverlinecrm.com',
        								 FirstName = 'Test');
        insert objContact;
        
        Profile newProfile = [select Id from Profile limit 1];
        
        User newUser = new User(Username='test11@yandex.ru',LastName='testName11',Email='test11@yandex.ru',Alias='EuKr11',CommunityNickname='EugenKr',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id);
        insert newUser;
        
        List<Employee_Profile__c> lstEmployeeProfile = new List<Employee_Profile__c>{
        																				new Employee_Profile__c(First_Name__c='testFirstName', Last_Name__c='testLastName',User_Id__c=newUser.Id),
        																				new Employee_Profile__c(First_Name__c='testFirstName', Last_Name__c='testLastName',User_Id__c=newUser.Id)
        																			};
        
        insert lstEmployeeProfile;

        Date aaDate = date.newInstance(2009,01,01);
        
        ID iDealRT = null;
        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' and Name like 'Capital%' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        
        Ibanking_Project__c newDeal1 = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        
        //Ibanking_Project__c newDeal1 = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        newDeal1.Name='test';
        newDeal1.Client__c = lstAccount[0].Id;
        newDeal1.EmailTriggerParams__c='STAFFER, ProjectStaffRequest';
        newDeal1.Est_Transaction_Size__c=12.4;
        newDeal1.Full_Description_of_Transaction__c='descr';
        newDeal1.Stage__c='Expense Code Request';
        
		newDeal1.Requesting_conflict_clearance__c='Yes';
		newDeal1.List_all_bankers_aware_of_transaction__c='Test';
		newDeal1.Name_of_counterparties__c='TestCounterParties';
		newDeal1.Name_of_parties_related_to_client__c='1';
		newDeal1.Other_relevant_info_for_conflict_check__c='fgdfgdf';
		newDeal1.Parties_related_to_counterparties__c = 'parties';
        
        insert newDeal1;
        //newDeal1.Staffer__c=lstEmployeeProfile[0].Id;
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
        
        Ibanking_Project__c newDeal2 = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        
        //Ibanking_Project__c newDeal2 = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i where i.ID != :newDeal1.ID order by i.CreatedDate desc limit 1];
        newDeal2.Name='test';
        newDeal2.Client__c = lstAccount[0].Id;
        newDeal2.EmailTriggerParams__c='STAFFER, ProjectStaffRequest';
        newDeal2.Est_Transaction_Size__c=12.4;
        newDeal2.Full_Description_of_Transaction__c='descr';
        newDeal2.Stage__c='Expense Code Request';
        
        newDeal2.Requesting_conflict_clearance__c='Yes';
		newDeal2.List_all_bankers_aware_of_transaction__c='Test';
		newDeal2.Name_of_counterparties__c='TestCounterParties';
		newDeal2.Name_of_parties_related_to_client__c='1';
		newDeal2.Other_relevant_info_for_conflict_check__c='fgdfgdf';
		newDeal2.Parties_related_to_counterparties__c = 'parties';
        insert newDeal2;
        //newDeal2.Staffer__c=lstEmployeeProfile[0].Id;
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

		
		List<Contact> lstContact = new List<Contact>{
														new Contact(LastName='test', FirstName='test', AccountId = lstAccount[0].Id, Email = 'brock@silverlinecrm.com'),
														new Contact(LastName='test', FirstName='test', AccountId = lstAccount[0].Id)
													};
		insert lstContact;
		
        
        /*DealIdea__c testDI1 = new DealIdea__c();
        DealIdea__c testDI2 = new DealIdea__c();
        insert testDI1;
        insert testDI2;*/
        Test.startTest();
        List<Potential_Buyer_Investor__c> lstPotentialBuyerInvestor = new List<Potential_Buyer_Investor__c>{
        																										new Potential_Buyer_Investor__c(Name='test', Project__c = newDeal1.ID, Type__c = 'Credit', TargetBuyer__c = lstAccount[0].Id),
        																										new Potential_Buyer_Investor__c(Name='test', Project__c = newDeal2.ID, Type__c = 'Credit', TargetBuyer__c = lstAccount[0].Id)
        																								    };
        insert lstPotentialBuyerInvestor;

        List<Financial_Sponsors__c> lstFinancialSponsors = new List<Financial_Sponsors__c>{
        																					 new Financial_Sponsors__c(Company_Name__c=lstAccount[0].Id,Financial_Sponsor_Name__c=lstAccount[1].Id),
        																					 new Financial_Sponsors__c(Company_Name__c=lstAccount[1].Id,Financial_Sponsor_Name__c=lstAccount[0].Id)
        																				  };
        
        insert lstFinancialSponsors;
        
        List<Project_Client_Contact__c> lstProjectClientContact = new List<Project_Client_Contact__c>{
        																								new Project_Client_Contact__c(Client_Contact__c=lstContact[0].Id, Moelis_Project__c=newDeal1.Id),
        																								new Project_Client_Contact__c(Client_Contact__c=lstContact[1].Id, Moelis_Project__c=newDeal2.Id)
        																							 };
        insert lstProjectClientContact;
        
        /*
        Project_Resource__c testPR1 = new Project_Resource__c(Banker__c=lstEmployeeProfile[0].Id);
        Project_Resource__c testPR2 = new Project_Resource__c(Banker__c=lstEmployeeProfile[1].Id);
        insert testPR1;
        insert testPR2;
        */
        
        List<Deal_Related_Parties__c> lstDealRelatedParties = new List<Deal_Related_Parties__c>{
        																							new Deal_Related_Parties__c(Company__c=lstAccount[0].Id, Deal__c = newDeal1.ID),
        																							new Deal_Related_Parties__c(Company__c=lstAccount[1].Id, Deal__c = newDeal2.ID)
        																						};
        insert lstDealRelatedParties;
        
        /*Key_Constituents__c testKC1 = new Key_Constituents__c(KC_Contact__c=lstContact[0].Id, Moelis_Project__c=newDeal1.Id);
        Key_Constituents__c testKC2 = new Key_Constituents__c(KC_Contact__c=lstContact[1].Id, Moelis_Project__c=newDeal2.Id);
        insert testKC1;
        insert testKC2;*/
        
        List<Potential_Buyer_Investor_Contact__c> lstPBSContact = new List<Potential_Buyer_Investor_Contact__c>{
        																											new Potential_Buyer_Investor_Contact__c(Contact__c=lstContact[0].Id, Target_Buyer__c=lstPotentialBuyerInvestor[0].Id),
        																											new Potential_Buyer_Investor_Contact__c(Contact__c=lstContact[1].Id, Target_Buyer__c=lstPotentialBuyerInvestor[1].Id)
        																										};
        
        insert lstPBSContact;
        
        /*Research_Client_Contact__c testRCC1 = new Research_Client_Contact__c(Client_Contact__c=lstContact[0].Id, Deal_Idea__c=testDI1.Id);
        Research_Client_Contact__c testRCC2 = new Research_Client_Contact__c(Client_Contact__c=lstContact[1].Id, Deal_Idea__c=testDI2.Id);
        insert testRCC1;
        insert testRCC2;*/
        
        List<Employee_Relationships__c> lstEmployeeRelationship = new List<Employee_Relationships__c>{
        																								new Employee_Relationships__c(Contact__c=lstContact[0].Id,Employee__c=lstEmployeeProfile[0].Id),
        																								new Employee_Relationships__c(Contact__c=lstContact[1].Id,Employee__c=lstEmployeeProfile[1].Id)
        																							 };
        
        insert lstEmployeeRelationship;
        
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

        //test_sLastElemID.DealIdeaObj = testDI1.Id;
        //test_sFirstElemID.DealIdeaObj = testDI1.Id;
        //ss.setSLastElemID(test_sLastElemID);
        //ss.setSFirstElemID(test_sLastElemID);
        ss.setSortExpression('Contact');
        ss.PagindDirection = 'Prev';
        ss.ViewPagingData();
        ss.PagindDirection = 'Next';
        ss.ViewPagingData();

        
        
        Test.stopTest();
        
    }
}