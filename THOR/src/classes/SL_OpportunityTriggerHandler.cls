/**
*  ClassName      : SL_OpportunityTriggerHandler.
*  JIRATicket     : THOR-6
*  CreatedOn      : 11/AUG/2014
*  ModifiedBy     : Pradeep
*  Description    : This is the handler class to update Apartment availability based on Opportunity StageName.
*/
public with sharing class SL_OpportunityTriggerHandler 
{
    static final string CLOSED_LOST = 'Closed Lost';
    static final string LEASED_AVAILABLE = 'Leased - Available';
    static final string LEASED_NOT_AVAILABLE = 'Leased - Not Available';
    static final string AVAILABLE_VACANT = 'Available - Vacant';
    static final string AVAILABLE_PENDING = 'Available - Pending';
    static final Id RENEWAL_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Renewal_Lease_Opportunity'].Id;
    static final Id NEW_LEASE_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'New_Lease_Opportunity'].Id;
    static final Id MOVEOUT_CASE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND  DeveloperName = 'Move_Out_Process'].Id;
    static final Id MOVEIN_CASE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND  DeveloperName = 'Move_In_Process'].Id;
    static final Id TRANSFER_OPPORTUNITY_RECORDTYPEID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Transfer_Opportunity'].Id;
    static final Id EXISTING_OPPORTUNITY_RECORDTYPEID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Existing_Opportunity'].Id;
    public static boolean isExecuting = false;
    
    /*
        * MethodName   : onBeforeInsert
        * param        : trigger.new
        * Description  : Will invoke on before insert of Opportunity record
    */
    public void onBeforeInsert(list<Opportunity> lstInsertedOpportunities)
    {
        List<Opportunity> lstFilteredOpportunity = new List<Opportunity>();///List to store Opportunity records with Apartment
        List<Opportunity> lstOpportunityWithAccount = new List<Opportunity>();
        List<Opportunity> lstOpportunityWithApartmentBuildingManager = new List<Opportunity>();
        List<Opportunity> lstOpportunityWithLeasingAgent = new List<Opportunity>();
        Set<Id> setApartmentId = new Set<Id>();
      	Set<Id> setAccountId = new Set<Id>();
      	Set<Id> setApartmentIdNew = new Set<Id>(); 
      	Set<Id> setLeasingAgentId = new Set<Id>();
      	
        ///Create a list of Opportunity records with Apartment
        for(Opportunity objOpportunity : lstInsertedOpportunities)
        {
            lstFilteredOpportunity.add(objOpportunity);
            setApartmentId.add(objOpportunity.Apartment__c);
            
            if(objOpportunity.AccountId != null)
            {
            	lstOpportunityWithAccount.add(objOpportunity);
            	setAccountId.add(objOpportunity.AccountId);
            }
            if(objOpportunity.Apartment__c != null)
            {
            	setApartmentIdNew.add(objOpportunity.Apartment__c);
            	lstOpportunityWithApartmentBuildingManager.add(objOpportunity);
            }
            else
            	objOpportunity.Property_Manager_Email__c = '';
            	
            if(objOpportunity.Leasing_Agent__c != null)
            {
            	setLeasingAgentId.add(objOpportunity.Leasing_Agent__c);
            	lstOpportunityWithLeasingAgent.add(objOpportunity);
            }
            else
            	objOpportunity.Leasing_Agent_Title__c = '';
        }
        if(!test.isRunningTest())
        	checkReferencedApartmentAvailability(setApartmentId,lstFilteredOpportunity,null);
        
        if(!setAccountId.isEmpty() && !lstOpportunityWithAccount.isEmpty())
        	updateOpportunityFieldsBasedOnAccount(lstOpportunityWithAccount,setAccountId);
        	
        if(!setApartmentIdNew.isEmpty() && !lstOpportunityWithApartmentBuildingManager.isEmpty())
        	updateOpportunityFieldsBasedOnApartmentBuildingManager(lstOpportunityWithApartmentBuildingManager,setApartmentIdNew);
    }
    
    /*
        * MethodName   : onBeforeUpdate
        * param        : trigger.new,trigger.oldMap
        * Description  : Will invoke on before Update of Opportunity record
    */
    public void onBeforeUpdate(list<Opportunity> lstUpdatedOpportunities,map<Id,Opportunity> mapOldUpdatedOpps)
    {
        List<Opportunity> lstFilteredOpportunity = new List<Opportunity>();///List to store Opportunity records with Apartment
        Set<Id> setApartmentId = new Set<Id>();
        List<Opportunity> lstOpportunityWithModifiedStage = new List<Opportunity>();
        Set<String> setOpportunityStages = new Set<String>{'Lease Sent','Lease Signed by Tenants','Lease Signed by Thor'};
        List<Opportunity> lstOpportunityWithAccount = new List<Opportunity>();
        List<Opportunity> lstOpportunityWithLeasingAgent = new List<Opportunity>();
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setLeasingAgentId = new Set<Id>();
        
        ///Create a list of Opportunity records with Apartment and whose apartment is changed
        for(Opportunity objOpportunity : lstUpdatedOpportunities)
        {
            if(objOpportunity.Apartment__c != mapOldUpdatedOpps.get(objOpportunity.Id).Apartment__c)
            {
                lstFilteredOpportunity.add(objOpportunity);
                setApartmentId.add(objOpportunity.Apartment__c);
            }
            if(objOpportunity.AccountId != null && objOpportunity.AccountId !=  mapOldUpdatedOpps.get(objOpportunity.Id).AccountId)
            {
            	lstOpportunityWithAccount.add(objOpportunity);
            	setAccountId.add(objOpportunity.AccountId);
            }
            if(objOpportunity.Leasing_Agent__c != null && objOpportunity.Leasing_Agent__c != mapOldUpdatedOpps.get(objOpportunity.Id).Leasing_Agent__c)
            {
            	setLeasingAgentId.add(objOpportunity.Leasing_Agent__c);
            	lstOpportunityWithLeasingAgent.add(objOpportunity);
            }
            else if(objOpportunity.Leasing_Agent__c == null)
            	objOpportunity.Leasing_Agent_Title__c = '';
            	
            if(objOpportunity.StageName != mapOldUpdatedOpps.get(objOpportunity.Id).StageName && setOpportunityStages.contains(objOpportunity.StageName))
                lstOpportunityWithModifiedStage.add(objOpportunity);
            if(objOpportunity.Apartment__c == null)
            	objOpportunity.Property_Manager_Email__c = '';
        }
        
    	checkReferencedApartmentAvailability(setApartmentId,lstFilteredOpportunity,mapOldUpdatedOpps);
        if(!lstOpportunityWithModifiedStage.isEmpty())
        	setOpportunityStageBasedOnContactRoleStatus(lstOpportunityWithModifiedStage);
        	
        if(!setAccountId.isEmpty() && !lstOpportunityWithAccount.isEmpty())
        	updateOpportunityFieldsBasedOnAccount(lstOpportunityWithAccount,setAccountId);
        
        if(!setApartmentId.isEmpty() && !lstFilteredOpportunity.isEmpty())	
        	updateOpportunityFieldsBasedOnApartmentBuildingManager(lstFilteredOpportunity,setApartmentId);
        	
    } 
    
    /*
        * MethodName   : onAfterInsert
        * param        : trigger.newMap
        * Description  : Will invoke on After insert of Opportunity record
    */
    public void onAfterInsert(map<Id,Opportunity> mapNewUpdatedOpps)
    {
        List<Opportunity> lstFilteredOpportunity = new List<Opportunity>();
        List<Opportunity> lstMoveInCaseOpportunity = new List<Opportunity>();
        List<Opportunity> lstMoveOutCaseOpportunity = new List<Opportunity>();
        List<Opportunity> lstNewLeaseOpportunity = new List<Opportunity>();
        List<Opportunity> lstOpportunityWithAppropriateStage = new List<Opportunity>();
        
        Set<String> setOpportunityStages = new Set<String>{'Lease Sent','Lease Signed by Tenants','Lease Signed by Thor'};
        set<String> setOpportunityClosedWonStages = new set<String>{'Lease Signed by Thor', 'Renewal Approved'};
        set<String> setLostReason = new set<String>{'Thor Relocation LED','Thor Relocation Mid-Lease'};
        
        if(!test.isRunningTest())
        {
	        if(SL_OpportunityTriggerHandler.isExecuting )
	      	{
	        	// if was executed during the same context 
		      	// avoid recursion
		      	return; 
	    	}
        }
      
      	SL_OpportunityTriggerHandler.isExecuting = true;
      	
        ///Create a list of Opportunities which have apartment
        for(Opportunity objOpportunity:mapNewUpdatedOpps.values())
        {
            if(setOpportunityStages.contains(objOpportunity.StageName))
                lstOpportunityWithAppropriateStage.add(objOpportunity);
            if(objOpportunity.Apartment__c != null)
                lstFilteredOpportunity.add(objOpportunity);
            if(objOpportunity.RecordTypeId == RENEWAL_OPPORTUNITY_ID && objOpportunity.StageName == CLOSED_LOST && setLostReason.contains(objOpportunity.Lost_Reason__c))
                lstNewLeaseOpportunity.add(objOpportunity);
            if(setOpportunityClosedWonStages.contains(objOpportunity.StageName))
                lstMoveInCaseOpportunity.add(objOpportunity);
            else if(objOpportunity.StageName == CLOSED_LOST && objOpportunity.RecordTypeId == RENEWAL_OPPORTUNITY_ID)
                lstMoveOutCaseOpportunity.add(objOpportunity); 
        } 
        if(!lstFilteredOpportunity.isEmpty())      
        	updateReferencedApartmentAvailability(lstFilteredOpportunity,null);
        if(!lstMoveInCaseOpportunity.isEmpty())  
        	createMoveInCases(lstMoveInCaseOpportunity);
        if(!lstMoveOutCaseOpportunity.isEmpty())  
        	createMoveOutCases(lstMoveOutCaseOpportunity);
        if(!lstNewLeaseOpportunity.isEmpty())  
        	createNewLeaseOpportunity(lstNewLeaseOpportunity);
        if(!lstOpportunityWithAppropriateStage.isEmpty())  
        	setOpportunityStageBasedOnContactRoleStatus(lstOpportunityWithAppropriateStage);
    }
    
    /*
        * MethodName   : onAfterUpdate
        * param        : trigger.oldMap,trigger.newMap
        * Description  : Will invoke on After Update of Opportunity record
    */
    public void onAfterUpdate(map<Id,Opportunity> mapOldUpdatedOpps,map<Id,Opportunity> mapNewUpdatedOpps)
    { 
        List<Opportunity> lstFilteredOpportunity = new List<Opportunity>();///List to store Opportunity records whose stage has been changed
        List<Opportunity> lstMoveInCaseOpportunity = new List<Opportunity>();
        List<Opportunity> lstMoveOutCaseOpportunity = new List<Opportunity>();
        List<Opportunity> lstNewLeaseOpportunity = new List<Opportunity>();
        List<Opportunity> lstTransferOpportunity = new List<Opportunity>();
        List<Opportunity> lstOpportunityWithLeaseSignedByThorStage = new List<Opportunity>();
        Map<Id,Id> mapApartmentId_AccountId = new Map<Id,Id>();
        
        set<String> setOpportunityClosedWonStages = new set<String>{'Lease Signed by Thor', 'Renewal Approved'};
        set<String> setLostReason = new set<String>{'Thor Relocation LED','Thor Relocation Mid-Lease'};
        Set<Id> setOldApartmentId = new Set<Id>();
        Set<Id> setGuarantorOppIds = new set<Id>();
        Set <Id> setUpdatedOppStageId = new Set <Id> ();
       	Set <Id> setUpdatedOppAccId = new Set <Id> ();
        Set <Id> setLeaseId = new Set <Id> ();
    	Set <Id> setUpdatedOppId = new Set <Id> (); 
        
        if(!test.isRunningTest())
        {
	        if(SL_OpportunityTriggerHandler.isExecuting )
	      	{
	        	// if was executed during the same context 
		      	// avoid recursion
		      	return;
	    	}
        }
      
      	SL_OpportunityTriggerHandler.isExecuting = true;
      	
        ///Create a list of Opportunity records whose stage has been changed and a set of opportunity whose apartment has been changed
        for(Opportunity objOpportunity:mapNewUpdatedOpps.values())
        {
            if(objOpportunity.Apartment__c != null && (objOpportunity.StageName != mapOldUpdatedOpps.get(objOpportunity.Id).StageName))
                lstFilteredOpportunity.add(objOpportunity);
            if(mapOldUpdatedOpps.get(objOpportunity.Id).Apartment__c != null && objOpportunity.Apartment__c != mapOldUpdatedOpps.get(objOpportunity.Id).Apartment__c)
                setOldApartmentId.add(mapOldUpdatedOpps.get(objOpportunity.Id).Apartment__c);
            if(!setOpportunityClosedWonStages.contains(mapOldUpdatedOpps.get(objOpportunity.Id).StageName) && setOpportunityClosedWonStages.contains(mapNewUpdatedOpps.get(objOpportunity.Id).StageName)) 
                lstMoveInCaseOpportunity.add(objOpportunity);
            if(mapOldUpdatedOpps.get(objOpportunity.Id).StageName != CLOSED_LOST && mapNewUpdatedOpps.get(objOpportunity.Id).StageName == CLOSED_LOST &&
               mapNewUpdatedOpps.get(objOpportunity.Id).RecordTypeId == RENEWAL_OPPORTUNITY_ID)
                lstMoveOutCaseOpportunity.add(objOpportunity);
            if(objOpportunity.RecordTypeId == RENEWAL_OPPORTUNITY_ID && objOpportunity.StageName ==  CLOSED_LOST 
                    && (setLostReason.contains(objOpportunity.Lost_Reason__c) && !setLostReason.contains(mapOldUpdatedOpps.get(objOpportunity.Id).Lost_Reason__c)))
                lstNewLeaseOpportunity.add(objOpportunity);
            if(objOpportunity.RecordTypeId == TRANSFER_OPPORTUNITY_RECORDTYPEID && objOpportunity.Apartment__c != mapOldUpdatedOpps.get(objOpportunity.Id).Apartment__c)
               lstTransferOpportunity.add(objOpportunity);
              
            if(((objOpportunity.StageName != mapOldUpdatedOpps.get(objOpportunity.Id).StageName) 
            	&& (objOpportunity.StageName == 'Lease Signed by Thor'))
            	&&  (objOpportunity.RecordTypeId == NEW_LEASE_OPPORTUNITY_ID  || objOpportunity.RecordTypeId == RENEWAL_OPPORTUNITY_ID || 
            	      objOpportunity.RecordTypeId == TRANSFER_OPPORTUNITY_RECORDTYPEID || objOpportunity.RecordTypeId == EXISTING_OPPORTUNITY_RECORDTYPEID))
            {
              	setUpdatedOppStageId.add(objOpportunity.Id);
            	setUpdatedOppAccId.add(objOpportunity.AccountId);
            }
            
            if((objOpportunity.StageName != mapOldUpdatedOpps.get(objOpportunity.Id).StageName) && (objOpportunity.StageName == 'Lease Signed by Thor') 
                && objOpportunity.AccountId != null  && objOpportunity.Apartment__c != null )
            {
            	mapApartmentId_AccountId.put(objOpportunity.Apartment__c, objOpportunity.AccountId);
            	lstOpportunityWithLeaseSignedByThorStage.add(objOpportunity);
            }
            
            /*THOR-46 - */    
            if((objOpportunity.StageName == 'Lease Signed by Thor') && 
	        	(objOpportunity.RecordTypeId == NEW_LEASE_OPPORTUNITY_ID  || objOpportunity.RecordTypeId == RENEWAL_OPPORTUNITY_ID ||
	        	  objOpportunity.RecordTypeId == TRANSFER_OPPORTUNITY_RECORDTYPEID || objOpportunity.RecordTypeId == EXISTING_OPPORTUNITY_RECORDTYPEID)&&
	        	(objOpportunity.Lease_Start_date__c != mapOldUpdatedOpps.get(objOpportunity.Id).Lease_Start_date__c
	            || objOpportunity.Lease_Type__c != mapOldUpdatedOpps.get(objOpportunity.Id).Lease_Type__c
	            || objOpportunity.Lease_End_Date__c != mapOldUpdatedOpps.get(objOpportunity.Id).Lease_End_Date__c
	            || objOpportunity.Apartment__c != mapOldUpdatedOpps.get(objOpportunity.Id).Apartment__c 
	            || objOpportunity.Monthly_Rent__c != mapOldUpdatedOpps.get(objOpportunity.Id).Monthly_Rent__c
	            || objOpportunity.Security_Deposit_Required__c != mapOldUpdatedOpps.get(objOpportunity.Id).Security_Deposit_Required__c
	            || objOpportunity.Insurance_Guaranty_Rider__c != mapOldUpdatedOpps.get(objOpportunity.Id).Insurance_Guaranty_Rider__c
	            || objOpportunity.Airbnb_Rider_Formula__c != mapOldUpdatedOpps.get(objOpportunity.Id).Airbnb_Rider_Formula__c
	            || objOpportunity.House_Rules_and_Relations__c != mapOldUpdatedOpps.get(objOpportunity.Id).House_Rules_and_Relations__c
	            || objOpportunity.Smoke_Free_Initiative_Rider__c != mapOldUpdatedOpps.get(objOpportunity.Id).Smoke_Free_Initiative_Rider__c
	            || objOpportunity.Terrace_Balcony_Rider__c != mapOldUpdatedOpps.get(objOpportunity.Id).Terrace_Balcony_Rider__c
	            || objOpportunity.Pet_Rider__c != mapOldUpdatedOpps.get(objOpportunity.Id).Pet_Rider__c
	            || objOpportunity.Pet_Fees__c != mapOldUpdatedOpps.get(objOpportunity.Id).Pet_Fees__c
	            || objOpportunity.Lease_Offer_Notice__c != mapOldUpdatedOpps.get(objOpportunity.Id).Lease_Offer_Notice__c
	            || objOpportunity.Early_Termination_Rider__c != mapOldUpdatedOpps.get(objOpportunity.Id).Early_Termination_Rider__c
	            || objOpportunity.J_51_Rider__c != mapOldUpdatedOpps.get(objOpportunity.Id).J_51_Rider__c
	            || objOpportunity.Early_Occupancy_Rider__c != mapOldUpdatedOpps.get(objOpportunity.Id).Early_Occupancy_Rider__c
	            || objOpportunity.Early_Occupancy_Date__c != mapOldUpdatedOpps.get(objOpportunity.Id).Early_Occupancy_Date__c
	            || objOpportunity.Storage__c != mapOldUpdatedOpps.get(objOpportunity.Id).Storage__c
	            || objOpportunity.Lead_Paint_Notice__c != mapOldUpdatedOpps.get(objOpportunity.Id).Lead_Paint_Notice__c
	            || objOpportunity.Window_Guards_Rider__c != mapOldUpdatedOpps.get(objOpportunity.Id).Window_Guards_Rider__c
	            || objOpportunity.W_9__c != mapOldUpdatedOpps.get(objOpportunity.Id).W_9__c
	            || objOpportunity.W_8__c != mapOldUpdatedOpps.get(objOpportunity.Id).W_8__c
            ))
	        {
	            setUpdatedOppId.add(objOpportunity.Id);
	            
	            if(objOpportunity.Lease__c != null)
	              setLeaseId.add(objOpportunity.Lease__c);
	        }    
            
            /* THOR-47 - Guarantor Required Email Automation */
            if(objOpportunity.Application_Status__c == 'Application Pending Guarantor' && (objOpportunity.Application_Status__c != mapOldUpdatedOpps.get(objOpportunity.Id).Application_Status__c))
              setGuarantorOppIds.add(objOpportunity.Id);
        }
        if(!test.isRunningTest()) 
        	updateReferencedApartmentAvailability(lstFilteredOpportunity,mapOldUpdatedOpps);
        	
        if(!setOldApartmentId.isEmpty())
        	populateOldApartmentStatus(setOldApartmentId);
        	
        if(!lstNewLeaseOpportunity.isEmpty())	
        	createNewLeaseOpportunity(lstNewLeaseOpportunity); 
        	
        if(!lstTransferOpportunity.isEmpty()) 
        	updateTransferToApartmentFieldOnRenewalOpportunity(lstTransferOpportunity);
        
        /*THOR-46*/  
        if(!setUpdatedOppStageId.isEmpty())
       		OpportunityToLeaseInsert(setUpdatedOppStageId,setUpdatedOppAccId);
       
        if(!setUpdatedOppId.isEmpty() && !setLeaseId.isEmpty())
      		updateParentLease(setUpdatedOppId,setLeaseId);
        
        /* THOR-47 - Guarantor Required Email Automation */
        if(!setGuarantorOppIds.isEmpty() && setGuarantorOppIds!= null)
           fetchRelatedContactRole(setGuarantorOppIds);
        
        if(!lstMoveInCaseOpportunity.isEmpty())
        	createMoveInCases(lstMoveInCaseOpportunity);
        
        if(!lstMoveOutCaseOpportunity.isEmpty())
        	createMoveOutCases(lstMoveOutCaseOpportunity); 
        	
       	if(!mapApartmentId_AccountId.isEmpty())
       		 updateCurrentTenantFieldOnApartment(mapApartmentId_AccountId);
       		 
       	if(!lstOpportunityWithLeaseSignedByThorStage.isEmpty())
       		updateAccountOnContactRole(lstOpportunityWithLeaseSignedByThorStage);
    }  
    
    /*
        * MethodName   : checkReferencedApartmentAvailability
        * param        : set of apartment id,trigger.new,trigger.oldMap
        * Description  : Method to check referenced Apartment availability on before Insert and before Update of Opportunity record.
    */
    private void checkReferencedApartmentAvailability(set<Id> setApartmentId,list<Opportunity> lstInsertedOrUpdatedOpps,map<Id,Opportunity> mapOldUpdatedOpps)
    {
        map<Id,Apartment__c> mapApartmentId_Apartment = new map<Id,Apartment__c>();
        set<String> setApartmentConflictStatus = new set<String>{'Leased - Not Available',
                                                                 'Leased - On Hold',
                                                                 'Available - On Hold'};
        set<String> setOpportunityStages = new set<String>{'Lease Signed by Tenants',
                                                           'Lease Signed by Thor',
                                                           'Pending Pricing',           
                                                           'Renewal Approved'};
            
        ///Create a mapof Apartmentid to Apartment
        for(Apartment__c objApartment : [SELECT Id,Name,Apartment_Status__c 
                                         FROM Apartment__c 
                                         WHERE Id IN:setApartmentId])
        {
            mapApartmentId_Apartment.put(objApartment.Id,objApartment);
        }
        
        
        ///Check for conditions and show an error if condition matches
       for(Opportunity objOpp : lstInsertedOrUpdatedOpps)
        {
            ///Show error message if Apartment status matches
            if(objOpp.Apartment__c != null && setApartmentConflictStatus.contains(mapApartmentId_Apartment.get(objOpp.Apartment__c).Apartment_Status__c)
                                            && objOpp.RecordTypeId != RENEWAL_OPPORTUNITY_ID)
            {
                objOpp.Apartment__c.addError(System.Label.SL_ConflictWithUnitAvailability); 
            }
            ///Show error message if Opportunity stage matches and there is an aprtment already on Opportunity before updating
            else if(setOpportunityStages.contains(objOpp.StageName) && mapOldUpdatedOpps != null && mapOldUpdatedOpps.get(objOpp.Id).Apartment__c !=  null)
            {
                objOpp.Apartment__c.addError(System.Label.SL_InvalidOpportunityStageToSaveApartment);
            }
        }
    }
    
    
    /*
        * MethodName   : updateReferencedApartmentAvailability
        * param        : trigger.new
        * Description  : Method to update Apartment Availability based on Opportunity Stage Values.
    */
    private void updateReferencedApartmentAvailability(list<Opportunity>lstOpportunity, map<Id,Opportunity> mapOldUpdatedOpps)
    {
        list<Apartment__c> lstApartmentToUpdate = new list<Apartment__c>();
        Id NEWLEASE_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'New_Lease_Opportunity'].Id;
        set<String> setLeaseNotAvailableStages = new set<String>{'Application Approved',
                                                                 'Lease Sent',
                                                                 'Lease Signed by Tenants',
                                                                 'Lease Signed by Thor'};
        set<Id> setApartmentId = new set<Id>();
        
        ///Modify Apartment status
        for(Opportunity objOpportunity : [SELECT Apartment__c,StageName,RecordTypeId,Apartment__r.Apartment_Status__c,Apartment__r.Previous_Apartment_Status__c,
                                          Apartment__r.Previous_Availability_Date__c,Apartment__r.Availability_Date__c  
                                          FROM Opportunity
                                          WHERE ID IN:lstOpportunity])
        {
            ///Make sure values from only one opportunity is conidered to update a related apartment
            if(!setApartmentId.contains(objOpportunity.Apartment__c))
            {
                Apartment__c objApartment = new Apartment__c(Id = objOpportunity.Apartment__c);
                
                ///Check for matching Opportunity stage and update apartment status accordingly
                if(setLeaseNotAvailableStages.contains(objOpportunity.StageName))
                {
                    objApartment.Apartment_Status__c = LEASED_NOT_AVAILABLE;
                    if(objOpportunity.Apartment__r.Availability_Date__c != null)
                    {
	                    objApartment.Previous_Availability_Date__c = objOpportunity.Apartment__r.Availability_Date__c;
	                    objApartment.Availability_Date__c = null;
                    }
                }
                ///Check for matching Opportunity stage and recordtype and update apartment status accordingly
                else if(objOpportunity.StageName == CLOSED_LOST && objOpportunity.RecordTypeId == RENEWAL_OPPORTUNITY_ID)   
                    objApartment.Apartment_Status__c = LEASED_AVAILABLE;
                    
                if(objOpportunity.StageName == CLOSED_LOST && (objOpportunity.RecordTypeId == NEWLEASE_OPPORTUNITY_ID ||  objOpportunity.RecordTypeId == TRANSFER_OPPORTUNITY_RECORDTYPEID)
                   && mapOldUpdatedOpps != null && mapOldUpdatedOpps.containskey(objOpportunity.Id) && mapOldUpdatedOpps.get(objOpportunity.Id) != null
                   && setLeaseNotAvailableStages.contains(mapOldUpdatedOpps.get(objOpportunity.Id).StageName))  
                {
                    objApartment.Apartment_Status__c = objOpportunity.Apartment__r.Previous_Apartment_Status__c; 
                    objApartment.Availability_Date__c  = objOpportunity.Apartment__r.Previous_Availability_Date__c;
                }   
                    
                setApartmentId.add(objOpportunity.Apartment__c); 
                lstApartmentToUpdate.add(objApartment);
            }
        }
        
        if(!lstApartmentToUpdate.isEmpty())
            update lstApartmentToUpdate;    
    }
    
    
    /*
        * MethodName   : populateOldApartmentStatus
        * param        : Set of old apartment ids
        * Description  : Method to update populate old Apartment status on Apartment.
    */
    private void populateOldApartmentStatus(Set<Id> setOldApartmentId)
    {
        List<Apartment__c> lstApartmentToUpdate = new List<Apartment__c>();
        Set<Id> setOldApartmentIdWithFutureLeaseDate = new Set<Id>();
        Map<Id,Case> mapLeaseId_Case = new Map<Id,Case>();
        Map<Id,Lease__c> mapApartmentId_Lease = new Map<Id,Lease__c>();
        
        ///Create a set of apartment ids which has atleast one opportunity with Lease_Start_date__c in future                                                        
        for(Opportunity objOpportunity:[SELECT Apartment__c
                                        FROM Opportunity
                                        WHERE Lease_Start_date__c >: date.today() AND Apartment__c IN:setOldApartmentId])
        {
            setOldApartmentIdWithFutureLeaseDate.add(objOpportunity.Apartment__c);
        }
        
        ///Create a map of apartment id to lease object
        for(Lease__c objLease:[SELECT Id,Apartment__c,End_Date__c 
                               FROM Lease__c
                               WHERE Apartment__c IN:setOldApartmentId
                               ORDER BY Start_Date__c DESC])
        {
            if(!mapApartmentId_Lease.containskey(objLease.Apartment__c))
                mapApartmentId_Lease.put(objLease.Apartment__c,objLease);
        }
        
        ///Create a map of lease to move out case object
        for(Case objCase:[SELECT Id,IsClosed,RecordTypeId,Lease__c
                          FROM Case
                          WHERE RecordTypeId =: MOVEOUT_CASE_ID AND Lease__c IN:mapApartmentId_Lease.values()])
        {
            mapLeaseId_Case.put(objCase.Lease__c,objCase);
        }
        
        ///Create data for apartement status
        for(Apartment__c objApartment:[SELECT Id,Previous_Apartment_Status__c,Apartment_Status__c,Availability_Date__c,Previous_Availability_Date__c 
                                       FROM Apartment__c
                                       WHERE Id IN:setOldApartmentId])
        {
            ///Check if previous apartment status is LEASED_AVAILABLE
            if(objApartment.Previous_Apartment_Status__c == LEASED_AVAILABLE)
            {
                ///Check if lease associated with apartment has end date in past
                if(mapApartmentId_Lease.containskey(objApartment.Id) && mapApartmentId_Lease.get(objApartment.Id) != null 
                    && mapApartmentId_Lease.get(objApartment.Id).End_Date__c < date.Today())
                {
                    ///Check if move out case is present
                    if(mapLeaseId_Case.containskey(mapApartmentId_Lease.get(objApartment.Id).Id)     
                            && mapLeaseId_Case.get(mapApartmentId_Lease.get(objApartment.Id).Id) != null)
                    {
                        ///Check if move out case associated with lease is closed
                        if(mapLeaseId_Case.get(mapApartmentId_Lease.get(objApartment.Id).Id).IsClosed)
                        {
                            ///Check if apartment has atleast one opportunity with Lease_Start_date__c in future
                            if(setOldApartmentIdWithFutureLeaseDate.contains(objApartment.Id))
                                objApartment.Apartment_Status__c =  LEASED_NOT_AVAILABLE;
                            else
                                objApartment.Apartment_Status__c =  AVAILABLE_VACANT;
                        }
                        else
                            objApartment.Apartment_Status__c = LEASED_AVAILABLE;
                    }
                    else 
                        objApartment.Apartment_Status__c = AVAILABLE_PENDING;
                }
                else
                    objApartment.Apartment_Status__c = LEASED_AVAILABLE;
            }
            else if(objApartment.Previous_Apartment_Status__c != 'Leased - Not Available')
            {
                objApartment.Apartment_Status__c = objApartment.Previous_Apartment_Status__c;
                objApartment.Availability_Date__c  = objApartment.Previous_Availability_Date__c;
            }
            lstApartmentToUpdate.add(objApartment);
        }
        
        if(!lstApartmentToUpdate.isEmpty())
            update lstApartmentToUpdate;
        
    }
    
    
    /*
        * MethodName   : createMoveInCases
        * param        : Filtered List of opportunities
        * Description  : Method to create new Case records for Opportunities updated as 'Lease Signed by Thor' or 'Renewal Approved'
    */
    private void createMoveInCases(List<Opportunity> lstMoveInCaseOpportunity)
    {
        List<Case> lstCaseToBeCreated = new List<Case>();///List to store case records to be inserted
        List<Case> lstCaseToBeUpdated = new List<Case>();///List to store case records to be lstCaseToBeUpdated
        Set<Id> setExistingOpportunityId = new Set<Id>();
        
        ///Update case records
        for(Case objCase:[SELECT Id,Apartment__c , Opportunity__r.Apartment__c,AccountId , Opportunity__r.AccountId,Lease__c , Opportunity__r.Lease__c,
						  Building__c , Opportunity__r.Apartment__r.Building__c ,Lease_Start_Date__c , Opportunity__r.Lease__r.Start_Date__c,
						  Opportunity__r.Lease_Start_date__c,Keys_Available_Date__c ,Opportunity__r.Apartment__r.Building__r.Building_Manager__c,
						  OwnerId ,Phone__c , Opportunity__r.Account.Phone,Email__c , Opportunity__r.Account.PersonEmail
						  FROM Case
						  WHERE Opportunity__c IN:lstMoveInCaseOpportunity AND RecordtypeId =: MOVEIN_CASE_ID ])
        {
        	objCase.Apartment__c = objCase.Opportunity__r.Apartment__c;
            objCase.AccountId = objCase.Opportunity__r.AccountId;
            objCase.Lease__c = objCase.Opportunity__r.Lease__c; 
           
            if(objCase.Opportunity__r.Apartment__c!= null)
                objCase.Building__c = objCase.Opportunity__r.Apartment__r.Building__c;
            if(objCase.Opportunity__r.Lease__c != null)
                objCase.Lease_Start_Date__c = objCase.Opportunity__r.Lease__r.Start_Date__c;
			if(objCase.Opportunity__r.Lease_Start_date__c != null)
				objCase.Keys_Available_Date__c = objCase.Opportunity__r.Lease_Start_date__c;
			if(objCase.Opportunity__r.Apartment__c != null && objCase.Opportunity__r.Apartment__r.Building__c != null && 
			    objCase.Opportunity__r.Apartment__r.Building__r.Building_Manager__c != null)
				objCase.OwnerId = objCase.Opportunity__r.Apartment__r.Building__r.Building_Manager__c;
			if(objCase.Opportunity__r.Account != null &&  objCase.Opportunity__r.Account.Phone != null)
				objCase.Phone__c = objCase.Opportunity__r.Account.Phone;
			if(objCase.Opportunity__r.Account != null && objCase.Opportunity__r.Account.PersonEmail != null)
				objCase.Email__c = objCase.Opportunity__r.Account.PersonEmail; 
			
			lstCaseToBeUpdated.add(objCase);
			setExistingOpportunityId.add(objCase.Opportunity__c);
        }
        
        ///Create a case record by querying since Opportunity.Unit__r.Building__c cannot be obtained directly from trigger.new values                   
        for(Opportunity objOpportunity : [SELECT Id,Apartment__c,Apartment__r.Building__c,AccountId ,Lease__r.Start_Date__c,Lease__c,Lease_Start_date__c,
                                          Apartment__r.Building__r.Building_Manager__c,Account.Phone,Account.PersonEmail 
                                          FROM   Opportunity 
                                          WHERE Id IN : lstMoveInCaseOpportunity AND ID NOT IN:setExistingOpportunityId
                                          AND (RecordtypeId =: NEW_LEASE_OPPORTUNITY_ID OR  RecordtypeId =: TRANSFER_OPPORTUNITY_RECORDTYPEID)])
        {
            Case objCase = new Case();
            objCase.Apartment__c = objOpportunity.Apartment__c;
            objCase.AccountId = objOpportunity.AccountId;
            objCase.Lease__c = objOpportunity.Lease__c;
            objCase.RecordTypeId = MOVEIN_CASE_ID;
            objCase.Opportunity__c = objOpportunity.Id;
            
            if(objOpportunity.Apartment__c!= null)
                objCase.Building__c = objOpportunity.Apartment__r.Building__c;
            if(objOpportunity.Lease__c != null)
                objCase.Lease_Start_Date__c = objOpportunity.Lease__r.Start_Date__c;
			if(objOpportunity.Lease_Start_date__c != null)
				objCase.Keys_Available_Date__c = objOpportunity.Lease_Start_date__c;
			if(objOpportunity.Apartment__c != null && objOpportunity.Apartment__r.Building__c != null && 
			              objOpportunity.Apartment__r.Building__r.Building_Manager__c != null)
				objCase.OwnerId = objOpportunity.Apartment__r.Building__r.Building_Manager__c;
			if(objOpportunity.Account != null &&  objOpportunity.Account.Phone != null)
				objCase.Phone__c = objOpportunity.Account.Phone;
			if(objOpportunity.Account != null && objOpportunity.Account.PersonEmail != null)
				objCase.Email__c = objOpportunity.Account.PersonEmail;
			
            lstCaseToBeCreated.add(objCase);
        }
        
        ///Insert case record
        if(!lstCaseToBeCreated.isEmpty())
            insert lstCaseToBeCreated;
        
        ///Update existing cases    
       	if(!lstCaseToBeUpdated.isEmpty())
       		update lstCaseToBeUpdated;
    }
    
    /*
        * MethodName   : createMoveOutCases
        * param        : Filtered List of opportunities
        * Description  : Method to create new Case records for Opportunities updated as 'Closed Lost'
    */
    private void createMoveOutCases(List<Opportunity> lstMoveOutCaseOpportunity)
    {
        List<Case> lstCaseToBeCreated = new List<Case>();///List to store case records to be inserted
        
        ///Create a case record by querying since Opportunity.Unit__r.Building__c cannot be obtained directly from trigger.newMap values                    
        for(Opportunity objOpportunity : [SELECT Apartment__c,Apartment__r.Building__c,Previous_Lease__c,AccountId,Lease__r.End_Date__c,Lease__c, Lease__r.Move_Out_Date__c,
                                          Apartment__r.Building__r.Building_Manager__c,Lease__r.Security_Deposit__c,Account.Phone,Account.PersonEmail,Previous_Opportunity__c,
                                          Previous_Opportunity__r.Lease__c
                                          FROM   Opportunity 
                                          WHERE Id IN : lstMoveOutCaseOpportunity])
        {
            Case objCase = new Case();
            objCase.Apartment__c = objOpportunity.Apartment__c;
            objCase.AccountId = objOpportunity.AccountId;
            if(objOpportunity.Previous_Opportunity__c != null &&  objOpportunity.Previous_Opportunity__r.Lease__c != null)
            	objCase.Lease__c = objOpportunity.Previous_Opportunity__r.Lease__c;
            objCase.RecordTypeId = MOVEOUT_CASE_ID;
            objCase.Opportunity__c = objOpportunity.Id;
            
            if(objOpportunity.Apartment__c!= null)
                objCase.Building__c = objOpportunity.Apartment__r.Building__c;
            if(objOpportunity.Lease__c != null)
                objCase.Lease_End_Date__c = objOpportunity.Lease__r.End_Date__c;
			if(objOpportunity.Apartment__c != null && objOpportunity.Apartment__r.Building__c != null && 
			            objOpportunity.Apartment__r.Building__r.Building_Manager__c != null)
				objCase.OwnerId = objOpportunity.Apartment__r.Building__r.Building_Manager__c;
			if(objOpportunity.Lease__c != null && objOpportunity.Lease__r.Security_Deposit__c != null)
				objCase.Security_Deposit__c = objOpportunity.Lease__r.Security_Deposit__c;
			if(objOpportunity.Account != null && objOpportunity.Account.Phone != null)
				objCase.Phone__c = objOpportunity.Account.Phone;
			if(objOpportunity.Account != null && objOpportunity.Account.PersonEmail != null)
				objCase.Email__c = objOpportunity.Account.PersonEmail;
			
            lstCaseToBeCreated.add(objCase);
        }
        
        ///Insert case record
        if(!lstCaseToBeCreated.isEmpty())
            insert lstCaseToBeCreated;
    }
    
    /*
        * MethodName   : createNewLeaseOpportunity
        * param        : Filtered List of opportunities
        * Description  : Method to create new lease opportunity records from renewal opportunity
    */
    private void createNewLeaseOpportunity(List<Opportunity> lstOpportunity)
    {
        Map<String,String> mapRenewalField_NewLeaseField = new Map<String,String>();
        Map<Id,Opportunity> mapRenewalOppId_NewLeaseOpportunity = new Map<Id,Opportunity>();
        Map<Id,List<Contact_Role__c>> mapRenewalOppId_LstContactRole = new Map<Id,List<Contact_Role__c>>();
        List<Contact_Role__c> lstContactRoleToUpdate = new List<Contact_Role__c>();
        Id TRANSFER_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Transfer_Opportunity'].Id;
        
        ///Create map of renewal opportunity field api name to new lease opportunity field api name
        for(SL_RenewalToNewLease__c objRenewalToNewLease:[SELECT Name, Renewal_Opportunity_Field_Name__c 
                                                          FROM SL_RenewalToNewLease__c])
        {
            mapRenewalField_NewLeaseField.put(objRenewalToNewLease.Renewal_Opportunity_Field_Name__c,objRenewalToNewLease.Name);
        }
        
        ///Create data for new lease opportunity
        for(Opportunity objRenewalOpportunity:[SELECT Id,Name,Lease__c,Lease__r.End_Date__c,CloseDate,Payment_Method__c,OwnerId,Tenant_Referral__c,
                                               First_Email_Date__c,AccountId,LeadSource,Best_Contact__c,Security_Deposit_Required__c,
                                               Lead_Converted_Date__c,Lead_Created_Date__c,Type_of_Credit_Card__c,Comments_from_Website__c,
                                               Existing_Security_Deposit__c,Budget__c,Budget_Max__c,First_Appointment_Date__c,First_Call_Date__c,
                                               Last_Appointment_Date__c,Amount,Transfer_To_Apartment__c,Monthly_Rent__c 
                                               FROM Opportunity
                                               WHERE ID IN:lstOpportunity])
        {
            sObject objSobjectRenewalOpportunity = new Opportunity();
            sObject objSobjectNewLeaseOpportunity = new Opportunity();
            objSobjectRenewalOpportunity = objRenewalOpportunity;
            objSobjectNewLeaseOpportunity.put('RecordTypeId',TRANSFER_OPPORTUNITY_ID);
            objSobjectNewLeaseOpportunity.put('Name','Transfer ' + objRenewalOpportunity.Name);
            objSobjectNewLeaseOpportunity.put('StageName','Qualified Prospect');
            
            ///Map fields from Renewal Opportunity to New Lease Opportunity
            for(String objString:mapRenewalField_NewLeaseField.keyset())
            {
                if(objSobjectRenewalOpportunity.get(objString) != null)
                    objSobjectNewLeaseOpportunity.put(mapRenewalField_NewLeaseField.get(objString),objSobjectRenewalOpportunity.get(objString));
            } 
            mapRenewalOppId_NewLeaseOpportunity.put(objRenewalOpportunity.Id, (Opportunity)objSobjectNewLeaseOpportunity);
        }
        
        ///Create map of Renewal Opportunity id to List of associated Contact role records
        for(Contact_Role__c objContactRole:[SELECT Id,Opportunity__c
                                            FROM Contact_Role__c
                                            WHERE Opportunity__c IN:lstOpportunity])
        {
            if(!mapRenewalOppId_LstContactRole.containskey(objContactRole.Opportunity__c))
                mapRenewalOppId_LstContactRole.put(objContactRole.Opportunity__c, new List<Contact_Role__c>{objContactRole});
            else if(mapRenewalOppId_LstContactRole.containskey(objContactRole.Opportunity__c) 
                     && mapRenewalOppId_LstContactRole.get(objContactRole.Opportunity__c) != null)
                mapRenewalOppId_LstContactRole.get(objContactRole.Opportunity__c).add(objContactRole);
        } 
        
        insert mapRenewalOppId_NewLeaseOpportunity.values();
        
        ///Associate Contact role records to new lease opportunity
        for(Id objRenewalOpportunityId:mapRenewalOppId_LstContactRole.keyset())
        {
            if(mapRenewalOppId_LstContactRole.get(objRenewalOpportunityId) != null)
            {
                for(Contact_Role__c objContactRole:mapRenewalOppId_LstContactRole.get(objRenewalOpportunityId))
                {
                    if(mapRenewalOppId_NewLeaseOpportunity.containskey(objRenewalOpportunityId) && mapRenewalOppId_NewLeaseOpportunity.get(objRenewalOpportunityId) != null)
                    {
                        objContactRole.Opportunity__c = mapRenewalOppId_NewLeaseOpportunity.get(objRenewalOpportunityId).Id;
                        lstContactRoleToUpdate.add(objContactRole);
                    }
                }
            }
        }
        
        if(!lstContactRoleToUpdate.isEmpty())
        {
            update lstContactRoleToUpdate;
        }
    }
    
    /*
        * MethodName   : setOpportunityStageBasedOnContactRoleStatus
        * param        : Filtered List of opportunities
        * Description  : Method to set Opportunity stage based on Contact role status
    */
    private void setOpportunityStageBasedOnContactRoleStatus(List<Opportunity> lstOpportunity)
    {
        Set<String> setApplicationStatus = new Set<String>{'Application Approved'};
        Set<Id> setOpportunityId = new Set<Id>();
        Set<Id> setOpportunityToShowErrorMessage = new Set<Id>();
        Set<Id> setOpportunityWithoutContactRole = new Set<Id>();
        
        ///Create a set of invalid opportunity ids
        for(Contact_Role__c objContactRole:[SELECT Status__c,Opportunity__c,Role__c 
                                            FROM Contact_Role__c
                                            WHERE Opportunity__c IN:lstOpportunity])
        {
          setOpportunityId.add(objContactRole.Opportunity__c);
            if(!setApplicationStatus.contains(objContactRole.Status__c))
            {
                setOpportunityToShowErrorMessage.add(objContactRole.Opportunity__c);
            }
        }
        
        ///Create a set of Opportunity ids which do not have a caontact role
        for(Opportunity objOpportunity:[SELECT Id
                                        FROM Opportunity
                                        WHERE Id IN:lstOpportunity AND ID NOT IN:setOpportunityId])
        {
          setOpportunityWithoutContactRole.add(objOpportunity.Id);
        }
        
        ///Show error messsage on Opportunity if Related contact role does not have an appropriate status
        for(Opportunity objOpportunity:lstOpportunity)
        {
            if(setOpportunityToShowErrorMessage.contains(objOpportunity.Id))
            {
                objOpportunity.StageName.addError(System.Label.SL_InvalidOpportunityStageForRelatedContactRoleStatus);
            }
            if(setOpportunityWithoutContactRole.contains(objOpportunity.Id))
            {
               objOpportunity.StageName.addError(System.Label.SL_NoAssociatedContactRoleToOpportunity);
            }
        }
    }
    
     /**
     @MethodName        : OpportunityToLeaseInsert
     @param             : Map<Id, Opportunity> MapNewInsertedOpps,Map<Id, Opportunity> MapOldInsertedOpps
     @Description       :      
    **/
    private void OpportunityToLeaseInsert(Set<Id>setUpdatedOppStageId,Set<Id> setUpdatedOppAccId)
    {
		List <Lease__c> lstInsertedLease = new List <Lease__c> (); 
       	lstInsertedLease = insertLeasBasedOnOppstageName(setUpdatedOppStageId,setUpdatedOppAccId);
       
       	if(!lstInsertedLease.isEmpty())
       		createLessees(setUpdatedOppStageId,lstInsertedLease);
  	}
    
     /**
     @MethodName        : insertLeasBasedOnOppstageName
     @param             : setUpdatedOppStageId,setUpdatedOppAccId
     @Description       : inserting Lease based on the Opportunity Stage Name and mapping the fields of Lease according to THOR-46      
    **/
    private List<Lease__c> insertLeasBasedOnOppstageName(Set<Id>setUpdatedOppStageId,Set<Id>setUpdatedOppAccId)
  	{
  	    Map<Id,Account> mapAccIdToName; 
	    Map<Id,Case> mapOppIdToMoveOutCase = new Map <Id,Case> ();
	    mapAccIdToName = new map<Id,Account>([SELECT Id,Name FROM Account WHERE Id IN :setUpdatedOppAccId]);
	    
	    set<Id> setOpportunityIdtoNotQuery = new set<Id>();
	    
	    List<Lease__c> lstLeaseToBeInserted = new List<Lease__c>();
	    List <Opportunity> lstUpdatedOpportunityInstance = new List <Opportunity> (); 
	    
	    for(Case objCase : [SELECT Id,Move_Out_Date__c,Opportunity__c
	                        FROM Case
	                        WHERE Opportunity__c IN : setUpdatedOppStageId AND RecordTypeId =: MOVEOUT_CASE_ID])
	    {
	        mapOppIdToMoveOutCase.put(objCase.Opportunity__c,objCase);
	    }                        
	    /*Added for THOR-74*/
	    for(Case objCase : [Select Id,Lease__c,Opportunity__c from Case where Opportunity__c IN :setUpdatedOppStageId AND (RecordTypeId =:MOVEOUT_CASE_ID OR RecordTypeId =:MOVEIN_CASE_ID) AND Opportunity__r.Lease__c != null])
	    {
	        setOpportunityIdtoNotQuery.add(objCase.Opportunity__c);
	    }
	    /*Added for THOR-74*/  
	    for(Opportunity objOpportunity : [SELECT Id,Lease_Start_date__c,Lease_Type__c,Lease_End_Date__c,AccountId,Apartment__c,Security_Deposit_Required__c,RecordtypeId,
	                	                  Monthly_Rent__c,StageName, Lease__c ,Insurance_Guaranty_Rider__c,Airbnb_Rider_Formula__c,House_Rules_and_Relations__c,
	                	                  Smoke_Free_Initiative_Rider__c,Terrace_Balcony_Rider__c,Pet_Rider__c,Pet_Fees__c,Lease_Offer_Notice__c,Early_Termination_Rider__c,
	                	                  J_51_Rider__c,Early_Occupancy_Rider__c,Early_Occupancy_Date__c,Storage__c,Lead_Paint_Notice__c,Window_Guards_Rider__c,W_9__c,W_8__c
	                                      FROM Opportunity 
                           				  WHERE Id IN:setUpdatedOppStageId AND Id NOT IN :setOpportunityIdtoNotQuery])
	    {
			Lease__c objLease = new Lease__c
			(
				Name = mapAccIdToName.get(objOpportunity.AccountId).Name + '  ' + ( (objOpportunity.Lease_Start_Date__c != null) ?(string.valueOf(objOpportunity.Lease_Start_Date__c)) : ''),
			    Type__c = objOpportunity.Lease_Type__c,Start_Date__c = objOpportunity.Lease_Start_date__c,End_Date__c = objOpportunity.Lease_End_Date__c,
	            Apartment__c = objOpportunity.Apartment__c,
	            Rent__c = objOpportunity.Monthly_Rent__c,
	            Financial_Responsible_Through_Date__c = objOpportunity.Lease_End_Date__c,
	            Security_Deposit__c = objOpportunity.Security_Deposit_Required__c,
	            Insurance_Guaranty_Rider__c  = objOpportunity.Insurance_Guaranty_Rider__c,
	            Airbnb_Rider__c  = objOpportunity.Airbnb_Rider_Formula__c,
	            House_Rules_and_Relations__c  = objOpportunity.House_Rules_and_Relations__c,
	            Smoke_Free_Initiative_Rider__c = objOpportunity.Smoke_Free_Initiative_Rider__c,
	            Terrace_Balcony_Rider__c  = objOpportunity.Terrace_Balcony_Rider__c,
	            Pet_Rider__c = objOpportunity.Pet_Rider__c,
	            Pet_Fees__c  = objOpportunity.Pet_Fees__c,
	            Lease_Offer_Notice__c = objOpportunity.Lease_Offer_Notice__c,
	            Early_Termination_Rider__c = objOpportunity.Early_Termination_Rider__c,
	            J_51_Rider__c  = objOpportunity.J_51_Rider__c,
	            Early_Occupancy_Rider__c  = objOpportunity.Early_Occupancy_Rider__c,
	            Early_Occupancy_Date__c = objOpportunity.Early_Occupancy_Date__c,
	            Storage__c = objOpportunity.Storage__c,
	            Lead_Paint_Notice__c  = objOpportunity.Lead_Paint_Notice__c,
	            Window_Guards_Rider__c = objOpportunity.Window_Guards_Rider__c,
	            W_9__c = objOpportunity.W_9__c,
	            W_8__c = objOpportunity.W_8__c
            );
            
	            
            if(!mapOppIdToMoveOutCase.isEmpty() && mapOppIdToMoveOutCase.containsKey(objOpportunity.Id))
                objLease.Move_Out_Date__c = Date.valueOf(mapOppIdToMoveOutCase.get(objOpportunity.Id).Move_Out_Date__c);
                
            if(objOpportunity.StageName == 'Lease Signed by Thor')
            {
            	if(objOpportunity.RecordTypeId == NEW_LEASE_OPPORTUNITY_ID || objOpportunity.RecordTypeId == TRANSFER_OPPORTUNITY_RECORDTYPEID)
            	{
                	objLease.Lease_Status__c = 'New';
            	}
            	else if(objOpportunity.RecordTypeId == RENEWAL_OPPORTUNITY_ID)
            	{
            		objLease.Lease_Status__c = 'Renewal';
            	}
            }
	              
            if(objLease.Apartment__c != null)
            {
              	lstLeaseToBeInserted.add(objLease);
              	Opportunity objOpp  = new Opportunity(Id = objOpportunity.Id); 
           		lstUpdatedOpportunityInstance.add(objOpp);
            }
	    }
	    
	    if(!lstLeaseToBeInserted.isEmpty())
      	{ 
	        insert lstLeaseToBeInserted;
	        
	        if(!lstUpdatedOpportunityInstance.isEmpty())
	        {
				for(integer i=0;i<lstUpdatedOpportunityInstance.size();i++)
	          	{
	            	lstUpdatedOpportunityInstance[i].Lease__c = lstLeaseToBeInserted[i].Id;
	          	}
	        }
      	}
      	if(!lstUpdatedOpportunityInstance.isEmpty())
      		update lstUpdatedOpportunityInstance;
	      
	    return lstLeaseToBeInserted;
  }
    
    /**
     @MethodName        : createLessees
     @param             : setOppIdToCreateLessees,lstInsertedLeases
     @Description       : Records on the Lessees object is created from Contact Roles records associated to the Opportunity from which this Lease is created upon Lease creation.      
    **/
    private void createLessees(Set <Id>setOppIdToCreateLessees,List <Lease__c> lstInsertedLeases)
  	{
    	List <Apartment_Lessee__c> lstApartment_Lessee = new List <Apartment_Lessee__c> ();
    	Map <Id,List<Contact_Role__c>> mapOppLeasIdToContactRoleList = new Map <Id,List<Contact_Role__c>> (); 
    	List<Contact_Role__c> lstcontactRoleAssosiatedToOpp = new List<Contact_Role__c> ();
    
    	for(Contact_Role__c objContactRole : [SELECT Id,Opportunity__c,Opportunity__r.Lease__c,Person_Account__c,Role__c
                    						  FROM Contact_Role__c
                    						  WHERE Opportunity__c IN:setOppIdToCreateLessees])
      	{
        	if(mapOppLeasIdToContactRoleList.containsKey(objContactRole.Opportunity__r.Lease__c))
      		{
        		lstcontactRoleAssosiatedToOpp = mapOppLeasIdToContactRoleList.get(objContactRole.Opportunity__r.Lease__c);
        		lstcontactRoleAssosiatedToOpp.add(objContactRole);
        		mapOppLeasIdToContactRoleList.put(objContactRole.Opportunity__r.Lease__c,lstcontactRoleAssosiatedToOpp);
      		}
      		else
        		mapOppLeasIdToContactRoleList.put(objContactRole.Opportunity__r.Lease__c,new List <Contact_Role__c>{objContactRole});
  		}
      
      	for(Lease__c objLease : lstInsertedLeases)
        {
        	if(mapOppLeasIdToContactRoleList != null && mapOppLeasIdToContactRoleList.containsKey(objLease.Id))
        	{
          		for(Contact_Role__c objContactRole : mapOppLeasIdToContactRoleList.get(objLease.Id))
          		{
		            Apartment_Lessee__c objApartment_Lessee = new Apartment_Lessee__c ();
		            objApartment_Lessee.Lease__c = objContactRole.Opportunity__r.Lease__c; 
		            objApartment_Lessee.Person_Account__c = objContactRole.Person_Account__c;
		            objApartment_Lessee.Role__c = objContactRole.Role__c;
		            lstApartment_Lessee.add(objApartment_Lessee);
          		}
        	}
      	}
      
      	if(!lstApartment_Lessee.isEmpty())
        	insert lstApartment_Lessee;
  	}
    
    /**
     @MethodName        : updateParentLease
     @param             : setOpportunityId,setLeaseId
     @Description       : Updating the Parent Lease record based on the Opportunity field update and mapping the fields according to the THOR-46        
   **/
    private void updateParentLease(Set <Id> setOpportunityId,Set <Id> setLeaseId)
  	{
    	Map <Id,Lease__c> mapIdToLease = new Map <Id,Lease__c> (); 
        List<Lease__c> lstleaseToBeUpdated = new List<Lease__c>();
        
        if(!setLeaseId.isEmpty())
      	{
      		for(Lease__c objLease : [SELECT Id,Rent__c, Security_Deposit__c,Type__c,Start_Date__c,Apartment__c,End_Date__c,Insurance_Guaranty_Rider__c,
      		                         Airbnb_Rider__c,House_Rules_and_Relations__c,Smoke_Free_Initiative_Rider__c,Terrace_Balcony_Rider__c,Pet_Rider__c,
      		                         Pet_Fees__c,Lease_Offer_Notice__c,Early_Termination_Rider__c,J_51_Rider__c,Early_Occupancy_Rider__c,Early_Occupancy_Date__c,
      		                         Storage__c,Lead_Paint_Notice__c,Window_Guards_Rider__c,W_9__c,W_8__c
                     				 FROM Lease__c
                     				 WHERE Id IN : setLeaseId])
        	{
          		mapIdToLease.put(objLease.Id,objLease);
        	}
        
        	for(Opportunity objOpportunity : [SELECT Id,Lease_Start_date__c,Lease_Type__c,Lease_End_Date__c,Apartment__c,Monthly_Rent__c,Lease__c,Security_Deposit_Required__c,
        	                                  Insurance_Guaranty_Rider__c,Airbnb_Rider_Formula__c,House_Rules_and_Relations__c	,Smoke_Free_Initiative_Rider__c,
        	                                  Terrace_Balcony_Rider__c,Pet_Rider__c,Pet_Fees__c,Lease_Offer_Notice__c,Early_Termination_Rider__c,J_51_Rider__c,
        	                                  Early_Occupancy_Rider__c,Early_Occupancy_Date__c,Storage__c,Lead_Paint_Notice__c,Window_Guards_Rider__c,W_9__c,W_8__c
                          				      FROM Opportunity 
                                              WHERE Id IN:setOpportunityId ])
        	{
          		if(mapIdToLease.containsKey(objOpportunity.Lease__c))
        		{
        			  Lease__c objLease = new Lease__c
        			  (
	        			  Id = objOpportunity.Lease__c,
	        			  Start_Date__c = objOpportunity.Lease_Start_date__c,
				          Type__c = objOpportunity.Lease_Type__c,
				          End_Date__c = objOpportunity.Lease_End_Date__c,
				          Security_Deposit__c = objOpportunity.Security_Deposit_Required__c,
				          Insurance_Guaranty_Rider__c = objOpportunity.Insurance_Guaranty_Rider__c,
				          Airbnb_Rider__c = objOpportunity.Airbnb_Rider_Formula__c,
				          House_Rules_and_Relations__c = objOpportunity.House_Rules_and_Relations__c,
				          Smoke_Free_Initiative_Rider__c = objOpportunity.Smoke_Free_Initiative_Rider__c,
				          Terrace_Balcony_Rider__c = objOpportunity.Terrace_Balcony_Rider__c,
				          Pet_Rider__c = objOpportunity.Pet_Rider__c,
				          Pet_Fees__c = objOpportunity.Pet_Fees__c,
				          Lease_Offer_Notice__c = objOpportunity.Lease_Offer_Notice__c,
				          Early_Termination_Rider__c = objOpportunity.Early_Termination_Rider__c,
				          J_51_Rider__c = objOpportunity.J_51_Rider__c,
				          Early_Occupancy_Rider__c = objOpportunity.Early_Occupancy_Rider__c,
				          Early_Occupancy_Date__c = objOpportunity.Early_Occupancy_Date__c,
				          Storage__c = objOpportunity.Storage__c,
				          Lead_Paint_Notice__c = objOpportunity.Lead_Paint_Notice__c,
				          Window_Guards_Rider__c = objOpportunity.Window_Guards_Rider__c, 
				          W_9__c = objOpportunity.W_9__c,
				          W_8__c = objOpportunity.W_8__c,
				          Rent__c = objOpportunity.Monthly_Rent__c
        			  );
			         
			          if(objOpportunity.Apartment__c != null)
			            objLease.Apartment__c = objOpportunity.Apartment__c;
			  
			          lstleaseToBeUpdated.add(objLease);
        		}
        	}
        	
        	if(!lstleaseToBeUpdated.isEmpty())
          		update lstleaseToBeUpdated;
      }
        
  }
    
    /*  
        * MethodName   : fetchRelatedContactRole
        * param        : set of opportunity ids which are updated
        * Description  : THOR-47: Method to fetch contact roles belongs to the updated Opp and role = Tenant
    */
    private void fetchRelatedContactRole(Set <Id> setGuarantorOppIds)
    {
		List <Contact_Role__c> lstContactRole = new List <Contact_Role__c> (); 
      	for(Contact_Role__c objContact_Role : [SELECT Id,Role__c,Email__c ,Opportunity__c,Person_Account__r.PersonContactId
                          					   FROM Contact_Role__c 
                          					   WHERE Opportunity__c IN :setGuarantorOppIds AND Role__c =: 'Tenant'])
    	{
      		if(objContact_Role.Email__c != null)
        		lstContactRole.add(objContact_Role);
    	}
    
	    if(!lstContactRole.isEmpty())
	      sendGuarantorEmail(lstContactRole);
    }
    
    /*
        * MethodName   : sendGuarantorEmail
        * param        : list of contact role
        * Description  : THOR-47: Method to send Email to the contact role's emails 
    */
    private void sendGuarantorEmail(List <Contact_Role__c> lstContactRole )
    {
		try
      	{
      		String[] toAddresses = new list<String>();
        	List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
      		EmailTemplate objEmailTemplate = [SELECT Id,Body FROM EmailTemplate WHERE DeveloperName = 'GUARANTOR_REQUIRED_RUPAL'];
      
      		for(Contact_Role__c objContRole : lstContactRole)
  			{
        		Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
         		objEmail.setWhatId(objContRole.Id);
         		objEmail.setTargetObjectId(objContRole.Person_Account__r.PersonContactId);
         		objEmail.setTemplateId(objEmailTemplate.Id);
        		lstMail.add(objEmail);
      		}
      		if(!lstMail.isEmpty()) 
        		Messaging.sendEmail(lstMail);
      	}
      	catch(Exception e)  
       	{
      		system.debug('----EXCEPTION-----'+e.getmessage());
      		return;
       	}
    }
    
    
    /*
        * MethodName   : updateTransferToApartmentFieldOnRenewalOpportunity
        * param        : List of transfer Opportunity
        * Description  : Method to update transfer to apartment field
    */
    private void updateTransferToApartmentFieldOnRenewalOpportunity(List<Opportunity> lstTransferOpportunity)
    {
    	Map<Id,Id> mapRenewalOpportunityId_TransferToApartment = new Map<Id,Id>();
    	List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
    	
    	///Craete a map of renewal opportunity id to transfer apartment
    	for(Opportunity objOpportunity:lstTransferOpportunity)
    	{
    		if(objOpportunity.Previous_Opportunity__c != null)
    			mapRenewalOpportunityId_TransferToApartment.put(objOpportunity.Previous_Opportunity__c, objOpportunity.Apartment__c);
    	}
    	
    	///Create data to update Transfer_To_Apartment__c on renewal opportunity
    	for(Opportunity objOpportunity:[SELECT Transfer_To_Apartment__c
    	                                FROM Opportunity
    	                                WHERE ID IN:mapRenewalOpportunityId_TransferToApartment.keyset()])
    	{
    		if(mapRenewalOpportunityId_TransferToApartment.containskey(objOpportunity.Id))
    			objOpportunity.Transfer_To_Apartment__c = mapRenewalOpportunityId_TransferToApartment.get(objOpportunity.Id);
    		
    		lstOpportunityToUpdate.add(objOpportunity);
    	}
    	
    	if(!lstOpportunityToUpdate.isEmpty())
    		update lstOpportunityToUpdate;
    }
    
    
    /*
        * MethodName   : updateCurrentTenantFieldOnApartment
        * param        : Map of Apartment id to account id
        * Description  : Method to update current tenant field on apartment with account name of opportunity
    */
    private void updateCurrentTenantFieldOnApartment(Map<Id,Id> mapApartmentId_AccountId)
    {
    	List<Apartment__c> lstApartmentToUpdate = new List<Apartment__c>();
    	
    	///Update current tenant field on Apartment
    	for(Apartment__c objApartment:[SELECT Id, Current_Tenant__c
    	                               FROM Apartment__c
    	                               WHERE Id IN:mapApartmentId_AccountId.keyset()])
    	{
    		objApartment.Current_Tenant__c = mapApartmentId_AccountId.get(objApartment.Id);
    		lstApartmentToUpdate.add(objApartment);
    	}
    	
    	if(!lstApartmentToUpdate.isEmpty())
    		update lstApartmentToUpdate;
    }
    
    
    /*
        * MethodName   : updateAccountOnContactRole
        * param        : List<Opportunity> lstOpportunity
        * Description  : Method to update current address on account associated to opportunity contact role from Opportunity Building
    */
    private void updateAccountOnContactRole(List<Opportunity> lstOpportunity)
    {
    	Map<Id,Account> mapAccountToUpdate = new Map<Id,Account>();
    	List<Contact_Role__c> lstContactRoleToUpdate = new List<Contact_Role__c>();
    	
    	
    	///Update account associated to contact role
    	for(Contact_Role__c objContactRole:[SELECT Id,Opportunity__c,Opportunity__r.Apartment__c,Opportunity__r.Apartment__r.Building__c,Person_Account__c,Person_Account__r.ShippingStreet,
    	                                    Person_Account__r.ShippingCity,Person_Account__r.ShippingState, Person_Account__r.ShippingPostalCode,Opportunity__r.Apartment__r.Building__r.Street_Address__c,
    	                                    Opportunity__r.Apartment__r.Building__r.City__c,Opportunity__r.Apartment__r.Building__r.State_For_Tenant__c,Opportunity__r.Apartment__r.Building__r.Zip_Code__c,
    	                                    Opportunity__r.Apartment__r.Building__r.Country__c,Current_Address_Street__c,Current_Address_City__c,Current_Address_State__c,
    	                                    Current_Address_ZIP__c,Current_Address_Country__c 
    	                                    FROM Contact_Role__c
    	                                    WHERE Opportunity__c IN:lstOpportunity AND (Role__c = 'Tenant' OR Role__c = 'Occupant')])
    	{
    		if(objContactRole.Opportunity__r.Apartment__c != null && objContactRole.Opportunity__r.Apartment__r.Building__c != null)
    		{
    			if(objContactRole.Person_Account__c != null)
    			{
	    			Account objAccount = new Account
	    			(
	    				Id = objContactRole.Person_Account__c,
	    			    ShippingStreet = objContactRole.Opportunity__r.Apartment__r.Building__r.Street_Address__c,
	    			    ShippingCity = objContactRole.Opportunity__r.Apartment__r.Building__r.City__c,
	    				ShippingPostalCode = objContactRole.Opportunity__r.Apartment__r.Building__r.Zip_Code__c,
	    				ShippingCountry = objContactRole.Opportunity__r.Apartment__r.Building__r.Country__c
	    			);
	    			
	    			///Set state on Person Account only if country is US
	    			if(objContactRole.Opportunity__r.Apartment__r.Building__r.Country__c == 'United States')
	    				objAccount.ShippingState  = objContactRole.Opportunity__r.Apartment__r.Building__r.State_For_Tenant__c;
	    				
	    			mapAccountToUpdate.put(objAccount.Id,objAccount);
    			}
    			
    			objContactRole.Current_Address_Street__c = objContactRole.Opportunity__r.Apartment__r.Building__r.Street_Address__c;
			    objContactRole.Current_Address_City__c = objContactRole.Opportunity__r.Apartment__r.Building__r.City__c;
				objContactRole.Current_Address_ZIP__c = objContactRole.Opportunity__r.Apartment__r.Building__r.Zip_Code__c;
				objContactRole.Current_Address_Country__c  = objContactRole.Opportunity__r.Apartment__r.Building__r.Country__c;
				
				///Set state on Person Account only if country is US
    			if(objContactRole.Opportunity__r.Apartment__r.Building__r.Country__c == 'United States')
    				objContactRole.Current_Address_State__c   = objContactRole.Opportunity__r.Apartment__r.Building__r.State_For_Tenant__c;
				
    			lstContactRoleToUpdate.add(objContactRole);              
    		}
    	}
    	
    	if(!mapAccountToUpdate.isEmpty())
    		update mapAccountToUpdate.values();
    		
    	if(!lstContactRoleToUpdate.isEmpty())
    		update lstContactRoleToUpdate;
    }
    
    
     /*
        * MethodName   : updateOpportunityFieldsBasedOnAccount
        * param        : List<Opportunity> lstOpportunity,Set<Id> setAccountId
        * Description  : Method to update Account_Current_Address__c,Person_Account_Email__c fields on Opportunity based on Account fields
    */
    private void updateOpportunityFieldsBasedOnAccount(List<Opportunity> lstOpportunity,Set<Id> setAccountId)
    {
    	Map<Id,String> mapAccountId_ShippingAddress = new Map<Id,String>();
    	Map<Id,String> mapAccountId_PersonEmail = new Map<Id,String>();
    	
    	///Create maps of accountid and account details
    	for(Account objAccount:[SELECT Id,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,PersonEmail
    	                        FROM Account
    	                        WHERE Id IN:setAccountId])
    	{
    		String strAddress = '';
    		
    		strAddress = (objAccount.ShippingStreet == null?'': objAccount.ShippingStreet + ',') + 	(objAccount.ShippingCity == null?'': objAccount.ShippingCity + ',') + 	
			             (objAccount.ShippingState == null?'': objAccount.ShippingState + ',') + (objAccount.ShippingPostalCode == null?'': objAccount.ShippingPostalCode + ',') + 	
			             (objAccount.ShippingCountry == null?'': objAccount.ShippingCountry + ',') ;
			
			if(strAddress != '')
    			strAddress = strAddress.Substring(0,strAddress.length()-1);
    				
    		if(objAccount.PersonEmail == null)
    			objAccount.PersonEmail = '';	
    			
    		mapAccountId_ShippingAddress.put(objAccount.Id,strAddress);
    		mapAccountId_PersonEmail.put(objAccount.Id,objAccount.PersonEmail);
    	}
    	
    	///Update Account_Current_Address__c,Person_Account_Email__c fields on Opportunity based on Account fields
    	for(Opportunity objOpportunity:lstOpportunity)
    	{
    		if(mapAccountId_ShippingAddress.containskey(objOpportunity.AccountId))
    			objOpportunity.Account_Current_Address__c = mapAccountId_ShippingAddress.get(objOpportunity.AccountId);
    			
    		if(mapAccountId_PersonEmail.containskey(objOpportunity.AccountId))
    			objOpportunity.Person_Account_Email__c = mapAccountId_PersonEmail.get(objOpportunity.AccountId);
    	}
    }
    
    
    /*
        * MethodName   : updateOpportunityFieldsBasedOnApartmentBuildingManager
        * param        : List<Opportunity> lstOpportunity,Set<Id> setApartmentId
        * Description  : Method to update Property_Manager_Email__c field on Opportunity based on Apartment__r.Building__r.Building_Manager__r.Email field
    */
    private void updateOpportunityFieldsBasedOnApartmentBuildingManager(List<Opportunity> lstOpportunity,Set<Id> setApartmentId)
    {
    	Map<Id,String> mapApartmentId_Email = new Map<Id,String>();
    	
    	for(Apartment__c objApartment:[SELECT Id,Building__c,Building__r.Building_Manager__c,Building__r.Building_Manager__r.Email
    	                               FROM Apartment__c
    	                               WHERE Id IN:setApartmentId]) 
    	{
    		if(objApartment.Building__c != null && objApartment.Building__r.Building_Manager__c != null)
    		{
    		    String eMail = '';
    		    system.debug('===>>>' + objApartment.Building__r.Building_Manager__r.Email);
    		    
    			if(objApartment.Building__r.Building_Manager__r.Email == null)
    			{
    			    eMail = '';
    			}
    			else
    			{
    				eMail = objApartment.Building__r.Building_Manager__r.Email;
    			}	
    			mapApartmentId_Email.put(objApartment.Id,objApartment.Building__r.Building_Manager__r.Email);
    		}
    		else if(objApartment.Building__c != null && objApartment.Building__r.Building_Manager__c == null)
    			mapApartmentId_Email.put(objApartment.Id,'');
    	}
    	
    	///Update Property_Manager_Email__c fields on Opportunity based on Apartment fields
    	for(Opportunity objOpportunity:lstOpportunity)
    	{
    		if(mapApartmentId_Email.containskey(objOpportunity.Apartment__c))
    			objOpportunity.Property_Manager_Email__c = mapApartmentId_Email.get(objOpportunity.Apartment__c);
    	}
    }
}