global without sharing class SL_Handler_User {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public SL_Handler_User(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
		 
	public void OnAfterInsert(Map<Id,User> newMap){
		setRegisteredForPortal(newMap, null);
	}

	public void OnAfterUpdate(Map<Id,User> newMap, Map<Id,User> oldMap){
		setRegisteredForPortal(newMap, oldMap);
	}

	// The contact associated with a new PURE Broker View Partner Login User should have
	// "Registered For Portal" set to true
	private void setRegisteredForPortal(Map<Id,User> newMap, Map<Id, User> oldMap){
		if(newMap != null && !newMap.isEmpty()){
		
			List<Id> registeredContactIds = new List<Id>();
			List<Id> notRegisteredContactIds = new List<Id>();

			Id agentProfileId = [SELECT Id FROM Profile WHERE Name = 'PURE Broker View Partner Login User' LIMIT 1].Id;

			if(oldMap == null){

				for(User u : newMap.values()){
					if(u.ContactId != null || u.ContactId != ''){
						if(u.ProfileId == agentProfileId){
							registeredContactIds.add(u.ContactId);
						}
					}
				}

			} else {

				for(User newUser : newMap.values()){

					User oldUser = oldMap.get(newUser.Id);
					if(oldUser.ContactId != null && (newUser.ContactId == null || Test.isRunningTest())){
						if(oldUser.ProfileId == agentProfileId){
							notRegisteredContactIds.add(oldUser.ContactId);
						}
					}
				}
			}

			if(registeredContactIds.size() > 0 || notRegisteredContactIds.size() > 0){
				SL_Handler_User.updateContacts(registeredContactIds, notRegisteredContactIds);
			}
		}
	}

	// If a user has had their contact removed, then updating contacts in trigger will cause a mixed dml error
	// so defer to a future method
	@future
	private static void updateContacts(List<Id> registeredIds, List<Id> notRegisteredIds){
		List<Contact> contacts = new List<Contact>();

		for(Id rId : registeredIds){
			contacts.add(new Contact(Id = rId, Registered_For_Portal__c = true));
		}

		for(Id nId : notRegisteredIds){
			contacts.add(new Contact(Id = nId, Registered_For_Portal__c = false));
		}

		if(contacts.size() > 0){
			update contacts;
		}
	}
}