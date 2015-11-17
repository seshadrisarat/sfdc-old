/** 
 * \author Vika Osmak 
 * \date 06/15/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Project_Client_Contact__c trigger handler. Runs onAfterInsert 
 * \test SL_Test_ProjectClientContact_Trigger
 */
public without sharing class SL_ProjectClientContact_Trigger_Handler 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean isFeedToPBICAdded = false;
    
    public SL_ProjectClientContact_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    } 
     
    public void OnAfterInsert(map<ID,Project_Client_Contact__c> newMap_PCCId_PCCs)
    {   
        if(!isFeedToPBICAdded)
        {
            isFeedToPBICAdded = true;
            setFeedToContact(newMap_PCCId_PCCs);
        }
    }
    
    private void setFeedToContact(map<ID,Project_Client_Contact__c> newMap_PBICId_PBICs)
    {
    	Set<Id> listPCCIds = newMap_PBICId_PBICs.keySet(); 
    	map<Id, SL_Trigger_Helper.AccountValues> map_objID_objName = new map<Id, SL_Trigger_Helper.AccountValues>();
    	map<Id, SL_Trigger_Helper.AccountValues> map_objID_objContactAccount = new map<Id, SL_Trigger_Helper.AccountValues>();
    	for(Project_Client_Contact__c item :[	SELECT Id, Client_Contact__r.Name,Client_Contact__r.Account.Name, Client_Contact__c,Moelis_Project__r.Client__r.Name
    											FROM Project_Client_Contact__c
    											WHERE Id IN : listPCCIds]) 
    	{
    		map_objID_objName.put(item.Id,new SL_Trigger_Helper.AccountValues(
    												item.Client_Contact__c,
    												item.Client_Contact__r.Name,
    												item.Client_Contact__r.Account.Name));
    		map_objID_objContactAccount.put(item.Id,new SL_Trigger_Helper.AccountValues(
    												/*item.Moelis_Project__r.Client__c,*/
    												item.Client_Contact__r.Account.Id,
    												item.Client_Contact__r.Name,
    												item.Client_Contact__r.Account.Name));
    	}
    	//add feed to added contact
    	SL_Trigger_Helper.createFeedMessage(map_objID_objName, 'Project Client Contact');
    	
    	SL_Trigger_Helper.createFeedMessage(map_objID_objContactAccount, 'Project Client Contact');
    } 
}