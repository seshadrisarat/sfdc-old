/**
 * \author Vladimir Dobrelya
 * \date Nov 21, 2014
 * \brief The validation trigger
 * \see https://silverline.jira.com/browse/HL-53
 */
trigger SL_OpportunityApprovalSection on Opportunity_Approval_Section__c ( before insert, before update ) {
	SL_handler_OpportunityApprovalSection handler = new SL_handler_OpportunityApprovalSection();

	if ( trigger.IsInsert ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeInsert( Trigger.new );
        }
    } else if ( trigger.IsUpdate ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeUpdate( Trigger.oldMap, Trigger.newMap );
        }
    }
}