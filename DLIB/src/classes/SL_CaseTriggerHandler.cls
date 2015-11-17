/**
* \arg ClassName      : SL_CaseTriggerHandler
* \arg JIRATicket     : SILVERLINE-189
* \arg CreatedOn      : 30/10/2013
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This is handler class for the SL_CaseTrigger.
*/
public with sharing class SL_CaseTriggerHandler 
{	
	 /* Start - Variable */
	 /* End - Variable*/
	 
	 /* Start - Constructor */
	 public SL_CaseTriggerHandler()
	 {
	 	//do nothing
	 }
	 /* End - Constructor */
	 
	 /*!
        * MethodName : onBeforeInsert
        * param      : List of the new Case records.
        * Description: This method will be called from the trigger on Before Insert event.
    */
	public void onBeforeInsert(list<Case> lstCases)
	{
		//Calling function to insert the Case records.
		updateLicenses(lstCases);
	}
	/* End */
	
	/*!
        * MethodName : onBeforeUpdate
        * param      : Map of old and new Case records.
        * Description: This method will be called from the trigger on Before Update event.
    */
	public void onBeforeUpdate(map<Id,Case> mapOldCase,map<Id,Case> mapNewCase)
	{
		List<Case> lstCases = new List<Case>();//List to contain the Case records in which Subscriber Organization Id has been modified.
		
		//Iterating on map to get the case record.
		for(Case objCase:mapNewCase.values())
		{
			//Checking the Condition whether the SubscriberOrgId has been modified or not by comparing the SubscriberOrgId of old Case record to new Case record.
			if(mapOldCase.get(objCase.Id).Subscriber_Organization_ID__c!=mapNewCase.get(objCase.Id).Subscriber_Organization_ID__c)
				lstCases.add(objCase);
		}
		
		if(!lstCases.IsEmpty())//Checking the condition whether the list is empty or not
			updateLicenses(lstCases);//Calling function to update the Case records.
	}
	/* End */
	
	/*!
        * MethodName : updateLicenses
        * param      : List of the new Case records.
        * Description: This method will be called from the onBeforeInsert and onBeforeUpdate methods of the handler.
    */
	private void updateLicenses(List<Case> lstCases)
	{
		Map<String,String> mapOrgIdsToLicenses = new Map<String,String>();//!< This map is used to keep the SubscriberOrgIds and corresponding License Ids.
		Set<String> setOrgIds = new Set<String>();//<! This set is used to keep the distinct SubscriberOrgIds.
		
		//Iterating on list of Cases to get the SubscriberOrgIds.
		for(Case objCase:lstCases)
		{
			if(objCase.Subscriber_Organization_ID__c!=null)//Checking whether SubscriberOrgId is null or not.
				setOrgIds.add(objCase.Subscriber_Organization_ID__c);
		}
		
		//Querying all the Ids and OrgIds filtered by OrgIds contained in setOrgIds. 
		for(sfLma__License__c objLicense : [SELECT Id,sfLma__Subscriber_Org_ID__c 
									 FROM sfLma__License__c 
									 WHERE sfLma__Subscriber_Org_ID__c IN : setOrgIds])
		{
			if(!mapOrgIdsToLicenses.containskey(objLicense.sfLma__Subscriber_Org_ID__c))
				mapOrgIdsToLicenses.put(objLicense.sfLma__Subscriber_Org_ID__c,objLicense.Id);
		}
		
		//Iterating on List of Cases to update the License Field of Case record.
		for(Case objCase : lstCases)
		{
			if(objCase.Subscriber_Organization_ID__c!=null && mapOrgIdsToLicenses.containskey(objCase.Subscriber_Organization_ID__c))
				objCase.License__c = mapOrgIdsToLicenses.get(objCase.Subscriber_Organization_ID__c);
			else
				objCase.License__c=null;
		}
	}
	/* End */
}