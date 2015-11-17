public class getDueDiligence {
  //  public getDueDiligence() { }
    public list<Due_Diligence__c> listDueDiligence{get;set;}
    public list<Fund__c> fundlist{get;set;}
    public Contact objContact = new Contact();
    String conId = ApexPages.currentPage().getParameters().get('id');


     public getDueDiligence(ApexPages.StandardController controller)
     { 

        if(conId !=null)
        {
          populateDueDiligencedata(conId);
        }
       
       
    }  
    
  public  void  populateDueDiligencedata(string id)
  {
        Contact objContact = new Contact();
        objContact = [select id,Name, Account.Name, Account.ID from Contact WHERE  id =:conId];        
        listDueDiligence = new list<Due_Diligence__c>();
        // listDueDiligence = [select Fund__c  from Due_Diligence__c where Account__c= '001q000000AO2QS' and Release_Date__c < TODAY and Fund__r.Fund_Acronym__c='IPCC' and Received_Approval__c= TRUE];
        listDueDiligence = [select Fund__c  from Due_Diligence__c where Account__c=:objContact.Account.ID and Release_Date__c < TODAY and Fund__r.Fund_Acronym__c='IPCC' and Received_Approval__c= TRUE];
        set<id>fundidsset=new set<id>();
        if(listDueDiligence.size() >0 )
        {
            for(Due_Diligence__c tc:listDueDiligence)
                fundidsset.add(tc.Fund__c);
        }
         fundlist = new list<Fund__c>();
        fundlist = [select id, name from Fund__c where Availability_Include__c=TRUE and id in:fundidsset];
  }
}