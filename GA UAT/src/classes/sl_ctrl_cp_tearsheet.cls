public with sharing class sl_ctrl_cp_tearsheet
{
	public String contJSONstr {get;set;}
	
	public sl_ctrl_cp_tearsheet()
	{
		Id acctId = ApexPages.currentPage().getParameters().get('acctId');

		Contact[] cList = [Select Id,Name,Include_for_Drawloop__c
						 From Contact
						 WHERE AccountId =: acctId
						 ORDER BY Name ASC];

		contJSON[] cJSON = new contJSON[]{};

		for(Contact c : cList)
		{
			cJSON.add(new contJSON(c.Id,c.Name));
		}

		contJSONstr = JSON.serialize(cJSON);		
	}

	@RemoteAction
    public static String setDLFlag(Id acctId, Id[] cIds, String ddpId, String deployId)
    {
    	Set<Id> setIds = new Set<Id>();
    	setIds.addAll(cIds);

    	Contact[] cList = [Select Id,Name,Include_for_Drawloop__c
						 From Contact
						 WHERE AccountId =: acctId];

		for(Contact c : cList)
		{
			if(setIds.contains(c.Id))
			{
				c.Include_for_Drawloop__c = true;
			}else
			{
				c.Include_for_Drawloop__c = false;
			}
		}

		update cList;	 

    	return '/apex/loop__looplus?sessionId='+UserInfo.getSessionId()+'&eid='+acctId+'&ddpIds='+ddpId+'&deploy='+deployId+'&autorun=true';
    }

	public class contJSON
	{
		public Id cId;
		public String cName;

		public contJSON(Id cId, String cName)
		{
			this.cId = cId;
			this.cName = cName;
		}
	}
}