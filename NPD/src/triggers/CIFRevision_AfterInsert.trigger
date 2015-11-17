trigger CIFRevision_AfterInsert on CIF_Revision__c (after insert) {

    for (Integer i = 0; i < Trigger.new.size(); i++) {
 
        if (Trigger.new[i].Description__c != null) {
        	
	        If (Trigger.new[i].Description__c.contains('AUTO-APPROVE')) {
	 
	            // create the new approval request to submit
	            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
	            req.setComments('Submitted for approval. Please approve.');
	            req.setObjectId(Trigger.new[i].Id);
	            // submit the approval request for processing
	            Approval.ProcessResult result = Approval.process(req);
	            // display if the request was successful
	            System.debug('Submitted for approval successfully: '+result.isSuccess());
	 
	        }

        }
 
    }
    
}