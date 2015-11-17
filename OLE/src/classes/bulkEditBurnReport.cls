public class bulkEditBurnReport{
  
    public Projects__c Proj { get; set; }
    public Burn_Report__c[] burn {get; set;}
   
public bulkEditBurnReport() {
  // Populate lists
  Proj = [select id, name from Projects__c where id =:ApexPages.currentpage().getParameters().get('id')];
    //Proj = [select id, name from Projects__c where id =:ApexPages.currentpage().getParameters().get('id')];  
    burn = [select Name, Role__c, Resource__c, Rate_hr__c, Budget_Hrs__c, Actual_Hours_to_date__c, Forecast_Final_Hours__c
                 from Burn_Report__c 
                 where project__c = :Proj.id
                ];
     
    if (burn.size() ==0)
      burn = new Burn_Report__c[] {};
  }

  public pageReference save() {
    try {
      update burn;
    } 
    catch( Exception e ) {}

    pageReference pr = new pageReference('/'+ Proj.id);
    pr.setredirect(true);
    return pr;  
  }

  public pageReference cancel() {
    pageReference pr = new pageReference('/'+ Proj.id);
    pr.setredirect(true);
    return pr;  
  }

}