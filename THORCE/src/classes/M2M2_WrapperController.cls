/*
*       M2M2_WrapperController is a wrapper controller for the main M2M2_Controller.
*       This controller is used for maintaining an instance of the M2M2_Controller and passing parameter attributes to the controller.
* 
*       Author  :   Wilson Ng 
*       Date    :   October 9, 2012
* 
*/
public with sharing class M2M2_WrapperController {

    public M2M2_Controller controller{get;set;}
    public String configName{get; set;}
    public Id fromId{get; set;}
    public String fromName{get; set;}
    public String pageTitle{get; set;}
    public M2M2_WrapperController() {
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
        
        M2M2_WrapperController wrapper = new M2M2_WrapperController();
        wrapper.controller = new M2M2_Controller();
        wrapper.configName = 'test config';
        wrapper.fromId = UserInfo.getUserId();
        wrapper.fromName = 'test from';
        wrapper.pageTitle = 'test title';
        PageReference nextPage = wrapper.wrapperInit();
        
        Test.stopTest();
    }
}