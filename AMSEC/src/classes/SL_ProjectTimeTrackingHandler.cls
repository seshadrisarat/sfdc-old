/**
* \arg \b ClassName      : SL_ProjectTimeTrackingHandler
* \arg \b JIRATicket     : AMSEC-237
* \arg \b CreatedOn      : 15/MAY/2015
* \arg \b ModifiedBy     : Lodhi
* \arg \b Description    : This is the handler class for SL_ProjectTimeTracking trigger.
*/
public class SL_ProjectTimeTrackingHandler 
{
    /* Start - Constructor */
    public SL_ProjectTimeTrackingHandler()
    {
        
    }
    /* End - Constructor */
    
    /*
	    * MethodName 	: onAfterInsert.
	    * param 		: List of Project_Time_Tracking__c
	    * Description	: .
    */
    public void onAfterInsert(Map<Id, Project_Time_Tracking__c> mapIdToProjTimeTrackingNew)
    {
        List<Project_Time_Tracking__c> lstFilteredPTT = new List<Project_Time_Tracking__c>();
         
        for(Project_Time_Tracking__c objPrjTracking : mapIdToProjTimeTrackingNew.values())
        {
            if(objPrjTracking.Date__c != null && objPrjTracking.Hours__c != null && objPrjTracking.Hours__c > 0 && objPrjTracking.Resource_User__c != null)
            {
                lstFilteredPTT.add(objPrjTracking);
            }    
        }
        updateWorkingGroupMembers(lstFilteredPTT);
    }
    
    /*
	    * MethodName 	: onAfterUpdate.
	    * param 		: Old and New map of Project_Time_Tracking__c
	    * Description	: .
    */
    public void onAfterUpdate(Map<Id, Project_Time_Tracking__c> mapIdToProjTimeTrackingOld, Map<Id, Project_Time_Tracking__c> mapIdToProjTimeTrackingNew)
    {
        List<Project_Time_Tracking__c> lstFilteredPTT = new List<Project_Time_Tracking__c>(); 
        
        for(Project_Time_Tracking__c objPrjTracking : mapIdToProjTimeTrackingNew.values())
        {
            if(objPrjTracking.Date__c != null && objPrjTracking.Resource_User__c != null && objPrjTracking.Hours__c != null && objPrjTracking.Hours__c > 0 
              && objPrjTracking.Hours__c != mapIdToProjTimeTrackingOld.get(objPrjTracking.Id).Hours__c 
              || objPrjTracking.Project_Name__c != mapIdToProjTimeTrackingOld.get(objPrjTracking.Id).Project_Name__c
              || objPrjTracking.Resource_User__c != mapIdToProjTimeTrackingOld.get(objPrjTracking.Id).Resource_User__c
              || objPrjTracking.Date__c != mapIdToProjTimeTrackingOld.get(objPrjTracking.Id).Date__c)
            {
                lstFilteredPTT.add(objPrjTracking);
            }       
        }
        updateWorkingGroupMembers(lstFilteredPTT);
    }
    
    /*
	    * MethodName 	: updateWorkingGroupMembers.
	    * param 		: list of Project_Time_Tracking__c
	    * Description	: .
    */
    private void updateWorkingGroupMembers(List<Project_Time_Tracking__c> lstFilteredPTT)
    {
        Set<Id> setASProjectId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        Map<String, Project_Time_Tracking__c> mapPrjIdUsrIdToTimeTracking = new Map<String, Project_Time_Tracking__c>();
        List<External_Working_Group_Member__c> lstWGM = new List<External_Working_Group_Member__c>(); 
        
        for(Project_Time_Tracking__c objPrjTracking : lstFilteredPTT)
        {
            setASProjectId.add(objPrjTracking.Project_Name__c);
            setUserId.add(objPrjTracking.Resource_User__c);
            mapPrjIdUsrIdToTimeTracking.put(objPrjTracking.Project_Name__c + '_' + objPrjTracking.Resource_User__c, objPrjTracking);
        }
        
        for(External_Working_Group_Member__c objWGM : [SELECT Id,
                                                              AS_Project__c,
                                                              Initial_Participation_Date__c,
                                                              Contact__r.Salesforce_User__c
                                                         FROM External_Working_Group_Member__c
                                                        WHERE AS_Project__c IN : setASProjectId
                                                          AND Contact__r.Salesforce_User__c IN : setUserId])
        {
            Date dtInitialDate = mapPrjIdUsrIdToTimeTracking.get(objWGM.AS_Project__c + '_' + objWGM.Contact__r.Salesforce_User__c).Date__c;
            
            if(objWGM.Initial_Participation_Date__c == null || objWGM.Initial_Participation_Date__c > dtInitialDate)
                lstWGM.add(new External_Working_Group_Member__c(Id = objWGM.Id, Initial_Participation_Date__c = dtInitialDate));
        } 
        update lstWGM;
    }
}