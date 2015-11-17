public with sharing class TMT_locatectc {

    private final contact myctc;

    public TMT_locatectc(ApexPages.StandardController stdcontroller) {
        this.myctc = (contact)stdController.getRecord();

    }


    string url;
    string coor;
    string loc;

    public string getloc() {
    
            url = 'http://maps.google.com/maps/geo?output=csv&q=' + myctc.mailingstreet + '+' + myctc.mailingcity + '+' + myctc.mailingstate;
    
          
             loc = buildurl.getpic(url);
                       
            return loc;
            }
       
        

    


}