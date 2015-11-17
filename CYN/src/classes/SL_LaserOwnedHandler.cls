/**
*  ClassName      : SL_LaserOwnedHandler
*  JIRATicket     : CYN-5
*  CreatedOn      : 9/29/15
*  ModifiedBy     : Sanath
*  Description    : Handler for trigger on Laser Owned
*/
public class SL_LaserOwnedHandler 
{
    
    /*
        * MethodName        : onAfterUpdate
        * param             : trigger.new , trigger.oldMap
        * Description       : Method to assign User Id values for Laser_Owned__c to created Task record
    */
    
	public void onAfterUpdate(List<Laser_Owned__c> lstTriggerNew , map<Id , Laser_Owned__c> mapIdToTriggerOld)
	{
	    map<Id , Laser_Owned__c> mapIdToLaserOwned = new map<Id , Laser_Owned__c>();
	    for(Laser_Owned__c objLaser : lstTriggerNew)
	    {
	        Laser_Owned__c objOldLaser = mapIdToTriggerOld.get(objLaser.Id);
	        if(objLaser.User_1__c != objOldLaser.User_1__c || objLaser.User_2__c != objOldLaser.User_2__c || objLaser.User_3__c != objOldLaser.User_3__c ||
	           objLaser.User_4__c != objOldLaser.User_4__c || objLaser.User_5__c != objOldLaser.User_5__c || objLaser.User_6__c != objOldLaser.User_6__c ||
	           objLaser.User_7__c != objOldLaser.User_7__c)
	       {
	           mapIdToLaserOwned.put(objLaser.Id , objLaser);    
	       }
	    }
	    if(!mapIdToLaserOwned.isEmpty())
	        updateTask(mapIdToLaserOwned);
	}
	
	/*
        * MethodName        : updateTask
        * param             : map(Laser_Owned__c)
        * Description       : Method to assign User Id values for Laser_Owned__c to created Task record
    */
	
	private void updateTask(map<Id , Laser_Owned__c> mapIdToLaserOwned)
	{
	    List<Task> lstTaskToUpdate = new List<Task>();
	    for(Task objTask : [Select Id,WhatId from Task where WhatId IN: mapIdToLaserOwned.keyset()])
	    {
	       Laser_Owned__c objLaserOwn = mapIdToLaserOwned.get(objTask.WhatId);
	       lstTaskToUpdate.add(new Task(Id=objTask.Id , User_1_Id__c = objLaserOwn.User_1__c ,
	                                                    User_2__c = objLaserOwn.User_2__c,
	                                                    User_3__c = objLaserOwn.User_3__c,
	                                                    User_4__c = objLaserOwn.User_4__c,
	                                                    User_5__c = objLaserOwn.User_5__c,
	                                                    User_6__c = objLaserOwn.User_6__c,
	                                                    User_7__c = objLaserOwn.User_7__c));     
	    }
	    if(!lstTaskToUpdate.isEmpty())
	        update lstTaskToUpdate;
	}
}