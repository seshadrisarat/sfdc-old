trigger BES_OnLeadConvertedToOpportunity on Lead (after update) 
{
	Map<Id,Lead> objMapLeadTobeUpdated = new Map<Id,Lead>();   
	Map<Id,Lead> objMapLeadTobeDeleted = new Map<Id,Lead>();
    for(Integer i = 0 ; i < Trigger.old.size(); i++)
    {
        for(Integer j = 0 ; j < Trigger.new.size(); j++)
        {
            if(Trigger.old[i].Id == Trigger.new[j].Id )
            {
                if(Trigger.old[i].IsConverted == false && Trigger.new[j].IsConverted == true && Trigger.new[j].ConvertedOpportunityId != null)
                {
                    if(objMapLeadTobeUpdated.size() < 1000)
                    {
                    	objMapLeadTobeUpdated.put(Trigger.new[j].Id,Trigger.new[j]);
                    }
                }
                else if(Trigger.old[i].IsConverted == false && Trigger.new[j].IsConverted == true && ((Trigger.new[j].ConvertedAccountId != null) || (Trigger.new[j].ConvertedContactId != null)))
                {
                	if(objMapLeadTobeDeleted.size() < 1000)
                	{
                		objMapLeadTobeDeleted.put(Trigger.new[j].Id,Trigger.new[j]);
                	}		
                } 
            }
        }
    }
    List<Property_to_Opportunity_Connector__c> lstPOCToBeDeleted = new List<Property_to_Opportunity_Connector__c>();
    List<Property_to_Opportunity_Connector__c> lstPOCToBeUpdated = new List<Property_to_Opportunity_Connector__c>();
    if(objMapLeadTobeDeleted.size() > 0)
    {
	    lstPOCToBeDeleted = [Select Property__c, Opportunity__c, Lead__c From Property_to_Opportunity_Connector__c where Lead__c IN:objMapLeadTobeDeleted.keyset()];
	    if(lstPOCToBeDeleted.size() > 0)
	    {	    	
	    	delete lstPOCToBeDeleted;
	    }
    }
    if(objMapLeadTobeUpdated.size() > 0)
    {
	    lstPOCToBeUpdated = [Select Property__c, Opportunity__c, Lead__c From Property_to_Opportunity_Connector__c where Lead__c IN:objMapLeadTobeUpdated.keyset()];
	    for(Integer i = 0;i < lstPOCToBeUpdated.size();i++ )
	    {    	
	    	lstPOCToBeUpdated[i].Opportunity__c = objMapLeadTobeUpdated.get(lstPOCToBeUpdated[i].Lead__c).ConvertedOpportunityId;
	    	lstPOCToBeUpdated[i].Lead__c = null;
	    }
	    if(lstPOCToBeUpdated.size() > 0)
	    {
	    	update lstPOCToBeUpdated;
	    }
    }    
}