/*
*
* @ClassName    : SL_Event_Handler
* @JIRATicket   : GREENHILL-20
* @CreatedOn    : 25/FEB/2013
* @ModifiedBy   : SL
* @Description  : 
*/


/**
@Developer Name                         :   Kamal
Percentage of best practices followed   :   100%
No of SOQL queries used                 :   1
No of collections used                  :   1
Exception Handling implemented          :   YES
Coding standards followed               :   YES
Naming conventions followed             :   YES
Third party integrations                :   NA
Maximum of No of records tested with    :   
Customer Approval                       :   
Last Modified Date                      :  5/MAR/2013
Approved by                             :   

*/


public with sharing class SL_Event_Handler 
{
	/* Start - Variables */
	/* End - Variables */ 
	
	/* Start - Conbtructor */
	public void SL_Event_Handler()
	{
		//do nothing.
	}
	/* End - Conbtructor */
	
	/*Start - Method will called on after insert of the Event */
	public void onAfterInsert(Map<Id,Event> mapIdToEventNew)
	{
		Map<Id,Event> mapIdToEventOld = new Map<Id,Event>();
		//calling methods to update the Fundraising deal object.
		updateFundraisingDeal(mapIdToEventOld, mapIdToEventNew);
	}
	/*End - Method will called on after insert of the Event */
	
	/*Start - Method will called on after update of the Event */
	public void onAfterUpdate(Map<Id,Event> mapIdToEventOld, Map<Id,Event> mapIdToEventNew)
	{
		try
		{
			Map<Id,Event> mapIdToEvent = new Map<Id,Event>();
			for(Event objEvent : mapIdToEventNew.Values())
			{
				if(objEvent.Call_Held_with_GP__c != mapIdToEventOld.get(objEvent.Id).Call_Held_with_GP__c || objEvent.Maximum_Commitment_Size__c != mapIdToEventOld.get(objEvent.Id).Maximum_Commitment_Size__c
					|| objEvent.Met_with_GP__c != mapIdToEventOld.get(objEvent.Id).Met_with_GP__c  || objEvent.Minimum_Commitment_Size__c != mapIdToEventOld.get(objEvent.Id).Minimum_Commitment_Size__c 
					|| objEvent.Next_Step__c != mapIdToEventOld.get(objEvent.Id).Next_Step__c  || objEvent.Stage__c != mapIdToEventOld.get(objEvent.Id).Stage__c ||  objEvent.Tier__c != mapIdToEventOld.get(objEvent.Id).Tier__c)
				{
					mapIdToEvent.put(objEvent.Id,objEvent);
				}
			}
			//calling methods to update the Fundraising deal object.
			updateFundraisingDeal(mapIdToEventOld, mapIdToEvent);
		}
		catch(Exception ex)
		{
			System.debug('============Exception============'+ex);
		}
	}
	/*End - Method will called on after update of the Event */
	
	/*Start - Method to update the Fundraising Deal Object */
	private void updateFundraisingDeal(Map<Id,Event> mapIdToEventOld, Map<Id,Event> mapIdToEvent)
	{
		try
		{
			Set<String> setFundRaisingDealId = new Set<String>();
			Map<String,Fundraising_Deal__c> mapIdToFundRaisingDeal = new Map<String,Fundraising_Deal__c>();
			for(Event objEvent : mapIdToEvent.values())
			{
				setFundRaisingDealId.add(objEvent.WhatId);
			}
			
			//Query all the Fundraising_Deal__c records corresponding to the task.
			for(Fundraising_Deal__c objFRD : [SELECT Id, Call_Held_with_GP__c,	Maximum_Commitment_Size__c,Met_with_GP__c,Minimum_Commitment_Size__c,Next_Step__c,Stage__c,Tier__c 
											  FROM Fundraising_Deal__c 
											  WHERE Id IN: setFundRaisingDealId])
			{
				mapIdToFundRaisingDeal.put(objFRD.Id,objFRD);
			}
			
			//Updating the Fundraising_Deal__c records.
			for(Event objEvent : mapIdToEvent.values())
			{
				if(mapIdToFundRaisingDeal.containsKey(objEvent.whatId) && objEvent.Stage__c != 'Closed' && (objEvent.Call_Held_with_GP__c != mapIdToFundRaisingDeal.get(objEvent.whatId).Call_Held_with_GP__c
																	      ||objEvent.Maximum_Commitment_Size__c != mapIdToFundRaisingDeal.get(objEvent.whatId).Maximum_Commitment_Size__c
																	      ||objEvent.Met_with_GP__c != mapIdToFundRaisingDeal.get(objEvent.whatId).Met_with_GP__c
																	      ||objEvent.Minimum_Commitment_Size__c != mapIdToFundRaisingDeal.get(objEvent.whatId).Minimum_Commitment_Size__c
																	      ||objEvent.Next_Step__c != mapIdToFundRaisingDeal.get(objEvent.whatId).Next_Step__c
																	      ||objEvent.Stage__c != mapIdToFundRaisingDeal.get(objEvent.whatId).Stage__c
																	      ||objEvent.Tier__c != mapIdToFundRaisingDeal.get(objEvent.whatId).Tier__c))
				{
					Fundraising_Deal__c objFRD = mapIdToFundRaisingDeal.get(objEvent.whatId);
					if(objEvent.Call_Held_with_GP__c)
						objFRD.Call_Held_with_GP__c = objEvent.Call_Held_with_GP__c;
					if(objEvent.Met_with_GP__c)
						objFRD.Met_with_GP__c = objEvent.Met_with_GP__c;
						
					//Checking if the Event fileds is updated or not.	
					if(mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Maximum_Commitment_Size__c != mapIdToEventOld.get(objEvent.Id).Maximum_Commitment_Size__c && objEvent.Maximum_Commitment_Size__c != null)
						objFRD.Maximum_Commitment_Size__c = objEvent.Maximum_Commitment_Size__c;
					else if(!mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Maximum_Commitment_Size__c != null)//This is for insert case.
						objFRD.Maximum_Commitment_Size__c = objEvent.Maximum_Commitment_Size__c;
					//Checking if the Event fileds is updated or not.	
					if(mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Minimum_Commitment_Size__c != mapIdToEventOld.get(objEvent.Id).Minimum_Commitment_Size__c && objEvent.Minimum_Commitment_Size__c != null)
						objFRD.Minimum_Commitment_Size__c = objEvent.Minimum_Commitment_Size__c;
					else if(!mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Minimum_Commitment_Size__c != null)//This is for insert case.
						objFRD.Minimum_Commitment_Size__c = objEvent.Minimum_Commitment_Size__c;
					//Checking if the Event fileds is updated or not.
					if(mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Next_Step__c != mapIdToEventOld.get(objEvent.Id).Next_Step__c && objEvent.Next_Step__c != null && objEvent.Next_Step__c != '')
						objFRD.Next_Step__c = objEvent.Next_Step__c;
					else if(!mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Next_Step__c != null && objEvent.Next_Step__c != '')//This is for insert case.
						objFRD.Next_Step__c = objEvent.Next_Step__c;
					//Checking if the Event fileds is updated or not.	
					if(mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Stage__c != mapIdToEventOld.get(objEvent.Id).Stage__c && objEvent.Stage__c != null && objEvent.Stage__c !='')
						objFRD.Stage__c = objEvent.Stage__c;
					else if(!mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Stage__c != null && objEvent.Stage__c !='')//This is for insert case.
						objFRD.Stage__c = objEvent.Stage__c;
					//Checking if the Event fileds is updated or not.	
					if(mapIdToEventOld.containsKey(objEvent.Id) && objEvent.Tier__c != mapIdToEventOld.get(objEvent.Id).Tier__c && objEvent.Tier__c != null && objEvent.Tier__c != '')
						objFRD.Tier__c = objEvent.Tier__c;
					else if(objEvent.Tier__c != null && objEvent.Tier__c != '')//This is for insert case.
						objFRD.Tier__c = objEvent.Tier__c;
						
					mapIdToFundRaisingDeal.put(objFRD.Id,objFRD);
				}
			}
			
			
			if(mapIdToFundRaisingDeal.size() > 0)
				update mapIdToFundRaisingDeal.values();
		}
		catch(Exception ex)
		{
			System.debug('================Exception======='+ex);
		}
		
	}
	/*End - Method to update the Fundraising Deal Object */
	
	/* Start - Test Method */
	@isTest
    static void SL_Event_Test()
    {
    	Fundraising_Deal__c objFRD = new Fundraising_Deal__c(Name='FRD1');
    	insert objFRD;
    	
    	Event objEvent = new Event(StartDateTime = datetime.now(), EndDateTime = datetime.now().addDays(1), Call_Held_with_GP__c = false, Maximum_Commitment_Size__c = 200, Met_with_GP__c = false, Minimum_Commitment_Size__c = 1200, Next_Step__c='Test', Stage__c='Circled', Tier__c='Tier I', whatId=objFRD.Id);
    	insert objEvent;
    	
    	objEvent.Maximum_Commitment_Size__c = 300;
    	objEvent.Call_Held_with_GP__c = true;
    	objEvent.Minimum_Commitment_Size__c = 30000;
    	objEvent.Stage__c = 'Strong Interest';
    	objEvent.Next_Step__c = 'This is test';
    	objEvent.Tier__c = 'Tier II';
    	objEvent.Met_with_GP__c = true;
    	update objEvent;
    }
	/* End - Test Method */
}