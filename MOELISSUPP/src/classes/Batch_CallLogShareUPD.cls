global class Batch_CallLogShareUPD implements Database.Batchable<Id> 
{
	public List<ID> CallLogToUpdate {get; set;}
	//public boolean isFinal {get; set;}
	public Batch_CallLogShareUPD(List<Id> tmp_list)
	{
		this.CallLogToUpdate = tmp_list;
	}
	global List<ID> start(Database.BatchableContext BC) 
	{
		return this.CallLogToUpdate;
	}
	
	global void execute(Database.BatchableContext BC, List<ID> scope) 
	{
		if(scope != null) 
		{
		   CallLogSharingRules.UpdateShare(scope);
		}  
	}

	global void finish(Database.BatchableContext BC) 
	{
		//this.isFinal = true;
	}
}