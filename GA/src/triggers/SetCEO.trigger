trigger SetCEO on Contact (after insert, after update) 
{
    Map<String,String> mA=new Map<String,String>();
      
    for(Contact c : trigger.new)
    {
        if((c.Title!=null) && c.Title.equalsIgnoreCase('CEO'))
            mA.put(c.AccountId,c.Id);
    }
    
    if(mA.size()>0)
    {
        List<Account> lA=[SELECT Id, Name, CEO__c FROM Account WHERE Id IN :mA.keySet() ];
        
        for(Account a : lA)
        {
            a.CEO__c=mA.get(a.Id);
        }
        
        update lA;
    }
}