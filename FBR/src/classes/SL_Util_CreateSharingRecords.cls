/**
* \arg ClassName        : SL_Util_CreateSharingRecords
* \arg JIRATicket     	: FBR-2
* \arg CreatedOn      	: 20/MAR/2015
* \arg LastModifiedOn   : 10/APR/2015
* \arg CreatededBy    	: Pankaj Ganwani
* \arg LastModifiedBy	: Pankaj Ganwani
*/
public class SL_Util_CreateSharingRecords 
{
	/* Start - Variables */  
	static final String EDIT_STATUS = 'Edit';
	/* End - Variables */
	
	public static void createDealSharingRecords(List<Deal_Team_Member__c> lstDealTeamMembers)
	{
		List<Deals__Share> lstDealShare = new List<Deals__Share>();//list to hold sharing records that needs to be inserted.
		
		//fetching deal team member records corresponding to which we have to create sharing records.
		for(Deal_Team_Member__c objDTM : lstDealTeamMembers)
		{
			lstDealShare.add(new Deals__Share(ParentId = objDTM.Related_Deal__c, UserOrGroupId = objDTM.FBR_Team_Member__r.User__c, AccessLevel = EDIT_STATUS));
		}
		
		if(!lstDealShare.isEmpty())
			Database.insert(lstDealShare,false);
	}
}