/**
 * \brief Controller for page BuyLicense3
 * \test Test_LicenseManager3_controller
 */
public without sharing class LicenseManager3_controller {
    public String packageversion {
    	get;
    	set {
    		packageversion = value;
			if(packageversion != null) {
	    		sfLma__License__c l = getLicense();
	    		
	   			if(l.sfLma__Expiration__c == null)
		        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your current license does not expire. Please contact support@silverlinecrm.com to buy additional licenses.'));
		        if(l.sfLma__Seats__c == -1)
		        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your current license is a site license. Please contact support@silverlinecrm.com to renew your license.'));
			}
   		}
    }
    public String PackageVersionName {
    	get {
    		sfLma__License__c l = getLicense();
    		return l.sfLma__Package_Version__r.sfLma__Version__c + ' - ' + l.sfLma__Package_Version__r.Version_Number__c;
    	} set;
    }
    
    public String LicenseFullName {
    	get {
    		//sfLma__License__c l = getLicense();
    		//return l.sfLma__Package_Version__r.Name + ' - ' + l.sfLma__Package_Version__r.Version_Number__c;
    		sfLma__Package_Version__c pv = getMostRecentVersion();
    		return pv.Name + ' - ' + pv.Version_Number__c;
    	}
    }
    
    //public String googleurl {get; set;}
    public List<SelectOption> items {get; set;}
    public Integer newlicenses {get; set;}
    public boolean renew {get; set;}
    //not used on page
    public boolean multiplelicenses {get; set;}
    
    public ID paymentID {get; set;}
    
    private map<string,sfLma__License__c> LicensesbyPackageVersion;
    private List<sfLma__License__c> licenses;
    public string organizationID {get;set;}
    
    public Decimal OneLicenseCost {
    	get {
    		return LicenseCostHelper3.CalculateYearlyCost(newlicenses, packageversion);
    		//return LicenseCostHelper3.DEFAULT_PRICE;
    	}
    }
    
    public Integer DaysLeft {
    	get {
    		Integer dl = 0;
    		sfLma__License__c lic = getLicense();
    		
    		//if(lic.sfLma__License_Status__c == 'Active')
			if(lic.sfLma__Expiration__c > Date.today())
				dl = Date.today().daysBetween(lic.sfLma__Expiration__c);
				
			return dl;
    	}
    }
    
    public Double PricePerLicense {
    	get {
    		sfLma__License__c l = getLicense();
    		
    		if(l.sfLma__Expiration__c < Date.today() || l.sfLma__License_Status__c == 'Trial')
    			return 0;
    		
    		Double yearlycost = LicenseCostHelper3.CalculateYearlyCost(newLicenses, packageversion);
	        Double totalprice = LicenseCostHelper3.CalculateTotalPrice(l, 1, yearlycost, false);

	        return totalprice;
    	}
    }
    
    public Double ProratedNewLicenseCharges {
    	get {
    		sfLma__License__c l = getLicense();
			if(l.sfLma__Expiration__c < Date.today() && l.sfLma__License_Status__c == 'Active')
				return 0;
    		
    		Double ch = 0;
    		
    		if(newLicenses > 0) {
    			Double yearlycost = LicenseCostHelper3.CalculateYearlyCost(newLicenses, packageversion);
	        	ch = LicenseCostHelper3.CalculateTotalPrice(l, newLicenses, yearlycost, false);
    		}
    		return ch;
    	}
    }
    
    public Double NewSubscriptionCharges {
    	get {
    		if(renew) {
    			return gettotallicenses() * getyearlycost().Price__c;
    		}
    		return 0;
    	}
    }
    
    public Date NewSubscriptionStartDate {
    	get {
    		sfLma__License__c l = getLicense();

    		Date expirationDate = l.sfLma__Expiration__c;
            
            if(expirationDate <= Date.today())
                return Date.today();
            	
            return expirationDate.addDays(1);
    	}
    }

	public sfLma__Package_Version__c getMostRecentVersion() {
		Id currentPackageId = [SELECT sfLma__Package__c FROM sfLma__Package_Version__c WHERE Id=:packageversion].sfLma__Package__c;
    		
		if(currentPackageId == null)
			return null;
		
		List<sfLma__Package_Version__c> versions = [SELECT Id, Name, sfLma__Release_Date__c, Version_Number__c, Package_Installation_URL__c FROM sfLma__Package_Version__c WHERE sfLma__Package__r.Id=:currentPackageId And sfLma__Is_Beta__c = false];
		if(versions.size() < 1)
			return null;
			
		sfLma__Package_Version__c mostRecentVersion = versions[0];
		for(sfLma__Package_Version__c pv : versions) {
			if(pv.sfLma__Release_Date__c > mostRecentVersion.sfLma__Release_Date__c)
				mostRecentVersion = pv;
		}
		
		return mostRecentVersion;
	}

    public String UpgradeLink {
    	get {
    		if(packageversion == null || packageversion == '')
    			return '';
    			
    		sfLma__Package_Version__c mrv = getMostRecentVersion();
    		if(mrv == null)
    			return '';
    		
    		if(mrv.Id == packageversion)
    			return '';
    		
    		UpgradeVersion = mrv.Version_Number__c;
    		
    		return mrv.Package_Installation_URL__c;
    	} private set;
    }
    
    public String UpgradeVersion { get; private set; }
    
    //not used on page
    public String checkoutLink {
        get {
            List<Google_Checkout_Settings__c> items = [select id,Name__c,Value__c 
                                                  from Google_Checkout_Settings__c
                                                  where Name__c = 'checkoutLink'];
            String res = '';
            
            if (items.size() > 0) {
                res = items[0].Value__c;
            }
            
            return res;
        }
    }
    
    public String digitalDescriptionString {
        get {
            String res = 'The licenses you have purchased should become available in your salesforce org shortly. If you have any issues with your order please contact <a href="mailto:support@silverlinecrm.com?Subject=Google%20Checkout%20Order">support@silverlinecrm.com</a>.';
            return res;
        }
    }
    
    public LicenseManager3_controller()
    {
        try
        {
            init();
            
            String orgID = System.currentPageReference().getParameters().get('orgid');
            organizationID = orgid;

            if(orgID == null || orgID == '')
            {
                throw new PageException('Woops! Looks like something went wrong. Please contact us at support@silverlinecrm.com for further assistance.');
            }
            
            licenses = FindLicenses(orgid); 
            if(licenses.IsEmpty())
            {
                throw new PageException('Woops! Looks like we couldn\'t find you. Please contact us at support@silverlinecrm.com for further assistance.');
            }
            
            for(sfLma__License__c lic : licenses)
            {
            	//this page doesn't handle site licenses or ones that do not expire
            	//if(lic.sfLma__Expiration__c <> null && lic.sfLma__Seats__c <> -1)
            	//{
                	LicensesbyPackageVersion.put(lic.sfLma__Package_Version__c,lic);
            	//}
            }
            
            items = getPackageVersionsList();

            if(items.size() > 0)
            	packageversion = items.get(0).getValue();
            
            if(LicensesbyPackageVersion.IsEmpty())
            {
            	if(licenses.get(0).sfLma__Expiration__c == null)
                {
                	throw new PageException('Your current license does not expire. Please contact support@silverlinecrm.com to buy additional licenses.');
                }
                if(licenses.get(0).sfLma__Seats__c == -1)
                {
                	throw new PageException('Your current license is a site license. Please contact support@silverlinecrm.com to renew your license.');
                }
            }
            //if there are multiple valid licenses the user will need to make a selection
            else if(LicensesbyPackageVersion.size() > 1)
            {
                multiplelicenses = true;
            }
            
            sfLma__License__c l = getLicense();
            if(l.sfLma__Expiration__c <= Date.today() && l.sfLma__License_Status__c == 'Active')
            	renew = true;
        }
        catch(Exception ex)
        {
        	if(ex.getmessage().contains('does not expire') || ex.getmessage().contains('site license'))
        	{
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));
        	}
        	else
        	{
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        	}
        }
    }
    
    private List<SelectOption> getPackageVersionsList() {
    	List<SelectOption> result = new List<SelectOption>();
    	
    	List<String> sortedItems = new List<String>();
        for(string key : LicensesbyPackageVersion.keyset())
        	sortedItems.add(LicensesbyPackageVersion.get(key).sfLma__Package_Version__r.Name);
        sortedItems.sort();
        
        for(string i : sortedItems) {
        	for(string key : LicensesbyPackageVersion.keyset()) {
        		if(LicensesbyPackageVersion.get(key).sfLma__Package_Version__r.Name == i)
        			result.add(new SelectOption(LicensesbyPackageVersion.get(key).sfLma__Package_Version__c, LicensesbyPackageVersion.get(key).sfLma__Package_Version__r.Name));
        	}
        }
        return result;
    }
    
    public void checkout()
    {
    	if(organizationID != null && organizationID != '') {
	    	sfLma__License__c l = getLicense();
	    	if(l != null) {
	    		Double t = gettotalprice().Price__c;
	    		if(t > 0) {
	    			Payment__c payment = new Payment__c();
			        payment.License__c = l.ID;
			        payment.Name = 'Payment for Licenses';
			        payment.Status__c = 'Pending';
			        payment.Total__c = t;
			        payment.Renewal__c = renew;
			        payment.new_licenses__c = newlicenses;
			        payment.Orgid__c = organizationID;
			        insert payment;
			        
			        paymentid = payment.ID;
	    		}
	    	}
    	}
    }
    
    public PageReference refresh()
    {
        if(newlicenses == null || newlicenses < 0)
            newlicenses = 0;
        
        if(getRenewalDisabled())
    		renew = false;
    	else {
    		sfLma__License__c l = getLicense();
	        if(l.sfLma__Expiration__c <= Date.today())
	        	renew = true;
	        else
	        	renew = false;
    	}
        
        return null;
    }
    
    public sfLma__License__c getLicense()
    {    	
        //if(!multiplelicenses && licenses.IsEmpty() == false)
        //    return licenses.get(0);
        
        return LicensesbyPackageVersion.get(packageversion);
    }
    
    public Integer gettotallicenses()
    {
        Integer total = 0;
        
        sfLma__License__c license = this.getLicense();
        
        if(license <> null && license.sfLma__Licensed_Seats__c <> null && license.sfLma__License_Status__c != 'Trial')
            total += Integer.valueof(license.sfLma__Seats__c);
        
        //system.debug('==== this.getLicense().sfLma__License_Status__c ==== '+this.getLicense().sfLma__License_Status__c);
            
        if(newlicenses <> null && newlicenses > 0)
            total += newlicenses;
        
        if (total < 0) total = 0;
        //system.debug('==== total ==== '+total);
        
        return total;   
    }
    
    public License_Price__c getyearlycost()
    {
        Integer NumLicenses = gettotallicenses();
        
        double yearlycost = LicenseCostHelper3.CalculateYearlyCost(NumLicenses, packageversion);
        
        License_Price__c tmp = new License_Price__c(price__c=yearlycost);
        return tmp;
    }
    
    public License_Price__c gettotalprice()
    {
        sfLma__License__c lic = getLicense();
        Integer NumLicenses = gettotallicenses();
        
        double yearlycost = LicenseCostHelper3.CalculateYearlyCost(NumLicenses, packageversion);
        double totalprice = LicenseCostHelper3.CalculateTotalPrice(lic, newlicenses, yearlycost, renew);
        
        License_Price__c tmp = new License_Price__c(Price__c = totalprice);
        return tmp;
    }
        
    private void init()
    {
        packageversion = null;
        //googleurl = '';
        items = new list<SelectOption>();
        newlicenses = 0;
        renew = false;
        multiplelicenses = false;
        LicensesbyPackageVersion = new map<string,sfLma__License__c>();
        licenses = new list<sfLma__License__c>();
    }
    
    private static List<sfLma__License__c> FindLicenses(string orgid)
    {
        List<sfLma__License__c> lics = [Select
                                        s.sfLma__Package_Version__c,
                                        s.sfLma__Package_Version__r.Name,
                                        s.sfLma__Package_Version__r.sfLma__Version__c,
                                        s.sfLma__Licensed_Seats__c,
                                        s.sfLma__Seats__c, 
                                        s.sfLma__License_Status__c, 
                                        s.sfLma__Expiration__c, 
                                        s.sfLma__Expiration_Date__c,
                                        Package_Name__c,
                                        sfLma__Package_Version__r.sfLma__Is_Beta__c,
                                        sfLma__Package_Version__r.sfLma__Release_Date__c,
                                        sfLma__Package_Version__r.Package_Installation_URL__c,
                                        sfLma__Package_Version__r.Version_Number__c,
                                        s.Id 
                                        From sfLma__License__c s
                                        where s.sfLma__Subscriber_Org_ID__c = :orgID 
                                        and s.sfLma__Status__c in ('Trial','Active','Suspended')];
        
        return lics;
    }
    
    public string getDescription()
    {
        String description = '';//'You are purcasing ';
        sfLma__License__c lic = getlicense();
        //Description += 'You are purchasing ' + String.valueof(gettotallicenses()) + ' licenses of ' + lic.sfLma__Package_Version__r.Name;
        
        if(!renew || (renew && newlicenses > 0))
        	description += 'New Licenses($' + ProratedNewLicenseCharges + '): ' + newlicenses + ' users – expires ' + dateToString(ProratedNewLicensesDescriptionDate);
        if(newlicenses > 0 && renew)
        	description += ' and ';
        if(renew)
        	description += 'New Subscription($' + NewSubscriptionCharges + '): ' + getTotalLicenses() + ' users – ' + dateToString(NewSubscriptionDescriptionDateFrom) + ' to ' + dateToString(NewSubscriptionDescriptionDateTo);
        
        //description += ' in the amount of $' + getTotalPrice().Price__c;
        
        return description;
    }
    
    public Date ProratedNewLicensesDescriptionDate {
    	get {
    		sfLma__License__c lic = getlicense();
    		if(lic.sfLma__Expiration__c <= Date.today() || lic.sfLma__License_Status__c != 'Active')
    			return getExpirationDate();
    		
			return lic.sfLma__Expiration__c;
    	} set;
    }
    
    public Date NewSubscriptionDescriptionDateFrom {
    	get {
    		if(renew)
    			return NewSubscriptionStartDate;
			
			return Date.today();
    	} set;
    }
    
    public Date NewSubscriptionDescriptionDateTo {
    	get {
    		return getExpirationDate();
    	} set;
    }
    
    private String dateToString(Date d) {
    	return d.month() + '/' + d.day() + '/' + d.year();
    }
    
    public Date getExpirationDate()
    {
        Date res = Date.Today();
        sfLma__License__c license = getLicense();
        
        if (license.sfLma__License_Status__c != 'Active') 
        {
            if(license.sfLma__Expiration__c <= Date.today())
            	res = Date.today().addYears(1).addDays(-1);
            else
            	res = license.sfLma__Expiration__c.addYears(1);
        } 
        else if (license.sfLma__License_Status__c == 'Active' && renew) 
        {
        	if(license.sfLma__Expiration__c <= Date.today())
        		res = Date.today().addYears(1).addDays(-1);
        	else
        		res = license.sfLma__Expiration__c.addYears(1);
        } 
        else 
        {
        	if(license.sfLma__Expiration__c < Date.today())
    			res = Date.today().addYears(1).addDays(-1);
        	else
	            res = license.sfLma__Expiration__c;
        }
        
        return res;
    }
    
    public boolean getRenewalDisabled()
    {
    	sfLma__License__c l = GetLicense();
        if (l != null) {
            if(l.sfLma__License_Status__c != 'Active') {
                return true;
            }
            else if(l.sfLma__Expiration__c <= Date.today()) {
            	renew = true;
            	return true;
            }
        }
        return false;   
    }
    
    public class PageException extends Exception{}
}