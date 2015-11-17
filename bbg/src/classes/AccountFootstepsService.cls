public with sharing class AccountFootstepsService extends FootstepsService {
	
	@future (callout=true)  
    public static void sendToFootsteps(Set<ID> ownerIds)
    {
    	AccountFootstepsService footStepsService = new AccountFootstepsService();
		footStepsService.footstepsFieldsMakeCallout(ownerIds);
    }
    
    @future (callout=true)  
    public static void sendToFootsteps(string jsonInput) {
    	AccountFootstepsService footStepsService = new AccountFootstepsService();
    	
    	map<Id, set<Id>> jsonMap = (map<Id, set<Id>>)JSON.deserialize(jsonInput, map<Id, set<Id>>.class);
    	if (jsonMap != null && !jsonMap.isEmpty()) {
    		system.debug('Received a json map of size = ' + jsonMap.size());
			footStepsService.footstepsFieldsMakeCallout(jsonMap);
    	}
    	else {
    		system.debug('Received empty json map for input - ' + jsonInput);
    	}
    }
	
	protected override List<FootstepsModel> getFootstepsModelsFrom(map<Id, set<Id>> idToDealerIdMap) {
		List<FootstepsModel> models = new List<FootstepsModel>();
		
		set<Id> ids = idToDealerIdMap.keySet();
		List<Account> accounts = [
			select FirstName, LastName, CreatedDate, LastModifiedDate, Industry, PersonEmail, Boat_Year_of_Interest__pc, 
				Brand_Interest__pc, Boat_Model_Interest__pc, Email_Opt_in_Display__pc,
				Boat_Category_of_Interest__pc, PersonMailingStreet, PersonMailingCity, PersonMailingPostalCode,
				PersonMailingState, PersonMailingCountry, Best_Time_to_Contact__pc, Preferred_method_of_contact__pc,
				Comments__pc, PersonLeadSource, Lead_Form_Name__pc, Brand__c, 
				PersonHasOptedOutOfEmail, Spouse__c, Occupation_Title__c, Company__c, 
				Birthday__pc, Buying_horizon__pc, First_Time_Boat_Owner__pc, 
				Hull_Identification_Number_HIN__pc, Phone, Best_Phone__pc, Trade_In_Model__pc, 
				Trade_In_Year__pc, Trade_In_Comments__pc, pi__score__pc, Notes__pc,
				Assigned_Dealer_1__r.CRM_System__c, 
				Assigned_Dealer_2__r.CRM_System__c, 
				Assigned_Dealer_3__r.CRM_System__c, 
				Assigned_Dealer_4__r.CRM_System__c, 
				Assigned_Dealer_5__r.CRM_System__c, 
				Assigned_Dealer_6__r.CRM_System__c, 
				Assigned_Dealer_7__r.CRM_System__c, 
				Assigned_Dealer_8__r.CRM_System__c, 
				Assigned_Dealer_9__r.CRM_System__c, 
				Assigned_Dealer_10__r.CRM_System__c,
				Assigned_Dealer_1__r.Dealer_Number__c, 
				Assigned_Dealer_2__r.Dealer_Number__c, 
				Assigned_Dealer_3__r.Dealer_Number__c, 
				Assigned_Dealer_4__r.Dealer_Number__c, 
				Assigned_Dealer_5__r.Dealer_Number__c, 
				Assigned_Dealer_6__r.Dealer_Number__c, 
				Assigned_Dealer_7__r.Dealer_Number__c, 
				Assigned_Dealer_8__r.Dealer_Number__c, 
				Assigned_Dealer_9__r.Dealer_Number__c, 
				Assigned_Dealer_10__r.Dealer_Number__c,
				Assigned_Dealer_1__r.id, 
				Assigned_Dealer_2__r.id, 
				Assigned_Dealer_3__r.id, 
				Assigned_Dealer_4__r.id, 
				Assigned_Dealer_5__r.id, 
				Assigned_Dealer_6__r.id, 
				Assigned_Dealer_7__r.id, 
				Assigned_Dealer_8__r.id, 
				Assigned_Dealer_9__r.id, 
				Assigned_Dealer_10__r.id
			from Account
			where Id in :ids
		];
		
		Map<Id, List<Owner_Boat_Relationship__c>> boatOwnerToOwnedBoats = new Map<Id, List<Owner_Boat_Relationship__c>>();
		for (Owner_Boat_Relationship__c obr : 
				[select Hin_Number__r.name, owner__r.id, Hin_Number__r.brand_del__c, Hin_Number__r.boat_class__c, Hin_Number__r.model_year__c, Hin_Number__r.boat_model__c, status__c
				 from Owner_Boat_relationship__c
				 where owner__r.id in :ids]) {
			if (boatOwnerToOwnedBoats.containsKey(obr.owner__r.id)) {
				boatOwnerToOwnedBoats.get(obr.owner__r.id).add(obr);
			}
			else {
				boatOwnerToOwnedBoats.put(obr.owner__r.id, new List<Owner_Boat_Relationship__c>{obr});
			}	 	
		}
		
		for (Account a: accounts) {
			set<Id> dealerIds = idToDealerIdMap.get(a.Id);
			if (boatOwnerToOwnedBoats.containsKey(a.id)) {
				models.add(new FootStepsModel(a, boatOwnerToOwnedBoats.get(a.id), dealerIds));
			}
			else {
				models.add(new FootStepsModel(a, dealerIds));
			}
			
		}
		return models;
	}

}