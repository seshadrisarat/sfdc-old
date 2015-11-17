/** 
* \author Julia Kolesnik 
* \date 5/15/12
* \tests for:
* \Phase.trigger, Project_Task.trigger, Worklog.trigger 
*/
@isTest
public class SL_Test_Worklog_TriggerHandler {
    //public static List<Project_Task__c> lstPT;
    //public static List<Worklog__c> newWL;
    //public static Phase__c newPh;
    //public static void insertData()
    //{
    //    Project__c newP = new Project__c();
    //    newP.OpenAir_Project_ID__c = 1;
    //    newP.Completion_Date__c = date.today();
    //    newP.Estimated_Start_Date__c = date.today();
    //    insert newP;
        
    //    List<Phase__c> lstPh = new List<Phase__c>();
    //    lstPh.add(new Phase__c(Project__c = newP.Id, OpenAir_Id__c = 'ph1', Name = 'ph1'));
    //    lstPh.add(new Phase__c(Project__c = newP.Id, OpenAir_Id__c = 'ph2', Name = 'ph2'));
    //    insert lstPh;
        
    //    newPh = new Phase__c(Project__c = newP.Id, OpenAir_Id__c = 'ph3', Name = 'ph3', Phase__c = 'ph1');
    //    insert newPh;
                
    //    lstPT = new List<Project_Task__c>();
    //    lstPT.add(new Project_Task__c(Project__c = newP.Id, OA_Project_Id__c = 'p1', OA_Project_Task_Id__c = 'pt1', OA_Project_Task_Id_Number__c = 'pt1n', Name = 'pt1', Phase__c = 'ph1'));
    //    lstPT.add(new Project_Task__c(Project__c = newP.Id, OA_Project_Id__c = 'p2', OA_Project_Task_Id__c = 'pt2', OA_Project_Task_Id_Number__c = 'pt2n', Name = 'pt2', Phase__c = 'ph3'));
    //    lstPT.add(new Project_Task__c(Project__c = newP.Id, OA_Project_Id__c = 'p3', OA_Project_Task_Id__c = 'pt3', OA_Project_Task_Id_Number__c = 'pt3n', Name = 'pt3', Phase__c = 'ph2'));
    //    insert lstPT;

    //    SF_Issue__c issue = new SF_Issue__c(Name='test-1');
    //    insert issue;

        
    //    newWL = new List<Worklog__c>();
    //    newWL.add(new Worklog__c(SF_Issue__c = issue.id, Project__c = newP.Id, OA_ProjectTask_ID__c = 'pt1n'));
    //    newWL.add(new Worklog__c(SF_Issue__c = issue.id, Project__c = newP.Id, OA_ProjectTask_ID__c = 'pt2n'));
    //    newWL.add(new Worklog__c(SF_Issue__c = issue.id, Project__c = newP.Id, OA_ProjectTask_ID__c = 'pt3n'));
    //    newWL.add(new Worklog__c(SF_Issue__c = issue.id, Project__c = newP.Id, OA_ProjectTask_ID__c = 'pt3n'));
    //    insert newWL;
    //}
    
    //public static testmethod void testWLTrigger()
    //{
        
    //    Test.StartTest();
    //    insertData();
        
    //    newPh.Phase__c = 'ph2';
    //    update newPh;
        
    //    lstPT[2].Phase__c = 'ph3';
    //    update lstPT[2];
        
    //    newWL[1].OA_ProjectTask_ID__c = 'pt1n';
    //    update newWL[1];

    //    Test.StopTest();
        
    //    list<Worklog__c> testWL = [SELECT ID 
    //                            FROM Worklog__c 
    //                            WHERE  Project_Task__c = :lstPT[2].Id];
    //    system.assertEquals(2, testWL.size());
    //}

}