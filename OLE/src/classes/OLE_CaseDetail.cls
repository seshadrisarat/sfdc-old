/*
    * Name         : OLE_CaseDetail
    * JIRA Ticket  : 
    * Author       : F8 Dev Team
    * Description  : Controller for Register Page   
*/
public class OLE_CaseDetail 
{
    public Case objCase                                                     {   get;set;    } // object for case
    public CaseComment objCaseComment                                       {   get;set;    } // object for caseComment
    public List<CaseComment> lstCaseComment                                 {   get;set;   }
    
    private String strCaseId;
    
    /* Start constructor */
    public OLE_CaseDetail()
    {
        initialization();
    }
    /* End constructor */
    
    /* Start - initialization */
    public void initialization()
    {
        objCase = new Case();
        objCaseComment = new CaseComment(IsPublished = true, ParentId = strCaseId);
        strCaseId = System.currentPagereference().getParameters().get('Id');
        if((!String.isEmpty(strCaseId)) && (strCaseId.length() == 15 || strCaseId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', strCaseId))
        {
            List<Case> lstCase = OLE_CommonShare.getSobjectRecords(OLE_CommonShare.prepareQuery('Case',OLE_CommonShare.getCSVField('Case','OLE_CaseDetailLeft', 'OLE_CaseDetailRight'), '', '', 'Id = \''+strCaseId+'\'','','','1'));
            objCase = lstCase.isEmpty() ? new Case() : lstCase[0];
        }
        else
            objCase = new Case();
        lstCaseComment = new List<CaseComment>();
        getCaseDetails();
    }
    /* End - initialization */
    
    /* Start - redirectUnAuthenticatedUser */
    public PageReference redirectUnauthenticatedUser()
    {
        return OLE_CommonShare.redirectToSignInPage();
    }
    /* End - redirectUnAuthenticatedUser */
    
    /* start - SaveCaseComment */
    public Pagereference SaveCaseComment(){
    
        objCaseComment.ParentId = objCase.Id;
        insert objCaseComment;
        getCaseDetails();
        //new Pagereference('/CaseDetail?Id='+objCase.Id);
        return null;
    }
    /* End - SaveCaseComment */
    
    /* start - getCaseDetails */
    private void getCaseDetails()
    {
        lstCaseComment = [Select Id,
                                CreatedDate,
                                CommentBody,
                                CreatedById,
                                CreatedBy.Name
                           From CaseComment
                           where ParentId = :objCase.Id];
    }
    /* End - getCaseDetails */
}