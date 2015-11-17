/**
*  Class Name     : SL_BatchToCreateEventInMyBuilding
*  JIRATicket     : STONEPIII-7
*  CreatedOn      : 19/SEP/2014
*  ModifiedBy     : Pankaj Ganwani
*  Description    : Batch to create Events in Mybuilding when case is inserted with recordtype 'Move In Process' or 'Move Out Process'.
*/
global class SL_BatchToCreateEventInMyBuilding implements Database.Batchable<sObject>, Database.AllowsCallouts
{
   //Global Variables
   global List<Case> lstCasesForEvent = new List<Case>();
   global SL_MyBuilding_Integration__c objIntegrationSetting;
   static final String MOVEIN_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName =: 'Move_In_Process'].Id;
   static final String MOVEOUT_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName =: 'Move_Out_Process'].Id;   
   
   // Constructor 
   global SL_BatchToCreateEventInMyBuilding(List<Case> lstCase)
   {
      objIntegrationSetting = new SL_MyBuilding_Integration__c();
      lstCasesForEvent.addAll(lstCase);
      objIntegrationSetting = SL_MyBuilding_Integration__c.getInstance('MyBuilding');
   }

   global Database.QueryLocator start(Database.BatchableContext BC)
   {
      return Database.getQueryLocator('Select Mybuilding_Event_Creation_Status__c, Mybuilding_Event_Id__c, Community_ID__c, Subject, Description, Lease_Start_Date__c, RecordTypeId, Move_In_Date__c, Move_Out_Date__c From Case Where Id IN :lstCasesForEvent');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
        List<Case> lstCase = new List<Case>();
        lstCase.addAll((List<Case>)scope);
        
        // Since scope size is set as '1' - this would be a list with single record
        for(Case objCase : lstCase)
        {
            // Make call-out to MyBuilding
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            String strRequestBody = 'format=json'; 

            strRequestBody += '&app_id=' + objIntegrationSetting.app_id__c;
            strRequestBody += '&app_key=' + objIntegrationSetting.app_key__c;
            strRequestBody += '&communityId=' + objCase.Community_ID__c;
            strRequestBody += '&title=' + objCase.Subject;
            strRequestBody += '&text=' + objCase.Description;
            strRequestBody += '&groupId=' + objIntegrationSetting.groupId__c;
            if(objCase.RecordTypeId == MOVEIN_CASE_RECORDTYPE_ID)
            {
                strRequestBody += '&date=' +  objCase.Move_In_Date__c.year()+'-'+objCase.Move_In_Date__c.month()+'-'+objCase.Move_In_Date__c.day();
                strRequestBody += '&dateFrom=' + objCase.Move_In_Date__c.hour()+':'+objCase.Move_In_Date__c.minute();
                strRequestBody += '&dateTo=' + objCase.Move_In_Date__c.addHours(1).hour()+':'+objCase.Move_In_Date__c.minute();
            }
            else
            {
                strRequestBody += '&date=' +  objCase.Move_Out_Date__c.year()+'-'+objCase.Move_Out_Date__c.month()+'-'+objCase.Move_Out_Date__c.day();
                strRequestBody += '&dateFrom=' + objCase.Move_Out_Date__c.hour()+':'+objCase.Move_Out_Date__c.minute();
                strRequestBody += '&dateTo=' + objCase.Move_Out_Date__c.addHours(1).hour()+':'+objCase.Move_Out_Date__c.minute();
            }
            strRequestBody += '&isAllDayEvent=' + objIntegrationSetting.isAllDayEvent__c;

            req.setEndpoint('http://api.mybuilding.org/events');
            req.setMethod('POST');
            req.setBody(strRequestBody);
            
            HttpResponse res;
            system.debug('-----req-------' + req);
            system.debug('-----strRequestBody -------' + strRequestBody );
            // Send the request, and return a response
            res = h.send(req);          
            
            SL_MyBuildingIntegration_ResponseClass objResponse = (SL_MyBuildingIntegration_ResponseClass)JSON.deserialize(res.getBody(), SL_MyBuildingIntegration_ResponseClass.class);
                         
            // Updating Case Mybuilding_Event_Id__c field with Event record created in MyBuilding if callout is success.
            if(objResponse.status == 'success')
            {
                objCase.Mybuilding_Event_Creation_Status__c = 'Successfully created event in MyBuilding App';
                objCase.Mybuilding_Event_Id__c = objResponse.response.eventId;
                //setting this field to true to make sure call out should happen only once corresponding to one single Case record
                objCase.Make_Call_out__c = true;
            }
            
            // Updating Case Mybuilding_Event_Creation_Status__c field with the response message when callout is failed. 
            if(objResponse.status != 'success')
            {
                objCase.Mybuilding_Event_Creation_Status__c = objResponse.response.message; 
            }
            
            update objCase;
        }
   }

   global void finish(Database.BatchableContext BC)
   {
   
   }
   
}