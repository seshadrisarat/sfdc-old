/**
* \arg ClassName        : SL_DealTeamMemberHandler
* \arg JIRATicket       : FBR-2
* \arg CreatedOn        : 19/MAR/2015
* \arg LastModifiedOn   : 7/April/2015
* \arg CreatededBy      : Pankaj Ganwani
* \arg LastModifiedBy   : Bryan Anderson
*/
public class SL_DealTeamMemberHandler 
{   
    
    /* Start - Constructor */
    public SL_DealTeamMemberHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    /*
        * MethodName   : onAfterInsert
        * Param        : map of inserted deal team members
        * Description  : This method is used to create sharing records corresponding to the inserted deal team members
    */
    public static void onAfterInsert(List<Deal_Team_Member__c> lstDealTeamMember)
    {
        createSharingRecords(lstDealTeamMember);
    }
    
    /**
        @MethodName : onAfterUpdate
        @Param      : new and old map of updated deal team members  
        @Description: This method is used to update sharing records corresponding to the updated deal team members
    **/  
    public static void onAfterUpdate(Map<Id,Deal_Team_Member__c> mapNewIdToDealTeamMember, Map<Id,Deal_Team_Member__c> mapOldIdToDealTeamMember)
    {
        List<Deal_Team_Member__c> lstDealTeamMemberToDelete = new List<Deal_Team_Member__c>();
        List<Deal_Team_Member__c> lstDealTeamMemberToInsert = new List<Deal_Team_Member__c>();
        
        for(Deal_Team_Member__c objDealTeamMember : mapNewIdToDealTeamMember.values())
        {
            if((objDealTeamMember.Status__c != mapOldIdToDealTeamMember.get(objDealTeamMember.Id).Status__c) && (objDealTeamMember.Status__c == 'Inactive'))
                lstDealTeamMemberToDelete.add(objDealTeamMember);
                
            if((objDealTeamMember.Status__c != mapOldIdToDealTeamMember.get(objDealTeamMember.Id).Status__c) && (objDealTeamMember.Status__c == 'Active'))
                lstDealTeamMemberToInsert.add(objDealTeamMember);
        }
        
        if(!lstDealTeamMemberToDelete.isEmpty())
            deleteSharingRecords(lstDealTeamMemberToDelete);
                    
        if(!lstDealTeamMemberToInsert.isEmpty())
            createSharingRecords(lstDealTeamMemberToInsert);
    }
    
    /*
        * MethodName   : onAfterDelete
        * Param        : list of deleted deal team member records
        * Description  : This method is used to delete the sharing records corresponding to the deleted deal team members.
    */
    public static void onAfterDelete(List<Deal_Team_Member__c> lstDealTeamMember)
    {
        deleteSharingRecords(lstDealTeamMember);
    }
    
    /*
        * MethodName   : createSharingRecords
        * Param        : set of ids of deal team members
        * Description  : Method to create sharing records and it is called by onAfterInsert method.
    */
    private static void createSharingRecords(List<Deal_Team_Member__c> lstDealTeamMember) 
    {
         SL_Util_CreateSharingRecords.createDealSharingRecords([SELECT Related_Deal__c, FBR_Team_Member__r.User__c, Status__c FROM Deal_Team_Member__c WHERE Id IN : lstDealTeamMember AND FBR_Team_Member__r.User__c!=null AND Status__c = 'Active']);
    }
    
    /*
        * MethodName   : deleteSharingRecords
        * Param        : list to hold deal team members
        * Description  : Method to delete sharing records and it is called by onAfterDelete method.
    */
    private static void deleteSharingRecords(List<Deal_Team_Member__c> lstDealTeamMember)
    {
        Set<Id> setDealId = new Set<Id>();
        Set<Id> setContactId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        Set<String> setDealIdToUserId = new Set<String>();
        List<Deals__Share> lstDealShare = new List<Deals__Share>();//list of deal share records that needs to be deleted.
        
        //Iterating over deal team member object to hold deals and contacts
        for(Deal_Team_Member__c objDTM : lstDealTeamMember)
        {
            setDealId.add(objDTM.Related_Deal__c);
            setContactId.add(objDTM.FBR_Team_Member__c);
        }
        
        //Fetching the user records corresponding to the Contact records
        for(Contact objContact : [SELECT User__c FROM Contact WHERE Id IN : setContactId AND User__c!=null])
        {
            setUserId.add(objContact.User__c);
        }
        
        //Finding those deal team members which correspondence to the same deal and same contact that are to be deleted so that sharing records cannot be deleted
        for(AggregateResult objAgg : [SELECT COUNT(ID) numOfTeamMembers, FBR_Team_Member__r.User__c userId, Status__c statusId, Related_Deal__c dealId FROM Deal_Team_Member__c WHERE Related_Deal__c IN : setDealId AND FBR_Team_Member__r.User__c IN : setUserId AND Status__c = 'Active' GROUP BY FBR_Team_Member__r.User__c, Related_Deal__c, Status__c])
        {
            if(Integer.valueOf(objAgg.get('numOfTeamMembers')) > 0)
                setDealIdToUserId.add(objAgg.get('dealId')+'_'+objAgg.get('userId'));
        }
        
        //fetching sharing that needs to be deleted.
        for(Deals__Share objDealShare : [SELECT ParentId, UserOrGroupId FROM Deals__Share WHERE ParentId IN : setDealId AND UserOrGroupId IN : setUserId])
        {
            if(!setDealIdToUserId.contains(objDealShare.ParentId+'_'+objDealShare.UserOrGroupId))
                lstDealShare.add(objDealShare);
        }
        
        if(!lstDealShare.isEmpty())
            //Database.delete(lstDealShare,false);
            delete lstDealShare;
    }
}