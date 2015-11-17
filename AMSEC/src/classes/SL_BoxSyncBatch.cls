global class SL_BoxSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	String query;
	String authToken;
	String boxAction;
	SL_BoxAPI handler = new SL_BoxAPI();
	box.Toolkit boxToolkit;
	Map<Id,String> folderNameMap;
	Map<Id,boolean> mapOfDealIdToStatusChanged;
	List<External_Working_Group_Member__c> wgMemberSync;
	Map<ID,Deal__c> dealsGlob;
	
	global SL_BoxSyncBatch(String action,Map<Id,String> folderNames, Map<Id,Boolean> mapOfDealToStatusChanged, List<External_Working_Group_Member__c> wgMembSync) { 
		boxAction = action;
		folderNameMap = folderNames;
		mapOfDealIdToStatusChanged = mapOfDealToStatusChanged;
		boxToolkit = new box.Toolkit();
		wgMemberSync = wgMembSync;
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		/*System.debug('start batch');
		List<Id> objectIds = new List<ID>();
		for(External_Working_Group_Member__c wgMemb:wgMemberSync)
		{
				objectIds.add(wgMemb.ID);
		}*/
		//List<External_Working_Group_Member__c> wgmembersynclist = [SELECT ID,Deal__c,Contact__c FROM External_Working_Group_Member__c where Id in:objectIds];
		if(handler.checkAuthentication() || Test.isRunningTest())
      	{
      		return wgMemberSync;
      	}
		return null;
	}

   	global void execute(Database.BatchableContext BC, List<External_Working_Group_Member__c> scope) {
   		System.debug('running iteration batch');
		Map<Id, Deal__c> mapOfDealRecs = new Map<Id, Deal__c>();
		Map<Id, String> MapOfDealToFolderName = new Map<Id, String>();
		List<External_Working_Group_Member__c> scopeWG = new List<External_Working_Group_Member__c>();
		if(boxAction=='syncFolder'||boxAction=='unSyncFolder')
		{
			 //scopeWG = [SELECT ID,Deal__c,Contact__c FROM External_Working_Group_Member__c where Id in:scope];
			 //List<Id> dealids= new List<ID>();
			 //for(External_Working_Group_Member__c wg: scope)
			 //{
			 //	if(wg.Deal__c!=null)
			 //	{
			 //		dealIds.add(wg.Deal__c);
			 //	}
			 //	else if()
			 //	{

			 //	}
			 //}
			 mapOfDealRecs = new Map<ID,Deal__c>([SELECT ID,Box_ID__c, Salesforce_Company__c, Deal_Status__c, Salesforce_Company__r.RecordTypeId, Name,RecordTypeId FROM Deal__c where Id in:folderNameMap.keyset()]);
		}


		// checking if more than one batch running and we are not sending null again if the map already contains values.....
		if(handler.mapOfFolderNameToFolderId.isEmpty()) {
			//Get all box folder ID's that are necessary for structure
			handler.getBoxFolderIDs(null);
		}

		if(boxAction == 'syncFolder' && !Test.isRunningTest())
		{
			handler.boxSyncFolder(mapOfDealRecs, boxToolkit, wgMemberSync);
		}
		else if(boxAction=='unSyncFolder' && !Test.isRunningTest())
		{
			handler.boxUnSyncFolder(mapOfDealRecs, boxToolkit, wgMemberSync);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		if (!Test.isRunningTest())
			boxToolkit.commitChanges();
	}
	
}