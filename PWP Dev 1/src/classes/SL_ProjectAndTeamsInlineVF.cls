/**
* \arg ClassName        : SL_ProjectAndTeamsInlineVF
* \arg JIRATicket     	: PWP-114
* \arg CreatedOn      	: 06/AUG/2015
* \arg LastModifiedOn	: 12/AUG/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Controller class for SL_ProjectAndTeamsInlineVF Page.
*/
public with sharing class SL_ProjectAndTeamsInlineVF 
{
    /* Start - Variables */
    public List<ProjectAndTeamsWrapper> lstProjectAndTeamsWrapper   {get;set;}
    public String strEditOrNew                                      {get;set;}
    public Map<String, Integer> mapStageValueToOrder                {get;set;}
    private Id accountId;
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_ProjectAndTeamsInlineVF(Apexpages.StandardController stdCtrl)
    {
        initialization();
        getPicklistValues();
        accountId = stdCtrl.getId();
        fetchProjectAndTeams();
    }
    /* Start - Constructor */
    
    /**
	    @MethodName : onAfterInsert
	    @Param 		: new map of Opportunity records  
	    @Description: This method called on after insert of Opportunity records.
    **/
    private void initialization()
    {
        streditOrNew = '';
        lstProjectAndTeamsWrapper = new List<ProjectAndTeamsWrapper>();
        mapStageValueToOrder = new Map<String, Integer>();
    }
    /* End */
    
    /**
	    @MethodName : fetchProjectAndTeams
	    @Param 		: NA
	    @Description: This method will prepare list of ProjectAndTeamsWrapper class
    **/
    public void fetchProjectAndTeams()
    {
        for(Opportunity objOpp : [SELECT Id, Name, CloseDate, Business_Group__c, 
                                         AccountId, StageName, Business_Group__r.Name,
                                         (SELECT Id, User__c, User__r.Name  
                                            FROM Coverage_Team_Members__r
                                        ORDER BY User__r.Name)
                                    FROM Opportunity 
                                   WHERE AccountId =: accountId ORDER BY Name])
        {
            lstProjectAndTeamsWrapper.add(new ProjectAndTeamsWrapper(objOpp, objOpp.Coverage_Team_Members__r));
        }
    }
    /* End */
    
    /* Start Wrapper for Project and their coverage teams */
    public class ProjectAndTeamsWrapper
    {
        public Opportunity objProject                           {get;set;}
        public List<Project_Coverage_Team_Member__c> lstProjectTeams      {get;set;}
        
        public ProjectAndTeamsWrapper(Opportunity objProject, List<Project_Coverage_Team_Member__c> lstProjectTeams)
        {
            this.objProject = objProject;
            this.lstProjectTeams = lstProjectTeams;
        }
    }
    /* End Wrapper for Project and their coverage teams */
    
    /*
        @MethodName : getPicklistValue 
        @param      : NA
        @Description: method to get picklist value from field.
    */
    private void getPicklistValues()
    {
        Integer intOrder = 1;
        for(Schema.PicklistEntry pickListVal : Opportunity.sObjectType.getDescribe().fields.getMap().get('StageName').getDescribe().getPickListValues())
        {
            mapStageValueToOrder.put(pickListVal.getValue(), intOrder);
            intOrder++;
        }
    }
    /* End */ 
}