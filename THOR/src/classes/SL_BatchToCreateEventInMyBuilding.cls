/**
*  Class Name     : SL_BatchToCreateEventInMyBuilding
*  JIRATicket     : THOR-29
*  CreatedOn      : 28/SEP/2014
*  ModifiedBy     : SANATH
*  Description    : Batch to create Events in Mybuilding when case is inserted with recordtype 'Move In Process' or 'Move Out Process'.
*/
global class SL_BatchToCreateEventInMyBuilding implements Database.Batchable<sObject>, Database.AllowsCallouts
{
   //Global Variables
   global List<Case> lstCasesForEvent = new List<Case>();
   global SL_MyBuilding_Integration__c objIntegrationSetting;
   
   // Constructor 
   global SL_BatchToCreateEventInMyBuilding(List<Case> lstCase)
   {
      objIntegrationSetting = new SL_MyBuilding_Integration__c();
      lstCasesForEvent.addAll(lstCase);
      objIntegrationSetting = SL_MyBuilding_Integration__c.getInstance('MyBuilding');
   }

   global Database.QueryLocator start(Database.BatchableContext BC)
   {
      return Database.getQueryLocator('Select Mybuilding_Event_Creation_Status__c,Move_In_Date__c,Move_Out_Date__c,Date_To__c,Date_From__c,RecordTypeId ,Mybuilding_Event_Id__c, Community_ID__c,Subject, Description, Apartment__r.Apartment_Number__c ,Lease_Start_Date__c From Case Where Id IN :lstCasesForEvent');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
        List<Case> lstCase = new List<Case>();
        lstCase.addAll((List<Case>)scope);
        Id MOVEIN_CASE_RECORDTYPEID = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND  DeveloperName = 'Move_In_Process'].Id;
        Id MOVEOUT_CASE_RECORDTYPEID = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND  DeveloperName = 'Move_Out_Process'].Id;
        
        if(!test.isRunningtest())
        {
            try{
	        // Since scope size is set as '1' - this would be a list with single record
	        for(Case objCase : lstCase)
	        {
	        	String strMoveInOrMoveOut = '';
	        	
	        	if(objCase.RecordTypeId == MOVEIN_CASE_RECORDTYPEID)
	        		strMoveInOrMoveOut = 'Move-In';
				else if(objCase.RecordTypeId == MOVEOUT_CASE_RECORDTYPEID)        	
	        		strMoveInOrMoveOut = 'Move-Out';
	        	
	            // Make call-out to MyBuilding
	            Http h = new Http();
	            HttpRequest req = new HttpRequest();
	            String strRequestBody = 'format=json'; 
	
	            strRequestBody += '&app_id=' + objIntegrationSetting.app_id__c;
	            strRequestBody += '&app_key=' + objIntegrationSetting.app_key__c;
	            strRequestBody += '&communityId=' + objCase.Community_ID__c; 
	            strRequestBody += '&title=' + strMoveInOrMoveOut+': Apartment #' + objCase.Apartment__r.Apartment_Number__c;
	            
	            if(objCase.RecordTypeId == MOVEIN_CASE_RECORDTYPEID)
	            {
	            	strRequestBody += '&text=' + 'A '+strMoveInOrMoveOut+' has been scheduled for Apartment #' + objCase.Apartment__r.Apartment_Number__c + ' On ' + 
	            	                   objCase.Move_In_Date__c.year()+'-'+objCase.Move_In_Date__c.month()+'-'+objCase.Move_In_Date__c.day() + ' At ' 
	            	                   +   objCase.Move_In_Date__c.hour()+':'+objCase.Move_In_Date__c.minute();
	            }
	            else if(objCase.RecordTypeId == MOVEOUT_CASE_RECORDTYPEID)
	            {
	            	strRequestBody +=  '&text=' + 'A '+strMoveInOrMoveOut+' has been scheduled for Apartment #' + objCase.Apartment__r.Apartment_Number__c + ' On ' + 
	            	                   objCase.Move_Out_Date__c.year()+'-'+objCase.Move_Out_Date__c.month()+'-'+objCase.Move_Out_Date__c.day() + ' At ' 
	            	                   +   objCase.Move_Out_Date__c.hour()+':'+objCase.Move_Out_Date__c.minute();
	            }
	            strRequestBody += '&groupId=' + objIntegrationSetting.groupId__c;
	            
	            if(objCase.RecordTypeId == MOVEIN_CASE_RECORDTYPEID)
		            strRequestBody += '&date=' +  objCase.Move_In_Date__c.year()+'-'+objCase.Move_In_Date__c.month()+'-'+objCase.Move_In_Date__c.day();
	            else if(objCase.RecordTypeId == MOVEOUT_CASE_RECORDTYPEID)
	            	strRequestBody += '&date=' +  objCase.Move_Out_Date__c.year()+'-'+objCase.Move_Out_Date__c.month()+'-'+objCase.Move_Out_Date__c.day();
	            
	            strRequestBody += '&dateFrom=' + objCase.Date_From__c.hour()+':'+objCase.Date_From__c.minute();
		        strRequestBody += '&dateTo=' + objCase.Date_To__c.hour()+':'+objCase.Date_To__c.minute();
	            strRequestBody += '&isAllDayEvent=' + objIntegrationSetting.isAllDayEvent__c;
	
	            req.setEndpoint(objIntegrationSetting.EndPoint__c +'/events');
	            req.setMethod('POST');
	            req.setBody(strRequestBody);
	             
	            HttpResponse res; 
	            
	            // Send the request, and return a response
	            res = h.send(req);
	           system.debug('Callout Response::'+ res.getBody());
	            SL_MyBuildingIntegration_ResponseClass objResponse = (SL_MyBuildingIntegration_ResponseClass)JSON.deserialize(res.getBody(), SL_MyBuildingIntegration_ResponseClass.class);
	            
	            // Updating Case Mybuilding_Event_Id__c field with Event record created in MyBuilding if callout is success.
	            if(objResponse.status == 'success')
	            {
	                objCase.Mybuilding_Event_Creation_Status__c = 'Successfully created event in MyBuilding App';
	                objCase.Mybuilding_Event_Id__c = objResponse.response.eventId;
	            }
	            
	            // Updating Case Mybuilding_Event_Creation_Status__c field with the response message when callout is failed. 
	            if(objResponse.status != 'success')
	            {
	                objCase.Mybuilding_Event_Creation_Status__c = objResponse.response.message; 
	            }
	            
	            update objCase;
	        }
            }catch(Exception e)
            {
                system.debug('Error Caught::: Line Number:' + e.getLineNumber() + 'Cause:' + e.getCause());    
            }
        }
   }

   global void finish(Database.BatchableContext BC)
   {
   
   }
   
}