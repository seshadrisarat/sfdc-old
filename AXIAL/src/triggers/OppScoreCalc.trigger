trigger OppScoreCalc on Opportunity (before insert, before update) {
	String labelVal = Label.Opp_Score_Fields;
	List<String> oppScoreFields = labelVal.split(',', 50);
	for(SObject o :trigger.new){
		Integer oppScore = 0;
		//for(String f :oppScoreFields){
		//	if(String.valueOf(o.get(f)).contains('https://axialmarket--c.na13.content.force.com/servlet/servlet.FileDownload?file=015a0000002m0BQ')){
		//		oppScore++;
		//	}
		//}
		//o.put('Opp_Score__c', oppScore);
	}
}