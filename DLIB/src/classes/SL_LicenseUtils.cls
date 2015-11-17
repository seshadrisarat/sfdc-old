public class SL_LicenseUtils {
	public static Map<String, sfLma__License__c> getLicensesByPackageVersion( String sOrganizationId ) {
		Map<String, sfLma__License__c> aResult = new Map<String, sfLma__License__c>();
		
		for ( sfLma__License__c oItem : [
        	SELECT Id, sfLma__Package_Version__c, sfLma__Package_Version__r.Name, sfLma__Package_Version__r.sfLma__Version__c,
            	sfLma__Licensed_Seats__c, sfLma__Seats__c, sfLma__License_Status__c, sfLma__Expiration__c, sfLma__Contact__r.Email,
            	sfLma__Expiration_Date__c, Package_Name__c, sfLma__Package_Version__r.sfLma__Is_Beta__c, sfLma__Lead__r.Email,
            	sfLma__Package_Version__r.sfLma__Release_Date__c, sfLma__Package_Version__r.Package_Installation_URL__c,
            	sfLma__Package_Version__r.Version_Number__c, Discounted_License_Price__c, Discounted_License_Price_Expiration__c
        	FROM sfLma__License__c
            WHERE sfLma__Subscriber_Org_ID__c = :sOrganizationId AND
            	sfLma__Status__c IN ( 'Trial', 'Active', 'Suspended' )
		] ) {
        	aResult.put( oItem.sfLma__Package_Version__c, oItem );
        	System.debug('SL_LU|License Map key: ' + oItem.sfLma__Package_Version__c);
        	System.debug('SL_LU|License Map value: ' + oItem);
        }
        System.debug('SL_LU|License Map size: ' + aResult.size());
        return aResult;
	}
	
	public static String getPackageVersionName( sfLma__License__c oLicense ) {
		return oLicense.sfLma__Package_Version__r.sfLma__Version__c + ' - ' + oLicense.sfLma__Package_Version__r.Version_Number__c;
	}
	
	public static String getLicenseFullName( sfLma__License__c oLicense ) {
		return oLicense.sfLma__Package_Version__r.Name + ' - ' + oLicense.sfLma__Package_Version__r.Version_Number__c;
	}
	
	public static Integer getDaysLeft( sfLma__License__c oLicense ) {
		if ( oLicense.sfLma__Expiration__c > Date.today() ) {
			return Date.today().daysBetween( oLicense.sfLma__Expiration__c );
		}
		return 0;
	}
	
	public static Date getNewSubscriptionStartDate( sfLma__License__c oLicense ) {
		Date dExpirationDate = oLicense.sfLma__Expiration__c;
        
        if ( dExpirationDate <= Date.today() ) {
            return Date.today();
        }
        return dExpirationDate.addDays( 1 );
	}
	
	public static sfLma__Package_Version__c getMostRecentVersion( ID idPackageVersion ) {
		Id idCurrentPackage;
		for ( sfLma__Package_Version__c oItem : [ SELECT sfLma__Package__c FROM sfLma__Package_Version__c WHERE Id = :idPackageVersion ] ) {
			idCurrentPackage = oItem.sfLma__Package__c;
		}
		if ( idCurrentPackage == null ) {
			return null;
		}
		
		List<sfLma__Package_Version__c> aVersions = [
			SELECT Id, Name, sfLma__Release_Date__c, Version_Number__c, Package_Installation_URL__c
			FROM sfLma__Package_Version__c
			WHERE sfLma__Package__r.Id = :idCurrentPackage AND
				sfLma__Is_Beta__c = false
		];		
		if ( aVersions.isEmpty() ) {
			return null;
		}
			
		sfLma__Package_Version__c oMostRecentVersion = aVersions.get( 0 );
		for ( sfLma__Package_Version__c oItem : aVersions ) {
			if ( oItem.sfLma__Release_Date__c > oMostRecentVersion.sfLma__Release_Date__c) {
				oMostRecentVersion = oItem;
			}
		}
		return oMostRecentVersion;
	}
	
	public static Integer getTotalLicenses( sfLma__License__c oLicense, Integer nNewLicenses ) {
		Integer nResult = 0;
		 
        if( oLicense != null && oLicense.sfLma__Licensed_Seats__c != null && oLicense.sfLma__License_Status__c != 'Trial' ) {
            nResult += Integer.valueof( oLicense.sfLma__Seats__c );
        }        
        if ( nNewLicenses != null && nNewLicenses > 0 ) {
            nResult += nNewLicenses;
        }
        if ( nResult < 0 ) {
        	nResult = 0;
        }        
        return nResult;   
	}
	
	public static Date getProratedNewLicensesDescriptionDate( sfLma__License__c oLicense, Boolean bIsRenewal ) {
		if ( oLicense.sfLma__Expiration__c <= Date.today() || oLicense.sfLma__License_Status__c != 'Active' ) {
			return getExpirationDate( oLicense, bIsRenewal );
		}
		return oLicense.sfLma__Expiration__c;
    }
    
    public static Date getNewSubscriptionDescriptionDateFrom( sfLma__License__c oLicense, Boolean bIsRenewal ) {
    	if ( bIsRenewal ) {
    		return getNewSubscriptionStartDate( oLicense );
    	}
		return Date.today();
    }   
    
    public static Date getExpirationDate( sfLma__License__c oLicense, Boolean bIsRenewal ) {
        Date dResult;
		if ( oLicense.sfLma__License_Status__c != 'Active' ) {
			if ( oLicense.sfLma__Expiration__c <= Date.today() ) {
            	dResult = Date.today().addYears( 1 ).addDays( -1 );
			} else {
            	dResult = oLicense.sfLma__Expiration__c.addYears( 1 );
			}
        } else if ( oLicense.sfLma__License_Status__c == 'Active' && bIsRenewal ) {
			if ( oLicense.sfLma__Expiration__c <= Date.today() ) {
        		dResult = Date.today().addYears(1).addDays( -1 );
			} else {
        		dResult = oLicense.sfLma__Expiration__c.addYears( 1 );
			}
        } else {
        	if ( oLicense.sfLma__Expiration__c < Date.today() ) {
    			dResult = Date.today().addYears(1).addDays( -1 );
        	} else {
	            dResult = oLicense.sfLma__Expiration__c;
        	}
        }
        
        if ( dResult == null ) {
        	return Date.Today();
        }        
        return dResult;
    }
}