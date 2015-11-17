global class UpdateCompanyFinancialsBatchable implements Database.Batchable<AggregateResult>, Database.Stateful 
{
	private String strQuery;

	global class AggregateResultIterable implements Iterable<AggregateResult> 
	{
		private String strQuery;
		
		global AggregateResultIterable(String strQuery)
		{
			this.strQuery=strQuery;
		}
		
        global Iterator<AggregateResult> Iterator()
        {
            return new AggregateResultIterator(strQuery);
       }
    }

    global class AggregateResultIterator implements Iterator<AggregateResult>
    {
        AggregateResult [] results {get;set;}
        Integer index {get; set;} 
                
        global AggregateResultIterator(String strQuery) 
        {
            index = 0;
            results = Database.query(strQuery);            
        } 
        
        global boolean hasNext()
        { 
           return results != null && !results.isEmpty() && index < results.size(); 
        }    
        
        global AggregateResult next(){ 
            return results[index++];            
        }       
    }
	
	global UpdateCompanyFinancialsBatchable	()
	{
		Integer iYear=date.today().year();
		strQuery='SELECT Company__c,  Min(Numeric_Year__c) year FROM Company_Financial__c WHERE isdeleted=false AND Type__c=\'Estimated\' AND Numeric_Year__c>='+iYear+'  GROUP BY Company__c order by company__c, min(numeric_year__c)';
	}
	
	global Iterable<AggregateResult> start(Database.batchableContext info)
	{
        return new AggregateResultIterable(strQuery);
    }
    
/*	
	global Database.QueryLocator start(Database.BatchableContext bc) 
	{
		System.debug(strQuery);
        return Database.getQueryLocator(strQuery);
    }
*/
	global void execute(Database.BatchableContext bc, List<AggregateResult> batch) 
	{
		updateCompanies(batch);
	}
	
	global void updateCompanies(List<AggregateResult> batch)
	{
		Map<Id,Decimal> mCompaniesWithYears=new Map<Id,Decimal>();
		Map<Id,Account> mCompaniesToUpdate=new Map<Id,Account>();
		
		for (AggregateResult cf : (List<AggregateResult>) batch)
		{
			mCompaniesWithYears.put((Id)cf.get('Company__c'),(Decimal)cf.get('year'));
		}
		
		List<Company_Financial__c> lCFs=[SELECT Id,Company__c,Numeric_Year__c FROM Company_Financial__c WHERE Company__c In :mCompaniesWithYears.keySet() AND isdeleted=false AND Type__c='Estimated' order by Numeric_Year__c ASC ];
		
		for(Company_Financial__c cf : lCFs)
		{
			if(cf.Numeric_Year__c == mCompaniesWithYears.get(cf.Company__c))
			{
				mCompaniesToUpdate.put(cf.Company__c, new Account(ID=cf.Company__c, Projected_Financials__c=cf.Id));
			}
		}
		
		if(mCompaniesToUpdate.size()>0)
			update mCompaniesToUpdate.values();		
	}
	
	global void finish(Database.BatchableContext bc) {}
	
	static testMethod void testUpdateCompanyFinancialsBatchable() 
	{	
		Account a1=new Account(name='a1');
		Account a2=new Account(name='a2');
		insert a1;
		insert a2;
		
		List<Company_Financial__c> lCFs=new List<Company_Financial__c>();
		Integer iYear=date.today().year();
		
		for(Integer i=0;i<5;++i)
		{
			lCFs.add(new Company_Financial__c(Company__c=a1.Id, Type__c='Estimated', Year__c=String.valueOf(iYear+i)));
			lCFs.add(new Company_Financial__c(Company__c=a2.Id, Type__c='Estimated', Year__c=String.valueOf(iYear+i-1)));
		}
		
		insert lCFs;
		System.debug(lCFs);
		
		Test.startTest();
        Database.executeBatch(new UpdateCompanyFinancialsBatchable());
        Test.stopTest();
        
        List<Account> lA=[SELECT Id,Name,Projected_Financials__c FROM Account WHERE Id=:a1.Id OR Id=:a2.Id];
        System.debug(lA);
	}
}