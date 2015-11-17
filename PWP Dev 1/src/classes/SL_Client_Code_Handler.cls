public with sharing class SL_Client_Code_Handler 
{
    public void onBeforeInsert(List<Client_Code__c> lstClientCode)
    {
        map<Id, Client_Code__c> mapCompanyIdToClientCode = new map<Id, Client_Code__c>();
        set<Id> setClientId = new set<Id>();
        for(Client_Code__c objClientCode: lstClientCode)
        {
            setClientId.add(objClientCode.Client__c);
            mapCompanyIdToClientCode.put(objClientCode.Client__c, objClientCode);
        }
        
    }
}