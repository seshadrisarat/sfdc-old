global class MigrationBatch implements Database.Batchable<sObject>{

   global final String Query;

   global MigrationBatch(String q){

      Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
     //for(sobject s : scope){
     //    s.put('DSE__DS_No_Duplicate__c',true); 
     //}
     update scope;
    }

   global void finish(Database.BatchableContext BC){
   }
}