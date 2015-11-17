/**  
* \arg ClassName        : SL_FundraisingOpportunityHandler
* \arg JIRATicket       : AEW-5, AEW-10, AEW-17
* \arg CreatedOn        : 02/Jan/2015
* \arg LastModifiedOn   : 14/Sept/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Pankaj Ganwani
* \arg Description      : Handler class for SL_FundraisingOpportunity trigger which is used to create 
                          record of Fundraising Opportunity Contact when Fundraising Opportunities records is inserted.
*/
public without sharing class SL_FundraisingOpportunityHandler 
{
    /* start - constructor */     
    public SL_FundraisingOpportunityHandler()
    {
        //do nothing
    }
    
    /**
    @MethodName : onBeforeInsert
    @Param      : List<Fundraising_Opportunity__c>
    @Description: This method will be used to populate Consultant__c, Opportunity_Type__c and Type_of_Client__c fields on inserted Fundraising Opportunity record. This function will calls updateFundRaisingOpportunities method for performing these operations.
    **/
    public static void onBeforeInsert(List<Fundraising_Opportunity__c> lstFundOpportunity)
    {
        updateFundRaisingOpportunities(lstFundOpportunity, NULL);
    }
    
    /**
    @MethodName : onBeforeUpdate
    @Param      : new and old map of Fundraising Opportunity records
    @Description: This method will be used to update Consultant__c, Opportunity_Type__c and Type_of_Client__c field values on updation of Fundraising Opportunity record. This function will calls updateFundRaisingOpportunities method for performing these operations.
    **/
    public static void onBeforeUpdate(Map<Id,Fundraising_Opportunity__c> mapNewFundraising, Map<Id,Fundraising_Opportunity__c> mapOldFundraising)
    {
        /* Update functionality has been commented as per the discussion happened with Zach on 11th Sept, 2015 */
        //updateFundRaisingOpportunities(mapNewFundraising.values(), mapOldFundraising);
    }
    
    /**
    @MethodName : updateFundRaisingOpportunities
    @Param      : list and old map of Fundraising Opportunity records
    @Description: This method will be used to update Consultant__c, Opportunity_Type__c and Type_of_Client__c field values on Fundraising Opportunity records based on related Organization and Fund values.
    **/
    private static void updateFundRaisingOpportunities(List<Fundraising_Opportunity__c> lstFundOpportunity, Map<Id,Fundraising_Opportunity__c> mapOldFundraising)
    {
        Set<Id> setFundIds = new Set<Id>();
        Set<Id> setOrgIdForConsultant = new Set<Id>();
        Set<Id> setOrgIdForClientInvestment = new Set<Id>();
        set<Id> setFundSeriesIds = new set<Id>();
        map<Id, Id> mapFundIdToFundSeriesIds = new map<Id, Id>();
        Map<Id, Id> mapOrgIdToParentId = new Map<Id, Id>();
        Map<Id, Set<Id>> mapParentIdToSetOfChildren = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapOrgIdToSetOfSiblings = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapChildAccountToGrandChildren = new Map<Id, Set<Id>>();        
        map<Id, List<Client_Investment__c>> mapFundSeriesIdToListOfCInvest = new map<Id, List<Client_Investment__c>>();
        
        Map<Id, Map<Id, List<Client_Investment__c>>> mapOrgIdToMapOfFundIdTolstCI = new Map<Id, Map<Id, List<Client_Investment__c>>>();
        
        for(Fundraising_Opportunity__c objFundraisingOpp : lstFundOpportunity)
        {
            if((Trigger.isInsert || (Trigger.isUpdate && (objFundraisingOpp.Organization__c!=mapOldFundraising.get(objFundraisingOpp.Id).Organization__c ||
                                                objFundraisingOpp.Fund__c != mapOldFundraising.get(objFundraisingOpp.Id).Fund__c))) && String.isNotEmpty(objFundraisingOpp.Organization__c))
            {
                setFundIds.add(objFundraisingOpp.Fund__c);
                setOrgIdForClientInvestment.add(objFundraisingOpp.Organization__c);             
                if(String.isEmpty(objFundraisingOpp.Consultant__c))
                {
                    setOrgIdForConsultant.add(objFundraisingOpp.Organization__c);
                }               
            }
        }
        
        Map<Id,Account> mapIdToAccount = new Map<Id,Account>([SELECT Id, Consultant_Organization__c FROM Account WHERE Id IN:setOrgIdForConsultant AND Consultant_Organization__c!=NULL]);
        Map<Id, Fund__c> mapIdToFund = new Map<Id,Fund__c>([SELECT Id, Fund_Series__c FROM Fund__c WHERE Id IN : setFundIds]);
        
        /*Added by Sandeep*/
        set<Id> setAllFundIds = new set<Id>(setFundIds);
        for(Fund__c objFund :mapIdToFund.values())
        {
            if(objFund.Fund_Series__c != null)
                setFundSeriesIds.add(objFund.Fund_Series__c);
        }
       
        for(Fund__c objFund :[SELECT Id, Fund_Series__c FROM Fund__c WHERE Fund_Series__c IN : setFundSeriesIds])
        {
            setAllFundIds.add(objFund.Id);
            mapFundIdToFundSeriesIds.put(objFund.Id, objFund.Fund_Series__c);
        }
        map<Id, Double> mapOrganizationIdToNoOfClientInvestment = new map<Id, Double>();
        
        for(AggregateResult agr : [select count(Id) countIds, Organization__c from Client_Investment__c WHERE Organization__c IN :setOrgIdForClientInvestment AND Status__c =: 'Active' group by Organization__c])
        {
            mapOrganizationIdToNoOfClientInvestment.put((Id)agr.get('Organization__c'), (Double)agr.get('countIds'));
        }
         /*Added by Sandeep*/
        
        /* Start -  Added By Pankaj Ganwani on 9/Sept/2015 as per the requirement of AEW-17 */
        Set<Id> setParentIds = new Set<Id>();// set to hold the parent ids of the related organization of inserted or update fundraising Opportunity record. 
        Set<Id> setAccountTemp = new Set<Id>();
        
        //fetching the parent accouts corresponding to the organizations of inserted fundraising Opportunity
        for(Account objAccount : [SELECT Id, ParentId FROM Account WHERE Id IN : setOrgIdForClientInvestment AND ParentId!=NULL])
        {
        	setParentIds.add(objAccount.ParentId);
        	mapOrgIdToParentId.put(objAccount.Id, objAccount.ParentId);
        }        
        setAccountTemp.addAll(setParentIds);
        
        
        //fetching siblings and grand children of the parent accounts.
        for(Account objAccount : [SELECT Id, ParentId, (SELECT Id FROM ChildAccounts) FROM Account WHERE ParentId IN : setParentIds])
        {
        	setAccountTemp.add(objAccount.Id);
        	setAccountTemp.addAll((new Map<Id,Account>(objAccount.ChildAccounts)).keyset());
        	
        	mapChildAccountToGrandChildren.put(objAccount.Id, (new Map<Id,Account>(objAccount.ChildAccounts)).keyset());
        	if(!mapParentIdToSetOfChildren.containskey(objAccount.ParentId))
        		mapParentIdToSetOfChildren.put(objAccount.ParentId, new Set<Id>{objAccount.Id});
        	else
        		mapParentIdToSetOfChildren.get(objAccount.ParentId).add(objAccount.Id);
        }
        
        for(Id accountId : setOrgIdForClientInvestment)
        {
        	if(mapOrgIdToParentId.containskey(accountId))
        	{
        		Id parentId = mapOrgIdToParentId.get(accountId);
        		Set<Id> setChildAccounts = mapParentIdToSetOfChildren.get(parentId);
        		setChildAccounts.remove(accountId);
        		mapOrgIdToSetOfSiblings.put(accountId, setChildAccounts);
        	}
        }
        
        setOrgIdForClientInvestment.addAll(setAccountTemp);   
        /* End -  Added By Pankaj Ganwani on 9/Sept/2015 as per the requirement of AEW-17 */
        
        for(Client_Investment__c objClientInvestment : [SELECT Fund__c, Fund__r.Fund_Series__c, Organization__c FROM Client_Investment__c WHERE (Organization__c IN : setOrgIdForClientInvestment OR Fund__c IN : setAllFundIds) AND Status__c =: 'Active'])
        {
            if(!mapOrgIdToMapOfFundIdTolstCI.containskey(objClientInvestment.Organization__c))
            {
            	mapOrgIdToMapOfFundIdTolstCI.put(objClientInvestment.Organization__c, new Map<Id, List<Client_Investment__c>>{objClientInvestment.Fund__c=>new List<Client_Investment__c>{objClientInvestment}});
            }
            else
            {
            	if(mapOrgIdToMapOfFundIdTolstCI.get(objClientInvestment.Organization__c).containskey(objClientInvestment.Fund__c))
            		mapOrgIdToMapOfFundIdTolstCI.get(objClientInvestment.Organization__c).get(objClientInvestment.Fund__c).add(objClientInvestment);
            	else
            		mapOrgIdToMapOfFundIdTolstCI.get(objClientInvestment.Organization__c).put(objClientInvestment.Fund__c, new List<Client_Investment__c>{objClientInvestment});
            }            
            
            if(objClientInvestment.Fund__r.Fund_Series__c != null)
            {
                if(!mapFundSeriesIdToListOfCInvest.containsKey(objClientInvestment.Fund__r.Fund_Series__c))
                    mapFundSeriesIdToListOfCInvest.put(objClientInvestment.Fund__r.Fund_Series__c, new List<Client_Investment__c>{objClientInvestment});
                else
                    mapFundSeriesIdToListOfCInvest.get(objClientInvestment.Fund__r.Fund_Series__c).add(objClientInvestment);
            }
        }
        
        for(Fundraising_Opportunity__c objFundraisingOpp : lstFundOpportunity)
        {
            if(String.isNotEmpty(objFundraisingOpp.Organization__c))
            {
                objFundraisingOpp.Consultant__c = mapIdToAccount.containskey(objFundraisingOpp.Organization__c) ? mapIdToAccount.get(objFundraisingOpp.Organization__c).Consultant_Organization__c : objFundraisingOpp.Consultant__c;
                
                if(mapOrgIdToMapOfFundIdTolstCI.containskey(objFundraisingOpp.Organization__c) || mapOrgIdToParentId.containskey(objFundraisingOpp.Organization__c) || mapOrgIdToSetOfSiblings.containskey(objFundraisingOpp.Organization__c) || mapChildAccountToGrandChildren.containskey(objFundraisingOpp.Organization__c))
                {
	                //checking for related organization
	                if(mapOrgIdToMapOfFundIdTolstCI.containskey(objFundraisingOpp.Organization__c))
	                {
	                	if(mapOrgIdToMapOfFundIdTolstCI.get(objFundraisingOpp.Organization__c).containskey(objFundraisingOpp.Fund__c))
	                	{
	                		objFundraisingOpp.Opportunity_Type__c ='Additional Investment';
	                		objFundraisingOpp.Type_of_Client__c =  'Prior Fund Investor';
	                	}
	                	else
	                	{
	                		objFundraisingOpp.Opportunity_Type__c = 'Initial Investment';
	                		if(mapIdToFund.containsKey(objFundraisingOpp.Fund__c) &&  mapIdToFund.get(objFundraisingOpp.Fund__c).Fund_Series__c == null)
	                        	objFundraisingOpp.Type_of_Client__c = 'New to Fund Series';
	                	}
	                	
	                	if(mapFundIdToFundSeriesIds.containsKey(objFundraisingOpp.Fund__c))
		                {
		                    objFundraisingOpp.Type_of_Client__c = mapFundSeriesIdToListOfCInvest.containsKey(mapFundIdToFundSeriesIds.get(objFundraisingOpp.Fund__c)) ?
		                                                                'Prior Fund Investor' :  'New to Fund Series';
		                }
	                }
	                //checking for related organization's parent
	                if(mapOrgIdToParentId.containskey(objFundraisingOpp.Organization__c))
	                {
	                	Id parentId = mapOrgIdToParentId.get(objFundraisingOpp.Organization__c);
	                	if(mapOrgIdToMapOfFundIdTolstCI.containskey(parentId))
	                	{
	                		if(mapOrgIdToMapOfFundIdTolstCI.get(parentId).containskey(objFundraisingOpp.Fund__c))
	                		{
	                			objFundraisingOpp.Opportunity_Type__c ='Additional Investment';
	                			objFundraisingOpp.Type_of_Client__c =  'Prior Fund Investor';
	                		}
	                		else
	                		{
	                			objFundraisingOpp.Opportunity_Type__c = 'Initial Investment';
	                			if(mapIdToFund.containsKey(objFundraisingOpp.Fund__c) &&  mapIdToFund.get(objFundraisingOpp.Fund__c).Fund_Series__c == null)
	                        		objFundraisingOpp.Type_of_Client__c = 'New to Fund Series';
	                		}
	                		
	                		if(mapFundIdToFundSeriesIds.containsKey(objFundraisingOpp.Fund__c))
			                {
			                    objFundraisingOpp.Type_of_Client__c = mapFundSeriesIdToListOfCInvest.containsKey(mapFundIdToFundSeriesIds.get(objFundraisingOpp.Fund__c)) ?
			                                                                'Prior Fund Investor' :  'New to Fund Series';
			                }
	                	}
	                	else
		                {
		                	objFundraisingOpp.Opportunity_Type__c = 'Initial Investment';
		                	objFundraisingOpp.Type_of_Client__c = 'New to Firm';                	
		                }   
	                }
	                //checking for related organization's siblings
	                if(mapOrgIdToSetOfSiblings.containskey(objFundraisingOpp.Organization__c))
	                {
	                	for(Id siblingAccount : mapOrgIdToSetOfSiblings.get(objFundraisingOpp.Organization__c))
	                	{
	                		if(mapOrgIdToMapOfFundIdTolstCI.containskey(siblingAccount))
		                	{
		                		if(mapOrgIdToMapOfFundIdTolstCI.get(siblingAccount).containskey(objFundraisingOpp.Fund__c))
		                		{
		                			objFundraisingOpp.Opportunity_Type__c ='Additional Investment';
		                			objFundraisingOpp.Type_of_Client__c =  'Prior Fund Investor';
		                		}
		                		else
		                		{
		                			objFundraisingOpp.Opportunity_Type__c = 'Initial Investment';
		                			if(mapIdToFund.containsKey(objFundraisingOpp.Fund__c) &&  mapIdToFund.get(objFundraisingOpp.Fund__c).Fund_Series__c == null)
		                        		objFundraisingOpp.Type_of_Client__c = 'New to Fund Series';
		                		}
		                		
		                		if(mapFundIdToFundSeriesIds.containsKey(objFundraisingOpp.Fund__c))
				                {
				                    objFundraisingOpp.Type_of_Client__c = mapFundSeriesIdToListOfCInvest.containsKey(mapFundIdToFundSeriesIds.get(objFundraisingOpp.Fund__c)) ?
				                                                                'Prior Fund Investor' :  'New to Fund Series';
				                }
		                	}
		                	else
			                {
			                	objFundraisingOpp.Opportunity_Type__c = 'Initial Investment';
			                	objFundraisingOpp.Type_of_Client__c = 'New to Firm';                	
			                }   
	                	}                	
	                }
	                //checking for related organization's grand children
	                if(mapChildAccountToGrandChildren.containskey(objFundraisingOpp.Organization__c))
	                {
	                	for(Id grandChild : mapOrgIdToSetOfSiblings.get(objFundraisingOpp.Organization__c))
	                	{
	                		if(mapOrgIdToMapOfFundIdTolstCI.containskey(grandChild))
		                	{
		                		if(mapOrgIdToMapOfFundIdTolstCI.get(grandChild).containskey(objFundraisingOpp.Fund__c))
		                		{
		                			objFundraisingOpp.Opportunity_Type__c ='Additional Investment';
		                			objFundraisingOpp.Type_of_Client__c =  'Prior Fund Investor';
		                		}
		                		else
		                		{
		                			objFundraisingOpp.Opportunity_Type__c = 'Initial Investment';
		                			if(mapIdToFund.containsKey(objFundraisingOpp.Fund__c) &&  mapIdToFund.get(objFundraisingOpp.Fund__c).Fund_Series__c == null)
		                        		objFundraisingOpp.Type_of_Client__c = 'New to Fund Series';
		                		}
		                		
		                		if(mapFundIdToFundSeriesIds.containsKey(objFundraisingOpp.Fund__c))
				                {
				                    objFundraisingOpp.Type_of_Client__c = mapFundSeriesIdToListOfCInvest.containsKey(mapFundIdToFundSeriesIds.get(objFundraisingOpp.Fund__c)) ?
				                                                                'Prior Fund Investor' :  'New to Fund Series';
				                }
		                	}
		                	else
			                {
			                	objFundraisingOpp.Opportunity_Type__c = 'Initial Investment';
			                	objFundraisingOpp.Type_of_Client__c = 'New to Firm';                	
			                }   
	                	}                	
	                }
                }
                else
                {
                	objFundraisingOpp.Opportunity_Type__c = 'Initial Investment';
                	objFundraisingOpp.Type_of_Client__c = 'New to Firm';                	
                }                
            }
            else
            {
                objFundraisingOpp.Consultant__c = objFundraisingOpp.Opportunity_Type__c = objFundraisingOpp.Type_of_Client__c = NULL;
            }
        }
    }
    /* Developed by Pankaj*/
    
    /**
    @MethodName : onAfterInsert
    @Param      : List<Fundraising_Opportunity__c>
    @Description: This method will be used to create Fundraising Opportunity Contact records on Fundraising Opportunity.
    **/
    public void onAfterInsert(List<Fundraising_Opportunity__c> lstFundOpportunity) 
    {
        Set<Id> setAccountId = new Set<Id>(); //Set of Account id.
        Map<Id, Set<Id>> mapAccountIdToSetContactId = new Map<Id, Set<Id>>(); //Map of account id to set of primary contact id.
        List<Fundraising_Opportunity_Contact__c> lstFundraisingOppConToInsert = new List<Fundraising_Opportunity_Contact__c>(); //List of Fundraising Opportunity Contact to insert
        
        //Iterating on Fundraising Opportunity to create set of account id.
        for(Fundraising_Opportunity__c objFundOpp : lstFundOpportunity)
        {
            if(objFundOpp.Organization__c != null)
                setAccountId.add(objFundOpp.Organization__c);
        }
        
        //Querying the Contact record on the bases of Account Id store in the setAccountId.
        for(Contact objContact : [SELECT Id, 
                                         Name, 
                                         AccountId, 
                                         Primary_IR_Contact__c 
                                    FROM Contact
                                   WHERE AccountId IN : setAccountId
                                     AND Primary_IR_Contact__c = true])
        {
            if(mapAccountIdToSetContactId.containskey(objContact.AccountId))
                mapAccountIdToSetContactId.get(objContact.AccountId).add(objContact.Id);
            else
                mapAccountIdToSetContactId.put(objContact.AccountId, new Set<Id>{objContact.Id});
        }
        //Iterating on Fundraising Opportunity to create Fundraising Opportunity Contact records.
        for(Fundraising_Opportunity__c objFundOpp : lstFundOpportunity)
        {
            if(mapAccountIdToSetContactId.containskey(objFundOpp.Organization__c))
            {
                for(Id contactId : mapAccountIdToSetContactId.get(objFundOpp.Organization__c))
                {
                    lstFundraisingOppConToInsert.add(new Fundraising_Opportunity_Contact__c(Contact__c = contactId, 
                                                                                            Fundraising_Opportunity__c = objFundOpp.Id));
                }
            }
        }
        
        if(!lstFundraisingOppConToInsert.isempty())
            insert lstFundraisingOppConToInsert;
    }
}