/**
* \arg ClassName      : SL_NoteHandler
* \arg JIRATicket     : HIL-4
* \arg CreatedOn      : 13/FEB/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as handler for SL_Note and used to create sharing records corresponding to Note__c. This class calls SL_Util_SharingController for creating sharing records.
*/
public with sharing class SL_NoteHandler 
{
	static final String ACCESS_LEVEL = 'Read';
	
	/* Start - Constructor */
	public SL_NoteHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	 /*
        * MethodName   : onAfterInsert
        * Param        : list of inserted Note__c records
        * Description  : This method is used to create sharing records corresponding to inserted Note__c records. This method calls createSharingRecords method for performing this operation.
    */
	public void onAfterInsert(Map<Id,Note__c> newMap)
	{
		SL_Note_Joiner_Handler njHandler = new SL_Note_Joiner_Handler(false,200);
		njHandler.createJoinerRecs(newMap);
		//createSharingRecords(null,newMap);//calling method to create association of rep code ids with object record ids.
	}
	
	/*
        * MethodName   : createSharingRecords
        * Param        : list of inserted Note__c records
        * Description  : This method is used to create sharing records corresponding to inserted Note__c records. This method calls createSharingRecords method of SL_Util_SharingController class.
    */
	private void createSharingRecords(Map<Id,Note__c> oldMap, Map<Id,Note__c> newMap)
	{
		List<SL_Util_SharingController.RepCodeType> rcList = new List<SL_Util_SharingController.RepCodeType>();
		
		for(Note__c objNote : newMap.values())
		{
			if(objNote.Account_del__c != null && objNote.Rep_Code__c != null)
			{
				rcList.add(new SL_Util_SharingController.RepCodeType(objNote.Id, objNote.Rep_Code__c));
			}
		}
		
		if(!rcList.isEmpty())
        {
			insert SL_Util_SharingController.createSharingRecords(rcList, ACCESS_LEVEL);
        }
	}
}