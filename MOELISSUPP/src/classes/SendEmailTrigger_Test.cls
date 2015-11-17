/*

Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 08/04/2010 - Task #10249
*/
@isTest
private class SendEmailTrigger_Test {
    static testMethod void testThis() {
        Account newAccount1 = new Account(Name='Test1');
        Account newAccount2 = new Account(Name='Test2');
        insert newAccount1;
        insert newAccount2;
        
        Profile newProfile = [select Id from Profile limit 1];
        
        //User newUser = new User(Username='ekrivobok@yandex.ru1',LastName='Kryvobok',Email='ekrivobok@yandex.ru',Alias='EuKr',CommunityNickname='EugenKr',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id);
        //insert newUser;
        id id1 = UserInfo.getUserId();
        User newUser = [select id from User where id=:id1];
        
        Employee_Profile__c newEmployeeProfile = new Employee_Profile__c(First_Name__c='Eugen', Last_Name__c='Kryvobok',User_Id__c=newUser.Id);
        insert newEmployeeProfile;

        Test.startTest();
        
        EmailTemplate emailTemplateObj = [select Id, developerName from EmailTemplate limit 1];
        
        
        ID iDealRT = null;
        
        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' and Name like 'Capital%' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        //Ibanking_Project__c newDeal = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        Ibanking_Project__c newDeal = new Ibanking_Project__c(Requesting_conflict_clearance__c = 'No', RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        
        newDeal.Name='testTargetBuyers';
        newDeal.Client__c = newAccount1.Id;
        newDeal.EmailTriggerParams__c='MOELIS_TEAM, '+emailTemplateObj.developerName;
        newDeal.Est_Transaction_Size__c=12.4;
        newDeal.Full_Description_of_Transaction__c='descr';
        newDeal.Stage__c='Expense Code Request';
        //newDeal.Staffer__c=newEmployeeProfile.Id;
        
        newDeal.Milestone_Agreements_Received_Date__c       = date.newInstance(2009,01,01);
        newDeal.Milestone_AML_OFAC_Cleared_Date__c          = date.newInstance(2009,01,01);
        newDeal.Milestone_DealTeamConflictCheckCleared__c   = date.newInstance(2009,01,01);
        newDeal.Milestone_Expense_Code_Date__c              = date.newInstance(2009,01,01);
        newDeal.Milestone_FINCEN_Cleared_Date__c            = date.newInstance(2009,01,01);
        newDeal.Milestone_KYC_Cleared_Date__c               = date.newInstance(2009,01,01);
        newDeal.Milestone_NBRC_Approved_Date__c             = date.newInstance(2009,01,01);
        newDeal.Milestone_NBRC_Committee_Date__c            = date.newInstance(2009,01,01);
        //newDeal.Milestone_Staffing_Date__c                    = date.newInstance(2009,01,01);
        insert newDeal;

     Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other', Project__c=newDeal.ID, Banker__c=newEmployeeProfile.ID);
        insert ProgResObj;        
        
        try{
          update newDeal;
        } catch (Exception e) {} 
        
       
        

        //newDeal.EmailTriggerParams__c='MOELIS_TEAM, '+emailTemplateObj.developerName;
        //update newDeal; 
/*
        Ibanking_Project__c newDeal = new Ibanking_Project__c(Client__c = newAccount1.Id,EmailTriggerParams__c='STAFFER, ProjectStaffRequest',Est_Transaction_Size__c=12.4,Full_Description_of_Transaction__c='descr',Stage__c='Expense Code Request',Staffer__c=newEmployeeProfile.Id);
        newDeal.Milestone_Agreements_Received_Date__c       = date.newInstance(2009,01,01);
        newDeal.Milestone_AML_OFAC_Cleared_Date__c          = date.newInstance(2009,01,01);
        newDeal.Milestone_DealTeamConflictCheckCleared__c   = date.newInstance(2009,01,01);
        newDeal.Milestone_Expense_Code_Date__c              = date.newInstance(2009,01,01);
        newDeal.Milestone_FINCEN_Cleared_Date__c            = date.newInstance(2009,01,01);
        newDeal.Milestone_KYC_Cleared_Date__c               = date.newInstance(2009,01,01);
        newDeal.Milestone_NBRC_Approved_Date__c             = date.newInstance(2009,01,01);
        newDeal.Milestone_NBRC_Committee_Date__c            = date.newInstance(2009,01,01);
        newDeal.Milestone_Staffing_Date__c                  = date.newInstance(2009,01,01);
        insert newDeal;
  */      
        Test.stopTest();

    }
}