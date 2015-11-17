/*
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_ActiveCareRelationshipHandler {
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
	public SL_ActiveCareRelationshipHandler(boolean isExecuting, integer size) 
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void onAfterUpdate(Map<Id, Active_Care_Relationship__c> mapOldCR, Map<Id, Active_Care_Relationship__c> mapNewACR){
        SL_ScriptPrecedenceUtil precedenceUtil = new SL_ScriptPrecedenceUtil('Active_Care_Relationship__c');
        precedenceUtil.getNewMap(mapOldCR, mapNewACR);
    }

}