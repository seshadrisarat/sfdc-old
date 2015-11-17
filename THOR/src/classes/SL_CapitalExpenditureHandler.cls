/**
*  ClassName      : SL_CapitalExpenditureHandler
*  JIRATicket     : THOR-63
*  CreatedOn      : 27/MAR/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the handler class to rollup the Total_IAI_Rent_Increase from Capital Expenditure to Apartment
*/
public with sharing class SL_CapitalExpenditureHandler 
{
	/*
    	* MethodName   : onAfterInsert
        * param        : trigger.new values
        * Description  : This method is called after Capital Expenditure records are inserted
    */
	public void onAfterInsert(List<Capital_Expenditure__c> lstCapitalExpenditure)
	{
		callUpdateTotalRentIncreaseOnApartment(lstCapitalExpenditure);
	}
	
	
	/*
    	* MethodName   : onAfterUpdate
        * param        : trigger.oldMap values, trigger.newMap values
        * Description  : This method is called after Capital Expenditure records are updated
    */
	public void onAfterUpdate(Map<Id,Capital_Expenditure__c> mapOldCapitalExpenditure, Map<Id,Capital_Expenditure__c> mapNewCapitalExpenditure)
	{
		Set<Id> setApartmentId = new Set<Id>();
		
		///Create a set of parent apartment ids of capital expenditures which have been updated
		for(Id objCapitalExpenditureId:mapNewCapitalExpenditure.keyset())
		{
			///Check if Apartment has been changed or Include_to_Rider__c has been changed or Total_IAI_Rent_Increase__c has been changed
			if((mapOldCapitalExpenditure.get(objCapitalExpenditureId).Apartment__c != mapNewCapitalExpenditure.get(objCapitalExpenditureId).Apartment__c)
			   || (mapOldCapitalExpenditure.get(objCapitalExpenditureId).Include_to_Rider__c != mapNewCapitalExpenditure.get(objCapitalExpenditureId).Include_to_Rider__c)
			   || (mapOldCapitalExpenditure.get(objCapitalExpenditureId).Total_IAI_Rent_Increase__c != mapNewCapitalExpenditure.get(objCapitalExpenditureId).Total_IAI_Rent_Increase__c))
			{
				if(mapOldCapitalExpenditure.get(objCapitalExpenditureId).Apartment__c != null)
					setApartmentId.add(mapOldCapitalExpenditure.get(objCapitalExpenditureId).Apartment__c);
				if(mapNewCapitalExpenditure.get(objCapitalExpenditureId).Apartment__c != null)
					setApartmentId.add(mapNewCapitalExpenditure.get(objCapitalExpenditureId).Apartment__c);
			}
		}
		
		if(!setApartmentId.isEmpty())
			updateTotalRentIncreaseOnApartment(setApartmentId);
	}
	
	
	/*
    	* MethodName   : onAfterDelete
        * param        : trigger.old values
        * Description  : This method is called after Capital Expenditure records are Deleted
    */
	public void onAfterDelete(List<Capital_Expenditure__c> lstCapitalExpenditure)
	{
		callUpdateTotalRentIncreaseOnApartment(lstCapitalExpenditure);
	}
	
	
	/*
    	* MethodName   : onAfterUnDelete
        * param        : trigger.new values
        * Description  : This method is called after Capital Expenditure records are unDeleted
    */
	public void onAfterUnDelete(List<Capital_Expenditure__c> lstCapitalExpenditure)
	{
		callUpdateTotalRentIncreaseOnApartment(lstCapitalExpenditure);
	}
	
	
	/*
    	* MethodName   : callUpdateTotalRentIncreaseOnApartment
        * param        : List<Capital_Expenditure__c> lstCapitalExpenditure
        * Description  : This method filters Capital_Expenditure__c records and creates a set of Apartment idds and passes it to 
                         updateTotalRentIncreaseOnApartment method
    */
	private void callUpdateTotalRentIncreaseOnApartment(List<Capital_Expenditure__c> lstCapitalExpenditure)
	{
		Set<Id> setApartmentId = new Set<Id>();
		
		///Create a set of parent apartment ids of capital expenditures whose Include_to_Rider__c is true
		for(Capital_Expenditure__c objCapitalExpenditure:lstCapitalExpenditure)
		{
			if(objCapitalExpenditure.Include_to_Rider__c && objCapitalExpenditure.Apartment__c != null)
			{
				setApartmentId.add(objCapitalExpenditure.Apartment__c);
			}
		}
		
		if(!setApartmentId.isEmpty())
			updateTotalRentIncreaseOnApartment(setApartmentId);
	}
	
	
	/*
    	* MethodName   : updateTotalRentIncreaseOnApartment
        * param        : Set<Id> setApartmentId
        * Description  : This method updates Total_IAI_Rent_Increase on Apartment
    */
	private void updateTotalRentIncreaseOnApartment(Set<Id> setApartmentId)
	{
		List<Apartment__c> lstApartment = new List<Apartment__c>();
		Set<Id> setFilteredApartmentId = new Set<Id>();
		
		///Update Total_IAI_Rent_Increase__c on Apartment
		for(AggregateResult objAggregateResult:[SELECT Apartment__c,SUM(Total_IAI_Rent_Increase__c) 
		                                        FROM Capital_Expenditure__c
		                                        WHERE Apartment__c IN:setApartmentId AND Include_to_Rider__c = true
		                                        GROUP BY Apartment__c])
		{
			Apartment__c objApartment = new Apartment__c(Id  = (Id)objAggregateResult.get('Apartment__c'), Total_IAI_Rent_Increase__c = (Decimal)objAggregateResult.get('expr0'));
			lstApartment.add(objApartment);
			setFilteredApartmentId.add(objApartment.Id);
		}
		
		if(trigger.isUpdate || trigger.isDelete)
		{
			///Make  Total_IAI_Rent_Increase__c on apartment as zero if there are no child Capital_Expenditure__c with Include_to_Rider__c = true
			for(Apartment__c objApartment:[SELECT Id,Total_IAI_Rent_Increase__c
			                               FROM Apartment__c
			                               WHERE Id IN:setApartmentId AND ID NOT IN:setFilteredApartmentId])
			{
				objApartment.Total_IAI_Rent_Increase__c = null;
				lstApartment.add(objApartment);
			}
		}
		
		if(!lstApartment.isEmpty())
			update lstApartment;
	}
}