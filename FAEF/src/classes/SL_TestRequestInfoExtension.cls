@isTest
private class SL_TestRequestInfoExtension {
	
	// SeeAllData is set to true in order to test methods with ConnectApi calls
	@isTest(SeeAllData=true)
	static void testCreateChatterPost_WithFile() {
		User tester = SL_Util_Test.createUser('tester', 'Operations - General', false);

		Credit_Requests__c cr = SL_Util_Test.createCreditRequest();

		SL_RequestInfoExtension extension = new SL_RequestInfoExtension(new ApexPages.StandardController(cr));

		String message = 'Testing creating a chatter post';
		Blob file = Blob.valueOf('Testing adding document');
		String fileType = 'Unknown';
		String fileName = 'Test';

		Test.startTest();
		ConnectApi.FeedItem chatterFeedItem = extension.postToChatter(tester.id, message, file, fileType, fileName);
		Test.stopTest();

		ConnectApi.MentionSegment mentionSeg = (ConnectApi.MentionSegment)chatterFeedItem.body.messageSegments[0];
		ConnectApi.TextSegment textSeg = (ConnectApi.TextSegment)chatterFeedItem.body.messageSegments[1];
		ConnectApi.ContentAttachment attachment = (ConnectApi.ContentAttachment)chatterFeedItem.attachment;

		System.assertEquals(tester.id, mentionSeg.record.id); // User mentioned should be the given user
		System.assertEquals(' ' + message, textSeg.text); // Text segment should be message given with a space in front
		System.assertNotEquals(null, attachment); // The file should exist
		System.assertEquals(fileName, attachment.title); // The chatter file title should be the given file name
		System.assertEquals(fileType, attachment.fileType); // The chatter file type should be the given type
	}

	// SeeAllData is set to true in order to test methods with ConnectApi calls
	@isTest(SeeAllData=true)
	static void testCreateChatterPost_WithoutFile() {
		User tester = SL_Util_Test.createUser('tester', 'Operations - General', false);

		Credit_Requests__c cr = SL_Util_Test.createCreditRequest();

		SL_RequestInfoExtension extension = new SL_RequestInfoExtension(new ApexPages.StandardController(cr));

		String message = 'Testing creating a chatter post';

		Test.startTest();
		ConnectApi.FeedItem chatterFeedItem = extension.postToChatter(tester.id, message, null, null, null);
		Test.stopTest();

		ConnectApi.MentionSegment mentionSeg = (ConnectApi.MentionSegment)chatterFeedItem.body.messageSegments[0];
		ConnectApi.TextSegment textSeg = (ConnectApi.TextSegment)chatterFeedItem.body.messageSegments[1];

		System.assertEquals(tester.id, mentionSeg.record.id); // User mentioned should be the given user
		System.assertEquals(' ' + message, textSeg.text); // Text segment should be message given with a space in front
	}

	//static testMethod void testRetrieveSubmitterId(){
	//	User tester = SL_Util_Test.createUser('tester', 'Operations - General', false);
	//	User approver = SL_Util_Test.createUser('tester2', 'Operations - Credit', true);

	//	System.runAs(tester){

	//		Credit_Requests__c cr = SL_Util_Test.createCreditRequest();

	//		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
	//		req1.setComments('Test approval');
	//		req1.setObjectId(cr.Id);

	//		Approval.ProcessResult result = Approval.process(req1);
	//		System.assert(result.isSuccess());

	//		System.runAs(approver){
	//			List<Id> newWorkItemIds = result.getNewWorkitemIds();

	//			Approval.ProcessWorkItemRequest req2 = new Approval.ProcessWorkItemRequest();
	//			req2.setComments('Approving request.');
	//			req2.setAction('Approve');
	//			req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

	//			req2.setWorkitemId(newWorkItemIds.get(0));
	//			Approval.ProcessResult result2 = Approval.process(req2);

	//			System.assert(result2.isSuccess(), 'Result Status:' + result2.isSuccess());
	//		}

	//		Test.startTest();

	//		SL_RequestInfoExtension extension = new SL_RequestInfoExtension(new ApexPages.StandardController(cr));
	//		System.assertEquals(UserInfo.getUserId(), extension.retrieveSubmitterID());

	//		Test.stopTest();
	//	}
	//}

	// SeeAllData is set to true in order to test methods with ConnectApi calls
	@isTest(SeeAllData=true)
	static void testSendChatterPost(){
      	User u = SL_Util_Test.createUser('Testing', 'Operations - Credit', false);
      	User u2 = SL_Util_Test.createUser('Testing2', 'Operations - Credit', false);

		Credit_Requests__c cr = SL_Util_Test.createCreditRequest();

		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Test approval');
		req1.setObjectId(cr.Id);

		Approval.ProcessResult result = Approval.process(req1);
		System.assert(result.isSuccess());

		SL_RequestInfoExtension extension = new SL_RequestInfoExtension(new ApexPages.StandardController(cr));
		extension.message = 'Test Message';

		extension.sendChatterPost();
		extension.enableFileAttach();

		//~~~~~~~~~ Requesting information ~~~~~~~~~
		Credit_Requests__c updatedCR = [SELECT Id, Status__c, Previous_Status__c, Requester__c, Requester_Name__c, Credit_Last_In_Timestamp__c, Credit_Last_Out_Timestamp__c
										FROM Credit_Requests__c
										WHERE Id = :cr.id
										LIMIT 1];

		System.assertEquals(cr.id, updatedCR.id);
		//System.assertEquals('Awaiting Information', updatedCR.Status__c);
		//System.assertEquals(u2.id, updatedCR.Requester__c);
		//System.assertEquals(u2.LastName, updatedCR.Requester_Name__c);
		System.assertEquals(cr.Status__c, updatedCR.Previous_Status__c);

		//System.assertEquals(Datetime.newInstance(Date.newInstance(1900, 1, 1), Time.newInstance(1, 1, 1, 1)), updatedCR.Credit_Last_In_Timestamp__c);
		System.assertNotEquals(null, updatedCR.Credit_Last_Out_Timestamp__c); // Make sure that Last Out Timestamp was set

		// Test calcTimeInCredit method
		Datetime timeIn = Datetime.newInstance(Date.newInstance(1900, 1, 1), Time.newInstance(1, 1, 1, 1));
		Datetime timeOut = Datetime.newInstance(Date.newInstance(1900, 1, 2), Time.newInstance(1, 1, 1, 1));
		cr.Credit_Last_In_Timestamp__c = timeIn;
		cr.Credit_Last_Out_Timestamp__c = timeOut;
		Decimal timeInCredit = extension.calcTimeInCredit(cr);

		System.assertEquals((timeOut.getTime() - timeIn.getTime()) / 60000, timeInCredit);
		

		/*List<Credit_Requests__Feed> creditRequestFeed = [SELECT Id, Body
														 FROM Credit_Requests__Feed
														 WHERE ParentId = :cr.Id
														 ORDER BY CreatedDate ASC];

		System.assertNotEquals(0, creditRequestFeed.size());

		List<ConnectApi.MessageSegmentInput> msgSegs = creditRequestFeed[0].Body.messageSegments;
		System.assertEquals(UserInfo.getUserId(), msgSegs[0].id);
		System.assertEquals(' ' + extension.message, msgSegs[1].text);

		List<ProcessInstanceWorkItem> workItemList = [SELECT Id, OriginalActor.Name,ActorId 
		                                              FROM ProcessInstanceWorkItem
		                                              WHERE ProcessInstance.TargetObjectId = :cr.id
		                                              ORDER BY CreatedDate DESC];

		System.assert(!workItemList.isEmpty());
		ProcessInstanceWorkItem piwi = workItemList.get(0);
		System.assertEquals(UserInfo.getUserName(), piwi.OriginalActor.Name);
		*/

		//~~~~~~~~~~~ Sending requested information ~~~~~~~~~~
		//extension.message = 'New Message';
		//extension.sendChatterPost();

		//Credit_Requests__c updatedCR2 = [SELECT Id, Status__c, Previous_Status__c, Requester__c
		//								FROM Credit_Requests__c
		//								WHERE Id = :updatedCr.id
		//								LIMIT 1];

		//System.assertEquals(cr.id, updatedCR2.id);
		//System.assertEquals(updatedCR.Status__c, updatedCR2.Status__c);
		//System.assertEquals('', updatedCR2.Requester__c);
		//System.assertEquals('', updatedCR2.Previous_Status__c);

		//creditRequestFeed = [SELECT Id, Body
		//					 FROM Credit_Requests__Feed
		//					 WHERE ParentId = :cr.Id
		//					 ORDER BY CreatedDate ASC];

		//msgSegs = creditRequestFeed[1].Body.messageSegments;
		//System.assertEquals(UserInfo.getUserId(), msgSegs[0].id);
		//System.assertEquals(' ' + extension.message, msgSegs[1].text);

		//workItemList = [SELECT Id, OriginalActor.Name,ActorId 
  		//                FROM ProcessInstanceWorkItem
  		//                WHERE ProcessInstance.TargetObjectId = :cr.id
  		//                ORDER BY CreatedDate DESC];

		//System.assert(!workItemList.isEmpty());
		//piwi = workItemList.get(0);
		//System.assertEquals(UserInfo.getUserName(), piwi.OriginalActor.Name);                                        
	}
}