/** 
 * \author Vika Osmak 
 * \date 06/16/11
 * \see http://silverline.jira.com/browse/MC-2
 * \brief Potential_Buyer_Investor_Contact__c trigger handler. Runs onAfterInsert 
 * \test SL_Test_PBIContact_Trigger_Handler
 */
public without sharing class SL_PBIContact_Trigger_Handler 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean isFeedToPBICAdded = false;
    
    public SL_PBIContact_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    } 
     
    public void OnAfterInsert(map<ID,Potential_Buyer_Investor_Contact__c> newMap_PBICId_PBICs)
    {   
        if(!isFeedToPBICAdded)
        {
            isFeedToPBICAdded = true;
            setFeedToContact(newMap_PBICId_PBICs);
        }
    }
    
    private void setFeedToContact(map<ID,Potential_Buyer_Investor_Contact__c> newMap_PBICId_PBICs)
    {
    	Set<Id> listPBICIds = newMap_PBICId_PBICs.keySet(); 
    	map<Id, list<SL_Trigger_Helper.AccountValues>> map_objID_objName = new map<Id, list<SL_Trigger_Helper.AccountValues>>();
    	for(Potential_Buyer_Investor_Contact__c item :[	SELECT Id, Contact__r.Name, Contact__c, Contact__r.Account.Name
    											FROM Potential_Buyer_Investor_Contact__c
    											WHERE Id IN : listPBICIds])
    	{
    		if(!map_objID_objName.keySet().contains(item.Id)) map_objID_objName.put(item.Id, new list<SL_Trigger_Helper.AccountValues>());
    		map_objID_objName.get(item.Id).add(new SL_Trigger_Helper.AccountValues(
    													item.Contact__c,
    													item.Contact__r.Name,
    													item.Contact__r.Account.Name));
    	}
    	SL_Trigger_Helper.createFeedMessageMulty(map_objID_objName, 'Potential Buyer/Investor Contact');
    } 
}