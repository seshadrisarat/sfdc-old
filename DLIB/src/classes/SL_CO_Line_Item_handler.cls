/**
 * \author Vladimir Dobrelya
 * \date Feb 17, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
 public class SL_CO_Line_Item_handler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public SL_CO_Line_Item_handler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert( Map<ID, CO_Line_Item__c> aRecords ) {
    	SL_sync_COLineItemToOppLineItem.insertOpportunityLineItems( aRecords );
    }

    public void OnBeforeUpdate( Map<ID, CO_Line_Item__c> aOldRecords, Map<ID, CO_Line_Item__c> aNewRecords ) {
        SL_sync_COLineItemToOppLineItem.refreshLineItems( aNewRecords );
    }

    public void OnBeforeDelete( Map<ID, CO_Line_Item__c> aRecords ) {
        SL_sync_COLineItemToOppLineItem.deleteLineItems( aRecords.keySet() );
    }
}