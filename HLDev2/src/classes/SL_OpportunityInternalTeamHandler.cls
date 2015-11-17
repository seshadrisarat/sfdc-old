/**  
* \arg ClassName		: SL_EngagementInternalTeamHandler
* \arg JIRATicket		: HL-90
* \arg CreatedOn		: 21/Jan/2015
* \arg LastModifiedOn	: 21/Jan/2015
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: Lodhi
* \arg Description		: Handler class for SL_OpportunityInternalTeam Trigger
*/
public with sharing class SL_OpportunityInternalTeamHandler 
{
	/* Start - Variable */
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
	/* End - Variable */
	
	/* Start - Constructor */
	public SL_OpportunityInternalTeamHandler(boolean isExecuting, integer size) 
	{
		m_isExecuting = isExecuting;
        BatchSize = size;
	}
	/* End - Constructor */
	
	/*
        @MethodName			: onAfterInsert
        @param				: List of Opportunity_Internal_Team__c
        @Description		: This function will be called on after insert of the Opportunity_Internal_Team__c records
    */
	public void onAfterInsert(List<Opportunity_Internal_Team__c> lstOIT)
	{
		SL_ManageSharingRules.manageSharingRules(lstOIT, 'Opportunity__c', 'Opportunity_Internal_Team__c', 'insert'); 																			 								 	
	}
	/* End */
	
	/*
        @MethodName			: onAfterUpdate
        @param				: Old and new map of Opportunity_Internal_Team__c
        @Description		: This function will be called on after update of the Opportunity_Internal_Team__c records
    */
	public void onAfterUpdate(Map<Id, Opportunity_Internal_Team__c> mapOldOIT, Map<Id, Opportunity_Internal_Team__c> mapNewOIT)
	{   
		SL_ManageSharingRules.createDeleteShareOnUpdate(mapOldOIT, mapNewOIT, 'Opportunity__c', 'Opportunity_Internal_Team__c');
	}
	/* End */
	
	/*
        @MethodName			: onAfterDelete
        @param				: map of Opportunity_Internal_Team__c
        @Description		: This function will be called on after delete of the Opportunity_Internal_Team__c records
        					  to delete the Opportunity share records related to Opportunity_Internal_Team__c	
    */
	public void onAfterDelete(Map<Id, Opportunity_Internal_Team__c> mapOITOld)
	{
		SL_ManageSharingRules.manageSharingRules(mapOITOld.values(), 'Opportunity__c', 'Opportunity_Internal_Team__c', 'delete');
	}
	/* End */
}