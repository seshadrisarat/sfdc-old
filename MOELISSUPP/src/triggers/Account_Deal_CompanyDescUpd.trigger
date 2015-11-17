trigger Account_Deal_CompanyDescUpd on Account (after insert, after update)
{
    BigListUpd oppQueue = new BigListUpd('Ibanking_Project__c');
    Map<ID,String> mapDealsDesc = new Map<ID,String>{};
    Map<ID,String> mapDealsDescOld = new Map<ID,String>{};
    String currAccountDesc = '';
    String currAccountDescOLD = '';
    
    for(Account accTmp : Trigger.new) mapDealsDesc.put(accTmp.ID,accTmp.Description);
    if(Trigger.isUpdate){ for(Account accTmp : Trigger.old) mapDealsDescOld.put(accTmp.ID,accTmp.Description);}
    for(Account accTmp : Trigger.new) mapDealsDesc.put(accTmp.ID,accTmp.Description);
    
    for(Ibanking_Project__c curObj : [Select ID, Description__c, Client__c, Client__r.ID From Ibanking_Project__c where Client__r.ID in :Trigger.new limit 1000])
    {
        if(mapDealsDesc.containsKey(curObj.Client__r.ID)) currAccountDesc = mapDealsDesc.get(curObj.Client__r.ID);
        else currAccountDesc = '';
        if(mapDealsDescOld.containsKey(curObj.Client__r.ID)) currAccountDescOLD = mapDealsDescOld.get(curObj.Client__r.ID);
        else currAccountDescOLD = '';

        if(currAccountDesc!=currAccountDescOLD)
        {
            curObj.Description__c = currAccountDesc;
            oppQueue.add(curObj);
        }
    }
    
    oppQueue.updateAll();
}