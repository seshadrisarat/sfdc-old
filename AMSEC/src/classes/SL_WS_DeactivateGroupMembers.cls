/**
* \arg ClassName      : SL_WS_DeactivateGroupMembers
* \arg JIRATicket     : AMSEC-12
* \arg CreatedOn      : 31/MARCH/2015
* \arg LastModifiedOn : 21/MAY/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : Webservice controller class to deactivating External_Working_Group_Member__c.
*/
global with sharing class SL_WS_DeactivateGroupMembers 
{
    /* Start variables */
    /* End variables */
    
    /*Start constructor*/
    global SL_WS_DeactivateGroupMembers()
    {
        //do nothing.
    }
    /*End constructor*/
    
    /*
        * MethodName    : deactivateGroupMembers()
        * param         : String of comma seperated External_Working_Group_Member__c Ids
        * Description   : This method is used for deactivating External_Working_Group_Member__c. 
    */
    Webservice static String deactivateGroupMembers(String strCSVWorkingGroupMemberIds, String strParentId)
    {
        String strMessage = 'success';
        Set<String> setMemberIds = new Set<String>();
        Set<String> setFullAccessUserIds = new Set<String>();
        Id parenId = Id.valueOf(strParentId);
        Id profileId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        List<External_Working_Group_Member__c> lstEWGMemberToUpdate = new List<External_Working_Group_Member__c>();
        
        setFullAccessUserIds = SL_ManageMassGroupMembers.checkPublicGroupMemberAccessiblity('fullaccess');
        
        String parentObjectAPIName = (parenId.getSobjectType() == Deal__c.getSobjectType()) 
			                          ? 'Deal__c' 
			                          : (parenId.getSobjectType() == Account.getSobjectType()) 
			                          ? 'Company__c' 
			                          : 'AS_Project__c';
			                          
        if(parentObjectAPIName == 'Company__c' || parentObjectAPIName == 'Deal__c')
		    setMemberIds = SL_ManageMassGroupMembers.checkPublicGroupMemberAccessiblity('AS_Project__c');
		    
		else 
		    setMemberIds = SL_ManageMassGroupMembers.checkPublicGroupMemberAccessiblity('Deal__c');
        
        if(!setMemberIds.contains(UserInfo.getUserId()) || profileId == UserInfo.getProfileId() || setFullAccessUserIds.contains(UserInfo.getUserId()))
        {
            if(!String.isBlank(strCSVWorkingGroupMemberIds))
            {
                Set<String> setWorkingGroupMemberIds = new Set<String>();//Set of External_Working_Group_Member__c ids
                setWorkingGroupMemberIds.addAll(strCSVWorkingGroupMemberIds.split(','));
                
                //Iterating on External_Working_Group_Member__c to set the End_date__c as today.
                for(External_Working_Group_Member__c objEWGMember : [SELECT Id, End_Date__c 
                                                                       FROM External_Working_Group_Member__c 
                                                                       WHERE Id IN: setWorkingGroupMemberIds
                                                                       AND End_Date__c = NULL])
                {
                    lstEWGMemberToUpdate.add(new External_Working_Group_Member__c(Id = objEWGMember.Id, End_Date__c = Date.today()));
                }
            }
        }
        else
            strMessage = 'failed';
        
        //Updating list of External_Working_Group_Member__c
        if(!lstEWGMemberToUpdate.isEmpty())
            update lstEWGMemberToUpdate;
        
        return strMessage;
    }
    /* End */
}