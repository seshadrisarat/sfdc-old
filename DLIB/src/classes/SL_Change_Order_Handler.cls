/**
 * \author Vladimir Dobrelya
 * \date Feb 14, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
public without sharing class SL_Change_Order_Handler
{
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public SL_Change_Order_Handler( boolean isExecuting, integer size ) {
		this.m_isExecuting = isExecuting;
		this.BatchSize = size;
	}
 
	public void OnBeforeInsert( List<Change_Order__c> aRecords ) {
		SL_sync_ChangeOrderToOpportunity.insertNewOpportunities( aRecords );
    }

    public void OnAfterInsert( Map<ID, Change_Order__c> aRecords ) {
		SL_sync_ChangeOrderToOpportunity.relateAfter( aRecords );
    }
    
	public void OnBeforeUpdate( Map<ID, Change_Order__c> aOldRecords, Map<ID, Change_Order__c> aNewRecords ) {
		SL_sync_ChangeOrderToOpportunity.updateChangeOrderWithEmptyOpportunity( aNewRecords.values() );
	}

	public void OnAfterUpdate( Map<ID, Change_Order__c> aOldRecords, Map<ID, Change_Order__c> aNewRecords ) {
		SL_sync_ChangeOrderToOpportunity.updateOpportunities( aNewRecords );
	}

	public void OnBeforeDelete( Map<ID, Change_Order__c> aRecords ) {
		SL_sync_ChangeOrderToOpportunity.deleteOpportunities( aRecords.keySet() );
	}
    
	public void OnUndelete( List<Change_Order__c> aRecords ) {
		SL_sync_ChangeOrderToOpportunity.undeleteOpportunities( aRecords );
	}
}