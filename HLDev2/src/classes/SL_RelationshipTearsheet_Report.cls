/**
* \arg ClassName      : SL_RelationshipTearsheet_Report
* \arg JIRATicket     : HL-24
* \arg CreatedOn      : 14/Aug/2014
* \arg LastModifiedOn : 18/AUg/2014
* \arg CreatededBy    : Sathya
* \arg ModifiedBy     : -
* \arg Description    : Controller class for SL_RelationshipTearsheet_Report page.   
*/
public with sharing class SL_RelationshipTearsheet_Report 
{    
	/*Start - Variables*/
	public Contact objContact						{get;set;}//To Store all information about Current Contact.    
	public Decimal totalReferralFees				{get;set;}//To Store total referral fee
	public Boolean isReferral						{get;set;}//To check current contact exist as referral contact on opportunity
	public String strCompanyDesc					{get;set;}//To store the truncated company description. 		 
	public String strTotalRefferalFeesSymbol		{get;set;}//To store the total refferal fees with symbol
	/*End - Variables*/
	
	/*Start - Constructor*/
	public SL_RelationshipTearsheet_Report()
	{
		initialize();//To initalize the necessary members.
		getReportData();//To get the Contact data.
	}
	/*End - Constructor*/
	
	/*
		@MethodName : initialize 
		@param 	    : NA
		@Description: method to intialize all global variables. 
	*/
	private void initialize()  
	{
		objContact = new Contact();
		totalReferralFees = 0;
	}
	/*End */
	
	/*
		@MethodName : getReportData 
		@param 	    : NA
		@Description: Method for fetching the report data. 
	*/
	public void getReportData()
	{
		String strContactId = ApexPages.currentPage().getParameters().get('Id');
		
		/* This is to show the first 2 blog data */
		List<Contact> lstContact = [SELECT Id, Name, 
										   Title, Phone, 
										   Email, MobilePhone, 
										   AssistantName, AssistantPhone, 
										   MailingStreet, MailingState, 
									       MailingPostalCode, MailingCountry, 
									       MailingCity, Account.Name, 
										   Account.Description, Account.Revenue_MM__c, 
										   Account.EBITDA_MM__c, Account.Total_Debt_MM__c, 
										   Account.Total_Debt_EBITDA__c
							          FROM Contact
				   			         WHERE Id =:strContactId];
				   			         
		if(!lstContact.isEmpty())
		{
			objContact = lstContact[0];
			strCompanyDesc = (objContact.Account.Description!= null && objContact.Account.Description.length() > 900)
							 ? objContact.Account.Description.substring(0, 890) + '....'
							 : objContact.Account.Description;
		}		   			         	
	}
	/*End */
	
	/*
		@MethodName : getMostActiveHLRelationship 
		@param 	    : NA
		@Description: method for getting Most recent HL relatioship . 
	*/
	public List<Relationship__c> getMostActiveHLRelationship()
	{
		List<Relationship__c> lstRelatioshipRecs = new List<Relationship__c>();//List of Relationship__c
		
		lstRelatioshipRecs = [SELECT Id, 
									 HL_Contact__r.Title, 
									 HL_Contact__r.Name,  
									 Strength_Rating__c, 
									 Number_of_Activities_LTM__c, 
									 Last_Activity_Date__c 
							    FROM Relationship__c  
							   WHERE External_Contact__c =: objContact.Id 
							ORDER BY Number_of_Activities_LTM__c DESC];
	
		if(lstRelatioshipRecs.size() > 0 && objContact.Id != null)
			return lstRelatioshipRecs;
		else 
			return new List<Relationship__c>();
	}
	/* End */
	
	/* Start - Wrapper class for Activities wrapper */
	public class ActivityWrapper implements Comparable
	{	
		public Date dtDlDate						{	get;set;	}//to store date
		public String strSub						{	get;set;	}//to store subject
		public String strWhoName					{	get;set;	}//to store contact name
		public String strWhoTitle					{	get;set;	}//to store contact name
		public String strWhoId						{	get;set;	}//to store contact id
		
		public ActivityWrapper(Date dtDlDate, String strSub, String strWhoName, String strWhoTitle, String strWhoId)
		{
			this.dtDlDate = dtDlDate;
			this.strSub = strSub;
			this.strWhoName = strWhoName;
			this.strWhoTitle = strWhoTitle;
			this.strWhoId = strWhoId;
		}
		public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        ActivityWrapper compareToActivity= (ActivityWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (dtDlDate > compareToActivity.dtDlDate) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (dtDlDate < compareToActivity.dtDlDate) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }

	}
	/*End - Wrapper class for hl transaction wrapper*/
	
	/* Start - Wrapper class for Engagment History with HL */
	public class EngagmentHistoryWrapper
	{
		public Date strEnggCloseDate				{	get;set;	}//to store close date 
		public String strEnggName					{	get;set;	}//to store engagement name
		public String strEnggJobType				{	get;set;	}//to store job type
		public String strEnggBusinessUnit			{	get;set;	}//to store business unit
		public String strEnggStatus					{	get;set;	}//to store status 
		public String strHLTeammember				{	get;set;	}//to store hl contact name
		public Boolean isActive						{	get;set;	}//to store boolean value
		
		public EngagmentHistoryWrapper(Date strEnggCloseDate, String strEnggName, String strEnggJobType, String strEnggBusinessUnit, 
									   String strEnggStatus, String strHLTeammember,Boolean isActive)
		{
			this.strEnggCloseDate = strEnggCloseDate;
			this.strEnggName = strEnggName;
			this.strEnggJobType = strEnggJobType;
			this.strEnggBusinessUnit = strEnggBusinessUnit;
			this.strEnggStatus = strEnggStatus;
			this.strHLTeammember = strHLTeammember;
			this.isActive = isActive;
		}
	}
	/* End - Wrapper class for Engagment History with HL */
	
	/* Start - Wrapper class for Engagment History with HL */
	public class RefferalFeesHistory
	{
		public Engagement__c objEngagement		{	get;set;	}//to store Engagement__c records
		public String strHLTeammember			{	get;set;	}//to store hl contact name
		
		public RefferalFeesHistory(Engagement__c objEngagement, String strHLTeammember)
		{
			this.objEngagement = objEngagement;
			this.strHLTeammember = strHLTeammember;
		}
	}
	/* End - Wrapper class for Engagment History with HL */
	
	/* Start - Wrapper class for Engagment History with HL */
	public class OpenOpportunityWrapper
	{
		public Opportunity__c objOpportunity		{	get;set;	}//to store Opportunity__c records
		public String strHLTeamMember				{	get;set;	}//to store hl contact name
		
		public OpenOpportunityWrapper(Opportunity__c objOpportunity, String strHLTeamMember)
		{
			this.objOpportunity = objOpportunity;
			this.strHLTeamMember = strHLTeamMember;
		}
	}
	/* End - Wrapper class for Engagment History with HL */
	
	/* Start - Wrapper class for conference attendence */
	public class ConferenceAttendanceWrapper
	{
		public Date dtStartDate						{	get;set;	}//to store the campaign start date
		public String strCampaignName				{	get;set;	}//to store campaign name
		public String strCampaignMemberStatus		{	get;set;	}//to store campaign member status
		
		public ConferenceAttendanceWrapper(Date dtStartDate, String strCampaignName, String strCampaignMemberStatus)
		{
			this.dtStartDate = dtStartDate;
			this.strCampaignName = strCampaignName;
			this.strCampaignMemberStatus = strCampaignMemberStatus;
		}
	}
	/* End - Wrapper class for conference attendence */
	
	/*
		@MethodName : getMostRecentActitivites 
		@param 	    : NA
		@Description: Method for Getting Most Recent Activites . 
	*/
	public List<ActivityWrapper> getMostRecentActitivites() 
	{
		Date currentDate = Date.today().addMonths(-12);//Variable to store one year ago date
		
		List<ActivityWrapper> lstActivityWrapper = new List<ActivityWrapper>();//List of ActivityWrapper 
		
		//Getting last 12 months task
		for (TaskRelation objTasktr:[SELECT TaskId,
                                            Task.Owner.Name,
                                            Task.Owner.Title,
                                            Task.ActivityDate,
                                            Task.Subject,
                                            RelationId,
                                            Relation.Name,
                                            Relation.Title
                                    FROM    TaskRelation
                                    WHERE   RelationId =: objContact.Id
                                    AND Task.ActivityDate >: currentDate
                                    ORDER BY Task.ActivityDate DESC])
		{
			lstActivityWrapper.add(new ActivityWrapper(objTasktr.Task.ActivityDate, objTasktr.Task.Subject, objTasktr.Task.Owner.Name, 
													   objTasktr.Task.Owner.Title, objTasktr.RelationId));
		}
		//Getting last 12 months event
		for (EventRelation objEventer:[SELECT EventId,
                                            Event.Owner.Name,
                                            Event.Owner.Title,
                                            Event.ActivityDate,
                                            Event.Subject,
                                            RelationId,
                                            Relation.Name,
                                            Relation.Title
                                    FROM    EventRelation
                                    WHERE   RelationId =: objContact.Id
                                    AND Event.ActivityDate >: currentDate
                                    ORDER BY Event.ActivityDate DESC])
		{
			lstActivityWrapper.add(new ActivityWrapper(objEventer.Event.ActivityDate, objEventer.Event.Subject, objEventer.Event.Owner.Name, 
													   objEventer.Event.Owner.Title, objEventer.RelationId));
		}
		
		lstActivityWrapper.sort();
		for (Integer ii = 0; ii < lstActivityWrapper.size()/2; ii++){
			ActivityWrapper temp = lstActivityWrapper[ii];
			lstActivityWrapper[ii]=lstActivityWrapper[(lstActivityWrapper.size()-1)-ii];
			lstActivityWrapper[(lstActivityWrapper.size()-1)-ii] = temp;
		}

		if(lstActivityWrapper.size() > 0 && objContact.Id != null)
			return lstActivityWrapper;
		else 
			return new List<ActivityWrapper>();
		
	}
	/* End */
	
	/*
		@MethodName : EngagementHistory 
		@param 	    : NA
		@Description: method for getting The Engagements
	*/
	public List<EngagmentHistoryWrapper> getEngagementHistory()
	{
		Date fiveYearDate = Date.today().addYears(-5);//Variable to store five year ago date 
		List<Engagement__c> lstEngagements = new List<Engagement__c>();//List of Engagement__c 
		List<EngagmentHistoryWrapper> lstEnggHistoryWrapper = new List<EngagmentHistoryWrapper>();//List of EngagmentHistoryWrapper
		Set<Id> setEngagementId = new Set<Id>();
		
		// Getting all the Engagements related to this Contact
		for(Engagement_External_Team__c objEngagementExternalTeam : [SELECT Id, 
																			Contact__c, 
																			Engagement__c 
																	   FROM Engagement_External_Team__c 
																	  WHERE Contact__c =: objContact.Id
																	  	AND Engagement__c != null])
		{
			setEngagementId.add(objEngagementExternalTeam.Engagement__c);
		}
		
		//Iterating on Engagement__c to add the EngagmentHistoryWrapper object into list 
		for(Engagement__c objEngagement : [SELECT Status__c, 
												  Name, 
												  Close_Date__c, 
												  Job_Type__c, 
												  Line_of_Business__c, 
												  RecordTypeId,
												  Active__c, 
										   		  (SELECT Id,  
										   		   		  Contact__r.Name
								  	      			 FROM Engagement_Teams__r
										 			WHERE Principal__c = true
										  		 ORDER BY CreatedDate DESC LIMIT 1)
										  	 FROM Engagement__c 
										    WHERE Id IN : setEngagementId 
										      AND ((Close_Date__c != NULL AND Close_Date__c >=: fiveYearDate) OR Active__c = true)
										 ORDER BY Close_Date__c DESC])
		{
			lstEnggHistoryWrapper.add(new EngagmentHistoryWrapper(objEngagement.Close_Date__c,
																  objEngagement.Name, 
																  objEngagement.Job_Type__c,
																  objEngagement.Line_of_Business__c, 
																  objEngagement.Status__c,
																  (objEngagement.Engagement_Teams__r.size() > 0) 
											    				   ? objEngagement.Engagement_Teams__r[0].Contact__r.Name : '',
											    				   objEngagement.Active__c));
		}
		
		if(lstEnggHistoryWrapper.size() > 0 && objContact.Id != null)    
			return lstEnggHistoryWrapper;
		else
			return new List<EngagmentHistoryWrapper>();
	}
	/* End */
	
	/*
		@MethodName : ConferenceAttendance 
		@param 	    : NA
		@Description: method for getting The Conference Attendance
	*/
	public List<ConferenceAttendanceWrapper> getConferenceAttendance()
	{
		List<ConferenceAttendanceWrapper> lstCAW = new List<ConferenceAttendanceWrapper>();//List of Campaign
		Map<Id, String> mapCampaignIdToMemberStatus = new Map<Id, String>();//Map of campaign id to campaign member status
	
		// Getting the Campaign Ids related CampaignMembers for the current Contact
		for(CampaignMember objCM : [SELECT CampaignId, 
										   Status 
									  FROM CampaignMember 
									 WHERE ContactId =: objContact.Id 
									   AND CampaignId != null])
			mapCampaignIdToMemberStatus.put(objCM.CampaignId, objCM.Status);
		//Getting all the campaign where start date is in past 
		for(Campaign objcampaign : [SELECT Id, 
										   StartDate, 
										   Name 
									  FROM Campaign 
									 WHERE Id IN : mapCampaignIdToMemberStatus.keySet() 
									   AND Type IN ('Conference', 'Event', 'Seminar / Conference')
									   AND StartDate <: Date.today()
								  ORDER BY StartDate DESC LIMIT 5])
		{
				lstCAW.add(new ConferenceAttendanceWrapper(objcampaign.StartDate, objcampaign.Name, 
														   mapCampaignIdToMemberStatus.get(objcampaign.Id) != null 
														   ? mapCampaignIdToMemberStatus.get(objcampaign.Id) : ''));
		}
		
		//Getting all the campaign where start date is in future
		for(Campaign objcampaign : [SELECT Id, 
										   StartDate, 
										   Name 
									  FROM Campaign 
									 WHERE StartDate >=: Date.today()
								  ORDER BY StartDate DESC])
		{
				lstCAW.add(new ConferenceAttendanceWrapper(objcampaign.StartDate, objcampaign.Name, 
														   (mapCampaignIdToMemberStatus.containsKey(objcampaign.Id) 
														   && mapCampaignIdToMemberStatus.get(objcampaign.Id) != null)
														   ? mapCampaignIdToMemberStatus.get(objcampaign.Id) : ''));
		}
		
		if(!lstCAW.isEmpty() && objContact.Id != null)
			return lstCAW;
		else
			return new List<ConferenceAttendanceWrapper>();
	}
	/* End */
	
	/*
		@MethodName : RefferalFeesHistory 
		@param 	    : NA
		@Description: method for getting The Engagements
	*/
	public List<RefferalFeesHistory> getRefferalFeesHistory()
	{
		list<RefferalFeesHistory> lstRefferalFeesHistory = new list<RefferalFeesHistory>();//list of RefferalFeesHistory wrapper
		totalReferralFees = 0;
		
		//Iterating on Engagement__c to get RefferalFeesHistory records
		for(Engagement__c objEngagement : [SELECT Status__c, 
												  Job_Type__c, 
												  Subject__r.Name, 
												  Stage__c, 
												  Name, 
												  Close_Date__c, 
												  Total_Fees__c, 
												  Transaction_Type__c, 
												  Start_Date__c, 
												  RecordType.Name, 
												  RecordTypeId, 
										   		  (SELECT Id,  
										   		  		  Contact__r.Name
									  	      		 FROM Engagement_Teams__r
											 		WHERE Principal__c=True
											  	 ORDER BY CreatedDate DESC LIMIT 1)
											 FROM Engagement__c 
										    WHERE Referral_Contact__c =: objContact.Id 
										 ORDER BY Start_Date__c DESC])
		{
			lstRefferalFeesHistory.add(new RefferalFeesHistory(objEngagement, 
															   (objEngagement.Engagement_Teams__r.size() > 0) 
												    		    ? objEngagement.Engagement_Teams__r[0].Contact__r.Name : ''));
		}
		
		//iterating on engagement for calulating the total sum.
		for(Engagement__c objEngagement : [SELECT Id,
												  ConvertCurrency(Total_Fees__c)
											 FROM Engagement__c
											WHERE Referral_Contact__c =: objContact.Id])
		{
			totalReferralFees += objEngagement.Total_Fees__c;
		}											 
		strTotalRefferalFeesSymbol = UserInfo.getDefaultCurrency();
		
		if(!lstRefferalFeesHistory.isEmpty() && objContact.Id != null)
			return lstRefferalFeesHistory;
		else
			return new List<RefferalFeesHistory>();
	}
	/* End */
	
	/*
		@MethodName : getDealsShown 
		@param 	    : NA
		@Description: method for getting The Deals
	*/
	public List<Engagement_Counterparty__c> getDealsShown()
	{
		Date fiveYearDate = Date.today().addYears(-5);//Variable to store five year ago date
		List<Engagement_Counterparty__c> lstECC = new List<Engagement_Counterparty__c>();//List of Engagement_Counterparty_Contact__c
		
		List<Engagement_Counterparty_Contact__c> validEngagements = [SELECT Counterparty__c FROM Engagement_Counterparty_Contact__c WHERE Contact__c=: objContact.Id];
		Set<Id> validEngagementIds = new Set<Id>();
		for (Engagement_Counterparty_Contact__c e: validEngagements){
			validEngagementIds.add(e.Counterparty__c);
		}

		lstECC = [	SELECT 
						Role__c,
		 				Status__c,	
		 				Company__r.Name,
						Engagement__r.Start_Date__c,
						Engagement__r.Name,
						Engagement__r.Job_Type__c
					FROM Engagement_Counterparty__c
					WHERE Id IN :validEngagementIds
					AND (Engagement__r.Close_date__c >: fiveYearDate 
					OR  Engagement__r.Close_date__c = null)
					ORDER BY Engagement__r.Close_date__c DESC NULLS FIRST];
		if(!lstECC.isEmpty() && objContact.Id != null)
			return lstECC;
		else
			return new List<Engagement_Counterparty__c>();
	}
	/* End */
	/*
		@MethodName : getNumDealsShown 
		@param 	    : NA
		@Description: method for getting The Deals number
	*/
	public Integer getNumDealsShown()
	{
		return getDealsShown().size();
	}
	/*
		@MethodName : getOpenOpportunities 
		@param 	    : NA
		@Description: method for getting The the recent Opportunities related to the Opp external team of the current contact
	*/
	public List<OpenOpportunityWrapper> getOpenOpportunities()
	{
		String strContactId = ApexPages.currentPage().getParameters().get('Id');
		List<OpenOpportunityWrapper> lstOpenOpportunityWrapper = new List<OpenOpportunityWrapper>();//List of OpenOpportunityWrapper
		Set<Id> setofOppIds = new Set<Id>();
		
		// Getting all Opportunity__c Ids from the related OpportunityExternal records related to the current conatct
		for(Opportunity_External_Team__c objOpportunityExternalTeam :[SELECT Id, 
																			 Opportunity__c, 
																			 Contact__c 
																		FROM Opportunity_External_Team__c 
																       WHERE Contact__c =: objContact.Id 
																		 AND Opportunity__c != NULL])
			setofOppIds.add(objOpportunityExternalTeam.Opportunity__c);
			
		//for getting referral source information 
		if(!String.isEmpty(strContactId))
			isReferral = [SELECT Id 
						    FROM Opportunity__c 
						   WHERE referral_contact__c =: strContactId LIMIT 1].size()>0 ? true : false;	
		
		if(!setofOppIds.isEmpty())
		{
			for(Opportunity__c objOpportunity  : [SELECT Stage__c, 
														 Client__r.Name, 
														 Client__c, 
														 Estimated_Fee__c, 
														 Job_Type__c, 
														 Estimated_Engagement_Date__c,
													  	 (SELECT Id,  
													  		  	 Contact__r.Name
										  	      		 	FROM Opportunity_Internal_Teams__r
												 		   WHERE Principal__c = true
												  	 	ORDER BY CreatedDate DESC LIMIT 1)
											 	    FROM Opportunity__c 
												   WHERE Id IN : setofOppIds 
											  		 AND Stage__c NOT IN ('Dead','Lost','Dead / Lost','Closed / Won / Engaged','Closed','Engaged') 
										 		ORDER BY Estimated_Engagement_Date__c DESC])
			{
				lstOpenOpportunityWrapper.add(new OpenOpportunityWrapper(objOpportunity,
																		 (objOpportunity.Opportunity_Internal_Teams__r.size() > 0) 
												    					 ? objOpportunity.Opportunity_Internal_Teams__r[0].Contact__r.Name : '')); 
			}
		}
		if(!lstOpenOpportunityWrapper.isEmpty() && objContact.Id != null)
			return lstOpenOpportunityWrapper ;
		else
			return new List<OpenOpportunityWrapper>();
	}
	/* End */
	
	/*
		@MethodName : getCareerBoardInformation 
		@param 	    : String
		@Description: method for getting The career informations
	*/
	public List<String> getCareerInformation()
	{
		return getCareerBoardInformation('Career');
	}
	/* End */
	
	/*
		@MethodName : getCareerBoardInformation 
		@param 	    : String
		@Description: method for getting The board informations
	*/
	public List<String> getBoardInformation()
	{
		return getCareerBoardInformation('Board');
	}
	/* End */
	
	/*
		@MethodName : getCareerBoardInformation 
		@param 	    : NA
		@Description: method for getting The career board informations related to current contact
	*/
	public List<String> getCareerBoardInformation(String strInfoType)
	{
		List<String> lstCareerBoardInformation = new List<String>();//List of String to store company names
		
		if(strInfoType == 'Career')
		{
			lstCareerBoardInformation.add(objContact.Account.Name);
			//Iterate on Affiliation__c where status is former
			for(Affiliation__c objAff : [SELECT Account__r.Name, 
												Contact__c, End_Date__c 
										   FROM Affiliation__c 
										  WHERE Contact__c =: objContact.Id 
											AND Status__c IN('Former') 
									   ORDER BY Account__r.Name LIMIT 4])
			{
				lstCareerBoardInformation.add(objAff.Account__r.Name);
			}
		}	
		
		if(strInfoType == 'Board')
		{
			String strType = '%Board Member%';
			//Iterate on Affiliation__c for getting board members.
			for(Affiliation__c objAff : [SELECT Account__r.Name, 
												CreatedDate, Contact__c, End_Date__c 
										   FROM Affiliation__c 
										  WHERE Contact__c =: objContact.Id 
											AND Type__c LIKE: strType 
									   ORDER BY Status__c, Account__r.Name LIMIT 5])
			{
				lstCareerBoardInformation.add(objAff.Account__r.Name);
			}
		}	
		return lstCareerBoardInformation;
	}
	/* End */
}