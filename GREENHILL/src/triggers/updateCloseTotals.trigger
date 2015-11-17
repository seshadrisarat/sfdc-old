trigger updateCloseTotals on Opportunity (after insert, after update, after delete) {
		if (Trigger.isDelete) {
			///only run if affect a Greenhill Placement type Record
			if (Trigger.old[0].RecordTypeId == '0124000000059rPAAQ') { 
				if(Trigger.old[0].Close__c != null){
					calcCloseTotals.updateCloseTotal(Trigger.old[0].Close__c);
				}
			} 
		} else {
			///only run if affect a Greenhill Placement type Record
			if (Trigger.new[0].RecordTypeId == '0124000000059rPAAQ') { 
				if(Trigger.new[0].Close__c != null){
					calcCloseTotals.updateCloseTotal(Trigger.new[0].Close__c);
				}
			}
		}
}