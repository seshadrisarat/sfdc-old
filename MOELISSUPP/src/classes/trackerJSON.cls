/*
Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 08/04/2010 - Task #10249
modified: Vika 05/12/2010 - Task #10350
*/
public class trackerJSON 
{
    public list<Potential_Buyer_Investor__c> buyersList {get; set;}
    public List<picklistItem> CA_Status_values {get; set;}
    public List<picklistItem> Status_values {get; set;}
    public List<picklistItem> Type_values {get; set;}
    public String CurAccountPrefix {get; set;}
    public Integer CIM_NumberLength {get; set;}
    public fieldLength FLength {get; set;} 
    
    public class picklistItem 
    {
        public string value {get; set;}
        public string label {get; set;}
        
        public picklistItem (string val, string lbl)
        {
            value = val;
            label = lbl;            
        }
    }
    
    public class fieldLength 
    {
        public Integer X1st_Round_Bid_HighLength {get; set;}
        public Integer X1st_Round_Bid_HighScale {get; set;}
        public Integer X1st_Round_Bid_LowLength {get; set;}
        public Integer X1st_Round_Bid_LowScale {get; set;}
        public Integer X2nd_Round_Bid_HighLength {get; set;}
        public Integer X2nd_Round_Bid_HighScale {get; set;}
        public Integer X2nd_Round_Bid_LowLength {get; set;}
        public Integer X2nd_Round_Bid_LowScale {get; set;}
        public Integer X3rd_Round_Bid_HighLength {get; set;}
        public Integer X3rd_Round_Bid_HighScale {get; set;}
        public Integer X3rd_Round_Bid_LowLength {get; set;}
        public Integer X3rd_Round_Bid_LowScale {get; set;}
        
        public fieldLength(){}
    }
    public trackerJSON()
    {
        buyersList = new list<Potential_Buyer_Investor__c>();
        
        if(System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!='')
        {
            String curPidID = System.currentPageReference().getParameters().get('pid');
            
            for (Potential_Buyer_Investor__c temp :  [
         Select t.TargetBuyer__r.Name,
                    t.TargetBuyer__c,
                    t.Project__r.Id, 
                    t.Project__c, 
                    t.Name, t.Declined__c,
           t.X3rd_Round_Bid_Received__c,        t.X3rd_Round_Bid_Low_mm__c,    t.X3rd_Round_Bid_High_mm__c,  t.X2nd_Round_Bid_Received__c,
                     t.X2nd_Round_Bid_Process_Letter_Sent__c,  t.X2nd_Round_Bid_Low_mm__c,   t.X2nd_Round_Bid_High_mm__c,  t.X1st_Round_Bid_Received__c,
                     t.X1st_Round_Bid_Low_mm__c,        t.X1st_Round_Bid_High_mm__c,  t.Type__c, t.Teaser_Sent__c,  t.Status__c,
                     t.Mgmt_Presentation__c,          t.Data_Room_Access__c,      t.Initial_Contact_Made__c,    t.CIM_Info_Package_Sent__c,
                     t.CIM_Number__c,              t.CIM_Info_Package_Returned__c,  t.CA_Under_Negotiation__c,    t.CA_Signed__c,
                     t.CA_Sent__c,                t.X1st_Round_Bid_Process_Letter_Sent__c,            t.X3rd_Round_Bid_Process_Letter_Sent__c
                From Potential_Buyer_Investor__c t     
                where t.Project__r.Id =: curPidID
                ORDER BY t.TargetBuyer__r.Name
                limit 200])
              {
                if (temp.CIM_Number__c !=null)
                {

                  //temp.CIM_Number__c = temp.CIM_Number__c.replaceAll('\r\n','#r#n');
                  temp.CIM_Number__c = temp.CIM_Number__c.replaceAll('"','\'');
                }
                buyersList.add(temp);
              }

        }
        
      this.CIM_NumberLength = Potential_Buyer_Investor__c.CIM_Number__c.getDescribe().getLength();
      FLength = new trackerJSON.fieldLength();
      
      FLength.X1st_Round_Bid_HighLength = Potential_Buyer_Investor__c.X1st_Round_Bid_High_mm__c.getDescribe().getPrecision() - Potential_Buyer_Investor__c.X1st_Round_Bid_High_mm__c.getDescribe().getScale(); 
      FLength.X1st_Round_Bid_HighScale = Potential_Buyer_Investor__c.X1st_Round_Bid_High_mm__c.getDescribe().getScale();  
      FLength.X1st_Round_Bid_LowLength = Potential_Buyer_Investor__c.X1st_Round_Bid_Low_mm__c.getDescribe().getPrecision() - Potential_Buyer_Investor__c.X1st_Round_Bid_Low_mm__c.getDescribe().getScale(); 
      FLength.X1st_Round_Bid_LowScale = Potential_Buyer_Investor__c.X1st_Round_Bid_Low_mm__c.getDescribe().getScale(); 
     
      FLength.X2nd_Round_Bid_HighLength = Potential_Buyer_Investor__c.X2nd_Round_Bid_High_mm__c.getDescribe().getPrecision() - Potential_Buyer_Investor__c.X2nd_Round_Bid_High_mm__c.getDescribe().getScale(); 
      FLength.X2nd_Round_Bid_HighScale = Potential_Buyer_Investor__c.X2nd_Round_Bid_High_mm__c.getDescribe().getScale();  
      FLength.X2nd_Round_Bid_LowLength = Potential_Buyer_Investor__c.X2nd_Round_Bid_Low_mm__c.getDescribe().getPrecision() - Potential_Buyer_Investor__c.X2nd_Round_Bid_Low_mm__c.getDescribe().getScale(); 
      FLength.X2nd_Round_Bid_LowScale = Potential_Buyer_Investor__c.X2nd_Round_Bid_Low_mm__c.getDescribe().getScale(); 
      
      FLength.X3rd_Round_Bid_HighLength = Potential_Buyer_Investor__c.X3rd_Round_Bid_High_mm__c.getDescribe().getPrecision() - Potential_Buyer_Investor__c.X3rd_Round_Bid_High_mm__c.getDescribe().getScale(); 
      FLength.X3rd_Round_Bid_HighScale = Potential_Buyer_Investor__c.X3rd_Round_Bid_High_mm__c.getDescribe().getScale();  
      FLength.X3rd_Round_Bid_LowLength = Potential_Buyer_Investor__c.X3rd_Round_Bid_Low_mm__c.getDescribe().getPrecision() - Potential_Buyer_Investor__c.X3rd_Round_Bid_Low_mm__c.getDescribe().getScale(); 
      FLength.X3rd_Round_Bid_LowScale = Potential_Buyer_Investor__c.X3rd_Round_Bid_Low_mm__c.getDescribe().getScale(); 
      
      
        Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
    this.CurAccountPrefix = R.getKeyPrefix();

        Schema.DescribeFieldResult fieldResult;
        List<Schema.PicklistEntry> PickilstValues;
        /*
        fieldResult = Potential_Buyer_Investor__c.CA_Status__c.getDescribe();
        PickilstValues = fieldResult.getPicklistValues();
        CA_Status_values = new List<picklistItem>();
        CA_Status_values.add(new picklistItem('',''));
        for (Schema.PicklistEntry pVal : PickilstValues)
        {
            CA_Status_values.add(new picklistItem(pVal.value,pVal.label));
        }
        */
        fieldResult = Potential_Buyer_Investor__c.Status__c.getDescribe();
        PickilstValues = fieldResult.getPicklistValues();
        Status_values = new List<picklistItem>();
        Status_values.add(new picklistItem('',''));
        for (Schema.PicklistEntry pVal : PickilstValues)
        {
            Status_values.add(new picklistItem(pVal.value,pVal.label));
        }
        fieldResult = Potential_Buyer_Investor__c.Status__c.getDescribe();
        PickilstValues = fieldResult.getPicklistValues();
        Status_values = new List<picklistItem>();
        Status_values.add(new picklistItem('',''));
        for (Schema.PicklistEntry pVal : PickilstValues)
        {
            Status_values.add(new picklistItem(pVal.value,pVal.label));
        }
        
        fieldResult = Potential_Buyer_Investor__c.Type__c.getDescribe();
        PickilstValues = fieldResult.getPicklistValues();
        Type_values = new List<picklistItem>();
        Type_values.add(new picklistItem('',''));
        for (Schema.PicklistEntry pVal : PickilstValues)
        {
            Type_values.add(new picklistItem(pVal.value,pVal.label));
        }
    }
    
    public static testMethod void trackerJSON_Test()
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
        
        Account accObj1 = new Account(Name='Company1',RecordTypeId=iCompanyRT,Type='Other',Industry='Other',Public_Private__c='Public',Client_Code__c='00001',EBITDA__c=2.0,Enterprise_Value__c=3.0,TickerSymbol='CSCO',Total_Revenue__c=10.0,Website='www.mail.ru');
        insert accObj1;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;

        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory'/*,Description__c='test1'*/,Est_Transaction_Size__c=100.0/*,Full_Description_of_Transaction__c='test2'*/);
        //Ibanking_Project__c IbankProjObj = [Select i.website__c, i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Co_Advisors__c = 'Test textttt';
        insert IbankProjObj;
        //IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        IbankProjObj.Stage__c = 'TTTEST!';
        
        
        update IbankProjObj;
        /*
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Sellside', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='FIG', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Client__c = accObj1.ID;
        IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        */
        
        Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other', Status__c='Active', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);
        insert ProgResObj;


        IbankProjObj.Name = 'Test Name-2';
        update IbankProjObj;
        
        Potential_Buyer_Investor__c targetBuyerObj = new Potential_Buyer_Investor__c(
            Type__c='Financial', 
            TargetBuyer__c=accObj1.ID, 
            Project__c=IbankProjObj.ID, 
            Name='test1'
        );
        insert targetBuyerObj;
        
        Potential_Buyer_Investor__c targetBuyerObj2 = new Potential_Buyer_Investor__c(Type__c='Financial', TargetBuyer__c=accObj1.ID, Project__c=IbankProjObj.ID, Name='test2');
        insert targetBuyerObj2;
        
        delete targetBuyerObj;

        Test.startTest();

        System.currentPageReference().getParameters().put('pid',IbankProjObj.ID);
        trackerJSON TrackerJSONClass = new trackerJSON();
        //TrackerJSONClass.
        
        Test.stopTest();
    }
    
}