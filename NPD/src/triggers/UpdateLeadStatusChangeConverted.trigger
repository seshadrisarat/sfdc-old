trigger UpdateLeadStatusChangeConverted on Lead (after update) {

// Get the Lead Record

//	for (lead l : [select id,converteddate,Status_Change_Converted__c from lead where id in :Trigger.new]) {
        
        // Update the Lead Record
//        if (l.converteddate <> null && l.Status_Change_Converted__c == null) {
//	        l.Status_Change_Converted__c = System.now();
//	        update l;
//        }  
              
//    }
        
}