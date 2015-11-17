trigger CSSAverageScore on Customer_Satisfaction_Survey_Result__c (after insert, after update, after delete) {

	If (Trigger.isDelete) {
		Customer_Satisfaction_Survey_Result__c[] css = Trigger.old;
	    Set<ID> aIds = new Set<ID>();
	    aIds.add(css[0].account__c);
	
		Account a = new Account();
		a = [select id, CSS_FY__c, CSS_top_box_score__c from Account where id in :aIds limit 1];
	
		Double CSSTotal = 0;
		Double CSSCount = 0;
		String CSSFY = 'FY2009'; 
		
		For (Customer_Satisfaction_Survey_Result__c css2 : [select id, account__c, top_box_score__c from Customer_Satisfaction_Survey_Result__c where account__c in :aIds and Fiscal_Year__c = :CSSFY]) {
			CSSTotal = CSSTotal+css2.top_box_score__c;
			CSSCount = CSSCount+1;		
		}
		
		if (CSSCount > 0) {
			a.CSS_FY__c = CSSFY;
			a.CSS_Top_Box_Score__c = CSSTotal/CSSCount;
		} else {
			a.CSS_FY__c = null;
			a.CSS_Top_Box_Score__c = null;		
		}
		
		update a;
		
	} else {
		Customer_Satisfaction_Survey_Result__c[] css = Trigger.New;
	    Set<ID> aIds = new Set<ID>();
	    aIds.add(css[0].account__c);
	
		Account a = new Account();
		a = [select id, CSS_FY__c, CSS_top_box_score__c from Account where id in :aIds limit 1];
	
		Double CSSTotal = 0;
		Double CSSCount = 0;
		String CSSFY = 'FY2009'; 
		
		For (Customer_Satisfaction_Survey_Result__c css2 : [select id, account__c, top_box_score__c from Customer_Satisfaction_Survey_Result__c where account__c in :aIds and Fiscal_Year__c = :CSSFY]) {
			CSSTotal = CSSTotal+css2.top_box_score__c;
			CSSCount = CSSCount+1;		
		}
		
		if (CSSCount > 0) {
			a.CSS_FY__c = CSSFY;
			a.CSS_Top_Box_Score__c = CSSTotal/CSSCount;
		} else {
			a.CSS_FY__c = null;
			a.CSS_Top_Box_Score__c = null;		
		}
		
		update a;
		
	}
	
}