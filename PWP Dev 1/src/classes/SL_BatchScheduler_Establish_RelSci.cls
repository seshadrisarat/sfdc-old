global class SL_BatchScheduler_Establish_RelSci implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		Database.executeBatch(new SL_Batch_Establish_RelSci_Relationship('SELECT Id, PWP_Employee__r.username, External_Contact__r.FirstName, External_Contact__r.Lastname, External_Contact__r.Email, Account__r.Name FROM Relationship__C WHERE Relsci_Status__c = null and External_Contact__r.FirstName != null and External_Contact__r.LastName != null' ), 33);
	}
}