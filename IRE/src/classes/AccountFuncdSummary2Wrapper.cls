global class AccountFuncdSummary2Wrapper implements comparable{
    public Daily_Sale__c year{get; set;}
    public List <Daily_Sale__c> years {get;set;}
	//calling constructor
    global AccountFuncdSummary2Wrapper(Daily_Sale__c year, List<Daily_Sale__c> years){
        this.year= year;
        this.years =years;
    }
    //compare years in Daily Sales table 
    global Integer compareTo(Object compareTo)
    {
        //cast argument to AccountFuncdSummary2Wrapper
        AccountFuncdSummary2Wrapper aFS = (AccountFuncdSummary2Wrapper)compareTo;
        
        //The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (aFS.year.Sales_Date__c > aFS.year.Sales_Date__c){
            returnValue= -1;
        }
        else if (aFS.year.Sales_Date__c < aFS.year.Sales_Date__c){
            returnValue = -1;
        }
        return returnValue;
    }
}