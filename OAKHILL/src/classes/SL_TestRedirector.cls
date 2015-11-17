@isTest
public class SL_TestRedirector {

	static testMethod void unitTestRedirector() {
	
    PageReference pageRef = Page.SL_MeetingNoteTask;
    pageRef.getParameters().put('id', '00T123123123ABC');
    
    Test.setCurrentPage(pageRef);

    SL_Redirector__c cs = new SL_Redirector__c(Disable_Redirect__c = true);
    insert cs;
    
    Test.startTest();

    ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new Task());
    SL_Redirector redir = new SL_Redirector(sc);
    redir.redirect();

    sc = new ApexPages.Standardcontroller(new Event());
    
    pageRef.getParameters().remove('id');

    redir = new SL_Redirector(sc);
    redir.redirect();

    pageRef = Page.SL_MeetingNoteEvent;
    redir = new SL_Redirector(sc);
    redir.redirect();

    Test.stopTest();

	}
}