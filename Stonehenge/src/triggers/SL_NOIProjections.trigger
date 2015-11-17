/*Trigger on insert of NOI Projection records
* Trigger Name  : SL_NOIProjections 
* JIRA Ticket   : STONEPIII-6
* Created on    : 26/April/2013
  Created by    : Shailendra
* Modified by   : 
* Description   : Implement a trigger on insert of NOIProjections which populating the NOI_Projection_c.NAME into the Operating_Expense1c.Operating_Expense_c.
*/
trigger SL_NOIProjections on NOI_Projection__c (after insert) 
{
	SL_NOIProjections_Handler handler = new SL_NOIProjections_Handler();
	
	if(Trigger.isInsert){
		if(Trigger.isAfter)	{
			handler.OnAfterInsert(Trigger.new);
		}	
	}
}