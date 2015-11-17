/**
* \arg ClassName      : SL_BatchScheduler_CreateRelationships
* \arg JIRATicket     : PWP-5
* \arg CreatedOn      : 5/DEC/2014
* \arg LastModifiedOn : 11/DEC/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as scheduler for SL_Batch_CreateRelationships batch apex
*/
global class SL_BatchScheduler_CreateRelationships implements Schedulable
{
	//execute method of schedulable interface
	global void execute(SchedulableContext sc)
	{
		//calling batch process for task
		Database.executeBatch(new SL_Batch_CreateRelationships('SELECT Id, OwnerId, (SELECT RelationId, TaskId FROM TaskRelations) FROM Task WHERE WhoId!=null'));
	}
}