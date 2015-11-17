/*
*		MemberLandingController is used to perform Controller logic for the Members home landing page.
*		This controller checks for fcf values from url parameters and custom settings.
* 
*		Author	:	Wilson Ng 
*		Date	:	January 9, 2013
* 
*/
public with sharing class MemberLandingController {

	static string FCF_CUSTOM_PARAMETER = 'myPage:myListview:fcf';
	static string FCF_PARAMETER = 'fcf';
	
	public MemberLandingController() {
	}
	
	public PageReference init() {
		// retrieve listview id fcf parameter from myPage:myListview:fcf, fcf and custom setting fcf values
		string fcfCustomParameter = ApexPages.currentPage().getParameters().get(FCF_CUSTOM_PARAMETER);
		string fcfParameter = ApexPages.currentPage().getParameters().get(FCF_PARAMETER);
		string fcfSetting = Common_Config__c.getInstance().Members_Landing_Page_fcf_id__c;
		system.debug(string.format('in MemberLandingController constructor:  fcfCustom[{0}], fcfParameter[{1}], fcfSetting[{2}]', new list<string> { fcfCustomParameter, fcfParameter, fcfSetting }));
		
		PageReference nextPage = null;
		// if fcf custom populate, use it
		if(fcfCustomParameter!=null) {
			system.debug('using fcf custom parameter: ' + fcfCustomParameter);
			nextPage = null;
		}
		else {
			// else, use fcf if populated, else use fcf from custom setting
			string fcf = (fcfParameter!=null ? fcfParameter : fcfSetting);
			system.debug('using fcf: ' + fcf);
			nextPage = Page.MemberLandingPage;
			nextPage.getParameters().put(FCF_CUSTOM_PARAMETER, fcf);
			nextPage.setRedirect(true);
		}
		return nextPage;
	}
	
	@isTest
	static void testThisController() {
		
		// populate custom setting
		Common_Config__c cconfig = Common_Config__c.getInstance();
		cconfig.Members_Landing_Page_fcf_id__c = 'fcfsetting';
		upsert cconfig;
		
		Test.startTest();
		
		PageReference pageRef = Page.MemberLandingPage;
		Test.setCurrentPageReference(pageRef);		
		MemberLandingController controller = new MemberLandingController();
		
		// test std fcf parameter
		ApexPages.currentPage().getParameters().put(FCF_CUSTOM_PARAMETER, null);
		ApexPages.currentPage().getParameters().put(FCF_PARAMETER, 'fcfvalue');
		PageReference nextPage = controller.init();
		system.assert(nextPage.getUrl().contains(EncodingUtil.urlEncode(FCF_CUSTOM_PARAMETER,'UTF-8') + '=fcfvalue'), 'Error test1: Controller did not redirect with correct fcf custom url parameter.');
		
		// test custom fcf parameter
		ApexPages.currentPage().getParameters().put(FCF_CUSTOM_PARAMETER, 'fcfcustom');
		ApexPages.currentPage().getParameters().put(FCF_PARAMETER, null);
		nextPage = controller.init();
		system.assert(nextPage==null, 'Error test2: Controller did not return null page reference for fcf custom parameter.');
		
		// test fcf custom setting
		ApexPages.currentPage().getParameters().put(FCF_CUSTOM_PARAMETER, null);
		ApexPages.currentPage().getParameters().put(FCF_PARAMETER, null);
		nextPage = controller.init();
		system.debug('HHEERREE - ' + nextPage.getUrl());
		system.assert(nextPage.getUrl().contains(EncodingUtil.urlEncode(FCF_CUSTOM_PARAMETER,'UTF-8') + '=fcfsetting'), 'Error test3: Controller did not redirect with correct fcf custom url parameter.');
		
		Test.stopTest();
	}
}