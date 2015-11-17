/**
* \arg ClassName        : SL_CaseHandler
* \arg JIRATicket     	: YNHH-110
* \arg CreatedOn      	: 17/JULY/2015
* \arg LastModifiedOn	: 14/AUG/2015
* \arg CreatededBy    	: Sanath 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Handler class for SL_Case trigger
*/
public without sharing class SL_CaseHandler 
{
    /* Start - Variables */
    private static final String PERMISSION_SET = 'Read';
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_CaseHandler()
    {
        //do nothing.
    }
    /* End - Constructor */
    
    /**
	    @MethodName : onAfterInsert
	    @Param 		: List of case  
	    @Description: This method called on after insert of case records.
    **/
    public void onAfterInsert(List<Case> lstCaseNew)
    {
       createCaseShareRecords(lstCaseNew , null);
    }
    /* End */
    
    /**
	    @MethodName : onAfterUpdate
	    @Param 		: new list and old map of case records 
	    @Description: This method called on after Update of Case record.
    **/
    public void onAfterUpdate(List<Case> lstCaseNew , map<Id, Case> mapIdToCaseOld)
    {
        createCaseShareRecords(lstCaseNew , mapIdToCaseOld);
    }
    /* End */

    public void onBeforeInsert(List<Case> lstCaseNew)
    {
        if(lstCaseNew.size() == 1){
            User u = [SELECT Id, HrContactId__c, Profile.Name 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];
            if(u.Profile.Name == 'YNHH Employee' && u.HrContactId__c != null){
                Case c = lstCaseNew[0];
                c.ContactId = u.HrContactId__c;
            }
        }
        if(System.Label.Default_Entitlement_Id != null)
            for(Case c :lstCaseNew)
                if(c.EntitlementId == null)
                    c.EntitlementId = System.Label.Default_Entitlement_Id;
    }
    
    /**
	    @MethodName : onBeforeUpdate
	    @Param 		: map<Id, Case> mapOldCase, map<Id, Case> mapNewCase
	    @Description: This method called on before Update of Case record.
    **/
    public void onBeforeUpdate(map<Id, Case> mapOldCase, map<Id, Case> mapNewCase)
    {
        Set<String> setCaseStatus = new Set<String>{'In Process', 'Escalated', 'Closed'};
        Set<Id> setCaseFirstResponseId = new Set<Id>();
        Set<Id> setCaseClosureId = new Set<Id>();
        
        for(Case objCase: mapNewCase.values())
        {
            if(objCase.Status != mapOldCase.get(objCase.Id).Status)
            {
                if(mapOldCase.get(objCase.Id).Status == 'New')
                    setCaseFirstResponseId.add(objCase.Id); 
                if(mapNewCase.get(objCase.Id).Status == 'Closed'){
                    setCaseClosureId.add(objCase.Id);
                    setCaseFirstResponseId.add(objCase.Id);
                }
            }
        }
        
        if(!setCaseFirstResponseId.isEmpty())
            updateCaseMilestones(setCaseFirstResponseId, 'First Response');    
        if(!setCaseClosureId.isEmpty())
            updateCaseMilestones(setCaseClosureId, 'Case Closure');     
    }
    
    /**
	    @MethodName : updateCaseMilestones
	    @Param 		: List of updated cases and milestone type
	    @Description: This method will update the CaseMilestone's completion date based on the case status
    **/
    //@future
    private static void updateCaseMilestones(Set<Id> setCaseIds, String strMileStoneType)
    {
        Map<Id, CaseMilestone> mapCaseIdToMileStoneUpdate = new Map<Id, CaseMilestone>();
        for(CaseMilestone objCaseMS : [SELECT Id, CaseId
                                         FROM CaseMilestone
                                        WHERE CaseId IN : setCaseIds
                                          AND MilestoneType.Name =: strMileStoneType
                                          AND CompletionDate = null
                                     ORDER BY LastModifiedDate DESC])
        {
            if(!mapCaseIdToMileStoneUpdate.containsKey(objCaseMS.CaseId))
                mapCaseIdToMileStoneUpdate.put(objCaseMS.CaseId, new CaseMilestone(Id = objCaseMS.Id, CompletionDate = DateTime.Now()));
        }   
        update mapCaseIdToMileStoneUpdate.values();
    }

     /**
	    @MethodName : createCaseShareRecords
	    @Param 		: new list and old map of case records 
	    @Description: This method called on after Update of Case record.
    **/
    private void createCaseShareRecords(List<Case> lstCaseNew , map<Id, Case> mapIdToCaseOld)
    {
        map<Id, Id> mapContactToPortalUser = new map<Id , Id>();
        map<Id, List<CaseShare>> mapCaseIdToCaseShare = new map<Id , list<CaseShare>>();
        set<Id> setContactId = new set<Id>();
        set<Id> setCaseId = new set<Id>();
        set<Id> setContactsOld = new Set<Id>();
        
        for(Case objCase : lstCaseNew)
        {
            if(objCase.ContactId != null /*&& (mapIdToCaseOld == null || objCase.ContactId != mapIdToCaseOld.get(objCase.Id).ContactId )*/)
            {
                setContactId.add(objCase.ContactId);
                setCaseId.add(objCase.Id);
                
                if(mapIdToCaseOld != null && mapIdToCaseOld.get(objCase.Id).ContactId != null)
                    setContactsOld.add(mapIdToCaseOld.get(objCase.Id).ContactId);
            }
            
            else if(objCase.ContactId == null && mapIdToCaseOld != null && mapIdToCaseOld.get(objCase.Id).ContactId != objCase.ContactId)
            {
                setCaseId.add(objCase.Id);
                setContactsOld.add(mapIdToCaseOld.get(objCase.Id).ContactId);
            } 
        }
        
        if(!setContactId.isEmpty() || !setContactsOld.isEmpty())
        {
            List<CaseShare> lstCaseNewSharetoInsert = new List<CaseShare>();
            for(Contact objContact : [SELECT Id , Portal_User__c FROM Contact WHERE Id IN : setContactId AND Portal_User__c != null])
            {
                mapContactToPortalUser.put(objContact.Id , objContact.Portal_User__c);
            }
            
            if(!setContactsOld.isEmpty())
            {
                set<Id> setPortalOldIds = new set<Id>();
                List<CaseShare> lstCaseShareToDelete = new List<CaseShare>();
                
                for(Contact objContactOld : [SELECT Id , Portal_User__c FROM Contact WHERE Id IN : setContactsOld AND Portal_User__c != null])
                {
                    setPortalOldIds.add(objContactOld.Portal_User__c);
                }
                
                if(!setPortalOldIds.isEmpty())
                {
                    for(CaseShare objCaseShare : [Select Id from CaseShare where CaseId IN :setCaseId AND UserOrGroupId IN :setPortalOldIds])
                    {
                        lstCaseShareToDelete.add(objCaseShare);
                    }
                    try{
                        delete lstCaseShareToDelete;                        
                    }catch(Exception e){
                        System.debug('Error deleting records');
                        System.debug(e);
                    }
                }
            }
            
            for(Case objCase : lstCaseNew)
            {
                if(mapContactToPortalUser.containsKey(objCase.ContactId))
                    lstCaseNewSharetoInsert.add(
                        new CaseShare( CaseAccessLevel = PERMISSION_SET , 
                                                CaseId = objCase.Id , 
                                         UserOrGroupId = mapContactToPortalUser.get(objCase.ContactId) ));
            }
            //Calling this method to create case share records when case assignment rule is fired.
            createShares(JSON.Serialize(lstCaseNewSharetoInsert));
        }
    }
    /* End */
    
    /**
	    @MethodName : createShares
	    @Param 		: JSON serialized string of case share records  
	    @Description: This method will create case share records along with case assignment rules.
    **/
    @future
    private static void createShares(String strCaseShares)
    {
        //Used database.insert to avoid the creation of owner sharing rules
        database.insert((List<CaseShare>)JSON.deserialize(strCaseShares, List<CaseShare>.Class), false);
    }
    /* End */
}