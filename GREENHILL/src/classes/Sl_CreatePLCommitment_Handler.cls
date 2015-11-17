/**
* Create new LP_Commitment__c record per mapping below, if Stage__c = Closed
* Trigger Name  : Sl_CreatePLCommitment
* JIRA Ticket   : GREENHILL-12
* Created on    : 23/Apr/2012
* Author        : Snezhana Storoschuk
* Description   : Implement a trigger on Fundraising_Deal__c to insert and update
* Test          : test SL_Test_CreatePLCommitment.cls 
*/


public with sharing class Sl_CreatePLCommitment_Handler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     
    public Sl_CreatePLCommitment_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnAfterInsert(map<Id, Fundraising_Deal__c> newFundMap) {
        createCommitment(newFundMap);
    }
    
    public void OnAfterUpdate(map<Id, Fundraising_Deal__c> oldFundMap, map<Id, Fundraising_Deal__c> newFundMap) {
        createCommitment(newFundMap);
    }
    
    private void createCommitment(map<Id, Fundraising_Deal__c> newFundMap) {
        List<LP_Commitment__c> lstLPCom = new List<LP_Commitment__c>();
        //List<Fundraising_Deal__c> lstFD_forUpdate = new List<Fundraising_Deal__c>();
        Set<Id> set_FDId = new Set<Id>();
        for (Fundraising_Deal__c fd: newFundMap.values()) {
            system.debug('fd===' + fd.Name);
            system.debug('fd===' + fd.Stage__c);
            system.debug('fd===' + fd.LP_Commitment_Created__c);
            if ('Closed' == fd.Stage__c && fd.LP_Commitment_Created__c == false && fd.RecordTypeID == null) {
                set_FDId.add(fd.Id);
                
                LP_Commitment__c lpcom = new LP_Commitment__c();
                lpcom.Commit_Amount__c = fd.Minimum_Commitment_Size__c;
                lpcom.Date_for_Commitment__c = fd.Close_Date__c;
                lpcom.Fundraising_Deal__c = fd.Id;
                lpcom.Fund__c = fd.Fund__c;
                lpcom.LP__c = fd.Company__c;
                lpcom.GHL_Fund__c = [SELECT v.GHL_Fund__c FROM vced2__Fund__c v WHERE v.Id = : fd.Fund__c].GHL_Fund__c;
    
                lstLPCom.add(lpcom);
                
                //fd.LP_Commitment_Created__c = true;
                //lstFD_forUpdate.add(fd);
            }
        }
        if (lstLPCom.size() > 0) insert lstLPCom;
        //if (lstFD_forUpdate.size() > 0) update lstFD_forUpdate;
        
        
        
        List<Fundraising_Deal__c> lstFD_forUpdate = [SELECT Id FROM Fundraising_Deal__c WHERE Id IN :set_FDId];
        for(Fundraising_Deal__c fd : lstFD_forUpdate) {
            fd.LP_Commitment_Created__c = true;
        }
        if (lstFD_forUpdate.size() > 0) update lstFD_forUpdate;
    }
    
    
    
}