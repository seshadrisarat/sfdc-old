/**
* \arg ClassName      : SL_InvestorContactHandler
* \arg JIRATicket     : OAKHILL-10
* \arg CreatedOn      : 08/OCT/2014
* \arg LastModifiedOn : 08/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as handler for SL_InvestorContact trigger and used to make inactive those Fund of interest records for which contact and fund is same as that of inserted investor contact's contact and related account respectively.
*/
public with sharing class SL_InvestorContactHandler 
{
	 /** 
        * @Name         : onAfterInsert
        * @parameter    : map of investor contact records
        * @Description  : This method will be called on after insert of investor contact record.
    */ 
	public void onAfterInsert(Map<Id,Investor_Contact__c> mapIdToInvestorContact)
	{
		Set<Id> setContactId = new Set<Id>();//set to contain contact ids related to inserted investor contacts
		Set<Id> setRelatedAccountId = new Set<Id>();//set to contain ids of related account records corresponding to inserted investor contacts
		Set<Id> setFundFamilyId = new Set<Id>();// set to contain fund ids
		List<Fund_of_Interest__c> lstFundOfInterest = new List<Fund_of_Interest__c>();//list to update fund of interest records
		
		//iterating over investor contact object to fill set of related contact ids and related account ids
		for(Investor_Contact__c objInvestorContact : mapIdToInvestorContact.values())
		{
			setContactId.add(objInvestorContact.Contact__c);
			setRelatedAccountId.add(objInvestorContact.Investment__c);
		}
		//iterating over related account object to fill the set of fund ids
		for(Related_Account__c objRelatedAccount : [SELECT Fund__r.Fund_Family__c FROM Related_Account__c WHERE Id IN:setRelatedAccountId])
		{
			if(objRelatedAccount.Fund__r.Fund_Family__c!=null)
				setFundFamilyId.add(objRelatedAccount.Fund__r.Fund_Family__c);
		}
		
		//iterating over fund of interest records to update them
		for(Fund_of_Interest__c objFundOfInterest : [SELECT Id FROM Fund_of_Interest__c WHERE Contact__c IN : setContactId AND Fund_Family__c IN : setFundFamilyId AND Status__c =:'Active'])
		{
			lstFundOfInterest.add(new Fund_of_Interest__c(Id = objFundOfInterest.Id, Status__c = 'Inactive'));
		}
		
		if(!lstFundOfInterest.isEmpty())
			update lstFundOfInterest;
	}
}