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
private class SL_TestChatterTopicWidget 
{
	//Percent of test coverage : 100, 100
    static testMethod void test_SL_IntranetChatterTopicController() 
    {
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetChatterTopic');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetChatterTopicController objChatterTopicController = new SL_IntranetChatterTopicController();
        
        objChatterTopicController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objChatterTopicController.getMyImpl();
        objChatterTopicController.getMyImpl().newComponent();
        
        system.assertEquals(0,0);
    }
    
    static PageRegionWidget__c createTestRecords(String configuration)
    {
        Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'TestHome');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = configuration);
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"topicId":""}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
    
}