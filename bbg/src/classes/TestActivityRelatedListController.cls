@isTest
private class TestActivityRelatedListController {
	
	static RecordType taskRecordType;
	static RecordType eventRecordType;
	static UserProfileActivityRecordTypes__c cs;
	
	static { 
		List<UserProfileActivityRecordTypes__c> existingCS = [Select Id From UserProfileActivityRecordTypes__c];
		delete existingCS;
		
		taskRecordType = [Select Id,DeveloperName From RecordType 
							Where SObjectType = 'Task' And IsActive = true Limit 1];
		eventRecordType = [Select Id,DeveloperName From RecordType 
							Where SObjectType = 'Event' And IsActive = true Limit 1];
		
		cs = new UserProfileActivityRecordTypes__c(SetupOwnerId = UserInfo.getProfileId());
		cs.Task_Record_Types__c = taskRecordType.DeveloperName;
		cs.Event_Record_Types__c = eventRecordType.DeveloperName;
		insert cs;
		
	}
	
	@isTest(SeeAllData=true)
	public static void testGetActivitesForAccount(){
		
		Account testAccount = TestUtilities.createTestOwnerAccounts(1, true)[0];
		
		List<Event> testOpenEvents = TestUtilities.createEvents(25, eventRecordType.Id, testAccount.Id, null, true);
		List<Task> testOpenTasks = TestUtilities.createTasks(25, taskRecordType.Id, testAccount.Id, null, true);
	
		Set<Id> expectedOpenActivities = new Set<Id>();
		expectedOpenActivities.addAll(Pluck.ids(testOpenEvents));
		expectedOpenActivities.addAll(Pluck.ids(testOpenTasks));

		List<Event> testClosedEvents = TestUtilities.createEvents(25, eventRecordType.Id, testAccount.Id, null, false);
		UnitTest.addData(testClosedEvents).assign('StartDateTime', Datetime.now().addDays(-1)).insertAll();

		List<Task> testClosedTasks = TestUtilities.createTasks(25, taskRecordType.Id, testAccount.Id, null, false);
		UnitTest.addData(testClosedTasks).assign('Status', 'Completed').insertAll();

		Set<Id> expectedClosedActivities = new Set<Id>();
		expectedClosedActivities.addAll(Pluck.ids(testClosedEvents));
		expectedClosedActivities.addAll(Pluck.ids(testClosedTasks));
		
        ActivityRelatedListController activityController = new ActivityRelatedListController ( );
        activityController.recordId = testAccount.Id;
		
		Test.startTest();
			List<OpenActivity> actualOpenActivities = activityController.getOpenActivities;
			List<ActivityHistory> actualClosedActivities = activityController.getActivityHistory;
			Boolean showViewAllButton = activityController.showViewAllButton;
		Test.stopTest();
		
		Set<Id> actualOpenActivitiesIds = Pluck.ids(actualOpenActivities);
		Set<Id> actualClosedActivitiesIds = Pluck.ids(actualClosedActivities);
		
		System.assertEquals(expectedOpenActivities, actualOpenActivitiesIds, 'We expect to get back all of the correct (open) task and events (activities) by record type for this account');
		System.assertEquals(expectedClosedActivities, actualClosedActivitiesIds, 'We expect to get back all of the correct (closed) task and events (activities) by record type for this account');
		System.assertEquals(true, showViewAllButton, 'We expect to show the view all button when history activity present');
		
	}

	@isTest(SeeAllData=true)
	public static void testGetActivitesForAccountDifferentRecordType(){

		delete cs;
		
		cs = new UserProfileActivityRecordTypes__c(SetupOwnerId = UserInfo.getProfileId());
		cs.Task_Record_Types__c = 'dummyTaskDevName';
		cs.Event_Record_Types__c = 'dummyEventDevName';
		insert cs;

		Account testAccount = TestUtilities.createTestOwnerAccounts(1, true)[0];
		
		List<Event> testOpenEvents = TestUtilities.createEvents(25, eventRecordType.Id, testAccount.Id, null, true);
		List<Task> testOpenTasks = TestUtilities.createTasks(25, taskRecordType.Id, testAccount.Id, null, true);
	
		List<Event> testClosedEvents = TestUtilities.createEvents(25, eventRecordType.Id, testAccount.Id, null, false);
		UnitTest.addData(testClosedEvents).assign('StartDateTime', Datetime.now().addDays(-1)).insertAll();

		List<Task> testClosedTasks = TestUtilities.createTasks(25, taskRecordType.Id, testAccount.Id, null, false);
		UnitTest.addData(testClosedTasks).assign('Status', 'Completed').insertAll();
		
        ActivityRelatedListController activityController = new ActivityRelatedListController ( );
		activityController.recordId = testAccount.Id;
		
		Test.startTest();
			List<OpenActivity> actualOpenActivities = activityController.getOpenActivities;
			List<ActivityHistory> actualClosedActivities = activityController.getActivityHistory;
			Boolean showViewAllButton = activityController.showViewAllButton;
			
		Test.stopTest();
		
		System.assertEquals(0, actualOpenActivities.size(), 'We expect to filter all the record types since they are not on the custom setting');
		System.assertEquals(0, actualClosedActivities.size(), 'We expect to filter all the record types since they are not on the custom setting');
		System.assertEquals(false, showViewAllButton, 'We expect to not show the view all button when no history activity present');
	}
	
	@isTest(SeeAllData=true)
	public static void testGetActivitesForContact(){
		
		Contact testContact=TestUtilities.createContacts(1, true)[0];
		
		List<Event> testOpenEvents = TestUtilities.createEvents(25, eventRecordType.Id, null, testContact.Id, true);
		List<Task> testOpenTasks = TestUtilities.createTasks(25, taskRecordType.Id, null, testContact.Id, true);
	
		Set<Id> expectedOpenActivities = new Set<Id>();
		expectedOpenActivities.addAll(Pluck.ids(testOpenEvents));
		expectedOpenActivities.addAll(Pluck.ids(testOpenTasks));

		List<Event> testClosedEvents = TestUtilities.createEvents(25, eventRecordType.Id,  null, testContact.Id, false);
		UnitTest.addData(testClosedEvents).assign('StartDateTime', Datetime.now().addDays(-1)).insertAll();

		List<Task> testClosedTasks = TestUtilities.createTasks(25, taskRecordType.Id,  null, testContact.Id, false);
		UnitTest.addData(testClosedTasks).assign('Status', 'Completed').insertAll();

		Set<Id> expectedClosedActivities = new Set<Id>();
		expectedClosedActivities.addAll(Pluck.ids(testClosedEvents));
		expectedClosedActivities.addAll(Pluck.ids(testClosedTasks));
		
        ActivityRelatedListController activityController = new ActivityRelatedListController ( );
        activityController.recordId = testContact.Id;
		
		Test.startTest();
			List<OpenActivity> actualOpenActivities = activityController.getOpenActivities;
			List<ActivityHistory> actualClosedActivities = activityController.getActivityHistory;
			Boolean showViewAllButton = activityController.showViewAllButton;
		Test.stopTest();
		
		Set<Id> actualOpenActivitiesIds = Pluck.ids(actualOpenActivities);
		Set<Id> actualClosedActivitiesIds = Pluck.ids(actualClosedActivities);
		
		System.assertEquals(expectedOpenActivities, actualOpenActivitiesIds, 'We expect to get back all of the correct (open) task and events (activities) by record type for this contact');

		System.assertEquals(expectedClosedActivities, actualClosedActivitiesIds, 'We expect to get back all of the correct (closed) task and events (activities) by record type for this contact');
		System.assertEquals(true, showViewAllButton, 'We expect to show the view all button when history activity present');
		
	}
	
	@isTest(SeeAllData=true)
	public static void testGetNoActivitesForAccount(){
		
		Account testAccount = TestUtilities.createTestOwnerAccounts(1, true)[0];
		
        ActivityRelatedListController activityController = new ActivityRelatedListController ( );
        activityController.recordId = testAccount.Id;
		
		Test.startTest();
			List<OpenActivity> actualOpenActivities = activityController.getOpenActivities;
			List<ActivityHistory> actualClosedActivities = activityController.getActivityHistory;
			Boolean showViewAllButton = activityController.showViewAllButton;
		Test.stopTest();
		
		Set<Id> actualOpenActivitiesIds = Pluck.ids(actualOpenActivities);
		Set<Id> actualClosedActivitiesIds = Pluck.ids(actualClosedActivities);
		
		System.assertEquals(0, actualOpenActivitiesIds.size(), 'We expect to get back no task and events (activities) by record type for this Account');
		System.assertEquals(0, actualClosedActivitiesIds.size(), 'We expect to get back no task and events (activities) by record type for this Account');
		System.assertEquals(false, showViewAllButton, 'We expect to not show the view all button when no history activity');
		
	}
	
	@isTest(SeeAllData=true)
	public static void testGetNoActivitesForContact(){
		
		Contact testContact=TestUtilities.createContacts(1, true)[0];
		
        ActivityRelatedListController activityController = new ActivityRelatedListController ( );
		activityController.recordId = testContact.Id; 
		
		Test.startTest();
			List<OpenActivity> actualOpenActivities = activityController.getOpenActivities;
			List<ActivityHistory> actualClosedActivities = activityController.getActivityHistory;
			Boolean showViewAllButton = activityController.showViewAllButton;
		Test.stopTest();
		
		Set<Id> actualOpenActivitiesIds = Pluck.ids(actualOpenActivities);
		Set<Id> actualClosedActivitiesIds = Pluck.ids(actualClosedActivities);
		
		System.assertEquals(0, actualOpenActivitiesIds.size(), 'We expect to get back all of the correct (open) task and events (activities) by record type for this contact');
		System.assertEquals(0, actualClosedActivitiesIds.size(), 'We expect to get back all of the correct (closed) task and events (activities) by record type for this contact');
		System.assertEquals(false, showViewAllButton, 'We expect to not show the view all button when no history activity');
	}
	
	static testMethod void testURLButtons(){
		Contact testContact= TestUtilities.createContacts(1, true)[0];
		Account testAccount = TestUtilities.createTestOwnerAccounts(1, true)[0];

        ActivityRelatedListController activityControllerContact = new ActivityRelatedListController ( );
        ActivityRelatedListController activityControllerAccount = new ActivityRelatedListController ( );
		activityControllerContact.recordId = testContact.Id;
		activityControllerAccount.recordId = testAccount.Id;

        String eventPrefix= Event.SObjectType.getDescribe().getKeyPrefix();
        String taskPrefix =	Task.SObjectType.getDescribe().getKeyPrefix();

        Test.startTest();
        
        	Boolean showWhatIdButtonsContact = activityControllerContact.showWhatIdButtons;
        	Boolean showWhoIdButtonsContact = activityControllerContact.showWhoIdButtons;
        	
        	Boolean showWhatIdButtonsAccount = activityControllerAccount.showWhatIdButtons;
        	Boolean showWhoIdButtonsAccount = activityControllerAccount.showWhoIdButtons;
        
        	String retUrlContact= activityControllerContact.customRetUrl;
        	String retUrlAccount= activityControllerAccount.customRetUrl;

        	String newEventUrlContact=activityControllerContact.customSaveNewEventUrl;
        	String newEventUrlAccount=activityControllerAccount.customSaveNewEventUrl;

        	String newTaskUrlContact=activityControllerContact.customSaveNewTaskUrl;
        	String newTaskUrlAccount=activityControllerAccount.customSaveNewTaskUrl;

        	String logACallUrlContact=activityControllerContact.customLogACallUrl;
        	String logACallUrlAccount=activityControllerAccount.customLogACallUrl;

        Test.stopTest();
        
        System.assertEquals(false, showWhatIdButtonsContact, 'We expect to hide what id buttons on contacts');
        System.assertEquals(true, showWhoIdButtonsContact, 'We expect to show who id buttons on contacts');
       
		System.assertEquals(true, showWhatIdButtonsAccount, 'We expect to show what id buttons on contacts');
        System.assertEquals(false, showWhoIdButtonsAccount, 'We expect to hide who id buttons on contacts');

        //Return URL
        System.assertEquals('/'+ testContact.Id, retUrlContact,'Return URL is URL of contact');
        System.assertEquals('/'+ testAccount.Id, retUrlAccount,'Return URL is URL of account');

        //New Event
        System.assert(newEventUrlContact.contains('/'+eventPrefix+'/e'),'New event goes to event edit page');
        System.assert(newEventUrlAccount.contains('/'+eventPrefix+'/e'),'New event goes to event edit page');

        System.assert(newEventUrlContact.contains('who_id='+testContact.Id),'New activity refers to the corresponding contact');
        System.assert(newEventUrlAccount.contains('what_id='+testAccount.Id),'New activity refers to the corresponding account');

        System.assert(newEventUrlContact.contains('retURL=%2F'+testContact.Id),'New activity returns to the previous object');
        System.assert(newEventUrlAccount.contains('retURL=%2F'+testAccount.Id),'New activity returns to the previous object');

        //New task
        System.assert(newTaskUrlContact.contains('/'+taskPrefix+'/e'),'New task goes to task edit page');
        System.assert(newTaskUrlAccount.contains('/'+taskPrefix+'/e'),'New task goes to task edit page');

        System.assert(newTaskUrlContact.contains('who_id='+testContact.Id),'New activity refers to the corresponding contact');
        System.assert(newTaskUrlAccount.contains('what_id='+testAccount.Id),'New activity refers to the corresponding account');

        System.assert(newTaskUrlContact.contains('retURL=%2F'+testContact.Id),'New activity returns to the previous object');
        System.assert(newTaskUrlAccount.contains('retURL=%2F'+testAccount.Id),'New activity returns to the previous object');

        //Log a call
        System.assert(logACallUrlContact.contains('/'+taskPrefix+'/e'),'New task goes to task edit page');
        System.assert(logACallUrlAccount.contains('/'+taskPrefix+'/e'),'New task goes to task edit page');

        System.assert(logACallUrlContact.contains('who_id='+testContact.Id),'New activity refers to the corresponding contact');
        System.assert(logACallUrlAccount.contains('what_id='+testAccount.Id),'New activity refers to the corresponding account');

        System.assert(logACallUrlContact.contains('retURL=%2F'+testContact.Id),'New activity returns to the previous object');
        System.assert(logACallUrlAccount.contains('retURL=%2F'+testAccount.Id),'New activity returns to the previous object');

        System.assert(logACallUrlContact.contains('title=Call')&& logACallUrlContact.contains('followup=1') && logACallUrlContact.contains('tsk5=Call'),'Log a call creates a call task and sets reminder');
        System.assert(logACallUrlAccount.contains('title=Call')&& logACallUrlAccount.contains('followup=1') && logACallUrlAccount.contains('tsk5=Call'),'Log a call creates a call task and sets reminder');

	}	
	
}