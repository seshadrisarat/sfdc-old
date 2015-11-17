/*

Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 08/04/2010 - Task #10249
*/
@isTest
private class IP_Rule_and_Counter_Trigger_Test 
{
	static testmethod void doTest(){
		Account acc = new Account();
        acc.Name = 'Test';
        acc.Client_Code__c = '1';
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
        proj.Name = 'testPrivladTargetBuyers';
        proj.Business_Type__c = 'Capital';
        insert proj;
        update proj;
	}
	
    /*static testMethod void testThis() 
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


        Account newAccount1 = new Account(Name='Test1');
        insert newAccount1;

        
        Profile newProfile = [select Id from Profile limit 1];
        
        //User newUser = new User(Username='vikao@dynamo-ny.com1',LastName='Osmak',Email='vikao@dynamo-ny.com',Alias='vikao',CommunityNickname='vikaO',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id);
        //insert newUser;
        id id1 = UserInfo.getUserId();
        User newUser = [select id from User where id=:id1];
        
        Employee_Profile__c newEmployeeProfile = new Employee_Profile__c(First_Name__c='Eugen', Last_Name__c='Kryvobok',User_Id__c=newUser.Id);
        insert newEmployeeProfile;

		//Ibanking_Project__c newDeal = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        //Ibanking_Project__c newDeal2 = [Select i.website__c, i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i where i.ID != :newDeal.ID order by i.CreatedDate desc limit 1];
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Test.startTest();
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c();
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = acc.Id;
        //IbankProjObj.Name = 'testPrivladTargetBuyers';
        insert IbankProjObj;
        /*newDeal.Name='testPrivladTargetBuyers';
        newDeal.Client__c = newAccount1.Id;
        newDeal.EmailTriggerParams__c='STAFFER, ProjectStaffRequest';
        newDeal.Est_Transaction_Size__c=12.4;
        newDeal.Full_Description_of_Transaction__c='descr';
        newDeal.Business_Type__c = 'Capital';
        newDeal.Stage__c='PITCHING';
        newDeal.Expense_Code__c = 'test12345678';
        newDeal.Description__c = 'test';
        newDeal.Industry__c = 'Other';
        newDeal.Region__c = 'Asia';
        newDeal.Stage__c = 'Idea';*/
//      newDeal.Staffer__c=newEmployeeProfile.Id;  



            
       
       // update newDeal;
        
        /*newDeal2.Name='testPrivladTargetBuyers';
        newDeal2.Client__c = newAccount1.Id;
        newDeal2.Business_Type__c = 'Capital';
        newDeal2.EmailTriggerParams__c='STAFFER, ProjectStaffRequest';
        newDeal2.Est_Transaction_Size__c=12.4;
        newDeal2.Full_Description_of_Transaction__c='descr';
        newDeal2.Stage__c='Expense Code Request';
        newDeal2.Expense_Code__c = '';
        newDeal2.Description__c = 'test';*//*
        
        //newDeal2.Staffer__c=newEmployeeProfile.Id;       
       
       // update newDeal2;
        
        List<Ibanking_Project__c> testListIP = new List<Ibanking_Project__c>();
        //newDeal2.Expense_Code__c = 'test12345679';
        //testListIP.add(newDeal);
        //testListIP.add(newDeal2);
        //update testListIP;
        
        Test.stopTest();
        
        //delete IbankProjObj;
        
    }*/

}