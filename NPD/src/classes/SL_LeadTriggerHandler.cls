/**  
* \arg ClassName        : SL_LeadTriggerHandler
* \arg JIRATicket       : NPD-213
* \arg CreatedOn        : 13/Oct/2015
* \arg LastModifiedOn   : 13/Oct/2015
* \arg CreatededBy      : Smriti
* \arg ModifiedBy       : Smriti
* \arg Description      : Handler class for Lead object.
*/
global class SL_LeadTriggerHandler extends SL_TriggerHandlerBase {
    
    private static final Id PracticeAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Account').getRecordTypeId(); /*
        Added by Smriti for NPD-213
    */
	public override void beforeInsert(List<SObject> newListGeneric){
		List<Lead> newList = (List<Lead>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		
		/*BEFORE INSERT METHODS END*/
	}
	
	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Lead> oldMap = (Map<Id, Lead>) oldMapGeneric;
		Map<Id, Lead> newMap = (Map<Id, Lead>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Lead> oldMap = (Map<Id, Lead>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, Lead> newMap = (Map<Id, Lead>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Lead> oldMap = (Map<Id, Lead>) oldMapGeneric;
		Map<Id, Lead> newMap = (Map<Id, Lead>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		createPracticeAccountsAndReparentOpportunities(oldMap,newMap);
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Lead> oldMap = (Map<Id, Lead>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, Lead> newMap = (Map<Id, Lead>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	
	 /*
        Added by Smriti for NPD-213
    */
    public void createPracticeAccountsAndReparentOpportunities(map<Id,Lead> mapOldLeads , map<Id,Lead> mapNewLeads)
    {
        set<Id> setConvertedOpportunityIds = new set<Id>();
        set<Id> setConvertedAccountIds = new set<Id>();
        
        map<Id,Practice__c> mapConvertedAccountIdToPracticeAccount = new map<Id,Practice__c>();
        map<Id,Practice__c> mapIdToPractice = new map<Id,Practice__c>();
        map<Id,Account> mapLeadIdToAccount = new map<Id,Account>();
        map<Id,Id> mapConvertedOpportunityIdToAccountId = new map<Id,Id>();
        map<Id,Account> mapConvertedAccountIdToAccount = new map<Id,Account>();
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        
        for(Lead objLead : mapNewLeads.values())
        {
            setConvertedOpportunityIds.add(objLead.ConvertedOpportunityId);
            setConvertedAccountIds.add(objLead.ConvertedAccountId);
        }
        
        for(Practice__c objPractice : [Select Id from Practice__c]) 
        {
            mapIdToPractice.put(objPractice.Id, objPractice);
        }
        
        for(Opportunity objOpportunity : [  Select  Id,
                                                    AccountId
                                            from    Opportunity
                                            Where   Id IN:setConvertedOpportunityIds])
        {
            lstOpp.add(objOpportunity);
        }
        
        for(Account objAccount : [Select Id, 
                                         RecordTypeId,
                                         Company_Account__c,
                                         Practice__c
                                  FROM   Account 
                                  Where  Company_Account__c IN:setConvertedAccountIds
                                  AND    RecordTypeId=:PracticeAccountRecordTypeId])  
        {
            mapConvertedAccountIdToPracticeAccount.put(objAccount.Company_Account__c,mapIdToPractice.get(objAccount.Practice__c));
        }
        
        for(Account objAccount: [Select Id,
                                        BillingCountry,
                                        BillingCity,
                                        BillingCountryCode,
                                        BillingLatitude,
                                        BillingLongitude,
                                        BillingPostalCode,
                                        BillingState,
                                        BillingStateCode,
                                        BillingStreet
                                        FROM Account
                                 Where  Id IN:mapConvertedAccountIdToPracticeAccount.keyset()])
        {
            mapConvertedAccountIdToAccount.put(objAccount.Id,objAccount);
        }
        
        
        for(Lead objLead : mapNewLeads.values())
        {
            if(mapConvertedAccountIdToPracticeAccount.get(objLead.ConvertedAccountId) != null)
            { 
                if(objLead.Practice__c !=   mapConvertedAccountIdToPracticeAccount.get(objLead.ConvertedAccountId).Id)   
                                            mapLeadIdToAccount.put(objLead.Id, new Account( Name='AUTO-GENERATED', Practice__c = objLead.Practice__c, RecordTypeId=PracticeAccountRecordTypeId,
                                                                                            BillingCountry = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingCountry,
                                                                                            BillingCity = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingCity,
                                                                                            BillingCountryCode = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingCountryCode,
                                                                                            BillingLatitude = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingLatitude,
                                                                                            BillingLongitude = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingLongitude,
                                                                                            BillingPostalCode = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingPostalCode,
                                                                                            BillingState = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingState,
                                                                                            BillingStateCode = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingStateCode,
                                                                                            BillingStreet = mapConvertedAccountIdToAccount.get(objLead.ConvertedAccountId).BillingStreet
                    ));
            }
            
            if(!mapLeadIdToAccount.values().isEmpty())
                insert mapLeadIdToAccount.values();
            
            for(Opportunity objOpportunity :lstOpp)
            {
                if(mapLeadIdToAccount.get(objLead.Id) != null)
                       mapConvertedOpportunityIdToAccountId.put(objOpportunity.Id, mapLeadIdToAccount.get(objLead.Id).Id);
                else
                       mapConvertedOpportunityIdToAccountId.put(objOpportunity.Id, mapNewLeads.get(objLead.Id).ConvertedAccountId);
            }
        }
        
        for(Opportunity objOpp : [Select Id,AccountId,Opportunity_Brief_Description__c from Opportunity where Id IN:mapConvertedOpportunityIdToAccountId.keyset()])
        {
            objOpp.AccountId = mapConvertedOpportunityIdToAccountId.get(objOpp.Id);
            if(objOpp.Opportunity_Brief_Description__c == null)
              objOpp.Opportunity_Brief_Description__c =  'Test Updated via apex';
            lstOppToUpdate.add(objOpp);
        }
        
            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
       
    }
}