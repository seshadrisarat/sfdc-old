/*
JIRA Ticket: PURE-8
Class name : SL_UpdatedCommunicationPreferences
Developer  : Pradeep
Created on : 27/Mar/2014
Description: Fetches the 'ContactInfo' records Information of a Member that are updated via community through ProfileSetting page.
*/

public with sharing class SL_UpdatedCommunicationPreferences 
{
	public String strMemberId											{get;set;}
	public String fullUrl		{get;set;}
	
	public SL_UpdatedCommunicationPreferences()
	{
		fullUrl = '';
		PortalURLMap__c oOrganizationURL = new PortalURLMap__c();
		oOrganizationURL = PortalURLMap__c.getInstance('OrgURL');
		fullUrl = (oOrganizationURL != null) ? oOrganizationURL.URL__c : '#';
	}	
	
	//	Getter method for Account record
	public Account getObjAccount()
	{
		try
		{
			String strQueryAccount = 'Select Id, Name, (Select Id,Name,Is_Updated__c,Type__c, Email__c, Street__c, Street_2__c, City__c, State__c, Zip__c, Receive_Annual_Report__c,Receive_Company_Updates__c,Receive_Policy_Information__c,' + 
											 'Receive_PURE_Events__c,Receive_PURE_Press__c,Receive_PURE_Prevention__c,Receive_PURE_Situation_Room__c,Receive_SSA_Statements__c From Contact_Info__r Where Is_Updated__c = true )' +  
											 ' From Account Where Id =: strMemberId limit 1';
											 
			Account objAccount = (Account)database.query(strQueryAccount);
			system.debug('============objAccount ==============' + objAccount);
			return objAccount;
		}
		
		catch(Exception e)
		{
			return new Account();
		}							 
		
	}
}