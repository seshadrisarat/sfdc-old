global class Batch_DealShareUPD implements Database.Batchable<Id> 
{
	public List<ID> DealToUpdate {get; set;}
	//public boolean isFinal {get; set;}
	public Batch_DealShareUPD(List<Id> tmp_list)
	{
		this.DealToUpdate = tmp_list;
	}
	global List<ID> start(Database.BatchableContext BC) 
	{
		return this.DealToUpdate;
	}
	
	global void execute(Database.BatchableContext BC, List<ID> scope) 
	{
		if(scope != null) 
		{
		   DealSharingRules.UpdateShare(scope);
		}  
	}

	global void finish(Database.BatchableContext BC) 
	{
		//this.isFinal = true;
	}
}