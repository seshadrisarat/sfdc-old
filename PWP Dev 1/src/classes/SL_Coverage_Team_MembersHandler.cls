/**
* \arg ClassName      : SL_Coverage_Team_MembersHandler
* \arg JIRATicket     : PWP-11,PWP-9
* \arg CreatedOn      : 18/DEC/2014
* \arg LastModifiedOn : 29/DEC/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is the Handler class for SL_Coverage_Team_Members Trigger.
*/
public without sharing class SL_Coverage_Team_MembersHandler 
{
    /**
        @MethodName : onAfterInsert
        @Param      : List<Coverage_Team_Members__c> lstCoverageTeamMembers 
        @Description: This method called on after insert of Coverage_Team_Members__c record.
    **/
    public void onAfterInsert(List<Coverage_Team_Members__c> lstCoverageTeamMembers)
    {
        //insert new EntitySubscription records corresponding to new CoverageTeamMembers records
        createEntitySubscriptionAndCallReportShare(lstCoverageTeamMembers);
    }
    
    /**
        @MethodName : onAfterUpdate
        @Param      : map<Id,Coverage_Team_Members__c> mapNewCoverageTeamMembers, map<Id,Coverage_Team_Members__c> mapOldCoverageTeamMembers 
        @Description: This method called on after update of Coverage_Team_Members__c record.
    **/
    public void onAfterUpdate(Map<Id, Coverage_Team_Members__c> mapNewCoverageTeamMembers, Map<Id,Coverage_Team_Members__c> mapOldCoverageTeamMembers)
    {
        List<Coverage_Team_Members__c> lstCTMToInsertES = new List<Coverage_Team_Members__c>();//List of Coverage_Team_Members__c to create the EntitySubscription
        List<Coverage_Team_Members__c> lstCTMToDeleteES = new List<Coverage_Team_Members__c>();//List of Coverage_Team_Members__c to delete the EntitySubscription
        
        //Iterating on Coverage_Team_Members__c to get the updated Relationship__c whose account or pwp employee is changed
        for(Coverage_Team_Members__c objCTM : mapNewCoverageTeamMembers.values())
        {
            if((objCTM.Company__c != mapOldCoverageTeamMembers.get(objCTM.Id).Company__c || objCTM.PWP_Employee__c != mapOldCoverageTeamMembers.get(objCTM.Id).PWP_Employee__c) && objCTM.Company__c != null && objCTM.PWP_Employee__c != null)
            {
                lstCTMToInsertES.add(objCTM);
                lstCTMToDeleteES.add(mapOldCoverageTeamMembers.get(objCTM.Id));
            }   
        }
            
        //Calling method to delete EntitySubscription records corresponding to Coverage_Team_Members__c
        if(!lstCTMToDeleteES.isEmpty())
            deleteEntitySubscriptionAndCallReportShare(lstCTMToDeleteES);
        //Calling method to create EntitySubscription records corresponding to Coverage_Team_Members__c
        if(!lstCTMToInsertES.isEmpty())
            createEntitySubscriptionAndCallReportShare(lstCTMToInsertES);
    }
    
    /**
        @MethodName : onAfterDelete
        @Param      : List<Coverage_Team_Members__c> lstCoverageTeamMembers
        @Description: This method called on after delete of Coverage_Team_Members__c record.
    **/
    public void onAfterDelete(List<Coverage_Team_Members__c> lstCoverageTeamMembers)
    {
        //Calling method to delete EntitySubscription records corresponding to Coverage_Team_Members__c
        deleteEntitySubscriptionAndCallReportShare(lstCoverageTeamMembers);
    }

    /**
        @MethodName : onAfterUnDelete
        @Param      : List<Coverage_Team_Members__c> lstCoverageTeamMembers
        @Description: This method called on after undelete of Coverage_Team_Members__c record.
    **/
    public void onAfterUnDelete(List<Coverage_Team_Members__c> lstCoverageTeamMembers)
    {
        //Calling method to create EntitySubscription records corresponding to Coverage_Team_Members__c
        createEntitySubscriptionAndCallReportShare(lstCoverageTeamMembers);
    }

    /**
        @MethodName : insertEntitySubscriptionRecords
        @Param      : List<Coverage_Team_Members__c> lstCoverageTeamMembers
        @Description: This method will be called from on after insert event of Coverage_Team_Members__c to insert corresponding Entity Subscription records.
    **/
    private void createEntitySubscriptionAndCallReportShare(List<Coverage_Team_Members__c> lstCoverageTeamMembers)
    {
        Map<String, EntitySubscription> mapEntitySubscription = new Map<String, EntitySubscription>();//Map of string combination of account id to user id to EntitySubscription for inserting the unique records
        Map<Id,List<Coverage_Team_Members__c>> mapAccountIdTolstOfCTM = new Map<Id,List<Coverage_Team_Members__c>>();// map to hold account id and its corresponding coverage team member records.
        List<Coverage_Team_Members__c> lstFilteredCTM = new List<Coverage_Team_Members__c>();//List of Coverage_Team_Members__c 
        List<Call_Report__Share> lstCRShare = new List<Call_Report__Share>();// list of call report share records to insert
        Set<Id> setAccountId = new Set<Id>();//Set of account id
        Set<Id> setEmployeeId = new Set<Id>();//Set of user id   
        Set<String> setAcountIdToEmployeeId = new Set<String>();//Set of string with combination of accountid and user id
        
        //Iterating on Relationship__c to get set of accountid, set of user id and filtered list of 
        for(Coverage_Team_Members__c objCTM : lstCoverageTeamMembers)
        {
            if(objCTM.Company__c != null && objCTM.PWP_Employee__c != null)
            {
                lstFilteredCTM.add(objCTM);
                setAccountId.add(objCTM.Company__c);
                setEmployeeId.add(objCTM.PWP_Employee__c);
                /* start - This part comes under the requirement of PWP-9 */
                if(!mapAccountIdTolstOfCTM.containskey(objCTM.Company__c))
                    mapAccountIdTolstOfCTM.put(objCTM.Company__c, new List<Coverage_Team_Members__c>{objCTM});
                else
                    mapAccountIdTolstOfCTM.get(objCTM.Company__c).add(objCTM);
                /* end - This part comes under the requirement of PWP-9 */
            }
        }
        
        //Iterating on Relationship__c to create unique EntitySubscription records.
        for(Coverage_Team_Members__c objCTM : lstFilteredCTM)
        {
                mapEntitySubscription.put(objCTM.Company__c +'_'+ objCTM.PWP_Employee__c, new EntitySubscription(ParentId = objCTM.Company__c,
                                                                                                          SubscriberId = objCTM.PWP_Employee__c));
        }
        
        /* start - This part comes under the requirement of PWP-9 */
        //Fetching all call reports correspnding to call report company records.
        for(Call_Report_Company__c objCRC : [SELECT Call_Report__c, Relevant_Company__c FROM Call_Report_Company__c WHERE Relevant_Company__c IN : mapAccountIdTolstOfCTM.keyset()])
        {
            if(mapAccountIdTolstOfCTM.containskey(objCRC.Relevant_Company__c))
            {
                for(Coverage_Team_Members__c objCTM : mapAccountIdTolstOfCTM.get(objCRC.Relevant_Company__c))
                {
                    lstCRShare.add(new Call_Report__Share(ParentId = objCRC.Call_Report__c, UserOrGroupId = objCTM.PWP_Employee__c, AccessLevel = 'Read'));
                }
            }
        }
        
        if(!lstCRShare.isEmpty())
           Database.insert(lstCRShare,false);
        /* end - This part comes under the requirement of PWP-9 */  
        //Calling method to create EntitySubscription records corresponding to Coverage_Team_Members__c
        if(!mapEntitySubscription.isEmpty())
            Database.insert(mapEntitySubscription.values(),false);
    }

    /**
        @MethodName : deleteEntitySubscriptionAndCallReportShare
        @Param      : map<Id, Coverage_Team_Members__c> mapOldCoverageTeamMembers, map<Id,Coverage_Team_Members__c> mapNewCoverageTeamMembers
        @Description: This method will be called from on after delete event of Coverage_Team_Members__c to delete corresponding Entity Subscription records.
    **/
    private void deleteEntitySubscriptionAndCallReportShare(List<Coverage_Team_Members__c> lstCoverageTeamMembers)
    {   
        List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();//List of EntitySubscription to delete
        List<Call_Report__Share> lstCallReportShare = new List<Call_Report__Share>();// list to delete the call report sharing records
        Set<Id> setAccountId = new Set<Id>();//Set of account id
        Set<Id> setPWPEmployeeId = new Set<Id>();//Set of user id   
        Set<String> setAcountIdToEmployeeId = new Set<String>();//Set of string with combination of accountid and user id
        Set<Id> setCallReportId = new Set<Id>();//set to hold the call report ids corresponding to companies of inserted coverage team members
        
        //Iterating on Coverage_Team_Members__c to get account id and user id into set
        for(Coverage_Team_Members__c objCTM : lstCoverageTeamMembers)
        {
            if(objCTM.Company__c != null && objCTM.PWP_Employee__c != null)
            {
                setAccountId.add(objCTM.Company__c);
                setPWPEmployeeId.add(objCTM.PWP_Employee__c);
            }
        }
        
        /* start - This part comes under the requirement of PWP-9 */
        //fetching all call reports corresponding to the inserted call team member's account
        for(Call_Report_Company__c objCRC : [SELECT Call_Report__c FROM Call_Report_Company__c WHERE Relevant_Company__c IN : setAccountId])
        {
            setCallReportId.add(objCRC.Call_Report__c);
        }
        /* end - This part comes under the requirement of PWP-9 */
        //Iterating on Relationship__c to create set of accountid and user id key combination
        for(Coverage_Team_Members__c objCTM :[SELECT Company__c, 
                                                     PWP_Employee__c 
                                                FROM Coverage_Team_Members__c
                                               WHERE Company__c IN: setAccountId
                                                 AND PWP_Employee__c IN: setPWPEmployeeId])
        {
            setAcountIdToEmployeeId.add(objCTM.Company__c +'_'+ objCTM.PWP_Employee__c);
            
        }
        
        //Iterating on Relationship__c to create set of accountid and user id key combination
        for(Relationship__c objRelationship :[SELECT Account__c, 
                                                     PWP_Employee__c 
                                                FROM Relationship__c
                                               WHERE Account__c IN: setAccountId
                                                 AND PWP_Employee__c IN: setPWPEmployeeId])
        {
            setAcountIdToEmployeeId.add(objRelationship.Account__c +'_'+ objRelationship.PWP_Employee__c);
        }
                
        //Iterating  on EntitySubscription to delete 
        for(EntitySubscription objEntitySubscription:[SELECT ParentId, 
                                                             SubscriberId 
                                                        FROM EntitySubscription
                                                       WHERE ParentId IN: setAccountId
                                                         AND SubscriberId IN: setPWPEmployeeId])
        {
            if(!setAcountIdToEmployeeId.contains(objEntitySubscription.ParentId +'_'+ objEntitySubscription.SubscriberId))
                lstEntitySubscription.add(objEntitySubscription);
        }
        /* start - This part comes under the requirement of PWP-9 */
        
        //Fetching call report share records correponding to call report ids and pwp employees
        for(Call_Report__Share objCRShare : [SELECT ParentId, UserOrGroupId FROM Call_Report__Share WHERE ParentId IN:setCallReportId AND UserOrGroupId IN:setPWPEmployeeId AND RowCause =:'Manual'])
        {
            if(!setAcountIdToEmployeeId.contains(objCRShare.ParentId +'_'+ objCRShare.UserOrGroupId))
            {
                lstCallReportShare.add(objCRShare);               
            }
        }
        /* end - This part comes under the requirement of PWP-9 */
        
        //Delete the EntitySubscription records
        if(!lstEntitySubscription.isEmpty())
           Database.delete(lstEntitySubscription,false);
        if(!lstCallReportShare.isEmpty())
            Database.delete(lstCallReportShare,false);
    }
}