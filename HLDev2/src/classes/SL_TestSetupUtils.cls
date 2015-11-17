/**  
* \arg ClassName      : SL_Test_Relationship_Rollups
* \arg JIRATicket     : HL-15
* \arg CreatedOn      : 30/MAY/2014
* \arg LastModifiedOn : 30/MAY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for batch and schedular
*/
public with sharing class SL_TestSetupUtils 
{
	private static Map<String, object> mapJsonObjects; 
	private static map<string,ID> recordTypeIds;
	
	static
	{
		String strJson = SL_TestSetupUtils.getTestJSONFromStaticResources('SL_TestCoverageJsonData');
		mapJsonObjects = (Map<String, SObject>) JSON.deserialize(strJson, Map<String, SObject>.class);
		recordTypeIds = new map<string,ID>();
		for(RecordType rt : [select ID, DeveloperName, sObjectType from RecordType where sObjectType in :mapJsonObjects.keyset()])
		{
			recordTypeIds.put(rt.sObjectType + '-' + rt.DeveloperName,rt.ID);
		}
	}
	
	public static List<Account> CreateAccount(String basename, Integer count)
    {
    	List<Account> results = new List<Account>();
		Account objAccount = (Account) mapJsonObjects.get('Account');
				
		for(Integer x = 0; x< count; x++)
		{
			Account objTempAcc = objAccount.clone();  
			objTempAcc.Name = basename + String.valueOf(x);
			results.add(objTempAcc);
		}
    	return results;  
	}
	
	public static List<Contact> CreateContact(String basename, Integer count)
    {
		List<Contact> results = new List<Contact>();
		Contact objContact = (Contact) mapJsonObjects.get('Contact');
		
		for(Integer x = 0; x< count; x++)
		{
			Contact objContactTemp = objContact.clone(); 
			results.add(objContactTemp);
		}
    	return results;  
	}
	
	public static List<Task> CreateTask(String basename, Integer count)
	{
		List<Task> results = new List<Task>();
		Task objTask = (Task) mapJsonObjects.get('Task');
		
		for(Integer x = 0; x< count; x++)
		{
			Task objTaskTemp = objTask.clone();
			results.add(objTaskTemp);
		}
		return results;
	}
	
	public static List<Event> CreateEvent(String basename, Integer count)
	{
		List<Event> results = new List<Event>();
		Event objEvent = (Event) mapJsonObjects.get('Event');
		
		for(Integer x = 0; x< count; x++)
		{
			Event objEventTemp = objEvent.clone();
			results.add(objEventTemp);
		}
		return results;
	}
	
	public static List<Engagement__c> CreateEngagement(String basename, Integer count)
	{
		List<Engagement__c> results = new List<Engagement__c>();
		Engagement__c objEngagement = (Engagement__c) mapJsonObjects.get('Engagement__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Engagement__c objEngagementTemp = objEngagement.clone();
			objEngagementTemp.Name = basename + String.valueOf(x);
			results.add(objEngagementTemp);
		}
		return results;
	}
	
	public static List<Engagement_Internal_Team__c> CreateEIT(String basename, Integer count)
	{
		List<Engagement_Internal_Team__c> results = new List<Engagement_Internal_Team__c>();
		Engagement_Internal_Team__c objEIT = (Engagement_Internal_Team__c) mapJsonObjects.get('Engagement_Internal_Team__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Engagement_Internal_Team__c objEITTemp = objEIT.clone();
			results.add(objEITTemp);
		}
		return results;
	}
	
	public static List<Engagement_External_Team__c> CreateEET(String basename, Integer count)
	{
		List<Engagement_External_Team__c> results = new List<Engagement_External_Team__c>();
		Engagement_External_Team__c objEET = (Engagement_External_Team__c) mapJsonObjects.get('Engagement_External_Team__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Engagement_External_Team__c objEETTemp = objEET.clone();
			results.add(objEETTemp);
		}
		return results;
	}
	
	public static List<Engagement_Counterparty__c> CreateEC(String basename, Integer count)
	{
		List<Engagement_Counterparty__c> results = new List<Engagement_Counterparty__c>();
		Engagement_Counterparty__c objEC = (Engagement_Counterparty__c) mapJsonObjects.get('Engagement_Counterparty__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Engagement_Counterparty__c objECTemp = objEC.clone();
			results.add(objECTemp);
		}
		return results;
	}
	
	public static List<Engagement_Counterparty_Contact__c> CreateECC(String basename, Integer count)
	{
		List<Engagement_Counterparty_Contact__c> results = new List<Engagement_Counterparty_Contact__c>();
		Engagement_Counterparty_Contact__c objECC = (Engagement_Counterparty_Contact__c) mapJsonObjects.get('Engagement_Counterparty_Contact__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Engagement_Counterparty_Contact__c objECCTemp = objECC.clone();
			results.add(objECCTemp);
		}
		return results;
	}
	
	public static List<Opportunity__c> CreateOpp(String basename, Integer count)
	{
		List<Opportunity__c> results = new List<Opportunity__c>();
		Opportunity__c objOpp = (Opportunity__c) mapJsonObjects.get('Opportunity__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Opportunity__c objOppTemp = objOpp.clone();
			objOppTemp.Name = basename + String.valueOf(x);
			results.add(objOppTemp);
		}
		return results;
	}
	
	public static List<Opportunity_Internal_Team__c> CreateOIT(String basename, Integer count)
	{
		List<Opportunity_Internal_Team__c> results = new List<Opportunity_Internal_Team__c>();
		Opportunity_Internal_Team__c objOIT = (Opportunity_Internal_Team__c) mapJsonObjects.get('Opportunity_Internal_Team__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Opportunity_Internal_Team__c objOITTemp = objOIT.clone();
			results.add(objOITTemp);
		}
		return results;
	}
	
	public static List<Opportunity_External_Team__c> CreateOET(String basename, Integer count)
	{
		List<Opportunity_External_Team__c> results = new List<Opportunity_External_Team__c>();
		Opportunity_External_Team__c objOET = (Opportunity_External_Team__c) mapJsonObjects.get('Opportunity_External_Team__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Opportunity_External_Team__c objOETTemp = objOET.clone();
			results.add(objOETTemp);
		}
		return results;
	}
	
	public static List<Relationship__c> CreateRelationship(String basename, Integer count)
	{
		List<Relationship__c> results = new List<Relationship__c>();
		Relationship__c objRelationship = (Relationship__c) mapJsonObjects.get('Relationship__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Relationship__c objRelationshipTemp = objRelationship.clone(); 
			results.add(objRelationshipTemp);
		}
		return results;
	}
	
	public static List<Affiliation__c> CreateAffiliation(String basename, Integer count) 
	{
		List<Affiliation__c> results = new List<Affiliation__c>();
		Affiliation__c objAffiliation = (Affiliation__c) mapJsonObjects.get('Affiliation__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Affiliation__c objAffiliationTemp = objAffiliation.clone();
			results.add(objAffiliationTemp);
		}
		return results;
	}
	
	public static List<Delegate_Public_Group__c> CreateDPG(String basename, Integer count) 
	{
		List<Delegate_Public_Group__c> results = new List<Delegate_Public_Group__c>();
		Delegate_Public_Group__c objDPG = (Delegate_Public_Group__c) mapJsonObjects.get('Delegate_Public_Group__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Delegate_Public_Group__c objDPGTemp = objDPG.clone();
			results.add(objDPGTemp);
		}
		return results;
	}
	
	public static List<Delegate_Public_Group_Member__c> CreateDPGM(String basename, Integer count) 
	{
		List<Delegate_Public_Group_Member__c> results = new List<Delegate_Public_Group_Member__c>();
		Delegate_Public_Group_Member__c objDPGM = (Delegate_Public_Group_Member__c) mapJsonObjects.get('Delegate_Public_Group_Member__c');
		
		for(Integer x = 0; x< count; x++)
		{
			Delegate_Public_Group_Member__c objDPGMTemp = objDPGM.clone();
			results.add(objDPGMTemp);
		}
		return results;
	}
	
	public static List<User> CreateUser(String basename, Integer count) 
	{
		List<User> results = new List<User>();
		User objUser = (User) mapJsonObjects.get('User');
		
		for(Integer x = 0; x< count; x++)
		{
			User objUserTemp = objUser.clone();
			results.add(objUserTemp);
		}
		return results;
	}
	
	public static List<Campaign> CreateCampaign(String basename, Integer count) 
	{
		List<Campaign> results = new List<Campaign>();
		Campaign objCampaign = (Campaign) mapJsonObjects.get('Campaign');
		
		for(Integer x = 0; x< count; x++)
		{
			Campaign objCampaignTemp = objCampaign.clone();
			results.add(objCampaignTemp);
		}
		return results;
	}
	
	public static List<CampaignMember> CreateCampaignMember(String basename, Integer count) 
	{
		List<CampaignMember> results = new List<CampaignMember>();
		CampaignMember objCampaignMember = (CampaignMember) mapJsonObjects.get('CampaignMember');
		
		for(Integer x = 0; x< count; x++)
		{
			CampaignMember objCampaignMemberTemp = objCampaignMember.clone();
			results.add(objCampaignMemberTemp);
		}
		return results;
	}
	
	private static String getTestJSONFromStaticResources(String resource)
    {
     	return [SELECT body, name from StaticResource where Name =:resource].body.toString();     	
    }     
}