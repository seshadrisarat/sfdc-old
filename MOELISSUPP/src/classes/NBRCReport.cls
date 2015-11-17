/**
* Test methods are in Test_Reports.cls
**/
public with sharing class NBRCReport 
{
    public String dealId { get; set; }
    public String DealName { get; set; }
    public Integer DescC_height { get; set; }
    public Integer DescT_height { get; set; }
    public Integer DescPFS_height { get; set; }
    public Integer DescRH_CL_height { get; set; }
    public Integer DescRS_height { get; set; }
    public Integer DescLO_height { get; set; }
    public Integer DescPA_height { get; set; }
    public Ibanking_Project__c dealObj { get; set; }
    public string strUrlCheckedImage {set;get;}// = SL_Checked_Image__c.getOrgDefaults().Checked_Image__c;
    public string strUrlUnCheckedImage{set;get;}
    public String renderMode { get; set; }
    public NBRCReport()
    {
        this.dealId = ApexPages.currentPage().getParameters().get('did');
        this.renderMode = ApexPages.currentPage().getParameters().get('render');
        for(SL_Checked_Image__c image   : [Select s.Name, s.Checked_Image__c From SL_Checked_Image__c s])
        {
            if(image.Name == 'Checked Image')
            {
                strUrlCheckedImage = image.Checked_Image__c;
            }
            else if(image.Name == 'Unchecked Image')
            {
                strUrlUnCheckedImage = image.Checked_Image__c;
            }
        }
        if (this.dealId != null && this.dealId != '') 
        {
            for (Ibanking_Project__c temp :  
                        [SELECT CurrencyIsoCode,
                                id,Name,                    RecordType.Name, RecordTypeId,
                                Target_Public_Private__c,   Target_Ticker_Symbol__c,
                                Acquiror_Public_Private__c, Acquiror_Ticker_Symbol__c,
                                Expense_Code__c,            Industry__c,
                                Client__c,Client__r.Name,   Sector__c,
                                Client_Alias__c,            Regions__c,
                                Target__c,
                                Acquiror__c,
                                Description__c,
                                
                                Client_Revenues__c,         Target_Revenues__c,
                                Client_EBITDA__c,           Target_EBITDA__c,
                                Client_Enterprise_Value__c, Target_Ent_Value_Deal_Amount__c,
                                Cash_mm__c,                 Target_Cash_mm__c,
                                Client_Total_Debt_mm__c,    Target_Total_Debt_mm__c,  
                                
                                Business_Type__c,           Stage__c,
                                Product_Type__c,            Status__c,
                                Transaction_Type__c,        Reason__c, 
                                Transaction_Sub_Type__c,    Milestone_DealTeamConflictCheckCleared__c,
                                Transaction_Feature__c,     Engagement_Date__c,
                                Fairness_Opinion__c,        Transaction_Announcement_Date__c,
                                Est_Transaction_Size__c,    Transaction_Completion_Date__c,
                                Estimated_Fee_Revenue__c,   Expected_Close_Date__c,
                                Total_Invoice_Fees_mm__c,  Revenue_Probability__c,
                                Probability_Adjusted_Revenue__c,Include_in_Pipeline__c,
                                Full_Description_of_Transaction__c, Pitch_Date__c,
                                Proposed_Fee_Structure__c,
                                Mgmt_Team_Displacement_1__c,
                                Mgmt_Team_Displacement_2__c,
                                CMC_Committee_Date__c,
                                
                                Moelis_Roles__c,                Co_Advisors__c,
                                Relationship_History__c,    Competitive_Landscape__c,
                                                            Referral_Source__c,
                                                                
                                Ticker__c,                  TaxID__c,
                                Principal_Address_no_POB__c,website__c,
                                Phone__c,                   Email__c,
                                Fax__c,                     Amount_of_Assets__c,
                                List_of_Owners__c,          Source_of_Funds__c,
                                
                                PublicPrivate__c,           Google_Internet_Check_Date__c,
                                Restrict__c,                Google_Internet_Check_Results__c,
                                
                                Milestone_Expense_Code_Date__c,Expense_Code_Done_By__c,
                                Expense_Code_Status__c,     Expense_Code_Comments__c,
                                Milestone_Agreements_Received_Date__c,Agreement_Received_Done_By__c,
                                Business_Conflict_Checked_Status__c,Business_Conflict_Checked_Comments__c,
                                NBRC_CMC_Request_Date__c,   NBRC_Committee_Done_By__c,
                                Milestone_NBRC_Committee_Date__c,NBRC_CMC_Committee_Comments__c,
                                Milestone_NBRC_Approved_Date__c,NBRC_Approval_Done_By__c,
                                NBRC_CMC_Approval_Status__c,NBRC_CMC_Approval_Comments__c,
                                Milestone_KYC_Cleared_Date__c,KYC_Cleared_Done_By__c,
                                NBRC_CMC_Committee__c,      KYC_Checked_Comments__c, 
                                Milestone_AML_OFAC_Cleared_Date__c,AML_OFAC_Cleared_Done_By__c,
                                AML_OFAC_Checked_Status__c, AML_OFAC_Checked_Comments__c, 
                                Milestone_FINCEN_Cleared_Date__c,FINCEN_Cleared_Done_By__c,
                                FINCEN_Checked_Status__c,   FINCEN_Checked_Comments__c,
                                Legal_Approved_Date__c,     Legal_Done_By__c,
                                Supervisory_Approval_Status__c,Supervisory_Approval_Comments__c,
                                Does_the_client_have_50mm_of_assets__c,
                                Full_Legal_Name_of_Client__c, Country_of_Incorporation__c,
                                Category_of_Client__c, Ticker_Symbol__c,AML_Risk_Level__c,
                                OwnerId,Owner.Name,     LastModifiedById,LastModifiedBy.Name,
                                Primary_Exchange__c, Name_of_Regulator__c, CMC_Committee_Comments__c, NDA_CA_Received__c,
                                NDA_CA_Approval_Date__c, Fairness_Opinion_Status__c, Fairness_Opinion_Date__c, 
                                Fairness_Opinion_Comments__c, Fairness_Opinion_Approved_By__c, 
                                Requesting_conflict_clearance__c, Conflict_Clearance_Request_Date__c,
                                Name_of_parties_related_to_client__c, Receiving_confidential_info_on_client__c,
                                Receiving_confidential_info_on_others__c,
                                Name_of_counterparties__c, NDA_CA_Approval_Done_By__c,Signing_an_NDA_CA__c,
                                Parties_related_to_counterparties__c, Other_relevant_info_for_conflict_check__c,
                                List_all_bankers_aware_of_transaction__c
                            FROM Ibanking_Project__c 
                            WHERE id=:this.dealId LIMIT 1])
            { 

                this.DescC_height = this.DescT_height = this.DescPFS_height = this.DescRH_CL_height = this.DescRS_height = this.DescLO_height = this.DescPA_height = 16;
                // for avoidance truncation in excel
                if(renderMode!='pdf')
                {
                    Integer rowHeight = 13;
                    Integer symbolsInRow = 160;
                    Integer symbolsInRow2 = 45;
                    //Company description, full description of transaction, proposed fee structure
                    if(temp.Description__c != null && temp.Description__c.length() > symbolsInRow)
                        this.DescC_height = (temp.Description__c.length() / symbolsInRow) * rowHeight;
                    if(temp.Full_Description_of_Transaction__c != null && temp.Full_Description_of_Transaction__c.length() > symbolsInRow)
                        this.DescT_height = (temp.Full_Description_of_Transaction__c.length() / symbolsInRow) * rowHeight;
                    if(temp.Proposed_Fee_Structure__c != null && temp.Proposed_Fee_Structure__c.length() > symbolsInRow)
                        this.DescPFS_height = (temp.Proposed_Fee_Structure__c.length() / symbolsInRow) * rowHeight;
                    
                    //referral source, list of owners, principal address
                    if(temp.Referral_Source__c != null && temp.Referral_Source__c.length() > symbolsInRow2)
                        this.DescRS_height = (temp.Referral_Source__c.length() / symbolsInRow2) * rowHeight;
                    if(temp.List_of_Owners__c != null && temp.List_of_Owners__c.length() > symbolsInRow2)
                        this.DescLO_height = (temp.List_of_Owners__c.length() / symbolsInRow2) * rowHeight;
                    if(temp.Principal_Address_no_POB__c != null && temp.Principal_Address_no_POB__c.length() > symbolsInRow2)
                        this.DescPA_height = (temp.Principal_Address_no_POB__c.length() / symbolsInRow2) * rowHeight;
                    
                    //Relationship_History__c,  Competitive_Landscape__c,
                    Integer tmpRH_height = 16;
                    Integer tmpCL_height = 16;
                    if(temp.Relationship_History__c != null && temp.Relationship_History__c.length() > symbolsInRow2)
                        tmpRH_height = (temp.Relationship_History__c.length() / symbolsInRow2) * rowHeight;
                    if(temp.Competitive_Landscape__c != null && temp.Competitive_Landscape__c.length() > symbolsInRow2)
                        tmpCL_height = (temp.Competitive_Landscape__c.length() / symbolsInRow2) * rowHeight;
                    if(tmpRH_height > tmpCL_height) this.DescRH_CL_height = tmpRH_height;
                    else  this.DescRH_CL_height = tmpCL_height;
                }
                this.dealObj = temp;
                
            }
            this.DealName = this.dealObj.Name;
        }
    }
    
    public List<Project_Resource__c> getDealTeamMembers()
    {
        List<Project_Resource__c> DealTeamMembers_List = [
            Select Title__c, Role__c,Banker__r.Title__c,  Name, Banker__r.Office_Location__c,Banker__r.Name, Banker__c
            From Project_Resource__c 
            WHERE Project__c=:this.dealId AND Status__c=: 'Active'
            ORDER BY Sort_Order__c limit 1000];//MOELIS-16: Sorting issue (i.e. picklist order for text columns) - DO NOT SORT. Only perform first level sorting for these (i.e. like the related lists)
            //ORDER BY Role__c,Banker__r.Title__c limit 1000];
        
        return DealTeamMembers_List;
    }
    
    public List<Deal_Related_Parties__c> getDealRelatedParties()
    {
        List<Deal_Related_Parties__c> DealRelatedParties_List = [
            Select Role__c, Party__c, Notes__c, Company__r.Name,Moelis_Client__c
            From Deal_Related_Parties__c
            WHERE Deal__c=:this.dealId 
            ORDER BY Role__c,Party__c limit 1000];
        
        return DealRelatedParties_List;
    }
        
    public List<Project_Client_Contact__c> getDealContacts()
    {
        List<Project_Client_Contact__c> DealContacts_List = [
            Select Name, Client_Contact__r.Title, Client_Contact__r.Account.Name,Client_Contact__r.Name, Client_Contact__c 
            From Project_Client_Contact__c
            WHERE Moelis_Project__c=:this.dealId 
            ORDER BY Client_Contact__r.Account.Name,Client_Contact__r.LastName limit 1000];
        
        return DealContacts_List;
    }
    
    public List<Potential_Buyer_Investor__c> getPotentialBuyersInvestors()
    {
        List<Potential_Buyer_Investor__c> PotentialBuyersInvestors_List = new List<Potential_Buyer_Investor__c>();
        for (Potential_Buyer_Investor__c temp : [ 
            Select Sub_Sector__c,Name,Project__r.Name,Project__c, Industry__c, Current_Stage__c 
            From Potential_Buyer_Investor__c
            WHERE Project__c=:this.dealId 
            ORDER BY Name limit 1000])
        {
            if(temp.Name != null && temp.Project__r.Name != null && temp.Name.length() > 2) temp.Name = temp.Name.substring(temp.Project__r.Name.length() + 2);
            PotentialBuyersInvestors_List.add(temp);
        }
        return PotentialBuyersInvestors_List;
    }
    
    public String getChooserender()
    {
        if(renderMode=='pdf') return 'pdf';
        //else if(renderMode=='excel')return 'excel';
        else return null;
    }
    
    public String getChooserender2()
    {
        if(renderMode=='pdf') return 'application/x-download#'+DealName.replaceAll(' ','')+'NBRCReport.pdf';
        else if(renderMode=='excel') return 'application/vnd.ms-excel#'+DealName.replaceAll(' ','')+'NBRCReport.xls';
        else return null;
    }
}