/**
* @ClassName    : SL_RentRoll_Handler
* @JIRATicket   : STONEPIII-1 and STONEPIII-5
* @CreatedOn    : 29/Mar/2013
* @ModifiedBy   : -
* @Description  : Handler for SL_rentRoll trigger.
*/


/**
@Developer Name: Shailendra
Percentage of best practices followed: 100%
No of SOQL queries used: 3
No of collections used: 1
Exception Handling implemented: Yes
Coding standards followed: Yes
Naming conventions followed: Yes
Third party integrations: No
Maximum of No of records tested with: 1000
Customer Approval:
Last Modified Date: 
Approved by:
Test Coverage : 99%
*/
public class SL_RentRoll_Handler 
{
	// MAP that stores the DEAL ids => Inner class objects
	Map<String, InnerDealFieldValues> mapDealIdToInnerDealFieldValues;
	
	// Constructor
	public SL_RentRoll_Handler()
	{
		mapDealIdToInnerDealFieldValues = new Map<String, InnerDealFieldValues>();
	}
	
	// Inner class to store rolled up values of Rent Roll field values to be updated on parent Deal record.
	public class InnerDealFieldValues
	{
		// Map of Lease Type to Count of all rent rolls 
		Map<String, Integer> mapLeaseTypeToCountOfRentRolls;
		// Map of Lease Type to Sum of Square Feet of all rent rolls 
		Map<String, Decimal> mapLeaseTypeToSumOfSF;
		// Map of Lease Type to Sum of Base Rents of all rent rolls 
		Map<String, Decimal> mapLeaseTypeToSumOfBaseRents;
		
		// Map of Unit Type to Count of all rent rolls 
		Map<String, Integer> mapUnitTypeToCountOfRentRolls;
		// Map of Unit Type to Sum of Square Feet of all rent rolls 
		Map<String, Decimal> mapUnitTypeToSumOfSF;
		// Map of Unit Type to Sum of Base Rents of all rent rolls 
		Map<String, Decimal> mapUnitTypeToSumOfBaseRents;
		
		// Inner class constructor
		public InnerDealFieldValues()
		{
			// Initialize all global variables
			mapLeaseTypeToCountOfRentRolls = new Map<String, Integer>();
			mapLeaseTypeToSumOfSF = new Map<String, Decimal>();
			mapLeaseTypeToSumOfBaseRents = new Map<String, Decimal>();
			mapUnitTypeToCountOfRentRolls = new Map<String, Integer>();
			mapUnitTypeToSumOfSF = new Map<String, Decimal>();
			mapUnitTypeToSumOfBaseRents = new Map<String, Decimal>();
		}
	}
	
	
	 /*
        @MethodName : rollUpRentRollValuesToDealFields
        @param None : List<Rent_Roll__c> lstRentRolls
        @Description: Method to rollup Rent Roll field values based on unit type and lease type to parent Deal's fields
    */
	public void rollUpRentRollValuesToDealFields(List<Rent_Roll__c> lstRentRolls)
	{
		try
		{
			Set<Id> setParentDealIds = new Set<Id>();
			Set<Id> setDealIdsWithNoRentRolls = new Set<Id>();
			
			// Collect all parent Deal objects and store them in a set of Deal Ids
			for(Rent_Roll__c objRR : lstRentRolls)
			{
				setParentDealIds.add(objRR.Deal__c);
			}
			
			/* We need to perform a check on any deal objects that has no chil Rent Rolls. 
			   This is important since existing rolled up values on fields of Deal has to be cleared off */
			for(Deal__c objDeal : [Select Id, (Select Id From Rent_Rolls__r)  
								   From Deal__c 
								   WHERE Id IN : setParentDealIds])
			{
				// To avoid " System.QueryException: Aggregate query has too many rows for direct assignment, use FOR loop"
				Boolean hasChildRentRolls = false;
				
				for(Rent_Roll__c objChildRentRolls : objdeal.Rent_Rolls__r)
				{
					hasChildRentRolls = true;
				}
				
				if(!hasChildRentRolls)
				{
					// Create a new inner class objects
					InnerDealFieldValues objLocalInnerDealFieldValues = new InnerDealFieldValues();
					mapDealIdToInnerDealFieldValues.put(objDeal.Id, objLocalInnerDealFieldValues);
				}
			}
			
			// Query all current Rent Roll records for the Deals
			for(Rent_Roll__c objRR : [Select Id, Square_Feet__c, Deal__c, 
									  Lease_Type__c, Base_Rent__c, Unit_Type__c
									  FROM Rent_Roll__c 
									  Where Deal__c IN : setParentDealIds])
			{
				// Check if map contains the same Deal Id previously. 
				// Yes: Simply rollup the values to existing object
				// No: Create a new InnerDealFieldValues object
				if(mapDealIdToInnerDealFieldValues.containsKey(objRR.Deal__c))
				{
					// Get the existing inner class object of the Deal
					InnerDealFieldValues objLocalInnerDealFieldValues = mapDealIdToInnerDealFieldValues.get(objRR.Deal__c);
					// Call incrementFieldValues method to roll up Rent Roll records field values and store it in local maps maintained within the inner class object
					InnerDealFieldValues updatedInnerDealFieldValues = incrementFieldValues(objLocalInnerDealFieldValues, objRR.Lease_Type__c, objRR.Unit_Type__c, isNUll(objRR.Square_Feet__c) ? 0 : objRR.Square_Feet__c, isNUll(objRR.Base_Rent__c) ? 0 : objRR.Base_Rent__c);
					mapDealIdToInnerDealFieldValues.put(objRR.Deal__c, updatedInnerDealFieldValues);
						
				}
				else
				{
					// Create a new inner class objects
					InnerDealFieldValues objLocalInnerDealFieldValues = new InnerDealFieldValues();
					// Call incrementFieldValues method to roll up Rent Roll records field values and store it in local maps maintained within the inner class object
					InnerDealFieldValues updatedInnerDealFieldValues = incrementFieldValues(objLocalInnerDealFieldValues, objRR.Lease_Type__c, objRR.Unit_Type__c, isNUll(objRR.Square_Feet__c) ? 0 : objRR.Square_Feet__c, isNUll(objRR.Base_Rent__c) ? 0 : objRR.Base_Rent__c);
					mapDealIdToInnerDealFieldValues.put(objRR.Deal__c, updatedInnerDealFieldValues);
				}
			}	
			
			// After the rolling up is performed, save the values to parent Deal records. Call saveRolledUpvaluesToDeal method
			saveRolledUpvaluesToDeal();
		}
		catch(Exception ex)
		{
		}
		
	}
	
	 /*
        @MethodName : saveRolledUpvaluesToDeal
        @param None : None
        @Description: Method to save the rolled up values to parent Deal record.
    */
	private void saveRolledUpvaluesToDeal()
	{
		List<Deal__c> lstDealsToUpdate = new List<Deal__c>();
		
		// Iterate through the Deal ids and from the maintained map of Id->Rolled up values, roll up the values to the Deal record.
		for(Id dealId : mapDealIdToInnerDealFieldValues.keyset())
		{
			// Create a new Deal object for updation to db (with rolled up values)
			Deal__c objDealToUpdate = new Deal__c(Id= dealId);
			
			InnerDealFieldValues objLocalInnerDealFieldValues = mapDealIdToInnerDealFieldValues.get(dealId);
			
			/*
				1. Check for corresponding Lease Type values and get the rolled up values corresponding to the Lease types.
				2. Update the Deal's corresponding fields as per mapping given on JIRA-STONEPIII-1
			*/
			if(objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey('RS'))
			{
				objDealToUpdate.RS_in_place_rent__c     = (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.get('RS') / 
														  objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get('RS') );
														  
				objDealToUpdate.RS_In_Place_Rent_PSF__c = (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get('RS') != 0) ? (objDealToUpdate.RS_in_place_rent__c / 
													   	  (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get('RS') / 
													  	  objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get('RS') )) * 12 : null;
			}
			
			if(objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey('RC'))
			{
				objDealToUpdate.RC_in_place_rent__c     = (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.get('RC') / 
														  objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get('RC') );
				objDealToUpdate.RC_In_Place_Rent_PSF__c = (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get('RC') != 0) ? (objDealToUpdate.RC_in_place_rent__c / 
													   	  (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get('RC') / 
													  	  objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get('RC') )) * 12 : null;
			}
			
			if(objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey('EX'))
			{
				objDealToUpdate.EX_in_place_rent__c     = (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.get('EX') / 
														  objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get('EX') );
				objDealToUpdate.EX_In_Place_Rent_PSF__c = (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get('EX') != 0) ? (objDealToUpdate.EX_in_place_rent__c / 
													   	  (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get('EX') / 
													  	  objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get('EX') )) * 12 : null;
			}
			
			if(objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey('FM'))
			{
				objDealToUpdate.FM_in_place_rent__c     = (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.get('FM') / 
														  objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get('FM') );
														  
				objDealToUpdate.FM_In_Place_Rent_PSF__c = (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get('FM') != 0) ? (objDealToUpdate.FM_in_place_rent__c / 
													   	  (objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get('FM') / 
													  	  objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get('FM') )) * 12 : null;
			}
			
			/*
				1. Check for corresponding Unit Type values and get the rolled up values corresponding to the Unit types.
				2. Update the corresponding fields as per mapping given on JIRA-STONEPIII-5
			*/
			if(objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('1 BR'))
			{
				objDealToUpdate.X1BR_AVG_Rent__c     = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.get('1 BR') / 
														  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('1 BR') );
				objDealToUpdate.X1BR_AVG_Rent_PSF__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('1 BR') != 0) ? (objDealToUpdate.X1BR_AVG_Rent__c / 
													   	  (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('1 BR') / 
													  	  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('1 BR') )) * 12 : null;
				
				objDealToUpdate.X1BR_SUM_SQFT__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('1 BR') / objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('1 BR'));
				objDealToUpdate.X1BR_Total_Units__c = objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('1 BR');
			}
			
			if(objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('2 BR'))
			{
				objDealToUpdate.X2BR_AVG_Rent__c     = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.get('2 BR') / 
														  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('2 BR') );
				objDealToUpdate.X2BR_AVG_Rent_PSF__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('2 BR') != 0) ? (objDealToUpdate.X2BR_AVG_Rent__c / 
													   	  (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('2 BR') / 
													  	  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('2 BR') )) * 12  : null;
				objDealToUpdate.X2BR_SUM_SQFT__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('2 BR') / objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('2 BR'));
				
				objDealToUpdate.X2BR_Total_Units__c = objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('2 BR');
			}
			
			if(objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('3 BR'))
			{
				objDealToUpdate.X3BR_AVG_Rent__c     = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.get('3 BR') / 
														  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('3 BR') );
				objDealToUpdate.X3BR_AVG_Rent_PSF__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('3 BR') != 0) ? (objDealToUpdate.X3BR_AVG_Rent__c / 
													   	  (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('3 BR') / 
													  	  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('3 BR') )) * 12  : null;
				objDealToUpdate.X3BR_SUM_SQFT__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('3 BR') / objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('3 BR'));
				objDealToUpdate.X3BR_Total_Units__c = objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('3 BR');
			}
			
			if(objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('4 BR'))
			{
				objDealToUpdate.X4BR_AVG_Rent__c     = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.get('4 BR') / 
														  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('4 BR') );
				objDealToUpdate.X4BR_AVG_Rent_PSF__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('4 BR') != 0) ? (objDealToUpdate.X4BR_AVG_Rent__c / 
													   	  (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('4 BR') / 
													  	  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('4 BR') )) * 12  : null;
				objDealToUpdate.X4BR_SUM_SQFT__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('4 BR') / objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('4 BR'));
				
				objDealToUpdate.X4BR_Total_Units__c = objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('4 BR');
			}
			
			if(objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('5 BR'))
			{
				objDealToUpdate.X5BR_AVG_Rent__c     = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.get('5 BR') / 
														  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('5 BR') );
				objDealToUpdate.X5BR_AVG_Rent_PSF__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('5 BR') != 0) ? (objDealToUpdate.X5BR_AVG_Rent__c / 
													   	  (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('5 BR') / 
													  	  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('5 BR') )) * 12 : null;
				objDealToUpdate.X5BR_SUM_SQFT__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('5 BR') / objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('5 BR'));
				
				objDealToUpdate.X5BR_Total_Units__c = objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('5 BR');
			}
			
			if(objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('6 BR'))
			{
				objDealToUpdate.X6BR_AVG_Rent__c     = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.get('6 BR') / 
														  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('6 BR') );
				objDealToUpdate.X6BR_AVG_Rent_PSF__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('6 BR') != 0) ? (objDealToUpdate.X6BR_AVG_Rent__c / 
													   	  (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('6 BR') / 
													  	  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('6 BR') )) * 12  : null;
				objDealToUpdate.X6BR_SUM_SQFT__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('6 BR') / objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('6 BR')) ;
				
				objDealToUpdate.X6BR_Total_Units__c = objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('6 BR');
			}
			
			if(objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('Studio'))
			{
				objDealToUpdate.XStudio_Avg_Rent__c    = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.get('Studio') / 
														  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('Studio') );
				objDealToUpdate.XStudio_Avg_Rent_PSF__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('Studio') != 0) ? (objDealToUpdate.XStudio_Avg_Rent__c / 
													   	  (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('Studio') / 
													  	  objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('Studio') )) * 12  : null;
				objDealToUpdate.XStudio_Avg_SF__c = (objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get('Studio') / objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('Studio')) ;
				
				objDealToUpdate.XStudio_Total_Units__c = objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get('Studio');
			}
			
			/*
				Next in the following lines of code:
				1. We need to update those custom Lease/Unit Rollup fields on Deal that do not have any corresponding child Rent Roll records with that particular 
				   Lease/Unit Types
				2. Make these corresponding fields as NULL
			*/
			
			if(!objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey('RS'))
			{
				objDealToUpdate.RS_in_place_rent__c     = null;
				objDealToUpdate.RS_In_Place_Rent_PSF__c = null;
			}
			
			if(!objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey('RC'))
			{
				objDealToUpdate.RC_in_place_rent__c     = null;
				objDealToUpdate.RC_In_Place_Rent_PSF__c = null;
			}
			
			if(!objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey('EX'))
			{
				objDealToUpdate.EX_in_place_rent__c     = null;
				objDealToUpdate.EX_In_Place_Rent_PSF__c = null;
			}
			
			if(!objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey('FM'))
			{
				objDealToUpdate.FM_in_place_rent__c     = null;
				objDealToUpdate.FM_In_Place_Rent_PSF__c = null;
			}
			// Unit type updates
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('1 BR'))
			{
				objDealToUpdate.X1BR_AVG_Rent__c     = null;
				objDealToUpdate.X1BR_AVG_Rent_PSF__c = null;
				objDealToUpdate.X1BR_SUM_SQFT__c 	 = null;
				objDealToUpdate.X1BR_Total_Units__c  = null;
				
			}
			
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('2 BR'))
			{
				objDealToUpdate.X2BR_AVG_Rent__c     = null;
				objDealToUpdate.X2BR_AVG_Rent_PSF__c = null;
				objDealToUpdate.X2BR_SUM_SQFT__c 	 = null;
				objDealToUpdate.X2BR_Total_Units__c  = null;
			}
			
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('3 BR'))
			{
				objDealToUpdate.X3BR_AVG_Rent__c     = null;
				objDealToUpdate.X3BR_AVG_Rent_PSF__c = null;
				objDealToUpdate.X3BR_SUM_SQFT__c     = null;
				objDealToUpdate.X3BR_Total_Units__c  = null;
			}
			
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('4 BR'))
			{
				objDealToUpdate.X4BR_AVG_Rent__c     = null;
				objDealToUpdate.X4BR_AVG_Rent_PSF__c = null;
				objDealToUpdate.X4BR_SUM_SQFT__c     = null;
				objDealToUpdate.X4BR_Total_Units__c  = null;
			}
			
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('5 BR'))
			{
				objDealToUpdate.X5BR_AVG_Rent__c     = null;
				objDealToUpdate.X5BR_AVG_Rent_PSF__c = null;
				objDealToUpdate.X5BR_SUM_SQFT__c     = null;
				objDealToUpdate.X5BR_Total_Units__c  = null;
			}
			
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('6 BR'))
			{
				objDealToUpdate.X6BR_AVG_Rent__c     = null;
				objDealToUpdate.X6BR_AVG_Rent_PSF__c = null;
				objDealToUpdate.X6BR_SUM_SQFT__c     = null;
				objDealToUpdate.X6BR_Total_Units__c  = null;
			}
			
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey('Studio'))
			{
				objDealToUpdate.XStudio_Avg_Rent__c     = null;
				objDealToUpdate.XStudio_Avg_Rent_PSF__c = null;
				objDealToUpdate.XStudio_Avg_SF__c       = null;
				objDealToUpdate.XStudio_Total_Units__c  = null;
			}
			
			// Add the updated Deal object to a list for performing update DML
			lstDealsToUpdate.add(objDealToUpdate);
		}
		
		
		// Update the Deal objects
		if(!lstDealsToUpdate.isEmpty())		update lstDealsToUpdate;
	}
	
	
	/*
        @MethodName : isNull
        @param None : Decimal decValueToBeChecked
        @Description: Utility method to check for NULL values for Decimal types
    */
	private Boolean isNull(Decimal decValueToBeChecked)
	{
		Boolean isNullValue;
		
		isNullValue = (decValueToBeChecked == null) ? true : false;
		
		return isNullValue;
	}
	
	
	/*
        @MethodName : incrementFieldValues
        @param None : InnerDealFieldValues objLocalInnerDealFieldValues, 
					  String strLeaseType, 
					  String strUnitType, 
					  Decimal decSquareFeet,  
					  Decimal decBaseRent
        @Description: Method to calculate values for rollup to parent Deal record
    */
	private InnerDealFieldValues incrementFieldValues(InnerDealFieldValues objLocalInnerDealFieldValues, 
													  String strLeaseType, 
													  String strUnitType, 
													  Decimal decSquareFeet,  
													  Decimal decBaseRent)
	{
		// Check if the Rent Roll record has a blank Lease type. In this case no need of rolling up its values
		if(strLeaseType != null)
		{
			// Check if in the map the particular Lease type already exists. If not, then put the count of Rent Roll as 1. 
			// Else, increment the counter for this particular Lease type.
			if(!objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.containsKey(strLeaseType))
			{
				objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.put(strLeaseType, 1);
			}
			else
			{
				Integer intCurrentCount = objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.get(strLeaseType) + 1;
				objLocalInnerDealFieldValues.mapLeaseTypeToCountOfRentRolls.put(strLeaseType, intCurrentCount);
			}
			
			// For sum of square feet values of Rent Roll records.
			if(!objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.containsKey(strLeaseType))
			{
				objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.put(strLeaseType, decSquareFeet);
			}
			else
			{
				Decimal decCurrentSum = objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.get(strLeaseType);
				objLocalInnerDealFieldValues.mapLeaseTypeToSumOfSF.put(strLeaseType, decCurrentSum + decSquareFeet);
			}
			
			// For sum of base rent values of Rent Roll records.
			if(!objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.containsKey(strLeaseType))
			{
				objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.put(strLeaseType, decBaseRent);
			}
			else
			{
				Decimal decCurrentSum = objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.get(strLeaseType);
				objLocalInnerDealFieldValues.mapLeaseTypeToSumOfBaseRents.put(strLeaseType, decCurrentSum + decBaseRent);
			}
		}
		
		// Check if the Rent Roll record has a blank Unit type. In this case no need of rolling up its values
		if(strUnitType != null)
		{
			// Check if in the map the particular Unit type already exists. If not, then put the count of Rent Roll as 1. 
			// Else, increment the counter for this particular Unit type.
			if(!objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.containsKey(strUnitType))
			{
				objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.put(strUnitType, 1);
			}
			else
			{
				Integer intCurrentCount = objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.get(strUnitType) + 1;
				objLocalInnerDealFieldValues.mapUnitTypeToCountOfRentRolls.put(strUnitType, intCurrentCount);
			}
			
			// For sum of square feet values of Rent Roll records.
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.containsKey(strUnitType))
			{
				objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.put(strUnitType, decSquareFeet);
			}
			else
			{
				Decimal decCurrentSum = objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.get(strUnitType);
				objLocalInnerDealFieldValues.mapUnitTypeToSumOfSF.put(strUnitType, decCurrentSum + decSquareFeet);
			}
			
			// For sum of base rent values of Rent Roll records.
			if(!objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.containsKey(strUnitType))
			{
				objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.put(strUnitType, decBaseRent);
			}
			else
			{
				Decimal decCurrentSum = objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.get(strUnitType);
				objLocalInnerDealFieldValues.mapUnitTypeToSumOfBaseRents.put(strUnitType, decCurrentSum + decBaseRent);
			}
		}
		
		// return the updated inner class object
		return objLocalInnerDealFieldValues;
	}
	
	@isTest
	private static void test_SL_RentRoll_Handler()
	{
		// Insert a Deal record
		// Insert a child Rent Roll record with field mappings
		// Update , delete the Rent roll record so that the code is covered.
		
		Deal__c objTestDeal = new Deal__c(Name = 'Test Deal');
		insert objTestDeal;
		
		List<Rent_Roll__c> lstTestRR = new List<Rent_Roll__c>();
		
		Rent_Roll__c objTestRR1 = new Rent_Roll__c(Deal__c = objTestDeal.Id, Lease_Type__c = 'RS', Unit_Type__c = '1 BR');
		lstTestRR.add(objTestRR1);
		
		Rent_Roll__c objTestRR2 = new Rent_Roll__c(Deal__c = objTestDeal.Id, Lease_Type__c = 'RC', Unit_Type__c = '3 BR');
		lstTestRR.add(objTestRR2);
		
		Rent_Roll__c objTestRR3 = new Rent_Roll__c(Deal__c = objTestDeal.Id, Lease_Type__c = 'EX', Unit_Type__c = '2 BR');
		lstTestRR.add(objTestRR3);
		
		Rent_Roll__c objTestRR4 = new Rent_Roll__c(Deal__c = objTestDeal.Id, Lease_Type__c = 'FM', Unit_Type__c = '4 BR');
		lstTestRR.add(objTestRR4);
		
		Rent_Roll__c objTestRR5 = new Rent_Roll__c(Deal__c = objTestDeal.Id, Lease_Type__c = 'EX', Unit_Type__c = '5 BR');
		lstTestRR.add(objTestRR5);
		
		Rent_Roll__c objTestRR6 = new Rent_Roll__c(Deal__c = objTestDeal.Id, Lease_Type__c = 'EX', Unit_Type__c = '6 BR');
		lstTestRR.add(objTestRR6);
		
		Rent_Roll__c objTestRR7 = new Rent_Roll__c(Deal__c = objTestDeal.Id, Lease_Type__c = 'EX', Unit_Type__c = '5 BR');
		lstTestRR.add(objTestRR7);
		
		Rent_Roll__c objTestRR8 = new Rent_Roll__c(Deal__c = objTestDeal.Id, Lease_Type__c = 'EX', Unit_Type__c = 'Studio');
		lstTestRR.add(objTestRR8);
		
		insert lstTestRR;
		
		
		objTestRR1.Lease_Type__c = 'RC';
		update objTestRR1;
		
		delete lstTestRR;
	}
}