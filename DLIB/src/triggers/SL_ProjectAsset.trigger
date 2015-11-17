/**
* @Trigger          : Project_Asset__c
* @JIRATicket       : DLIB-3
* @CreatedOn        : 20/AUG/2014
* @ModifiedBy       : Harsh
* @Description      : This is the trigger on Project_Asset__c Object
*/

trigger SL_ProjectAsset on Project_Asset__c (after undelete, after update, after insert) 
{
    SL_ProjectAssetHandler objProjectAssetHandler = new SL_ProjectAssetHandler(Trigger.isExecuting, Trigger.size);
    
    if(trigger.isAfter && trigger.isInsert)
    {
        //calling functions of handler class on before insert
        objProjectAssetHandler.onAfterInsert(Trigger.new); 
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
    	//calling functions of handler class on after insert
    	objProjectAssetHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);    
    }
    
    if(trigger.isAfter && trigger.isUnDelete)
    {
    	//calling functions of handler class on after undelete
    	objProjectAssetHandler.onAfterUndelete(trigger.new);
    }
}