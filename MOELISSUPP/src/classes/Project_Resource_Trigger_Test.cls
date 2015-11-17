/*

Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 08/04/2010 - Task #10249
*/
public class Project_Resource_Trigger_Test {

    public static List<Employee_Profile__c> lstEmployeeProfile {get;set;}
    public static Ibanking_Project__c testDeal {get;set;}
        
   static testMethod void testVariables() {
      SL_ProjectResource_Trigger_Handler handler = new SL_ProjectResource_Trigger_Handler(true, 10);
      Test.startTest();
      Boolean IsWebServiceContext = handler.IsWebServiceContext;
      Boolean IsTriggerContext = handler.IsTriggerContext;
        Boolean IsVisualforcePageContext = handler.IsVisualforcePageContext;
        Boolean IsExecuteAnonymousContext = handler.IsExecuteAnonymousContext;
      
       
      System.assert(!IsWebServiceContext);
      System.assert(IsTriggerContext);
      System.assert(!IsVisualforcePageContext);
      System.assert(!IsExecuteAnonymousContext);
      
      Test.stopTest();
    }
    public static void createdata() 
    {
      Account testAccount1 = new Account(Name='testAccount2');
        insert testAccount1;
        
        Contact testContact = new Contact(AccountId=testAccount1.Id,FirstName='testFirstName', LastName='testLastName');
        insert testContact;

        
        //Ibanking_Project__c testDeal = new Ibanking_Project__c(Client__c=testAccount1.Id);
        //insert testDeal;

        Profile newProfile = [select Id from Profile limit 1];

        User newUser = new User(Username='test111hgh@silverlinecrm.com',LastName='testsilverline111dfh',Email='testsilver1114334@silverlinecrm.com',Alias='testlkjl',CommunityNickname='EugenKr111eedw',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id);
        insert newUser;

        User newUser2 = new User(Username='test423423@yandex.ru',LastName='testName2',Email='test43243@yandex.ru',Alias='EuKr2',CommunityNickname='EugenKr2',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id);
        insert newUser2;

        lstEmployeeProfile = new List<Employee_Profile__c>{
                              new Employee_Profile__c(First_Name__c='testFirstName', Last_Name__c='testLastName',Title__c = 'Managing Director',User_Id__c=newUser.Id),
                              new Employee_Profile__c(First_Name__c='testFirstName2', Last_Name__c='testLastName2',Title__c = 'Managing Director',User_Id__c=newUser2.Id)
                                  };
        insert lstEmployeeProfile;
        
        ID iDealRT = null;
        
        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' and Name like 'Capital%' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        //Ibanking_Project__c testDeal = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        testDeal = new Ibanking_Project__c(Requesting_conflict_clearance__c = 'No', RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        testDeal.Client__c = testAccount1.ID;
        
        insert testDeal; 
        
        //testDeal.Staffer__c = lstEmployeeProfile[0].ID;
        testDeal.Co_Advisors__c = 'Test textttt';
        testDeal.Competitive_Landscape__c = 'Test textttt';
        testDeal.Stage__c = 'TTTEST!';

    
        update testDeal;
        
        List<Potential_Buyer_Investor__c> lstPBI = new List<Potential_Buyer_Investor__c>{
                                                  new Potential_Buyer_Investor__c(Project__c = testDeal.Id, Name = 'Test PBI', TargetBuyer__c = testAccount1.Id),
                                                  new Potential_Buyer_Investor__c(Project__c = testDeal.Id, Name = 'Test PBI1', TargetBuyer__c = testAccount1.Id)
                                                };
        insert lstPBI;
    }
    
    static testMethod void myUnitTest() {
        createdata();
        Project_Resource__c testPR = new Project_Resource__c(Banker__c=lstEmployeeProfile[0].Id, Status__c='Active',Project__c=testDeal.Id);
        Test.startTest();
        
        insert testPR;
        Test.stopTest();
    } 
        static testMethod void myUnitTest2() {
        createdata();
        Project_Resource__c testPR = new Project_Resource__c(Banker__c=lstEmployeeProfile[0].Id, Status__c='Active',Project__c=testDeal.Id);
        insert testPR;
        Test.startTest();
        testPR.Banker__c = lstEmployeeProfile[1].Id;
        update testPR;
        Test.stopTest();
    }
        static testMethod void myUnitTest3() {
        createdata();
        
        List<Project_Resource__c> lstProjectResource = new List<Project_Resource__c>{
                                                new Project_Resource__c(Banker__c=lstEmployeeProfile[0].Id, Status__c='Active',Project__c=testDeal.Id),
                                                new Project_Resource__c(Banker__c=lstEmployeeProfile[1].Id, Status__c='Active',Project__c=testDeal.Id)
                                              };
        insert lstProjectResource;
        
        Test.startTest();
        delete lstProjectResource[0];
        Test.stopTest();
    }
}