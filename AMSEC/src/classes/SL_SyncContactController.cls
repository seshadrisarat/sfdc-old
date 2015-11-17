/*
ClassName 		: SL_SyncContactController
JIRA Ticket 	: AMSEC-578
CreatedOn 		: 22/Sept/15
LastModifiedOn  : 22/Sept/15
CreatededBy 	: Praful Gadge
ModifiedBy 		: Praful Gadge
Description 	: To create Sync Contact button on contact detail page as an inline vf page
*/
public with sharing class SL_SyncContactController {

	public String getIsSyncContact() { return isSyncContact ? 'Un-Sync Contact' : 'Sync Contact'; }

	private String strContactId;
	private List<User> lstUserContact;
	private Boolean isSyncContact;
	private List<Outlook_Sync__c> lstOSToInsert = new List<Outlook_Sync__c>();

	public SL_SyncContactController(ApexPages.StandardController stdCtrl) {

		isSyncContact = false;

		strContactId = stdCtrl.getId();

		lstUserContact = [SELECT Contact_ID__c FROM User WHERE Id =: UserInfo.getUserId()];

		if(!lstUserContact.isEmpty()){
			for(Outlook_Sync__c objOS : [SELECT Id
										   FROM Outlook_Sync__c
										  WHERE Contact__c =: strContactId
										    AND AS_Person__c =: lstUserContact[0].Contact_ID__c]){

				lstOSToInsert.add(objOS);

				if(objOS != null)
					isSyncContact = true;
			}
		}

	}

	public void syncContact(){

		if(!isSyncContact){
			if(!lstUserContact.isEmpty()){
				if(lstOSToInsert.isEmpty()){
					lstOSToInsert.add(new Outlook_Sync__c(Contact__c = strContactId, AS_Person__c = lstUserContact[0].Contact_ID__c));

					if(!lstOSToInsert.isEmpty())
						insert lstOSToInsert;	
				}
			}	
		}else{
			if(!lstOSToInsert.isEmpty())
				delete lstOSToInsert;	
		}

	}
}