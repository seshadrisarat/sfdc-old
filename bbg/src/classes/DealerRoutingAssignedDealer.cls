public class DealerRoutingAssignedDealer {
	// The id of the dealer
	public id Id {get;set;}
	
	public string DealerNumber {get;set;}
	
	public string SubjectLine {get;set;}
	
	public string CRMEmail {get;set;}
	
	public string PrimaryEmail {get;set;}
	
	public string SecondaryEmail1 {get;set;}
	
	public string SecondaryEmail2 {get;set;}
	
	public string SecondaryEmail3 {get;set;}

	public string SecondaryEmail4 {get;set;}
	
	public string SecondaryEmail5 {get;set;}
	
	public DealerRoutingAssignedDealer(DealerRoutingModel model, Dealer_Brand__c dealerBrand) {
		this.Id = dealerBrand.Dealer__c;
		this.DealerNumber = dealerBrand.Dealer_Number__c;
		this.SubjectLine = model.LeadSource + ' : ' + model.LeadFormName;
		
		this.CRMEmail = dealerBrand.Dealer_CRM_Email__c;
		this.PrimaryEmail = dealerBrand.Dealer_Primary_Email__c;
		this.SecondaryEmail1 = dealerBrand.Dealer_Secondary_Email_1__c;
		this.SecondaryEmail2 = dealerBrand.Dealer_Secondary_Email_2__c;
		this.SecondaryEmail3 = dealerBrand.Dealer_Secondary_Email_3__c;
		this.SecondaryEmail4 = dealerBrand.Dealer_Secondary_Email_4__c;
		this.SecondaryEmail5 = dealerBrand.Dealer_Secondary_Email_5__c;
	}
	
}