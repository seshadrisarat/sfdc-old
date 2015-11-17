/**
* \arg ClassName      : SL_DealHandler
* \arg JIRATicket     : CAINSUPP-5
* \arg CreatedOn      : 09/12/2013
* \arg CreatededBy    : Praful
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class works as handler for SL_Deal Trigger.
*/
public with sharing class SL_DealHandler 
{
    /* Start - Variables */
    /* End -  Variables */  
    
    /* Start -  Constructor */
    public SL_DealHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */    
    
    /*!
        * MethodName : onAfterInsert
        * param      : map of newly inserted Deals
        * Description: This method is called after insertion of the Deal
    */
    public void onAfterInsert(Map<Id, Deal__c> mapIdToDeal)
    {
        Set<Id> setOpportunityId = new Set<Id>();//Set to get all OpportunityId from Deal 
        
        //Iterating on Deal to get OpportunityId
        for(Deal__c objDeal : mapIdToDeal.values())
        {
            if(objDeal.Opportunity__c!=null)
            	setOpportunityId.add(objDeal.Opportunity__c);
        }
        
        //Invoking createCainTeamMember method to create cain team members records 
        if(!setOpportunityId.isEmpty())
        {
            createCainTeamMember(mapIdToDeal, setOpportunityId);
            updatePotentialBuyerSeller(mapIdToDeal,setOpportunityId);
        }   
    }
    /* End */
    
    /*!
        * MethodName : onAfterUpdate
        * param      : map of New and Old Deals
        * Description: This method is called after updation of the Deal
    */    
    public void onAfterUpdate(Map<Id, Deal__c> mapNewDeal, Map<Id, Deal__c> mapOldDeal)
    {
        Map<Id, Deal__c> mapIdToDeal = new Map<Id, Deal__c>();//Map to get OpportunityId and Deal
        Set<Id> setOpportunityId = new Set<Id>();//Set to get all OpportunityId from Deal 
        Set<Id> setDealId = new Set<Id>();//Set to get all Old OpportunityId from Deal
        List<Cain_Deal_Team__c> lstCDTeamToDelete = new List<Cain_Deal_Team__c>();//List to get CainDealTeam to Delete
        List<Potential_Buyer_Seller__c> lstPotentialBuyerSeller = new List<Potential_Buyer_Seller__c>();//List to get PotentialBuyerSeller to update
        
        //Iterating over Deal to get new OpportunityId
        for(Deal__c objDeal : mapNewDeal.values())
        {
            //Checking if new opportunityId is not equals to old opportunityId
            if(objDeal.Opportunity__c != mapOldDeal.get(objDeal.Id).Opportunity__c)
            {
                setDealId.add(objDeal.Id);
                setOpportunityId.add(objDeal.Opportunity__c);
                mapIdToDeal.put(objDeal.Id, objDeal);
            }
        }
        
        //Iterating over PotentialBuyerSeller to set null value to corresponding Deal    
        for(Potential_Buyer_Seller__c objPotentialBuyerSeller : [SELECT Id,Deal__c FROM Potential_Buyer_Seller__c WHERE Deal__c IN : setDealId])
        {
        	lstPotentialBuyerSeller.add(new Potential_Buyer_Seller__c(Id = objPotentialBuyerSeller.Id, Deal__c = null));
        }
        
        //perform update DML
        if(!lstPotentialBuyerSeller.isEmpty())
        	update lstPotentialBuyerSeller;
        	
        //Fetching old CainDealTeam records to delete
        lstCDTeamToDelete = [SELECT Id 
                             FROM Cain_Deal_Team__c 
                             WHERE Deal__c IN : mapIdToDeal.keySet()];
        
        //perform delete dml
        if(!lstCDTeamToDelete.isEmpty())
            delete lstCDTeamToDelete;
        
        //Invoking createCainTeamMember method to create cain team members records  
        if(!setOpportunityId.isEmpty())
        {
            createCainTeamMember(mapIdToDeal, setOpportunityId);
            updatePotentialBuyerSeller(mapIdToDeal,setOpportunityId);
        }
        
    }
    /* End */
    
    /*!
        * MethodName : onBeforeDelete
        * param      : map of Old Deals
        * Description: This method is called before deletion of a Deal
    */   
    public void onBeforeDelete(Map<Id,Deal__c> mapIdToDeal)
    {
    	List<Potential_Buyer_Seller__c> lstPotentialBuyerSeller = new List<Potential_Buyer_Seller__c>();
    	//Iterating over potential buyer and seller records where opportunity is null and deal contained in map keyset
    	for(Potential_Buyer_Seller__c objPotentialBuyerSeller : [SELECT Id FROM Potential_Buyer_Seller__c WHERE Deal__c IN : mapIdToDeal.keyset() AND Opportunity__c =: NULL])
    	{
    		lstPotentialBuyerSeller.add(objPotentialBuyerSeller);
    	}
    	//perfrom delete dml
    	if(!lstPotentialBuyerSeller.isEmpty())
    		delete lstPotentialBuyerSeller;
    }
    /* End */
    
    /*!
        * MethodName : createCainTeamMember
        * param      : map of IdToDeal and Set of OpportunityId.
        * Description: This method is called for both onAfterInsert and onAfterUpdate
    */  
    private void createCainTeamMember(Map<Id, Deal__c> mapIdToDeal, Set<Id> setOpportunityId)
    {
        Map<Id, List<Cain_Opportunity_Team__c>> mapOpportunityIdToCainOpportunityTeam = new Map<Id, List<Cain_Opportunity_Team__c>>();//Map of OpportunityId and list of Cain_Opportunity_Team records.
        List<Cain_Deal_Team__c> lstCDTeam = new List<Cain_Deal_Team__c>();//List of CainDealTeam to insert 
        
        //Iterating over CainOpportunityTeam to get no. of OpportunityTeam 
        for(Cain_Opportunity_Team__c objOT : [SELECT Team_Member__c, Role__c, Opportunity__c, Relationship_Banker_Number__c
                                              FROM Cain_Opportunity_Team__c
                                              WHERE Opportunity__c =: setOpportunityId])
        {
            if(mapOpportunityIdToCainOpportunityTeam.containsKey(objOT.Opportunity__c))
                mapOpportunityIdToCainOpportunityTeam.get(objOT.Opportunity__c).add(objOT);
            else
                mapOpportunityIdToCainOpportunityTeam.put(objOT.Opportunity__c, new List<Cain_Opportunity_Team__c>{objOT});
        }
        
        //Iterating over Deal to get dealId and OpportunityId
        for(Deal__c objDeal : mapIdToDeal.values())
        {
            if(mapOpportunityIdToCainOpportunityTeam.containsKey(objDeal.Opportunity__c))
            {
                //Iterating over CainOpportunityTeam to create CainDealTeam records 
                for(Cain_Opportunity_Team__c objOT : mapOpportunityIdToCainOpportunityTeam.get(objDeal.Opportunity__c))
                {
                    lstCDTeam.add(new Cain_Deal_Team__c(Deal__c = objDeal.Id, 
                                                        Role__c = objOT.Role__c,    
                                                        Team_Member__c = objOT.Team_Member__c,
                                                        Relationship_Banker_Number__c = objOT.Relationship_Banker_Number__c));
                }
            }
        }
        
        //perform insert dml
        if(!lstCDTeam.isEmpty())
            insert lstCDTeam;
    }
    /* End */
    
     /*!
        * MethodName : updatePotentialBuyerSeller
        * param      : map of IdToDeal and Set of Opportunity Ids.
        * Description: This method is called for both onAfterInsert and onAfterUpdate
    */  
    private void updatePotentialBuyerSeller(Map<Id,Deal__c> mapIdToDeal,Set<Id> setOpportunityId)
    {
    	Map<Id,List<Potential_Buyer_Seller__c>> mapOpportunityIdToLstOfPBS = new Map<Id,List<Potential_Buyer_Seller__c>>();//map to contain opportunity id and its corresponding PBS
    	List<Potential_Buyer_Seller__c> lstPotentialBuyerSeller = new List<Potential_Buyer_Seller__c>();//List to contain values of PBS that are to be updated or created
    	//Iterating over potential buyer/seller record to fill the map with opportunity id and its corresponding potential buyer/seller records
    	for(Potential_Buyer_Seller__c objPortentialBuyerSeller : [SELECT Assigned_to_call__c, Comments__c, Company_Name__c, Deal__c, Declined_Notes__c, 
    											         				 Declined_Reasons__c, Final_Indication_Range__c, Final_Round_EBITDA_Multiple__c,
    											         				 Final_Stage__c, First_Round_EBITDA_Multiple__c, Initital_Indication_Range__c,
    											         				 Invited_to_Phase_2__c, Opportunity__c, Status__c 
    											  				 FROM 	 Potential_Buyer_Seller__c 
    											  				 WHERE 	 Opportunity__c IN:setOpportunityId])
    	{
    		if(!mapOpportunityIdToLstOfPBS.containskey(objPortentialBuyerSeller.Opportunity__c))
    			mapOpportunityIdToLstOfPBS.put(objPortentialBuyerSeller.Opportunity__c,new List<Potential_Buyer_Seller__c>{objPortentialBuyerSeller});
    		else
    			mapOpportunityIdToLstOfPBS.get(objPortentialBuyerSeller.Opportunity__c).add(objPortentialBuyerSeller);
    	}
    	
    	//Iterating over Deal object to create or update related potential buyer/seller records
    	for(Deal__c objDeal : mapIdToDeal.values())
    	{
    		//Checking if map contains opportunity id
    		if(mapOpportunityIdToLstOfPBS.containskey(objDeal.Opportunity__c))
    		{
	    		//Iterating over potential buyer/seller records related to the opportunity of current deal
	    		for(Potential_Buyer_Seller__c objPotentialBuyerSeller : mapOpportunityIdToLstOfPBS.get(objDeal.Opportunity__c))
	    		{
	    			//Checking if potential buyer/seller's deal id is not null
	    			if(objPotentialBuyerSeller.Deal__c!=null)
	    			{
	    				lstPotentialBuyerSeller.add(new Potential_Buyer_Seller__c(Assigned_to_call__c = objPotentialBuyerSeller.Assigned_to_call__c,
	    																		  Comments__c = objPotentialBuyerSeller.Comments__c,
	    																		  Company_Name__c = objPotentialBuyerSeller.Company_Name__c,
	    																		  Deal__c = objDeal.Id,Declined_Notes__c = objPotentialBuyerSeller.Declined_Notes__c,
	    																		  Declined_Reasons__c = objPotentialBuyerSeller.Declined_Reasons__c,
	    																		  Final_Indication_Range__c = objPotentialBuyerSeller.Final_Indication_Range__c,
	    																		  Final_Round_EBITDA_Multiple__c = objPotentialBuyerSeller.Final_Round_EBITDA_Multiple__c,
	    																		  Final_Stage__c = objPotentialBuyerSeller.Final_Stage__c,
	    																		  First_Round_EBITDA_Multiple__c = objPotentialBuyerSeller.First_Round_EBITDA_Multiple__c,
	    																		  Initital_Indication_Range__c = objPotentialBuyerSeller.Initital_Indication_Range__c,
	    																		  Invited_to_Phase_2__c = objPotentialBuyerSeller.Invited_to_Phase_2__c,
	    																		  Opportunity__c = objPotentialBuyerSeller.Opportunity__c,
	    																		  Status__c = objPotentialBuyerSeller.Status__c));
	    			}
	    			//If deal id is null then we simply update the deal field with the current deal
	    			else
	    			{
	    				lstPotentialBuyerSeller.add(new Potential_Buyer_Seller__c(Id = objPotentialBuyerSeller.Id,Deal__c = objDeal.Id));
	    			}    				
	    		}
    		}
    	}
    	//Checking if list is not empty
    	if(!lstPotentialBuyerSeller.isEmpty())
    		upsert lstPotentialBuyerSeller;
    }
    /* End */
}