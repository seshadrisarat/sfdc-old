public class AccountFundSummary2 {
    
 	public list<AggregateResult> lstAr = new list<AggregateResult>();
    public list<AggregateResult> lstAr2 = new list<AggregateResult>();
    public Map<String,Map<integer,String>> MapResults {get; set;}			// Map gets YTD all the way to 5 years back
    public Map<String,Map<integer,String>> MapPriorYearResults {get; set;}	// this Map only to get prior year from 6 year ago and beyond
    
    public list<String> yearList {get;set;}								// A list to get the year of the fund and sort by it.
      
    //Include ApexPages within the constractor so it will tie up with the specific accountID
    public AccountFundSummary2(ApexPages.StandardController std){
       String acctId = ApexPages.currentPage().getParameters().get('id');
        lstAr = [select Fund__r.Fund_Acronym__c fn, FISCAL_YEAR(Sales_Date__c) Ye, Sum(Amount__c) amt
                from Daily_Sale__c 
                where  Account__c = :acctId and Sales_Date__c >= LAST_N_YEARS:5
                Group BY Fund__r.Fund_Acronym__c, FISCAL_YEAR(Sales_Date__c) order by FISCAL_YEAR(Sales_Date__c) ASC];
       
            lstAr2 = [select Fund__r.Fund_Acronym__c fn, Sum(Amount__c) amt
                from Daily_Sale__c
                where  Account__c = :acctId  and Sales_Date__c < LAST_N_YEARS:5
                Group BY Fund__r.Fund_Acronym__c];       
    }

   
    
    public Map<String, Map<integer,String>> getresults2()
    {
        MapResults = new Map<String, Map<integer, String>>();			// YTD, 2014, 2013, 2012, 2011, 2010        
   		MapPriorYearResults = new Map<String, Map<integer, String>>();  // prior years up to 2009
        
        integer currentYear = System.today().year();
        Double firstYearTotal = 0;
        
        yearList = new List<string>();        
      	yearList.addAll(MapResults.keySet());
	  	yearList.sort();
        List<String> sortedList = new List<String>();
        for(Integer i = sortedList.size() -1; i >= 0; i--)
        {
           sortedList.add(yearList.get(i));
        }
        
        
                
        for(AggregateResult ar:lstAr)
        {  
           string FundName = (string)ar.get('fn');
           if(MapResults.get(FundName) == null)
           {
              MapResults.put(FundName, new Map<integer, String>());
           }
           MapResults.get(FundName).put((integer)ar.get('Ye'),currency(string.valueOf(ar.get('amt')))); 
        }
   
      
	        
              
         for(AggregateResult ar:lstAr2){     
           string FundName = (string)ar.get('fn');
                if(MapResults.get(FundName) == null)
            {
                MapResults.put(FundName, new Map<integer, String>());
            }
                  
           MapResults.get(FundName).put(currentYear - 6,currency(string.valueOf(ar.get('amt'))));          
         }
        
        
        
        
        for(string loopFN:MapResults.keySet()){
               integer loopYear;
               Double TA = 0;
                for (integer i = 0; i < 7 ; i++ )
                {
                    loopYear = currentYear - i;
                    if(MapResults.get(loopFN).get(loopYear) == null)
                    {
                        MapResults.get(loopFN).put(loopYear,'0');
                    }
                    else
                    {
                        TA = TA + Double.valueOf(MapResults.get(loopFn).get(loopYear).replaceAll(',',''));
                    }
                }
                MapResults.get(loopFN).put(3000,currency(string.valueOf(TA)));  
           }
        
        
        
        return MapResults;
    }   
    public static String currency(String i) {
    String s = ( decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
    return s.substring(0,s.length()-1);
     }

}