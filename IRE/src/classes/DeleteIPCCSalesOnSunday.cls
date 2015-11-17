global class DeleteIPCCSalesOnSunday implements Schedulable{	
	global void execute(SchedulableContext SC)
	{
		massDelete();
	}
	
	public void massDelete()
	{
		List <Daily_Sale__c> listtoDelete = [select id 
		From daily_sale__c 
		where Fund__r.name <> 'Modell Pharmacy Custom' and fund__r.fund_acronym__c = 'ipcc' limit 10000]; 
		delete listtodelete;
	}
}