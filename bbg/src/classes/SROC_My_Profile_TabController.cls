public with sharing class SROC_My_Profile_TabController {

	//public Id pageUserId {get;private set;}
		
	public User u {get;private set;}
	
	public String saveSection {get;set;}
	
	public Owner_Boat_Relationship__c obr {get;private set;}
	
	public SROC_My_Profile_TabController() {
	
		//Id pageUserId = ApexPages.currentPage().getParameters().get('sfdc.userId');
		Id pageUserId = UserInfo.getUserId();
		
		this.u = [SELECT 
					Id, 
					Birthdate__c, 
					Street,
					City, 
					State, 
					Country, 
					PostalCode, 
					firstName,
					lastName,
					AboutMe,
					communityNickname,
					Spouse__c,
					mobilePhone,
					Phone,
					Email,
					Number_of_Children__c,
					Profession__c,
					Industry__c,
					Boating_Experience__c,
					CORECONNECT__CC_List_In_Directory__c,
					Receive_Event_Invitations__c,
					Birthdate_Privacy__c,
					FirstName_Privacy__c,
					LastName_Privacy__c,
					Spouse_Privacy__c,
					Number_of_Children_Privacy__c,
					Boating_Experience_Privacy__c,
					Profession_Privacy__c,
					Industry_Privacy__c,
					MobilePhone_Privacy__c,
					Phone_Privacy__c,
					Email_Privacy__c
					FROM User WHERE Id = :pageUserId LIMIT 1];
					
		this.obr = SROCUtilities.queryOwnerBoatRelationship();
		defaultPrivacySettings();
	}
	
	public PageReference saveMyProfile() {
		
		if(!validate())
		{
			return null;
		}
		
		PageReference pr = new PageReference('/sroc/' + this.u.Id + '?tab=My_Profile');
		
		try {
			update this.u;
			pr.setRedirect(true);
			return pr;
		}catch(Exception e) {
			
			if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == false)
			{
				Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,e.getMessage());
       	 		Apexpages.addmessage(msg);
			}
       	 	return null;
		}
		
		
	}
	
	private Boolean validate() {
		
		if(String.isEmpty(this.u.firstName))
		{
			Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Please enter a First Name.');
       	 	Apexpages.addmessage(msg);
       	 	this.u.firstName.addError('Please enter a First Name.');
		}
		
		if(String.isEmpty(this.u.Street))
		{
			Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Please enter a Street Address.');
       	 	Apexpages.addmessage(msg);
       	 	this.u.Street.addError('Please enter a Street Address.');
		}
		
		if(String.isEmpty(this.u.City))
		{
			Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Please enter a City.');
       	 	Apexpages.addmessage(msg);
       	 	this.u.City.addError('Please enter a City.');
		}
		
		if(String.isEmpty(this.u.State))
		{
			Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Please enter a State.');
       	 	Apexpages.addmessage(msg);
       	 	this.u.State.addError('Please enter a State.');
		}
		
		if(String.isEmpty(this.u.PostalCode))
		{
			Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Please enter a Postal Code.');
       	 	Apexpages.addmessage(msg);
       	 	this.u.PostalCode.addError('Please enter a Postal Code.');
		}
		else if(SROCUtilities.postalCodeToGeocodeData(this.u.PostalCode) == null)
		{
			Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'The entered Postal Code is not valid.');
       	 	Apexpages.addmessage(msg);
       	 	this.u.PostalCode.addError('Please enter a valid Postal Code.');
		}
		
		if(String.isEmpty(this.u.Country))
		{
			Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Please enter a Country.');
       	 	Apexpages.addmessage(msg);
       	 	this.u.Country.addError('Please enter a Country.');
		}
		
		
		
		if(isError)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

public Boolean isError {
	get {
		if(ApexPages.getMessages().size() > 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}
	
public String HeaderCSSBrandingResourceName {
        get{
    			CORECONNECT__CC_Header_Footer_Settings__c headerfooter = CORECONNECT__CC_Header_Footer_Settings__c.getInstance(Site.GetName());

            	if(headerfooter==null || headerfooter.CORECONNECT__Header_CSS_Branding_Resource_Name__c == null || headerfooter.CORECONNECT__Header_CSS_Branding_Resource_Name__c.trim() == ''){
                	return '';
            	}
            	else
           	 	{
           	 		return headerfooter.CORECONNECT__Header_CSS_Branding_Resource_Name__c;
            	}

            }
	 }

	private void defaultPrivacySettings() {
		
		if(this.u.FirstName_Privacy__c == null) {this.u.Birthdate_Privacy__c = 'Private';}
		if(this.u.LastName_Privacy__c == null) {this.u.Birthdate_Privacy__c = 'Private';}
		if(this.u.Spouse_Privacy__c == null) {this.u.Spouse_Privacy__c = 'Private';}
		if(this.u.Number_of_Children_Privacy__c == null) {this.u.Number_of_Children_Privacy__c = 'Private';}
		if(this.u.Birthdate_Privacy__c == null) {this.u.Birthdate_Privacy__c = 'Private';}
		if(this.u.Boating_Experience_Privacy__c == null) {this.u.Boating_Experience_Privacy__c = 'Private';}
		if(this.u.Profession_Privacy__c == null) {this.u.Profession_Privacy__c = 'Private';}
		if(this.u.Industry_Privacy__c == null) {this.u.Industry_Privacy__c = 'Private';}
		if(this.u.MobilePhone_Privacy__c == null) {this.u.MobilePhone_Privacy__c = 'Private';}
		if(this.u.Phone_Privacy__c == null) {this.u.Phone_Privacy__c = 'Private';}
		if(this.u.Email_Privacy__c == null) {this.u.Email_Privacy__c = 'Private';}
	}

}