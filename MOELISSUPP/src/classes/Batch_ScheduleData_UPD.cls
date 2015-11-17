global class Batch_ScheduleData_UPD implements Database.Batchable<sObject> 
{
	public List<sObject> ScheduleDataToUpdate {get; set;}

	public Batch_ScheduleData_UPD(List<sObject> tmp_list)
	{
		this.ScheduleDataToUpdate = tmp_list;
	}
	global List<sObject> start(Database.BatchableContext BC) 
	{
		return this.ScheduleDataToUpdate;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) 
	{
		if(scope != null && scope.size() > 0) 
		{
		   insert scope;
		}  
	}
	
	global void finish(Database.BatchableContext BC) {}
}