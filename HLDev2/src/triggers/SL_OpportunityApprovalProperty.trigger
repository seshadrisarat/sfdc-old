/**
 * \author Vladimir Dobrelya
 * \date Nov 21, 2014
 * \brief The validation trigger
 * \see https://silverline.jira.com/browse/HL-53
 */
trigger SL_OpportunityApprovalProperty on Opportunity_Approval_Properties__c ( before insert, before update ) {
	SL_handler_OpportunityApprovalProperty handler = new SL_handler_OpportunityApprovalProperty();

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