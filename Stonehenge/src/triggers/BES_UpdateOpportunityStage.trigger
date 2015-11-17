trigger BES_UpdateOpportunityStage on Property_to_Opportunity_Connector__c (before insert) {

	List<Property_to_Opportunity_Connector__c> lstPOC = new List<Property_to_Opportunity_Connector__c>();
	Set<Id> lstOpportunity = new Set<Id>();
	for(Integer i=0 ; i < Trigger.new.size();i++)
	{
		if(trigger.new[i].Opportunity__c != null)
		{
			if(lstOpportunity.contains(trigger.new[i].Opportunity__c))
			{
				//do nothing
			}
			else
			{
				lstOpportunity.add(trigger.new[i].Opportunity__c);
			}
		}	
	}
	if(lstOpportunity.size() > 0)
	{
		lstPOC = [Select Id, Opportunity__c From Property_to_Opportunity_Connector__c where Opportunity__c IN: lstOpportunity];
		List<Opportunity> lstOpportunityUpd = new List<Opportunity>();
		if(lstPOC.size() != 0)
		{
			for(Integer j=0 ; j < lstPOC.size();j++)
			{
				Opportunity objOpportunity = new Opportunity(Id=lstPOC[j].Opportunity__c);
					objOpportunity.StageName = 'Appointments';
					lstOpportunityUpd.add(objOpportunity);
			}
		}
		else
		{
			for(Integer k=0 ; k < lstOpportunity.size();k++)
			{
				Opportunity objOpportunity = new Opportunity(Id=trigger.new[k].Opportunity__c);
				objOpportunity.StageName = 'Appointments';
				lstOpportunityUpd.add(objOpportunity);
			}
		}
		try
		{
			if(lstOpportunityUpd.size() > 0)
			{
				update lstOpportunityUpd;
			}
		}
		catch(Exception ex)
		{
			System.debug(ex);
		}
	}
	

}