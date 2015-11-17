/**
ClassName 		: SL_AddRemoveWGUserOnProjectCtrl
JIRA Ticket 	: AMSEC-563
CreatedOn 		: 18/Sept/15
LastModifiedOn  : 22/Sept/15
CreatededBy 	: Praful Gadge
ModifiedBy 		: Praful Gadge
Description 	: To create Add/Remove Me button on Project detail page as an inline vf page
*/
public with sharing class SL_AddRemoveWGUserOnProjectCtrl {
 
	// To update button lable to Add/Remove Me
	public String getButtonLabel() {	return isAddMe ? 'Add Me' : 'Remove Me';	}

	private Boolean isAddMe; // To check the Add/Remove Me
	private String strProjectId; // To get the project id
	private List<Contact> lstContacts; // To get the associated contacts
	private List<External_Working_Group_Member__c> lstWGMembers; // To get the list of working group members

	public SL_AddRemoveWGUserOnProjectCtrl(ApexPages.StandardController ctrl) {

		isAddMe = true;

		strProjectId = ctrl.getId(); 

		lstWGMembers = new List<External_Working_Group_Member__c>();

		lstContacts = [SELECT Id FROM Contact WHERE Salesforce_User__c =: UserInfo.getUserId()];

		if(!lstContacts.isEmpty()){
			for(External_Working_Group_Member__c objWGM : [SELECT Id, End_Date__c, Initial_Participation_Date__c
															 FROM External_Working_Group_Member__c
															WHERE AS_Project__c =: strProjectId
															  AND Contact__c =: lstContacts[0].Id
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
															AS_Project__c = strProjectId
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