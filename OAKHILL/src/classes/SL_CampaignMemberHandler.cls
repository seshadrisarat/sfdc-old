/**
* \arg ClassName      : SL_CampaignMemberHandler
* \arg JIRATicket     : OAKHILL-26
* \arg CreatedOn      : 18/JUNE/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class works as handler for SL_CampaignMember and is employed for rolling up the campaign email addresses to related campaign.
*/
public with sharing class SL_CampaignMemberHandler 
{
	/* Start - Constructor */
	public SL_CampaignMemberHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/*
		@MethodName : onAfterInsert 
		@param 	    : list of inserted campaign member records
		@Description: This method will be called on insertion of campaign member records and calls another private method for updating the related campaign record. 
	*/
	public static void onAfterInsert(List<CampaignMember> lstCampaignMember)
	{
		rollUpEmail(lstCampaignMember);
	}
	
	/*
		@MethodName : onAfterDelete 
		@param 	    : list of deleted campaign member records
		@Description: This method will be called on deletion of campaign member records and calls another private method for updating the related campaign record. 
	*/
	public static void onAfterDelete(List<CampaignMember> lstCampaignMember)
	{
		rollUpEmail(lstCampaignMember);
	}
	
	/*
		@MethodName : rollUpEmail 
		@param 	    : list of deleted campaign member records
		@Description: Method which will be called from both onAfterInsert and onAfterDelete methods and used to update the campaigns with rolled up emails of campaign members. 
	*/
	private static void rollUpEmail(List<CampaignMember> lstCampaignMember)
	{
		Map<Id, Set<String>> mapCampaignIdToSetOfEmail = new Map<Id, Set<String>>();
		Set<Id> setCampaignId = new Set<Id>();
		List<Campaign> lstCampaign = new List<Campaign>();
		
		//collecting campaign ids so that we can fetch related existing campaign members.
		for(CampaignMember objCM : lstCampaignMember)
		{
			setCampaignId.add(objCM.CampaignId);
		}
		
		for(CampaignMember objCM : [SELECT Contact.Email, Lead.Email, CampaignId FROM CampaignMember WHERE CampaignId IN : setCampaignId AND (Contact.Email!=NULL OR Lead.Email!=NULL) ORDER BY CreatedDate])
		{
			String strEmail = String.isNotEmpty(objCM.Contact.Email) ? objCM.Contact.Email : objCM.Lead.Email;
			
			//set has been taken so that we can prevent duplicate email addresses in roll up field on related campaign as more than one campaign members may have same email address.
			if(!mapCampaignIdToSetOfEmail.containskey(objCM.CampaignId))
				mapCampaignIdToSetOfEmail.put(objCM.CampaignId, new Set<String>{strEmail});
			else
				mapCampaignIdToSetOfEmail.get(objCM.CampaignId).add(strEmail);
		}
		
		for(Id campaignId : setCampaignId)
		{
			lstCampaign.add(new Campaign(Id = campaignId, Campaign_Member_Emails__c = mapCampaignIdToSetOfEmail.containskey(campaignId) ? String.join(new List<String>(mapCampaignIdToSetOfEmail.get(campaignId)),';') : NULL));
		}
		
		update lstCampaign;
	}
}