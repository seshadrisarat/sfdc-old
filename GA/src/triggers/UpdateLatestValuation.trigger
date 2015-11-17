trigger UpdateLatestValuation on Valuation__c (after delete, after insert, after undelete, after update) 
{
	Map<Id,Account> mA=new Map<Id, Account>();
	List<Valuation__c> lV=trigger.isDelete?trigger.old:trigger.new;

	for(Valuation__c v : lV)
	{
		mA.put(v.Company__c,null);
	}

	lV=[SELECT Id, Date__c, Company__c FROM Valuation__c WHERE Company__c IN :mA.keySet() ORDER by Date__c DESC];
	Integer i=0;
	
	for(Valuation__c v : lV)
	{
		if(mA.get(v.Company__c)==null)
		{
			mA.put(v.Company__c,new Account(id=v.Company__c,Latest_Valuation__c=v.Id));
			++i;
		}
		
		if(i==mA.size()) //CWD-- short circuit logic to kick out when we've filled up the map
			break;
	}

	if(i>0)
		update mA.values();
}