global class SL_SortProceeds implements Comparable{
	public Proceeds__c proceed;

	public SL_SortProceeds(Proceeds__c p){
		proceed = p;
	}

	global Integer compareTo(Object compareTo){
		SL_SortProceeds proceedCompareTo = (SL_SortProceeds)compareTo;
		if(proceed.Date_Posted__c == proceedCompareTo.proceed.Date_Posted__c) return 0;
		if(proceed.Date_Posted__c > proceedCompareTo.proceed.Date_Posted__c) return 1;
		return -1;
	}
}