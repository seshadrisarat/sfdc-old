/*
*
* @ClassName    : SL_Task_Handler
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
Last Modified Date                      :  19/MAR/2013
Approved by                             :   

*/


public with sharing class SL_Task_Handler 
{
	/* Start - Variables */
	/* End - Variables */ 
	
	/* Start - Conbtructor */
	public void SL_Task_Handler()
	{
		//do nothing.
	}
	/* End - Conbtructor */
	
	/*Start - Method will called on after insert of the Task */
	public void onAfterInsert(Map<Id,Task> mapIdToTaskNew)
	{
		Map<Id,Task> mapIdToTaskOld = new Map<Id,Task>();
		//calling methods to update the Fundraising deal object.
		updateFundraisingDeal(mapIdToTaskOld,mapIdToTaskNew);
	}
	/*End - Method will called on after insert of the Task */
	
	/*Start - Method will called on after update of the Task */
	public void onAfterUpdate(Map<Id,Task> mapIdToTaskOld, Map<Id,Task> mapIdToTaskNew)
	{
		try
		{
			Map<Id,Task> mapIdToTask = new Map<Id,Task>();
			for(Task objTask : mapIdToTaskNew.Values())
			{
				if(objTask.Call_Held_with_GP__c != mapIdToTaskOld.get(objTask.Id).Call_Held_with_GP__c || objTask.Maximum_Commitment_Size__c != mapIdToTaskOld.get(objTask.Id).Maximum_Commitment_Size__c
					|| objTask.Met_with_GP__c != mapIdToTaskOld.get(objTask.Id).Met_with_GP__c  || objTask.Minimum_Commitment_Size__c != mapIdToTaskOld.get(objTask.Id).Minimum_Commitment_Size__c 
					|| objTask.Next_Step__c != mapIdToTaskOld.get(objTask.Id).Next_Step__c  || objTask.Stage__c != mapIdToTaskOld.get(objTask.Id).Stage__c ||  objTask.Tier__c != mapIdToTaskOld.get(objTask.Id).Tier__c)
				{
					mapIdToTask.put(objTask.Id,objTask);
				}
			}
			//calling methods to update the Fundraising deal object.
			updateFundraisingDeal(mapIdToTaskOld,mapIdToTask);
		}
		catch(Exception ex)
		{
			System.debug('============Exception============'+ex);
		}
	}
	/*End - Method will called on after update of the Task */
	
	/*Start - Method to update the Fundraising Deal Object */
	private void updateFundraisingDeal(Map<Id,Task> mapIdToTaskOld,Map<Id,Task> mapIdToTask)
	{
		try
		{
			Set<String> setFundRaisingDealId = new Set<String>();
			Map<String,Fundraising_Deal__c> mapIdToFundRaisingDeal = new Map<String,Fundraising_Deal__c>();
			for(Task objTask : mapIdToTask.values())
			{
				setFundRaisingDealId.add(objTask.WhatId);
			}
			
			//Query all the Fundraising_Deal__c records corresponding to the task.
			for(Fundraising_Deal__c objFRD : [SELECT Id, Call_Held_with_GP__c,	Maximum_Commitment_Size__c,Met_with_GP__c,Minimum_Commitment_Size__c,Next_Step__c,Stage__c,Tier__c 
											  FROM Fundraising_Deal__c 
											  WHERE Id IN: setFundRaisingDealId])
			{
				mapIdToFundRaisingDeal.put(objFRD.Id,objFRD);
			}
			
			//Updating the Fundraising_Deal__c records.
			for(Task objTask : mapIdToTask.values())
			{
				if(mapIdToFundRaisingDeal.containsKey(objTask.whatId) && objTask.Stage__c != 'Closed' && (objTask.Call_Held_with_GP__c != mapIdToFundRaisingDeal.get(objTask.whatId).Call_Held_with_GP__c
																	      ||objTask.Maximum_Commitment_Size__c != mapIdToFundRaisingDeal.get(objTask.whatId).Maximum_Commitment_Size__c
																	      ||objTask.Met_with_GP__c != mapIdToFundRaisingDeal.get(objTask.whatId).Met_with_GP__c
																	      ||objTask.Minimum_Commitment_Size__c != mapIdToFundRaisingDeal.get(objTask.whatId).Minimum_Commitment_Size__c
																	      ||objTask.Next_Step__c != mapIdToFundRaisingDeal.get(objTask.whatId).Next_Step__c
																	      ||objTask.Stage__c != mapIdToFundRaisingDeal.get(objTask.whatId).Stage__c
																	      ||objTask.Tier__c != mapIdToFundRaisingDeal.get(objTask.whatId).Tier__c))
				{
					Fundraising_Deal__c objFRD = mapIdToFundRaisingDeal.get(objTask.whatId);
					if(objTask.Call_Held_with_GP__c)
						objFRD.Call_Held_with_GP__c = objTask.Call_Held_with_GP__c;
					if(objTask.Met_with_GP__c)
						objFRD.Met_with_GP__c = objTask.Met_with_GP__c;
						
					//Checking if the Task fileds is updated or not.	
					if(mapIdToTaskOld.containsKey(objTask.Id) && objTask.Maximum_Commitment_Size__c != mapIdToTaskOld.get(objTask.Id).Maximum_Commitment_Size__c && objTask.Maximum_Commitment_Size__c != null)
						objFRD.Maximum_Commitment_Size__c = objTask.Maximum_Commitment_Size__c;
					else if(!mapIdToTaskOld.containsKey(objTask.Id) && objTask.Maximum_Commitment_Size__c != null)//This is for insert case.
						objFRD.Maximum_Commitment_Size__c = objTask.Maximum_Commitment_Size__c;
					//Checking if the Task fileds is updated or not.	
					if(mapIdToTaskOld.containsKey(objTask.Id) && objTask.Minimum_Commitment_Size__c != mapIdToTaskOld.get(objTask.Id).Minimum_Commitment_Size__c && objTask.Minimum_Commitment_Size__c != null)
						objFRD.Minimum_Commitment_Size__c = objTask.Minimum_Commitment_Size__c;
					else if(!mapIdToTaskOld.containsKey(objTask.Id) && objTask.Minimum_Commitment_Size__c != null)//This is for insert case.
						objFRD.Minimum_Commitment_Size__c = objTask.Minimum_Commitment_Size__c;
					//Checking if the Task fileds is updated or not.
					if(mapIdToTaskOld.containsKey(objTask.Id) && objTask.Next_Step__c != mapIdToTaskOld.get(objTask.Id).Next_Step__c && objTask.Next_Step__c != null && objTask.Next_Step__c != '')
						objFRD.Next_Step__c = objTask.Next_Step__c;
					else if(!mapIdToTaskOld.containsKey(objTask.Id) && objTask.Next_Step__c != null && objTask.Next_Step__c != '')//This is for insert case.
						objFRD.Next_Step__c = objTask.Next_Step__c;
					//Checking if the Task fileds is updated or not.	
					if(mapIdToTaskOld.containsKey(objTask.Id) && objTask.Stage__c != mapIdToTaskOld.get(objTask.Id).Stage__c && objTask.Stage__c != null && objTask.Stage__c !='')
						objFRD.Stage__c = objTask.Stage__c;
					else if(!mapIdToTaskOld.containsKey(objTask.Id) && objTask.Stage__c != null && objTask.Stage__c !='')//This is for insert case.
						objFRD.Stage__c = objTask.Stage__c;
					//Checking if the Task fileds is updated or not.	
					if(mapIdToTaskOld.containsKey(objTask.Id) && objTask.Tier__c != mapIdToTaskOld.get(objTask.Id).Tier__c && objTask.Tier__c != null && objTask.Tier__c != '')
						objFRD.Tier__c = objTask.Tier__c;
					else if(objTask.Tier__c != null && objTask.Tier__c != '')//This is for insert case.
						objFRD.Tier__c = objTask.Tier__c;
						
					mapIdToFundRaisingDeal.put(objFRD.Id,objFRD);
				}
			}
			
			//Updating the FundraisingDeal object.
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
    static void SL_Task_Test()
    {
    	Fundraising_Deal__c objFRD = new Fundraising_Deal__c(Name='FRD1');
    	insert objFRD;
    	
    	Task objTask = new Task(Call_Held_with_GP__c = true, Maximum_Commitment_Size__c = 200, Met_with_GP__c = true, Minimum_Commitment_Size__c = 1200, Next_Step__c='Test', Stage__c='Circled', Tier__c='Tier I', whatId=objFRD.Id);
    	insert objTask;
    	
    	objTask.Maximum_Commitment_Size__c = 300;
    	objTask.Call_Held_with_GP__c = true;
    	objTask.Minimum_Commitment_Size__c = 30000;
    	objTask.Stage__c = 'Strong Interest';
    	objTask.Next_Step__c = 'This is test';
    	objTask.Tier__c = 'Tier II';
    	objTask.Met_with_GP__c = true;
    	update objTask;
    }
	/* End - Test Method */
}