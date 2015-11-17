/**
* \arg ClassName      : SL_Activity_NoAccess
* \arg JIRATicket     : PWP-20
* \arg CreatedOn      : 2015-03-10
* \arg LastModifiedOn : -
* \arg CreatededBy    : Edward Rivera
* \arg ModifiedBy     : -
* \arg Description    : This class serves as the controller for the SL_Activity_NoAccess page
*/
public with sharing class SL_Activity_NoAccess {
	Id returnId;
	public SL_Activity_NoAccess() {
		returnId = ApexPages.currentPage().getParameters().get('Id');//get the account id from the page and store into the accountid variable
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'ERROR: You do not have access to this activity.  Click cancel to return.'));
	}
	public PageReference cancel (){
		Pagereference returnTo = new PageReference('/'+returnId);
		returnTo.setRedirect(true);
		return returnTo;
	}
}