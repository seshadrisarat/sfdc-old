global class Batch_PBIShareUPD implements Database.Batchable<Id> 
{
	public List<ID> PBIToUpdate {get; set;}
	//public boolean isFinal {get; set;}
	public Batch_PBIShareUPD(List<Id> tmp_list)
	{
		this.PBIToUpdate = tmp_list;
	}
	global List<ID> start(Database.BatchableContext BC) 
	{
		return this.PBIToUpdate;
	}
	
	global void execute(Database.BatchableContext BC, List<ID> scope) 
	{
		if(scope != null) 
		{
		   PBISharingRules.UpdateShare(scope);
		}  
	}

	global void finish(Database.BatchableContext BC) 
	{
		//this.isFinal = true;
	}
}