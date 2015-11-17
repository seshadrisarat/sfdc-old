trigger DealBeforeInsertBeforeUpdate on Deal__c (before insert, before update) {
	for(Deal__c d : trigger.new) {
		d.AS_Team_hidden__c = d.AS_Team__c;

		if(trigger.isInsert) {
			d.Stage_Column__c = null;
			d.FC_Column__c = null;
			d.Include_In_Funnel_Stage__c = false;
			d.Include_In_Funnel_FC__c = false;
		}

		if(!Flags.UpdatingInvOppColumns && trigger.isUpdate) {
			Deal__c old = trigger.oldMap.get(d.Id);
			d.Stage_Column__c = old.Stage_Column__c;
			d.FC_Column__c = old.FC_Column__c;
		}

		if(!d.Include_In_Funnel_Stage__c || d.Inv_Opp_Launch_Year__c == null) {
			d.Stage_Column__c = null;

		}

		if(!d.Include_In_Funnel_FC__c || d.Inv_Opp_Launch_Year__c == null) {
			d.FC_Column__c = null;
		}
	}
}