/**
* \arg ClassName      : SL_UpdateGroupMemberController
* \arg JIRATicket     : HIL-7
* \arg CreatedOn      : 20/FEB/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves a generic class and contains the static methods which will be called from both SL_HilliardLyonsAccountHandler and SL_FinancialAccountHandler.
*/
public with sharing class SL_UpdateGroupMemberController 
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_UpdateGroupMemberController()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/*
        * MethodName   : updateGroupMembers
        * Param        : set of the group member record Ids that need to be updated
        * Description  : This method is used to update the group member object records corresponding to the passed group member ids
    */
	@future
	public static void updateGroupMembers(Set<Id> setGMId)
	{
		List<Group_Member__c> lstGM = new List<Group_Member__c>();//list to hold group member object records that need to be updated
		for(Group_Member__c objGM : [SELECT Id, Total_Primary_Asset__c, Total_Primary_Cash_Available__c, Total_Primary_Money_Market__c, Total_Primary_Revenue__c FROM Group_Member__c WHERE Id IN : setGMId])
		{
            System.debug(objGM);
			lstGM.add(new Group_Member__c(Id = objGM.Id, Total_Primary_Asset_RU__c = objGM.Total_Primary_Asset__c, Total_Primary_Cash_Available_RU__c = objGM.Total_Primary_Cash_Available__c, Total_Primary_Money_Market_RU__c = objGM.Total_Primary_Money_Market__c, Total_Primary_Revenue_RU__c = objGM.Total_Primary_Revenue__c));
		}
		if(!lstGM.isEmpty())
			update lstGM;
	}
}