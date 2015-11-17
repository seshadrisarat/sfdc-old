public with sharing class SL_WorkingGroupTriggerHandler {
	public SL_WorkingGroupTriggerHandler() {
		
	}

	public void onBeforeInsert(List<External_Working_Group_Member__c> newList)
	{
		updateOriginalCompany(newList);
	}
	public void onAfterInsert(List<External_Working_Group_Member__c> newList)
	{
		List<External_Working_Group_Member__c> DealProjectlist = new List<External_Working_Group_Member__c>();
		Map<ID,External_Working_Group_Member__c> companylist = new Map<ID,External_Working_Group_Member__c>();
		for(External_Working_Group_Member__c newwg:newList)
		{
			if(newwg.WG_Type__c=='Deal'||(newwg.WG_Type__c=='Project'&&newwg.Project_Deal_ID__c!=null))
			{
				DealProjectlist.add(newWG);
			}
			else if(newwg.WG_Type__c=='Company'||(newwg.WG_Type__c=='Project'&&newwg.Project_Deal_ID__c==null))
			{
				companyList.put(newwg.id,newwg);
			}
		}
		if(DealProjectlist.size()>0)
		{
			updateDealSyncState(DealProjectlist);
		}
		if(companylist.size()>0)
		{
			checkSync(companylist,null);
		}
	}
	

	public void onAfterUpdate(Map<ID,External_Working_Group_Member__c> newMap,Map<ID,External_Working_Group_Member__c> oldMap)
	{
		checkSync(newMap,oldMap);
		checkDesync(newMap,oldMap);
	}
	public void onBeforeDelete(Map<ID,External_Working_Group_Member__c> oldMap)
	{
		checkDesync(null,oldMap);
	}

	public void checkSync(Map<ID,External_Working_Group_Member__c> newMap,Map<ID,External_Working_Group_Member__c> oldMap)
	{
		Map<Id,String> folderNameMap = new Map<Id,String>();
		List<External_Working_Group_Member__c> wgMembToSync = new List<External_Working_Group_Member__c>();
		Map<ID,External_Working_Group_Member__c> gettingCompanies = new Map<ID,External_Working_Group_Member__c>([SELECT ID,Contact__c,Project_Deal_ID__c, AS_project__r.Portfolio_Company__c,AS_project__r.Box_Sync_Folder_ID__c,AS_project__r.Investment_Opportunity__c,WG_Type__c,Deal__c, Deal__r.Salesforce_Company__c,Company__c,Company__r.Box_ID__c,Original_Deal_ID__c,Original_Deal_ID__r.Box_ID__c  FROM External_Working_Group_Member__c WHERE ID IN: newMap.keySet()]);
		List<String> companyBoxIds = new List<String>();
		for(ID newID:newMap.keySet())
		{
			External_Working_Group_Member__c newMember = newMap.get(newID);
			if(newMember.WG_Type__c=='Company'&&gettingCompanies.get(newID).Company__r.Box_ID__c!=null)
				companyBoxIds.add(gettingCompanies.get(newID).Company__r.Box_ID__c);
			if(newMember.WG_Type__c =='Project'&&gettingCompanies.get(newID).AS_project__r.Box_Sync_Folder_ID__c!=null&&newMember.Project_Deal_ID__c==null)
				companyBoxIds.add(gettingCompanies.get(newID).Company__r.Box_ID__c);
		}
		System.debug('cbi'+companyBoxIds);
		List<Deal__c> lstDeals= [SELECT ID, Box_ID__c FROM Deal__c WHERE Box_ID__c IN: companyBoxIds];
		Map<String,ID> boxIdToDeals = new Map<String,ID>();
		for(Deal__c deal:lstDeals)
		{
			boxIdToDeals.put(deal.Box_ID__c,deal.Id);
		}
		for(ID newID:newMap.keySet())
		{
			External_Working_Group_Member__c oldMember = new External_Working_Group_Member__c();
			if(oldMap!=null)
			{
				oldMember = oldMap.get(newID);
			}
			External_Working_Group_Member__c newMember = newMap.get(newID);
			if(oldMap!=null)
			{
				if((newMember.End_Date__c==null)&&(oldMember.End_Date__c!=null))
				{
					//sync user for deal
					if(newMember.WG_Type__c=='Deal')
					{
				    	folderNameMap.put(newMember.Deal__c,'');
				    	wgMembToSync.add(newMember);
					}
				    else if(newMember.WG_Type__c == 'Project')
				    {
				    	if(newMember.Project_Deal_ID__c!=null)
				    		folderNameMap.put(newMember.Project_Deal_ID__c,'');
				    	else
				    		folderNameMap.put(boxIdToDeals.get(gettingCompanies.get(newID).AS_project__r.Box_Sync_Folder_ID__c),'');
				    	wgMembToSync.add(gettingCompanies.get(newID));
				    }
				    else if(newMember.WG_type__c == 'Company')
				    {
				    	folderNameMap.put(boxIdToDeals.get(gettingCompanies.get(newID).Company__r.Box_ID__c),'');
				    	wgMembToSync.add((gettingCompanies.get(newID)));
				    }
				}
				System.debug('Companyfoldernamemap'+foldernameMap);
			}
			else
			{
					if(newMember.WG_type__c == 'Company')
				    {
				    	folderNameMap.put(boxIdToDeals.get(gettingCompanies.get(newID).Company__r.Box_ID__c),'');
				    	wgMembToSync.add((gettingCompanies.get(newID)));
				    	System.debug('Companyfoldernamemap'+foldernameMap);
				    }
				    else if(newMember.WG_Type__c == 'Project')
				    {
				    	if(newMember.Project_Deal_ID__c!=null)
				    		folderNameMap.put(newMember.Project_Deal_ID__c,'');
				    	else
				    		folderNameMap.put(boxIdToDeals.get(gettingCompanies.get(newID).AS_project__r.Box_Sync_Folder_ID__c),'');
				    	wgMembToSync.add(gettingCompanies.get(newID));
				    }
			}
		}
		if(wgMembToSync.size()>0)
		{
		  SL_BoxSyncBatch b = new SL_BoxSyncBatch('syncFolder',folderNameMap, NULL,wgMembToSync);
			if(!Test.isRunningTest())
				Database.executeBatch(b,1);
		}
	}

	public void checkDesync(Map<ID,External_Working_Group_Member__c> newMap,Map<ID,External_Working_Group_Member__c> oldMap)
	{
		Map<Id,String> folderNameMap = new Map<Id,String>();
		List<External_Working_Group_Member__c> wgMembToSync = new List<External_Working_Group_Member__c>();
		List<ID> lstContactIDs = new List<ID>();
		List<ID> projectIds = new List<ID>();
		Map<ID,External_Working_Group_Member__c> gettingProjectCompanies = new Map<ID,External_Working_Group_Member__c>([SELECT ID,Contact__c,Project_Deal_ID__c, AS_project__r.Portfolio_Company__c,AS_project__r.Box_Sync_Folder_ID__c,AS_project__r.Investment_Opportunity__c,WG_Type__c,Deal__c, Deal__r.Salesforce_Company__c,Company__c,Company__r.Box_ID__c,Original_Deal_ID__c,Original_Deal_ID__r.Box_ID__c FROM External_Working_Group_Member__c WHERE ID IN: oldMap.keySet()]);
		System.debug('projCompanies'+ gettingProjectcompanies);
		for(ID old:oldMap.keySet())
		{
			External_Working_Group_Member__c oldMember = oldMap.get(old);
			lstContactIDs.add(oldMember.Contact__c);
		}
		List<String> companyBoxIds = new List<String>();
		for(ID oldID:oldMap.keySet())
		{
			External_Working_Group_Member__c oldMember = oldMap.get(oldID);
			if(oldMember.WG_Type__c=='Company'&&gettingProjectCompanies.get(oldID).Company__r.Box_ID__c!=null)
				companyBoxIds.add(gettingProjectCompanies.get(oldID).Company__r.Box_ID__c);
			if(oldMember.WG_Type__c =='Project'&&gettingProjectCompanies.get(oldID).AS_project__r.Box_Sync_Folder_ID__c!=null&&oldMember.Project_Deal_ID__c==null)
				companyBoxIds.add(gettingProjectCompanies.get(oldID).Company__r.Box_ID__c);
		}
		List<Deal__c> lstDeals= [SELECT ID, Box_ID__c FROM Deal__c WHERE Box_ID__c IN: companyBoxIds];
		System.debug('lstdeals'+lstDeals);
		Map<String,ID> boxIdToDeals = new Map<String,ID>();
		for(Deal__c deal:lstDeals)
		{
			boxIdToDeals.put(deal.Box_ID__c,deal.Id);
		}
		List<External_Working_Group_Member__c> lstOtherWGMembers = new List<External_Working_Group_Member__c>([SELECT ID,Deal__c,Contact__c,Company__c, Deal__r.Salesforce_Company__c, AS_project__r.Portfolio_Company__c,End_Date__c,WG_Type__c,Original_Deal_ID__c,Original_Deal_ID__r.Box_ID__c from External_Working_Group_Member__c where Contact__c in:lstContactIDs and End_Date__c=null]);
		System.debug('lstOtherWGMembers'+ lstOtherWGMembers);
		Map<ID,Integer> companytoActiveWGMembers = new Map<Id,Integer>();
		for(External_Working_Group_Member__c wg:lstOtherWGMembers)
		{
			if(wg.AS_project__r.Portfolio_Company__c!=null)
			{
				if(companytoActiveWGMembers.get(wg.AS_project__r.Portfolio_Company__c)!=null)
				{
					Integer numberActive = companytoActiveWGMembers.get(wg.AS_project__r.Portfolio_Company__c);
					numberActive++;
					companytoActiveWGMembers.put(wg.AS_project__r.Portfolio_Company__c,numberActive);
				}
				else 
				{
					companytoActiveWGMembers.put(wg.AS_project__r.Portfolio_Company__c,1);
				}
			}
			else if(wg.Deal__r.Salesforce_Company__c!=null)
			{
				if(companytoActiveWGMembers.get(wg.Deal__r.Salesforce_Company__c)!=null)
				{
					Integer numberActive = companytoActiveWGMembers.get(wg.Deal__r.Salesforce_Company__c);
					numberActive++;
					companytoActiveWGMembers.put(wg.Deal__r.Salesforce_Company__c,numberActive);
				}
				else 
				{
					companytoActiveWGMembers.put(wg.Deal__r.Salesforce_Company__c,1);
				}
			}
			else if(wg.Company__c!=null)
			{
				if(companytoActiveWGMembers.get(wg.Company__c)!=null)
				{
					Integer numberActive = companytoActiveWGMembers.get(wg.Company__c);
					numberActive++;
					companytoActiveWGMembers.put(wg.Company__c,numberActive);
				}
				else 
				{
					companytoActiveWGMembers.put(wg.Company__c,1);
				}
			}
		}
		//List<Deal__c> dealsOnCompanies = [SELECT ID,Box_ID__c FROM deal__c WHERE Salesforce_Company__c in: companytoActiveWGMembers.keyset() AND Box_Id__c!=null];
		//Map<String,Id> boxIdToDeals = new Map<String,Id>();
		//for(Deal__c d:dealsOnCompanies)
		//{
		//	boxIdToDeals.put(d.Box_ID__c,d.ID);
		//}
		for(ID old:oldMap.keySet())
		{
			External_Working_Group_Member__c oldMember = oldMap.get(old);
			ID companyID;
			if(oldMember.WG_Type__c=='Project')
				companyID = gettingProjectCompanies.get(old).AS_project__r.Portfolio_Company__c;
			else if(oldMember.WG_Type__c=='Deal')
				companyID = gettingProjectCompanies.get(old).Deal__r.Salesforce_Company__c;
			else if(oldMember.WG_Type__c=='Company')
				companyID=gettingProjectCompanies.get(old).Company__c;
			if(newMap!=null)
			{
				External_Working_Group_Member__c newMember = newMap.get(old);

				if((newMember.End_Date__c!=null)&&(oldMember.End_Date__c==null)&&(companytoActiveWGMembers.get(companyID)==null))
				{
					//desync user for deal
					if(newMember.Deal__c!=null)
					{
			        	folderNameMap.put(newMember.Deal__c,'');
			        	 wgMembToSync.add(newMember);
			    	}
			    	else if(companyID!=null)
			    	{
			    		if(newMember.WG_type__c=='Project')
			    		{
			    			if(gettingProjectCompanies.get(old).AS_project__r.Investment_Opportunity__c!=null)
			    			{
			    				folderNameMap.put(gettingProjectCompanies.get(old).AS_project__r.Investment_Opportunity__c,'');
			    				wgMembToSync.add(newMember);
			    			}
			    			else
			    			{
			    				folderNameMap.put(boxIdToDeals.get(gettingProjectCompanies.get(old).AS_project__r.Box_Sync_Folder_ID__c),'');
			    				wgMembToSync.add(gettingProjectCompanies.get(old));
			    			}
			    			
			    		}
			    		else if(newMember.WG_Type__c =='Company')
			    		{
			    			if(gettingProjectCompanies.get(old).Original_Deal_ID__c!=null)
			    			{
			    				folderNameMap.put(gettingProjectCompanies.get(old).Original_Deal_ID__c,'');
			    			}
			    			else
			    			{
			    				folderNameMap.put(boxIdToDeals.get(gettingProjectCompanies.get(old).Company__r.Box_ID__c),'');
			    			}
			    			wgMembToSync.add(gettingProjectCompanies.get(old));
			    		}
			    	}
			    	System.debug('wgMembToSync'+ wgMembToSync);
			    }
			}
			else
			{
				if((companytoActiveWGMembers.get(companyID)<2))
				{
					if(oldMember.Deal__c!=null)
					{
						folderNameMap.put(oldMember.Deal__c,'');
						wgMembToSync.add(oldMember);
					}
					else if(companyID!=null)
			    	{
			    		if(oldMember.WG_type__c=='Project')
			    		{
			    			if(gettingProjectCompanies.get(old).AS_project__r.Investment_Opportunity__c!=null)
			    			{
			    				folderNameMap.put(gettingProjectCompanies.get(old).AS_project__r.Investment_Opportunity__c,'');
			    				wgMembToSync.add(oldMember);
			    			}
			    			else
			    			{
			    				folderNameMap.put(boxIdToDeals.get(gettingProjectCompanies.get(old).AS_project__r.Box_Sync_Folder_ID__c),'');
			    				wgMembToSync.add(gettingProjectCompanies.get(old));
			    			}
			    		}
			    		else if(oldMember.WG_Type__c =='Company')
			    		{
			    			if(gettingProjectCompanies.get(old).Original_Deal_ID__c!=null)
			    			{
			    				folderNameMap.put(gettingProjectCompanies.get(old).Original_Deal_ID__c,'');
			    			}
			    			else
			    			{
			    				folderNameMap.put(boxIdToDeals.get(gettingProjectCompanies.get(old).Company__r.Box_ID__c),'');
			    			}
			    			wgMembToSync.add(gettingProjectCompanies.get(old));
			    		}
			    	}
			    	System.debug('wgMembToSync'+ wgMembToSync);
				}
			}

		}
		if(wgMembToSync.size()>0)
		{
		  SL_BoxSyncBatch b = new SL_BoxSyncBatch('unSyncFolder',folderNameMap, NULL,wgMembToSync);
			if(!Test.isRunningTest())
				Database.executeBatch(b,1);
		}
	}

	// Added as per AMSEC-521 ticket..
	public void updateDealSyncState(List<External_Working_Group_Member__c> newListofWGMEmbers)
	{
		Set<Id> setOfDealIds = new Set<Id>();
		Map<Id,String> folderNameMap = new Map<Id,String>();
		for(External_Working_Group_Member__c objExternalWorkingGroupMember : newListofWGMEmbers)
		{
			if(objExternalWorkingGroupMember.WG_Type__c=='Project')
				setOfDealIds.add(objExternalWorkingGroupMember.Project_Deal_ID__c);
			else if(objExternalWorkingGroupMember.WG_Type__c=='Deal')
				setOfDealIds.add(objExternalWorkingGroupMember.Deal__c);
		}

		if(setOfDealIds.isEmpty())
			return;


		/*** Collecting the Active Amsec Staus values from the parent Deal record...*/

		Set<String> setOfActiveAmsecStatuses = new Set<String>();
		SL_DealTriggerHandler objDealHandler = new SL_DealTriggerHandler();

		// Collecting all the Active Status values from the custom setting....
		for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
		    if(objStatus.Name.startsWith('Active') && objStatus.Am_Sec_Status__c != NULL)
		        setOfActiveAmsecStatuses.add(objStatus.Am_Sec_Status__c);
		}
		/**** ENDS */

		// Collecting the Deal records whose Status is present in the Active Process record from the custom setting..
		for(Deal__c objDeal : [Select Id, Name, RecordTypeId, Salesforce_Company__r.Name, Salesforce_Company__c, Salesforce_Company__r.Alt_Box_Folder_Name__c 
                           			From Deal__c 
                           			Where Id IN : setOfDealIds AND Box_ID__c != NULL AND Deal_Status__c IN : setOfActiveAmsecStatuses])
		{
			//String folderName = objDealHandler.getFolderName(objDeal);
            folderNameMap.put(objDeal.ID,'');
		}

		List<External_Working_Group_Member__c> syncWGMembers = new List<External_Working_Group_Member__c>();
		for(External_Working_Group_Member__c objExternalWorkingGroupMember : newListofWGMEmbers)
		{
			if(objExternalWorkingGroupMember.WG_Type__c =='Project' && folderNameMap.keySet().contains(objExternalWorkingGroupMember.Project_Deal_ID__c))
			{
				syncWGMembers.add(objExternalWorkingGroupMember);
			}
			else if(objExternalWorkingGroupMember.WG_Type__c=='Deal' && folderNameMap.keySet().contains(objExternalWorkingGroupMember.Deal__c))
			{
				syncWGMembers.add(objExternalWorkingGroupMember);
			}
		}
		// calling the Batch
		if(!folderNameMap.isEmpty())
		{
		    SL_BoxBatch b = new SL_BoxBatch('syncFolder',folderNameMap, NULL,syncWGMembers);
			if(!Test.isRunningTest())
				Database.executeBatch(b,1);
		}
	}

	public void updateOriginalCompany(List<External_Working_Group_Member__c> newWGMembers)
	{
		List<External_Working_Group_Member__c> updateMembers = new List<External_Working_Group_Member__c>();
		List<ID> contactIDs = new List<ID>();
		for(External_Working_Group_Member__c wg:newWGMembers)
		{
			contactIDs.add(wg.Contact__c);
		}
		Map<ID,Contact> allContacts = new Map<ID,Contact>([SELECT ID,Account.Name FROM Contact where id in:contactIDs]);
		for(External_Working_Group_Member__c wg:newWGMembers)
		{
			if(wg.Original_Company__c==null)
			{
				if(wg.Contact__c!=null)
				{
					wg.Original_Company__c =allContacts.get(wg.Contact__c).Account.Name;
				}
			}
		}
	}
}