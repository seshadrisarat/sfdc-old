/**
 * \author Vladimir Dobrelya
 * \date Feb 12, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
 public class SL_OpportunityLineItem_Handler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public SL_OpportunityLineItem_Handler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert( List<OpportunityLineItem> aRecords ) {
        SL_sync_OppLineItemToCOLineItem.insertChangeOrderLineItems( aRecords );
    }

    public void OnBeforeUpdate( Map<ID, OpportunityLineItem> aOldRecords, Map<ID, OpportunityLineItem> aNewRecords ) {
        SL_sync_OppLineItemToCOLineItem.refreshLineItems( aNewRecords );
    }

    public void OnBeforeDelete( Map<ID, OpportunityLineItem> aRecords ) {
        SL_sync_OppLineItemToCOLineItem.deleteLineItems( aRecords );
    }
}