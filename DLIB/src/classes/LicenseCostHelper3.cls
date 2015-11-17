public without sharing class LicenseCostHelper3 {
	
	public static Decimal DEFAULT_PRICE = 60.0;
	
	public static Decimal CalculateYearlyCost(Integer NumLicenses, ID packageversion){
		
		list<License_Price__c> prices = [select Price__c from License_Price__c where package_version__c = :packageversion and Min__c <= :NumLicenses and Max__c >= :NumLicenses limit 1];
		
		if(prices.IsEmpty() == false)
			return prices.get(0).Price__c; 
		
		return DEFAULT_PRICE;
	}
	
	public static Decimal CalculateTotalPrice(sfLma__License__c lic, Integer newlicenses, Decimal yearlycost, boolean renew)
	{
		Decimal totalprice=0;
				
		if (lic != null) 
		{
			if(lic.sfLma__License_Status__c != 'Active')
			{
				totalprice = yearlycost * newlicenses;	
			}
			else if(lic.sfLma__License_Status__c == 'Active' && renew)
			{
				totalprice = Integer.valueOf(lic.sfLma__Seats__c) * yearlycost; 
				if(lic.sfLma__Expiration__c > Date.today())
					totalprice += newlicenses * yearlycost + (yearlycost / 365 * Date.today().daysBetween(lic.sfLma__Expiration__c) * newlicenses);
				else
					totalprice += newlicenses * yearlycost;
			}
			else if(lic.sfLma__License_Status__c == 'Active' && !renew)
			{
				if(lic.sfLma__Expiration__c > Date.today())
					totalprice = yearlycost / 365 * Date.today().daysBetween(lic.sfLma__Expiration__c) * newlicenses;
				else
					totalprice = newlicenses * yearlycost;
			}
		}
		
		totalprice = totalprice.setscale(2);
		
		return totalprice;
	}	

}