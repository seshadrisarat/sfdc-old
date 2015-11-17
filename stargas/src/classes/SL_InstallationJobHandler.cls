/**  
* \arg ClassName      : SL_InstallationJobHandler
* \arg JIRATicket     : STARGAS-45
* \arg CreatedOn      : 5/NOV/2015
* \arg LastModifiedOn : 10/11/2015
* \arg CreatededBy    : Sanath
* \arg ModifiedBy     : Prakash
* \arg Description    : -
*/
public with sharing class SL_InstallationJobHandler 
{
    public SL_InstallationJobHandler()
    {
        //Do Nothing
    }
    
    public static void onBeforeUpdateInsert(List<Installation_Job__c> lstInstallationJob)
    {
        Set<Id> setInstalJobIds = new Set<Id>();
        List<Installation_Adjustments__c> lstInsJob = new List<Installation_Adjustments__c>();

        if(Trigger.isUpdate){
            for(Installation_Job__c objInstallationJob : lstInstallationJob)
            {
                setInstalJobIds.add(objInstallationJob.Id); 
            }   
            if(!setInstalJobIds.isEmpty())
                lstInsJob = [Select Id From Installation_Adjustments__c Where Installation_Job__c IN : setInstalJobIds AND Apply__c = true limit 1];
        }
        for(Installation_Job__c objInstallationJob : lstInstallationJob)
        {
            if(Trigger.isUpdate){
                objInstallationJob.Price_diff__c = objInstallationJob.Adj_Sale_Price__c!=NULL ? objInstallationJob.Adj_Sale_Price__c - (objInstallationJob.Price__c!=NULL ? objInstallationJob.Price__c : 0) : NULL;
                objInstallationJob.MajMatdiff__c = objInstallationJob.Adj_Major_Materials__c!=NULL ? objInstallationJob.Adj_Major_Materials__c - (objInstallationJob.Maj_Mat__c!=NULL ? objInstallationJob.Maj_Mat__c : 0) : NULL;
                objInstallationJob.MiscMat_diff__c = objInstallationJob.Adj_Misc_Material__c!=NULL ? objInstallationJob.Adj_Misc_Material__c - (objInstallationJob.Misc_Mat__c!=NULL ? objInstallationJob.Misc_Mat__c : 0) : NULL;
                objInstallationJob.Tax_diff__c = objInstallationJob.Adj_Sales_Tax__c!=NULL ? objInstallationJob.Adj_Sales_Tax__c - (objInstallationJob.Tax__c!=NULL ? objInstallationJob.Tax__c :0) : NULL;
                objInstallationJob.SubExp_diff__c = objInstallationJob.Adj_Sub_Contract_Expense__c!=NULL ? objInstallationJob.Adj_Sub_Contract_Expense__c - (objInstallationJob.Sub_Exp__c!=NULL ? objInstallationJob.Sub_Exp__c : 0) : NULL;
                objInstallationJob.FilingFeesdiff__c = objInstallationJob.Adj_Filing_Fees__c!=NULL ? objInstallationJob.Adj_Filing_Fees__c - (objInstallationJob.Filing_Fees__c!=NULL ? objInstallationJob.Filing_Fees__c : 0) : NULL;
                objInstallationJob.Mfr_Rebates_diff__c = objInstallationJob.Adj_Manf_Rebate_Allowance__c!=NULL ? objInstallationJob.Adj_Manf_Rebate_Allowance__c - (objInstallationJob.Mfr_Rebates__c!=NULL ? objInstallationJob.Mfr_Rebates__c : 0) : NULL;
                objInstallationJob.CAREdiff__c = objInstallationJob.Adj_CARE_Tank_Charge__c!=NULL ? objInstallationJob.Adj_CARE_Tank_Charge__c - (objInstallationJob.CARE__c!=NULL ? objInstallationJob.CARE__c : 0) : NULL;
                //objInstallationJob.Sales_Comm_diff__c = objInstallationJob.Adj_Sales_Comm__c!=NULL && objInstallationJob.Sales_Comm_amt__c!=NULL? objInstallationJob.Adj_Sales_Comm__c - objInstallationJob.Sales_Comm_amt__c : NULL;
                objInstallationJob.Manual_Comm_diff__c = objInstallationJob.Adj_Manual_Comm_amt__c!=NULL ? objInstallationJob.Adj_Manual_Comm_amt__c - (objInstallationJob.Manual_Comm_Amt__c!=NULL ? objInstallationJob.Manual_Comm_Amt__c : 0) : NULL;
                objInstallationJob.FinFeediff__c = objInstallationJob.FinFeeadj__c!=NULL ? objInstallationJob.FinFeeadj__c - (objInstallationJob.FinFee__c!=NULL ? objInstallationJob.FinFee__c : 0) : NULL;
                objInstallationJob.Techamt_diff__c = objInstallationJob.TechAmt_adj__c!=NULL ? objInstallationJob.TechAmt_adj__c - (objInstallationJob.TechAmt__c!=NULL ? objInstallationJob.TechAmt__c : 0) : NULL;
                objInstallationJob.TechHours_diff__c = objInstallationJob.TechHoursAdj__c!=NULL ? objInstallationJob.TechHoursAdj__c - (objInstallationJob.TechHours__c!=NULL ? objInstallationJob.TechHours__c : 0) : NULL;
            }
            objInstallationJob.Gross_P_L_B4_Sales_Comm__c = ((objInstallationJob.Price__c != null ? objInstallationJob.Price__c : 0) - 
                                            (objInstallationJob.Maj_Mat__c != null ? objInstallationJob.Maj_Mat__c : 0) - 
                                            (objInstallationJob.Misc_Mat__c != null ? objInstallationJob.Misc_Mat__c : 0) - 
                                            (objInstallationJob.Tax__c != null ? objInstallationJob.Tax__c : 0) - 
                                            (objInstallationJob.Sub_Exp__c != null ? objInstallationJob.Sub_Exp__c : 0) - 
                                            (objInstallationJob.Filing_Fees__c != null ? objInstallationJob.Filing_Fees__c : 0) - 
                                            (objInstallationJob.Mfr_Rebates__c != null ? objInstallationJob.Mfr_Rebates__c: 0) - 
                                            (objInstallationJob.CARE__c != null ? objInstallationJob.CARE__c : 0) - 
                                            (objInstallationJob.TechAmt__c != null ? objInstallationJob.TechAmt__c : 0));
            // The Installation_Job_C.Gross P/L B4 Sales Comm-adj field should not be calculated unless there is at least one Adjustment Record where Apply = True OR the Installation_Jobc.Adjust_c = True
            objInstallationJob.Gross_P_L_B4_Sales_Comm_adj__c = 0;
            if(objInstallationJob.Adjusted__c == true || lstInsJob.size() > 0){
                objInstallationJob.Gross_P_L_B4_Sales_Comm_adj__c = ((objInstallationJob.Sale_Price_final__c != null ? objInstallationJob.Sale_Price_final__c : 0) - 
                                            (objInstallationJob.Major_Materials_final__c != null ? objInstallationJob.Major_Materials_final__c : 0) - 
                                            (objInstallationJob.Misc_Materials_final__c != null ? objInstallationJob.Misc_Materials_final__c : 0) - 
                                            (objInstallationJob.Sales_Tax_final__c != null ? objInstallationJob.Sales_Tax_final__c : 0) - 
                                            (objInstallationJob.Sub_Contract_Expense_final__c != null ? objInstallationJob.Sub_Contract_Expense_final__c : 0) - 
                                            (objInstallationJob.Filing_Fees_final__c != null ? objInstallationJob.Filing_Fees_final__c : 0) - 
                                            (objInstallationJob.Manf_Rebates_Allowance_final__c != null ? objInstallationJob.Manf_Rebates_Allowance_final__c: 0) - 
                                            (objInstallationJob.CARE_Tank_Charge_final__c != null ? objInstallationJob.CARE_Tank_Charge_final__c : 0) - 
                                            (objInstallationJob.TechAmt_final__c != null ? objInstallationJob.TechAmt_final__c : 0));
            }
            if(objInstallationJob.Adjusted__c == true)
                objInstallationJob.Sales_Comm_diff__c = objInstallationJob.Sales_Comm_adj__c - objInstallationJob.Sales_Comm_amt__c;
            else
            	objInstallationJob.Sales_Comm_diff__c = 0;
        }
    }
}