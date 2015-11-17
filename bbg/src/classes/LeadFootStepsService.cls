public with sharing class LeadFootStepsService extends FootstepsService {
	
	@future (callout=true)  
    public static void sendToFootsteps(Set<ID> leadIds)
    { 
    	LeadFootStepsService footStepsService = new LeadFootStepsService();
		footStepsService.footstepsFieldsMakeCallout(leadIds);
    }
    
    @future (callout=true)  
    public static void sendToFootsteps(string jsonInput) {
    	LeadFootStepsService footStepsService = new LeadFootStepsService();
    	
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
		
		List<Lead> leads = [
			select FirstName, LastName, CreatedDate, LastModifiedDate, Industry, Email, Boat_Year_Interest__c, 
				Brand_Interest__c, Boat_Model_Interest__c, Email_Opt_in__c,
				Boat_Category_of_Interest__c, Street, City, PostalCode,
				State, Country, Best_Time_to_Contact__c, Preferred_method_of_contact__c,
				Comments__c, LeadSource, Lead_Form_Name__c, Brand_Code__c, 
				HasOptedOutOfEmail, Spouse_Name__c, Occupation_Title__c, Company, 
				Birthday__c, Buying_horizon__c, First_Time_Boat_Owner__c, 
				Hull_Identification_Number_HIN__c, Phone, Best_Phone__c, Trade_In_Model__c, 
				Trade_In_Year__c, Trade_In_Comments__c, pi__score__c, Notes__c,
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
			from Lead
			where Id in :idToDealerIdMap.keySet()
		];
		
		for (Lead l: leads) {
			set<Id> dealerIds = idToDealerIdMap.get(l.Id);
			models.add(new FootStepsModel(l, dealerIds));
		}
		return models;
	}

}