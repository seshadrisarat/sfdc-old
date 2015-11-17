/*
*  ClassName  	  : SL_PolicyDetailPage
*  JIRATicket     : PURE-13
*  CreatedOn      : 1/31/2013
*  ModifiedOn     : 5/20/2015
*  ModifiedBy     : Sandeep
*  Description    : Sandeep
*/
public without sharing class SL_PolicyDetailPage  
{
	
	public String memberName						{get;set;}
	public String memberId							{get;set;}
	public String policyType						{get;set;}
	public Policy__c sObjPolicy						{get;set;}	
	public String policyNumber						{get;set;}
	public String latestPolicyDocUrl				{get;set;}
	public Decimal collectibleBlanket				{get;set;}
	public Decimal scheduleCoverage					{get;set;} 
	
	public Decimal wineBlanket						{get;set;}
	public Decimal wineSchedule						{get;set;} 
	
	public Decimal worldWideJewelryBlanket			{get;set;}
	public Decimal JewelrySchedule					{get;set;} 
	
	public Decimal silverFursBlanket				{get;set;}
	public Decimal silverFursSchedule				{get;set;} 
	
	public Decimal bankValutedJewelryScheduled		{get;set;}
	public Decimal miscValuableScheduled			{get;set;}
	
	public List<TransactionsWrapper> lstTransactions{get;set;}
	public List<SelectOption> lstpolicies 			{get;set;}
	public String strLimit							{get;set;}
	public String strSelectedPolicy					{get;set;}

	public list<VehicleWrapper> lstVehicles					{get;set;}
	public list<listedOperatorWrapper> lstListedOperators	{get;set;}
	public list<coveredVesselsWrapper> lstCoveredvessels	{get;set;} 
	public list<coveredPropertiesWrapper> lstCoveredProperties{get;set;}
	public list<coveredPropertiesWrapper> lstExtendedProperties				{get;set;}
	public list<riskManagmentWrapper> lstRiskManagmentWrapper				{get;set;}
	public list<Covered_Employees__c> lstCoveredEmployees   {get;set;}
	public Boolean isError		{get;set;}
	public Boolean isRiskState					{get;set;}
	private set<String> setOfStates;
	//public Boolean isAgentView												{get;set;}
	
	public PageReference pageAction()
	{
		List<SL_PolicyStatusValues__c> lstSLPolicyStatusValues = new List<SL_PolicyStatusValues__c>();
		lstSLPolicyStatusValues = SL_PolicyStatusValues__c.getall().values();
		
		Set<String> setSLPolicyStatusValuesName = new Set<String>();
		
		for(SL_PolicyStatusValues__c obj : lstSLPolicyStatusValues) {
			
			setSLPolicyStatusValuesName.add(obj.Name);
		}
		
		isError = isRiskState = false;

		//If logged in user type is 'Guest' then redirect to login page.
		if(Userinfo.getUserType() == 'Guest'){
			if(!Apexpages.currentPage().getParameters().containsKey('mId')){
				return new PageReference('/LoginPage');
			} else {
				return new PageReference('/AgentLogin');
			}
		}

		String policyid = '';
		
		String userAccountId;    //This is to store logged in user account id.
		String userRecordTypeId; //To store record type id.
		sObjPolicy = new Policy__c();
		lstTransactions = new List<TransactionsWrapper>();
		lstpolicies = new list<SelectOption>();
		lstpolicies.add(new SelectOption('Select', 'Select Another Policy'));
		
		lstExtendedProperties = new list<coveredPropertiesWrapper>();
		lstRiskManagmentWrapper = new list<riskManagmentWrapper>();
		lstVehicles = new list<VehicleWrapper>();
		lstListedOperators = new list<listedOperatorWrapper>();
		lstCoveredProperties = new list<coveredPropertiesWrapper>();
		lstCoveredvessels = new list<coveredVesselsWrapper>();
		strSelectedPolicy = '';
		Boolean isPolicyExist = false;
		memberName = memberId = policyType =  policyNumber  = latestPolicyDocUrl = '';
		collectibleBlanket = scheduleCoverage = 0.00;
		wineBlanket = wineSchedule = worldWideJewelryBlanket = JewelrySchedule = silverFursBlanket = silverFursSchedule = bankValutedJewelryScheduled = miscValuableScheduled = 0.00;
		policyNumber = policyid;
		
		setOfStates = new set<String>();
		
		States_Not_Display_Id_Cards__c objCustomSetting = new States_Not_Display_Id_Cards__c();
		objCustomSetting = States_Not_Display_Id_Cards__c.getInstance('States');
			
		if(objCustomSetting != null)
		{
			String strCommaSeparatedStates = objCustomSetting.List_Of_States__c;
			for(String strState : strCommaSeparatedStates.split(','))
			{
				strState = strState.trim();
				setOfStates.add(strState);
			}
		}
		
		String strBrocker = ''; 
		String strContactId = '';
		Set<Id> setAgencyContactId = new Set<Id>();
		String strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
		
		/* If it is accessed from Agent home page */ 
		if(strProfileName == 'PURE Broker View Partner Login User')
		{
			for(User objUser : [SELECT ContactId
			 					  FROM User 
			 					 WHERE Id =: Userinfo.getUserId()
			 					 LIMIT 1])
			{
				strContactId = objUser.ContactId; 
				//primaryEmail = objUser.User_s_Email__c;
			}
			
			
			// Member Id
			userAccountId = Apexpages.currentPage().getParameters().get('mId');

			if(userAccountId != null || userAccountId != ''){

				// Ensure that the current user can access this account by checking if anything is
				// returned from this query
				List<Account> securityVerify =  [SELECT Id, Name, Member_Key_EDW__c
												 FROM Account
												 WHERE RecordType.Name = 'Member'
												   AND ID = :userAccountId
												   AND Broker__c IN (SELECT Agency__c 
														 			 FROM Agency_Contact__c 
														 			 WHERE Contact__c =: strContactId 
														   				AND User_Status__c = 'Active'
														   				AND (Agency__r.Broker_Status__c = 'Active'
							 					 						 OR Agency__r.Broker_Status__c = 'Suspended With Access'))
												 LIMIT 1];
				if(securityVerify.isEmpty()){
					PageReference pr = new PageReference('/Exception');
					pr.setRedirect(true);
					return pr;
				} else {
					memberName = securityVerify[0].Name;
					memberId = securityVerify[0].Member_Key_EDW__c;
				}

				String policyNumParam = Apexpages.currentPage().getParameters().get('url');
				if(policyNumParam != null){
					List<Policy__c> lstPolicy = new List<Policy__c>([Select Id, Policy_Number__c From Policy__c 
																	 Where Policy_Number__c = :policyNumParam
																	   AND (Policy_Status__c IN : setSLPolicyStatusValuesName)
																	   AND Member__c =: userAccountId]);
					if(!lstPolicy.isEmpty()) 
					{
						policyid = lstPolicy[0].Id;
					}
					else
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Parameter'));
						isError = true;
						return null;
					}
				}
			}

			//for(Agency_Contact__c obj : )
			//	setAgencyContactId.add(obj.Agency__c);
			
			//if(!setAgencyContactId.isEmpty() && setAgencyContactId != null)
			//	strBrocker =  'Broker__c IN: setAgencyContactId';
			//else{
			//	PageReference pr = new PageReference('/Exception');
			//	pr.setRedirect(true);
			//	return pr;
			//}
			
			/*
			userAccountId = objUser.Contact.AccountId;	
					memberName = objUser.Contact.Account.Name;
					memberId = objUser.Contact.Account.Member_Key_EDW__c;*/
				
			//String strQuery = 'SELECT Name, Member_Key_EDW__c, Phone, Primary_Email__c';
			//List<Account> lstAccount = new List<Account>();
			
			//String strMember = 'Member';
			
			//if(!String.isEmpty(strBrocker) && strBrocker != '')
			//{
			//	strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';
			//	lstAccount = Database.query(strQuery);
				
			//	if(lstAccount.isEmpty() || lstAccount == null )
			//	{
			//		PageReference pageRef = new PageReference('/Exception');
			//		return pageRef;
			//	}
			//	else
			//	{
			//		memberName = lstAccount[0].Name;
			//		memberId = lstAccount[0].Member_Key_EDW__c;
			//	}
			//}	
		} else {
					
			//If it is not accessing from portal
			if(Apexpages.currentPage().getParameters().containsKey('pid'))
			{
				policyid = ApexPages.currentPage().getParameters().get('pid');//Getting selected policy id from page.
				
				if(policyid != '') 
				{
					//Checking user type is Standard
					if(Userinfo.getUserType() == 'Standard') 
					{
						List<Policy__c> lstPolicy = new List<Policy__c>([Select Id From Policy__c Where Id = :policyid]);
					
						if(!lstPolicy.isEmpty()) 
						{
							policyid = lstPolicy[0].Id;
							/* This is to query member record type id.*/
							
							for(Policy__c objPolicy : [Select Id, Member__r.Name, Member__r.Member_Key_EDW__c from Policy__c where Id=:policyid])
							{
								memberName = objPolicy.Member__r.Name;
								memberId = objPolicy.Member__r.Member_Key_EDW__c;
							}
						}
						else
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Parameter'));
							isError = true;
							return null;
						}
					}
					else
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Parameter'));
						isError = true;
						return null;
					}
				}
				else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Parameter'));
					isError = true;
					return null;
				}
			}
			else if(Apexpages.currentPage().getParameters().containsKey('url'))
			{
				
				String policyNumber;
				policyNumber = ApexPages.currentPage().getParameters().get('url');//Getting selected policy id from page.
				
				if(policyNumber != '')
				{
					
					/* This is to query member record type id.*/
					for(RecordType objRecordType : [Select Id, SobjectType, Name from RecordType where Name =:'Member' AND SobjectType =: 'Account' limit 1])
					{
						userRecordTypeId = objRecordType.Id;
					}	
					
					/* This is to query logged in user account id, related member name and member id. */
					for(User objUser : [	Select Id, Contact.AccountId, Contact.Account.RecordTypeId,  Contact.Account.Last_Payment_Received__c,
											Contact.Account.Member_Key_EDW__c, Contact.Account.Name 
				 							from User where Id=: Userinfo.getUserId() AND Contact.Account.RecordTypeId =: userRecordTypeId limit 1
				 						
				 					])
					{
					
						userAccountId = objUser.Contact.AccountId;	
						memberName = objUser.Contact.Account.Name;
						memberId = objUser.Contact.Account.Member_Key_EDW__c;
						
					}	
					
					
					List<Policy__c> lstPolicy = new List<Policy__c>([	Select Id, Policy_Number__c From Policy__c 
																		Where Policy_Number__c = :policyNumber
																		AND (Policy_Status__c IN : setSLPolicyStatusValuesName)
																		AND Member__c =: userAccountId
																		
																	]);
					if(!lstPolicy.isEmpty()) 
					{
						policyid = lstPolicy[0].Id;
					}
					else
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Parameter'));
						isError = true;
						return null;
					}
				}
				else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Parameter'));
					isError = true;
					return null;
				}
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Parameter'));
				isError = true;
				return null;
			}
		}
		
			
		/* This is to query all policies related to that particular user .*/
		for(Policy__c objPolicy : [		Select Id, Member__c, Policy_Number__c, Name, Line_of_Business__c, Description__c, Bill_Payor_Name__c,
										Total_Premium_Amount__c, Policy_Status__c, Fine_Arts_Collectible_Blanket__c, 	Fine_Arts_Collectible_Scheduled__c, Description_Display__c 
										from Policy__c 
										where Member__c =: userAccountId
										AND (Policy_Status__c IN : setSLPolicyStatusValuesName)
									])
		{
			if(objPolicy.Line_of_Business__c != null && objPolicy.Line_of_Business__c != '' && objPolicy.Line_of_Business__c.trim().toLowerCase() != 'flood')
				lstpolicies.add(new SelectOption(objPolicy.Policy_Number__c, objPolicy.Description_Display__c));
		}
			
			sObjPolicy = [		Select Id, Bill_Payor_Name__c, 	Risk_State__c, Annual_Premium__c, Description_Display__c, Total_Premium_Amount__c, Line_of_Business__c, Policy_Number__c,LatestPolicyDocURL__c,
								Personal_Excess_Liability_Amount__c, Excess_Uninsured_Amount__c, Limited_Employment__c, Fine_Arts_Collectible_Blanket__c,Fine_Arts_Collectible_Scheduled__c,
								Wine_Blanket__c, Wine_Scheduled__c, Worldwide_Jewelry_Blanket__c, Worldwide_Jewelry_Scheduled__c, Coin_Silver_Stamps_Furs_Blanket__c,
								Coin_Silver_Stamps_Furs_Scheduled__c, Bank_vaulted_Jewelry_Scheduled__c, Misc_valuables_Scheduled__c
								from Policy__c
								where Id = :policyid
								limit 1
					];
		
			policyNumber = 	sObjPolicy.Policy_Number__c;
			policyType = sObjPolicy.Line_of_Business__c.trim().toLowerCase();
			latestPolicyDocUrl = sObjPolicy.LatestPolicyDocURL__c;
			strSelectedPolicy = sObjPolicy.Policy_Number__c;
			
			//set<String> setOfStates = new set<String>{'NJ', 'DE', 'MS', 'HI', 'CA'};
			if(sObjPolicy.Risk_State__c != null && sObjPolicy.Risk_State__c != '' && setOfStates.contains(sObjPolicy.Risk_State__c))
				isRiskState = true;
			
			
			collectibleBlanket = ((sObjPolicy.Fine_Arts_Collectible_Blanket__c != null ? (sObjPolicy.Fine_Arts_Collectible_Blanket__c != ''? Decimal.valueOf(sObjPolicy.Fine_Arts_Collectible_Blanket__c) :0.00):0.00));
			scheduleCoverage = ((sObjPolicy.Fine_Arts_Collectible_Scheduled__c != null ? (sObjPolicy.Fine_Arts_Collectible_Scheduled__c != ''? Decimal.valueOf(sObjPolicy.Fine_Arts_Collectible_Scheduled__c) :0.00):0.00));
			
			wineBlanket = ((sObjPolicy.Wine_Blanket__c != null ? (sObjPolicy.Wine_Blanket__c != ''? Decimal.valueOf(sObjPolicy.Wine_Blanket__c) :0.00):0.00));
			wineSchedule = ((sObjPolicy.Wine_Scheduled__c != null ? (sObjPolicy.Wine_Scheduled__c != ''? Decimal.valueOf(sObjPolicy.Wine_Scheduled__c) :0.00):0.00));
			worldWideJewelryBlanket = ((sObjPolicy.Worldwide_Jewelry_Blanket__c != null ? (sObjPolicy.Worldwide_Jewelry_Blanket__c != ''? Decimal.valueOf(sObjPolicy.Worldwide_Jewelry_Blanket__c) :0.00):0.00));
			JewelrySchedule = ((sObjPolicy.Worldwide_Jewelry_Scheduled__c != null ? (sObjPolicy.Worldwide_Jewelry_Scheduled__c != ''? Decimal.valueOf(sObjPolicy.Worldwide_Jewelry_Scheduled__c) :0.00):0.00));
			silverFursBlanket = ((sObjPolicy.Coin_Silver_Stamps_Furs_Blanket__c != null ? (sObjPolicy.Coin_Silver_Stamps_Furs_Blanket__c != ''? Decimal.valueOf(sObjPolicy.Coin_Silver_Stamps_Furs_Blanket__c) :0.00):0.00));
			silverFursSchedule = ((sObjPolicy.Coin_Silver_Stamps_Furs_Scheduled__c != null ? (sObjPolicy.Coin_Silver_Stamps_Furs_Scheduled__c != ''? Decimal.valueOf(sObjPolicy.Coin_Silver_Stamps_Furs_Scheduled__c) :0.00):0.00));
			bankValutedJewelryScheduled = ((sObjPolicy.Bank_vaulted_Jewelry_Scheduled__c != null ? (sObjPolicy.Bank_vaulted_Jewelry_Scheduled__c != ''? Decimal.valueOf(sObjPolicy.Bank_vaulted_Jewelry_Scheduled__c) :0.00):0.00));
			miscValuableScheduled = ((sObjPolicy.Misc_valuables_Scheduled__c != null ? (sObjPolicy.Misc_valuables_Scheduled__c != ''? Decimal.valueOf(sObjPolicy.Misc_valuables_Scheduled__c) :0.00):0.00));
			
			Integer TranscationRows = 0;
			Integer maxPolicyTerm = 0;
			
			maxPolicyTerm = Integer.valueOf([SELECT Max(Policy_Term_Sequence__c) FROM Transactions__c WHERE Policy__c =:sObjPolicy.Id ][0].get('expr0'));
			
			if(maxPolicyTerm != null)
				maxPolicyTerm = maxPolicyTerm - 2;
			
			/* This is to show all transactions happened in last 2 years. */
			for(Transactions__c objTransactions : [		Select Id, Name, Policy_Term_Transaction_Sequence__c, Effective_Date__c, Document_URL__c, Do_Not_Show__c, Description__c, Type__c, Cost__c, Process_Date__c, Document_URL_ID__c
														From Transactions__c 
														Where Policy__c =: sObjPolicy.Id 
														AND 
														CreatedDate = LAST_N_DAYS:430
														AND Do_Not_Show__c = false
														AND Description__c != 'download'
														AND Policy_Term_Sequence__c  >:maxPolicyTerm
														order By Policy_Term_Transaction_Sequence__c DESC NULLS LAST
														
												])
			{
				lstTransactions.add(new TransactionsWrapper((objTransactions.Effective_Date__c), objTransactions.Type__c, objTransactions.Description__c, (objTransactions.Process_Date__c), (objTransactions.Cost__c), objTransactions.Document_URL__c, TranscationRows++));
			}
			
			
			/* If policy type is Auto then show all necessary details.*/
			if(policyType == 'Auto')
			{
				getCoveredVehicle(sObjPolicy.Id);
				getPolicyListedOperators(sObjPolicy.Id);
				
			}
			else if(policyType == 'Homeowners')
			{
				getCoveredProperties(sObjPolicy.Id);
				getRiskManagmentReportData(sObjPolicy.Id);
				
			}
			else if(policyType == 'excess')
			{
				getCoveredVessels(sObjPolicy.Id);
				getPolicyListedOperators(sObjPolicy.Id);
				getCoveredProperties(sObjPolicy.Id);
			}
			else if(policyType == 'watercraft')
			{
				getCoveredVessels(sObjPolicy.Id);
				getPolicyListedOperators(sObjPolicy.Id);      
			}
			else if(policyType == 'collections')
			{
						
			}
			else if(policyType == 'workers_compensation')
			{
				getCoveredProperties(sObjPolicy.Id);
				lstCoveredEmployees = new list<Covered_Employees__c>();
				lstCoveredEmployees = [SELECT State__c, Number_of_Employees__c FROM Covered_Employees__c WHERE Policy__c =: sObjPolicy.Id];
			}
		
		return null;	
	}
	
	
	/* Wrapper class to store all vehile related to selected policy*/
	public class VehicleWrapper
	{
		public Decimal vehileYear				{get;set;}
		public string vehileModel				{get;set;}
		public Decimal vehileAgreedValue		{get;set;}
		public string vehileVin					{get;set;}
		public string vehileMake				{get;set;}
		public String idCardUrl					{get;set;}
		public Integer totalRows				{get;set;}
		public Boolean isIdCardVisible			{get;set;}
		
		/* Main constructor*/
		public VehicleWrapper(Decimal vehileYear, string vehileModel, Decimal vehileAgreedValue, string vehileVin, string vehileMake, String idCardUrl, Integer totalRows, Boolean isIdCardVisible)
		{
			this.vehileYear = vehileYear;
			this.vehileModel = vehileModel;
			this.vehileAgreedValue = vehileAgreedValue;
			this.vehileVin = vehileVin;
			this.vehileMake = vehileMake;
			this.idCardUrl = idCardUrl;
			this.totalRows = totalRows;
			this.isIdCardVisible = isIdCardVisible;
		}
				
	}

	/* Wrapper class to store all Risk Managment Data related to selected policy */
	public class riskManagmentWrapper
	{
		public String riskManagmentDownloadLink		{get;set;}
		public String riskManagmentPropertyAddress		{get;set;}
		
		public riskManagmentWrapper(String riskManagmentDownloadLink, String riskManagmentPropertyAddress)
		{
			this.riskManagmentDownloadLink = riskManagmentDownloadLink;
			this.riskManagmentPropertyAddress = riskManagmentPropertyAddress;
		}
		
	}

	
	/* Wrapper class to store all vehile related to selected policy*/
	public class listedOperatorWrapper
	{
		public String operatorName				{get;set;}
		public String operatorLicense			{get;set;}
		public String operatorState				{get;set;}
		public String operatorType				{get;set;}
		public String operatorStatus			{get;set;}
		public Date operatorDateOfBirth			{get;set;}
		public String statusDescription			{get;set;}
		public Integer row						{get;set;}
		
		/* Main constructor*/
		public listedOperatorWrapper(string operatorName, string operatorLicense, string operatorState, string operatorType, string operatorStatus, Date operatorDateOfBirth, String statusDescription, Integer row)
		{
			this.operatorName = operatorName;
			this.operatorLicense = operatorLicense;
			this.operatorState = operatorState;
			this.operatorType = operatorType;
			this.operatorStatus = operatorStatus;
			this.operatorDateOfBirth = operatorDateOfBirth;
			this.statusDescription = statusDescription;
			this.row = row;
		}
				
	}
	
	public class coveredVesselsWrapper
	{
		public Decimal CVHullValue				{get;set;}
		public Decimal CVHorsePower				{get;set;}
		public String CVMake					{get;set;}
		public String CVModel					{get;set;}
		public String CVlength					{get;set;}
		public String CVName					{get;set;}
		public Integer row						{get;set;}
		
		public coveredVesselsWrapper(Decimal CVHullValue, Decimal CVHorsePower, String CVMake, String CVModel, String CVlength, String CVName, Integer row)
		{
			this.CVHullValue = CVHullValue;
			this.CVHorsePower = CVHorsePower;
			this.CVMake = CVMake;
			this.CVModel = CVModel;
			this.CVlength = CVlength;
			this.CVName = CVName;
			this.row = row;
			
		}
	}
	
	/* Wrapper class to store all vehile related to selected policy*/
	public class coveredPropertiesWrapper
	{
		public String coveredProperty	{get;set;}
		public Integer propertyNo		{get;set;}
		
		public String LossOfUse						{get;set;}
		public Decimal LiabilityLimitAmount			{get;set;}
		public Decimal MedicalPaymentsAmount		{get;set;}
		public Decimal AOPDeductible				{get;set;}
		public Decimal HurricaneDeductible			{get;set;}
		public Decimal DwellingAmount				{get;set;}
		public Decimal OtherStructuresAmount		{get;set;}
		public Decimal ContentsAmount				{get;set;}
		
		public String LossOfUseLabel				{get;set;}
		public String LiabilityLimitAmountlabel		{get;set;}
		public String MedicalPaymentsAmountLabel	{get;set;}
		public String AOPDeductibleLabel			{get;set;}
		public String HurricaneDeductibleLabel		{get;set;}
		public String DwellingAmountlabel			{get;set;}
		public String OtherStructuresAmountlabel	{get;set;}
		public String ContentsAmountlabel			{get;set;}
		
		public Boolean isExtendedLiability			{get;set;}
		
		public coveredPropertiesWrapper(Integer propertyNo, String coveredProperty, Decimal DwellingAmount, Decimal OtherStructuresAmount, 	Decimal ContentsAmount,String LossOfUse, 	
										Decimal LiabilityLimitAmount, Decimal MedicalPaymentsAmount,
										Decimal AOPDeductible, Decimal HurricaneDeductible, 
										String DwellingAmountlabel, String OtherStructuresAmountlabel, String ContentsAmountlabel,
										String LossOfUseLabel, String LiabilityLimitAmountlabel, String MedicalPaymentsAmountLabel, String AOPDeductibleLabel,
										String HurricaneDeductibleLabel, Boolean isExtendedLiability)
		{
			this.coveredProperty = coveredProperty;
			this.propertyNo = propertyNo;
			
			this.LossOfUse = LossOfUse;
			this.LiabilityLimitAmount = LiabilityLimitAmount;
			this.MedicalPaymentsAmount = MedicalPaymentsAmount;
			this.AOPDeductible = AOPDeductible;
			this.HurricaneDeductible = HurricaneDeductible;
			this.DwellingAmount = DwellingAmount;
			this.OtherStructuresAmount = OtherStructuresAmount;
			this.ContentsAmount = ContentsAmount;
			
			this.LossOfUseLabel = LossOfUseLabel;
			this.LiabilityLimitAmountlabel = LiabilityLimitAmountlabel;
			this.MedicalPaymentsAmountLabel = MedicalPaymentsAmountLabel;
			this.AOPDeductibleLabel = AOPDeductibleLabel;
			this.HurricaneDeductibleLabel = HurricaneDeductibleLabel;
			this.DwellingAmountlabel = DwellingAmountlabel;
			this.OtherStructuresAmountlabel = OtherStructuresAmountlabel;
			this.ContentsAmountlabel = ContentsAmountlabel;
			this.isExtendedLiability = isExtendedLiability;
		}
		
		public coveredPropertiesWrapper(String coveredProperty, Integer propertyNo)
		{
			this.coveredProperty = coveredProperty;
			this.propertyNo = propertyNo;
		}
				
	}
	
	public class TransactionsWrapper
	{
		public Date transactionEffectiveDate		{get;set;}
		public Decimal transactionCost				{get;set;}
		public String transactionType				{get;set;}
		public Date transactionProcessDate			{get;set;}
		public String transactionDescription		{get;set;}
		public String transactionDownloadlink		{get;set;}
		public Integer row							{get;set;}
		
		public TransactionsWrapper(Date transactionEffectiveDate , String transactionType, String transactionDescription, Date transactionProcessDate, Decimal transactionCost, String transactionDownloadlink, Integer row	)
		{
			this.transactionEffectiveDate = transactionEffectiveDate;
			this.transactionCost = transactionCost;
			this.transactionType = transactionType;
			this.transactionProcessDate = transactionProcessDate;
			this.transactionDescription = transactionDescription;
			this.transactionDownloadlink = transactionDownloadlink;
			this.row = row;
		}
		
	}
	
	/*
        * MethodName        : getRiskManagmentReportData
        * param             : policyid
        * Description       : This function will Query all covered vehicle related to policy id.
    */
	private void getRiskManagmentReportData(String policyid)
	{
		
		for(Risk_Management_Report__c objRM : [		Select Id, Policy__c, DocURL__c, DocId__c, Date__c, Address__c 
													from Risk_Management_Report__c
													where Policy__c =: policyid
													 
											])
		{
			lstRiskManagmentWrapper.add(new riskManagmentWrapper(objRM.DocURL__c, objRM.Address__c));
		}
	}
	
	/*
        * MethodName        : getCoveredVehicle
        * param             : policyid
        * Description       : This function will Query all covered vehicle related to policy id.
    */
	private void getCoveredProperties(String policyid)
	{
		Integer strPropertyNo = 0;
		Integer strExtendedPropert = 0;
		
		for(Property__c objProperty : [		Select Id, Name, 	AOP_Deductible__c, City__c, Contents_Amount__c, Dwelling_Amount__c,
											EDW_ID__c, 	Extended_Liability__c, 	Hurricane_Deductible__c, Liability_Limit_Amount__c,
											Loss_of_Use__c, Medical_Payments_Amount__c, Other_Structures_Amount__c, Properties__c, 	Policy__c,
											State__c, Street__c, Street_2__c, Zip__c
											from  Property__c 
											where Policy__c =: policyid
													
														
												])
		{
			
			if(objProperty.Extended_Liability__c == true && objProperty.Properties__c != '')
			{
				strExtendedPropert++;	
				
				lstExtendedProperties.add(new coveredPropertiesWrapper(objProperty.Properties__c, strExtendedPropert));
			}
			else
			{
			
				CoverageClasslabel__c ccl = 	CoverageClasslabel__c.getInstance(objProperty.State__c);
				
				strPropertyNo++;
				if(ccl != null)
				{
						lstCoveredProperties.add(		new coveredPropertiesWrapper(strPropertyNo, objProperty.Properties__c,
												objProperty.Dwelling_Amount__c, objProperty.Other_Structures_Amount__c,
												objProperty.Contents_Amount__c, objProperty.Loss_of_Use__c,
												objProperty.Liability_Limit_Amount__c,objProperty.Medical_Payments_Amount__c, objProperty.AOP_Deductible__c,
												objProperty.Hurricane_Deductible__c,
												(ccl.Dwelling_Amount__c == null? 'Dwelling Amount': ccl.Dwelling_Amount__c),
												(ccl.Other_Structures_Amount__c == null? 'Other Structures Amount': ccl.Other_Structures_Amount__c),
												(ccl.Contents_Amount__c == null? 'Contents Amount': ccl.Contents_Amount__c),
												(ccl.Loss_of_Use__c == null? 'Loss Of Use': ccl.Loss_of_Use__c),
												(ccl.Liability_Limit_Amount__c == null? 'Liability Limit Amount': ccl.Liability_Limit_Amount__c),
												(ccl.Medical_Payments_Amount__c == null? 'Medical Payments Amount': ccl.Medical_Payments_Amount__c),
												(ccl.AOP_Deductible__c != null? 'AOP Deductible': ccl.AOP_Deductible__c),
												(ccl.Hurricane_Deductible__c == null? 'Hurricane Deductible': ccl.Hurricane_Deductible__c),
												
												objProperty.Extended_Liability__c));
				}
				else
				{
					lstCoveredProperties.add(	new coveredPropertiesWrapper(strPropertyNo, objProperty.Properties__c, objProperty.Dwelling_Amount__c, objProperty.Other_Structures_Amount__c,
												objProperty.Contents_Amount__c, objProperty.Loss_of_Use__c,
												objProperty.Liability_Limit_Amount__c,objProperty.Medical_Payments_Amount__c, objProperty.AOP_Deductible__c,
												objProperty.Hurricane_Deductible__c,
												'Dwelling Amount',
												 'Other Structures Amount',
												 'Contents Amount',
												 'Loss Of Use',
												'Liability Limit Amount',
												'Medical Payments Amount',
												'AOP Deductible',
												'Hurricane Deductible',
												
												 objProperty.Extended_Liability__c));
				}
			
			}
		}
		system.debug('---------lstCoveredProperties-----------------:'+lstCoveredProperties);
	}
	
	/*
        * MethodName        : getCoveredVehicle
        * param             : policyid
        * Description       : This function will Query all covered vehicle related to policy id.
    */
	private void getCoveredVehicle(String policyid)
	{
		Integer countRows = 0;
		//set<String> setOfStates = new set<String>{'NJ', 'DE', 'MS', 'HI', 'CA'};
		
		for(Vehicle__c objvehicle : [	Select Id, Make__c, Model__c, Agreed_Value__c, Year__c, VIN__c, IDCardURL__c,Can_Download__c, Policy__r.Risk_State__c
										from Vehicle__c 
										where Policy__c =: policyid  
											
									])
		{
			countRows++;
			if(objvehicle.Policy__r.Risk_State__c != null && objvehicle.Policy__r.Risk_State__c != '' && setOfStates.contains(objvehicle.Policy__r.Risk_State__c))
				lstVehicles.add(new VehicleWrapper(objvehicle.Year__c, objvehicle.Model__c, objvehicle.Agreed_Value__c, objvehicle.VIN__c, objvehicle.Make__c, objvehicle.IDCardURL__c, countRows,false));
			else
				lstVehicles.add(new VehicleWrapper(objvehicle.Year__c, objvehicle.Model__c, objvehicle.Agreed_Value__c, objvehicle.VIN__c, objvehicle.Make__c, objvehicle.IDCardURL__c, countRows, true));
		}
	}
	
	/*
        * MethodName        : getCoveredVessels
        * param             : policyid
        * Description       : This function will Query all covered vessels related to policy id.
    */
	private void getCoveredVessels(String policyid)
	{
		
		Integer I = 0;
		for(Covered_Vessels__c objCoveredvessels : [	Select Id, Name, Horsepower__c, Hull_Value__c, 	Length__c, 	Make__c, Model__c, 	Policy__c
														from Covered_Vessels__c
														where Policy__c =: policyid
															
															])
		{
			lstCoveredvessels.add(new coveredVesselsWrapper(objCoveredvessels.Hull_Value__c, objCoveredvessels.Horsepower__c, objCoveredvessels.Make__c, objCoveredvessels.Model__c, objCoveredvessels.Length__c, objCoveredvessels.Name , I++));
		}
	
	}
	
	/*
        * MethodName        : getPolicyListedOperators
        * param             : policyid
        * Description       : This function will Query all listed operators related to policy id.
    */
	private void getPolicyListedOperators(String policyid)
	{
		
		Integer I = 0;
		/* Query all operators related to Selected policy */	
		for(Operator__c objoperator : [		Select Id, Name, DOB__c, License__c, Status__c, Type__c, State__c
											from Operator__c
											where Policy__c =: policyid	
												
									])
									
		{
			OperatorStatus__c os  = new OperatorStatus__c();
			
			if(objoperator.Status__c != null && objoperator.Status__c != '')
			{
				os = OperatorStatus__c.getInstance(objoperator.Status__c);
				if(os != null)
				lstListedOperators.add(new listedOperatorWrapper(objoperator.Name, objoperator.License__c, objoperator.State__c, objoperator.Type__c, objoperator.Status__c, objoperator.DOB__c, os.statusDescription__c, I++));
			}
			else
			lstListedOperators.add(new listedOperatorWrapper(objoperator.Name, objoperator.License__c, objoperator.State__c, objoperator.Type__c, objoperator.Status__c, objoperator.DOB__c, 'Status is not available', I++));
		}
		
	}
	
}