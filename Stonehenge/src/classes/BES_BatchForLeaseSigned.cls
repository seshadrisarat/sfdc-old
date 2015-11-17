global class BES_BatchForLeaseSigned implements Database.Batchable<sObject>
{
   global String query;
   global List<Property_to_Opportunity_Connector__c> lstPTOConnector = new List<Property_to_Opportunity_Connector__c>();
   
   global BES_BatchForLeaseSigned(String q,List<Property_to_Opportunity_Connector__c>lstPTOConn)
   {
       query = q;
       lstPTOConnector = lstPTOConn;  
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
        return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {   
        update lstPTOConnector;
   }

   global void finish(Database.BatchableContext BC)
   {
   
   }
   
}