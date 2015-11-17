@isTest(SeeAllData=true)
private class SL_test_handler_ProcessQueue {

    static testMethod void myUnitTest() {
      Test.startTest();
       String objectId = '123456789101123';
       String domainName ='Test Domain Name';
       String action = 'Test Action Name';
       String parameters ='ananta.risal@gmail.com';
      
      Process_Queue__c testQueue = new Process_Queue__c(
          Object_Id__c = objectId, 
          Domain__c = domainName, 
          Action__c = action, 
          Parameters__c = parameters
        );
        insert testQueue;
        
        List<Process_Queue__c> process_queue_list = [SELECT id, Object_Id__c, Domain__c, Action__c, Parameters__c
        				FROM Process_Queue__c
        				WHERE Object_Id__c =:objectId AND Domain__c =:domainName AND Action__c =:action AND Parameters__c =:parameters limit 1];
        if (process_queue_list.size()==1){
        	process_queue_list[0].Action__c = 'Test2 Action Name';
        	//Now update the record
        	update process_queue_list[0];
        	//Now delete the record
        	delete process_queue_list[0];
        }        
      Test.stopTest();
    }
}