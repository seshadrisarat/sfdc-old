global class SL_BoxBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	String query;
	String authToken;
	String boxAction;
	SL_BoxAPI handler = new SL_BoxAPI();
	box.Toolkit boxToolkit;
	Map<Id,String> folderNameMap;
	Map<Id,boolean> mapOfDealIdToStatusChanged;
	List<External_Working_Group_Member__c> wgMemberSync;
	Map<ID,Deal__c> dealsGlob;
	global SL_BoxBatch(String action,Map<Id,String> folderNames, Map<Id,Boolean> mapOfDealToStatusChanged, List<External_Working_Group_Member__c> wgMembSync) { 
		boxAction = action;
		folderNameMap = folderNames;
		mapOfDealIdToStatusChanged = mapOfDealToStatusChanged;
		boxToolkit = new box.Toolkit();
		wgMemberSync = wgMembSync;
		dealsGlob = new Map<ID,Deal__c>();
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		List<Deal__c> deals = [SELECT ID,Box_ID__c, Salesforce_Company__c, Deal_Status__c, Salesforce_Company__r.RecordTypeId, Name,RecordTypeId FROM Deal__c where Id in:folderNameMap.keyset()];
		for(Deal__c deal:deals)
		{
			dealsGlob.put(deal.id,deal);
		}
		
		if(handler.checkAuthentication() || Test.isRunningTest())
      	{
      		return deals;
      	}
		return null;
	}

	global void execute(Database.BatchableContext BC, List<Deal__c> scope) {
		Map<Id, Deal__c> mapOfDealRecs = new Map<Id, Deal__c>();
		Map<Id, String> MapOfDealToFolderName = new Map<Id, String>();

		for(Deal__c deal:scope)
		{
			mapOfDealRecs.put(deal.Id, deal);
		}
		
		// checking if more than one batch running and we are not sending null again if the map already contains values.....
		if(handler.mapOfFolderNameToFolderId.isEmpty()) {
			//Get all box folder ID's that are necessary for structure
			handler.getBoxFolderIDs(null);
		}


		// Calling the handler method to udapte the records Box_Id field
		if(boxAction == 'createFolder' && !Test.isRunningTest()) {
			String boxID = handler.boxCreateFolder(mapOfDealRecs, folderNameMap, boxToolkit);	
		}
		else if(boxAction =='moveFolder' && !Test.isRunningTest()) {
			handler.boxMoveFolder(mapOfDealRecs, folderNameMap, mapOfDealIdToStatusChanged, boxToolkit); 	
		}
		else if(boxAction == 'syncFolder' && !Test.isRunningTest())
		{
			handler.boxSyncFolder(mapOfDealRecs, boxToolkit, wgMemberSync);
		}

	}
	
	global void finish(Database.BatchableContext BC) {
		if(boxAction=='moveFolder')
		{
			List<External_Working_Group_Member__c> allWGMembers = [SELECT ID,Contact__c,Project_Deal_ID__c, AS_project__r.Portfolio_Company__c,AS_project__r.Box_Sync_Folder_ID__c,AS_project__r.Investment_Opportunity__c,WG_Type__c,Deal__c, Deal__r.Salesforce_Company__c,Company__c,Company__r.Box_ID__c,Original_Deal_ID__c,Original_Deal_ID__r.Box_ID__c  FROM External_Working_Group_Member__c WHERE Deal__c IN:dealsGlob.keyset() AND End_Date__c=null];
	        Map<ID,List<External_Working_Group_Member__c>> dealToWGMembersMap = new Map<ID,List<External_Working_Group_Member__c>>();
	        Set<String> setOfActiveAmsecStatuses = new Set<String>();
	        Set<String> setOfInactiveAmsecStatuses = new Set<String>();
	        for(External_Working_Group_Member__c wg:allWGMembers)
	        {
	        	ID dealId;

	        	if(wg.WG_Type__c=='Project')
	        		dealId = wg.Project_Deal_ID__c;
	        	else if(wg.WG_Type__c=='Deal')
	        		dealID = wg.Deal__c;
	            if(dealToWGMembersMap.get(dealId)==null)
	            {
	                List<External_Working_Group_Member__c> newList = new List<External_Working_Group_Member__c>();
	                newList.add(wg);
	                dealToWGMembersMap.put(dealId,newList);
	            }
	            else
	            {
	                List<External_Working_Group_Member__c> newList = dealToWGMembersMap.get(dealId);
	                newList.add(wg);
	                dealToWGMembersMap.put(dealId,newList);
	            }
	        }
	        for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
	            if(objStatus.Name.startsWith('Active') && objStatus.Am_Sec_Status__c != NULL)
	                setOfActiveAmsecStatuses.add(objStatus.Am_Sec_Status__c);
	            if(objStatus.Name.startsWith('Inactive') && objStatus.Am_Sec_Status__c != NULL)
	            	setOfInactiveAmsecStatuses.add(objStatus.Am_Sec_Status__c);
	        }
	        for(Deal__c objDeal:dealsGlob.values())
	        {
	          if(setOfActiveAmsecStatuses.contains(objDeal.Deal_Status__c))
	            {
	                if(dealToWGMembersMap.get(objDeal.ID)!=null)
	                {
	                    System.debug('going to sync folder');
	                    Map<Id,String> folderNameMap = new Map<Id,String>();
	                    folderNameMap.put(objDeal.Id,'');
	                     SL_BoxSyncBatch b = new SL_BoxSyncBatch('syncFolder',folderNameMap, NULL,dealToWGMembersMap.get(objDeal.ID));
						  if(!Test.isRunningTest())
							Database.executeBatch(b,1);
	                }
	            }
	            else if(setOfInactiveAmsecStatuses.contains(objDeal.Deal_Status__c))
	            {
	            	if(dealToWGMembersMap.get(objDeal.ID)!=null)
	                {
	                    System.debug('going to sync folder');
	                    Map<Id,String> folderNameMap = new Map<Id,String>();
	                    folderNameMap.put(objDeal.Id,'');
	                     SL_BoxSyncBatch b = new SL_BoxSyncBatch('unSyncFolder',folderNameMap, NULL,dealToWGMembersMap.get(objDeal.ID));
						  if(!Test.isRunningTest())
							Database.executeBatch(b,1);
	                }
	            }
	        }
	    }
		if (!Test.isRunningTest())
			boxToolkit.commitChanges();
	}
	
}