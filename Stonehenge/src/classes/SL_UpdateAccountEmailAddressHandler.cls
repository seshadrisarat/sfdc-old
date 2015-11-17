/**
* @ClassName 	: SL_UpdateAccountEmailAddressHandler 
* @JIRATicket   : STONEPII-100
* @CreatedOn    : 16/july/12
* @ModifiedBy   : SL
* @Description  : This is the Handler class update the contact roles.
*/

/**
@ Shailendra
Percentage of best practices followed: 100%
No of SOQL queries used: 2 
No of collections used: 0
Exception Handling implemented: yes
Coding standards followed: Yes
Naming conventions followed: Yes 
Third party integrations: No
Maximum of No of records tested with: 
Customer Approval: 
Last Modified Date: 18/july/12
Approved by: 

*/
public with sharing class SL_UpdateAccountEmailAddressHandler 
{
	/*
		@MethodName: onBeforeUpdate 
		@param: Map of Account Id to Account object.
		@Description: update Contact role whose email is diffrent to Person account email.
	*/
	public void onBeforeUpdate(Map<Id,Account> mapAccountIdToAccount)
	{
		try{
			//Local variables.
			Map<Id,Id> mapContactIdToAccountId = new Map<Id, Id>();
			Map<Id,String> mapAccountIdToContactEmailAdd = new Map<Id,String>();
			List<Contact_Role__c> lstContactRole = new List<Contact_Role__c>(); 
			
			//Create Map between Contact id and Account Id
			for(Account objAccount : [Select PersonContactId From Account where Id IN : mapAccountIdToAccount.keySet()])
			{
				mapContactIdToAccountId.put( objAccount.PersonContactId, objAccount.Id);
			}
			
			//Create Map of Contact related with person account.
			Map<Id,Contact> mapContactIdToContact = new Map<Id,Contact>([select Id , Name, Email from contact where Id IN : mapContactIdToAccountId.keySet()]);
			
			//Map between Account Id and related Email.
			for( Id conId : mapContactIdToContact.keySet())
			{
				mapAccountIdToContactEmailAdd.put(mapContactIdToAccountId.get(conId), mapContactIdToContact.get(conId).email);
			}
			
			//Create list of Contact roles their email is diffrert with Person account.
			for(Contact_Role__c objContactRole : [select Id, Contact_Email__c, Contact__c from Contact_Role__c where Contact__c IN : mapAccountIdToAccount.keySet()])
			{
				if(objContactRole.Contact_Email__c != mapAccountIdToContactEmailAdd.get(objContactRole.Contact__c))
				{
					lstContactRole.add(objContactRole);
				}
			}
			
			//Update List Contact roles.
			if(lstContactRole.size() > 0)
				update lstContactRole;
		}
		catch(Exception e)
		{
			//do nothing
		}
	}
}