/**
* \arg ClassName      : SL_Batch_RollupClientInvestments
* \arg JIRATicket     : AEW-4
* \arg CreatedOn      : 2nd/JAN/2015
* \arg LastModifiedOn : 13th/JAN/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This batch process is used to roll up client investments.
*/
global class SL_Batch_RollupClientInvestments implements Database.Batchable<sObject>
{
	/* Start - Constructor */
	global SL_Batch_RollupClientInvestments()
	{
		/* Do nothing */
	}
	/* End - Constructor */
   
	/* Start Method */
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		String query = 'SELECT Id, ParentId, Name FROM Account WHERE ParentId = null';
		return Database.getQueryLocator(query); 
	}
	   
	/* Execute Method */
	global void execute(Database.BatchableContext BC, List<Account> lstAccount)
	{
		List<Account> lstAccountToupdate = new List<Account>();
		Map<Id, Account> parentAccountMap = new Map<Id, Account>(lstAccount);
		Map<Id, Double> mapAccountId_Nav = new Map<Id, Double>();
		Map<Id, Double> mapAccountId_GPV = new Map<Id, Double>();
		Map<Id, Double> mapAccountId_TotComAmt = new Map<Id, Double>();
		Map<Id, Double> mapAccountId_TotDisAmt = new Map<Id, Double>();
		Map<Id, Double> mapAccountId_TotConAmt = new Map<Id, Double>();
		Map<Id, Date> mapAccountId_RecentDate = new Map<Id, Date>();
		
		Map<Id, Account> childAccountMap = new Map<Id, Account>([SELECT Id, 
																		ParentId 
																   FROM Account 
																  WHERE ParentId IN : parentAccountMap.keySet()]);
		 
		for(AggregateResult aggreResult : [SELECT SUM(NAV__c) nav, SUM(GPV__c) gpv, 
												  SUM(Total_Commitment_Amount__c) totComAmt, 
												  SUM(Total_Distribution_Amount__c) totDisAmt, 
												  SUM(Total_Contribution_Amount__c) totConAmt,
												  MAX(As_Of__c) recentDate,
												  Organization__c account
											 FROM Client_Investment__c 
											WHERE (Organization__c IN : parentAccountMap.keySet() OR Organization__c IN : childAccountMap.keySet()) 
											  AND Exclude_from_Rollup__c = false
										 GROUP BY Organization__c])
		{
			mapAccountId_Nav.put((Id)aggreResult.get('account'), (aggreResult.get('nav') != null) ? (Double)aggreResult.get('nav') : 0.00);
			mapAccountId_GPV.put((Id)aggreResult.get('account'), (aggreResult.get('gpv') != null) ? (Double)aggreResult.get('gpv') : 0.00);
			mapAccountId_TotComAmt.put((Id)aggreResult.get('account'), (aggreResult.get('totComAmt') != null) ? (Double)aggreResult.get('totComAmt') : 0.00);
			mapAccountId_TotDisAmt.put((Id)aggreResult.get('account'), (aggreResult.get('totDisAmt') != null) ? (Double)aggreResult.get('totDisAmt') : 0.00);
			mapAccountId_TotConAmt.put((Id)aggreResult.get('account'), (aggreResult.get('totConAmt') != null) ? (Double)aggreResult.get('totConAmt') : 0.00);
			mapAccountId_RecentDate.put((Id)aggreResult.get('account'), (aggreResult.get('recentDate') != null) ? (Date)aggreResult.get('recentDate') : null);
			
		}
		
		/* Iterating over the child account's values */
		for(Account objAccount : childAccountMap.values())
		{
			
			lstAccountToupdate.add(new Account(Id = objAccount.Id, NAV__c = (mapAccountId_Nav.containsKey(objAccount.Id)) ? mapAccountId_Nav.get(objAccount.Id) : 0.00, 
												   GPV__c = (mapAccountId_GPV.containsKey(objAccount.Id)) ? mapAccountId_GPV.get(objAccount.Id) : 0.00, 
												   Total_Commitment_Amount__c = (mapAccountId_TotComAmt.containsKey(objAccount.Id)) ? mapAccountId_TotComAmt.get(objAccount.Id) : 0.00, 
												   Total_Distribution_Amount__c = (mapAccountId_TotDisAmt.containsKey(objAccount.Id)) ? mapAccountId_TotDisAmt.get(objAccount.Id) : 0.00,
												   Total_Contribution_Amount__c = (mapAccountId_TotConAmt.containsKey(objAccount.Id)) ? mapAccountId_TotConAmt.get(objAccount.Id) : 0.00,
												   AEW_Financials_As_Of__c = (mapAccountId_RecentDate.containsKey(objAccount.Id)) ? mapAccountId_RecentDate.get(objAccount.Id) : null
												   ));
			
			if(mapAccountId_Nav.containsKey(objAccount.Id))
			{
				mapAccountId_Nav.put(objAccount.ParentId, (mapAccountId_Nav.containsKey(objAccount.ParentId)? (mapAccountId_Nav.get(objAccount.ParentId)) : 0.00) + mapAccountId_Nav.get(objAccount.Id));
				mapAccountId_GPV.put(objAccount.ParentId, (mapAccountId_GPV.containsKey(objAccount.ParentId)? (mapAccountId_GPV.get(objAccount.ParentId)) : 0.00)  + mapAccountId_GPV.get(objAccount.Id));
				mapAccountId_TotComAmt.put(objAccount.ParentId,  (mapAccountId_TotComAmt.containsKey(objAccount.ParentId)? (mapAccountId_TotComAmt.get(objAccount.ParentId)) : 0.00)
																															+ mapAccountId_TotComAmt.get(objAccount.Id));
																															
				mapAccountId_TotDisAmt.put(objAccount.ParentId,  (mapAccountId_TotDisAmt.containsKey(objAccount.ParentId)? (mapAccountId_TotDisAmt.get(objAccount.ParentId)) : 0.00)
																															+ mapAccountId_TotDisAmt.get(objAccount.Id));
				
				mapAccountId_TotConAmt.put(objAccount.ParentId,  (mapAccountId_TotConAmt.containsKey(objAccount.ParentId)? (mapAccountId_TotConAmt.get(objAccount.ParentId)) : 0.00)
																															+ mapAccountId_TotConAmt.get(objAccount.Id));
				
				// Added Regarding AEW-6
				mapAccountId_RecentDate.put(objAccount.ParentId, (mapAccountId_RecentDate.containsKey(objAccount.ParentId) ? (mapAccountId_RecentDate.get(objAccount.ParentId) >=  mapAccountId_RecentDate.get(objAccount.Id) 
																  ? mapAccountId_RecentDate.get(objAccount.ParentId) : mapAccountId_RecentDate.get(objAccount.Id)): mapAccountId_RecentDate.get(objAccount.Id)));
				
			}
		}
		
		/* Iterating over the parent account's values */
		for(Account objAccount : parentAccountMap.values())
		{
			/* Adding parent Accounts fields into list to update */
			lstAccountToupdate.add(new Account(Id = objAccount.Id, NAV__c = (mapAccountId_Nav.containsKey(objAccount.Id)) ? mapAccountId_Nav.get(objAccount.Id) : 0.00, 
											   GPV__c = (mapAccountId_GPV.containskey(objAccount.Id)) ? mapAccountId_GPV.get(objAccount.Id) : 0.00, 
											   Total_Commitment_Amount__c = (mapAccountId_TotComAmt.containskey(objAccount.Id)) ? mapAccountId_TotComAmt.get(objAccount.Id) : 0.00,
											   Total_Distribution_Amount__c = (mapAccountId_TotDisAmt.containskey(objAccount.Id)) ? mapAccountId_TotDisAmt.get(objAccount.Id) : 0.00, 
											   Total_Contribution_Amount__c = (mapAccountId_TotConAmt.containskey(objAccount.Id)) ? mapAccountId_TotConAmt.get(objAccount.Id) : 0.00, 
											   AEW_Financials_As_Of__c = (mapAccountId_RecentDate.containskey(objAccount.Id)) ? mapAccountId_RecentDate.get(objAccount.Id) : null)); 
		}
		
		/* Updationg list of Accounts if it is not empty */
		if(!lstAccountToupdate.isEmpty())
		{
			update lstAccountToupdate;
		}	
	}
	
	/* Finish Method */
	global void finish(Database.BatchableContext BC)
	{
		/* Do Nothing */
	}
}