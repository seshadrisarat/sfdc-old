@isTest 
private class vf003_Case_Test {
    static testMethod void testUpdate() {
        List<Case> lCase_Test=new List<Case>();
        Case Case1=new Case(
            RecordTypeId=F8_ScheduleImplementation.Case_RecordTypeId_Statement
            ,Subject='TestAccount1 - Statement Distribution - test1234'
            ,Status='Open'
            ,Origin='Automated'
            ,Priority='Medium'
            ,Type='Statement Distribution'
            ,Reason = 'Statement Process'
            ,Due_Date__c=date.today().addDays(30)
        );
        Case Case2=new Case(
            RecordTypeId=F8_ScheduleImplementation.Case_RecordTypeId_Statement
            ,Subject='TestAccount2 - Statement Distribution - test2345'
            ,Status='Open'
            ,Origin='Automated'
            ,Priority='Medium'
            ,Type='Statement Distribution'
            ,Reason = 'Statement Process'
            ,Due_Date__c=date.today().addDays(30)
        );
        
        List<Case> lCase_Add=new List<Case>{ Case1, Case2};         
        Test.startTest();
        insert lCase_Add;
        Case1.Status='Closed';
        Case2.Status='Closed';
        update lCase_Add;
        Test.stopTest();    
    }
}