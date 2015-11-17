public with sharing class TestApproval 
{
	public static void submitAndProcessApprovalRequest() 
	{
		// Create an approval request for the account
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		system.debug('=========comments========'+req1.getComments());
		system.debug('=========next approver========'+req1.getNextApproverIds());
		system.debug('=========object Id========'+req1.getObjectId());
		req1.setComments('Submitting request for approval.');
		req1.setObjectId('00128000002pApu');
		// Submit on behalf of a specific submitter
		req1.setSubmitterId('00528000000Dsuj');
		// Submit the record to specific process and skip the criteria evaluation
		req1.setProcessDefinitionNameOrId('Test_Account');
		req1.setSkipEntryCriteria(true);
		// Submit the approval request for the account
		Approval.ProcessResult result = Approval.process(req1);
		// Verify the result
		System.assert(result.isSuccess());		
		
		system.debug('=========comments========'+req1.getComments());
		system.debug('=========next approver========'+req1.getNextApproverIds());
		system.debug('=========object Id========'+req1.getObjectId());
		
		/*List<Id> newWorkItemIds = result.getNewWorkitemIds();
		system.debug('=========work item ids========'+result.getNewWorkitemIds());
		// Instantiate the new ProcessWorkitemRequest object and populate it
		Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
		req2.setComments('Approving request.');
		req2.setAction('Reject');
		req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
		// Use the ID from the newly created item to specify the item to be worked
		req2.setWorkitemId(newWorkItemIds.get(0));
		// Submit the request for approval
		Approval.ProcessResult result2 = Approval.process(req2);*/
		
	}
}