/**
 * Author: Gregory Grinberg 
 * Description: Adds code coverage buylicense page and controller. Actual test code still needs to be written
 */
 
@isTest
private class Test_LicenseManager_Controller {
	/*static testMethod void LicenseManager_controller_UnitTest() {
// fake_license_changes
    	sfLma__License__c la = License_Alfa;
    	sfLma__License__c lb = License_Beta;
//    	License__c la = License_Alfa;
//    	License__c lb = License_Beta;
// fake_license_changes
    	
    	ApexPages.currentPage().getParameters().put( 'orgid', la.sfLma__Subscriber_Org_ID__c );
        LicenseManager_controller controller = new LicenseManager_controller();
        controller.getyearlycost();
        controller.getDescription();
        controller.getExpirationDate();
        Integer i = controller.getDaysLeft();
        Double d = controller.getPricePerLicense();
        controller.newlicenses = 2;
        Double d2 = controller.getProratedNewLicenseCharges();
        Double d3 = controller.getNewSubscriptionCharges();
        controller.bIsRenewal = true;
        Double d4 = controller.getNewSubscriptionCharges();
        Double d5 = controller.getOneLicenseCost();
        Date dt = controller.getNewSubscriptionStartDate();
        String s = controller.UpgradeLink;
        String s3 = controller.getDescription();
        String s4 = controller.getPackageVersionName();
        
        String sToken = '{' +
        	'"id": "tok_102w7t252zefHLcQM1VyENGq",' +
			'"livemode": false,' +
			'"created": 1384395231,' +
			'"used": false,' +
			'"object": "token",' +
			'"type": "card",' +
			'"card": {' +
				'"id": "card_102w7s252zefHLcQcd0BXLwO",' +
			    '"object": "card",' +
			    '"last4": "4242",' +
			    '"brand": "Visa",' +
                '"funding": "credit",' +
			    '"exp_month": 11,' +
			    '"exp_year": 2014,' +
			    '"fingerprint": "qej8u5csKEr2MX9Z",' +
			    '"customer": null,' +
			    '"country": "US",' +
			    '"name": "Greg Grinberg",' +
			    '"address_line1": "447A State st.",' +
			    '"address_line2": null,' +
			    '"address_city": "Brooklyn",' +
			    '"address_state": "NY",' +
			    '"address_zip": "11217",' +
			    '"address_country": "US"' +
			'}' +
		'}';
			  
        ApexPages.currentPage().getParameters().put( 'token', sToken );
        
        controller.createCharge();
        
        controller.bIsRenewal = false;
        Double d6 = controller.getNewSubscriptionCharges();
        Date dt1 = controller.getExpirationDate();
        Date dt2 = controller.getNewSubscriptionDescriptionDateFrom();
        
        controller.packageversion = PackageVersion_Beta.Id;
        String s5 = controller.UpgradeLink;
        Double d7 = controller.getProratedNewLicenseCharges();        
    }
    
    static testMethod void LM3_OrgIdNull_Or_NotHaveLicenses_UnitTest() {
        LicenseManager_controller controller = null;
        controller = new LicenseManager_controller();
        ApexPages.currentPage().getParameters().put('orgid', 'SomeOrgIdWhatNotHaveAnyLicenses');
        controller = new LicenseManager_controller();
        
// fake_license_changes
        ApexPages.currentPage().getParameters().put('orgid', TrialLicense.sfLma__Subscriber_Org_ID__c);
//        ApexPages.currentPage().getParameters().put('orgid', TrialLicense.sfLma_Subscriber_Org_ID__c);
        controller = new LicenseManager_controller();
        Double d = controller.getPricePerLicense();
    }
    
    static testMethod void LM3_SiteLicense_UnitTest() {
// fake_license_changes
    	ApexPages.currentPage().getParameters().put('orgid', SiteLicense.sfLma__Subscriber_Org_ID__c);
//    	ApexPages.currentPage().getParameters().put('orgid', SiteLicense.sfLma_Subscriber_Org_ID__c);
        LicenseManager_controller controller = new LicenseManager_controller();
        //controller.refresh();
    }
    
    static testMethod void LM3_TrialLicense_NotExpired_UnitTest() {
    	LicenseManager_controller controller = null;
// fake_license_changes
    	ApexPages.currentPage().getParameters().put('orgid', TrialLicense_NotExpired.sfLma__Subscriber_Org_ID__c);
//    	ApexPages.currentPage().getParameters().put('orgid', TrialLicense_NotExpired.sfLma_Subscriber_Org_ID__c);
        controller = new LicenseManager_controller();
        Date dt = controller.getExpirationDate();
    }
    
    static testMethod void LM3_NotExpiredLicense_UnitTest() {
// fake_license_changes
  		ApexPages.currentPage().getParameters().put('orgid', LicenseNotExpired_Alfa.sfLma__Subscriber_Org_ID__c);
//  		ApexPages.currentPage().getParameters().put('orgid', LicenseNotExpired_Alfa.sfLma_Subscriber_Org_ID__c);
    	LicenseManager_controller c = new LicenseManager_controller();
    	Double d1 = c.getDaysLeft();
    	Date dt = c.getNewSubscriptionStartDate();
    	c.newlicenses = 0;
    	
    	c.bIsRenewal = true;
    	c.newlicenses = 1;
    	c.getDescription();
    }
  
    
    // === PROPERTIES =================================================================================== //
    private static Account pAccount {
    	get {
    		if ( pAccount != null ) {
    			return pAccount;
    		}
    		
    		Account oVar = new Account();
    		oVar.Name = 'TestAccountName';
    		insert oVar;
    		
    		pAccount = [
    			SELECT Id
    			FROM Account
    			WHERE Id = :oVar.Id
    		];
    		
    		return pAccount;
    	} private set;
    }
    
// fake_license_changes
    public static sfLma__License__c License_Alfa {
//    public static License__c License_Alfa {
    	get {
    		if(License_Alfa == null) {
// fake_license_changes
    			sfLma__License__c var = new sfLma__License__c();
    			var.sfLma__Package_Version__c = PackageVersion_Alfa.Id;
    			var.sfLma__Subscriber_Org_ID__c = UserInfo.getOrganizationId();
    			var.sfLma__Install_Date__c = Date.today();
    			var.sfLma__Expiration__c = Date.today();
    			var.sfLma__Status__c = 'Active';
    			var.sfLma__Seats__c = 1;
    			var.sfLma__Used_Licenses__c = 1;
    			var.sfLma__Account__c = pAccount.Id;
//    			License__c var = new License__c();
//    			var.sfLma_Package_Version__c = PackageVersion_Alfa.Id;
//    			var.sfLma_Subscriber_Org_ID__c = UserInfo.getOrganizationId();
//    			var.sfLma_Install_Date__c = Date.today();
//    			var.sfLma_Expiration__c = Date.today();
//    			var.sfLma_Status__c = 'Active';
//    			var.sfLma_Seats__c = 1;
//    			var.sfLma_Used_Licenses__c = 1;
    			var.RecordTypeId = LicenseActive_RecordType.Id;
    			insert var;
    			
// fake_license_changes
    			License_Alfa = [SELECT Id, sfLma__Subscriber_Org_ID__c FROM sfLma__License__c WHERE Id=:var.Id];
//    			License_Alfa = [SELECT Id, sfLma_Subscriber_Org_ID__c FROM License__c WHERE Id=:var.Id];
    		}
    		return License_Alfa;
    	} private set;
    }
    
// fake_license_changes
    public static sfLma__License__c License_Beta {
//    public static License__c License_Beta {
    	get {
    		if(License_Beta == null) {
// fake_license_changes
    			sfLma__License__c var = new sfLma__License__c();
    			var.sfLma__Package_Version__c = PackageVersion_Beta.Id;
    			var.sfLma__Subscriber_Org_ID__c = UserInfo.getOrganizationId();
    			var.sfLma__Install_Date__c = Date.today().addDays(-1);
    			var.sfLma__Expiration__c = Date.today();
    			var.sfLma__Status__c = 'Active';
    			var.sfLma__Seats__c = 1;
    			var.sfLma__Used_Licenses__c = 1;
    			var.sfLma__Account__c = pAccount.Id;
//    			License__c var = new License__c();
//   			var.sfLma_Package_Version__c = PackageVersion_Beta.Id;
//    			var.sfLma_Subscriber_Org_ID__c = UserInfo.getOrganizationId();
//    			var.sfLma_Install_Date__c = Date.today().addDays(-1);
//    			var.sfLma_Expiration__c = Date.today();
//    			var.sfLma_Status__c = 'Active';
//    			var.sfLma_Seats__c = 1;
//    			var.sfLma_Used_Licenses__c = 1;
    			var.RecordTypeId = LicenseActive_RecordType.Id;
    			insert var;
    			
// fake_license_changes
    			License_Beta = [SELECT Id, sfLma__Subscriber_Org_ID__c FROM sfLma__License__c WHERE Id=:var.Id];
//    			License_Beta = [SELECT Id, sfLma_Subscriber_Org_ID__c FROM License__c WHERE Id=:var.Id];
    		}
    		return License_Beta;
    	} private set;
    }
    
// fake_license_changes
    public static sfLma__License__c TrialLicense {
//    public static License__c TrialLicense {
    	get {
    		if(TrialLicense == null) {
// fake_license_changes
    			sfLma__License__c var = new sfLma__License__c();
    			var.sfLma__Package_Version__c = PackageVersion_Beta.Id;
    			var.sfLma__Subscriber_Org_ID__c = UserInfo.getOrganizationId();
    			var.sfLma__Install_Date__c = Date.today();
    			var.sfLma__Status__c = 'Trial';
	   			var.sfLma__Seats__c = -1;
	   			var.sfLma__Account__c = pAccount.Id;
//    			License__c var = new License__c();
//    			var.sfLma_Package_Version__c = PackageVersion_Beta.Id;
//    			var.sfLma_Subscriber_Org_ID__c = UserInfo.getOrganizationId();
//    			var.sfLma_Install_Date__c = Date.today();
//    			var.sfLma_Status__c = 'Trial';
//    			var.sfLma_Seats__c = -1;
    			insert var;
    			
// fake_license_changes
    			TrialLicense = [SELECT Id, sfLma__Subscriber_Org_ID__c FROM sfLma__License__c WHERE Id=:var.Id];
//    			TrialLicense = [SELECT Id, sfLma_Subscriber_Org_ID__c FROM License__c WHERE Id=:var.Id];
    		}
    		return TrialLicense;
    	} private set;
    }
    
// fake_license_changes
    public static sfLma__License__c TrialLicense_NotExpired {
//    public static License__c TrialLicense_NotExpired {
    	get {
    		if(TrialLicense_NotExpired == null) {
// fake_license_changes
    			sfLma__License__c var = new sfLma__License__c();
    			var.sfLma__Package_Version__c = PackageVersion_Beta.Id;
    			var.sfLma__Subscriber_Org_ID__c = UserInfo.getOrganizationId();
    			var.sfLma__Install_Date__c = Date.today();
    			var.sfLma__Expiration__c = Date.today().addDays(1);
    			var.sfLma__Status__c = 'Trial';
    			var.sfLma__Seats__c = -1;
    			var.sfLma__Account__c = pAccount.Id;
//    			License__c var = new License__c();
//    			var.sfLma_Package_Version__c = PackageVersion_Beta.Id;
//    			var.sfLma_Subscriber_Org_ID__c = UserInfo.getOrganizationId();
//    			var.sfLma_Install_Date__c = Date.today();
//    			var.sfLma_Expiration__c = Date.today().addDays(1);
//    			var.sfLma_Status__c = 'Trial';
//    			var.sfLma_Seats__c = -1;
    			insert var;
    			
// fake_license_changes
    			TrialLicense_NotExpired = [SELECT Id, sfLma__Subscriber_Org_ID__c FROM sfLma__License__c WHERE Id=:var.Id];
//    			TrialLicense_NotExpired = [SELECT Id, sfLma_Subscriber_Org_ID__c FROM License__c WHERE Id=:var.Id];
    		}
    		return TrialLicense_NotExpired;
    	} private set;
    }
    
// fake_license_changes
    public static sfLma__License__c LicenseNotExpired_Alfa {
//    public static License__c LicenseNotExpired_Alfa {
    	get {
    		if(LicenseNotExpired_Alfa == null) {
// fake_license_changes
    			sfLma__License__c var = new sfLma__License__c();
    			var.sfLma__Package_Version__c = PackageVersion_Alfa.Id;
    			var.sfLma__Subscriber_Org_ID__c = UserInfo.getOrganizationId();
    			var.sfLma__Install_Date__c = Date.today();
    			var.sfLma__Expiration__c = Date.today().addDays(1);
    			var.sfLma__Status__c = 'Active';
    			var.sfLma__Seats__c = 1;
	   			var.sfLma__Used_Licenses__c = 1;
	   			var.sfLma__Account__c = pAccount.Id;
//    			License__c var = new License__c();
//    			var.sfLma_Package_Version__c = PackageVersion_Alfa.Id;
//    			var.sfLma_Subscriber_Org_ID__c = UserInfo.getOrganizationId();
//    			var.sfLma_Install_Date__c = Date.today();
//    			var.sfLma_Expiration__c = Date.today().addDays(1);
//    			var.sfLma_Status__c = 'Active';
//    			var.sfLma_Seats__c = 1;
//    			var.sfLma_Used_Licenses__c = 1;
    			var.RecordTypeId = LicenseActive_RecordType.Id;
    			insert var;
    			
// fake_license_changes
    			LicenseNotExpired_Alfa = [SELECT Id, sfLma__Subscriber_Org_ID__c FROM sfLma__License__c WHERE Id=:var.Id];
//    			LicenseNotExpired_Alfa = [SELECT Id, sfLma_Subscriber_Org_ID__c FROM License__c WHERE Id=:var.Id];
    		}
    		return LicenseNotExpired_Alfa;
    	} private set;
    }
    
// fake_license_changes
    public static sfLma__License__c SiteLicense {
//    public static License__c SiteLicense {
    	get {
    		if(SiteLicense == null) {
// fake_license_changes
    			sfLma__License__c var = new sfLma__License__c();
    			var.sfLma__Package_Version__c = PackageVersion_Beta.Id;
    			var.sfLma__Subscriber_Org_ID__c = UserInfo.getOrganizationId();
    			var.sfLma__Install_Date__c = Date.today();
    			var.sfLma__Expiration__c = Date.today();
    			var.sfLma__Status__c = 'Trial';
    			var.sfLma__Seats__c = -1;
    			var.sfLma__Account__c = pAccount.Id;
//    			License__c var = new License__c();
//    			var.sfLma_Package_Version__c = PackageVersion_Beta.Id;
//    			var.sfLma_Subscriber_Org_ID__c = UserInfo.getOrganizationId();
//    			var.sfLma_Install_Date__c = Date.today();
//    			var.sfLma_Expiration__c = Date.today();
//    			var.sfLma_Status__c = 'Trial';
//    			var.sfLma_Seats__c = -1;
    			insert var;
    			
// fake_license_changes
    			SiteLicense = [SELECT Id, sfLma__Subscriber_Org_ID__c FROM sfLma__License__c WHERE Id=:var.Id];
//    			SiteLicense = [SELECT Id, sfLma_Subscriber_Org_ID__c FROM License__c WHERE Id=:var.Id];
    		}
    		return SiteLicense;
    	} private set;
    }
    
    public static RecordType LicenseActive_RecordType {
    	get {
    		if(LicenseActive_RecordType == null) {
// fake_license_changes
    			LicenseActive_RecordType = [SELECT Id FROM RecordType WHERE SObjectType='sfLma__License__c' And DeveloperName='Active'];	
//    			LicenseActive_RecordType = [SELECT Id FROM RecordType WHERE SObjectType='License__c' And DeveloperName='Active'];	
    		}    		
    		return LicenseActive_RecordType;
    	} private set;
    }
    
    public static sfLma__Package_Version__c PackageVersion_Alfa {
    	get {
    		if(PackageVersion_Alfa == null) {
    			sfLma__Package_Version__c var = new sfLma__Package_Version__c();
    			var.Name = 'Test_PackageVersion_Alfa';
    			var.sfLma__Package__c = TPackage.Id;
    			var.sfLma__Version__c = '1.0';
    			var.sfLma__Is_Beta__c = false;
    			insert var;
    			
    			PackageVersion_Alfa = [SELECT Id FROM sfLma__Package_Version__c WHERE Id=:var.Id];
    		}
    		return PackageVersion_Alfa;
    	} private set;
    }
    
    public static sfLma__Package_Version__c PackageVersion_Beta {
    	get {
    		if(PackageVersion_Beta == null) {
    			sfLma__Package_Version__c var = new sfLma__Package_Version__c();
    			var.Name = 'Test_PackageVersion_Beta';
    			var.sfLma__Package__c = TPackage.Id;
    			var.sfLma__Version__c = '0.1';
    			var.sfLma__Is_Beta__c = true;
    			insert var;
    			
    			PackageVersion_Beta = [SELECT Id FROM sfLma__Package_Version__c WHERE Id=:var.Id];
    		}
    		return PackageVersion_Beta;
    	} private set;
    }
    
    public static sfLma__Package__c TPackage {
    	get {
    		if(TPackage == null) {
    			sfLma__Package__c var = new sfLma__Package__c();
    			var.Name = 'Test_TPackage';
    			insert var;
    			
    			TPackage = [SELECT Id FROM sfLma__Package__c WHERE Id=:var.Id];
    		}
    		return TPackage;
    	} private set;
    }*/
}