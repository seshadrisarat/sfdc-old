/** 
* \author Wes Weingartner
* \date 09/10/2013
* \brief Credit Request Handler should update the Funding Source details when a Credit Request is approved.
*/

public without sharing class SL_Credit_Requests_Handler
{ 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean CRHandlerHasRun = false;

    public SL_Credit_Requests_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    //public void OnBeforeInsert(List<Credit_Requests__c> newCR){ }
    
    public void OnAfterInsert(Map<Id,Credit_Requests__c> newMap)
    {
        if(!CRHandlerHasRun)
        {
            CRHandlerHasRun = true;
            updateFundingSources(newMap);
        }
        updateAccountExposure(newMap);
    }
    
    public void OnAfterUpdate(Map<Id, Credit_Requests__c> newMap, Map<Id, Credit_Requests__c> oldMap)
    {
    	Map<Id, Credit_Requests__c> mapIdToCR = new Map<Id, Credit_Requests__c>();
        if(!CRHandlerHasRun)
        {
            CRHandlerHasRun = true;
            updateFundingSources(newMap);
        }
        
        for(Credit_Requests__c objCR : newMap.values())
        {
        	if(objCR.Status__c != oldMap.get(objCR.Id).Status__c)
        	{
        		mapIdToCR.put(objCR.Id, objCR);
        	}
        }
    
        if(!mapIdToCR.isEmpty())
        	updateAccountExposure(mapIdToCR);    
    }
    
    
    /*!
        * MethodName : onAfterDelete
        * param      : Map of Credit Request old
        * Description: This method invoked from the trigger on After delete of the records.
    *//*
    public void onAfterDelete(Map<Id, Credit_Requests__c> mapCROld)
    {
        updateAccountExposure(mapCROld);   
    }*/
    /* End */
    
    
    /*!
        * MethodName : onBeforeDelete
        * param      : Map of Credit Request old
        * Description: This method invoked from the trigger on After delete of the records.
    */
    public void onBeforeDelete(Map<Id, Credit_Requests__c> mapCROld)
    {
        updateAccountExposure(mapCROld);   
    }
    /* End */
    
    /*!
        * MethodName : onAfterUnDelete
        * param      : Map of Credit Request new
        * Description: This method invoked from the trigger on After undelete of the records.
    */
    public void onAfterUnDelete(Map<Id, Credit_Requests__c> mapCRNew)
    {
        updateAccountExposure(mapCRNew);
    }
    /* End */
    
    /*
    *	TicketName : FAEF-23
    *	CreatedBy  : Praful
    *	CreatedOn  : 28/01/14
    *	MethodName : updateAccountExposure
    *	Params	   : Map of Credit Request new
    *	Description: This is stateless method invoked from (AfterInsert/AfterUpdate/AfterDelete/AfterUndelete methods) used to update the AccountExposure on Account  
    */
    public void updateAccountExposure(Map<Id, Credit_Requests__c> mapCRNew)
    {
    	Set<Id> setAccountIds = new Set<Id>();
    	Set<Id> setBacklogExpAcctIds = new Set<Id>();// Get a set of Backlog Exposure Account Ids
		Set<Id> setPendingExpAcctIds = new Set<Id>();// Get a set of pending Exposure Account Ids
    	Set<String> setScheduleStages = new Set<String>{'Booked with Follow ups', 'Booked', 'Cancelled', 'Declined', 'Withdrawn'};
    	Map<Id, Decimal> mapAcctIdToBackLogTotal = new Map<Id, Decimal>();// Get a map of AccountId to BacklogTotal
		Map<Id, Decimal> mapAcctIdToPendingTotal = new Map<Id, Decimal>();// Get a map of AccountId to PendingTotal
		Map<Id, Account> mapAccountToUpdate = new Map<Id, Account>(); 
        set<Id> setFundingSrcIdsDeclinedStatus = new set<Id>();
    	 
        for (Credit_Requests__c objCR : [SELECT Id, Funding_Source__r.Letter_of_Intent__r.Account__c
								         FROM Credit_Requests__c
								         WHERE Id IN : mapCRNew.keySet()])
        {
            setAccountIds.add(objCR.Funding_Source__r.Letter_of_Intent__r.Account__c);
        
        }
        
        // Get all the funding sources where AccId in above set and RecordType is Internal
        for (Funding_Source__c objFS : [SELECT Id, Account__c, Status__c 
        								FROM Funding_Source__c 
        								WHERE Letter_of_Intent__r.Account__c IN : setAccountIds AND RecordType.DeveloperName = : 'Internal'])
        {
        	if(objFS.Status__c == 'Approved')
				setBacklogExpAcctIds.add(objFS.Account__c);
			else if(objFS.Status__c !='Approved' && objFS.Status__c!='Declined' && objFS.Status__c!='Withdrawn')
				setPendingExpAcctIds.add(objFS.Account__c);
            else 
                setFundingSrcIdsDeclinedStatus.add(objFS.Account__c);   
        }
        
        // Get all the Schedules for mapAcctIdToBackLogTotal where Stages not in strScheduleStages and Status is Approved
        for (Schedule__c objSchedule : [SELECT Id, Total_Equipment_Cost__c, Letter_of_Intent__r.Account__c 
							  			FROM Schedule__c 
							  			WHERE Stage__c NOT IN : setScheduleStages 
							  			AND Letter_of_Intent__r.Account__c IN : setBacklogExpAcctIds 
							  			AND Funding_Source__r.RecordType.DeveloperName = : 'Internal' 
							  			AND Funding_Source__r.Status__c = : 'Approved' ORDER BY Letter_of_Intent__r.Account__c])
		{
			if(!mapAcctIdToBackLogTotal.containsKey(objSchedule.Letter_of_Intent__r.Account__c))
				mapAcctIdToBackLogTotal.put(objSchedule.Letter_of_Intent__r.Account__c, 0.0);
				
			mapAcctIdToBackLogTotal.put(objSchedule.Letter_of_Intent__r.Account__c, mapAcctIdToBackLogTotal.get(objSchedule.Letter_of_Intent__r.Account__c) + objSchedule.Total_Equipment_Cost__c);
		}
		
		// Get all the Schedules for mapAcctIdToPendingTotal where Stages not in strScheduleStages and Status is not Approved
		for (Schedule__c objSchedule : [SELECT Id, Total_Equipment_Cost__c, Letter_of_Intent__r.Account__c 
							  			FROM Schedule__c 
							  			WHERE Stage__c NOT IN : setScheduleStages 
							  			AND Letter_of_Intent__r.Account__c IN : setPendingExpAcctIds 
							  			AND Funding_Source__r.RecordType.DeveloperName = : 'Internal' 
							  			AND Funding_Source__r.Status__c != : 'Approved' 
                                        AND Funding_Source__r.Status__c!='Declined' 
                                        AND Funding_Source__r.Status__c!='Withdrawn' ORDER BY Letter_of_Intent__r.Account__c])
		{
			if(!mapAcctIdToPendingTotal.containsKey(objSchedule.Letter_of_Intent__r.Account__c))
				mapAcctIdToPendingTotal.put(objSchedule.Letter_of_Intent__r.Account__c, 0.0);
			
			mapAcctIdToPendingTotal.put(objSchedule.Letter_of_Intent__r.Account__c, mapAcctIdToPendingTotal.get(objSchedule.Letter_of_Intent__r.Account__c) + objSchedule.Total_Equipment_Cost__c);
		}
		
		// Get a mapAccountToUpdate from mapAcctIdToBackLogTotal
		for(Id accountId : mapAcctIdToBackLogTotal.keySet())
		{
			Account objAccount = new Account (Id = accountId, FAEF_Backlog_Exposure__c = mapAcctIdToBackLogTotal.get(accountId),FAEF_Pending_Exposure__c=NULL);//
			mapAccountToUpdate.put(accountId, objAccount);
		}
		
		// Get a mapAccountToUpdate from mapAcctIdToPendingTotal
		for(Id accountId : mapAcctIdToPendingTotal.keySet())
		{
			// If AccountId is not present in mapAccountToUpdate then create new mapAccountToUpdate for PendingTotal
			if(!mapAccountToUpdate.containsKey(accountId))
			{   
				Account objAccount = new Account (Id = accountId, FAEF_Pending_Exposure__c = mapAcctIdToPendingTotal.get(accountId),FAEF_Backlog_Exposure__c=NULL );
				mapAccountToUpdate.put(accountId, objAccount);	
			}
			else// If AccountId is present in mapAccountToUpdate then get account and add PendingTotal to FAEF_Pending_Exposure__c
			{
				Account objAccount = mapAccountToUpdate.get(accountId);
				objAccount.FAEF_Pending_Exposure__c = mapAcctIdToPendingTotal.get(accountId);    
				mapAccountToUpdate.put(accountId, objAccount);
			}
		}

        for(Schedule__c objSchedule : [SELECT Id, Total_Equipment_Cost__c, Letter_of_Intent__r.Account__c 
                                        FROM Schedule__c 
                                        WHERE Stage__c NOT IN : setScheduleStages 
                                        AND Letter_of_Intent__r.Account__c IN : setFundingSrcIdsDeclinedStatus 
                                        AND Funding_Source__r.RecordType.DeveloperName = : 'Internal' 
                                        AND Funding_Source__r.Status__c != : 'Approved' 
                                        AND (Funding_Source__r.Status__c=:'Declined' 
                                        OR Funding_Source__r.Status__c=:'Withdrawn') ORDER BY Letter_of_Intent__r.Account__c])
        {
            if(!mapAccountToUpdate.containsKey(objSchedule.Letter_of_Intent__r.Account__c))
            {
                mapAccountToUpdate.put(objSchedule.Letter_of_Intent__r.Account__c , new Account(Id=objSchedule.Letter_of_Intent__r.Account__c,
                                                                                                FAEF_Pending_Exposure__c=NULL,
                                                                                                FAEF_Backlog_Exposure__c=NULL));
            }   
        }


		
		//----------DML-----------
		if(!mapAccountToUpdate.isEmpty())
			update mapAccountToUpdate.values();
    }
    /* End */
	
    public void updateFundingSources(Map<Id,Credit_Requests__c> newMap)
    {
        // get a list of funding sources for these credit requests.
        Set<Id> fsIds = new Set<Id>();
        
        for (Credit_Requests__c cr : newMap.values())
        {
            fsIds.add(cr.Funding_Source__c);
        }
        
        // Get a list of all the credit requests in this trigger.
        Map<Id,Credit_Requests__c> allCRs = new Map<Id,Credit_Requests__c>([SELECT  Id, Collateral__c, Funding_Source__c, Funding_Source__r.Status__c,
                                                                        Financial_Product__c, Decision_Date__c, Status__c, Approved_Spread__c,Proposed_Spread__c
                                                                        FROM Credit_Requests__c
                                                                        WHERE Funding_Source__c IN:fsIds
                                                                       ]);
                                                                       
        // Get a map of all the funding sources that might be needed in this trigger.
        Map<Id,Funding_Source__c> allFSs = new Map<Id,Funding_Source__c>([SELECT Id, Collateral__c,Financial_Product__c,Approved_Spread__c,Proposed_Spread__c
                                                                    FROM Funding_Source__c
                                                                    WHERE ID IN: fsIds]);
        
        // Init 3 maps. 
        // Map 1: key: Funding source Id; value: the latest dated, approved credit request object.
        // Map 2: key: Funding source Id; value: the "best" status for this Funding source.
        // Map 3: key: funding source Id; value: a list of all the credit requests on this funding source.
        // Map 4: key: funding source Id; value: a string of the collateral.
        Map<Id,Credit_Requests__c> mapFSId_LatestCRObj = new Map<Id,Credit_Requests__c>();
        Map<Id,String> mapFSId_Status = new Map<Id,String>();
        Map<Id,List<Credit_Requests__c>> mapFSID_AllCRs = new Map<Id,List<Credit_Requests__c>>();
        Map<Id,List<String>> mapFSId_Collateral = new Map<Id,List<String>>();

        // For each of the credit requests for any of the Funding Sources related list of credit requests,
        // add things to the appropriate maps. 
        //   We need the latest dated, approved cr to add to mapFSId_LatestCRObj. 
        //   We need to calculate the "best" status and add that status string to mapFSId_Status 
        //   We need to add all cr's to mapFSID_AllCRs so we can do some rollups later.
        for(Credit_Requests__c tempCR:allCRs.values())
        {
            Id fsId = tempCR.Funding_Source__c;
            if((tempCR.Status__c == 'Approved') && (tempCR.Decision_Date__c !=null))
            {
                if(mapFSId_LatestCRObj.get(fsId) == null)
                    mapFSId_LatestCRObj.put(fsId,tempCR);
                else if((mapFSId_LatestCRObj.get(fsId) != null) &&
                        (mapFSId_LatestCRObj.get(fsId).Decision_Date__c !=null) && 
                        (tempCR.Decision_Date__c >= mapFSId_LatestCRObj.get(fsId).Decision_Date__c))
                {
                    mapFSId_LatestCRObj.put(fsId,tempCR);
                }

                if(!String.isEmpty(tempCR.Collateral__c))
                {
                    if(!mapFSId_Collateral.containsKey(fsId))
                        mapFSId_Collateral.put(fsId, new List<String>());

                    mapFSId_Collateral.get(fsId).add(tempCR.Collateral__c);
                    //mapFSId_Collateral.put(fsId,(String.isEmpty(mapFSId_Collateral.get(fsId))?tempCR.Collateral__c: mapFSId_Collateral.get(fsId) + ' ' + tempCR.Collateral__c));
                }
            }

            mapFSId_Status.put(fsId,returnHighestStatus(tempCR.Status__c,mapFSId_Status.get(fsId)));
            if(mapFSID_AllCRs.get(fsId) == null)
                mapFSID_AllCRs.put(fsId,new List<Credit_Requests__c>());
            mapFSID_AllCRs.get(fsId).add(tempCR);
        }

        // Init a new map of funding sources to update. Map is used instead of list because 
        // certain logic needs to update certain fields on potentially the same funding source.
        Map<Id,Funding_Source__c> fsToUpdate = new Map<Id,Funding_Source__c>();

        // This for loop is to get the collateral and the financial product from the latest dated, approved credit request.
        // this credit request was already calculated earlier.
        for(Id fsId:mapFSId_LatestCRObj.keySet())
        {
            Funding_Source__c fs = allFSs.get(fsId);
            Credit_Requests__c cr = mapFSId_LatestCRObj.get(fsId);
            
            /*// if the fs.Collateral__c contains the cr.Collateral__c, don't append it.
            if(!String.isEmpty(fs.Collateral__c) && !String.isEmpty(cr.Collateral__c) && !fs.Collateral__c.contains(cr.Collateral__c))
            {
                fs.Collateral__c += ' ' + cr.Collateral__c;    
            }*/
            if(mapFSId_Collateral.get(fsId) != null)
            {
                List<String> collat = mapFSId_Collateral.get(fsId);
                collat.sort();
                String tempCollat = String.join(collat, ' ');
                fs.Collateral__c = (tempCollat.length() > 255?tempCollat.substring(0,255):tempCollat);
            }
            fs.Financial_Product__c = (cr.Financial_Product__c != null? cr.Financial_Product__c : fs.Financial_Product__c);
            fsToUpdate.put(fsId,fs);
        }

        // This for loop is to ensure that the funding sources we want to update have the "best" status.
        // We already calculated the "best" statuses for each FS when we were looping through the CR's earlier.
        for(Id fsId : mapFSId_Status.keySet())
        {
            if(!fsToUpdate.keyset().contains(fsId)){
                fsToUpdate.put(fsId,new Funding_Source__c(id=fsId)); 
            }
            Funding_Source__c newFS = fsToUpdate.get(fsId);
            newFS.Status__c = mapFSId_Status.get(fsId);
            fsToUpdate.put(fsId,newFS);
        }

        // This for loop is meant to ensure the FS is up to date. 
        // We can't do anymore rollup fields so I put the approved and proposed spread rollups in this trigger instead.
        for(Id fsId : mapFSID_AllCRs.keySet())
        {
            if(!fsToUpdate.keyset().contains(fsId)){
                fsToUpdate.put(fsId,new Funding_Source__c(id=fsId)); 
            }
            Funding_Source__c newFS = fsToUpdate.get(fsId);
            Decimal proposedSpread = 0;
            Decimal approvedSpread = 0;

            for(Credit_Requests__c cr: mapFSID_AllCRs.get(fsId))
            {
                proposedSpread += (cr.Proposed_Spread__c == null? 0: cr.Proposed_Spread__c);
                approvedSpread += (cr.Approved_Spread__c == null? 0: cr.Approved_Spread__c);
            }
            newFS.Proposed_Spread__c = proposedSpread;
            newFS.Approved_Spread__c = approvedSpread;
            fsToUpdate.put(fsId,newFS);
        }

        // If we have something to update, update it.
        if(!fsToUpdate.isEmpty())
        {
            update fsToUpdate.values();
        }
    }
                      
    private String returnHighestStatus(String crStatus,String bestFsStatus)
	{
		if((bestFsStatus =='Approved') || (crStatus =='Approved'))
			return 'Approved';
		else if((bestFsStatus =='In Progress') || (crStatus =='Awaiting Information'))
			return 'In Progress';
		else if((bestFsStatus =='Pending Approval') || (crStatus =='Pending Final Approval') || (crStatus =='Pending Recommender Approval') || (crStatus =='Pending Preparer Approval'))
			return 'Pending Approval';
        else if((bestFsStatus =='Withdrawn') || (crStatus =='Withdrawn'))
            return 'Withdrawn';
		else if((bestFsStatus =='Declined') || (crStatus =='Declined'))
			return 'Declined';
		
		return 'Not Submitted Yet';
	}
}