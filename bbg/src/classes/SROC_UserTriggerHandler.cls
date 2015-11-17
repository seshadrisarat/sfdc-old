public without sharing class SROC_UserTriggerHandler {
	
	private SROC_System_Settings__c objSS;
	private static final string CUSTOM_SETTING_INSTANCE_NAME = 'SROC'; 
	private map<Id,User> map_toUpdatePA; //maps person account Id to person account 
	private map<Id,User> map_toUpdateContact; //maps cpntact Id to Contact
	
	private Id ownerCCLProfileId;
	private Id ownerCCUProfileId;
	private Id dealerCCUProfileId;
	private Id dealerCCLProfileId;
	//Constructor
	public SROC_UserTriggerHandler() {
		
		//Getting thee values from the SROC_System_Settings__c custom object for Profile Id comparision
		objSS = SROC_System_Settings__c.getValues(CUSTOM_SETTING_INSTANCE_NAME);
		map_toUpdatePA = new map<Id,User>();
		map_toUpdateContact = new map<Id,User>();
		assignProfileIds();
	}

	
	private void assignProfileIds() {
		
		try {
			ownerCCLProfileId = (Id)objSS.Owner_CCL_Profile_Id__c;
		}catch(Exception e){
			ownerCCLProfileId = '';
		}
		
		try {
			ownerCCUProfileId = (Id)objSS.Owner_CCU_Profile_Id__c;
		}catch(Exception e){
			ownerCCUProfileId = '';
		}
		
		try {
			dealerCCUProfileId = (Id)objSS.Dealer_CCU_Profile_Id__c;
		}catch(Exception e){
			dealerCCUProfileId = '';
		}
		
		try {
			dealerCCLProfileId = (Id)objSS.Dealer_CCL_Profile_Id__c;
		}catch(Exception e){
			dealerCCLProfileId = '';
		}
		
	}
	
	//Methods to default some user values
	public void onBeforeInsert(List<User> userList) {
		
		for(User u : userList)
		{
			
			if(u.ProfileId == ownerCCLProfileId || u.ProfileId == ownerCCUProfileId || u.ProfileId == dealerCCLProfileId || u.ProfileId == dealerCCUProfileId)
			{
				u.FirstName_Privacy__c = 'Private';
            	u.LastName_Privacy__c = 'Private';
            	u.Birthdate_Privacy__c = 'Private';
            	u.Spouse_Privacy__c = 'Private';
            	u.Number_of_Children_Privacy__c = 'Private';
            	u.Boating_Experience_Privacy__c = 'Private';
            	u.Profession_Privacy__c = 'Private';
            	u.Industry_Privacy__c = 'Private';
            	u.MobilePhone_Privacy__c = 'Private';
            	u.Email_Privacy__c = 'Private';
            	u.CORECONNECT__CC_List_In_Directory__c = true;
            	u.Receive_Event_Invitations__c = true;
			}
			
			if((u.ProfileId == ownerCCLProfileId || u.ProfileId == ownerCCUProfileId) && (u.CORECONNECT__Classification1__c == null || u.CORECONNECT__Classification1__c == ''))
			{
				u.CORECONNECT__Classification1__c = 'Owner';
			}
			
			if((u.ProfileId == dealerCCLProfileId || u.ProfileId == dealerCCUProfileId) && (u.CORECONNECT__Classification1__c == null || u.CORECONNECT__Classification1__c == ''))
			{
				u.CORECONNECT__Classification1__c = 'Dealer';
			}
			
		}
			
                                                
	}
	
	//Method to update the related person account or dealer contact when a community user is inserted
	public void onAfterInsert( map<Id,User> newMap) {

		for(User objUser : newMap.values()) {

			//Checking if the User has Ower CCU or Owner CCl profiles
			if((objUser.ProfileId == ownerCCLProfileId  || objUser.ProfileId == ownerCCUProfileId) && objUser.AccountId != Null) {

				map_toUpdatePA.put(objUser.AccountId,objUser);
			}
			//Checking if the User has Dealer CCU or Dealer CCl profiles
			else if((objUser.ProfileId == objSS.Dealer_CCL_Profile_Id__c || objUser.ProfileId == objSS.Dealer_CCU_Profile_Id__c) && objUser.ContactId != Null) {

				map_toUpdateContact.put(objUser.ContactId,objUser);			}
		}

		if(!map_toUpdatePA.IsEmpty())
			updatePersonAccounts(map_toUpdatePA,'Insert');	

		if(!map_toUpdateContact.IsEmpty())
			updateContacts(map_toUpdateContact);
	}

	//Method to update the related person account or dealer contact when a community user is updated
	public void onAfterUpdate( map<Id,User> oldMap , map<Id,User> newMap) {

		for(User objUser : newMap.values()) {

			//Checking if the User has Ower CCU or Owner CCl profiles and if certain fields are  updated
			if((objUser.ProfileId == ownerCCLProfileId || objUser.ProfileId == ownerCCUProfileId) && objUser.AccountId != Null
				    && ((objUser.FirstName != oldMap.get(objUser.id).FirstName) || (objUser.LastName != oldMap.get(objUser.id).LastName) || (objUser.Email != oldMap.get(objUser.id).Email) 
					|| (objUser.Street != oldMap.get(objUser.id).Street) || (objUser.City != oldMap.get(objUser.id).City) || (objUser.State != oldMap.get(objUser.id).State) 
					|| (objUser.Country != oldMap.get(objUser.id).Country)|| (objUser.PostalCode != oldMap.get(objUser.id).PostalCode) || (objUser.MobilePhone != oldMap.get(objUser.id).MobilePhone) 
					|| (objUser.Phone != oldMap.get(objUser.id).Phone)  || (objUser.Birthdate__c != oldMap.get(objUser.id).Birthdate__c) || (objUser.Title != oldMap.get(objUser.id).Title))) {

				map_toUpdatePA.put(objUser.AccountId,objUser);
			}
			//Checking if the User has Dealer CCU or Dealer CCl profiles and if certain fields are  updated
			else if((objUser.ProfileId == dealerCCLProfileId || objUser.ProfileId == dealerCCUProfileId) && objUser.ContactId != Null 
				    && ((objUser.FirstName != oldMap.get(objUser.id).FirstName) || (objUser.LastName != oldMap.get(objUser.id).LastName) || (objUser.Email != oldMap.get(objUser.id).Email) 
					|| (objUser.Street != oldMap.get(objUser.id).Street) || (objUser.City != oldMap.get(objUser.id).City) || (objUser.State != oldMap.get(objUser.id).State) 
					|| (objUser.Country != oldMap.get(objUser.id).Country)|| (objUser.PostalCode != oldMap.get(objUser.id).PostalCode) || (objUser.MobilePhone != oldMap.get(objUser.id).MobilePhone) 
					|| (objUser.Phone != oldMap.get(objUser.id).Phone)  || (objUser.Birthdate__c != oldMap.get(objUser.id).Birthdate__c) || (objUser.Title != oldMap.get(objUser.id).Title))) {

				map_toUpdateContact.put(objUser.ContactId,objUser);
			}
		}

		if(!map_toUpdatePA.IsEmpty())
			updatePersonAccounts(map_toUpdatePA,'Update');	

		if(!map_toUpdateContact.IsEmpty())
			updateContacts(map_toUpdateContact);
		
	}

	//method to fetch the related person account for user and update
	private void updatePersonAccounts(map<Id,User> map_toUpdatePA,String strTriggerEvent) {

		map<Id,Account> mapPersonAccountsToUpdatePreferredDealer = new map<Id,Account>();
		map<Id,Account> mapAccountIdtoAccount = new map<Id,Account>();
		list<Account> lstUpdatedPAwithexistingDealer = new list<Account>();

		for(Account objPA : [SELECT Id,FirstName,LastName,PersonEmail,PersonMailingStreet,PersonMailingCity,PersonMailingState,
							 		PersonMailingCountry,PersonMailingPostalCode,PersonMobilePhone,PersonHomePhone,
							 		PersonBirthdate,PersonTitle,SROC_Preferred_Dealer__c
							 FROM Account 
							 WHERE  Id =: map_toUpdatePA.keyset()
							 AND IsPersonAccount = true]) {

			mapAccountIdtoAccount.put(objPA.id,objPA);
		}

		try {

			for(User objUser : map_toUpdatePA.values()) {

				if(mapAccountIdtoAccount.containsKey(objUser.AccountId)) {

					Account objPAtoUpdate = mapAccountIdtoAccount.get(objUser.AccountId);

					if(checkNotEmpty(objUser.FirstName))
						objPAtoUpdate.FirstName = objUser.FirstName;

					if(checkNotEmpty(objUser.LastName))
						objPAtoUpdate.LastName = objUser.LastName;

					if(checkNotEmpty(objUser.Email))
						objPAtoUpdate.PersonEmail = objUser.Email;

					if(checkNotEmpty(objUser.Street))
						objPAtoUpdate.PersonMailingStreet = objUser.Street;

					if(checkNotEmpty(objUser.City))
						objPAtoUpdate.PersonMailingCity = objUser.City;

					if(checkNotEmpty(objUser.State))
						objPAtoUpdate.PersonMailingState = objUser.State;

					if(checkNotEmpty(objUser.Country))
						objPAtoUpdate.PersonMailingCountry = objUser.Country;

					if(checkNotEmpty(objUser.PostalCode))
						objPAtoUpdate.PersonMailingPostalCode = objUser.PostalCode;

					if(checkNotEmpty(objUser.MobilePhone))
						objPAtoUpdate.PersonMobilePhone = objUser.MobilePhone;

					if(checkNotEmpty(objUser.Phone))
						objPAtoUpdate.PersonHomePhone = objUser.Phone;

					if(checkNotEmpty(String.valueof(objUser.Birthdate__c)))
						objPAtoUpdate.PersonBirthdate = objUser.Birthdate__c;

					if(checkNotEmpty(objUser.Title))
						objPAtoUpdate.PersonTitle = objUser.Title;

					if(objPAtoUpdate.SROC_Preferred_Dealer__c == Null && strTriggerEvent == 'Insert') {

						if(checkNotEmpty(objPAtoUpdate.PersonMailingPostalCode))
							mapPersonAccountsToUpdatePreferredDealer.put(objPAtoUpdate.Id,objPAtoUpdate);
					}
					else {
						
						lstUpdatedPAwithexistingDealer.add(objPAtoUpdate);	
					}
				}
				//updateAccountWithAssociatedUser(JSON.serialize(lstUpdatedPAwithexistingDealer));
				update lstUpdatedPAwithexistingDealer;

				if(!mapPersonAccountsToUpdatePreferredDealer.IsEmpty())
					processInBatches(mapPersonAccountsToUpdatePreferredDealer);
			}
		}
		catch(Exception ex) {
         
             system.debug('Exception:'+ex.getMessage());
        }
	}
	
	/*@future
	private static void updateAccountWithAssociatedUser(String accountList){
		List<Account> lstToUpdate = (List<Account>)JSON.deserialize(accountList, List<Account>.class);
		
		update lstToUpdate;
	}*/

	//method to fetch the related contact  for user and update
	private void updateContacts(map<Id,User> map_toUpdateContact) {

		list<Contact> lstContactsToUpdate = new list<Contact>();
		map<Id,Contact> mapContactIdtoContact = new map<Id,Contact>();
		Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();

			for(Contact objContact : [SELECT FirstName,LastName,Email,MailingStreet,MailingCity,MailingState,
								 	  MailingCountry,MailingPostalCode,MobilePhone,HomePhone,
								 	  Birthday__c,Title 
									  FROM Contact 
									  WHERE  Id =: map_toUpdateContact.keyset()
									  AND RecordTypeId =:devRecordTypeId]) {

				mapContactIdtoContact.put(objContact.id,objContact);
			}

		try {

			for(User objUser : map_toUpdateContact.values()) {

				if(mapContactIdtoContact.containsKey(objUser.ContactId)) {

					Contact objContacttoUpdate = mapContactIdtoContact.get(objUser.ContactId);

					if(checkNotEmpty(objUser.FirstName))
						objContacttoUpdate.FirstName = objUser.FirstName;

					if(checkNotEmpty(objUser.LastName))
						objContacttoUpdate.LastName = objUser.LastName;

					if(checkNotEmpty(objUser.Email))
						objContacttoUpdate.Email = objUser.Email;

					if(checkNotEmpty(objUser.Street))
						objContacttoUpdate.MailingStreet = objUser.Street;

					if(checkNotEmpty(objUser.City))
						objContacttoUpdate.MailingCity = objUser.City;

					if(checkNotEmpty(objUser.State))
						objContacttoUpdate.MailingState = objUser.State;

					if(checkNotEmpty(objUser.Country))
						objContacttoUpdate.MailingCountry = objUser.Country;

					if(checkNotEmpty(objUser.PostalCode))
						objContacttoUpdate.MailingPostalCode = objUser.PostalCode;

					if(checkNotEmpty(objUser.MobilePhone))
						objContacttoUpdate.MobilePhone = objUser.MobilePhone;

					if(checkNotEmpty(objUser.Phone))
						objContacttoUpdate.HomePhone = objUser.Phone;

					if(checkNotEmpty(String.valueof(objUser.Birthdate__c)))
						objContacttoUpdate.Birthday__c = objUser.Birthdate__c;

					if(checkNotEmpty(objUser.Title))
						objContacttoUpdate.Title = objUser.Title;

					lstContactsToUpdate.add(objContacttoUpdate);
				}

				update 	lstContactsToUpdate;
			}
		}
		catch(Exception ex) {
         
             system.debug('Exception:'+ex.getMessage());
        }
	}

	//method to check if passed filed value is empty or not
	private boolean checkNotEmpty(string fieldvalue) {

		return String.isNotEmpty(fieldvalue);
	}

	//method to group Person Accounts
	private void processInBatches(map<Id,Account> mapPersonAccount)
	{
		Integer counterTotal = 0;
		map<Id,Account> tmp_mapPersonAccount = new map<Id,Account>();
		for(Account objPA : mapPersonAccount.values()) {
			counterTotal++;
			tmp_mapPersonAccount.put(objPA.Id, objPA);

			if(tmp_mapPersonAccount.keySet().size() == 100 || counterTotal == mapPersonAccount.keySet().size()) {

				updatePersonAccountWithDealer(JSON.serialize(tmp_mapPersonAccount.values()));
				tmp_mapPersonAccount = new map<Id,Account>();
			}	
		}	
	}

	@Future(callout=true)
	private static void updatePersonAccountWithDealer(String strSerialisedPA) {

		set<String> setPostalCode = new set<String>();
		set<String> setvalidPostalCode = new set<String>();
		list<Account> lstPAtoUpdate = (List<Account>)JSON.deserialize(strSerialisedPA, List<Account>.class);
		map<String,String> mapPostalCodeToPrefferdDealer = new map<String,String>();
		for(Account objAccount : lstPAtoUpdate) {

			setPostalCode.add(objAccount.PersonMailingPostalCode);
		}

		for(String strPostalCode : setPostalCode) {

			ApexPages.StandardSetController obj = SROCUtilities.queryDealersNear(strPostalCode, 100);
			if(obj != NULL && !obj.getRecords().IsEmpty()) {

				mapPostalCodeToPrefferdDealer.put(strPostalCode,obj.getRecords()[0].Id);
			}
		}
		
		for(Account objAccount : lstPAtoUpdate) {
			
			objAccount.SROC_Preferred_Dealer__c = mapPostalCodeToPrefferdDealer.containsKey(objAccount.PersonMailingPostalCode) ? mapPostalCodeToPrefferdDealer.get(objAccount.PersonMailingPostalCode) : Null;
		}
		update lstPAtoUpdate;
	}

}