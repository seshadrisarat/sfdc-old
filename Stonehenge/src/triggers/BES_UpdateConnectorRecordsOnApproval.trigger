trigger BES_UpdateConnectorRecordsOnApproval on Opportunity (after update) 
{
	List<Property_to_Opportunity_Connector__c> lstPropOppConnectorRecords = new List<Property_to_Opportunity_Connector__c>();

	Set<Id>	setOppId = new Set<Id>();
	Set<Id>	setOppPropId = new Set<Id>();
		
	for(Integer i=0;i < Trigger.new.size();i++)
	{
		if(Trigger.new[i].Approval_Status__c == 'Approved')
		{
			setOppId.add(Trigger.new[i].Id);
			if(Trigger.new[i].Property__c != null)
				setOppPropId.add(Trigger.new[i].Property__c);
		}
	}
	
	if(setOppId.size() > 0)
	{
		lstPropOppConnectorRecords = [Select Id, Status__c From Property_to_Opportunity_Connector__c where (Property__c in :setOppId or Opportunity__r.IsClosed = false or Lead__c != null) limit 1000 FOR UPDATE];
	}
	
	for(Integer i=0; i < lstPropOppConnectorRecords.size();i++)
	{
		lstPropOppConnectorRecords[i].Status__c = 'In Progress';
	}
	
	if(lstPropOppConnectorRecords.size() > 0)
	{
		update lstPropOppConnectorRecords;
	}
}