/**
	@ClassName    : SL_User_Handler
	@JIRATicket   : YNHH-109,138
	@CreatedOn    : 7/17/2015
	@CreatedBy    : Sandeep
	@ModifiedBy   : Sanath on 4th July,2015 
	@Description  : This is the handler class for User trigger(SL_User).
*/
public class SL_User_Handler 
{
    public class UserLicenseHandler_Exception extends Exception {}
    
    /**
		@MethodName : onAfterInsert
		@Param 		: List<User> lstUser
		@Description: This method called on after insert of user record 
    **/
    public void onAfterInsert(List<User> lstUser)
    {
        //

    }
    
    /**
		@MethodName : onAfterUpdate
		@Param 		: map<Id, User> mapNewUser, map<Id, User> mapOldUser
		@Description: This method called on after update of user record
    **/
    public void onBeforeUpdate(map<Id, User> mapNewUser, map<Id, User> mapOldUser)
    {
       assignPermissionSet(mapNewUser, mapOldUser);
    }

    private void assignPermissionSet(map<Id, User> mapNewUser, map<Id, User> mapOldUser)
    {
        set<Id> setUserId = new set<Id>();
        map<Id , set<String>> mapUserToPermissionsetToDelete = new map<Id , set<String>>();
        map<String , String> mapPermissionSetMapping = new map<String, String>();
        set<String> setPermissions = new set<String>();
        for(ProcessLevelMapping__c objCustomSetting : ProcessLevelMapping__c.getAll().values())
        {
            mapPermissionSetMapping.put(objCustomSetting.Name , objCustomSetting.Permission_Set_Name__c); 
        }

        for(User objUser : mapNewUser.values())
        {
            /* Please update this code as follows:

                Please assume that Job_Code__c and Process_Level_1__ will 
                contain a **comma separated list** of values.  Please use string.split(',') 
                and ensure that the permission sets assigned match all of the values in
                the resulting array */
            if(!mapUserToPermissionsetToDelete.containsKey(objUser.Id))
                mapUserToPermissionsetToDelete.put(objUser.Id , new set<String>());
            
            if(objUser.Job_Code__c != mapOldUser.get(objUser.Id).Job_Code__c)
            {
                mapUserToPermissionsetToDelete.get(objUser.Id).add(mapOldUser.get(objUser.Id).Job_Code__c);
                setPermissions.add(mapOldUser.get(objUser.Id).Job_Code__c);
                setUserId.add(objUser.Id);
                setPermissions.add(objUser.Job_Code__c);
            }
            
            if(objUser.Process_Level_1__c != mapOldUser.get(objUser.Id).Process_Level_1__c)
            {
                mapUserToPermissionsetToDelete.get(objUser.Id).add(mapOldUser.get(objUser.Id).Process_Level_1__c);
                setPermissions.add(mapOldUser.get(objUser.Id).Process_Level_1__c);
                setUserId.add(objUser.Id);
                setPermissions.add(objUser.Process_Level_1__c);
            }
            
            if(objUser.Process_Level_2__c != mapOldUser.get(objUser.Id).Process_Level_2__c)
            {
                mapUserToPermissionsetToDelete.get(objUser.Id).add(mapOldUser.get(objUser.Id).Process_Level_2__c);
                setPermissions.add(mapOldUser.get(objUser.Id).Process_Level_2__c);
                setUserId.add(objUser.Id);
                setPermissions.add(objUser.Process_Level_2__c);
            }
        }
        if(!setUserId.isEmpty())
        {
            map<String , PermissionSet> mapAPInamePermissionSet = new map<String , PermissionSet>();
            set<Id> setPermissionSetId = new set<Id>();
            set<String> setPermissionKeys = new set<String>();
            map<Id , PermissionSetAssignment> mapIdToPermissionSet = new map<Id , PermissionSetAssignment>(); 
            for(String str : setPermissions)
            {
                if(mapPermissionSetMapping.containsKey(str))
                {
                    setPermissionKeys.add(mapPermissionSetMapping.get(str));
                }    
            }
            for(PermissionSet objPermissions : [Select Id , Label , Name from PermissionSet where Name IN:setPermissionKeys])
            {
                mapAPInamePermissionSet.put(objPermissions.Name , objPermissions);
                setPermissionSetId.add(objPermissions.Id);
            }


            for(PermissionSetAssignment objPermissionAssignment : [Select Id , AssigneeId , PermissionSetId from PermissionSetAssignment where AssigneeId IN :setUserId AND PermissionSetId IN :setPermissionSetId])
            {
                mapIdToPermissionSet.put(objPermissionAssignment.Id , objPermissionAssignment);
            }    
            //Permission set to Delete
            if(mapOldUser!= null)
            {
                List<PermissionSetAssignment> lstPermissionSetToDelete = new List<PermissionSetAssignment>();
                for(PermissionSetAssignment objPermissionAssignment : mapIdToPermissionSet.values())
                {
                    if(mapUserToPermissionsetToDelete.containsKey(objPermissionAssignment.AssigneeId))
                    {
                        for(String permission : mapUserToPermissionsetToDelete.get(objPermissionAssignment.AssigneeId)) 
                        {
                             if(mapPermissionSetMapping.containsKey(permission))
                             {
                                 if(mapAPInamePermissionSet.get(mapPermissionSetMapping.get(permission)).Id == objPermissionAssignment.PermissionSetId)
                                 {
                                     lstPermissionSetToDelete.add(objPermissionAssignment);
                                 }
                             }
                        }
                    }
                }
                
                if(!lstPermissionSetToDelete.isEmpty())
                    delete lstPermissionSetToDelete;
            }
            //Insert Permission sets
            /*For Preventing Duplicate Assignments*/
            map<Id , set<Id>> mapUserIdToPermissionSet = new map<Id , set<Id>>();
            for(PermissionSetAssignment objPermissionsSets : [Select Id , AssigneeId , PermissionSetId from PermissionSetAssignment where AssigneeId IN :setUserId])
            {
                if(!mapUserIdToPermissionSet.containsKey(objPermissionsSets.AssigneeId))
                    mapUserIdToPermissionSet.put(objPermissionsSets.AssigneeId , new set<Id>());
                
                mapUserIdToPermissionSet.get(objPermissionsSets.AssigneeId).add(objPermissionsSets.PermissionSetId);    
            }
            /*For Preventing Duplicate Assignments*/
            List<PermissionSetAssignment> lstPermissionSetToInsert = new List<PermissionSetAssignment>();
            map<Id , Set<Id>> mapUserToPermissionsets = new map<Id , set<Id>>();
            for(User objUser : mapNewUser.values())
            {
                if(setUserId.contains(objUser.Id))
                {
                    set<Id> setPermissionsInserted = new set<Id>();
                    setPermissionsInserted.addAll(mapUserIdToPermissionSet.get(objUser.Id)); 
                    if(mapPermissionSetMapping.containsKey(objUser.Job_Code__c))
                    {
                        if(mapAPInamePermissionSet.containsKey(mapPermissionSetMapping.get(objUser.Job_Code__c)) && !setPermissionsInserted.contains(mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Job_Code__c)).Id))
                        {
                            lstPermissionSetToInsert.add(new PermissionSetAssignment(AssigneeId = objUser.Id , PermissionSetId = mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Job_Code__c)).Id));
                            setPermissionsInserted.add(mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Job_Code__c)).Id);
                        }
                    }
                    
                    if(mapPermissionSetMapping.containsKey(objUser.Process_Level_1__c))
                    {
                        if(mapAPInamePermissionSet.containsKey(mapPermissionSetMapping.get(objUser.Process_Level_1__c)) && !setPermissionsInserted.contains(mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Process_Level_1__c)).Id))
                        {
                            lstPermissionSetToInsert.add(new PermissionSetAssignment(AssigneeId = objUser.Id , PermissionSetId = mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Process_Level_1__c)).Id));
                            setPermissionsInserted.add(mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Process_Level_1__c)).Id);
                        }
                    }
                    
                    if(mapPermissionSetMapping.containsKey(objUser.Process_Level_2__c))
                    {
                        if(mapAPInamePermissionSet.containsKey(mapPermissionSetMapping.get(objUser.Process_Level_2__c)) && !setPermissionsInserted.contains(mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Process_Level_2__c)).Id))
                        {
                            lstPermissionSetToInsert.add(new PermissionSetAssignment(AssigneeId = objUser.Id , PermissionSetId = mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Process_Level_2__c)).Id));
                            setPermissionsInserted.add(mapAPInamePermissionSet.get(mapPermissionSetMapping.get(objUser.Process_Level_2__c)).Id);
                        }
                    }
                }
            }
            
            if(!lstPermissionSetToInsert.isEmpty())
            {   
                //try{
                insert lstPermissionSetToInsert;
                //}catch(DMLException e)
                //{
                //    if(e.getMessage().contains('user license doesn\'t match'))
                //    {
                //        UserLicenseHandler_Exception ex = new UserLicenseHandler_Exception();
                //        ex.setMessage('Incorrect User License');
                //        throw ex;
                //    }
                //}
            }    
        }
    }
}