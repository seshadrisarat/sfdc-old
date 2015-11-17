/**  
* \arg ClassName      : SL_InstallationAdjustmentHandler
* \arg JIRATicket     : STARGAS-45
* \arg CreatedOn      : 24/JULY/2015
* \arg LastModifiedOn : 28/OCT/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Sanath
* \arg Description    : This class serves as handler class for SL_InstallationAdjustment trigger and is used to update the Installation_Job__c record with the related most recent Installation_Adjustments__c child record on insertion, updation and deletion of Installation_Adjustments__c record.
*/
public without sharing class SL_InstallationAdjustmentHandler 
{
	/* Start - Constructor */
	public SL_InstallationAdjustmentHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	private class RollUpWrapper
	{
	    Decimal salesPrice;
	    Decimal majorMaterials;
	    Decimal miscMaterials;
	    Decimal salesTax;
	    Decimal subContractExpense;
	    Decimal fillingFees;
	    Decimal manfRebateAllowance;
	    Decimal careTankCharge;
	    Decimal manualCommAmt;
	    Decimal financeFee;
	    Decimal coServTechsc;
	    Decimal coServTechHoursc;
	    Date    installAdjDate;
	    String  manualComm;
	    String  salesRep;
	    String  salesRepId;
	    String  salesRepName;
	    String  serviceTech;
	    String  comments;
	    
	    RollUpWrapper(Decimal salesPrice, Decimal majorMaterials, Decimal miscMaterials, 
	                  Decimal salesTax, Decimal subContractExpense, Decimal fillingFees, 
	                  Decimal manfRebateAllowance, Decimal careTankCharge, Decimal manualCommAmt,
	                  Decimal financeFee, Decimal coServTechsc, Decimal coServTechHoursc,
	                  Date installAdjDate, String manualComm,String salesRep, String salesRepId, String salesRepName, String serviceTech, String comments)
	    {
	        this.salesPrice = salesPrice;
	        this.majorMaterials = majorMaterials;
	        this.miscMaterials = miscMaterials;
	        this.salesTax = salesTax;
	        this.subContractExpense = subContractExpense;
	        this.fillingFees = fillingFees;
	        this.manfRebateAllowance = manfRebateAllowance;
	        this.careTankCharge = careTankCharge;
	        this.manualComm = manualComm;
	        this.manualCommAmt = manualCommAmt;
	        this.financeFee = financeFee;
	        this.coServTechsc = coServTechsc;
	        this.coServTechHoursc = coServTechHoursc;
	        this.installAdjDate = installAdjDate;
	        this.salesRep = salesRep;
	        this.salesRepId = salesRepId;
	        this.salesRepName = salesRepName;
	        this.serviceTech = serviceTech;
	        this.comments = comments;
	    }
	}
	
	/*
        * MethodName        : onAfterInsert
        * param             : list of inserted installation adjustment records
        * Description       : This function will be called on after insert of Installation_Adjustments__c record and calls another method named as updateInstallationJob to update the corresponding Installation Job record.
    */
	public static void onAfterInsert(List<Installation_Adjustments__c> lstIA)
	{
		updateInstallationJob(lstIA, NULL);
	}
	
	/*
        * MethodName        : onAfterUpdate
        * param             : new and old maps of updated installation adjustments records.
        * Description       : This function will be called on after update of Installation_Adjustments__c record and calls another method named as updateInstallationJob to update the corresponding Installation Job record.
    */
	public static void onAfterUpdate(Map<Id, Installation_Adjustments__c> mapNewIdToIA, Map<Id, Installation_Adjustments__c> mapOldIdToIA)
	{
		updateInstallationJob(mapNewIdToIA.values(), mapOldIdToIA);
	}
	
	/*
        * MethodName        : onAfterDelete
        * param             : list of deleted installation adjustments records.
        * Description       : This function will be called on after delete of Installation_Adjustments__c record and calls another method named as updateInstallationJob to update the corresponding Installation Job record.
    */
	public static void onAfterDelete(List<Installation_Adjustments__c> lstIA)
	{
		updateInstallationJob(lstIA, NULL);
	}
	
	/*
        * MethodName        : updateInstallationJob
        * param             : list of Installation_Adjustments__c records which need to be processed and map of Installation_Adjustments__c records.
        * Description       : This function will be called on before insert of opportunity.
    */
	private static void updateInstallationJob(List<Installation_Adjustments__c> lstIA, Map<Id, Installation_Adjustments__c> mapIdToIA)
	{
		Set<Id> setInstallationJobId = new Set<Id>();
		Set<Id> setApplyInstalJobId = new Set<Id>();
		Map<Id, Installation_Job__c> mapIJobIdToMostRecentIAdjustments = new Map<Id, Installation_Job__c>();
		Map<Id, RollUpWrapper> mapIJobIdToRollUpWrapper = new Map<Id, RollUpWrapper>();
		Installation_Adjustments__c objOldIA;
		Installation_Job__c objInsJob;

		for(Installation_Adjustments__c objIA : lstIA)
		{
			if(Trigger.isUpdate)
				objOldIA = mapIdToIA.get(objIA.Id);
			
			if(!Trigger.isUpdate || (objOldIA.Sale_Price__c!=objIA.Sale_Price__c || objOldIA.Major_Materials__c!=objIA.Major_Materials__c 
									|| objOldIA.Misc_Materials__c!=objIA.Misc_Materials__c || objOldIA.Sales_Tax__c!=objIA.Sales_Tax__c 
									//|| objOldIA.Sales_Comm__c!=objIA.Sales_Comm__c || objOldIA.Sub_Contract_Expense__c!=objIA.Sub_Contract_Expense__c
									|| objOldIA.Filing_Fees__c!=objIA.Filing_Fees__c || objOldIA.Care_Tank_Charge__c!=objIA.Care_Tank_Charge__c
									|| objOldIA.Manf_Rebate_Allowance__c!=objIA.Manf_Rebate_Allowance__c || objOldIA.Care_Tank_Charge__c!=objIA.Care_Tank_Charge__c
									|| objOldIA.Manual_Comm__c!=objIA.Manual_Comm__c || objOldIA.Manual_Comm_amt__c!=objIA.Manual_Comm_amt__c
									|| objOldIA.Comments__c!=objIA.Comments__c
									|| objOldIA.Apply__c!=objIA.Apply__c
									|| objOldIA.Sales_Rep__c!=objIA.Sales_Rep__c
									|| objOldIA.Sales_RepID__c!=objIA.Sales_RepID__c
									|| objOldIA.Installation_Job__c!=objIA.Installation_Job__c
									|| objOldIA.Finance_Fee__c!=objIA.Finance_Fee__c
									|| objOldIA.Co_Serv_Tech_Hours__c!=objIA.Co_Serv_Tech_Hours__c
									|| objOldIA.Co_Serv_Tech_s__c!=objIA.Co_Serv_Tech_s__c
									|| objOldIA.Install_Adj_Date__c!=objIA.Install_Adj_Date__c
									|| objOldIA.Service_Tech__c!=objIA.Service_Tech__c))
			{
				setInstallationJobId.add(objIA.Installation_Job__c);
				if(objIA.Apply__c)
					setApplyInstalJobId.add(objIA.Installation_Job__c);
				if(Trigger.isUpdate && objOldIA.Installation_Job__c!=objIA.Installation_Job__c){
					setInstallationJobId.add(objOldIA.Installation_Job__c);
					if(objOldIA.Apply__c)
						setApplyInstalJobId.add(objOldIA.Installation_Job__c);
				}
			}
		}
		
		List<Installation_Adjustments__c> lstAllIA = [SELECT Installation_Job__c, Sale_Price__c, Major_Materials__c, Misc_Materials__c, Sales_Tax__c,
														//Sales_Comm__c,
														Sub_Contract_Expense__c, Filing_Fees__c, Manf_Rebate_Allowance__c, Care_Tank_Charge__c, 
														Manual_Comm__c,Manual_Comm_amt__c, Comments__c, Apply__c, Sales_Rep__c, Sales_RepID__c, Sales_Rep__r.Name,
														Finance_Fee__c, Co_Serv_Tech_s__c,
														Co_Serv_Tech_Hours__c, Install_Adj_Date__c, Service_Tech__c
												 FROM 	Installation_Adjustments__c
												 WHERE  Installation_Job__c IN : setInstallationJobId ORDER BY CreatedDate];
		
		
		
		for(Installation_Adjustments__c objIA : lstAllIA)
		{
		    if(objIA.Apply__c)
		    {
		        if(!mapIJobIdToRollUpWrapper.containskey(objIA.Installation_Job__c))
		            mapIJobIdToRollUpWrapper.put(objIA.Installation_Job__c, new RollUpWrapper(objIA.Sale_Price__c, objIA.Major_Materials__c, objIA.Misc_Materials__c, objIA.Sales_Tax__c, objIA.Sub_Contract_Expense__c, objIA.Filing_Fees__c, 
		                                                                    objIA.Manf_Rebate_Allowance__c, objIA.Care_Tank_Charge__c, objIA.Manual_Comm_amt__c,
		                                                                    objIA.Finance_Fee__c, objIA.Co_Serv_Tech_s__c,objIA.Co_Serv_Tech_Hours__c!=NULL ? Decimal.valueOf(objIA.Co_Serv_Tech_Hours__c) : NULL, objIA.Install_Adj_Date__c, 
		                                                                    objIA.Manual_Comm__c, objIA.Sales_Rep__c!=NULL ? String.valueOf(objIA.Sales_Rep__c) : NULL,
		                                                                    objIA.Sales_RepID__c, objIA.Sales_Rep__r.Name, objIA.Service_Tech__c, objIA.Comments__c));
		        else
		        {
		            RollUpWrapper objRollUpWrapper = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c);
		            if(objRollUpWrapper.salesPrice!=NULL && objIA.Sale_Price__c!=NULL)
		               objRollUpWrapper.salesPrice+= objIA.Sale_Price__c;
		            if(objRollUpWrapper.majorMaterials!=NULL && objIA.Major_Materials__c!=NULL)
		               objRollUpWrapper.majorMaterials+= objIA.Major_Materials__c;
		            if(objRollUpWrapper.miscMaterials!=NULL && objIA.Misc_Materials__c!=NULL)
		               objRollUpWrapper.miscMaterials+= objIA.Misc_Materials__c;
		            if(objRollUpWrapper.salesTax!=NULL && objIA.Sales_Tax__c!=NULL)
		               objRollUpWrapper.salesTax+= objIA.Sales_Tax__c;
		            if(objRollUpWrapper.subContractExpense!=NULL && objIA.Sub_Contract_Expense__c!=NULL)
		               objRollUpWrapper.subContractExpense+= objIA.Sub_Contract_Expense__c;
		            if(objRollUpWrapper.fillingFees!=NULL && objIA.Filing_Fees__c!=NULL)
		               objRollUpWrapper.fillingFees+= objIA.Filing_Fees__c;
		            if(objRollUpWrapper.manfRebateAllowance!=NULL && objIA.Manf_Rebate_Allowance__c!=NULL)
		               objRollUpWrapper.manfRebateAllowance+= objIA.Manf_Rebate_Allowance__c;
		            if(objRollUpWrapper.careTankCharge!=NULL && objIA.Care_Tank_Charge__c!=NULL)
		               objRollUpWrapper.careTankCharge+= objIA.Care_Tank_Charge__c;
		            if(objRollUpWrapper.manualCommAmt!=NULL && objIA.Manual_Comm_amt__c!=NULL)
		               objRollUpWrapper.manualCommAmt+= objIA.Manual_Comm_amt__c;
		            if(objRollUpWrapper.financeFee!=NULL && objIA.Finance_Fee__c!=NULL)
		               objRollUpWrapper.financeFee+= objIA.Finance_Fee__c;
		            if(objRollUpWrapper.coServTechsc!=NULL && objIA.Co_Serv_Tech_s__c!=NULL)
		               objRollUpWrapper.coServTechsc+= objIA.Co_Serv_Tech_s__c;
		            if(objRollUpWrapper.coServTechHoursc!=NULL && objIA.Co_Serv_Tech_Hours__c!=NULL)
		               objRollUpWrapper.coServTechHoursc+= Decimal.valueOf(objIA.Co_Serv_Tech_Hours__c);
		            if(objIA.Install_Adj_Date__c!=NULL)
		               objRollUpWrapper.installAdjDate = objIA.Install_Adj_Date__c;
		            if(objIA.Manual_Comm__c!=NULL)
		               objRollUpWrapper.manualComm = objIA.Manual_Comm__c;
		            if(objIA.Sales_Rep__c!=NULL)
		               objRollUpWrapper.salesRep = String.valueOf(objIA.Sales_Rep__c);
		            if(objIA.Sales_RepID__c!=NULL)
		               objRollUpWrapper.salesRepId = objIA.Sales_RepID__c;
		            if(objIA.Sales_Rep__r.Name!=NULL)
		                objRollUpWrapper.salesRepName = objIA.Sales_RepID__c;
		            if(objIA.Service_Tech__c!=NULL)
		                objRollUpWrapper.serviceTech = objIA.Service_Tech__c;
		            if(objIA.Comments__c!=NULL && objRollUpWrapper.comments!=NULL)
		                objRollUpWrapper.comments+=' '+ objIA.Comments__c;
		                
		            mapIJobIdToRollUpWrapper.put(objIA.Installation_Job__c, objRollUpWrapper);
		        }
		    }
		}
		
		
		for(Installation_Adjustments__c objIA : lstAllIA)
		{
			mapIJobIdToMostRecentIAdjustments.put(objIA.Installation_Job__c, objIA.Apply__c ?  new Installation_Job__c(Id = objIA.Installation_Job__c, 
																														Adj_Sale_Price__c = objIA.Sale_Price__c,
																														Adj_Major_Materials__c = objIA.Major_Materials__c,
																														Adj_Misc_Material__c = objIA.Misc_Materials__c,
																														Adj_Sales_Tax__c = objIA.Sales_Tax__c,
																														Adj_Sub_Contract_Expense__c = objIA.Sub_Contract_Expense__c,
																														Adj_Filing_Fees__c = objIA.Filing_Fees__c,
																														Adj_Manf_Rebate_Allowance__c = objIA.Manf_Rebate_Allowance__c,
																														Adj_CARE_Tank_Charge__c = objIA.Care_Tank_Charge__c,
																														//Adj_Sales_Comm__c = objIA.Sales_Comm__c,
																														Adj_Manual_Comm__c = objIA.Manual_Comm__c,
																														Adj_Manual_Comm_amt__c = objIA.Manual_Comm_amt__c,
																														Adj_Comments__c = objIA.Comments__c,
																														Sales_Rep_adj__c = objIA.Sales_Rep__r.Name,
																														Sales_RepID_adj__c = objIA.Sales_RepID__c,
																														FinFeeadj__c = objIA.Finance_Fee__c,
																														TechHoursAdj__c = objIA.Co_Serv_Tech_Hours__c!=NULL ? Decimal.ValueOf(objIA.Co_Serv_Tech_Hours__c) : NULL,
																														TechAmt_adj__c = objIA.Co_Serv_Tech_s__c,
																														Install_Date_adj__c = objIA.Install_Adj_Date__c,
																														Tech_adj__c = objIA.Service_Tech__c,
																														Adjusted__c = true) 
																								:																									
																								mapIJobIdToRollUpWrapper.containsKey(objIA.Installation_Job__c)
																								
																								?
																								
																								new Installation_Job__c(Id = objIA.Installation_Job__c, 
																															Adj_Sale_Price__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).salesPrice,
																															Adj_Major_Materials__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).majorMaterials,
																															Adj_Misc_Material__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).miscMaterials,
																															Adj_Sales_Tax__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).salesTax,
																															Adj_Sub_Contract_Expense__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).subContractExpense,
																															Adj_Filing_Fees__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).fillingFees,
																															Adj_Manf_Rebate_Allowance__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).manfRebateAllowance,
																															Adj_CARE_Tank_Charge__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).careTankCharge,
																															//Adj_Sales_Comm__c = NULL,
																															Adj_Manual_Comm__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).manualComm,
																															Adj_Manual_Comm_amt__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).manualCommAmt,
																															Adj_Comments__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).comments,
																															Sales_Rep_adj__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).salesRep,
																															Sales_RepID_adj__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).salesRepId,
																															FinFeeadj__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).financeFee,
																															TechHoursAdj__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).coServTechHoursc,
																															TechAmt_adj__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).coServTechsc,
																															Install_Date_adj__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).installAdjDate,
																															Tech_adj__c = mapIJobIdToRollUpWrapper.get(objIA.Installation_Job__c).serviceTech,
																															Adjusted__c = true)
																								
																								:
																									new Installation_Job__c(Id = objIA.Installation_Job__c, 
																															Adj_Sale_Price__c = NULL,
																															Adj_Major_Materials__c = NULL,
																															Adj_Misc_Material__c = NULL,
																															Adj_Sales_Tax__c = NULL,
																															Adj_Sub_Contract_Expense__c = NULL,
																															Adj_Filing_Fees__c = NULL,
																															Adj_Manf_Rebate_Allowance__c = NULL,
																															Adj_CARE_Tank_Charge__c = NULL,
																															//Adj_Sales_Comm__c = NULL,
																															Adj_Manual_Comm__c = NULL,
																															Adj_Manual_Comm_amt__c = NULL,
																															Adj_Comments__c = NULL,
																															Sales_Rep_adj__c = NULL,
																															Sales_RepID_adj__c = NULL,
																															FinFeeadj__c = NULL,
																															TechHoursAdj__c = NULL,
																															TechAmt_adj__c = NULL,
																															Install_Date_adj__c = NULL,
																															Tech_adj__c = NULL,
																															Adjusted__c = false));
		}
		
		if(Trigger.isDelete || Trigger.isUpdate)
		{
			for(Id installationJobId : setInstallationJobId)
			{
				if(!mapIJobIdToMostRecentIAdjustments.containskey(installationJobId))
					mapIJobIdToMostRecentIAdjustments.put(installationJobId, new Installation_Job__c(Id = installationJobId, 
																										Adj_Sale_Price__c = NULL,
																										Adj_Major_Materials__c = NULL,
																										Adj_Misc_Material__c = NULL,
																										Adj_Sales_Tax__c = NULL,
																										Adj_Sub_Contract_Expense__c = NULL,
																										Adj_Filing_Fees__c = NULL,
																										Adj_Manf_Rebate_Allowance__c = NULL,
																										Adj_CARE_Tank_Charge__c = NULL,
																										//Adj_Sales_Comm__c = NULL,
																										Adj_Manual_Comm__c = NULL,
																										Adj_Manual_Comm_amt__c = NULL,
																										Adj_Comments__c = NULL,
																										Sales_Rep_adj__c = NULL,
																										Sales_RepID_adj__c = NULL,
																										FinFeeadj__c = NULL,
																										TechAmt_adj__c = NULL,
																										TechHoursAdj__c = NULL,
																										Install_Date_adj__c = NULL,
																										Tech_adj__c = NULL,
																										Adjusted__c = false));
			}
		}
		
		for(Installation_Job__c objInstallationJob:[Select Id,Adjusted__c,Gross_P_L_B4_Sales_Comm_adj__c,Sale_Price_final__c,Major_Materials_final__c,
											Misc_Materials_final__c,Sales_Tax_final__c,Sub_Contract_Expense_final__c,Filing_Fees_final__c,
											Manf_Rebates_Allowance_final__c,CARE_Tank_Charge_final__c,TechAmt_final__c,FinFeefin__c 
											From Installation_Job__c Where Id IN : mapIJobIdToMostRecentIAdjustments.KeySet()]){
			objInsJob = mapIJobIdToMostRecentIAdjustments.get(objInstallationJob.Id);
			objInsJob.Gross_P_L_B4_Sales_Comm_adj__c = 0;
			// The Installation_Job_C.Gross P/L B4 Sales Comm-adj field should not be calculated unless there is at least one Adjustment Record where Apply = True OR the Installation_Jobc.Adjust_c = True
			if(setApplyInstalJobId.contains(objInstallationJob.Id) || objInstallationJob.Adjusted__c == true){
				
				objInsJob.Gross_P_L_B4_Sales_Comm_adj__c = ((objInstallationJob.Sale_Price_final__c != null ? objInstallationJob.Sale_Price_final__c : 0) - 
	                                            (objInstallationJob.Major_Materials_final__c != null ? objInstallationJob.Major_Materials_final__c : 0) - 
	                                            (objInstallationJob.Misc_Materials_final__c != null ? objInstallationJob.Misc_Materials_final__c : 0) - 
	                                            (objInstallationJob.Sales_Tax_final__c != null ? objInstallationJob.Sales_Tax_final__c : 0) - 
	                                            (objInstallationJob.Sub_Contract_Expense_final__c != null ? objInstallationJob.Sub_Contract_Expense_final__c : 0) - 
	                                            (objInstallationJob.Filing_Fees_final__c != null ? objInstallationJob.Filing_Fees_final__c : 0) - 
	                                            (objInstallationJob.Manf_Rebates_Allowance_final__c != null ? objInstallationJob.Manf_Rebates_Allowance_final__c: 0) - 
	                                            (objInstallationJob.CARE_Tank_Charge_final__c != null ? objInstallationJob.CARE_Tank_Charge_final__c : 0) - 
	                                            (objInstallationJob.TechAmt_final__c != null ? objInstallationJob.TechAmt_final__c : 0) );

			}
			mapIJobIdToMostRecentIAdjustments.put(objInstallationJob.Id, objInsJob);
		}

		update mapIJobIdToMostRecentIAdjustments.values();
	}
}