/*
*		AdvancedSearch_WrapperController is a wrapper controller for the main AdvancedSearch_Controller.
*		This controller is used for maintaining an instance of the AdvancedSearch_Controller and passing parameter attributes to the controller.
* 
*		Author	:	Wilson Ng 
*		Date	:	October 18, 2012
* 
*/
public with sharing class AdvancedSearch_WrapperController {

	public AdvancedSearch_Controller controller{get;set;}
	public String configName{get; set;}
	public Id fromId{get; set;}
	public String fromName{get; set;}
	public String pageTitle{get; set;}

	public AdvancedSearch_WrapperController() {
	}
	
	public PageReference wrapperInit() {
		
		if(this.configName != null) {
			this.controller.configName = this.configName;
			this.controller.fromId = this.fromId;
			this.controller.fromName = this.fromName;
			this.controller.searchPageTitleOverride = this.pageTitle;
		}
		return this.controller.myinitfunc();
	}
	
	//
	// test method
	@isTest
	static void testThisClass() {
		
		Test.startTest();
		
		AdvancedSearch_WrapperController wrapper = new AdvancedSearch_WrapperController();
		wrapper.controller = new AdvancedSearch_Controller();
		wrapper.configName = 'test config';
		wrapper.fromId = UserInfo.getUserId();
		wrapper.fromName = 'test from';
		wrapper.pageTitle = 'test title';
		PageReference nextPage = wrapper.wrapperInit();
		
		Test.stopTest();
	}
}