/**
* @ClassName 	: SL_ChangeContactRoleEmailAddressHandler 
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

public with sharing class SL_ChangeContactRoleEmailAddressHandler 
{
	/*
		@MethodName: onInsertAndUpdate 
		@param: List of Contact Role
		@Description: Update the email with related Person Account.
	*/
	public void onInsertAndUpdate(List<Contact_Role__c> lstCR)
	{
		try{
			//local variables
			Set<String> setContactId = new Set<String>();
			Map<Id,List<Contact_Role__c>> mapAccountIdToListConactRole = new Map<Id,List<Contact_Role__c>>();
			Map<Id,String> mapAccountIdToContactEmailAdd = new Map<Id,String>();
			Map<Id,Id> mapContactIdToAccountId = new Map<Id,Id>();
			
			//Create Map of AccountId and List of Contact Role associated with one Account
			for(Contact_Role__c objContactRole : lstCR) 
			{
				//If Account Id is not in Map
				if(mapAccountIdToListConactRole.get(objContactRole.Contact__c) == null)
				{
					List<Contact_Role__c> lstContactRole = new List<Contact_Role__c>();
					lstContactRole.add(objContactRole);
					mapAccountIdToListConactRole.put(objContactRole.Contact__c, lstContactRole);
				}
				else
				{
					mapAccountIdToListConactRole.get(objContactRole.Contact__c).add(objContactRole);
				}
			}
			
			//Create Map between Contact id and Account Id
			for(Account objAccount : [Select PersonContactId From Account where Id IN : mapAccountIdToListConactRole.keySet()])
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
			
			//Update the Email of Contact role with related account email
			for(Id accId : mapAccountIdToListConactRole.keySet())
			{
				for(Contact_Role__c objContactRole: mapAccountIdToListConactRole.get(accId))
				{
					objContactRole.Contact_Email__c = mapAccountIdToContactEmailAdd.get(accId);
				}
			}
		}
		catch(Exception e)
		{
			//do nothing
		}
	}
	
	//Test Method .
	static testMethod void Test_SL_ChangeContactRoleEmailAddressHandler() 
    {
		Account objAcc1 = new Account(FirstName = 'T', PersonEmail = 'mail.trekbin@rediffmail.com', Postal_Code__c = '457896', Country__c = 'United States', State1__c = 'Hawaii', City__c = 'Hawaii', Address__c = 'Hawaii', LastName = 'Test Account 001' );
 		insert objAcc1;
 		Opportunity objOpp1 = new Opportunity(Lease_End_Date__c = system.today().addDays(60), Name = 'Test Opportunity 001', StageName = 'Appointments', CloseDate = date.today(), AccountId = objAcc1.Id);
 		insert objOpp1;
 		
 		List<Contact_Role__c> lstCR = new List<Contact_Role__c>(); 
 		lstCR.add(new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Tenant'));
 		insert lstCR;
 		
 		objAcc1.PersonEmail = 'test@test.com';
 		update objAcc1;
    }
}