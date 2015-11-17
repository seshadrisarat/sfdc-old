@RestResource(urlMapping='/TerritoryDeletionV2')
global with sharing class TerritoryDeletionServiceV2
{
	public static final String JOIN_DELIMITER = '::';
	public static final String OK_RESULT = 'success';
	public static final String FAILURE_RESULT = 'failed';

	public static Map<String, Set<String>> brandToTerritoryColumns {
		get {
			if (brandToTerritoryColumns == null){
				brandToTerritoryColumns = new Map<String, Set<String>>();
				for (TerritoryDeletionSettings__c cs : TerritoryDeletionSettings__c.getAll().values()){
					brandToTerritoryColumns.put(cs.Name, new Set<String>(cs.Columns_To_Use__c.split(';')));
				}
			}
			return brandToTerritoryColumns;
		}
		set;
	}

	private static final Map<String, String> PACKAGE_PROPERTY_TO_FIELD = new Map<String, String>{ 'dealerBrand' => 'Brand__c',
                                                                                                    'productCategory' => 'Boat_Class__c',
                                                                                                    'country' => 'Country_formula__c',
                                                                                                    'state' => 'State_Province__c',
                                                                                                    'county' => 'County__c',
                                                                                                    'postalCode' => 'Zipcode_Postal_Code__c' };

    @HttpPost
    global static TerritoryDeletionPackageResult deleteTerritory( TerritoryDeletionPackage thePackage )
    {
       system.debug('TerritoryDeletionService - deleteTerritory');
    	
        Set<String> uniqueDealerBrands = new Set<String>();
        Set<String> seenDealerBrands = new Set<String>();
        Set<String> seenCategories = new Set<String>();
        Set<String> seenCountries = new Set<String>();
        Set<String> seenStates = new Set<String>();
        Set<String> seenCounties = new Set<String>();
        Set<String> seenPostalCodes = new Set<String>();
        for( TerritoryDeletionRecord aRecord : thePackage.values )
        {
            uniqueDealerBrands.add( aRecord.dealerBrandId );
            seenDealerBrands.add( aRecord.dealerBrand );
            seenCategories.add( aRecord.productCategory );
            seenCountries.add( aRecord.country );
            seenStates.add( aRecord.state );
            seenCounties.add( aRecord.county );
            seenPostalCodes.add( aRecord.postalCode );
        }

        List<Territory__c> territoriesToDelete = new List<Territory__c>();
        TerritoryDeletionPackageResult deletionResult = new TerritoryDeletionPackageResult();
        String dealerBrandsQuery = 'SELECT Id, Unique_ID__c, ' + 
        					'(SELECT Id, ' + String.join(PACKAGE_PROPERTY_TO_FIELD.values(), ', ') + 
        					' FROM Territories__r ' + 
        					' WHERE Brand__c IN :seenDealerBrands ' + 
                            ' OR Boat_Class__c IN :seenCategories ' + 
                            ' OR Country_formula__c IN :seenCountries ' + 
                            ' OR State_Province__c IN :seenStates ' + 
                            ' OR County__c IN :seenCounties ' + 
                            ' OR Zipcode_Postal_Code__c IN :seenPostalCodes) ' + 
                            ' FROM Dealer_Brand__c WHERE Unique_ID__c IN :uniqueDealerBrands';
                            
        for (Dealer_Brand__c[] dealerBrands : [
        	SELECT Id, Unique_ID__c,
        		(SELECT Id, Brand__c, Boat_Class__c, Country_formula__c, Zipcode_Postal_Code__c, State_Province__c, County__c
        		 FROM Territories__r
        		 WHERE
        		 	Brand__c IN :seenDealerBrands
        		 	OR Boat_Class__c IN :seenCategories
        		 	OR Country_formula__c IN :seenCountries
        		 	OR State_Province__c IN :seenStates
        		 	OR County__c IN :seenCounties
        		 	OR Zipcode_Postal_Code__c IN :seenPostalCodes)
        	FROM Dealer_Brand__c WHERE Unique_ID__c IN :uniqueDealerBrands
        	]) {
        		


	       	//List<Dealer_Brand__c> dealerBrands = (List<Dealer_Brand__c>)Database.query(dealerBrandsQuery);           
	       	
	        // group dealer brands by Unique ID
	        Map<String, List<Dealer_Brand__c>> brandsByUniqueId = GroupBy.strings( 'Unique_ID__c', dealerBrands );
	        Map<String, Map<String, Territory__c>> uniqueBrandIdToTerritoriesByKey = new Map<String, Map<String, Territory__c>>();
	        // for every unique ID that was retrieved
	        for( List<Dealer_Brand__c> aDealerBrand : brandsByUniqueId.values() )
	        {
	            Map<String, Territory__c> hashedTerritories = new Map<String, Territory__c>();
	            //List<Territory__c> relatedTerritories = aDealerBrand[0].Territories__r;
	            //for( Territory__c aTerritory : relatedTerritories )
	            for( Territory__c aTerritory : aDealerBrand[0].Territories__r )
	            {
	            	if ( brandToTerritoryColumns.containsKey(aTerritory.Brand__c) ){
		                List<String> seenValues = new List<String>();
		                // retrieve package columns to use for the territory's brand
		                for( String aColumn : brandToTerritoryColumns.get( aTerritory.Brand__c ) )
		                {
		                    // get related sfdc field to use based on package property
		                    seenValues.add( (String)aTerritory.get( PACKAGE_PROPERTY_TO_FIELD.get(aColumn) ) );
		                }
		                hashedTerritories.put( String.join( seenValues, JOIN_DELIMITER ), aTerritory );
	            	} 
	            }
	            uniqueBrandIdToTerritoriesByKey.put( aDealerBrand[0].Unique_ID__c, hashedTerritories );
	        }
	
			Map<TerritoryDeletionRecord, Id> territoryToDeletionRecord = new Map<TerritoryDeletionRecord, Id>();
			
			Map<TerritoryDeletionRecord, String> territoryDeletionRecordToMessage = new Map<TerritoryDeletionRecord, String>();
			
	        for( TerritoryDeletionRecord aRecord : thePackage.values )
	        {
	            Map<String, String> recordAsMap = (Map<String, String>)JSON.deserialize( JSON.serialize(aRecord), Map<String, String>.class );
	            Map<String, Territory__c> relatedTerritories = uniqueBrandIdToTerritoriesByKey.get( aRecord.dealerBrandId );
	            List<String> seenValues = new List<String>();
	            
	            if ( brandToTerritoryColumns.containsKey(aRecord.dealerBrand) ){
	            	
	            	for( String aColumn : brandToTerritoryColumns.get( aRecord.dealerBrand ) )
		            {
		                seenValues.add( recordAsMap.get( aColumn ) );
		            }
		            String hash = String.join( seenValues, JOIN_DELIMITER );
	
		            if( relatedTerritories != null && relatedTerritories.containsKey( hash ) )
		            {
		            	Territory__c territoryToDelete = relatedTerritories.get( hash );
		                territoriesToDelete.add( territoryToDelete );
		                territoryToDeletionRecord.put(aRecord, territoryToDelete.Id);
		            } 
		            else {
		            	territoryDeletionRecordToMessage.put(aRecord, 'No Territories found matching specified hashed values: ' + hash);
		            }
	            } 
	            else {
	            	territoryDeletionRecordToMessage.put(aRecord, 'Please contact your administrator: No Territory Deletion Custom Setting setup for ' + aRecord.dealerBrand);
	            }
	            
	        }
	    	
	    	Map<Id, Database.DeleteResult> deleteResultMap = new Map<Id, Database.DeleteResult>();
	    	Database.DeleteResult[] deleteResult = Database.delete(territoriesToDelete, false);
	    	for (Database.DeleteResult dResult : deleteResult){
	    		deleteResultMap.put(dResult.id, dResult);
	    	}
	    	
	    	for ( TerritoryDeletionRecord aRecord : thePackage.values ){
	    		
	    		TerritoryDeletionRecordResult dResultRecord = new TerritoryDeletionRecordResult();
	    		
	    		if (territoryDeletionRecordToMessage.containsKey(aRecord)){
	    			dResultRecord.record = aRecord;
	    			dResultRecord.resultCode = FAILURE_RESULT;
	    			dResultRecord.resultMessage = territoryDeletionRecordToMessage.get(aRecord);
	    		}
	    		else if (territoryToDeletionRecord.containsKey(aRecord)) {
	    			Database.DeleteResult dResult = deleteResultMap.get(territoryToDeletionRecord.get(aRecord));
	    			dResultRecord.record = aRecord;
		    		if (dResult.success){
		    			dResultRecord.resultCode = OK_RESULT;
		    			dResultRecord.resultMessage = OK_RESULT;
		    		}
		    		else {
		    			dResultRecord.resultCode = FAILURE_RESULT;
		    			String errorMessage = '';
		    			for (Database.Error err : dResult.errors){
		    				errorMessage += '('+err.message+')';
		    			}
		    			dResultRecord.resultMessage = errorMessage;
		    		}
	    		}
	    		deletionResult.values.add(dResultRecord);
	    	}
        }
    	
    	
        
        return deletionResult;
    }

    global class TerritoryDeletionPackage
    {
        public List<TerritoryDeletionRecord> values;
    }

    global class TerritoryDeletionRecord
    {
        public String statusCode;
        public String recordNumber;
        public String dealerBrandId;
        public String dealerAbbreviation;
        public String dealerBrand;
        public String productCategory;
        public String country;
        public String state;
        public String county;
        public String postalCode;
    }

    global class TerritoryDeletionPackageResult
    {
        public List<TerritoryDeletionRecordResult> values{
        	get {
        		if (values == null){
        			values = new List<TerritoryDeletionRecordResult>();
        		}
        		return values;
        	}
        	set;
        }
    }

    global class TerritoryDeletionRecordResult
    {
        public TerritoryDeletionRecord record;
        public String resultCode;
        public String resultMessage;
    }
}