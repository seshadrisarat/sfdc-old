public class DealerServices {
	
	public class QueryAndDMLException extends Exception {}
	
	public static Boolean ACCOUNTS_TO_REPROCESS = false;
	
	private static String DEALER_RECORD_TYPE = 'Dealer';

	@testVisible
	private static Map<Schema.sObjectType, String> SOBJECT_TYPE_TO_ACCOUNT_FIELD = new Map<Schema.sObjectType, String>{ Contact.getSObjectType() => 'AccountId', Boat__c.getSObjectType() => 'Dealer__c' };
	
	public static Id DEALER_RECORD_TYPE_ID {
		get {
			if (DEALER_RECORD_TYPE_ID == null){
				// make get describe
				RecordType rt = [Select Id From RecordType Where SObjectType = 'Account' AND DeveloperName = :DEALER_RECORD_TYPE];
				if (rt != null){
					DEALER_RECORD_TYPE_ID = rt.Id;
				}
			}
			return DEALER_RECORD_TYPE_ID;
		}
		set;
	}
	
	@testVisible
	private static Boolean fieldHasChanged(Account sobj, Account oldSobj, Set<String> fieldsToCheck){
		Boolean result = false;
		for (String field : fieldsToCheck){
			if (sobj.get(field) != oldSobj.get(field) ){
				return true;
			}
		}
		return result;
	}
	
	@testVisible
	private static Boolean fieldIsBlank(Account sobj, Set<String> fieldsToCheck){
		Boolean result = false;
		for (String field : fieldsToCheck){
			if ( String.isBlank(String.valueOf(sobj.get(field))) ){
				return true;
			}
		}
		return result;
	}

	public static List<Account> filterDealersToBeConsilidated(List<Account> accounts, Map<Id, Account> accountOldMap){
		
		Set<String> dealerConsolidationFields = new Set<String>{'Consolidated_To_Dealer_Datetime__c', 'Consolidated_To_Dealer_Number__c'};
		
		List<Account> result = new List<Account>();
		for (Account acc : accounts){
			Boolean isAccountDataNotValid = acc.RecordTypeId != DEALER_RECORD_TYPE_ID || fieldIsBlank(acc, dealerConsolidationFields);
			Boolean isUpdateAndFieldNotChanged = accountOldMap != null && accountOldMap.containsKey(acc.Id) && !fieldHasChanged(acc, accountOldMap.get(acc.Id), dealerConsolidationFields);

			if(	isAccountDataNotValid || isUpdateAndFieldNotChanged)
			{
				continue;
			}
			result.add( acc );
			
		}
		
		return result;
	}
	
	@testVisible 
	private static Map<Id, Id> createDealerToNewParentMap(List<Account> dealers){
		
		Map<String, List<Account>> dealerNumberToDealers = (Map<String, List<Account>>) GroupBy.strings('Consolidated_To_Dealer_Number__c', dealers);
		
		Map<Id,Id> newParentMap = new Map<Id,Id>();
		
		for (Account newParent : [Select Id,Dealer_Number__c from Account where Dealer_Number__c in :dealerNumberToDealers.keySet()]){
			for (Account oldParent : dealerNumberToDealers.get( newParent.Dealer_Number__c )){
				newParentMap.put( oldParent.Id, newParent.Id );
			}
		}
		
		return newParentMap;
	}
	
	
	@testVisible
	private static List<SObject> getSObjectsRelatedToAccounts(String sObjectType, Set<Id> accountIds, String accountRelationshipField){
		return getSObjectsRelatedToAccounts(sObjectType,accountIds,accountRelationshipField, null);
	}
	
	@testVisible
	private static List<SObject> getSObjectsRelatedToAccounts(String sObjectType, Set<Id> accountIds, String accountRelationshipField, String whereClause){
		
		String query = String.format('Select Id, {1} from {0} Where {1} in :accountIds ', new List<String>{ String.escapeSingleQuotes(sObjectType), 
																										String.escapeSingleQuotes(accountRelationshipField)});
		if (String.isNotBlank(whereClause)){
			query += ' AND ' + whereClause;
		}
		system.debug('query: ' + query);
		return Database.query(query + ' LIMIT ' + Limits.getLimitQueryRows());
	}
	
	/* 	This function modified the sObjList reference 
		@Post Populates the new parent on every SObject (sObjList)
		@Return List of Old Parent Id for every reparented SObject. Will be one-to-one mapping between Old Parent Id and sObjList 
	*/
	@testVisible
	private static List<Id> reparentObjects( List<sObject> sObjList, Map<Id, Id> parentToNewParentMap )
	{
		List<Id> oldParentIds = new List<Id>();
		for( sObject sObj : sObjList )
		{
			String parentFieldName = SOBJECT_TYPE_TO_ACCOUNT_FIELD.get( sObj.getSObjectType() );
			Id oldParent = (Id)sObj.get( parentFieldName );
			oldParentIds.add(oldParent);
			sObj.put( parentFieldName, parentToNewParentMap.get( oldParent ) );
		}
		
		return oldParentIds;
	}
	
	public static void consolidateDealers(Map<Id, Account> dealers){
		consolidateDealers(dealers, null);
	}
	
	public static List<Account> consolidateDealer( List<Account> accountList )
	{
		return consolidateDealersFunction(new Map<Id, Account>(accountList), null, false);
	}
	
	public static void consolidateDealers(Map<Id, Account> dealers, Map<Id, Account> oldDealerMap){
		//Savepoint sp = Database.setSavepoint();
		List<Account> accountsWithErrors;
		try{
			accountsWithErrors = consolidateDealersFunction( dealers, oldDealerMap, true );
			
			// If this is not empty that means these accounts had errors
			if( !accountsWithErrors.isEmpty() )
			{
				//Database.rollback( sp );
				for( Account act : accountsWithErrors )
				{
					act.addError('Error consolidating dealer.');
				}
			}
		}
		catch (Exception l){
			//Catches Exceptions from exceeding dml update limits
			//Database.rollback(sp);
			for (Account accNew : dealers.values()){
				accNew.Re_Process_Consolidation__c = true;
			}
			ACCOUNTS_TO_REPROCESS = true;
		}
	}
	
	private static List<Account> consolidateDealersFunction(Map<Id, Account> dealers, Map<Id, Account> oldDealerMap, Boolean isAllOrNothing){
		
		List<Account> filteredDealers = filterDealersToBeConsilidated(dealers.values(), oldDealerMap);
		List<Account> accountsWithErrors = new List<Account>();
		if (!filteredDealers.isEmpty()){
			Map<Id, Id> newParentMap = createDealerToNewParentMap(filteredDealers);
			List<Id> oldParentIds;
			
			for (Schema.sObjectType sobjType : SOBJECT_TYPE_TO_ACCOUNT_FIELD.keySet()){
				String objectName = sobjType.getDescribe().getName();
				
				// Potential Error: Query for related objects exceeds the limit (10000)
				
				List<SObject> sobjectsToUpdate = getSObjectsRelatedToAccounts(objectName, newParentMap.keySet(), SOBJECT_TYPE_TO_ACCOUNT_FIELD.get(sobjType));
					
				if((Limits.getDMLRows() + sobjectsToUpdate.size()) >= Limits.getLimitDMLRows())
					throw new QueryAndDMLException('DML Limit Reached.');
					
				if (!sobjectsToUpdate.isEmpty()){
					oldParentIds = reparentObjects(sobjectsToUpdate, newParentMap);
					
					// check limits class before update, if exceeds, mark for re-processing
					Database.SaveResult[] resultList = Database.update( sobjectsToUpdate, isAllOrNothing );
					
					//Get Accounts that have errors so we can append them to the list
					if( resultList != null ){
						for( Integer i = 0; i < resultList.size(); i++ ){
							Database.SaveResult sr = resultList[i];
							if( !sr.isSuccess() )
								accountsWithErrors.add( dealers.get( oldParentIds[i] ) );
						}
					}
				}
				
				if(Limits.getQueryRows() >= Limits.getLimitQueryRows())
					throw new QueryAndDMLException('Query Limit Reached.');
				
			}
			populateConsolidatedDealerLookup(dealers.values(), newParentMap);
		}
		return accountsWithErrors;
	}
	
	private static void populateConsolidatedDealerLookup(List<Account> accountsToUpdate, Map<Id, Id> newParentMap){
		for (Account acc : accountsToUpdate){
			acc.Consolidated_To_Dealer__c = newParentMap.get(acc.Id);
		}
	}
	
}