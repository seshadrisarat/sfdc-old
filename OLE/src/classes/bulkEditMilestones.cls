public class bulkEditMilestones{
	
    public Projects__c Proj { get; set; }
    public Milestones__c[] milestone {get; set;}
   
public bulkEditMilestones() {
	// Populate lists
	Proj = [select id, name from Projects__c where id =:ApexPages.currentpage().getParameters().get('id')];
    //Proj = [select id, name from Projects__c where id =:ApexPages.currentpage().getParameters().get('id')];  
    milestone = [select Name, Phase__c, Original_Completion_Date__c, Revised_Est_Completion_Date__c
                      , Actual_Completion_Date__c, Progress__c, Status__c 
                 from Milestones__c 
                 where project__c = :Proj.id
                 order by Latest_of_Est_Date_and_Rev_Date__c 
                ];
     
    if (milestone.size() ==0)
    	milestone = new Milestones__c[] {};
	}

  public pageReference save() {
    try {
      update milestone;
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