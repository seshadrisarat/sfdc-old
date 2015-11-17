public class ResearchProjectApproverController 
{
    public Project__c project { get; private set; }
    
    public ResearchProjectApproverController()
    {
        Id idProjectID=ApexPages.currentPage().getParameters().get('Id');
        project=[SELECT Id,Name,OwnerId,Owner.Name,Status__c FROM Project__c WHERE Id=:idProjectID LIMIT 1];
    }
    
    public PageReference approveProject()
    {     
        Profile p=[SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1];  
        
        if(project.Status__c=='Completed / Awaiting Approval')
        { 
            if( (project.OwnerId==UserInfo.getUserId()) || (p.Name=='Genpact Admin') )
            {
                project.Status__c='Approved';
                update project;
            }
        }
        
        return new PageReference('/'+project.Id);
    }
    
     private static testMethod void test() 
     {
        Project__c p = new Project__c(Name = 'Project', Status__c='Completed / Awaiting Approval' );
        insert p;
        
        ApexPages.currentPage().getParameters().put('Id', p.Id);
        ResearchProjectApproverController controller=new ResearchProjectApproverController();
        controller.approveProject();
     }   
}