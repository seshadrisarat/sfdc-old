trigger MeetingNote_StatsUpdate on Meeting_Note__c (after delete, after insert, after update) 
{
	List<Meeting_Note__c> lNotes=(trigger.isDelete?trigger.old:trigger.new);
	List<Meeting_Agenda_Item__c> lItems=new List<Meeting_Agenda_Item__c>();
	
	for(Meeting_Note__c n : lNotes)
	{
		lItems.add(new Meeting_Agenda_Item__c(Id=n.Agenda_Item__c));
	}
	
	List<AggregateResult> lStats=[SELECT Agenda_Item__c, AVG(Numeric_Vote_Value__c) AvgVote,AVG(Numeric_Quality_of_Materials_Value__c) AvgQoM, AVG(Numeric_Would_Invest_Value__c) AvgProInvest, COUNT(id) NumVotes FROM Meeting_Note__c WHERE Agenda_Item__c IN :lItems GROUP BY Agenda_Item__c];
	lItems=new List<Meeting_Agenda_Item__c>();
	System.debug(lStats);
	
	
	for(AggregateResult ar : lStats)
	{
		lItems.add(new Meeting_Agenda_Item__c(id=(id)ar.get('Agenda_Item__c'), Average_Vote__c=(Decimal)ar.get('AvgVote'), Average_QoM__c=(Decimal)ar.get('AvgQoM'), Average_Pro_Investment__c=(Decimal)ar.get('AvgProInvest'), Vote_Count__c=(Decimal)ar.get('NumVotes') ));
	}
	
	if(lItems.size()>0) update lItems;
}