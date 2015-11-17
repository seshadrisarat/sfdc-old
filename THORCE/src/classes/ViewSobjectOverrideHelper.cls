/*
*		ViewSobjectOverrideHelper is helper class for all View <Sobject> Override Controllers.
*		This controller contains common code used for all override controllers
* 
*		Author	:	Wilson Ng 
*		Date	:	November 06, 2012
* 
*/
public with sharing class ViewSobjectOverrideHelper {

	id objId;
	string objPrefix;
	public set<string> checkProfiles{get;set;}
	PageReference flowPage1;
	string retUrl;
	string myProfile;
	
	public ViewSobjectOverrideHelper(id mid, string opref, list<string> profs, PageReference fpage, string rurl) {
		this.objId = mid;
		this.objPrefix = opref;
		this.checkProfiles = new set<string>();
		this.checkProfiles.addAll(profs);
		this.flowPage1 = fpage;
		this.retUrl = rurl;
		
		this.myProfile = [select name from Profile where id=:userinfo.getProfileId()].name;
	}
    
    public PageReference initView() {
    	PageReference nextPage = null;
    	// check current user profile.  if profile matched, then go to flow page 1, else go to normal detail page
        if(this.checkProfiles.contains(myProfile)) {
            nextPage = this.flowPage1;
            nextPage.getParameters().put('id', objId);
        }
        else {
            nextPage = new PageReference('/'+objId);
            nextPage.getParameters().put('nooverride', '1');
        }
        // add retURL parameter if in the current url
        if(!isEmpty(retUrl))
        	nextPage.getParameters().put('retURL', retUrl);
        return nextPage;
    }
    
    private boolean isEmpty(string str) { return (str==null || str==''); }
    
    //
    // test method
    @isTest
    static void testThisClass() {
    	
    	// create dummy account/tenant
    	Account acct = new Account(Name='test tenant', RecordType=new RecordType(Name='Tenant'));
    	insert acct;
    	string profileValue = [select name from Profile where id=:userinfo.getProfileId()].name;
    	
    	Test.startTest();
    	
    	// test redirect
    	ViewSobjectOverrideHelper helper = new ViewSobjectOverrideHelper(acct.Id, '001', new list<string> { profileValue }, Page.ViewTenantOverride, '/home/home.jsp');
    	PageReference nextPage = helper.initView();
    	system.assert(nextPage.getUrl().containsIgnoreCase('ViewTenantOverride'), 'Error: ViewOverride Helper class did not redirect to flow page.');
    	
    	// test nooverride
    	helper = new ViewSobjectOverrideHelper(acct.Id, '001', new list<string> { 'dummy' }, Page.ViewTenantOverride, '/home/home.jsp');
    	nextPage = helper.initView();
    	system.assert(nextPage.getUrl().containsIgnoreCase('nooverride'), 'Error: ViewOverride Helper class did not redirect to nooverride standard page.');
    	
    	Test.stopTest();
    }
}