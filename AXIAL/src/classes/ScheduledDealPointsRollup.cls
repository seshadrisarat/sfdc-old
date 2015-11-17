global class ScheduledDealPointsRollup implements Schedulable{
	global void execute(SchedulableContext sc) {
		UpdateContactDealPoints obj = new UpdateContactDealPoints();
		obj.query = 'SELECT Three_Month_Deal_Points__c, Six_Month_Deal_Points__c, Twelve_Month_Deal_Points__c FROM Contact';
		Database.executeBatch(obj, 100);
	}
}