/**
* \arg ClassName      		: SL_Util_SharingController
* \arg JIRATicket     		: HIL-4
* \arg CreatedOn      		: 13/FEB/2015
* \arg LastModifiedOn 		: 29/APR/2015
* \arg CreatededBy    		: Pankaj Ganwani
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description    		: This util class is used to create sharing records corresponding to different objects. This class will be called from several controllers and it uses SL_SharingController for getting list of sharing records.
*/
public without sharing class SL_Util_SharingController 
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
		Rep_Code__c[] rcpList = new Rep_Code__c[]{};// this list holds the information related to Public group which belongs to rep code.
		Map<Id,Id> rcpMap = new Map<Id,Id>(); //Map of repCode Ids and associated public group ids
		
		for(RepCodeType r : rcList) //Loop through custom type to get all Rep Code Ids
		{
			rcIds.add(r.repCodeId);
		}
		/* Start - This code snippet has been updated as per the requirement of HIL-14 */
		rcpList = [SELECT Public_Group_Id__c, Id FROM Rep_Code__c WHERE Id IN: rcIds AND Public_Group_Id__c!=NULL];
		
		if(!rcpList.isEmpty())
		{			
			for(Rep_Code__c objRepCode : rcpList)
				rcpMap.put(objRepCode.Id,objRepCode.Public_Group_Id__c);
		}
				
		for(RepCodeType r : rcList) //Loop through list, create sharing records
		{
			Id publicGroupId = rcpMap.get(r.repCodeId);
			lstSharingParams.add(new SL_SharingController.sharingParams(r.recordId, publicGroupId, accessLevel));				
		}		
		/* End - This code snippet has been updated as per the requirement of HIL-14 */
		if(!lstSharingParams.isEmpty())
		{
			lstSobject = SL_SharingController.modifySharing(lstSharingParams);//calling method to return the list of sharing object records.	
		}
		return lstSobject; //pass back a list of sObjects, DML should happen in TriggerHandler not Utility Class
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