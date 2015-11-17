/**
* \arg ClassName      : SL_Util_SharingController
* \arg JIRATicket     : HIL-4
* \arg CreatedOn      : 13/FEB/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This util class is used to create sharing records corresponding to different objects. This class will be called from several controllers and it uses SL_SharingController for getting list of sharing records.
*/
public with sharing class SL_Util_SharingController 
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_Util_SharingController()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	 /*
        * MethodName   : createSharingRecords
        * Param        : map of rep code id to list of repcodetype class instances and access level
        * Description  : This method is used to create sharing records corresponding the record Ids which are specified in wrapper class.
    */
	public static sObject[] createSharingRecords(List<RepCodeType> rcList, String accessLevel)
	{
		List<SL_SharingController.sharingParams> lstSharingParams = new List<SL_SharingController.sharingParams>();// list to hold the wrapper class records which has been developed in SL_SharingController controller to frame sharing records
        Sobject[] lstSobject = new Sobject[]{};
		Set<Id> rcIds = new Set<Id>();
		Rep_Code_User__c[] rcuList = new Rep_Code_User__c[]{};
		Map<Id,Set<Id>> rcuMap = new Map<Id,Set<Id>>(); //Map of repCode Ids and associated User Ids since the
														//Rep_Code_User__c object is a many-to-many relationship
		
		for(RepCodeType r : rcList) //Loop through custom type to get all Rep Code Ids
		{
			rcIds.add(r.repCodeId);
		}
		
		rcuList = [SELECT Rep_Code__c, User__c FROM Rep_Code_User__c WHERE Rep_Code__c IN: rcIds AND User__r.IsActive = true];
		
		if(!rcuList.isEmpty())
		{			
			for(Rep_Code_User__c rcu : rcuList) //Populate map
			{
				if(rcuMap.containsKey(rcu.Rep_Code__c))
				{
					rcuMap.get(rcu.Rep_Code__c).add(rcu.User__c);
				}else
				{
					rcuMap.put(rcu.Rep_Code__c,new Set<Id>{rcu.User__c});
				}
			}
		}
				
		for(RepCodeType r : rcList) //Loop through list, create sharing records
		{
			Set<Id> userIds = rcuMap.get(r.repCodeId);
			
			if(userIds != null && !userIds.isEmpty())
			{
				for(Id i : userIds)
				{
					lstSharingParams.add(new SL_SharingController.sharingParams(r.recordId, i, accessLevel));
				}
			}
		}
			
		if(!lstSharingParams.isEmpty())
		{
			lstSobject = SL_SharingController.modifySharing(lstSharingParams);//calling method to return the list of sharing object records.	
		}
		
		return lstSobject; //pass back a list of sObjects, DML should happen in TriggerH	andler not Utility Class
	}
	
	//wrapper class to hold the object record id for which we have to create sharing records and corresponding repcode id.
	public class RepCodeType
	{
		Id recordId;
		Id repCodeId;
		
		public RepCodeType(Id recordId, Id repCodeId)
		{
			this.recordId = recordId;
			this.repCodeId = repCodeId;
		}
	}
	
}