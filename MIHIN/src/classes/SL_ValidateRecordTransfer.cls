/*
*Class: SL_ValidateRecordTransfer
*Description: This class will validate the transfer records.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public without sharing class SL_ValidateRecordTransfer 
{
	public static final String profileName = 'HPD - Population Admin';//Store the 'HPD - Population Admin' profilr name.
	public String profileId;//To store the profile Id.
	
	/*Main constructor*/
	public SL_ValidateRecordTransfer()
	{
		profileId = '';
		profileId =  [Select Id, Name from Profile where Name=: profileName limit 1].Id;
			
	}
	
	/*  
    @MethodName   : validateUpdatedRecords
    @param        : set<Id> setRecordIds
    @Description  : Method called on event: Before Update
    */
	public set<Id> validateUpdatedRecords(set<Id> setRecordIds)
	{
		list<Id> lstRecordIds = new list<Id>(setRecordIds);
		set<Id> setErrorRecordIds = new set<Id>();//To store the error records.
		
		/* If Profile Id equal to HPD-Profile then only we need to check the record access permission */
		if(Userinfo.getProfileId() == profileId)
		{
			/*Taking all the record ids where profile is 'HPD - Population Admin' and user is having access of that record. */
	    	for(UserRecordAccess  objURA : [SELECT RecordId, HasEditAccess FROM UserRecordAccess where (RecordId IN :lstRecordIds ) AND (UserId =:Userinfo.getUserId())])
	    	{
	    		/*If user dont have read/write access then throw the error message.*/
	    		if(!objURA.HasEditAccess)
	    		{
	    			setErrorRecordIds.add(Id.valueOf(objURA.RecordId));
	    		}
	    	}
		}
    	
    	return setErrorRecordIds;
	}
}