trigger BES_UpdateConnectorOnLeadConversion on Lead (after update) 
{
	List<Lead> lstConvertedLeads = new List<Lead>();
	List<Task> lstTaskRecords = new List<Task>();
	
	Set<Id> setLeadIds = new Set<Id>();
	
	for(Integer i=0 ; i < Trigger.new.size();i++ )
	{
		if(Trigger.new[i].IsConverted)
		{
			lstConvertedLeads.add(Trigger.new[i]);
			setLeadIds.add(Trigger.new[i].Id);
		}
	}
	
	if(setLeadIds.size() > 0)
	{
		lstTaskRecords = [Select Id, WhoId from Task where WhoId in : setLeadIds];
		if(lstTaskRecords.size() > 0)
		{
			for(Integer i=0;i < lstTaskRecords.size();i++)
			{
				String strConvContactId = '';
				for(Integer j=0;j < lstConvertedLeads.size();j++)
				{
					if(lstConvertedLeads[j].Id == lstTaskRecords[i].WhoId)
					{
						strConvContactId = lstConvertedLeads[j].ConvertedContactId;
						break;	
					}					
				}
				lstTaskRecords[i].WhoId = strConvContactId;
			}
			update lstTaskRecords;
		}		
		
	}
}