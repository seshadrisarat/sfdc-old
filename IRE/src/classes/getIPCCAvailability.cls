public class getIPCCAvailability {
public list<Due_Diligence__c> listDueDiligence{get;set;}
    public Contact objContact = new Contact();
    public list<Fund__c> fundlist{get;set;}
    public list<wrapfund> wrapfundList{get;set;}
    String conId = ApexPages.currentPage().getParameters().get('id');
    
    //constrctor
     public getIPCCAvailability(ApexPages.StandardController controller)
     { 
        if(conId !=null)
        {
          populateDueDiligencedata(conId);
        }      
     }  
    
public void populateDueDiligencedata(string id)
{
        Contact objContact = new Contact();
        objContact = [select id,Name, Account.Name, Account.ID from Contact WHERE  id =:conId];        
        listDueDiligence = new list<Due_Diligence__c>();
        listDueDiligence = [select Fund__c  from Due_Diligence__c where Account__c=:objContact.Account.ID and 
                            Release_Date__c < TODAY and Fund__r.Fund_Acronym__c='IPCC' and Received_Approval__c= TRUE];
        set<id>fundidsset=new set<id>();
        if(listDueDiligence.size() >=0 )
        {
            for(Due_Diligence__c tc:listDueDiligence)
                fundidsset.add(tc.Fund__c);
        }
   
    	wrapfundList = new list<wrapfund>();
    	for(Fund__c fu:[select id, name, Equity_Available__c
                        from Fund__c where Availability_Include__c=TRUE and id in:fundidsset]){
                            wrapfundList.add(new wrapfund(fu)); 	// add the Fund records to the wrapper class instances.                          
        }        
} 

    public class wrapfund{
        public Fund__c fun{get;set;}
        public double Amount{get;set;}
        public string strAmount{get;set;}
        
        //constructor
        public wrapfund(Fund__c fu){ 
          fun=fu;
          Amount = (double)fun.get('Equity_Available__c');  
          strAmount=currency(string.ValueOf(Amount));
        }
 
        //Format the Ammount to Currency look and feel
        public String currency(String i) {
                String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
                return s.substring(0,s.length()-1);
        }
    }
}