/*
     * Name         : OLE_CaseEntry
     * JIRA Ticket  : 
     * Author       : F8 Dev Team
     * Description  : Controller to submit a case

     * Maintenance History:
     * 30/10/2015 - 1.0 - Created    
*/ 

public class OLE_CaseEntry
{
    public String strCaseType                       {   get;set;    }
    public Case objCase                             {   get;set;    }
    
    /*Start - constructor*/
    public OLE_CaseEntry()
    {
        initialize();
    }
    /*End - constructor*/
    
    /*Start - createTicket*/
    public pageReference createTicket()
    {   
        try
        {
            if(objCase != null && objCase.Id == null)
                insert objCase;

            return new Pagereference(Site.getBaseUrl()+'/CaseDetail?Id='+objCase.Id);
        }
        catch(Exception ex){}
        
        return null;   
    }
    /*End - createTicket*/
    
    /*Start - initialize*/
    private void initialize()
    {
        objCase = new Case();
    }  
    /*End - initialize*/
}