global class DealerInfo 
{
    webservice String dealerId;
    webservice String dealerName;
    webservice String dealerPhone;
    webservice String dealerWebsite;
	webservice String dealerShippingStreet;
	webservice String dealerShippingState;
	webservice String dealerShippingPostalCode;
	webservice String dealerShippingCountry;
	webservice String dealerShippingCity;
	webservice String dealerProductCategory;
	webservice String exceptionMessage;
	
	public DealerInfo(String msg){
		exceptionMessage = msg;
	}
	
	public DealerInfo(Account a, Dealer_Brand__c b){
		dealerId = a.Id;
		dealerName = a.Name;
		dealerShippingStreet = a.ShippingStreet;
		dealerShippingCity = a.ShippingCity;
		dealerShippingState = a.ShippingState;
		dealerShippingPostalCode = a.ShippingPostalCode;
		dealerShippingCountry = a.ShippingCountry;
		if (b!= null && b.Brand_Phone_Number__c != null){
			dealerPhone = b.Brand_Phone_Number__c;
		} else {
			dealerPhone = a.Phone;
		}
		if (b!= null && b.Brand_URL__c != null){
			dealerWebsite = b.Brand_URL__c;
		} else {
			dealerWebsite = a.Website;
		}


		dealerProductCategory = null;
	}
	
	public String getHashKey(){
		return this.dealerId + ';' + this.dealerProductCategory;
	}
	
}