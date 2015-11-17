/** 
* A generic routing model class for all types of objects that need to be routed to dealers
* 
* @author Mike Regan
*/
public class DealerRoutingModel {
    // The id of the object
    public id Id{get;set;}
    
    // The Brand
    public string Brand{get;set;}
    
    // The Boat Product Category
    public string ProductCategory{get;set;}
    
    // The Country ISO Code
    public string CountryISO{get;set;}
    
    // The State
    public string State{get; set;}
    
    // The Postal Code
    public string PostalCode{
    	get;
    	set {
    		// http://doctor.bicmgmt.com:8079/browse/BS-330 - trim trailing characters from postal code
    		if (value != null && value.contains('-') && value.indexOf('-') == 5) {
    			this.PostalCode = value.substring(0, value.indexOf('-'));
    			system.debug('adjusting postalcode from: ' + value + ', to: ' + this.PostalCode);
    		}
    		else {
    			this.PostalCode = value;
    		}
    	}
    }
    
    // The County
    public string County{get; set;}
    
    // The Latitude
    public double Latitude{get; set;}
    
    // The Longitude
    public double Longitude{get; set;}
    
    public string LeadSource{get; set;}
    
    public string LeadFormName{get; set;}
    
    //Added for BS-123
    public decimal PardotScore{get; set;}
    
    public boolean HasBeenAssigned {
        get{
            if(hasBeenAssigned==null){
                hasBeenAssigned = false;
            }
            return hasBeenAssigned;
        }
        set;
    }
    public boolean HasBeenRouted{
        get{
            if(hasBeenRouted==null){
                hasBeenRouted = false;
            }
            return hasBeenRouted;
        }
        set;
    }
    
    public DealerRoutingModel lead(Lead lead) {
        this.CountryISO = lead.Country_ISO_Code__c;
        this.State = lead.State;
        this.PostalCode = lead.PostalCode;
        this.County = lead.County__c;
        this.Latitude = lead.GeoLocation__Latitude__s;
        this.Longitude = lead.GeoLocation__Longitude__s;
        this.Brand = lead.Brand_Code__c;
        this.ProductCategory = lead.Boat_Category_of_Interest__c;
        this.HasBeenAssigned = false;
        this.HasBeenRouted = false;
        this.Id = lead.Id;
        this.LeadSource = lead.LeadSource;
        this.LeadFormName = lead.Lead_Form_Name__c;
        this.PardotScore = lead.pi__score__c;
        return this;    
    }
    
    public DealerRoutingModel owner(Account owner, string brand, string productCategory) {
        this.CountryISO = owner.Home_Address_ISO_Code__c;
        this.State = owner.PersonMailingState;
        this.PostalCode = owner.PersonMailingPostalCode;
        this.County = owner.County__c;
        this.Latitude = owner.GeoLocation__Latitude__s;
        this.Longitude = owner.GeoLocation__Longitude__s;
        this.Brand = brand;
        this.ProductCategory = productCategory;
        this.HasBeenAssigned = false;
        this.HasBeenRouted = false;
        this.Id = owner.Id;
        this.LeadSource = owner.PersonLeadSource;
        this.LeadFormName = owner.Lead_Form_Name__pc;
        this.PardotScore = owner.pi__score__pc;
        return this;
    }
}