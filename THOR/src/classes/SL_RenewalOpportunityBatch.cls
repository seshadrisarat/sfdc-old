/**
*  ClassName      : SL_RenewalOpportunityBatch
*  JIRATicket     : THOR-42
*  CreatedOn      : 23/SEP/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the batch class to Create Renewal Opportunity records from New Lease Opportunity records
*/
global class SL_RenewalOpportunityBatch implements Database.Batchable<Sobject>
{
	/* START : Global variables */
    public string strQuery = ''; 
    public Date FAIRMARKET_NUMBEROFDAYS;
	public Date FAIRMARKET_RENEWAL_NUMBEROFDAYS;
	public Date RENT_STABILIZED_NUMBEROFDAYS;
	public Date RENT_STABILIZED_RENEWAL_NUMBEROFDAYS;
	public String FAIR_MARKET;
	public String FAIR_MARKET_RENEWAL;
	public String RENT_STABILIZED;
	public String RENT_STABILIZED_RENEWAL;
	public Id NEW_LEASE_RECORDTYPE_ID;
    /* END : Global variables */

    
    /* Start : Constructor */
    public SL_RenewalOpportunityBatch(String strQuery,Id NEW_LEASE_RECORDTYPE_ID ,Date FAIRMARKET_NUMBEROFDAYS, Date FAIRMARKET_RENEWAL_NUMBEROFDAYS, 
                                      Date RENT_STABILIZED_NUMBEROFDAYS,Date RENT_STABILIZED_RENEWAL_NUMBEROFDAYS, String FAIR_MARKET, String FAIR_MARKET_RENEWAL, 
                                      String RENT_STABILIZED,String RENT_STABILIZED_RENEWAL)
    {
        this.strQuery = strQuery;
        this.FAIRMARKET_NUMBEROFDAYS = FAIRMARKET_NUMBEROFDAYS;
		this.FAIRMARKET_RENEWAL_NUMBEROFDAYS = FAIRMARKET_RENEWAL_NUMBEROFDAYS;
		this.RENT_STABILIZED_NUMBEROFDAYS = RENT_STABILIZED_NUMBEROFDAYS;
		this.RENT_STABILIZED_RENEWAL_NUMBEROFDAYS = RENT_STABILIZED_RENEWAL_NUMBEROFDAYS;
		this.FAIR_MARKET = FAIR_MARKET;
		this.FAIR_MARKET_RENEWAL = FAIR_MARKET_RENEWAL;
		this.RENT_STABILIZED = RENT_STABILIZED;
		this.RENT_STABILIZED_RENEWAL = RENT_STABILIZED_RENEWAL;
		this.NEW_LEASE_RECORDTYPE_ID = NEW_LEASE_RECORDTYPE_ID;
    }
    /* End : Constructor */
     
    
	/*
    	* MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns list of Lease records to execute method
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	return Database.getQueryLocator(strQuery);
    }
    
    
    /*
    	* MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Opportunity> lstOpportunity
        * Description  : Processes Lease records returned by start method
    */
    global void execute(Database.BatchableContext BC, List<Opportunity> lstOpportunity)
    {
    	///Query Renewal Opportunity record type id
    	Id RENEWAL_LEASE_RECORDTYPE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND  DeveloperName = 'Renewal_Lease_Opportunity'].Id;
    	Map<Id,Opportunity> mapNewLeaseOppId_RenewalOpportunity = new Map<Id,Opportunity>();
    	Map<String,String> mapNewLeaseField_RenewalLeaseField = new Map<String,String>();
    	sObject objSobjectRenewalOpportunity = new Opportunity();
    	Map<Id,List<Contact_Role__c>> mapNewLeaseOppId_LstContactRole = new Map<Id,List<Contact_Role__c>>();
    	List<Contact_Role__c> lstContactRoleToUpdate = new List<Contact_Role__c>();
    	
    	///Create map of new lease field api name to new renewal opportunity field api name
    	for(SL_RenewalBatchMapping__c objRenewalToNewLease:[SELECT Name, Lease_Opportunity_Field_Api_Name__c 
                                                          FROM SL_RenewalBatchMapping__c])
        {
        	mapNewLeaseField_RenewalLeaseField.put(objRenewalToNewLease.Lease_Opportunity_Field_Api_Name__c,objRenewalToNewLease.Name);
        }
        
        /* START: Added on : 30/10/2014 */
        Set<String> setOfParentLeaseOfNewLeaseOpportunity = new Set<String>(); //!< Used to store parent Lease to get End date for mapping
        Map<Id, Date> mapLeaseIdToEndDate = new Map<Id, Date>(); //!< Used to store Lease with its end date for mapping 
        
        for(Opportunity objOpportunity : lstOpportunity) 
        {
        	if(objOpportunity.Lease__c != null)
        		setOfParentLeaseOfNewLeaseOpportunity.add(objOpportunity.Lease__c);
        }
        
        for(Lease__c objLease : [select Id, End_Date__c from Lease__c where Id IN : setOfParentLeaseOfNewLeaseOpportunity])
        {
        	mapLeaseIdToEndDate.put(objLease.Id, objLease.End_Date__c);
        }
        /* END: Added on : 30/10/2014*/
        
    	///Create data for Renewal Opportunity
    	for(Opportunity objNewLeaseOpportunity:lstOpportunity)
    	{
			sObject objSobjectNewLeaseOpportunity = objNewLeaseOpportunity;
			objSobjectRenewalOpportunity = new Opportunity();
			
			/* START: Added on : 30/10/2014*/
			
			if(objNewLeaseOpportunity.Lease__c != null && mapLeaseIdToEndDate.containsKey(objNewLeaseOpportunity.Lease__c) && 
			   mapLeaseIdToEndDate.get(objNewLeaseOpportunity.Lease__c) != null)
			{
				objSobjectRenewalOpportunity.put('CloseDate',mapLeaseIdToEndDate.get(objNewLeaseOpportunity.Lease__c).addDays(-1));
			}
			
			if(objNewLeaseOpportunity.Lease_End_Date__c != null)
				objSobjectRenewalOpportunity.put('Lease_Start_date__c',objNewLeaseOpportunity.Lease_End_Date__c.addDays(1));
			
			objSobjectRenewalOpportunity.put('StageName','Pending Pricing');
			objSobjectRenewalOpportunity.put('Previous_Opportunity__c', objNewLeaseOpportunity.Id);
			/* END: Added on : 30/10/2014*/
			
			objSobjectRenewalOpportunity.put('Name', 'Renewal '+ objNewLeaseOpportunity.Name);
			objSobjectRenewalOpportunity.put('RecordTypeId',RENEWAL_LEASE_RECORDTYPE_ID);
			
			///Map fields from new lease to renewal opportunity
			for(String objString:mapNewLeaseField_RenewalLeaseField.keyset())
			{
				if(objSobjectNewLeaseOpportunity.get(objString) != null)
					objSobjectRenewalOpportunity.put(mapNewLeaseField_RenewalLeaseField.get(objString),objSobjectNewLeaseOpportunity.get(objString));
			}
			mapNewLeaseOppId_RenewalOpportunity.put(objNewLeaseOpportunity.Id, (Opportunity)objSobjectRenewalOpportunity);
    	}
    	
    	 ///Create map of  New lease Opportunity id to List of associated Contact role records
        for(Contact_Role__c objContactRole:[SELECT Id,Opportunity__c
                                            FROM Contact_Role__c
                                            WHERE Opportunity__c IN:lstOpportunity])
        {
            if(!mapNewLeaseOppId_LstContactRole.containskey(objContactRole.Opportunity__c))
                mapNewLeaseOppId_LstContactRole.put(objContactRole.Opportunity__c, new List<Contact_Role__c>{objContactRole});
            else if(mapNewLeaseOppId_LstContactRole.containskey(objContactRole.Opportunity__c) 
                     && mapNewLeaseOppId_LstContactRole.get(objContactRole.Opportunity__c) != null)
                mapNewLeaseOppId_LstContactRole.get(objContactRole.Opportunity__c).add(objContactRole);
        } 
        
        if(!mapNewLeaseOppId_RenewalOpportunity.isEmpty())
        	database.insert(mapNewLeaseOppId_RenewalOpportunity.values(),false);
        
        system.debug('----------mapNewLeaseOppId_RenewalOpportunity--->>>>>>>>>>>>>>'+mapNewLeaseOppId_RenewalOpportunity);
        
    	///Associate Contact role records to renewal opportunity
        for(Id objNewLeaseOpportunityId:mapNewLeaseOppId_LstContactRole.keyset())
        {
            if(mapNewLeaseOppId_LstContactRole.get(objNewLeaseOpportunityId) != null)
            {
                for(Contact_Role__c objContactRole:mapNewLeaseOppId_LstContactRole.get(objNewLeaseOpportunityId))
                {
                    if(mapNewLeaseOppId_RenewalOpportunity.containskey(objNewLeaseOpportunityId) && mapNewLeaseOppId_RenewalOpportunity.get(objNewLeaseOpportunityId) != null)
                    {
                        objContactRole.Opportunity__c = mapNewLeaseOppId_RenewalOpportunity.get(objNewLeaseOpportunityId).Id;
                        lstContactRoleToUpdate.add(objContactRole);
                    }
                }
            }
        }
        
        system.debug('----------lstContactRoleToUpdate--->>>>>>>>>>>>>>'+lstContactRoleToUpdate);
        
        if(!lstContactRoleToUpdate.isEmpty())
        {
            database.update(lstContactRoleToUpdate,false);
        }
    }
    
    
    /*
    	* MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        ///Does nothing
    }
}