/****************************************************************************************
Name            : psaMiscAdjustmentHandler
Author          : Julia Kolesnik
Created Date    : January 13, 2014
Description     : Contains methods for the MiscAdjustment trigger.
******************************************************************************************/
public class psaMiscAdjustmentHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	private map<Id,RecordType> mapRecordTypeIds2Names;
	private map<string,Id> mapRecordTypeNames2Ids;
	public static boolean isRecursion= false;

	/**
		* Constructor		: Initialise the global variables
		* @param			: None
	*/
	public psaMiscAdjustmentHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	/*
		@MethodName		: onAfterInsert
		@param			: lstNew (Trigger New Values)
		@Description	: To create appropriate pse__Miscellaneous_Adjustment__c records 
	*/
	public void onAfterInsert(list<pse__Miscellaneous_Adjustment__c> lstNew)
	{
		try
		{
			mapRecordTypeNames2Ids = new map<string,Id>();
			mapRecordTypeIds2Names = new map<Id,RecordType>([Select Id, DeveloperName FROM RecordType WHERE sObjectType='pse__Miscellaneous_Adjustment__c']);
			for (RecordType item:mapRecordTypeIds2Names.values())
			{
				mapRecordTypeNames2Ids.put(item.DeveloperName, item.id);
			}
			
			list<pse__Miscellaneous_Adjustment__c> lstMA = new list<pse__Miscellaneous_Adjustment__c>();
			for (pse__Miscellaneous_Adjustment__c item:lstNew)
			{
				if (item.RecordTypeId==mapRecordTypeNames2Ids.get('Pre_Bill')||item.RecordTypeId==mapRecordTypeNames2Ids.get('Retainer')) {
					lstMA.add(item);
				}
			}
			
			if (lstMA.size()>0) AutoCreateAdjustments(lstMA);
		}
		catch(Exception e) {}
	}
	
	private void AutoCreateAdjustments(list<pse__Miscellaneous_Adjustment__c> lstMA)
	{
		list<pse__Miscellaneous_Adjustment__c> lstMAToInsert = new list<pse__Miscellaneous_Adjustment__c>();
		pse__Miscellaneous_Adjustment__c curMA;
		for (pse__Miscellaneous_Adjustment__c item:lstMA)
		{
			curMA = item.clone();
			curMA.RecordTypeId = mapRecordTypeNames2Ids.get(mapRecordTypeIds2Names.get(curMA.RecordTypeId).DeveloperName+'_Adjustment');
			if (item.pse__Amount__c!=null) curMA.pse__Amount__c = item.pse__Amount__c*(-1);
			lstMAToInsert.add(curMA);
		}
		if (lstMAToInsert.size()>0) insert lstMAToInsert;
	}

}