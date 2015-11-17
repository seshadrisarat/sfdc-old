trigger CompanyFinancialsFields on Company_Financial__c (after insert, after update, after delete, after undelete)  {
    Map<Id,Account> latestFinancials = new Map<Id,Account>();
    Map<Id, Account> accounts = new Map<Id, Account>();
    for (Company_Financial__c cf : (Trigger.isDelete ? Trigger.old :Trigger.new)) {
        accounts.put(cf.Company__c, null);
    }
    accounts.remove(null);
    
 /*   **CWD-- removed this in favour of batch apex solution as new logic is to select most current estimated financials. this moves with time so schedulable apex made the most sense
	List<Account> lA_Projected=[SELECT Id,Projected_Financials__c,(SELECT Id, Numeric_Year__c, Year__c FROM Company_Financials__r WHERE Type__c='Estimated' ORDER BY Year__c DESC LIMIT 1) FROM Account WHERE Id IN:accounts.keySet() ];
	
	for(Account a: lA_Projected)
	{
		a.Projected_Financials__c=null; //CWD-- wipe out existing projection
		
		for(Company_Financial__c cf : a.Company_Financials__r)
		{
			if(cf.Numeric_Year__c >= date.today().year()) //CWD-- only include future projections
				a.Projected_Financials__c=cf.Id;
		}
	}
	
	update lA_Projected;
*/

    accounts = new Map<Id, Account>([SELECT Id, (SELECT Revenue_Growth__c, Revenue_MM__c, Year__c FROM Company_Financials__r WHERE Type__c<>'Estimated' ORDER BY Year__c DESC) FROM Account WHERE Id IN :accounts.keySet()]);
    List<Company_Financial__c> financials = new List<Company_Financial__c>();
    for (Account a : accounts.values()) {
        Integer i = 1;
        for (Company_Financial__c cf : a.Company_Financials__r) {
            // Set company most recent financials
            if (!latestFinancials.containsKey(a.Id)) {
                latestFinancials.put(a.Id,new Account(
                    Id=a.Id,
                    Revenue__c = cf.Revenue_MM__c,
                    Latest_Financials__c=cf.Id,
                    Projected_Financials__c=null
                ));
            }
            Company_Financial__c financial = new Company_Financial__c(
                Id = cf.Id,
                Revenue_Growth__c = null
            );
            try {
                Company_Financial__c pcf = a.Company_Financials__r.get(i);
                financial.Revenue_Growth__c = (cf.Revenue_MM__c == null || pcf.Revenue_MM__c == null ? 1 : cf.Revenue_MM__c / pcf.Revenue_MM__c) - 1;
            } catch (Exception e) {
            }
            if (cf.Revenue_Growth__c != financial.Revenue_Growth__c) {
                financials.add(financial);
            }
            i++;
        }
    }
    if (!latestFinancials.values().isEmpty()) {
        update latestFinancials.values();
    }
    
    if (!financials.isEmpty()) {
        update financials;
    }
    
    /* **CWD-- update projected financials now */
	Integer iYear=date.today().year();
	List<AggregateResult> lA_Projected=[SELECT Company__c,  Min(Numeric_Year__c) year FROM Company_Financial__c WHERE isdeleted=false AND Type__c='Estimated' AND Numeric_Year__c>=:iYear AND Company__c IN :accounts.keySet() GROUP BY Company__c order by company__c, min(numeric_year__c)];
	UpdateCompanyFinancialsBatchable ucfb=new UpdateCompanyFinancialsBatchable();
	ucfb.updateCompanies(lA_Projected);    
}


/*
trigger CompanyFinancialsFields on Company_Financial__c (before insert, before update) 
{
    List<Company_Financial__c> lCF=new List<Company_Financial__c>();
    
    for(Company_Financial__c cf : trigger.new)
    {
        if(cf.Year__c!=null)
        {
            try
            {
                Integer iYear=Integer.valueOf(cf.Year__c);
                --iYear;
                List<Company_Financial__c> lcfPrev=[SELECT Id,Revenue_MM__c FROM Company_Financial__c WHERE Company__c=:cf.Company__c AND Year__c=:(''+iYear)];
            
                if(lcfPrev.size()>0)
                {
                    Company_Financial__c cfPrev=lcfPrev.get(0);
                    
                    if(cfPrev.Revenue_MM__c!=null)
                        cf.Revenue_Growth__c=(cf.Revenue_MM__c/cfPrev.Revenue_MM__c)-1;
                    else
                        cf.Revenue_Growth__c=0;
                }
                else
                    cf.Revenue_Growth__c=0;
            }
            catch(System.TypeException eTE)
            {
                cf.Revenue_Growth__c=0;
            }
        }
    }
    
    if(lCF.size()>0)
        update lCF;
}
*/