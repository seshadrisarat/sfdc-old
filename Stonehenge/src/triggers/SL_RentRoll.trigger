/*Trigger on insert,update,delete of RentRoll records
* Trigger Name  : SL_RentRoll 
* JIRA Ticket   : STONEPIII-1 and STONEPIII-5
* Created on    : 29/Mar/2013
  Created by    : Shailendra
* Modified by   : 
* Description   : Implement a trigger on insert/update/delete of RentRoll which rollsup values to parent Deal record
*/
trigger SL_RentRoll on Rent_Roll__c (after delete, after insert, after update) 
{
	SL_RentRoll_Handler objHandler = new SL_RentRoll_Handler();
	
	if(Trigger.isAfter && Trigger.isInsert)
	{
		objHandler.rollUpRentRollValuesToDealFields(Trigger.New);
	}
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		objHandler.rollUpRentRollValuesToDealFields(Trigger.New);
	}
	if(Trigger.isAfter && Trigger.isDelete)   
	{
		objHandler.rollUpRentRollValuesToDealFields(Trigger.Old);
	}
}