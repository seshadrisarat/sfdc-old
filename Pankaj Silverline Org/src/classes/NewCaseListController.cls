public class NewCaseListController 
{
  public List<Case> getNewCases()
    {
        List<Case> lstCase = [SELECT Id, CaseNumber FROM Case WHERE status =: 'New' LIMIT 1000];
        
        return lstCase;
    }
}