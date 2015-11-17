trigger UpdateProjectStatus on Task_Activity__c (after insert, after update) 
{
	List<Task__c> ts=new List<Task__c>();
	
	for(Task_Activity__c ta : trigger.new)
	{
		Task__c t=new Task__c(Id=ta.Task__c, Next_Steps__c=ta.Next_Steps__c);
		ts.add(t);
	}

	if(ts.size()>0)
		update ts;
}