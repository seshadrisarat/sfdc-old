trigger ExecResourceHistory on Contact (before update) {
	/* for(Contact cnew : trigger.new){
		Contact cold = System.Trigger.oldMap.get(cnew.Id);
		if(cold.Expertise_Knowledge__c != cnew.Expertise_Knowledge__C || cold.Functional_Expertise__c != cnew.Functional_Expertise__c || cold.Doc_on_File__c != cnew.Doc_on_File__c || cold.Ownership_Coverage__c != cnew.Ownership_Coverage__c || cold.Potential_Role__c != cnew.Potential_Role__c || cold.Summary_Remarks__c != cnew.Summary_Remarks__c){
			cnew.Resource_Last_Modified__c = Date.today();
		}
	} */
}