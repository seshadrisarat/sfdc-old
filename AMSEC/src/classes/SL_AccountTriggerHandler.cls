/**  
* \arg ClassName        : SL_AccountTriggerHandler
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Handler class for Account object.
*/
global class SL_AccountTriggerHandler extends SL_TriggerHandlerBase {
	Id portFolioRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Portfolio Company').RecordTypeId;

	public override void beforeInsert(List<SObject> newListGeneric){
		List<Account> newList = (List<Account>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		
		/*BEFORE INSERT METHODS END*/
	}
	
	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		updateFolderNamesInBox(oldMap, newMap);
		updateWorkingGroupMember(oldMap, newMap);
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	

	/*
        * MethodName : updateWorkingGroupMember
        * Param      : Map<Id, Account> oldMap, Map<Id, Account> newMap
        * Description: Stamp End Dates to WG members on Former Portfolio Company record
    */
	private void updateWorkingGroupMember(Map<Id, Account> oldMap, Map<Id, Account> newMap){

		Set<Id> setAccIds = new Set<Id>();
		List<External_Working_Group_Member__c> lstWGMToUpdate = new List<External_Working_Group_Member__c>();
		Id formerPortfolioRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Former_Portfolio'].Id;

		for(Account objAcc : newMap.values()){
			Account objOldAcc = oldMap.get(objAcc.Id);
			if(objAcc.RecordTypeId != objOldAcc.RecordTypeId && objAcc.RecordTypeId == formerPortfolioRecTypeId)
				setAccIds.add(objAcc.Id);
		}

		for(External_Working_Group_Member__c objWGM : [SELECT End_Date__c 
														 FROM External_Working_Group_Member__c
														WHERE Company__c IN :setAccIds]){
			lstWGMToUpdate.add(new External_Working_Group_Member__c(Id = objWGM.Id, End_Date__c = System.today()));
		}

		if(!lstWGMToUpdate.isEmpty())
			update lstWGMToUpdate;
	}

	/*
        * MethodName : updateFolderNamesInBox
        * Param      : Map<Id, Account> oldMap, Map<Id, Account> newMap
        * Description: Calling to collect the child deal records and update the folderNames in Box.com
    */
    private void updateFolderNamesInBox(Map<Id, Account> oldMap, Map<Id, Account> newMap) 
	{
		Map<Id,String> folderNameMap = new Map<Id,String>();
		Map<Id, String> mapOfAccIds = new Map<Id, String>();

		Map<Id, boolean> mapOfDealIdToStausChanged = new Map<Id, Boolean>();
		Set<String> setOfActiveAmsecStatuses = new Set<String>();

		// Collecting all the Active Status values from the custom setting....
		for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
		    if(objStatus.Name.startsWith('Active') && objStatus.Am_Sec_Status__c != NULL)
		        setOfActiveAmsecStatuses.add(objStatus.Am_Sec_Status__c);
		}


		// Iterating on new Acc.
		for(Account objAcc : newMap.values()) 
		{
			Account objOldAcc = oldMap.get(objAcc.Id); 		// Getting Old Account record...

			/*** 
			ASSUMPTION : Giving priotity to Alt_Box_Folder_Name__c than Name
			***/
			if(objAcc.RecordTypeId != objOldAcc.RecordTypeId && objAcc.Alt_Box_Folder_Name__c != NULL)
				mapOfAccIds.put(objAcc.ID, objAcc.Alt_Box_Folder_Name__c);
			// If comany got changed adding in to the set and wil get the folderName form the COmapny.Name OR Company.Alt_Box_Folder_Name__c fields.
			else if(objAcc.Alt_Box_Folder_Name__c != NULL && objAcc.Alt_Box_Folder_Name__c != objOldAcc.Alt_Box_Folder_Name__c)
				mapOfAccIds.put(objAcc.Id, objAcc.Alt_Box_Folder_Name__c);
			// If Name got changed directly adding in to the map
			else if(objAcc.Alt_Box_Folder_Name__c == NULL && objAcc.Name != NULL && ((objAcc.Alt_Box_Folder_Name__c != objOldAcc.Alt_Box_Folder_Name__c) || (objAcc.Name != objOldAcc.Name) ) )
				mapOfAccIds.put(objAcc.ID,objAcc.Name);
			// As per AMSEC-475..checking only recordType of Acc.....For moving the folders.....
			else if(objAcc.RecordTypeId != objOldAcc.RecordTypeId) {
				mapOfAccIds.put(objAcc.ID, objAcc.Name);
			}		
		}

		system.debug('mapOfAccIds==============>>>' +mapOfAccIds);
		// Collecting the chisld Deal records to udpate the folder Name....
		if(!mapOfAccIds.isEmpty()) {
			// Querying the Updated Salesforce_Company related field to get the folder Name to update in Box.com
          	for(Deal__c objDeal : [Select Id, Name, Deal_Status__c, RecordTypeId, Salesforce_Company__r.Name, Salesforce_Company__c, Salesforce_Company__r.Alt_Box_Folder_Name__c 
                           			From Deal__c 
                           			Where Salesforce_Company__c IN : mapOfAccIds.keySet() AND Box_ID__c != NULL]  ) {
            	String folderName = mapOfAccIds.get(objDeal.Salesforce_Company__c);
            	folderNameMap.put(objDeal.ID,folderName);

            	if(setOfActiveAmsecStatuses.contains(objDeal.Deal_Status__c))
            		mapOfDealIdToStausChanged.put(objDeal.Id, true);
        	}
		}

		// Calling the batch
        SL_BoxBatch b = new SL_BoxBatch('moveFolder',folderNameMap, mapOfDealIdToStausChanged,null);
    	if(!Test.isRunningTest())
    		Database.executeBatch(b,1);
	}
}