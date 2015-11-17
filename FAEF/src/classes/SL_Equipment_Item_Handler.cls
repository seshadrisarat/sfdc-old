public with sharing class SL_Equipment_Item_Handler
{
	public SL_Equipment_Item_Handler()
	{		
	}

	public void onAfterInsert(Map<Id, Equipment_Item__c> newMap)
    {
    	updateEquipDispItemCount(newMap.values());
    }

    public void onAfterUpdate(Map<Id, Equipment_Item__c> oldMap,Map<Id, Equipment_Item__c> newMap)
    {
    	updateEquipDispItemCount(newMap.values());
    }

    public void updateEquipDispItemCount(Equipment_Item__c[] eIList)
    {
    	Set<Id> edISet = new Set<Id>();
    	Equipment_Disposition_Item__c[] ediList = new Equipment_Disposition_Item__c[]{};
    	Equipment_Disposition_Item__c[] ediUpdate = new Equipment_Disposition_Item__c[]{};

    	for(Equipment_Item__c e : eIList)
    	{
    		if(e.Equipment_Disposition_Item__c != null)
    		{
    			ediSet.add(e.Equipment_Disposition_Item__c);
    		}
    	}

    	System.debug(ediSet);

    	ediList = [Select Id,(Select Id From Equipment_Items__r) From Equipment_Disposition_Item__c WHERE Id IN: ediSet];

    	for(Equipment_Disposition_Item__c e : ediList)
    	{
    		System.debug(e.Equipment_Items__r.size());
    		ediUpdate.add(new Equipment_Disposition_Item__c(Id = e.Id, Equipment_Item_Count__c = e.Equipment_Items__r.size()));
    	}

    	update ediUpdate;
    }
}