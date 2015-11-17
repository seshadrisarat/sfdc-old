/**  
* \arg ClassName      : SL_util_TestSetup
* \arg JIRATicket     : 
* \arg createdOn      : 2015-06-23
* \arg LastModifiedOn : 
* \arg creatededBy    : Edward Rivera
* \arg ModifiedBy     : 
* \arg Description    : Utility class for setting up test variables based on JSON
*/
public with sharing class SL_util_TestSetup 
{
	private static Map<String, Object> mapJsonObjects; 
	private static Map<string, ID> recordTypeIds;
	
	static
	{
		String strJson = getTestJSONFromStaticResources('SL_TestSetupJsonData');
		mapJsonObjects = (Map<String, SObject>) JSON.deserialize(strJson, Map<String, SObject>.class);
		recordTypeIds = new map<string,ID>();
		for(RecordType rt : [select ID, DeveloperName, sObjectType from RecordType where sObjectType in :mapJsonObjects.keyset()])
		{
			recordTypeIds.put(rt.sObjectType + '-' + rt.DeveloperName, rt.ID);
		}
	}

	public static List<SObject> createRecords(String baseName, Integer count){
		List<SObject> results = new List<SObject>();
		SObject baseObject = (SObject) mapJsonObjects.get(basename);
		
		for(Integer x = 0; x < count; x++)
		{
			results.add(baseObject.clone());
		}
		return results;
	}

	private static String getTestJSONFromStaticResources(String resource)
    {
     	return [SELECT body, name from StaticResource where Name =:resource].body.toString();     	
    }     
}