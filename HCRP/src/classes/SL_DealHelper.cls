/**  
* \arg ClassName        : SL_DealHelper
* \arg JIRATicket       : 
* \arg CreatedOn        : 2015-06-23
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Edward Rivera
* \arg ModifiedBy       : 
* \arg Description      : Helper class
*/
public with sharing class SL_DealHelper {

/*BEGIN PROPERTIES*/

private static Map<String, Double> conversionRates;

/*END PROPERTIES*/

/***************************************************
*	SHARED METHODS    					   		   *
***************************************************/

public static List<Deal__c> getClosedWonDeals(List <Deal__c> potentialDeals){
	List<Deal__c> closedDeals = new List<Deal__c>();
	for (Deal__c deal: potentialDeals){
		if (deal.Capture_Local_Currency_Formula__c){
			closedDeals.add(deal);
		}
	}
	return closedDeals;
}

public static List<Deal__c> stampCurrency(List <Deal__c> dealsToStamp){
	if (conversionRates == null){
		loadConversionRates();
	}
	List<Deal__c> dealsToUpdate = new List<Deal__c>();
	for (Deal__c dealToStamp: dealsToStamp){
		Deal__c dealClone = dealToStamp.clone();
		dealClone.Id = dealToStamp.Id;
		dealClone.Capture_Local_CurrencyISOCode__c = dealToStamp.CurrencyISOCode;
		dealClone.Capture_Local_Currency_Conversion_Rate__c = conversionRates.get(dealToStamp.CurrencyISOCode);
		dealClone.Capture_Local_Currency_Amount_USD__c = (dealToStamp.Amount__c != null ? dealToStamp.Amount__c / conversionRates.get(dealToStamp.CurrencyISOCode):0);
		dealsToUpdate.add(dealClone);
	}

	return dealsToUpdate;
}

private static void loadConversionRates(){
	conversionRates = new Map<String, Double>();
	for (CurrencyType dcr: [        SELECT  ConversionRate, 
                                            IsoCode 
                                    FROM    CurrencyType
                            ]){
        conversionRates.put(dcr.IsoCode, dcr.ConversionRate);
    }
}

/***************************************************
*	BEFORE INSERT METHODS    					   *
***************************************************/

/***************************************************
*	BEFORE UPDATE METHODS    					   *
***************************************************/

/***************************************************
*	BEFORE DELETE METHODS    					   *
***************************************************/

/***************************************************
*	AFTER INSERT METHODS    					   *
***************************************************/

/***************************************************
*	AFTER UPDATE METHODS    					   *
***************************************************/

/***************************************************
*	AFTER DELETE METHODS    					   *
***************************************************/

/***************************************************
*	AFTER UNDELETE METHODS    					   *
***************************************************/

}