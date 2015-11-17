/**  
* \arg ClassName		: SL_EngagementInternalTeamHandler
* \arg JIRATicket		: HL-31
* \arg CreatedOn		: 06/Oct/2014
* \arg LastModifiedOn	: 21/Jan/2015
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: Lodhi
* \arg Description		: Handler class for SL_EngagementInternalTeam Trigger
*/
public with sharing class SL_EngagementInternalTeamHandler 
{
	/* Start - Variable */
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
	/* End - Variable */
	
	/* Start - Constructor */
	public SL_EngagementInternalTeamHandler(boolean isExecuting, integer size) 
	{
		m_isExecuting = isExecuting;
        BatchSize = size;
	}
	/* End - Constructor */
	
	/*
        @MethodName			: onAfterInsert
        @param				: List of Engagement_Internal_Team__c
        @Description		: This function will be called on after insert of the Engagement_Internal_Team__c records 
    */
	public void onAfterInsert(List<Engagement_Internal_Team__c> lstEIT)
	{
		SL_ManageSharingRules.manageSharingRules(lstEIT, 'Engagement__c', 'Engagement_Internal_Team__c', 'insert');																			 								 	
	}
	/* End */
	
	/*
        @MethodName			: onAfterUpdate
        @param				: Old and new map of Engagement_Internal_Team__c
        @Description		: This function will be called on after update of the Engagement_Internal_Team__c records 
    */
	public void onAfterUpdate(Map<Id, Engagement_Internal_Team__c> mapOldEIT, Map<Id, Engagement_Internal_Team__c> mapNewEIT)
	{
		SL_ManageSharingRules.createDeleteShareOnUpdate(mapOldEIT, mapNewEIT, 'Engagement__c', 'Engagement_Internal_Team__c');																			 								 	
	}
	/* End */
	
	/*
        @MethodName			: onAfterDelete
        @param				: map of Engagement_Internal_Team__c  
        @Description		: This function will be called on after delete of the Engagement_Internal_Team__c records
        					  to delete the engagement share records related to Engagement_Internal_Team__c	
    */
	public void onAfterDelete(Map<Id, Engagement_Internal_Team__c> mapEITOld)
	{
		SL_ManageSharingRules.manageSharingRules(mapEITOld.values(), 'Engagement__c', 'Engagement_Internal_Team__c', 'delete');
	}
	/* End */
}
/* End */