public without sharing class LicenseCostHelper {
	//public static Decimal OLD_PRICE = 60.0;
	public static Decimal DEFAULT_PRICE = 96.0;
	 
// fake_license_changes
	private static Map<String, sfLma__License__c> LicensesByPackageVersion = null;	
//	private static Map<String, License__c> LicensesByPackageVersion = null;
	
// fake_license_changes
	public static Decimal CalculateYearlyCost( sfLma__License__c oLicense, Integer NumLicenses, ID packageversion ) {
//	public static Decimal CalculateYearlyCost( License__c oLicense, Integer NumLicenses, ID packageversion ) {		
		System.debug('LCH|Is oLicense Null: ' + oLicense == null ? 'yes':'no');
		System.debug('LCH|oLicense: ' + oLicense);
		if ( oLicense.Discounted_License_Price_Expiration__c != null && oLicense.Discounted_License_Price__c != null && oLicense.Discounted_License_Price_Expiration__c >= Date.today() ) {
			return oLicense.Discounted_License_Price__c;
		}
		
		list<License_Price__c> prices = [select Price__c from License_Price__c where package_version__c = :packageversion and Min__c <= :NumLicenses and Max__c >= :NumLicenses limit 1];
		
		if(prices.IsEmpty() == false)
			return prices.get(0).Price__c; 
		
		return DEFAULT_PRICE;
	}
	
// fake_license_changes
	public static Decimal CalculateTotalPrice(sfLma__License__c lic, Integer newlicenses, Decimal yearlycost, boolean renew)
//	public static Decimal CalculateTotalPrice(License__c lic, Integer newlicenses, Decimal yearlycost, boolean renew)
	{
		Decimal totalprice=0;
				
		if (lic != null) 
		{
// fake_license_changes
			if(lic.sfLma__License_Status__c != 'Active')
//			if(lic.sfLma_License_Status__c != 'Active')
			{
				totalprice = yearlycost * newlicenses;
			}
// fake_license_changes
			else if(lic.sfLma__License_Status__c == 'Active' && renew)
//			else if(lic.sfLma_License_Status__c == 'Active' && renew)
			{
// fake_license_changes
				totalprice = Integer.valueOf(lic.sfLma__Seats__c) * yearlycost; 
				if(lic.sfLma__Expiration__c > Date.today())
					totalprice += newlicenses * yearlycost + (yearlycost / 365 * Date.today().daysBetween(lic.sfLma__Expiration__c) * newlicenses);
//				totalprice = Integer.valueOf(lic.sfLma_Seats__c) * yearlycost; 
//				if(lic.sfLma_Expiration__c > Date.today())
//					totalprice += newlicenses * yearlycost + (yearlycost / 365 * Date.today().daysBetween(lic.sfLma_Expiration__c) * newlicenses);
				else
					totalprice += newlicenses * yearlycost;
			}
// fake_license_changes
			else if(lic.sfLma__License_Status__c == 'Active' && !renew)
//			else if(lic.sfLma_License_Status__c == 'Active' && !renew)
			{
// fake_license_changes
				if(lic.sfLma__Expiration__c > Date.today())
					totalprice = yearlycost / 365 * Date.today().daysBetween(lic.sfLma__Expiration__c) * newlicenses;
//				if(lic.sfLma_Expiration__c > Date.today())
//					totalprice = yearlycost / 365 * Date.today().daysBetween(lic.sfLma_Expiration__c) * newlicenses;
				else
					totalprice = newlicenses * yearlycost;
			}
		}
		
		totalprice = totalprice.setscale(2);
		
		return totalprice;
	}	
	
	public static Decimal getOneLicenseCost( sfLma__License__c oLicense, Boolean bIsRenewal, Integer nNewLicenses, String sPackageVersion ) {
		return CalculateYearlyCost( oLicense, (Integer)( !bIsRenewal ? nNewLicenses : nNewLicenses + oLicense.sfLma__Seats__c ), sPackageVersion );
	}
	
	public static Decimal getPricePerLicense( sfLma__License__c oLicense, Boolean bIsRenewal, Integer nNewLicenses, String sPackageVersion ) {
		if ( oLicense.sfLma__Expiration__c < Date.today() || oLicense.sfLma__License_Status__c == 'Trial' ) {
			return 0;
		}
		return CalculateTotalPrice( oLicense, 1, getOneLicenseCost( oLicense, bIsRenewal, nNewlicenses, sPackageVersion ), false );
	}
	
	public static Decimal getProratedNewLicenseCharges( sfLma__License__c oLicense, Boolean bIsRenewal, Integer nNewLicenses, String sPackageVersion ) {
		if ( ( oLicense.sfLma__Expiration__c < Date.today() && oLicense.sfLma__License_Status__c == 'Active' ) || nNewLicenses <= 0 ) {
			return 0;
		}
		return CalculateTotalPrice( oLicense, nNewlicenses, getOneLicenseCost( oLicense, bIsRenewal, nNewlicenses, sPackageVersion ), false );
	}
	
	public static Double getNewSubscriptionCharges( Boolean bIsRenewal, Integer nTotalLicenses, Decimal nYearlyCost ) {
    	if ( bIsRenewal ) {
			return nTotalLicenses * nYearlyCost;
		}
		return 0;
    }
}