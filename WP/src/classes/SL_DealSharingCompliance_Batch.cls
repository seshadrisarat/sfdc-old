global without sharing class SL_DealSharingCompliance_Batch implements Database.Batchable<Sobject>
{
	global string query;
	
	global SL_DealSharingCompliance_Batch(string q)
	{
		query = q;
	}
	
	global SL_DealSharingCompliance_Batch()  
	{
		//query = 'Select Id, Account_Status__c From Account';
		//Select d.UserOrGroupId, d.ParentId, d.LastModifiedDate, d.LastModifiedById, d.Id From Deal__Share d
		SLDealSharingCompliance__c CS = SLDealSharingCompliance__c.getOrgDefaults();
		//system.debug('>>>>>>>>>>>'+CS.LastRunTime__c);
		query = 'Select UserOrGroupId, ParentId, LastModifiedDate, LastModifiedById, Id From Deal__Share where RowCause=\'Manual\' and LastModifiedDate>';
		if(CS==null || CS.LastRunTime__c==null) query += '2010-01-01T00:00:00Z';
		else query += (''+CS.LastRunTime__c).substring(0,10)+'T'+(''+CS.LastRunTime__c).substring(11)+'Z';
		
		CS.LastRunTime__c = datetime.now();
		update CS;
		
		//system.debug('query >>>>>>>>>>>'+query);
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Deal__Share> scope)
	{
		Set<ID> setUserIDs = new Set<ID>();
		Set<ID> setGroupIDs = new Set<ID>();
		List<Deal_Share_Compliance_Email__c> lst2InsDSComplEmail = new List<Deal_Share_Compliance_Email__c>();
		//Deal_Share_Compliance_Email__c itemDSComplEmail = new Deal_Share_Compliance_Email__c();
		for(Deal__Share item : scope)
		{
			if((''+item.UserOrGroupId).substring(0,3)=='005'){ setUserIDs.add(item.UserOrGroupId);}
			else setGroupIDs.add(item.UserOrGroupId);
		}
		
		Map<ID,User> mapUserInfo = new Map<ID,User>();
		Map<ID,Group> mapGroupInfo = new Map<ID,Group>();
		
		if(setUserIDs.size()>0){ mapUserInfo = new Map<ID, User>([SELECT Id, Name FROM User where ID in :setUserIDs]);}
		if(setGroupIDs.size()>0){ mapGroupInfo = new Map<ID, Group>([Select Type, RelatedId, Name, Id, Email, DeveloperName From Group where ID in :setGroupIDs]);}
		
		Set<ID> setRoleIDs = new Set<ID>();
		for(Group item:mapGroupInfo.values())
		{
			if((item.Type=='Role' || item.Type=='RoleAndSubordinates') && item.RelatedId!=null){ setRoleIDs.add(item.RelatedId);}
		}
		
		Map<ID,UserRole> mapUserRoleInfo = new Map<ID,UserRole>();
		if(setRoleIDs.size()>0){ mapUserRoleInfo = new Map<ID, UserRole>([Select Name, Id From UserRole where ID in :setRoleIDs]);}
		system.debug('setUserIDs>>>>>>>>>> '+setUserIDs);
		system.debug('setGroupIDs>>>>>>>>>> '+setGroupIDs);
		system.debug('setRoleIDs>>>>>>>>>> '+setRoleIDs);
		
		system.debug('mapUserInfo>>>>>>>>>> '+mapUserInfo);
		system.debug('mapGroupInfo>>>>>>>>>> '+mapGroupInfo);
		system.debug('mapUserRoleInfo>>>>>>>>>> '+mapUserRoleInfo);
		
		
		for(Deal__Share item : scope)
		{
			system.debug('item Deal>>>>>>>>>> '+item);
			Boolean isCreateRecord = true; 
			Deal_Share_Compliance_Email__c itemDSComplEmail = new Deal_Share_Compliance_Email__c();
			itemDSComplEmail.Deal__c = item.ParentId;
			itemDSComplEmail.DateTime_Shared__c = item.LastModifiedDate;
			itemDSComplEmail.Shared_By_User__c = item.LastModifiedById;
			if((''+item.UserOrGroupId).substring(0,3)=='005')
			{
				itemDSComplEmail.Shared_To_User__c = item.UserOrGroupId;
				itemDSComplEmail.Shared_Type__c = 'User';
				if(mapUserInfo.containsKey(item.UserOrGroupId)) itemDSComplEmail.Shared_To_Name__c = mapUserInfo.get(item.UserOrGroupId).Name;
			}
			else
			{
				if(mapGroupInfo.containsKey(item.UserOrGroupId))
				{
					if(mapGroupInfo.get(item.UserOrGroupId).Type == 'Regular')
					{
						itemDSComplEmail.Shared_Type__c = 'Group';
						itemDSComplEmail.Shared_To_Name__c = mapGroupInfo.get(item.UserOrGroupId).Name;
					}
					else if(mapGroupInfo.get(item.UserOrGroupId).Type == 'Organization')
					{
						itemDSComplEmail.Shared_Type__c = 'Organization';
						itemDSComplEmail.Shared_To_Name__c = 'All Internal Users';
					}
					else if(mapGroupInfo.get(item.UserOrGroupId).Type == 'RoleAndSubordinates' || mapGroupInfo.get(item.UserOrGroupId).Type == 'Role')
					{
						if(mapGroupInfo.get(item.UserOrGroupId).Type == 'Role') itemDSComplEmail.Shared_Type__c = 'Role';
						else itemDSComplEmail.Shared_Type__c = 'Role and Subordinates';
						if(mapGroupInfo.get(item.UserOrGroupId).RelatedId!=null && mapUserRoleInfo.containsKey(mapGroupInfo.get(item.UserOrGroupId).RelatedId))
						{
							itemDSComplEmail.Shared_To_Name__c = mapUserRoleInfo.get(mapGroupInfo.get(item.UserOrGroupId).RelatedId).Name;
						}
					}
					else isCreateRecord = false;
				}
				else isCreateRecord = false;
			}
			system.debug('itemDSComplEmail>>>>>>>>>> '+itemDSComplEmail);
			
			if(isCreateRecord) lst2InsDSComplEmail.add(itemDSComplEmail);
			
		}

		if(lst2InsDSComplEmail.size()>0) insert lst2InsDSComplEmail;
	}

	global void finish(Database.BatchableContext BC)
	{
	
	}

}