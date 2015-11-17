public class FootstepsModel {
	
	public Id sourceId {get;set;}
	public String destinationType {get;set;}
	public String destinationIdentificationNumber {get;set;}
	public String dealerIdentificationCode {get;set;}
	public String internalRequestTypeNumber {get;set;}	
	public String internalModelNumber {get;set;}
	public String industry{get;set;}
	public String originationDate{get;set;}
	public String firstName{get;set;}
	public String lastName{get;set;}
	public String emailAddress{get;set;}
	public String zipPostalCode{get;set;}
	public String street{get;set;}
	public String city{get;set;}
	public String state{get;set;}
	public String country{get;set;}
	public String phone{get;set;}
	public String bestPhone{get;set;}
	public String modelOfInterest{get;set;}
	public String boatCategoryOfInterest{get;set;}
	public String hinNumber{get;set;}
	public String comments{get;set;}
	public String firstTimeBoatOwner{get;set;}
	public String buyingHorizon{get;set;}
	public String webFormName{get;set;}
	public String birthday{get;set;}
	public String bestTimeToContact{get;set;}
	public String company{get;set;}
	public String currentJobTitle{get;set;}
	public String spouseName{get;set;}
	public String brandInterest{get;set;}
	public String preferedContactMethod{get;set;}
	public String boatYear{get;set;}
	public String leadScore{get;set;}
	public String tradeInModel{get;set;}
	public String tradeInYear{get;set;}
	public String tradeInComments{get;set;}
	public String emailOptIn{get;set;}
	public String towVehicle {get;set;}
	public String previousOwner {get;set;}
	public String previosPurchaseNewOrUsed {get;set;}
	public String notes {get;set;}
	
	private List<Owner_Boat_Relationship__c> boatRelationShipLists = new List<Owner_Boat_Relationship__c>();
	public List<Owner_Boat_Relationship__c> boatRelationShips 
	{
		get {
			return boatRelationShipLists;
		}
	}
		
	// TODO all these new fields
	private Map<Id, String> assignedDealerIdToCRMSystem = new Map<Id, String>();
	public Map<Id, String> assignedDealerIdToCRMSystemMap {
		get {
			return assignedDealerIdToCRMSystem;
		}
	}
	private Set<String> dealerAccountNumbers = new Set<String>();
	public Set<String> dealerAccountNumbersSet{
		get {
			return dealerAccountNumbers;
		}
	}
	public String brandCode{get;set;}
	public String leadFormName{get;set;}
	public String leadSource{get;set;}
	public boolean footStepsRetry {get; set;}
	
	@testVisible 
	private static Map<String, String> leadFormIdentificationNumberMap {
		get {
			if (leadFormIdentificationNumberMap == null){
				leadFormIdentificationNumberMap = new Map<String, String>();
				for (Lead_Form_Settings__c lfs : Lead_Form_Settings__c.getAll().values()){
					//DCH (BS-152) -- Added brand code to the key: lfs.Brand_Code__c + '#' + 
					leadFormIdentificationNumberMap.put( String.valueOf(lfs.Lead_Source__c + '#' + lfs.Brand_Code__c + '#' + lfs.Lead_Form_Name__c).toLowerCase(), lfs.identification_number__c );
				} 
			}
			return leadFormIdentificationNumberMap;
		}
	}
	
	@testVisible 
	private static Map<String, String> leadFormRequestTypeNumberMap {
		get {
			if (leadFormRequestTypeNumberMap == null){
				leadFormRequestTypeNumberMap = new Map<String, String>();
				for (Lead_Form_Settings__c lfs : Lead_Form_Settings__c.getAll().values()){
					//DCH (BS-152) -- Added brand code to the key: lfs.Brand_Code__c + '#' + 
					leadFormRequestTypeNumberMap.put(String.valueOf(lfs.Lead_Source__c + '#' + lfs.Brand_Code__c + '#' + lfs.Lead_Form_Name__c).toLowerCase(), lfs.internal_request_type_number__c );
				}
			}
			return leadFormRequestTypeNumberMap;
		}
	}
	

	public FootstepsModel() {
		this.destinationType = 'oem';
		this.destinationIdentificationNumber = '';
		this.dealerIdentificationCode = '';
		this.internalRequestTypeNumber = '';
		this.internalModelNumber = '';
		this.towVehicle = '';
		this.previousOwner = '';
		this.footStepsRetry = false;
	}
	
	public FootstepsModel(Lead lead, set<Id> dealerIds) {
		this();
		this.industry	 = 'Boats'; 
		this.originationDate = getStringValue(lead.LastModifiedDate );
		this.firstName = getNullSafeValue(lead.FirstName);
		this.lastName = getNullSafeValue(lead.LastName) ;
		this.emailAddress = getNullSafeValue(lead.Email) ;
		this.zipPostalCode = getNullSafeValue(lead.PostalCode) ;
		this.street = getNullSafeValue(lead.Street) ;
		this.city = getNullSafeValue(lead.City) ;
		this.state = getNullSafeValue(lead.State);
		this.country = getNullSafeValue(lead.Country);
		this.phone = getNullSafeValue(lead.Phone) ;
		this.bestPhone = getNullSafeValue(lead.Best_Phone__c) ;
		this.modelOfInterest = getNullSafeValue(lead.Boat_Model_Interest__c);
		this.boatCategoryOfInterest = getNullSafeValue(lead.Boat_Category_of_Interest__c);
		this.hinNumber = getNullSafeValue(lead.Hull_Identification_Number_HIN__c) ;
		this.comments	= getNullSafeValue(lead.Comments__c);
		this.firstTimeBoatOwner = getNullSafeValue(lead.First_Time_Boat_Owner__c) == 'true' ? 'Yes' : 'No' ;
		this.buyingHorizon = getNullSafeValue(lead.Buying_horizon__c)  ;
		this.webFormName = getNullSafeValue(lead.Lead_Form_Name__c);
		this.birthday = getNullSafeValue(lead.Birthday__c) ;
		this.bestTimeToContact = getNullSafeValue(lead.Best_Time_to_Contact__c) ;
		this.company = getNullSafeValue(lead.Company) ;
		this.currentJobTitle = getNullSafeValue(lead.Occupation_Title__c) ;
		this.spouseName = getNullSafeValue(lead.Spouse_Name__c) ;
		this.brandInterest = getNullSafeValue(lead.Brand_Interest__c) ;
		this.preferedContactMethod = getNullSafeValue(lead.Preferred_method_of_contact__c);
		this.boatYear = getNullSafeValue(lead.Boat_Year_Interest__c) ;
        this.leadScore = getNullSafeValue(lead.pi__score__c);
		this.tradeInModel = getNullSafeValue(lead.Trade_In_Model__c);
		this.tradeInYear = getNullSafeValue(lead.Trade_In_Year__c);
		this.tradeInComments = getNullSafeValue(lead.Trade_In_Comments__c);
		this.emailOptIn = getNullSafeValue(lead.Email_Opt_in__c) == 'No' ? 'N' : 'Y';
		this.notes = getNullSafeValue(lead.Notes__c);
			
		this.comments += '\n Trade-In Model: ' +  this.tradeInModel;
		this.comments += '\n Trade-In Year: ' +  this.tradeInYear;
		this.comments += '\n Trade-In Comments: ' +  this.tradeInComments;
		this.comments += '\n Notes: ' +  notes;
			
		this.leadSource = getNullSafeValue(lead.leadSource);
		this.sourceId = lead.id;
		
		//DCH (BS-152) -- Added brand code to the key: outgoingLead.Brand_Code__c + '#' + 
		String leadFormKey = String.valueOf(lead.LeadSource + '#' + lead.Brand_Code__c + '#' + lead.Lead_Form_Name__c).toLowerCase();
			
		if (leadFormIdentificationNumberMap.containsKey(leadFormKey)){
			destinationIdentificationNumber = leadFormIdentificationNumberMap.get(leadFormKey);
		}
			
		if (leadFormRequestTypeNumberMap.containsKey(leadFormKey)){
			internalRequestTypeNumber = leadFormRequestTypeNumberMap.get(leadFormKey);
		}
		
		for (Integer i=1; i<=10; i++) {
			Account a = (Account)lead.getSObject('assigned_dealer_' + i + '__r');
			if (a != null) {
				if (dealerIds == null || dealerIds.isEmpty() || dealerIds.contains(a.Id)) {
					this.dealerAccountNumbersSet.add(a.dealer_number__c);
					this.assignedDealerIdToCRMSystemMap.put(a.id, a.CRM_System__c);
				}
			}
		}
		this.brandCode = getNullSafeValue(lead.Brand_Code__c);
		
	}
	
	public FootstepsModel(Account account, set<Id> dealerIds) {
		this(account, new List<Owner_Boat_Relationship__c>(), dealerIds);
	}
	
	public FootstepsModel(Account account, List<Owner_Boat_Relationship__c> boatRelationships, set<Id> dealerIds) {
		this();
		this.boatRelationShips.addAll(boatRelationships);
		this.industry	 = 'Boats';
		this.originationDate = getStringValue(account.LastModifiedDate );
		this.firstName = getNullSafeValue(account.FirstName);
		this.lastName = getNullSafeValue(account.LastName) ;
		this.emailAddress = getNullSafeValue(account.PersonEmail) ;
		this.zipPostalCode = getNullSafeValue(account.PersonMailingPostalCode) ;
		this.street = getNullSafeValue(account.PersonMailingStreet) ;
		this.city = getNullSafeValue(account.PersonMailingCity) ;
		this.state = getNullSafeValue(account.PersonMailingState);
		this.country = getNullSafeValue(account.PersonMailingCountry);
		this.phone = getNullSafeValue(account.Phone) ;
		this.bestPhone = getNullSafeValue(account.Best_Phone__pc) ;
		this.modelOfInterest = getNullSafeValue(account.Boat_Model_Interest__pc);
		this.boatCategoryOfInterest = getNullSafeValue(account.Boat_Category_of_Interest__pc);
		this.hinNumber = getNullSafeValue(account.Hull_Identification_Number_HIN__pc) ;
		this.comments	= getNullSafeValue(account.Comments__pc);
		this.firstTimeBoatOwner = getNullSafeValue(account.First_Time_Boat_Owner__pc) == 'true' ? 'Yes' : 'No' ;
		this.buyingHorizon = getNullSafeValue(account.Buying_horizon__pc)  ;
		this.webFormName = getNullSafeValue(account.Lead_Form_Name__pc);
		this.birthday = getNullSafeValue(account.Birthday__pc) ;
		this.bestTimeToContact = getNullSafeValue(account.Best_Time_to_Contact__pc) ;
		this.company = getNullSafeValue(account.Company__c);
		this.currentJobTitle = getNullSafeValue(account.Occupation_Title__c) ;
		this.spouseName = getNullSafeValue(account.Spouse__c) ;
		this.brandInterest = getNullSafeValue(account.Brand_Interest__pc) ;
		this.preferedContactMethod = getNullSafeValue(account.Preferred_method_of_contact__pc);
		this.boatYear = getNullSafeValue(account.Boat_Year_of_Interest__pc) ;
        this.leadScore = getNullSafeValue(account.pi__score__pc);
		this.tradeInModel = getNullSafeValue(account.Trade_In_Model__pc);
		this.tradeInYear = getNullSafeValue(account.Trade_In_Year__pc);
		this.tradeInComments = getNullSafeValue(account.Trade_In_Comments__pc);
		this.emailOptIn = getNullSafeValue(account.Email_Opt_In_Display__pc) == 'No' ? 'N' : 'Y';
		this.notes = getNullSafeValue(account.Notes__pc);
			
		this.comments += '\n Trade-In Model: ' +  this.tradeInModel;
		this.comments += '\n Trade-In Year: ' +  this.tradeInYear;
		this.comments += '\n Trade-In Comments: ' +  this.tradeInComments;
		this.comments += '\n Notes: ' +  notes;
			
		this.leadSource = getNullSafeValue(account.PersonLeadSource);
		this.sourceId = account.id;
		
		//DCH (BS-152) -- Added brand code to the key: outgoingaccount.Brand_Code__c + '#' + 
		String leadFormKey = String.valueOf(account.PersonLeadSource + '#' + account.Brand__c + '#' + account.Lead_Form_Name__pc).toLowerCase();
			
		if (leadFormIdentificationNumberMap.containsKey(leadFormKey)){
			destinationIdentificationNumber = leadFormIdentificationNumberMap.get(leadFormKey);
		}
			
		if (leadFormRequestTypeNumberMap.containsKey(leadFormKey)){
			internalRequestTypeNumber = leadFormRequestTypeNumberMap.get(leadFormKey);
		}
		
		for (Integer i=1; i<=10; i++) {
			Account a = (Account)account.getSObject('assigned_dealer_' + i + '__r');
			if (a != null) {
				if (dealerIds == null || dealerIds.isEmpty() || dealerIds.contains(a.Id)) {
					this.dealerAccountNumbersSet.add(a.dealer_number__c);
					this.assignedDealerIdToCRMSystemMap.put(a.id, a.CRM_System__c);
				}
			}
		}
		this.brandCode = getNullSafeValue(account.Brand__c);
	}

	private String getStringValue(DateTime dateValue){
		if (dateValue != null){
			return dateValue.format();
		}
		return ''; 
	}
	
	private String getNullSafeValue(Object value) {
		if (value != null) {
			return String.valueOf(value);
		}
		return '';
	}

}