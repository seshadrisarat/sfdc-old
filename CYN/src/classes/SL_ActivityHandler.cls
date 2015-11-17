/**
*  ClassName      : SL_ActivityHandler
*  JIRATicket     : CYN-5
*  CreatedOn      : 9/29/15
*  ModifiedBy     : Sanath
*  Description    : Handler for trigger on Task
*/
public class SL_ActivityHandler 
{
    
    /*
        * MethodName        : onBeforeInsert
        * param             : trigger.new(Before Insert) 
        * Description       : Method to assign User Id values for Laser_Owned__c to created Task record
    */
    
    public void onBeforeInsert(List<Task> lstTriggerNew)
	{
	    set<Id> setLaserOwned = new set<Id>();
	    Map<Id , Laser_Owned__c> mapIdToLaserOwned = new Map<Id , Laser_Owned__c>();
        
        for(Task objTask : lstTriggerNew)
        {
            if(objTask.WhatId.getSObjectType() == Laser_Owned__c.SObjectType)
            {
                setLaserOwned.add(objTask.WhatId); 
            }
        }
        if(!setLaserOwned.isEmpty())
        {
            for(Laser_Owned__c objLaserOwned : [Select User_1__c, User_2__c, User_3__c, User_4__c,
                                                   User_5__c, User_6__c, User_7__c
                                            from Laser_Owned__c
                                            where Id In :setLaserOwned ])
            {
                mapIdToLaserOwned.put(objLaserOwned.Id , objLaserOwned);
            }
            for(Task objTask : lstTriggerNew)
            {
                if(mapIdToLaserOwned.containsKey(objTask.WhatId))
                {
                    Laser_Owned__c objLaserOwned = mapIdToLaserOwned.get(objTask.WhatId);
                    objTask.OwnerId = objTask.User_1_Id__c = objLaserOwned.User_1__c;
                    objTask.User_2__c = objLaserOwned.User_2__c;
                    objTask.User_3__c = objLaserOwned.User_3__c;
                    objTask.User_4__c = objLaserOwned.User_4__c;
                    objTask.User_5__c = objLaserOwned.User_5__c;
                    objTask.User_6__c = objLaserOwned.User_6__c;
                    objTask.User_7__c = objLaserOwned.User_7__c;
                    
                    if(objTask.Subject!=NULL)
                    	objTask.Subject = objTask.Subject.toUpperCase();
                }
            }        
        }
    }
	
}