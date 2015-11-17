trigger BES_UpdatePropertyStatus on Opportunity (after insert,after update)
{
	/*if(trigger.isAfter)
	{
		List<Property__c> lstProperty = new List<Property__c>();
		Map<Id,Opportunity> mapOpprIds = new Map<Id,Opportunity>();
		Map<Id,Opportunity> mapPropertyIds = new Map<Id,Opportunity>();
		for(Integer i=0;i<trigger.new.size();i++)
		{
			if(trigger.new[i].StageName == 'Signed Lease' && trigger.new[i].Property__c != null)
			{
				mapOpprIds.put(trigger.new[i].Id,trigger.new[i]);
				mapPropertyIds.put(trigger.new[i].Property__c,trigger.new[i]);		
				Property__c objProperty = new Property__c(Id=trigger.new[i].Property__c);
				objProperty.Unit_Status__c = 'Rented';
				objProperty.UnitStatusUpdateDate__c = System.Date.today();
				lstProperty.add(objProperty); 
			}
		}
		if(lstProperty.size() > 0)
		{
			update lstProperty;
			/*List<Property_to_Opportunity_Connector__c> lstPOCToBeUpdated = [Select Id, Property__c, Opportunity__c,status__c From Property_to_Opportunity_Connector__c where Opportunity__c IN:mapOpprIds.keyset() and Property__c IN:mapPropertyIds.keySet()];
			for(Integer j=0;j<lstPOCToBeUpdated.size();j++)
			{
				lstPOCToBeUpdated[j].Status__c = 'Unavailable - Lease Signed';								
			}
			if(lstPOCToBeUpdated.size() > 0)
			{
				update lstPOCToBeUpdated; 
			}
		}
		
		
	}*/
}