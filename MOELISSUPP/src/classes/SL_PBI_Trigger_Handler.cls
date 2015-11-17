/** 
 * \author Vika Osmak 
 * \date 06/16/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Potential_Buyer_Investor__c trigger handler. Runs onAfterInsert 
 * \test SL_Test_PBI_Trigger_Handler
 */
public without sharing class SL_PBI_Trigger_Handler 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean isFeedToPBIAdded = false;
    
    public SL_PBI_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
     
    public void OnAfterInsert(map<ID,Potential_Buyer_Investor__c> newMap_PBIId_PBIs)
    {   
        if(!isFeedToPBIAdded)
        {
            isFeedToPBIAdded = true;
            setFeedToAccount(newMap_PBIId_PBIs);
        }
    }
    
    private void setFeedToAccount(map<ID,Potential_Buyer_Investor__c> newMap_PBIId_PBIs)
    {
    	Set<Id> listPBIIds = newMap_PBIId_PBIs.keySet(); 
    	map<Id, SL_Trigger_Helper.AccountValues> map_PBIIds_Account = new map<Id, SL_Trigger_Helper.AccountValues>();
    	map<Id, Id> map_PBIId_AccountId = new map<Id, Id>();
    	for(Potential_Buyer_Investor__c item :[	SELECT Id, TargetBuyer__r.Name, TargetBuyer__c
    											FROM Potential_Buyer_Investor__c
    											WHERE Id IN : listPBIIds])
    	{
    		map_PBIIds_Account.put(item.Id,new SL_Trigger_Helper.AccountValues(item.TargetBuyer__c,item.TargetBuyer__r.Name));
    		map_PBIId_AccountId.put(item.Id,item.TargetBuyer__c);
    	}
    	SL_Trigger_Helper.createFeedMessage(map_PBIIds_Account, 'Potential Buyer/Investor');
    
    	//do not add feed to the contacts assosiated with Company
    	//SL_Trigger_Helper.createFeedMessageForContactsOfAccount(map_PBIId_AccountId, 'Potential Buyer/Investor');
    } 
}