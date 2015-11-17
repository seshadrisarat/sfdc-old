public without sharing class LicenseManager_controller {
     public String packageversion {
    	get;
    	set {
            System.debug('LMC|setpackageversion called');
    		this.packageversion = value;
			if ( this.packageversion != null ) {
                System.debug('LMC|Is packageversion null: ' + this.packageversion == null ? 'yes' : 'no');
                System.debug('LMC|packageversion: ' + this.packageversion);
                System.debug('LMC|LicensesByPackageVersion Contains PackageVersion: ' + this.LicensesbyPackageVersion.containsKey(this.packageversion));
                System.debug('LMC|Is LicensesByPackageVersion.get(package version) null: ' + this.LicensesbyPackageVersion.get(this.packageversion) == null ? 'yes' : 'no');
				this.oLicense = this.LicensesbyPackageVersion.get( this.packageversion );
	   			if( this.getLicense().sfLma__Expiration__c == null ) {
		        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Your current license does not expire. Please contact support@silverlinecrm.com to buy additional licenses.' ) );
	   			}
	   			if ( this.getLicense().sfLma__Seats__c == -1 ) {
		        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Your current license is a site license. Please contact support@silverlinecrm.com to this.bIsRenewal your license.' ) );
	   			}
			}
   		}
    }
    public List<SelectOption> items { get; set; }
    public Integer newlicenses { get; set; }
    public Boolean bIsRenewal { get; set; }
    
    private sfLma__License__c oLicense;
    private Map<String, sfLma__License__c> LicensesbyPackageVersion;
    public String sOrganizationId { get; set; }
    
    public String getPackageVersionName() {
		return SL_LicenseUtils.getPackageVersionName( this.getLicense() );
    }
    
    public String getLicenseFullName() {
    	return SL_LicenseUtils.getLicenseFullName( this.getLicense() );
    }
    
    public Decimal getOneLicenseCost() {
    	return LicenseCostHelper.getOneLicenseCost( this.getLicense(), this.bIsRenewal, this.newlicenses, this.packageversion );
    }
    
    public Integer getDaysLeft() {
    	return SL_LicenseUtils.getDaysLeft( this.getLicense() );
    }
    
    public Double getPricePerLicense() {
    	return LicenseCostHelper.getPricePerLicense( this.getLicense(), this.bIsRenewal, this.newlicenses, this.packageversion );
    }
    
    public Double getProratedNewLicenseCharges() {
    	return LicenseCostHelper.getProratedNewLicenseCharges( this.getLicense(), this.bIsRenewal, this.newlicenses, this.packageversion );
    }
    
    public Double getNewSubscriptionCharges() {
    	return LicenseCostHelper.getNewSubscriptionCharges( this.bIsRenewal, this.getTotalLicenses(), this.getYearlyCost() );
    }
    
    public Date getNewSubscriptionStartDate() {
    	return SL_LicenseUtils.getNewSubscriptionStartDate( this.getLicense() );
    }

	public sfLma__Package_Version__c getMostRecentVersion() {
		return SL_LicenseUtils.getMostRecentVersion( this.packageversion );
	}

    public String UpgradeLink {
    	get {
    		if ( packageversion == null || packageversion == '' ) {
    			return '';
    		}
    		
    		sfLma__Package_Version__c oMostRecentVersion = this.getMostRecentVersion();
    		if ( oMostRecentVersion == null ) {
    			return '';
    		}    		
    		if ( oMostRecentVersion.Id == this.packageversion ) {
    			return '';
    		}
    		
    		UpgradeVersion = oMostRecentVersion.Version_Number__c;
    		
    		return oMostRecentVersion.Package_Installation_URL__c;
    	} private set;
    }
    
    public String UpgradeVersion { get; private set; }
    
    public LicenseManager_controller() {
        try {
	        this.newlicenses = this.getNewLicenses();
			this.LicensesbyPackageVersion = new Map<String, sfLma__License__c>();
			
			this.sOrganizationId = this.getOrganizationId();            
	        this.LicensesbyPackageVersion = this.getLicensesByProductVersion( this.sOrganizationId );
	        this.items = this.getPackageVersionsList();
	
			this.packageversion = this.getPackageVersion();
	        if ( this.items.size() > 0 && String.isBlank( this.packageversion ) ) {
	        	this.packageversion = this.items.get( 0 ).getValue();
	        }
			
			/*if(LicensesbyPackageVersion.IsEmpty())
            {
            	if ( licenses.get(0).sfLma__Expiration__c == null ) {
                	throw new PageException('Your current license does not expire. Please contact support@silverlinecrm.com to buy additional licenses.');
                }
                if ( licenses.get(0).sfLma__Seats__c == -1 ) {
                	throw new PageException('Your current license is a site license. Please contact support@silverlinecrm.com to this.bIsRenewal your license.');
                }
            }*/
			
			if ( this.getLicense().sfLma__Expiration__c <= Date.today() && this.getLicense().sfLma__License_Status__c == 'Active' ) {
	        	this.bIsRenewal = true;
	        } else {
	        	this.bIsRenewal = this.getRenewal();
	        }
        } catch( Exception e ) {
        	//if ( e.getmessage().contains( 'does not expire' ) || ex.getmessage().contains( 'site license' ) ) {
        	//	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, ex.getMessage() ) );
        	//} else {
            	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage() ) );
        	//}
        }
    }
    
    private String getOrganizationId() {
    	String sResult = ApexPages.currentPage().getParameters().get( 'orgid' );
        if ( String.isBlank( sResult ) ) {
            throw new PageException( 'Woops! Looks like something went wrong. Please contact us at support@silverlinecrm.com for further assistance.' );
        }        
        return sResult;
    }
    
    private Map<String, sfLma__License__c> getLicensesByProductVersion( String sOrganizationId ) {
    	Map<String, sfLma__License__c> aResult = SL_LicenseUtils.getLicensesByPackageVersion( sOrganizationId );
        if ( aResult.isEmpty() ) {
        	throw new PageException( 'Woops! Looks like we couldn\'t find you. Please contact us at support@silverlinecrm.com for further assistance.' );
        }
        return aResult;
    }
    
    private String getPackageVersion() { 
        return ApexPages.currentPage().getParameters().get( 'product' );
    }
    
    private Integer getNewLicenses() {
    	Integer nResult;
    	try {
    		nResult = Integer.valueOf( ApexPages.currentPage().getParameters().get( 'qty' ) );
    		if ( nResult < 0 ) {
    			nResult = 0;
    		} else if ( nResult > 999 ) {
    			nResult = 999;
    		}
    	} catch ( Exception e ) {
    		nResult = 0;
    	}
        return nResult;
    }
    
    private Boolean getRenewal() {
    	Boolean bResult;
    	try {
    		bResult = Boolean.valueOf( ApexPages.currentPage().getParameters().get( 'renew' ) );
    	} catch ( Exception e ) {
    		bResult = false;
    	}
    	return bResult;
    }
    
    public sfLma__License__c getLicense() {
        System.debug('LMC|Is oLicense Null: ' + oLicense == null ? 'yes':'no');
    	return this.oLicense;
    }
    
    public String getCustomerEmail() {
    	if ( this.getLicense().sfLma__Contact__r.Email != null ) {
    		return this.getLicense().sfLma__Contact__r.Email;
    	}
    	return this.getLicense().sfLma__Lead__r.Email != null ? this.getLicense().sfLma__Lead__r.Email : '';
    }
    
    private List<SelectOption> getPackageVersionsList() {
    	List<SelectOption> aResult = new List<SelectOption>();
    	
    	List<String> aSortedItems = new List<String>();
        for ( String sKey : this.LicensesbyPackageVersion.keyset() ) {
        	aSortedItems.add( this.LicensesbyPackageVersion.get( sKey ).sfLma__Package_Version__r.Name );
        }
        aSortedItems.sort();
        
        for ( String sItem : aSortedItems ) {
        	for ( string sKey : this.LicensesbyPackageVersion.keyset() ) {
        		if ( this.LicensesbyPackageVersion.get( sKey ).sfLma__Package_Version__r.Name == sItem ) {
        			aResult.add( new SelectOption( LicensesbyPackageVersion.get( sKey ).sfLma__Package_Version__c, LicensesbyPackageVersion.get( sKey ).sfLma__Package_Version__r.Name ) );
        		}
        	}
        }
        return aResult;
    }
    
    /*public PageReference refresh() {
        if ( this.newlicenses == null || this.newlicenses < 0 ) {
            this.newlicenses = 0;
        }
        
        if ( this.getRenewalDisabled() ) {
    		this.bIsRenewal = false;
        } else {
	        if( this.getLicense().sfLma__Expiration__c <= Date.today() ) {
	        	this.bIsRenewal = true;
	        } else {
	        	this.bIsRenewal = false;
	        }
    	}
        return null;
    }*/
    
    public Integer getTotalLicenses() {
		return SL_LicenseUtils.getTotalLicenses( this.getLicense(), this.newlicenses );
    }
    
    public Decimal getYearlyCost() {        
        return LicenseCostHelper.CalculateYearlyCost( this.getLicense(), this.getTotalLicenses(), this.packageversion );
    }
    
    public Decimal getTotalPrice() {
        return LicenseCostHelper.CalculateTotalPrice( this.getLicense(), this.newlicenses, this.getYearlyCost(), this.bIsRenewal );
    }
    
    public String getDescription() {
        String sResult = '';
        
        if ( !this.bIsRenewal || ( this.bIsRenewal && this.newlicenses > 0 ) ) {
        	sResult += 'New Licenses($' + this.getProratedNewLicenseCharges() + '): ' + this.newlicenses + ' users – expires ' + this.dateToString( this.getProratedNewLicensesDescriptionDate() );
        }
        if ( this.newlicenses > 0 && this.bIsRenewal ) {
        	sResult += ' and ';
        }
        if ( this.bIsRenewal ) {
        	sResult += 'New Subscription($' + this.getNewSubscriptionCharges() + '): ' + this.getTotalLicenses() + ' users – ' + this.dateToString( this.getNewSubscriptionDescriptionDateFrom() ) + ' to ' + this.dateToString( this.getExpirationDate() );
        }        
        return sResult;
    }
    
    public Date getProratedNewLicensesDescriptionDate() {
    	return SL_LicenseUtils.getProratedNewLicensesDescriptionDate( this.getLicense(), this.bIsRenewal );
    }
    
    public Date getNewSubscriptionDescriptionDateFrom() {
    	return SL_LicenseUtils.getNewSubscriptionDescriptionDateFrom( this.getLicense(), this.bIsRenewal );
    }
    
    private String dateToString( Date dDate ) {
    	return dDate.month() + '/' + dDate.day() + '/' + dDate.year();
    }
    
    public Date getExpirationDate() {
    	return SL_LicenseUtils.getExpirationDate( this.getLicense(), this.bIsRenewal );
    }
    
    public Boolean getRenewalDisabled() {
        if ( this.getLicense().sfLma__License_Status__c != 'Active' ) {
            return true;
        } else if ( this.getLicense().sfLma__Expiration__c <= Date.today() ) {
        	this.bIsRenewal = true;
        	return true;
        }
        return false;
    }
    
    public void createCharge() {
    	system.debug( LoggingLevel.ERROR, '### this.getToken() : ' + this.getToken() );
    	Payment.CreateCharge(
    		new Payment.ChargeInfo(
    			this.sOrganizationId,
    			this.getLicense(),
    			this.getTotalPrice(),
    			this.bIsRenewal,
    			this.newlicenses,
    			this.getDescription(),
				this.getToken()
    		)
    	);
    }
    
    private String getToken() {
    	return ApexPages.currentPage().getParameters().get( 'token' );
    }
    
    public String getStripePublishableKey() {
    	return Payment.getStripePublishableKey();
    }
    
    public class PageException extends Exception { }
}