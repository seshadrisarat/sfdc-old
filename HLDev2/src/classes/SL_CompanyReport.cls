/**
* \arg ClassName      : SL_CompanyReport
* \arg JIRATicket     : HL-25
* \arg CreatedOn      : 18/Aug/2014
* \arg LastModifiedOn : 3/Dec/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Controller class for SL_CompanyReport page.
*/
public with sharing class SL_CompanyReport 
{
    /*Start - Variables*/
    public String strCompanyDesc        {   get;set;    }//to store the truncated company description.
    private Set<Id> setAccountId;//set of related company ids.   
    /*End - Variables*/
    
    /*Start - Constructor*/
    public SL_CompanyReport()
    {
        setAccountId = getAccountIds(ApexPages.currentPage().getParameters().get('Id'));//Set of related Company id
    }
    /*End - Constructor*/
    
    
    /* Start - Wrapper class for contact wrapper */
    public class ContactWrapper implements Comparable
    {
        public String strName           {   get;set;    }// Variable used for contact name.
        public String strTitle          {   get;set;    }// Variable used for contact title.
        public String strLastActivity   {   get;set;    }// Variable used for latest activity date of the contact
        public Integer intTotalActivity {   get;set;    }// Variable used for getting total no of activity on contact
        public DateTime dtLastActivity  {   get;set;    }// Variable used for getting subject of latest activity.
        
        public ContactWrapper(String strName, String strTitle, String strLastActivity, Integer intTotalActivity, DateTime dtLastActivity)
        {
            this.strName = strName;
            this.strTitle = strTitle;
            this.strLastActivity = strLastActivity;
            this.intTotalActivity = intTotalActivity;
            this.dtLastActivity = dtLastActivity;
        }

        public Integer compareTo(Object compareTo) {
            // Cast argument to Contact Wrapper
            ContactWrapper compareToContact= (ContactWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (intTotalActivity < compareToContact.intTotalActivity) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (intTotalActivity > compareToContact.intTotalActivity) {
                // Set return value to a negative value.
                returnValue = -1;
            }
        
        return returnValue;       
        }
        
    }
    /* End - Wrapper class for contact wrapper */
    
    /*Start - Wrapper class for recent activity of company*/
    public class RecentActivityWrapper implements Comparable
    {
        public DateTime dtActivityDate          {   get;set;    }// Variable used for getting recent activity date of company
        public String strActivity               {   get;set;    }// Variable used for getting recent activity subject
        public String strHlEmployee             {   get;set;    }// Variable used for getting name of activity owner
        public String strTitle                  {   get;set;    }// Variable used for getting title of activity owner
        public String strExternalContact		{   get;set;    }// Variable used for getting name of activity external contact

        public RecentActivityWrapper(DateTime dtActivityDate, String strActivity, String strHlEmployee, String strTitle, String strExternalContact)
        {
            this.dtActivityDate = dtActivityDate;
            this.strActivity = strActivity;
            this.strHlEmployee = strHlEmployee;
            this.strTitle = strTitle;
            this.strExternalContact=strExternalContact;
        }
        public Integer compareTo(Object compareTo) {
            // Cast argument to RecentActivityWrapper
            RecentActivityWrapper compareToActivity= (RecentActivityWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (dtActivityDate < compareToActivity.dtActivityDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (dtActivityDate > compareToActivity.dtActivityDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
        
        return returnValue;       
        }
    }
    /*End - Wrapper class for recent activity of company*/
    
    /* Start - Wrapper class for Opportunity wrapper */
    public class OpportunityWrapper
    {   
        public Opportunity__c objOpportunity    {   get;set;    }
        public String strPrincipal              {   get;set;    }// Variable used for getting Opportunity internal team name  
        
        public OpportunityWrapper(Opportunity__c objOpportunity, String strPrincipal)
        {
            this.objOpportunity = objOpportunity;
            this.strPrincipal = strPrincipal;
        }
                
    }
    /*End - Wrapper class for Opportunity wrapper*/
    
    /* Start - Wrapper class for hl transaction wrapper */
    public class HlTransactionWrapper
    {
        public Engagement__c objEngagement          {   get;set;    }//To store engagement details
        public String strTransPrincipal             {   get;set;    }//To store the contact name related to engagement internal teams 

        public HlTransactionWrapper(Engagement__c objEngagement, String strTransPrincipal)
        {
            this.objEngagement = objEngagement;
            this.strTransPrincipal = strTransPrincipal;
        }
    }
    /* End - Wrapper class for deal wrapper*/
    
    /* Start - Wrapper class for hl transaction wrapper */
    public class DealWrapper
    {   
        public Date dtDlDate                        {   get;set;    }// Variable used for getting Engagement start date.
        public String strDlProjectName              {   get;set;    }// Variable used for getting Engagement name
        public String strDlCompanyName              {   get;set;    }// Variable used for getting Company name
        public String strDlTransType                {   get;set;    }// Variable used for getting Engagement transaction type.
        public String strDlCompanyContact           {   get;set;    }// Variable used for getting Engagement_counterparty_contact name
        public String strDlStatus                   {   get;set;    }// Variable used for getting Engagement status 
        
        public DealWrapper(Date dtDlDate, String strDlProjectName, String strDlCompanyName, String strDlTransType, String strDlCompanyContact, String strDlStatus)
        {
            this.dtDlDate = dtDlDate;
            this.strDlProjectName = strDlProjectName;
            this.strDlCompanyName = strDlCompanyName;
            this.strDlTransType = strDlTransType;
            this.strDlCompanyContact = strDlCompanyContact;
            this.strDlStatus = strDlStatus;
        }
                
    }
    /*End - Wrapper class for hl transaction wrapper*/
    
    /*
        @MethodName : getCompany 
        @param      : NA
        @Description: method for getting company data. 
    */
    public Account getCompany()
    {
        String strAccountId = ApexPages.currentPage().getParameters().get('Id');
        
        if(!String.isBlank(strAccountId))
        {
            // getting the company data
            List<Account> lstAccount = [SELECT Id,
                                               Name,
                                               Phone,
                                               Website,
                                               EBITDA_MM__c, 
                                               Revenue_MM__c,
                                               BillingStreet,
                                               BillingState, 
                                               BillingPostalCode, 
                                               BillingCountry, 
                                               BillingCity, 
                                               Ownership,
                                               Total_Debt_MM__c,
                                               Total_Debt_EBITDA__c,
                                               Industry,
                                               Description
                                          FROM Account
                                         WHERE Id =: strAccountId LIMIT 1];
        
            if(!lstAccount.isEmpty())
            {
                strCompanyDesc = (lstAccount[0].Description!= null && lstAccount[0].Description.length() > 745)
                             ? lstAccount[0].Description.substring(0, 735) + '....'
                             : lstAccount[0].Description; 
                             
                return lstAccount[0];   
            }
            else
                return new Account();
        }
        else
            return new Account();
    }
    /*End */
    
    /*
        @MethodName : getCompanyRelationship 
        @param      : NA
        @Description: method for getting external relatioship . 
    */
    public List<ContactWrapper> getCompanyRelationship()
    {
        String recordTypeId = [SELECT Id  FROM RecordType  WHERE RecordType.DeveloperName = 'External_Contact'].Id;
        String strAccountId = ApexPages.currentPage().getParameters().get('Id');
    	List<ContactWrapper> lstContactWrapper = new List<ContactWrapper>();// List of ContactWrapper  
		
		Map<Id, Task> mapIdToLastTask = new Map<Id, Task>();
		Map<Id, Event> mapIdToLastEvent = new Map<Id, Event>();

		Map<Id, Integer> mapIdToTotalActivity = new Map<Id, Integer>();// Map of contact id to total no of activities

		if(String.isBlank(strAccountId) && String.isBlank(recordTypeId))
			return lstContactWrapper;

		for (AggregateResult ar : [	SELECT 	COUNT(Id) total,
							  				WhoId
									FROM 	Task
									WHERE 	(WhatId =: strAccountId
									OR 		AccountId =: strAccountId)
									AND 	IsClosed=True
									GROUP BY WhoId
						]){
            if (ar.get('WhoId')!=null){
                mapIdToTotalActivity.put((Id)ar.get('WhoId'), (Integer)ar.get('total'));    
            }
			
		}

		for (AggregateResult ar : [	SELECT 	COUNT(Id) total,
							  				WhoId
									FROM 	Event
									WHERE 	(WhatId =: strAccountId
									OR 		AccountId =: strAccountId)
									AND     (Event.ActivityDate < TODAY OR (Event.IsAllDayEvent=False AND Event.ActivityDateTime < :DateTime.Now()))
									GROUP BY WhoId
						]){
            if (ar.get('WhoId')!=null){
    			if (!mapIdToTotalActivity.keySet().contains((Id)ar.get('WhoId'))) {
    				mapIdToTotalActivity.put((Id)ar.get('WhoId'), (Integer)ar.get('total'));
    			}
    			else {
    				mapIdToTotalActivity.put((Id)ar.get('WhoId'), mapIdToTotalActivity.get((Id)ar.get('WhoId'))+(Integer)ar.get('total'));	
    			}
            }
		}
		Map <Integer, List<Id>> mapTotalActivityToUsers = new Map<Integer, List<Id>>();
		for (Id whoId: mapIdToTotalActivity.keySet()){
			if (!mapTotalActivityToUsers.keySet().contains(mapIdToTotalActivity.get(whoId))){
				mapTotalActivityToUsers.put(mapIdToTotalActivity.get(whoId), new List<Id>{whoId});
			}
			else {
				mapTotalActivityToUsers.get(mapIdToTotalActivity.get(whoId)).add(whoId);
			}
		}
		List<Integer> topTenGenerator = new List<Integer>();
		topTenGenerator.addAll(mapTotalActivityToUsers.keyset());
		topTenGenerator.sort();
		Set<Id> topTen = new Set<Id>();
		for (Integer ii = topTenGenerator.size()-1; ii >= 0 && topTen.size()<10; ii--){
			if (topTen.size()+mapTotalActivityToUsers.get(topTenGenerator[ii]).size()<=10){
				topTen.addAll(mapTotalActivityToUsers.get(topTenGenerator[ii]));
			}
			else {
				for (Integer jj = 0; jj < mapTotalActivityToUsers.get(topTenGenerator[ii]).size() && topTen.size()<10; jj++ ){
					topTen.add(mapTotalActivityToUsers.get(topTenGenerator[ii])[jj]);
				}
			}
		}

		for (Task t: [	SELECT 	Id,
								Subject,
							  	ActivityDate,
							  	WhoId,
							  	Who.Name,
							  	Who.Title
						FROM 	Task
						WHERE 	(WhatId =: strAccountId
						OR 		AccountId =: strAccountId)
						AND 	IsClosed=True
						AND 	WhoId IN :topTen
						ORDER BY ActivityDate DESC]){
			if (!mapIdToLastTask.keyset().contains(t.WhoId)) {
				mapIdToLastTask.put(t.WhoId, t);
			}
		}

		for (Event e: [	SELECT 	Id,
								Subject,
							  	ActivityDate,
							  	WhoId,
							  	Who.Name
						FROM 	Event
						WHERE 	(WhatId =: strAccountId
						OR 		AccountId =: strAccountId)
						AND     (Event.ActivityDate < TODAY OR (Event.IsAllDayEvent=False AND Event.ActivityDateTime < :DateTime.Now()))
						AND 	WhoId IN :topTen
						ORDER BY ActivityDate DESC]){
			if (!mapIdToLastEvent.keyset().contains(e.WhoId)) {
				mapIdToLastEvent.put(e.WhoId, e);
			}
		}

		Set <Id> AllIdsWithPastActivity = new Set<Id>();
        AllIdsWithPastActivity.addAll(mapIdToLastTask.keyset());
        AllIdsWithPastActivity.addAll(mapIdToLastEvent.keyset());
        Map <Id, Contact> idToContact = new Map <Id, Contact>();
        for (Contact c: [SELECT Id, Title FROM Contact WHERE Id in :AllIdsWithPastActivity]){
            idToContact.put(c.Id, c);
        }


        for (Id whoId: allIdsWithPastActivity){
            if (mapIdToLastTask.keySet().contains(whoId)&&mapIdToLastEvent.keySet().contains(whoId) ){
                if (mapIdToLastEvent.get(whoId).ActivityDate < mapIdToLastTask.get(whoId).ActivityDate){
                    lstContactWrapper.add(new ContactWrapper(mapIdToLastTask.get(whoId).Who.Name, idToContact.containsKey(whoId) ? idToContact.get(whoId).Title : '', mapIdToLastTask.get(whoId).Subject, mapIdToTotalActivity.get(whoId), mapIdToLastTask.get(whoId).ActivityDate));
                }
                else{
                	lstContactWrapper.add(new ContactWrapper(mapIdToLastEvent.get(whoId).Who.Name, idToContact.containsKey(whoId) ? idToContact.get(whoId).Title : '', mapIdToLastEvent.get(whoId).Subject, mapIdToTotalActivity.get(whoId), mapIdToLastEvent.get(whoId).ActivityDate));    
                }
            }
            else if (mapIdToLastTask.keySet().contains(whoId)){
                lstContactWrapper.add(new ContactWrapper(mapIdToLastTask.get(whoId).Who.Name, idToContact.containsKey(whoId) ? idToContact.get(whoId).Title : '', mapIdToLastTask.get(whoId).Subject, mapIdToTotalActivity.get(whoId), mapIdToLastTask.get(whoId).ActivityDate));
            }
            else{
            	lstContactWrapper.add(new ContactWrapper(mapIdToLastEvent.get(whoId).Who.Name, idToContact.containsKey(whoId) ? idToContact.get(whoId).Title : '', mapIdToLastEvent.get(whoId).Subject, mapIdToTotalActivity.get(whoId), mapIdToLastEvent.get(whoId).ActivityDate));    
            }
        }     
        lstContactWrapper.sort();
		return  lstContactWrapper;
    }
    /*End */
    
    /*
        @MethodName : getHLExternalRelationship 
        @param      : CompanyId and RecordTypeName
        @Description: method for getting active relatioship records. 
    */
    public List<ContactWrapper> getHLRelationship(){
    	String recordTypeId = [SELECT Id  FROM RecordType  WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
        String strAccountId = ApexPages.currentPage().getParameters().get('Id');
    	List<ContactWrapper> lstContactWrapper = new List<ContactWrapper>();// List of ContactWrapper  

		Map<Id, Task> mapIdToLastTask = new Map<Id, Task>();
		Map<Id, Event> mapIdToLastEvent = new Map<Id, Event>();

		Map<Id, Integer> mapIdToTotalActivity = new Map<Id, Integer>();// Map of contact id to total no of activities

		if(String.isBlank(strAccountId) && String.isBlank(recordTypeId))
			return lstContactWrapper;

		for (AggregateResult ar : [	SELECT 	COUNT(Id) total,
							  				OwnerId
									FROM 	Task
									WHERE 	(WhatId =: strAccountId
									OR 		AccountId =: strAccountId)
									AND 	IsClosed=True
									GROUP BY OwnerId
						]){
            if (ar.get('OwnerId')!=null){
			    mapIdToTotalActivity.put((Id)ar.get('OwnerId'), (Integer)ar.get('total'));	
            }
		}

		for (AggregateResult ar : [	SELECT 	COUNT(Id) total,
							  				OwnerId
									FROM 	Event
									WHERE 	(WhatId =: strAccountId
									OR 		AccountId =: strAccountId)
									AND     (Event.ActivityDate < TODAY OR (Event.IsAllDayEvent=False AND Event.ActivityDateTime < :DateTime.Now()))
									GROUP BY OwnerId
						]){
            if (ar.get('OwnerId')!=null){
    			if (!mapIdToTotalActivity.keySet().contains((Id)ar.get('OwnerId'))) {
    				mapIdToTotalActivity.put((Id)ar.get('OwnerId'), (Integer)ar.get('total'));
    			}
    			else {
    				mapIdToTotalActivity.put((Id)ar.get('OwnerId'), mapIdToTotalActivity.get((Id)ar.get('OwnerId'))+(Integer)ar.get('total'));	
    			}
            }
		}
		Map <Integer, List<Id>> mapTotalActivityToUsers = new Map<Integer, List<Id>>();
		for (Id ownerId: mapIdToTotalActivity.keySet()){
			if (!mapTotalActivityToUsers.keySet().contains(mapIdToTotalActivity.get(ownerId))){
				mapTotalActivityToUsers.put(mapIdToTotalActivity.get(ownerId), new List<Id>{ownerId});
			}
			else {
				mapTotalActivityToUsers.get(mapIdToTotalActivity.get(ownerId)).add(ownerId);
			}
		}
		List<Integer> topTenGenerator = new List<Integer>();
		topTenGenerator.addAll(mapTotalActivityToUsers.keyset());
		topTenGenerator.sort();
		Set<Id> topTen = new Set<Id>();
		for (Integer ii = topTenGenerator.size()-1; ii >= 0 && topTen.size()<10; ii--){
			if (topTen.size()+mapTotalActivityToUsers.get(topTenGenerator[ii]).size()<=10){
				topTen.addAll(mapTotalActivityToUsers.get(topTenGenerator[ii]));
			}
			else {
				for (Integer jj = 0; jj < mapTotalActivityToUsers.get(topTenGenerator[ii]).size() && topTen.size()<10; jj++ ){
					topTen.add(mapTotalActivityToUsers.get(topTenGenerator[ii])[jj]);
				}
			}
		}

		for (Task t: [	SELECT 	Id,
								Subject,
							  	ActivityDate,
							  	OwnerId,
							  	Owner.Name,
							  	Owner.Title
						FROM 	Task
						WHERE 	(WhatId =: strAccountId
						OR 		AccountId =: strAccountId)
						AND 	IsClosed=True
						AND 	OwnerId IN :topTen
						ORDER BY ActivityDate DESC]){
			if (!mapIdToLastTask.keyset().contains(t.OwnerId)) {
				mapIdToLastTask.put(t.OwnerId, t);
			}
		}

		for (Event e: [	SELECT 	Id,
								Subject,
							  	ActivityDate,
							  	OwnerId,
							  	Owner.Name,
							  	Owner.Title
						FROM 	Event
						WHERE 	(WhatId =: strAccountId
						OR 		AccountId =: strAccountId)
						AND     (Event.ActivityDate < TODAY OR (Event.IsAllDayEvent=False AND Event.ActivityDateTime < :DateTime.Now()))
						AND 	OwnerId IN :topTen
						ORDER BY ActivityDate DESC]){
			if (!mapIdToLastEvent.keyset().contains(e.OwnerId)) {
				mapIdToLastEvent.put(e.OwnerId, e);
			}
		}

		Set <Id> AllIdsWithPastActivity = new Set<Id>();
        AllIdsWithPastActivity.addAll(mapIdToLastTask.keyset());
        AllIdsWithPastActivity.addAll(mapIdToLastEvent.keyset());
        for (Id ownerId: allIdsWithPastActivity){
            if (mapIdToLastTask.keySet().contains(ownerId)&&mapIdToLastEvent.keySet().contains(ownerId) ){
                if (mapIdToLastEvent.get(ownerId).ActivityDate < mapIdToLastTask.get(ownerId).ActivityDate){
                    lstContactWrapper.add(new ContactWrapper(mapIdToLastTask.get(ownerId).Owner.Name, mapIdToLastTask.get(ownerId).Owner.Title, mapIdToLastTask.get(ownerId).Subject, mapIdToTotalActivity.get(ownerId), mapIdToLastTask.get(ownerId).ActivityDate));
                }
                else{
                	lstContactWrapper.add(new ContactWrapper(mapIdToLastEvent.get(ownerId).Owner.Name, mapIdToLastEvent.get(ownerId).Owner.Title, mapIdToLastEvent.get(ownerId).Subject, mapIdToTotalActivity.get(ownerId), mapIdToLastEvent.get(ownerId).ActivityDate));    
                }
            }
            else if (mapIdToLastTask.keySet().contains(ownerId)){
                lstContactWrapper.add(new ContactWrapper(mapIdToLastTask.get(ownerId).Owner.Name, mapIdToLastTask.get(ownerId).Owner.Title, mapIdToLastTask.get(ownerId).Subject, mapIdToTotalActivity.get(ownerId), mapIdToLastTask.get(ownerId).ActivityDate));
            }
            else{
            	lstContactWrapper.add(new ContactWrapper(mapIdToLastEvent.get(ownerId).Owner.Name, mapIdToLastEvent.get(ownerId).Owner.Title, mapIdToLastEvent.get(ownerId).Subject, mapIdToTotalActivity.get(ownerId), mapIdToLastEvent.get(ownerId).ActivityDate));    
            }
        }     
        lstContactWrapper.sort();
		return  lstContactWrapper;
	}
    /*End */
    
    /*
        @MethodName : getRecentActivities 
        @param      : NA
        @Description: method for getting activities of company. 
    */
    public List<RecentActivityWrapper> getRecentActivities()
    {
        Id strAccountId = ApexPages.currentPage().getParameters().get('Id');//Set of related Company ids
        List<RecentActivityWrapper> lstRecentActivityWrapper = new List<RecentActivityWrapper>();// List of RecentActivityWrapper
        Set<Id> setOwnerId = new Set<Id>();//Set of activities owner id
        Map<Id, Contact> mapOwnerIdToContact = new Map<Id, Contact>();//Map ownerid to contact
        Map<Id, Task> mapIdToTask = new Map<Id, Task>();
        Map<Id, Event> mapIdToEvent = new Map<Id, Event>();

        if(String.isBlank(strAccountId))
            return lstRecentActivityWrapper;
            
        //fetching all the related activities related to operating company
        Account objAccount = [SELECT Id,
                                       (SELECT Id,
                                               Subject,
                                               ActivityDate,
                                               Owner.Name,
                                               Owner.Title,
                                               OwnerId,
                                               Who.Name
                                          FROM Tasks 
                                         WHERE ActivityDate > LAST_YEAR
                                      ORDER BY ActivityDate DESC),
                                        (SELECT Id,
                                               Subject,
                                               ActivityDate,
                                               Owner.Name,
                                               Owner.Title,
                                               OwnerId,
                                               Who.Name  
                                          FROM Events
                                         WHERE ActivityDate > LAST_YEAR
                                      ORDER BY ActivityDate DESC)   
                                FROM Account
                               WHERE Id =:strAccountId];

            // Iterating on open activities for adding object of RecentActivityWrapper into list                       
        for(Task objTask : objAccount.Tasks)
        {
            mapIdToTask.put(objTask.id, objTask); 
        }
            
            // Iterating on closed activities for adding object of RecentActivityWrapper into list   
        for(Event objEvent : objAccount.Events)
        {
            mapIdToEvent.put(objEvent.id, objEvent);
        }


        for (Contact c: [SELECT Id,
                                (SELECT Id,
                                        Subject,
                                        ActivityDate,
                                        Owner.Name,
                                        Owner.Title,
                                        OwnerId,
                                        Who.Name
                                FROM Tasks 
                                WHERE ActivityDate > LAST_YEAR
                                ORDER BY ActivityDate DESC),
                                (SELECT Id,
                                        Subject,
                                        ActivityDate,
                                        Owner.Name,
                                        Owner.Title,
                                        OwnerId,
                                        Who.Name  
                                FROM Events
                                WHERE ActivityDate > LAST_YEAR
                                ORDER BY ActivityDate DESC)   
                        FROM Contact
                        WHERE AccountId =:strAccountId]){
            for(Task objTask : c.Tasks)
            {
                if (!mapIdToTask.keySet().contains(objTask.id)){
                    mapIdToTask.put(objTask.id, objTask);
                }
                
            }
            
            // Iterating on closed activities for adding object of RecentActivityWrapper into list   
            for(Event objEvent : c.Events)
            {
                if (!mapIdToEvent.keySet().contains(objEvent.id)){
                    mapIdToEvent.put(objEvent.id, objEvent);
                }
                
            }
        }
        for (Task objTask: mapIdToTask.values()){
            lstRecentActivityWrapper.add(new RecentActivityWrapper( objTask.ActivityDate,
                                                                    objTask.Subject,
                                                                    objTask.Owner.Name,
                                                                    objTask.Owner.Title, 
                                                                    objTask.Who.Name));
        }
        for (Event objEvent: mapIdToEvent.values()){
            lstRecentActivityWrapper.add(new RecentActivityWrapper( objEvent.ActivityDate,
                                                                    objEvent.Subject,
                                                                    objEvent.Owner.Name,
                                                                    objEvent.Owner.Title, 
                                                                    objEvent.Who.Name));
        }
        lstRecentActivityWrapper.sort();
        return lstRecentActivityWrapper;                                        
    }
    /*End */

    /*
        @MethodName : getCompany 
        @param      : NA
        @Description: method for getting company data. 
    */
    public List<OpportunityWrapper> getOpenOpportunities()
    {
        List<OpportunityWrapper> lstOpportunityWrapper = new List<OpportunityWrapper>();// List of OpportunityWrapper
        
        if(setAccountId.isEmpty())  
            return lstOpportunityWrapper;
        //fetching all the transaction record ralted to the operating company



        Set<Id> relatedOpportunities = new Set<Id>();
        for (Opportunity_Client_Subject__c relOp:     [SELECT Opportunity__c
                                                FROM Opportunity_Client_Subject__c
                                                WHERE Client_Subject__c IN : setAccountId
                                                ]){
            relatedOpportunities.add(relOp.Opportunity__c);
        }

        for(Opportunity__c objOpportunity : [   SELECT Id,
                                                    Pitch_Date__c,
                                                    Job_Type__c,
                                                    Client__r.Name,
                                                    Stage__c,
                                                    Total_Fee__c,
                                                    Estimated_Engagement_Date__c,
                                                    (SELECT Id,
                                                            Contact__r.Name
                                                    FROM Opportunity_Internal_Teams__r
                                                    WHERE Principal__c = true
                                                    ORDER BY Contact__r.Name)  
                                                FROM Opportunity__c   
                                                WHERE Id IN :relatedOpportunities
                                                AND Closed__c=False
                                                ORDER BY Estimated_Engagement_Date__c DESC])
        {
            String strPricipals = '';      
            for(Opportunity_Internal_Team__c objOIT : objOpportunity.Opportunity_Internal_Teams__r)
            {
                strPricipals += ', ' + objOIT.Contact__r.Name;
            }
            strPricipals = strPricipals.replaceFirst(',', '');
            lstOpportunityWrapper.add(new OpportunityWrapper(objOpportunity, strPricipals));
        }
        
        return lstOpportunityWrapper;
    } 
    /*End*/

    /*
        @MethodName : getTransInvolvement 
        @param      : NA
        @Description: method for getting transaction data related to the company. 
    */
    public List<HlTransactionWrapper> getTransInvolvement()
    {
        List<HlTransactionWrapper> lstHlTransactionWrapper = new List<HlTransactionWrapper>();//List of HlTransactionWrapper
        
        if(setAccountId.isEmpty())
            return lstHlTransactionWrapper;
        
        //getting engagement records related to operating company   
        for(Engagement__c objEngagement : [SELECT Id,
                                                  Start_Date__c,
                                                  Name,
                                                  Job_Type__c,
                                                  Status__c,
                                                  Active__c,
                                                  (SELECT Id,
                                                          Contact__r.Name
                                                     FROM Engagement_Teams__r
                                                    WHERE Principal__c = true
                                                 ORDER BY Contact__r.Name)
                                             FROM Engagement__c
                                            WHERE Client__c IN : setAccountId
                                               OR Subject__c IN : setAccountId])
        {
            String strPrincipal = '';    
            //Iterating on Engagement_Internal_Team__c to get all the contact name 
            for(Engagement_Internal_Team__c objEIT : objEngagement.Engagement_Teams__r)
            {
                strPrincipal += ', ' + objEIT.Contact__r.Name;
            }
            strPrincipal = strPrincipal.replaceFirst(',', '');
            
            lstHlTransactionWrapper.add(new HlTransactionWrapper(objEngagement, strPrincipal));
        }                                                   
        return lstHlTransactionWrapper;
    } 
    /*End */
    
    /*
        @MethodName : getDealsData 
        @param      : NA
        @Description: method for getting deal data related to the company. 
    */
    public List<DealWrapper> getDealsData()
    {
        List<DealWrapper> lstDealWrapper = new List<DealWrapper>();// List of lstDealWrapper
        
        if(setAccountId.isEmpty())
            return lstDealWrapper;  
        
        //Iterating on Engagement_Counterparty__c for getting role
        for(Engagement_Counterparty__c objEC : [SELECT Id,
                                                       Role__c,
                                                       Engagement__r.Start_Date__c,
                                                       Engagement__r.Name,
                                                       Engagement__r.Job_Type__c,
                                                       Company__r.Name,
                                                       Status__c,
                                                       (SELECT Id,
                                                               Contact__r.Name
                                                          FROM Engagement_Counterparty_Contacts__r
                                                         WHERE Type__c = 'Primary' 
                                                      ORDER BY CreatedDate DESC LIMIT 1)
                                                  FROM Engagement_Counterparty__c
                                                 WHERE Company__c IN : setAccountId])
        {
            lstDealWrapper.add(new DealWrapper(objEC.Engagement__r.Start_Date__c, 
                                               objEC.Engagement__r.Name,
                                               objEc.Company__r.Name,
                                               objEC.Engagement__r.Job_Type__c,
                                               (objEC.Engagement_Counterparty_Contacts__r.size() > 0) 
                                                ? objEC.Engagement_Counterparty_Contacts__r[0].Contact__r.Name : '',
                                                objEC.Status__c));
        }
            
        return lstDealWrapper;
    }
    /*End */
    
    /*
        @MethodName : getAccountIds 
        @param      : NA
        @Description: method for getting company ids related to the operating company. 
    */
    private Set<Id> getAccountIds(String strAccountId)
    {
        Set<Id> setAccountId = new Set<Id>{strAccountId};// Set of all child and parent company id related to operating company 
        if(String.isBlank(strAccountId) || strAccountId == null)
            return setAccountId;
            
        Account objAccount = [SELECT Id, 
                                     Ultimate_Parent__c 
                                FROM Account 
                               WHERE Id =: strAccountId];
        
        if(objAccount.Ultimate_Parent__c !=null)
        {
            setAccountId.add(objAccount.Ultimate_Parent__c);
            for(Account objAcc : [SELECT Id,
                                         Ultimate_Parent__c
                                    FROM Account
                                   WHERE Ultimate_Parent__c =: objAccount.Ultimate_Parent__c])
            {
                setAccountId.add(objAcc.Id);
            }
        }   
        else
        {
            for(Account objAcc : [SELECT Id,
                                         Ultimate_Parent__c
                                    FROM Account
                                   WHERE Ultimate_Parent__c =: strAccountId])
            {
                setAccountId.add(objAcc.Id);
            }
        }
        return setAccountId;
    }
    /*End */
}