/*
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_AffiliationHandler {
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
	public SL_AffiliationHandler(boolean isExecuting, integer size) 
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void onAfterUpdate(Map<Id, Affiliation__c> mapOldAffiliation, Map<Id, Affiliation__c> mapNewAffiliation){
        SL_ScriptPrecedenceUtil precedenceUtil = new SL_ScriptPrecedenceUtil('Affiliation__c');
        precedenceUtil.getNewMap(mapOldAffiliation, mapNewAffiliation);
    }

}