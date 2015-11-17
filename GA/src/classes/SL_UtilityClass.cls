/**
* @author Edward Rivera
* @date 12/14/2014
* @description This class is a utility class that returns records diffed over a set of fields, useful for Trigger.new[Map] and Trigger.old[Map].
*/
public with sharing class SL_UtilityClass {

	public static Map<SObjectType, Schema.DescribeSObjectResult> cachedDescribe = new Map<SObjectType, Schema.DescribeSObjectResult>();
	/**
	* @author Edward Rivera
	* @date 12/14/2014
	* @description Pass in an SObject and get its name.
	*/ 
	public static String getSObjectTypeName(SObject so) {
		SObjectType objType = so.getSObjectType();
		if (!cachedDescribe.containsKey(objType)){
			cachedDescribe.put(objType, objType.getDescribe());
		}
		return cachedDescribe.get(objType).getName();
	}
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
	* @description Pass in two maps of Id to Record and a list of fields, returns a map of only the changed SObjects
	*/  
	public static Map<Id, SObject> getRecordsWithDiff(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, Set<String> fieldNames){
		return new Map<Id, SObject> (getRecordsWithDiff(oldMap.values(), newMap.values(), fieldNames));
	} 
	/**
	* @author Edward Rivera
	* @date 12/14/2014
	* @description Pass in two lists of Records and a field, returns a map of only the changed SObjects 
	*/ 
	public static List <SObject> getRecordsWithDiff(List <SObject> oldList, List <SObject> newList, Set<String> fieldNames){
		try{ 
			List <SObject> recordsWithDiff = new List<SObject>();
			if (oldList.isEmpty()){
				return recordsWithDiff;
			}
			if (oldList.isEmpty() || oldList.size()!=newList.size()){
				throw new CustomException('Lists are different sizes.');
			}
			SObjectType objType = oldList[0].getSObjectType();
			if (objType!=newList[0].getSObjectType()){
				throw new CustomException('Lists are of different types');
			}
			if (!cachedDescribe.containsKey(objType)){
				cachedDescribe.put(objType, objType.getDescribe());
			}
			Set <String> fieldNamesLowerCase = new Set<String>();
			for (String ss: fieldNames){
				fieldNamesLowerCase.add(ss.toLowercase());
			}
			Set<String> allObjectFieldNames = cachedDescribe.get(objType).fields.getMap().keySet();
				if (!allObjectFieldNames.containsAll(fieldNamesLowerCase)){
					throw new CustomException('Not all fields are valid ' + cachedDescribe.get(objType).getName() + ' fields');
			}

			for (Integer ii = 0; ii < oldList.size(); ii++){
				if (recordDiff(oldList[ii], newList[ii], fieldNames)){
					recordsWithDiff.add(newList[ii]);
				}
			}
			return recordsWithDiff;
		}
		catch (CustomException ex){
			throw ex;
		}
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

	public class CustomException extends Exception{}
}