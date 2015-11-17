/**
*  ClassName      : SL_ApartmentTriggerHandler
*  CreatedOn      : 20/SEP/2014
*  ModifiedBy     : Sanath
*  Description    : This is the handler class to to update apartment previous status field.
*/
public with sharing class SL_ApartmentTriggerHandler 
{
	/*
    	* MethodName   : onBeforeInsert
        * param        : trigger.new
        * Description  : Will invoke on before insert of apartment record
    */
	public void onBeforeInsert(List<Apartment__c> lstInsertedApartment)
	{
		updatePreviousApartmentStatus(null,lstInsertedApartment);
	}
	
	/*
    	* MethodName   : onBeforeUpdate
        * param        : trigger.oldMap, trigger.newMap
        * Description  : Will invoke on before update of apartment record
    */
	public void onBeforeUpdate(Map<Id,Apartment__c> mapOldApartment, Map<Id,Apartment__c> mapNewApartment)
	{
		List<Apartment__c> lstFilteredApartment = new List<Apartment__c>();
		
		for(Apartment__c objApartment:mapNewApartment.values())
		{
			if(objApartment.Apartment_Status__c != mapOldApartment.get(objApartment.Id).Apartment_Status__c)
			{
				lstFilteredApartment.add(objApartment);
			}
		}
		updatePreviousApartmentStatus(mapOldApartment,lstFilteredApartment);
	}
	
	/*
    	* MethodName   : updatePreviousApartmentStatus
        * param        : trigger.oldMap,Filtered apartment list
        * Description  : Will update apartment previous status field.
    */
	private void updatePreviousApartmentStatus(Map<Id,Apartment__c> mapOldApartment,List<Apartment__c> lstApartment)
	{
		for(Apartment__c objApartment:lstApartment)
		{
			///Check for insert case
			if(mapOldApartment == null)
				objApartment.Previous_Apartment_Status__c = objApartment.Apartment_Status__c;
			///Check for update case
			else if(mapOldApartment.containskey(objApartment.Id) && mapOldApartment.get(objApartment.Id) != null)
				objApartment.Previous_Apartment_Status__c = mapOldApartment.get(objApartment.Id).Apartment_Status__c;
		}
	}
}