/**
ClassName 		: SL_AddRemoveWGUserOnAccountCtrl
JIRA Ticket 	: AMSEC-565
CreatedOn 		: 18/Sept/15
LastModifiedOn  : 22/Sept/15
CreatededBy 	: Praful Gadge
ModifiedBy 		: Praful Gadge
Description 	: To create Add/Remove Me button on Account detail page as an inline vf page where recordType is Portfolio_Company
*/
public with sharing class SL_AddRemoveWGUserOnAccountCtrl {

	// To update button lable to Add/Remove Me
	public String getButtonLabel() {	return isAddMe ? 'Add Me' : 'Remove Me';	}

	private Boolean isAddMe; // To check the Add/Remove Me
	private String strAccountId; // To get the account id
	private List<Contact> lstContacts; // To get the associated contacts
	private List<External_Working_Group_Member__c> lstWGMembers; // To get the list of working group members

	public SL_AddRemoveWGUserOnAccountCtrl(ApexPages.StandardController ctrl) {

		isAddMe = true;

		strAccountId = ctrl.getId(); 

		lstWGMembers = new List<External_Working_Group_Member__c>();

		lstContacts = [SELECT Id FROM Contact WHERE Salesforce_User__c =: UserInfo.getUserId()];

		if(!lstContacts.isEmpty()){
			for(External_Working_Group_Member__c objWGM : [SELECT Id, Initial_Participation_Date__c, End_Date__c
															FROM External_Working_Group_Member__c
														   WHERE Contact__c =: lstContacts[0].Id
														     AND Company__c =: strAccountId
														ORDER BY CreatedDate DESC LIMIT 1]){
				lstWGMembers.add(objWGM);

				//If they are a working group member AND the End_Date__c isblank, the Button Text should display Remove Me
				if(objWGM.End_Date__c == null){
					isAddMe = false;
				}
			}
		}
		
	}

	public void addRemoveMe(){

		if(isAddMe){
			if(!lstContacts.isEmpty()){
				if(lstWGMembers.isEmpty()){
					External_Working_Group_Member__c objWGMembersToInsert = new External_Working_Group_Member__c(
															Contact__c = lstContacts[0].Id, 
															Initial_Participation_Date__c = System.today(),
															Company__c = strAccountId
														);

					insert objWGMembersToInsert;
				}else{
					for(External_Working_Group_Member__c objWGMember : lstWGMembers){
						objWGMember.End_Date__c = null;
					}
					if(!lstWGMembers.isEmpty())
						update lstWGMembers;
				}
			}	
		}else{
			if(!lstContacts.isEmpty()){
				if(!lstWGMembers.isEmpty()){
					for(External_Working_Group_Member__c objWGMember : lstWGMembers){
						objWGMember.End_Date__c = System.today();
					}
					if(!lstWGMembers.isEmpty())
						update lstWGMembers;
				}
			}
		}
	}
	
}