/*
Developer Name: Angela Williams
*/
public with sharing class AccountServices
{ 
	public static boolean disablePardotLogCheck = false;
	public static boolean disableDealerBrandTriggerProcessing = false;
	public static boolean disableTriggerProcessing = false;
    final static String CLASSNAME = '\n\n**** AccountServices.METHODNAME()';
    public static Boolean ranPopulateAccountGeoFields = False; 
    public static Boolean isApexTest= false;
    public static Integer MAX_ACCOUNT_GEOCODE_BATCH_SIZE = 10;
    public static integer ACCOUNT_SCORE_THRESHOLD = 50;
    
    final static String UNITED_STATES = 'US';
    final static String UNITED_STATES_OF_AMERICA = 'USA';
    final static String CANADA = 'CA';
    
    //BS-265 (David Hickman)
    public static Map<Id, RecordType> allAccountRecordTypes {
        get{
            
            if (allAccountRecordTypes == null){
                allAccountRecordTypes = new Map<Id, RecordType>([Select Id, DeveloperName From RecordType Where SObjectType = 'Account']);
                system.debug('Account record types: ' + allAccountRecordTypes);
            }
            return allAccountRecordTypes;
        }
        set;
    }
    
    
    
   	@future (callout = true)     
    public static void populateAccountGeoFieldsFuture(Set<ID> AccountIDs) {
    	populateAccountGeoFields(AccountIDs);	
    }
    
    
    
    public static list<Account> getDealerAccountsForRouting(set<Id> accountIds) {
    	return [Select Id, 
    				   ShippingPostalCode, 
    				   shippingcity, 
    				   shippingCountry, 
    				   Country_ISO_Code__c, 
    				   county__c, 
    				   latitude__c, 
    				   longitude__c,
    				   GeoLocation__Latitude__s,
    				   GeoLocation__Longitude__s,
    				   Brand__c,
    				   CreatedDate,
    				   GeoNames_WebService_Error__c,
    				   Notes__pc,
                	   Geonames_Retry__c
    				   from Account where id in: accountIds];
    }
    
    // method to call GeoWebService and populate Geo fields on Account.    
    public static void populateAccountGeoFields(Set<ID> AccountIDs)
    {
    	AccountServices.ranPopulateAccountGeoFields = true;
    	try {
	        String METHODNAME = CLASSNAME.replace('METHODNAME', 'populateAccountGeoFields');
	        system.debug(LoggingLevel.DEBUG, METHODNAME.replace('**** ', '**** Inside ') + ' \n\n');
	        // list to store account records which needs to be updated.        
	        list<Account> AccountUpdateList = new list<Account>();   
	        //AccountList will store all account records whose id is in AccountIDs
	        list<Account> AccountList = getDealerAccountsForRouting(AccountIDs);               
	        // Loop thorugh each account record
	        for(Account acc : AccountList) { 
	            acc.Latitude__c = null;
	            acc.Longitude__c = null;           
	            map<String, String> AccountFieldsMap = new Map<String, String>();          
	            AccountFieldsMap.clear();        
	            
	            if(((acc.Country_ISO_Code__c == UNITED_STATES || acc.Country_ISO_Code__c == CANADA) && acc.ShippingPostalCode != null) ||
	               ((acc.Country_ISO_Code__c != UNITED_STATES && acc.Country_ISO_Code__c != CANADA && acc.Country_ISO_Code__c != UNITED_STATES_OF_AMERICA) && acc.ShippingPostalCode != null) ){                   
	                   
	                   String cleanedPostalCode = ''; 
	                   if(acc.ShippingPostalCode.Contains('-')){
	                       cleanedPostalCode = acc.ShippingPostalCode.subString(0,5);
	                   }else{
	                       cleanedPostalCode = acc.ShippingPostalCode; 	
	                   }
	                   AccountFieldsMap = GeoNamesWebService.getLocationInfo(EncodingUtil.urlEncode(cleanedPostalCode,'UTF-8'), acc.Country_ISO_Code__c,null, false);
	               }   
	            if((AccountFieldsMap.values().isEmpty() && (acc.Country_ISO_Code__c != UNITED_STATES && acc.Country_ISO_Code__c != CANADA) && acc.shippingcity != null)){  
	                AccountFieldsMap = GeoNamesWebService.getLocationInfo(null, acc.Country_ISO_Code__c, EncodingUtil.urlEncode(acc.shippingcity,'UTF-8'),false);
	            }   
	            
	            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: Map value***'+AccountFieldsMap );  
	            Boolean updFlag = False;        
	            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: AccountFieldsMap '+AccountFieldsMap);         
	            
	            if(AccountFieldsMap.isEmpty()) {
	                acc.Latitude__c = null;
	                acc.Longitude__c = null;
	                acc.GeoLocation__Latitude__s = null;
	                acc.GeoLocation__Longitude__s = null;
	                updFlag = True;
	            }  
	            
	            if(AccountFieldsMap.get('adminName2') != null) {      
	                acc.county__c = AccountFieldsMap.get('adminName2').contains('County') ?  AccountFieldsMap.get('adminName2').remove('County').trim() : AccountFieldsMap.get('adminName2');            	       
	                acc.GeoNames_WebService_Error__c = '';       
	                updFlag = True;                     
	            }            
	            if(AccountFieldsMap.get('lat') != null) {   
	                acc.latitude__c = decimal.valueOf(AccountFieldsMap.get('lat'));   
	                acc.GeoLocation__Latitude__s = decimal.valueOf(AccountFieldsMap.get('lat'));   
	                acc.GeoNames_WebService_Error__c = '';             
	                updFlag = True;     
	            }            
	            if(AccountFieldsMap.get('lng') != null) {  
	                acc.longitude__c = decimal.valueOf(AccountFieldsMap.get('lng')); 
	                acc.GeoLocation__Longitude__s = decimal.valueOf(AccountFieldsMap.get('lng')); 
	                acc.GeoNames_WebService_Error__c = '';
	                updFlag = True;    
	            }   
	            if(AccountFieldsMap.get('WebService Exception: ') != null) {    
	                acc.GeoNames_WebService_Error__c = AccountFieldsMap.get('WebService Exception: ');
	                updFlag = True;     
	            }   
	            if(AccountFieldsMap.get('XML Parsing Exception: ') != null)
	            { 
	                if(AccountFieldsMap.get('WebService Exception: ') != null) {    
	                    acc.GeoNames_WebService_Error__c += AccountFieldsMap.get('XML Parsing Exception: ');   
	                } else {                 
	                    acc.GeoNames_WebService_Error__c += AccountFieldsMap.get('XML Parsing Exception: ');  
	                }
	                updFlag = True;  
	            }  
	            if(updFlag == True) {      
	            	acc.Geonames_Retry__c = false;
	                AccountUpdateList.add(acc);   
	            } 
	        } 
	        // Update AccountUpdateList list if it has atleast 1 record    
	        if(AccountUpdateList.size() > 0) {     
	            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: AccountUpdateList '+AccountUpdateList); 
	            try {
	                update AccountUpdateList; 
	            } 
	            catch(DMLException ex) {      
	                system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: update exception '+ ex);   
	            }
	        }
    	}
    	finally {
    		//AccountServices.ranPopulateAccountGeoFields = false;
    	}
        
    }
    
    final static String DEALER = 'Dealer';	
    public static Id getDealerRecordType() {
    	list<RecordType> recordTypes = [Select id from RecordType where developerName = 'Dealer' and SobjectType = 'Account'];
    	if (recordTypes != null && recordTypes.size() > 0) {
    		return recordTypes[0].Id;
    	}
    	system.debug('No dealer record type was found');
    	return null;
    }
    final static set<Id> dealerAccountIds = new set<Id>();
    
    public static set<Id> getDealerAccountIds (list<Account> accRecords){
        Id dealerRecordType = getDealerRecordType();
        final set<String> recordTypeNames = new Set<String>{DEALER};	
            
            for(Account rec: accRecords){
                if(dealerRecordType == rec.recordTypeId){
                    dealerAccountIds.add(rec.Id);
                }
            }
        return dealerAccountIds;
    }
    
    public static list<Account> getDealerAccounts (list<Account> accRecords){
    	list<Account> dealerAccounts = new list<Account>();
        Id dealerRecordType = getDealerRecordType();
        for(Account rec: accRecords){
         	if	(dealerRecordType == rec.recordTypeId){
             	dealerAccounts.add(rec);
            }
        }
        return dealerAccounts;
    }
    
    public static void markNewAccountForGeocodingRetry(list<Account> accountList) {
    	if (!System.isFuture()) {
	    	for (Account account : accountList) {
	    		account.Geonames_Retry__c = true;
	    	}
        }
    }
    
    public static void markAccountForGeocodingRetryIfAddressHasChanged(map<Id, Account> oldMap, map<Id, Account> newMap) {
    	if( !System.isFuture()) {	
       		for (Id accountId : newMap.keySet()) {
       			Account oldAccount = oldMap.get(accountId);
       			Account newAccount = newMap.get(accountId);
       			
       			if (accountAddressHasChanged(oldAccount, newAccount)) {
       				newAccount.Geonames_Retry__c = true;
       			}
       		}  	
    	}
    }
    
    private static boolean accountAddressHasChanged(Account oldAccount, Account newAccount) {
        if (StringUtils.isNotEqualIgnoreCase(oldAccount.PersonMailingPostalCode, newAccount.PersonMailingPostalCode) ||
        	StringUtils.isNotEqualIgnoreCase(oldAccount.ShippingPostalCode, newAccount.ShippingPostalCode) ||
    		StringUtils.isNotEqualIgnoreCase(oldAccount.Home_Address_ISO_Code__c, newAccount.Home_Address_ISO_Code__c) ||
    		StringUtils.isNotEqualIgnoreCase(oldAccount.Country_ISO_Code__c, newAccount.Country_ISO_Code__c) ||
    		StringUtils.isNotEqualIgnoreCase(oldAccount.PersonMailingCity, newAccount.PersonMailingCity) ||
    		StringUtils.isNotEqualIgnoreCase(oldAccount.ShippingCity, newAccount.ShippingCity)) {
        	return true;
        } 
        
        return false;
    }
    
    public static void geocodeDealersIfAddressHasChanged(map<Id, Account> oldMap, map<Id, Account> newMap) {
    	set<Id> dealerIdsWithChangedAddress = new set<Id>();
    	
    	for (Id accountId : newMap.keySet()) {
       		Account oldAccount = oldMap.get(accountId);
       		Account newAccount = newMap.get(accountId);
    		if (accountAddressHasChanged(oldAccount, newAccount)) {
    			dealerIdsWithChangedAddress.add(accountId);	
    		}
    	}
    	
    	if (!dealerIdsWithChangedAddress.isEmpty()) {
    		system.debug('dealers with changed address=' + dealerIdsWithChangedAddress);
    		AccountServices.ranPopulateAccountGeoFields = true;
    		populateAccountGeoFieldsFuture(dealerIdsWithChangedAddress);
    	}
    }
    
    public static void geocodeOwnersIfAddressHasChanged(map<Id, Account> oldMap, map<Id, Account> newMap) {
    	set<Id> ownerIdsWithChangedAddress = new set<Id>();
    	
    	for (Id accountId : newMap.keySet()) {
       		Account oldAccount = oldMap.get(accountId);
       		Account newAccount = newMap.get(accountId);
    		if (accountAddressHasChanged(oldAccount, newAccount)) {
    			ownerIdsWithChangedAddress.add(accountId);	
    		}
    	}
    	
    	if (!ownerIdsWithChangedAddress.isEmpty()) {
    		system.debug('owners with changed address=' + ownerIdsWithChangedAddress);
    		OwnerServices.schedulePopulateOwnerGeoFields(ownerIdsWithChangedAddress);
    	}
    }
    
    public static void scheduleDealerGeocodingJob(list<Account> dealerList) {
    	if (!dealerList.isEmpty() && !System.isFuture()) {
	        if ([Select Count() From AsyncApexJob a Where a.ApexClassId = :GEONAMES_DEALER_BATCH_CLASS_ID And Status In ('Preparing', 'Processing', 'Queued')] < 1) {
	        	system.debug('scheduling dealer geocoding job');
	        	AccountServices.ranPopulateAccountGeoFields = true;
		        GeonamesDealerErrorHandlingBatch batch = new GeonamesDealerErrorHandlingBatch();
		        if (Test.isRunningTest()) {
	    	    	Database.executeBatch(batch, 100);
		        }
		        else {
		        	Database.executeBatch(batch, MAX_ACCOUNT_GEOCODE_BATCH_SIZE);
		        }
	    	}
    	}
    }
    
    public static void scheduleDealerGeocodingJobIfAddressHasChanged(map<Id, Account> oldMap, map<Id, Account> newMap) {
    	if (!newMap.isEmpty() && !System.isFuture()) {
    		boolean hasChangedAddress = false;
    		
    		for (Id accountId : newMap.keySet()) {
       			Account oldAccount = oldMap.get(accountId);
       			Account newAccount = newMap.get(accountId);
    			if (accountAddressHasChanged(oldAccount, newAccount)) {
    				hasChangedAddress = true;
    				break;
    			}
    		}
    		
    		if (hasChangedAddress) {
		        if ([Select Count() From AsyncApexJob a Where a.ApexClassId = :GEONAMES_DEALER_BATCH_CLASS_ID And Status In ('Preparing', 'Processing', 'Queued')] < 1) {
		        	system.debug('scheduling dealer geocoding job');
		        	AccountServices.ranPopulateAccountGeoFields = true;
			        GeonamesDealerErrorHandlingBatch batch = new GeonamesDealerErrorHandlingBatch();
			        if (Test.isRunningTest()) {
		    	    	Database.executeBatch(batch, 100);
			        }
			        else {
			        	Database.executeBatch(batch, MAX_ACCOUNT_GEOCODE_BATCH_SIZE);
			        }
		    	}
    		}
    	}
    }
    
    public static void scheduleOwnerGeocodingJob(list<Account> ownerList) {
    	if (!ownerList.isEmpty() && !System.isFuture()) {
	        if ([Select Count() From AsyncApexJob a Where a.ApexClassId = :GEONAMES_OWNER_BATCH_CLASS_ID And Status In ('Preparing', 'Processing', 'Queued')] < 1) {
	        	system.debug('scheduling owner geocoding job');
		        GeonamesOwnerErrorHandlingBatch batch = new GeonamesOwnerErrorHandlingBatch();
	    	    if (Test.isRunningTest()) {
	    	    	Database.executeBatch(batch, 100);
		        }
		        else {
		        	Database.executeBatch(batch, MAX_ACCOUNT_GEOCODE_BATCH_SIZE);
		        }
	    	}
    	}
    }
    
    public static void scheduleOwnerGeocodingJobIfAddressHasChanged(map<Id, Account> oldMap, map<Id, Account> newMap) {
    	if (!newMap.isEmpty() && !System.isFuture()) {
    		boolean hasChangedAddress = false;
    		
    		for (Id accountId : newMap.keySet()) {
       			Account oldAccount = oldMap.get(accountId);
       			Account newAccount = newMap.get(accountId);
    			if (accountAddressHasChanged(oldAccount, newAccount)) {
    				hasChangedAddress = true;
    				break;
    			}
    		}
    		
    		if (hasChangedAddress) {
		        if ([Select Count() From AsyncApexJob a Where a.ApexClassId = :GEONAMES_OWNER_BATCH_CLASS_ID And Status In ('Preparing', 'Processing', 'Queued')] < 1) {
		        	system.debug('scheduling owner geocoding job');
			        GeonamesOwnerErrorHandlingBatch batch = new GeonamesOwnerErrorHandlingBatch();
		    	    if (Test.isRunningTest()) {
		    	    	Database.executeBatch(batch, 100);
			        }
			        else {
			        	Database.executeBatch(batch, MAX_ACCOUNT_GEOCODE_BATCH_SIZE);
			        }
		    	}
    		}
    	}
    }
    
    public static Id GEONAMES_DEALER_BATCH_CLASS_ID {
    	get {
	    	if (GEONAMES_DEALER_BATCH_CLASS_ID == null) {
	    		GEONAMES_DEALER_BATCH_CLASS_ID = [Select a.Id From ApexClass a Where Name = 'GeonamesDealerErrorHandlingBatch'].Id;
	    	}
	    	return GEONAMES_DEALER_BATCH_CLASS_ID;
    	}
    	set;	
    }
    
    public static Id GEONAMES_OWNER_BATCH_CLASS_ID {
    	get {
	    	if (GEONAMES_OWNER_BATCH_CLASS_ID == null) {
	    		GEONAMES_OWNER_BATCH_CLASS_ID = [Select a.Id From ApexClass a Where Name = 'GeonamesOwnerErrorHandlingBatch'].Id;
	    	}
	    	return GEONAMES_OWNER_BATCH_CLASS_ID;
    	}
    	set;	
    }
    
    
   /*
	* BS-265 (David Hickman)
	* Need to exclude the "Media" and "Marketing Partner" record types from executing the trigger
	*
	*/
    public static List<Account> qualifyAccountRecordTypesForTrigger(List<Account> accountList) {
    	
    	List<Account> validateList = new List<Account>(accountList);
    	
    	for (Integer x = 0; x < validateList.size(); x++) {
    		if (allAccountRecordTypes.get(validateList.get(x).RecordTypeId).DeveloperName.equalsIgnoreCase('Media') ||
    		    allAccountRecordTypes.get(validateList.get(x).RecordTypeId).DeveloperName.equalsIgnoreCase('Marketing_Partners')) {
    		    validateList.remove(x);
    		}
    	}
    	
    	return validateList;
    }
}