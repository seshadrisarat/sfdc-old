/**  
* \arg ClassName        : SL_AccountHelper
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Helper class
*/
public without sharing class SL_AccountHelper {

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

public static void updateProspectSharing(map<Id,Account> newMap)
{
	map<Id,Id> acctRepMap = new map<Id,Id>();
	//map<String,Id> rcPgIdMap = new map<String,Id>();

	for(Account a : newMap.values())
	{
		if(a.Type == 'Prospect' && a.Prospect_Rep_Code__c != null)
		{
			acctRepMap.put(a.Id,a.Prospect_Rep_Code__c);
		}
	}

	AccountShare[] aShare = new AccountShare[]{};
	aShare = [Select Id
			  From AccountShare
			  WHERE AccountId IN: acctRepMap.keyset() AND RowCause = 'Manual'];

	delete aShare;

	SL_Util_SharingController.RepCodeType[] shareList = new SL_Util_SharingController.RepCodeType[] {};

    if(acctRepMap != null && !acctRepMap.isEmpty())
    {
        for(Id i : acctRepMap.keySet())
        {
            shareList.add(new SL_Util_SharingController.RepCodeType(i, acctRepMap.get(i)));
        }
    }

    aShare = SL_Util_SharingController.createSharingRecords(shareList, 'Edit');

    for(AccountShare a : aShare)
    {
    	a.OpportunityAccessLevel = 'Edit';
    }

    Database.insert(aShare);
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