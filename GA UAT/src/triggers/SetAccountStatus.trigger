trigger SetAccountStatus on Deal__c (after insert, after update, after delete, after undelete) {
    List<Deal__c> deals = new List<Deal__c>();
    
    if (Trigger.isDelete) 
    {
        deals = Trigger.old;
    } 
    else 
    {
        deals = Trigger.new;
    }

    Set<Id> accountIds = new Set<Id>();
    
    for (Deal__c d : deals) 
    {
        accountIds.add(d.Related_Company__c);
        
        if (Trigger.isUpdate) 
        {
            accountIds.add(Trigger.oldMap.get(d.Id).Related_Company__c);
        }
    }
    
    accountIds.remove(null);

    List<Account> accounts = new List<Account>();
    
    if (!accountIds.isEmpty()) 
    {
        Set<String> inactiveStatus = new Set<String> { 'Closed', 'Passed', 'Funded by Others', 'On Hold', 'Evaluating' };
        Map<Id, Id> accountDealMap = new Map<Id, Id>();
        
        for (Deal__c d : [SELECT Id, Related_Company__c FROM Deal__c WHERE Related_Company__c IN :accountIds AND Status__c NOT IN :inactiveStatus AND IsDeleted=FALSE ORDER BY CreatedDate DESC]) 
        {
            accountDealMap.put(d.Related_Company__c, d.Id);
        }

        for (Account a : [SELECT Id, Deal__c, Status__c FROM Account WHERE Id IN :accountIds AND IsDeleted=FALSE]) 
        {
            Id dealId = accountDealMap.get(a.Id);
            
            if (dealId == null) 
            {
                if (a.Deal__c != null) 
                {
                    accounts.add(new Account( Id = a.Id, Deal__c = null, Status__c = 'Monitor' ));             
                }
            } 
            else 
            {
                if (a.Deal__c != dealId || a.Status__c != 'Live Deal') 
                {
                    Account acc = new Account( Id = a.Id, Deal__c = dealId, Status__c = 'Live Deal' );
                    accounts.add(acc);
                }
            }
        }
    }

    if (!accounts.isEmpty()) 
    {
        //update accounts;  //CWD-- **20111006-- turning this off until we can figure out a proper worflow here
    }
}