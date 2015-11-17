trigger MQLTrigger on MQL__c (before insert) {

	//List<MQL__c> dedupedList = new List<MQL__c>();

	//for(MQL__c m :trigger.new){
	//	for(MQL__c orig :dedupedList){
	//		if(
	//			m.MQL_Date__c.day() == orig.MQL_Date__c.day() &&
	//			m.MQL_Date__c.month() == orig.MQL_Date__c.month() &&
	//			m.MQL_Date__c.year() == orig.MQL_Date__c.year() &&
	//			m.MQL_Date__c.minute() == orig.MQL_Date__c.minute()){

	//			if(
	//				(m.Lead__c != null && m.Lead__c == orig.Lead__c) || 
	//				(m.Contact__c != null && m.Contact__c == orig.Contact__c)
	//			  ){
	//				Boolean dupe = True;
	//			}else{
	//				dedupedList.add(m);
	//			}
	//		}
	//	}
	//}

	//List<DateTime> dts = new List<DateTime>();
	//for(MQL__c m :trigger.new){
	//	dts.add(m.MQL_Date__c);
	//}
	//List<MQL__c> dupcheck = [SELECT Id, MQL_date__c, Lead__c, Contact__c FROM MQL__c WHERE MQL_date__c in :dts];
	
	//for(MQL__c m :dedupedList){
	//	for(MQL__c dedup :dupcheck){
	//		if(
	//			m.MQL_Date__c.day() == dedup.MQL_Date__c.day() &&
	//			m.MQL_Date__c.month() == dedup.MQL_Date__c.month() &&
	//			m.MQL_Date__c.year() == dedup.MQL_Date__c.year() &&
	//			m.MQL_Date__c.minute() == dedup.MQL_Date__c.minute()){
				
	//			if(
	//				(m.Lead__c != null && m.Lead__c == dedup.Lead__c) || 
	//				(m.Contact__c != null && m.Contact__c == dedup.Contact__c)
	//			  ){
	//				//m.addError('Duplicate MQL');
	//			}
	//		}
	//	}
	//}
}