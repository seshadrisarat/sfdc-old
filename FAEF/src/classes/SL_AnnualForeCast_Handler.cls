/**
* \arg \b ClassName      : SL_AnnualForeCast_Handler
* \arg \b JIRATicket     : FAEF-32
* \arg \b CreatedOn      : 11/Sep/2014
* \arg \b ModifiedBy     : Harsh
* \arg \b Description    : This is the handler class for SL_AnnualForeCast trigger to prevent the actions occuring for avoiding duplicate values.	
*/
public with sharing class SL_AnnualForeCast_Handler 
{
	//Constructor of a Handler Class
	public SL_AnnualForeCast_Handler()
	{
		/* Do nothing. */
	}
	
	/*
	    * MethodName 	: onBeforeInsert.
	    * param 		: List<Id, Annual_Forecast__c> lstNewAnnualForecastRecords
	    * Description	: This function will call After insert of the AnnualForecast.
    */
    public void onBeforeInsert(List<Annual_Forecast__c> lstNewAnnualForecastRecords)
    {
    	preventDuplicate(lstNewAnnualForecastRecords);
    }
	
	/*
    	* MethodName 	: onBeforeUpdate.
        * param 		: Map<Id, Annual_Forecast__c> mapNewAnnualForecastRecords,  Map<Id, Annual_Forecast__c> mapNewAnnualForecastRecords
        * Description	: This function will call After Update of the AnnualForecast.
    */
    public void onBeforeUpdate( Map<Id, Annual_Forecast__c> mapOldAnnualForecastRecords, Map<Id, Annual_Forecast__c> mapNewAnnualForecastRecords)
    {
        List<Annual_Forecast__c> lstAnnualForecastRecordsToUpdate = new List<Annual_Forecast__c>();
        for(Annual_Forecast__c objAnnualForecast : mapNewAnnualForecastRecords.values())
        {
        	// Adding only those AnnualForecastRecords whose Fiscal Year OR Schedule feld value is changing
        	if(mapOldAnnualForecastRecords.get(objAnnualForecast.Id).Fiscal_Year__c != objAnnualForecast.Fiscal_Year__c || mapOldAnnualForecastRecords.get(objAnnualForecast.Id).Schedule__c != objAnnualForecast.Schedule__c )
				lstAnnualForecastRecordsToUpdate.add(objAnnualForecast);
        }
        preventDuplicate(lstAnnualForecastRecordsToUpdate);
    }
    
    /*
        * MethodName 	: onAfterUndelete.
        * param 	    : Map of AnnualForecast.
        * Description	: This function will call After UnDelete of the note.
    */
    public void onAfterUndelete(Map<Id, Annual_Forecast__c> mapNewAnnualForecastRecords)
    {
        preventDuplicate(mapNewAnnualForecastRecords.values());
    }
    
    /*
        * MethodName	: PreventDuplicate
        * param None	: List of AnnualForeCast.
        * Description	: Prevent duplicate AnnualForeCast Records
    */
    private void preventDuplicate(List<Annual_Forecast__c> lstNewAnnualForecastRecords)
    {
    	Set<Id> setOfScheduleIds = new Set<Id>();			// Set to keep the Current AnnualForecast record's ScheduleIds
		Set<String> setOfFiscalYears= new Set<String>();	// Set to keep the Current AnnualForecast record's Fischal Year field values
    	
    	Map<String, Id> mapOfSchduleIAndFiscalYear = new Map<String, Id>();			// Map to keep the Annual Forecast records which are matched to the curent Annual forecast record field values
    	
    	// Set to Keep the Uniue Annual Forecast Records
    	Set<String> setOfUniqueForecast = new Set<String>();
        List<Annual_Forecast__c> lstAnnualForecastRecordsToUpdate = new List<Annual_Forecast__c>();
    	
    	// Keeping all the ScheduleIds in setOfScheduleIds set and Fischal Year in setOfFiscalYears set
    	for(Annual_Forecast__c objAnnualForecast : lstNewAnnualForecastRecords)
		{
			// Checking and showing Error if duplicate combination of Schedule and Fiscal Year Annual Investment record found else adding to the lstAnnualForecastRecordsToUpdate
			if(setOfUniqueForecast.contains(objAnnualForecast.Schedule__c+ '-' +objAnnualForecast.Fiscal_Year__c)){
					objAnnualForecast.addError(Label.SL_PreventAnnualForeCastErrorMessage);
			}
			else{
				// Adding To the setOfUniqueInvestments and lstAnnualForecastRecordsToUpdate
				setOfUniqueForecast.add(objAnnualForecast.Schedule__c+ '-' +objAnnualForecast.Fiscal_Year__c);
        		lstAnnualForecastRecordsToUpdate.add(objAnnualForecast);
				
				setOfScheduleIds.add(objAnnualForecast.Schedule__c);
				if(objAnnualForecast.Fiscal_Year__c != NULL)
					setOfFiscalYears.add(objAnnualForecast.Fiscal_Year__c);
			}
		}
		
		// Iterating on AnnualForecast records ti get the matched Schduled ID AND Fiscal Year
		for(Annual_Forecast__c objAnnualForecast : [Select Id, Fiscal_Year__c, Schedule__c From Annual_Forecast__c 
													Where Schedule__c IN : setOfScheduleIds AND Fiscal_Year__c IN : setOfFiscalYears AND ID NOT IN : lstAnnualForecastRecordsToUpdate])
		{
			mapOfSchduleIAndFiscalYear.put(objAnnualForecast.Schedule__c+ '-' +objAnnualForecast.Fiscal_Year__c, objAnnualForecast.Id);
		}
		
		// Now Iterating on Annual Forecast and preventing for duplicate AnnualInvestMent records
		for(Annual_Forecast__c objAnnualForecast : lstAnnualForecastRecordsToUpdate)
		{
			If(mapOfSchduleIAndFiscalYear.containsKey(objAnnualForecast.Schedule__c+ '-' +objAnnualForecast.Fiscal_Year__c))
				objAnnualForecast.addError(Label.SL_PreventAnnualForeCastErrorMessage);
		}
    }
}