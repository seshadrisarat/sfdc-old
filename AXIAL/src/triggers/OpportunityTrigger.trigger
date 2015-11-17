trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	for (Opportunity so : Trigger.new) {
		//friends remind friends to bulkify
	}

}