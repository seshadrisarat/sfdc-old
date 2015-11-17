public with sharing class TMT_locateacct {

    private final account m;
    
    string url;    

    string loc;
    
    

    public TMT_locateacct(ApexPages.StandardController stdcontroller) {
    
        this.m = (account)stdController.getRecord();
        

    }
    

   
    public string getloc() {
    
           url = 'http://maps.google.com/maps/geo?output=csv&q=' + m.billingstreet + '+' + m.billingcity + '+' + m.billingstate;
                
           loc = buildurl.getpic(url);
            
            return loc;
            }


            
       
        

    


}