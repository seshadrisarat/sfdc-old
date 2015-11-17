public with sharing class AddWOEmailController 
{
    public String searchvalue { public get; public set; }
    public List<Work_Order_Email__c> emails { public get; private set; }
    public boolean showResults { public get; private set; }
    private String woID;
    private Work_Order__c workorder;
    
    public AddWOEmailController() 
    {
        showResults=false;
        emails=new List<Work_Order_Email__c>();
        workorder=[SELECT Id,Name FROM Work_Order__c WHERE Id=:ApexPages.currentPage().getParameters().get('woID') LIMIT 1];
    }
/*
    public AddWOEmailController(ApexPages.StandardController controller) 
    {
        showResults=false;
        emails=new List<Work_Order_Email__c>();
        woID=ApexPages.currentPage().getParameters().get('woID');
    }
*/    
    public PageReference attachEmail()
    {
        Work_Order_Email__c workorderemail=[SELECT Id,Name,Work_Order__c FROM Work_Order_Email__c WHERE ID=:ApexPages.currentPage().getParameters().get('woeID')];
        workorderemail.Work_Order__c=workorder.Id;
        update workorderemail;
        
        PageReference wopage = new ApexPages.StandardController(workorder).view();
        wopage.setRedirect(true);
        return wopage;
    }
    
    public PageReference searchEmails()
    {
        if((searchvalue!=null)&&(!searchvalue.equalsIgnoreCase('')))
        {
            try
            {
                List<List<SObject>> searchList=[FIND :searchvalue IN ALL FIELDS RETURNING Work_Order_Email__c(Id,Name,Subject__c,Sender__c,Work_Order__c,CreatedDate) ];
                emails=(List<Work_Order_Email__c>)searchList[0];
                showResults=true;
            }
            catch(System.SearchException se)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, se.getMessage()));
            }
        }
        else
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Search value is required'));
        
        return null;
    }

    public PageReference cancel() 
    {
        PageReference wopage = new ApexPages.StandardController(workorder).view();
        wopage.setRedirect(true);
        return wopage;
    }
}