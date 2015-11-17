global class SL_Batch_RedoSharing implements Database.Batchable<sObject>
{
	
	String query;
	
	global SL_Batch_RedoSharing()
	{
		query = 'Select Id,OwnerId From Note__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
   		Note__c[] tempList = (Note__c[])scope;

   		Set<Id> nIds = new Set<Id>();
   		Set<Id> njIds = new Set<Id>();
   		//Set<Id> relGrpIds = new Set<Id>();
   		//Set<Id> acctIds = new Set<Id>();
   		Set<Id> rcIds = new Set<Id>();
   		Set<Id> pgIds = new Set<Id>();

   		Note_Joiner__c[] njList = new Note_Joiner__c[]{};
   		Note__Share[] nShares = new Note__Share[]{};
   		//Relationship_Group__c[] relGrpList = new Relationship_Group__c[]{};
   		//Hilliard_Lyons_Account__c[] hlList = new Hilliard_Lyons_Account__c[]{};
   		Rep_Code__c[] rcList = new Rep_Code__c[]{};
   		//map<String,Id> rcMap = new map<String,Id>();
   		//map<Id,Set<Id>> noteRCMap = new map<Id,Set<Id>>();
   		SL_Util_SharingController.RepCodeType[] rcTypeList = new SL_Util_SharingController.RepCodeType[]{};
   		map<Id,Set<Id>> pgGmMap = new map<Id,Set<Id>>();
   		map<Id,Id> rcPgMap = new map<Id,Id>();

   		for(Note__c n : tempList)
   		{
   			nIds.add(n.Id);
   		}

   		nShares = [Select Id From Note__Share WHERE ParentId IN: nIds AND RowCause = 'Manual'];

         delete nShares;

   		njList = [Select Id,
   						 Relationship_Group__c,
   						 Relationship_Group__r.Rep_Code__c,
   						 Client_Prospect__c,
   						 Note__c,
   						 Note__r.OwnerId
   						 From Note_Joiner__c
   						 WHERE Note__c IN: nIds];

   		for(Note_Joiner__c nj : njList)
   		{
   			if(nj.Relationship_Group__r.Rep_Code__c != null)
   			{
   				rcIds.add(nj.Relationship_Group__r.Rep_Code__c);
   			}
   		}

   		rcList = [SELECT Id,Public_Group_Id__c FROM Rep_Code__c WHERE Id IN: rcIds AND Public_Group_Id__c!=NULL];

   		for(Rep_Code__c r : rcList)
   		{
   			rcPgMap.put(r.Id,r.Public_Group_Id__c);
   			pgIds.add(r.Public_Group_Id__c);
   		}

   		GroupMember[] gmList = [Select Id,GroupId,UserOrGroupId From GroupMember WHERE GroupId IN: pgIds];

   		for(GroupMember gm : gmList)
   		{
   			if(pgGmMap.containsKey(gm.GroupId))
   			{
   				pgGmMap.get(gm.GroupId).add(gm.UserOrGroupId);
   			}else
   			{
   				pgGmMap.put(gm.GroupId, new Set<Id>{gm.UserOrGroupId});
   			}
   		}

   		for(Note_Joiner__c nj : njList)
   		{
   			if(nj.Relationship_Group__r.Rep_Code__c != null)
   			{
   				Id pgId = rcPgMap.get(nj.Relationship_Group__r.Rep_Code__c);

   				if(pgId != null)
   				{
   					Set<Id> gmIds = pgGmMap.get(pgId);

   					if(gmIds != null && !gmIds.isEmpty())
   					{
   						if(gmIds.contains(nj.Note__r.OwnerId))
   						{
   							rcTypeList.add(new SL_Util_SharingController.RepCodeType(nj.Note__c, nj.Relationship_Group__r.Rep_Code__c));
   						}
   					}
   				}
   			}
   		}

         System.debug(rcTypeList);

   		Database.insert(SL_Util_SharingController.createSharingRecords(rcTypeList, 'Edit'),false);

	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
	
}