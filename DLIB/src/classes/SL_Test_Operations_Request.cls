@isTest
private class  SL_Test_Operations_Request {

     static testmethod void testBulkInsertionAndUpdate() {
        // tests insertion and updating of Operation Request objects
        
        List<Operations_Request__c> requests = new List<Operations_Request__c>();
        final Integer NUMREQUEST=20;
        
        User TestPerson = [SELECT Id FROM User WHERE LastName = 'Rivera' LIMIT 1];

        for (Integer ii = 0; ii < NUMREQUEST; ii++){
            Operations_Request__c o = (new Operations_Request__c(Subject__c='bar', Priority__c='High', Requester__c=TestPerson.id, Request_Type__c='People Services (Private)'));
            requests.add(o);
        }

        Test.startTest();
        Database.SaveResult[] result = Database.insert(requests);
        Test.stopTest();

        for (Database.SaveResult r: result){
            System.assert(r.isSuccess());            
        }
        
    }
    
}