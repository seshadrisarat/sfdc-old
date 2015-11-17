@isTest
public class SL_TestActivityHandler {

    static testMethod void unitTestCode() {

        SL_ActivityHandler objActivityHandler = new SL_ActivityHandler();

        List<sObject> lstActivities = new List<sObject>();

        Event objEvent = new Event();
        objEvent.IsParent__c = true;
        objEvent.StartDateTime = date.today();
        objEvent.EndDateTime = date.today();
        insert objEvent;

        Event objEvent1 = new Event();
        objEvent1.StartDateTime = date.today();
        objEvent1.EndDateTime = date.today();
        objEvent1.ParentId__c = objEvent.Id;
        insert objEvent1;

        delete objEvent;
        lstActivities.add(objEvent);

        Task objTask = new Task();
        objTask.IsParent__c = true;
        insert objTask;

        Task objTask1 = new Task();
        objTask1.ParentId__c = objTask.Id;
        insert objTask1;

        delete objTask;
        lstActivities.add(objTask);

        objActivityHandler.onAfterDelete(lstActivities);
    }
}