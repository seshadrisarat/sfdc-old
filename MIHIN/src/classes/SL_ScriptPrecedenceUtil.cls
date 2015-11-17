/*
Utility class to compare the precedence of the Script__c field from an object to that in the custom setting 
and update fields based on the precedence. SL Ref: MIHIN-119
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_ScriptPrecedenceUtil {
	
	string sObjectName = null;
	public static boolean isExecuting = false;
	set<string> objectsUsingTrigger = new set<string>();
	public static Map<string, SL_Script_Precedence__c> mapPrecedences = SL_Script_Precedence__c.getAll();

	public SL_ScriptPrecedenceUtil(string sObjectName) {
		objectsUsingTrigger.add(sObjectName);
		this.sObjectName = sObjectName;
	}

	public void getNewMap(Map<id, sObject> oldMap, Map<id, sObject> newMap){
		
		if( SL_ScriptPrecedenceUtil.isExecuting && objectsUsingTrigger.contains(sObjectName)){
			//Avoid recursion for the current object
			return;
		}
 
		SL_ScriptPrecedenceUtil.isExecuting = true;
		Map<id, sObject> mapToReturn = new Map<id, sObject>();
		
		Map<String, Schema.sObjectType> globalDescribe = Schema.getGlobalDescribe();
		Schema.DescribesObjectResult res = globalDescribe.get(sObjectName).getDescribe();  
		Map<String, Schema.sObjectField> mapToken_Fields = res.fields.getMap();
		
		for(Id objId : newMap.keySet()){
			sObject sObjToUpdate = Schema.getGlobalDescribe().get(sObjectName).newSObject() ;
			sObjToUpdate.Id = objId;
			sObject newobj = newMap.get(objId);
			sObject oldobj = oldMap.get(objId);
			String newScript = (string)newobj.get('Script__c');
			String oldScript = (string)oldobj.get('Script__c');
		
			SL_Script_Precedence__c objNewPrecedence = mapPrecedences.get(newScript);
			SL_Script_Precedence__c objOldPrecedence = mapPrecedences.get(oldScript);

			//NOTE: Lower number in precedence means higher precedence so checking for lower precendence would mean checking for greater than
			if(objOldPrecedence!=null
				&& oldScript != null 
				&& newScript != oldScript 
				&& (objNewPrecedence == null 
					|| objNewPrecedence.Precedence__c >= objOldPrecedence.Precedence__c)){
				
				//For each field, only update blank fields - so change the newMap accordingly
				for( String field : mapToken_Fields.keySet()){
					//system.debug('Comparing '+field+' : '+oldobj.get(field)+' and '+ newobj.get(field));
					if(mapToken_Fields.get(field).getDescribe().isUpdateable() 
							&& oldobj.get(field) !=null 
								&& oldobj.get(field) != newobj.get(field)){
						//system.debug('Changing '+field+' back to:'+ oldobj.get(field));
						sObjToUpdate.put(field, oldobj.get(field));

					}
				}

			}
			mapToReturn.put(objId, sObjToUpdate);
		}
		update(mapToReturn.values());
		
	}

}