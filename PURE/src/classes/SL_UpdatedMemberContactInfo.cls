/*
JIRA Ticket: PURE-8
Class name : SL_UpdatedMemberContactInfo
Developer  : Pradeep
Created on : 19/Mar/2014
Description: Fetches the Contact Inforation of a Member that updated via community
*/
public with sharing class SL_UpdatedMemberContactInfo 
{
	/*	START : Global variables	 */
	public String strMemberId		                                {get;set;}
	public String fullUrl		                                    {get;set;}
	
	public Map<String, String> mapOldAndNewAddressFieldMappings		{get;set;}
	public Map<String, String> mapAPINameToLabel					{get;set;}
	public string strMailingAddrOld                                 {get;set;}
	public string strMailingAddrNew                                 {get;set;}
	public string strBillingAddrOld                                 {get;set;}
	public string strBillingAddrNew                                 {get;set;}
	public string strEmailAddrOld                                   {get;set;}
	public string strEmailAddrNew                                   {get;set;}
	public string strPhoneAddrOld                                   {get;set;}
	public string strPhoneAddrNew                                   {get;set;}
	//public list<Contact_Info__c> lstPrimUpdatedContInfo;
	
	/*	END : Global variables	 */
	
	//	Constructor
	public SL_UpdatedMemberContactInfo()
	{
		mapOldAndNewAddressFieldMappings = new Map<String, String>();
		mapAPINameToLabel = new Map<String, String>();
		//lstPrimUpdatedContInfo = new list<Contact_Info__c>();
		
		//	Fetches all the field mappings between old and new address
		for(SL_FieldMappings_OldANDNewAddress__c objCS : SL_FieldMappings_OldANDNewAddress__c.getAll().values())
			mapOldAndNewAddressFieldMappings.put(objCS.Name, objCS.Related_Old_Filed__c);
			
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
			//	Dynamic query formation for querying Account and related Contact Info records
			String strQueryAccount = 'Select Id,Member_Key_EDW__c, Name, (Select Id, Type__c ,Was_Last_Primary__c,Is_Updated__c,Is_Primary__c, Name, ';
			for(Schema.FieldSetMember field : SObjectType.Contact_Info__c.FieldSets.SL_AddressFileds.getFields())
			{
				if(field.getFieldPath() != 'Id' && field.getFieldPath() != 'Name')
				{
					strQueryAccount += field.getFieldPath() + ', '; 
					mapAPINameToLabel.put(field.getFieldPath(), field.getLabel());
				}
			}
			strQueryAccount = strQueryAccount.removeEnd(', ');
			strQueryAccount += ' From Contact_Info__r Where Is_Updated__c = true ) From Account Where Id =: strMemberId limit 1'; 
			
			Account objAccount = (Account)database.query(strQueryAccount);
			return objAccount;
		}
		catch(Exception e)
		{
			return new Account();
		}
	}
	
	public list<Contact_Info__c> getlstPrimUpdatedContInfo()
	{
		//list<Contact_Info__c> lstContInfoToUpdateIsPrimChangedFlag = new list<Contact_Info__c>();
		list<Contact_Info__c> lstPrimUpdatedContInfo = new list<Contact_Info__c>();
		
		list<Contact_Info__c> lstPrimAndLasPrimContInfo = [ Select Type__c,Is_Primary__c,Was_Last_Primary__c,Street__c,Street_2__c,Zip__c,State__c,City__c,Account__c,Email__c,Phone__c,Is_Primary_Changed__c
														    from Contact_Info__c
														    where Account__c = :strMemberId AND Is_Primary_Changed__c = true
														  ];
														  
		system.debug('=====lstPrimAndLasPrimContInfo=========' + lstPrimAndLasPrimContInfo);		
		
		/*Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    	String[] toAddresses = new String[] {'sandeep@silverlinecrm.com'}; 
		email.setToAddresses(toAddresses);  
		email.setHtmlBody('========='+lstPrimAndLasPrimContInfo.size()+ ' ' + strMemberId);
		  
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });*/    
												  
														 
		for(Contact_Info__c objContInfo : lstPrimAndLasPrimContInfo)
		{
			if( objContInfo.Type__c == 'Mailing')
			{
				if(objContInfo.Is_Primary__c)	
				{
         			lstPrimUpdatedContInfo.add(objContInfo);
         			strMailingAddrNew = (objContInfo.Street__c != null ? objContInfo.Street__c + ', ': '') + (objContInfo.Street_2__c != null ? ' ' + objContInfo.Street_2__c + ', ' : '') + (objContInfo.City__c != null ? objContInfo.City__c + ', ' : '') + (objContInfo.State__c != null ? objContInfo.State__c + ', ': '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c + ', ': '');
				}	
         	
         		if(objContInfo.Was_Last_Primary__c)
         			strMailingAddrOld = (objContInfo.Street__c != null ? objContInfo.Street__c + ', ': '') + (objContInfo.Street_2__c != null ? ' ' + objContInfo.Street_2__c + ', ' : '') + (objContInfo.City__c != null ? objContInfo.City__c + ', ' : '') + (objContInfo.State__c != null ? objContInfo.State__c + ', ': '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c + ', ': '');
			}
			
			if( objContInfo.Type__c == 'Billing')
			{
				if(objContInfo.Is_Primary__c)
				{	
         			strBillingAddrNew = (objContInfo.Street__c != null ? objContInfo.Street__c + ', ': '') + (objContInfo.Street_2__c != null ? ' ' + objContInfo.Street_2__c + ', ' : '') + (objContInfo.City__c != null ? objContInfo.City__c + ', ' : '') + (objContInfo.State__c != null ? objContInfo.State__c + ', ': '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c + ', ': '');
         			lstPrimUpdatedContInfo.add(objContInfo);
				}	
         	
         		if(objContInfo.Was_Last_Primary__c)
         			strBillingAddrOld = (objContInfo.Street__c != null ? objContInfo.Street__c + ', ': '') + (objContInfo.Street_2__c != null ? ' ' + objContInfo.Street_2__c + ', ' : '') + (objContInfo.City__c != null ? objContInfo.City__c + ', ' : '') + (objContInfo.State__c != null ? objContInfo.State__c + ', ': '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c + ', ': '');
			}
			
			if( objContInfo.Type__c == 'Email')
			{
				if(objContInfo.Is_Primary__c)	
				{
			       strEmailAddrNew = objContInfo.Email__c;
			       lstPrimUpdatedContInfo.add(objContInfo);
				}   
			      
			    if(objContInfo.Was_Last_Primary__c)  	
			    	strEmailAddrOld = objContInfo.Email__c;
			}
			
			if( objContInfo.Type__c == 'Phone-Home' || objContInfo.Type__c == 'Phone-Work' || objContInfo.Type__c == 'Phone-Mobile' )
			{
				if(objContInfo.Is_Primary__c)	
				{
			       strPhoneAddrNew = objContInfo.Phone__c;
			       lstPrimUpdatedContInfo.add(objContInfo);
				}   
			      
			    if(objContInfo.Was_Last_Primary__c)  	
			    	strPhoneAddrOld = objContInfo.Phone__c; 
			}
			
			objContInfo.Is_Primary_Changed__c = false;
            //lstContInfoToUpdateIsPrimChangedFlag.add(objContInfo);		
            
		}	
		//Database.update(lstContInfoToUpdateIsPrimChangedFlag,false);
		
		return lstPrimUpdatedContInfo;
	}
}