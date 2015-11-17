/**
* @author Edward Rivera
* @date 12/14/2014
* @description This class is a utility class that returns records diffed over a set of fields, useful for Trigger.new[Map] and Trigger.old[Map].
*/
public with sharing class SL_util_DiffRecord {

	/**
	* @author Edward Rivera
	* @date 12/14/2014
	* @description Pass in two maps of Id to Record and a field, returns a map of only the changed SObjects
	*/  
	public static Map<Id, SObject> getRecordsWithDiff(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, String fieldName){
		return getRecordsWithDiff(oldMap, newMap, new Set<String>{fieldName});
	}	
	/**
	* @author Edward Rivera
	* @date 12/14/2014
	* @description Pass in two lists of Records and a field, returns a map of only the changed SObjects 
	*/  
	public static List <SObject> getRecordsWithDiff(List <SObject> oldList, List <SObject> newList, String fieldName){
		return getRecordsWithDiff(oldList, newList, new Set<String>{fieldName});
	}
	/**
	* @author Edward Rivera
	* @date 12/14/2014
	* @description Pass in two maps of Id to Record and a set of fields, returns a map of only the changed SObjects
	*/  
	public static Map<Id, SObject> getRecordsWithDiff(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, Set<String> fieldNames){
		return new Map<Id, SObject> (getRecordsWithDiff(oldMap.values(), newMap.values(), fieldNames));
	} 
	/**
	* @author Edward Rivera
	* @date 12/14/2014
	* @description Pass in two lists of Records and a set of fields, returns a map of only the changed SObjects 
	*/ 
	public static List <SObject> getRecordsWithDiff(List <SObject> oldList, List <SObject> newList, Set<String> fieldNames){
		List <SObject> recordsWithDiff = new List<SObject>();
		if (oldList.isEmpty()){
			return newList;
		}
		if (oldList.size()!=newList.size()){
			throw new CustomException('Lists are different sizes.');
		}
		// throws exception if fields are not valid for list types
		getFieldCheckResult(oldList[0].getSObjectType(), newList[0].getSObjectType(), fieldNames);

		for (Integer ii = 0; ii < oldList.size(); ii++){
			if (recordDiff(oldList[ii], newList[ii], fieldNames)){
				recordsWithDiff.add(newList[ii]);
			}
		}
		return recordsWithDiff;
	}


	/**
	* @author Edward Rivera
	* @date 2/20/2015
	* @description Pass in the old version and new version of an SObject and a set of fields to check again, returns if the record has changed over those fields
	*/ 
	public static Boolean recordDiff(SObject oldObj, SObject newObj, Set<String> fieldNames){
		for (String fieldName: fieldNames){
			if (oldObj.get(fieldName)!=newObj.get(fieldName)){
				return true;
			}
		}
		return false;
	}

	/**
	* @author Edward Rivera
	* @date 2/20/2015
	* @description Pass in the old version and new version of an SObject and a set of fields to check again, returns if the record has changed over those fields
	*/ 
	public static void getFieldCheckResult(SObjectType oldObjType, SObjectType newObjType, Set<String> fieldNames){
		Set <String> fieldNamesLowerCase = new Set<String>();
		for (String ss: fieldNames){
			fieldNamesLowerCase.add(ss.toLowercase());
		}
		Set<String> oldObjectFieldNames = oldObjType.getDescribe().fields.getMap().keySet();
		Set<String> oldMissingFields = new Set<String>();
		String fieldCheckResult = '';

		if (oldObjType!=newObjType){
			System.debug(LoggingLevel.WARN, 'WARNING: Lists are of different types.');
			Set<String> newObjectFieldNames = newObjType.getDescribe().fields.getMap().keySet();
			Set<String> newMissingFields = new Set<String>();
			for (String fieldName: fieldNamesLowerCase){
				if (!newObjectFieldNames.contains(fieldName)){
					newMissingFields.add(fieldName);
				}
			}
			if (!newMissingFields.isEmpty()){
				fieldCheckResult += 'Not all fields are valid ' + newObjType.getDescribe().getName() + ' fields: ';
				fieldCheckResult += String.join(new List<String>(newMissingFields), ', ');
			}
		}
		for (String fieldName: fieldNamesLowerCase){
			if (!oldObjectFieldNames.contains(fieldName)){
				oldMissingFields.add(fieldName);
			}
		}
		if (!oldMissingFields.isEmpty()){
			fieldCheckResult += 'Not all fields are valid ' + oldObjType.getDescribe().getName() + ' fields: ';
			fieldCheckResult += String.join(new List<String>(oldMissingFields), ', ');
		}
		
		if (fieldCheckResult!=''){
			throw new CustomException(fieldCheckResult);
		}
				
	}

	public class CustomException extends Exception{}
}