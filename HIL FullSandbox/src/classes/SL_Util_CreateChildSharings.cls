/**
* \arg ClassName      		: SL_Util_CreateChildSharings
* \arg JIRATicket       	: HIL-21
* \arg CreatedOn        	: 12/OCT/2015
* \arg LastModifiedOn   	: 19/OCT/2015
* \arg CreatededBy      	: Pankaj Ganwani
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description      	: This util class is used to update the household field value on the corresponding child object records based on the Account field value.
*/
public without sharing class SL_Util_CreateChildSharings 
{
	/* Start - Constructor */
	public SL_Util_CreateChildSharings()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	public static Map<Id,Id> formAccountToHouseholdMapping(Set<Id> setClientIds)
	{
		Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
		Set<Id> setRepCodeIds = getAccessibleRepCodes();
		
		for(Group_Member__c objGM : [SELECT Relationship_Group__c, Client_Prospect__c FROM Group_Member__c WHERE Client_Prospect__c IN : setClientIds AND Relationship_Group__r.Rep_Code__c IN : setRepCodeIds ORDER BY Relationship_Group__r.CreatedDate])
		{
			mapAccIdToHousehold.put(objGM.Client_Prospect__c, objGM.Relationship_Group__c);
		}		
		return mapAccIdToHousehold;
	}
	
	public static List<Sobject> createSharingRecords(Map<Id, Id> mapChildIdToHouseholdId)
	{
		List<SL_Util_SharingController.RepCodeType> lstRepCodeType = new List<SL_Util_SharingController.RepCodeType>();
		Map<Id,Id> mapHouseholdIdToRepCode = new Map<Id,Id>();
		Set<Id> setRepCodeIds = getAccessibleRepCodes();
		
		for(Relationship_Group__c objRG : [SELECT Rep_Code__c, Id FROM Relationship_Group__c WHERE ID IN : mapChildIdToHouseholdId.values() AND  Rep_Code__c IN : setRepCodeIds])
		{
			mapHouseholdIdToRepCode.put(objRG.Id, objRG.Rep_Code__c);
		}
		
		for(Id childId : mapChildIdToHouseholdId.keyset())
		{
			Id householdId = mapChildIdToHouseholdId.get(childId);
			
			if(mapHouseholdIdToRepCode.containskey(householdId))
				lstRepCodeType.add(new SL_Util_SharingController.RepCodeType(childId, mapHouseholdIdToRepCode.get(householdId)));
		}
		return SL_Util_SharingController.createSharingRecords(lstRepCodeType, 'Read');
	}
	
	private static Set<Id> getAccessibleRepCodes()
	{
		Map<Id,Id> mapPublicGroupIdToRepCode = new Map<Id,Id>();
		Set<Id> setRepCodeIds = new Set<Id>();
		
		for(Rep_Code__c objRC : [SELECT Id, Public_Group_Id__c FROM Rep_Code__c WHERE Public_Group_Id__c!=NULL])
		{
			mapPublicGroupIdToRepCode.put(objRC.Public_Group_Id__c, objRC.Id); 
		}
		
		for(GroupMember objGM : [SELECT GroupId FROM GroupMember WHERE UserOrGroupId =: Userinfo.getUserId() AND GroupId IN : mapPublicGroupIdToRepCode.keyset()])
		{
			setRepCodeIds.add(mapPublicGroupIdToRepCode.get(objGM.GroupId));
		}
		
		return setRepCodeIds;
	}
}