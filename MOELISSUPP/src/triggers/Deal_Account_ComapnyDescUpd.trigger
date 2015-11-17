trigger Deal_Account_ComapnyDescUpd on Ibanking_Project__c (before insert)
{
    List<ID> AccIDs = new List<ID>();
    for(Ibanking_Project__c accTmp : Trigger.new)
    {
        if(accTmp.Client__c!=null) AccIDs.add(accTmp.Client__c);
    }
    
    Map<ID,String> mapDealsDesc = new Map<ID,String>{};
    String currAccountDesc = '';
    if(AccIDs.size()>0)
    {
        for(Account accTmp : [select ID,Description from Account where ID in :AccIDs limit 1000]) mapDealsDesc.put(accTmp.ID,accTmp.Description);
        
        for(integer i=0; i<Trigger.new.size();i++)
        {
            if(Trigger.new[i].Client__c!=null)
            {
                if(mapDealsDesc.containsKey(Trigger.new[i].Client__c)) currAccountDesc = mapDealsDesc.get(Trigger.new[i].Client__c);
                else currAccountDesc = '';
                Trigger.new[i].Description__c = currAccountDesc;
            }
        }
    }

}