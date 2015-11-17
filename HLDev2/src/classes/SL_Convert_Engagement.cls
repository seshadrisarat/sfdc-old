/**
* \arg ClassName      : SL_Convert_Engagement
* \arg JIRATicket     : HL-7
* \arg CreatedOn      : 14/APR/2014
* \arg LastModifiedOn : 10/DEC/2014
* \arg CreatededBy    : Vishnu
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Handler class for SL_Convert_Engagement page.
*/
global with sharing class SL_Convert_Engagement {
	
	webService static String convertEngagement(Id opportunityId) {
    Map<Id,Opportunity__c> mapIdToOpportunity = new Map<Id,Opportunity__c>();
    try {
  		Map<String, String> fieldNames = new Map<String, String>();
  		Map<String, Schema.SObjectField> opportunityFields = Opportunity__c.getSObjectType().getDescribe().fields.getMap();
  		Map<String, Schema.SObjectField> engagementFields = Engagement__c.getSObjectType().getDescribe().fields.getMap();
  		for(SL_Convert__Field_Mapping__c objFM : [SELECT SL_Convert__Context_Field_Name__c,
  														                         SL_Convert__Target_Field_Name__c
                                            			FROM SL_Convert__Field_Mapping__c 
                                            		   WHERE SL_Convert__Active__c = true 
                                            		   	 AND SL_Convert__Object_Relationship__r.SL_Convert__Parent_Object_Relationship__c = null 
                                            		     AND SL_Convert__Object_Relationship__r.SL_Convert__Context_Object_API__c = 'Opportunity__c']){
        if(objFM.SL_Convert__Context_Field_Name__c != null 
          	&& objFM.SL_Convert__Context_Field_Name__c != '' 
            && objFM.SL_Convert__Target_Field_Name__c != null 
            && objFM.SL_Convert__Target_Field_Name__c != ''
          	&& opportunityFields.keySet().contains(objFM.SL_Convert__Context_Field_Name__c.toLowerCase())
          	&& engagementFields.keySet().contains(objFM.SL_Convert__Target_Field_Name__c.toLowerCase())){
          	fieldNames.put(objFM.SL_Convert__Target_Field_Name__c, objFM.SL_Convert__Context_Field_Name__c);
        }
      }
         	
  		String strQuery = !fieldNames.isEmpty() ? ', ' + String.join(fieldNames.values(), ', ') : '';
      strQuery = 'SELECT Id, Converted_To_Engagement__c' + strQuery + ' FROM Opportunity__c WHERE Id = \'' +opportunityId +'\'';
         	
      for(Opportunity__c opp : Database.query(strQuery)){
        if (opp.Converted_to_Engagement__c){
          return 'ERROR: Opportunity has already been converted to an Engagement!';
        }
        opp.Converted_To_Engagement__c=true;
        update opp;
        mapIdToOpportunity.put(opp.Id, opp);
      }
      SL_Convert.SL_MappingTrigger_Handler objMappingTriggerHandler = new SL_Convert.SL_MappingTrigger_Handler();
  		objMappingTriggerHandler.createSobjectRecords(mapIdToOpportunity,'Opportunity__c');//<! call createSobjectRecords method
  		
  		List<Engagement__c> newEngagement = [SELECT Id FROM Engagement__c WHERE Opportunity__c=:opportunityId ORDER BY CreatedDate Desc LIMIT 1];

  		if (!newEngagement.isEmpty()){
  			return newEngagement[0].Id;
  		}
  		return opportunityId;
    }
    catch (DMLException e){ 
      return 'ERROR: ' + e.getDMLMessage(0);
    }
    catch (Exception e){
      return 'ERROR: ' + e.getMessage();
    }
    finally {
      for (Opportunity__c opp: mapIdToOpportunity.values()){
        opp.Converted_To_Engagement__c=false;
      }
      if (!mapIdToOpportunity.isEmpty()){
        update mapIdToOpportunity.values();
      }
    }
	}
}