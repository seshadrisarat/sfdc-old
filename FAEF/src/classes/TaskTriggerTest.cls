@isTest
private class TaskTriggerTest {

    static testMethod void testEmailCreatorOfTaskIfDelegated() {
        User u = [SELECT id FROM User LIMIT 1];
        
        Task t = new Task(
        	OwnerId = u.id,
        	Notify_Creator_When_Complete__c = true,
        	Status = 'Completed'
        );
        insert t;
    }
}