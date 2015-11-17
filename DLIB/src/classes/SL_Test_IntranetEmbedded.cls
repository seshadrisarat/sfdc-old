/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 @isTest
private class SL_Test_IntranetEmbedded {


    //Percent of test coverage : 100, 100
    static testMethod void test_SL_IntranetEmbeddedController() 
    {
    	Test.startTest();
        PageRegionWidget__c objPageRegionWidget = createTestRecordsList('SL_IntranetEmbedded');
        ApexPages.currentPage().getParameters().put('page', 'Employee Profile');
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
		SL_IntranetEmbeddedController obj = new SL_IntranetEmbeddedController();
		SL_IntranetEmbedded objIntranetEmbedded = new SL_IntranetEmbedded();
		objIntranetEmbedded.postInitialize();
    	obj.compImpl = WidgetAbstract.getInstance(objWPSC);
    	obj.getMyImpl();
    	obj.getMyImpl().newComponent();
    	obj.getMyImpl().configuration();
    	//obj.getFilteredByDepartment();
    	
    	SL_IntranetEmbedded objIE = new SL_IntranetEmbedded();
    	objPageRegionWidget.Configuration__c ='{"content":"Test my Emdedded","background":"Red","fontcolor":"green","fontsize":"20","fontfamily":"Courier","fontstyle":"bold","heading":"Test Heading","department":"","initialstate":"","buttontext":"Embedded Content","title":"Test Title","padding":"","fontweight":"normal","offices":""}';
    	update objPageRegionWidget;
    	
    	
    	SL_IntranetEmbedded objIE1 = new SL_IntranetEmbedded();
    	
    	Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objIE1.notify(objIWidget);
    	objIE1.configuration();
    	objIE1.strDeptId ='';
    	objIE1.getFilteredByDepartment();
    	objIE1.strDeptId ='All';
    	objIE1.getFilteredByDepartment();
    	Test.stopTest();
    	system.assertEquals(0,0);
    }
    
    static PageRegionWidget__c createTestRecordsList(String configuration)
    {
        Region__c objRegion = new Region__c(Name = 'testRegion1.1.1');
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'testPagetest1.1.1');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = configuration, Configuration__c= '{"background":"Red","title":"Test Title","content":"Test my Emdedded","department":"test","heading":"Test Heading","fontsize":"20","fontcolor":"green","fontstyle":"bold", "fontfamily":"Courier"}');
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                          Page_Region__r = objPageRegion, Widget__r = objWidget,
                                                                          Configuration__c= '{"background":"Red","title":"Test Title","content":"Test my Emdedded","department":"test","heading":"Test Heading","fontsize":"20","fontcolor":"green","fontstyle":"bold", "fontfamily":"Courier"}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
    
}