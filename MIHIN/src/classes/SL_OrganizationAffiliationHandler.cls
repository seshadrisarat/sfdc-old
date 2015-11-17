/*
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_OrganizationAffiliationHandler {
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
	public SL_OrganizationAffiliationHandler(boolean isExecuting, integer size) 
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void onAfterUpdate(Map<Id, Organization_Affiliation__c> mapOldAffiliation, Map<Id, Organization_Affiliation__c> mapNewAffiliation){
        SL_ScriptPrecedenceUtil precedenceUtil = new SL_ScriptPrecedenceUtil('Organization_Affiliation__c');
        precedenceUtil.getNewMap(mapOldAffiliation, mapNewAffiliation);
    }

}