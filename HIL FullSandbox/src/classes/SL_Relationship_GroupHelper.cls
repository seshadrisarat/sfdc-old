/**  
* \arg ClassName        : SL_Relationship_GroupHelper
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Helper class
*/
public with sharing class SL_Relationship_GroupHelper {

/*BEGIN PROPERTIES*/

/*END PROPERTIES*/

/***************************************************
*	SHARED METHODS    					   		   *
***************************************************/

/***************************************************
*	BEFORE INSERT METHODS    					   *
***************************************************/

/***************************************************
*	BEFORE UPDATE METHODS    					   *
***************************************************/

/***************************************************
*	BEFORE DELETE METHODS    					   *
***************************************************/

/***************************************************
*	AFTER INSERT METHODS    					   *
***************************************************/

public static void updateSharing(map<Id,Relationship_Group__c> newMap)
{
	Relationship_Group__Share[] relSharing = new Relationship_Group__Share[]{};

	relSharing = [Select Id
				  From Relationship_Group__Share
				  WHERE ParentId IN: newMap.keyset() AND RowCause = 'Manual'];

	delete relSharing;

	SL_Util_SharingController.RepCodeType[] shareList = new SL_Util_SharingController.RepCodeType[] {};

    if(newMap != null && !newMap.isEmpty())
    {
        for(Id i : newMap.keySet())
        {
            shareList.add(new SL_Util_SharingController.RepCodeType(i, newMap.get(i).Rep_Code__c));
        }
    }

    Database.insert(SL_Util_SharingController.createSharingRecords(shareList, 'Edit'),false);
}

/***************************************************
*	AFTER UPDATE METHODS    					   *
***************************************************/

/***************************************************
*	AFTER DELETE METHODS    					   *
***************************************************/

/***************************************************
*	AFTER UNDELETE METHODS    					   *
***************************************************/

}