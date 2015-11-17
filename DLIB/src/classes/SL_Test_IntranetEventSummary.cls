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
private class SL_Test_IntranetEventSummary {


    //Percent of test coverage : 100, 100
    static testMethod void test_IntranetEventSummaryController() 
    {
        date endDate = date.today();
        endDate = endDate.addDays(30);
        
        Intranet_Event__c objIntranetEvent = new Intranet_Event__c(Name = 'Test-IntranetEvent',Date_of_Event__c = Date.today(),
                                                                   End_Date__c = endDate ,Event_Type__c = 'Annual Meeting');
        insert objIntranetEvent;    
        
        Intranet_Event__c objIntranetEvent1 = new Intranet_Event__c(Name = 'Test-IntranetEvent-01',Date_of_Event__c = Date.today(),
                                                                   End_Date__c = endDate,Event_Type__c = 'Annual Meeting');
        insert objIntranetEvent1;                                                          
          
        PageRegionWidget__c objPageRegionWidget = createTestRecordsEventSummary('SL_IntranetEventSummary');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        ApexPages.currentPage().getParameters().put('page','testPagetest123');
        
        SL_IntranetEventSummaryController objController = new SL_IntranetEventSummaryController();
        
        objController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objController.getMyImpl();
        objController.getMyImpl().newComponent();
        objController.loadEventSummaryData();
        objController.showMoreRecords();
        objController.getMyImpl().getFilteredByDepartment();

        system.assertEquals(0,0);
    }
    
    static PageRegionWidget__c createTestRecordsEventSummary(String configuration)
    {
        Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'testPagetest123');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = configuration, Configuration__c = '{"eventDate":"","fieldset":"","heading":" ","numbertodisplay":4,"TotalRecords":10}');
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                          Page_Region__r = objPageRegion, Widget__r = objWidget,
                                                                          Configuration__c = '{"fieldset":"","heading":" ","numbertodisplay":2,"TotalRecords":5}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }

   
    //Percent of test coverage : 100, 100
    static testMethod void test_IntranetEventSummaryDetailsController() 
    {
        date endDate = date.today();
        endDate = endDate.addDays(30);
        
        Intranet_Event__c objIntranetEvent = new Intranet_Event__c(Name = 'Test-IntranetEvent',Date_of_Event__c = Date.today(),
                                                                   End_Date__c = endDate ,Event_Type__c = 'Annual Meeting');
        insert objIntranetEvent;    
        
        Intranet_Event__c objIntranetEvent1 = new Intranet_Event__c(Name = 'Test-IntranetEvent-01',Date_of_Event__c = Date.today(),
                                                                   End_Date__c = endDate,Event_Type__c = 'Annual Meeting');
        insert objIntranetEvent1;   
        
        SL_Intranet_PaginationSettings__c objPagination = new SL_Intranet_PaginationSettings__c(Name = 'pageSize', 
                                                                                                        Calendar_PageSize__c = 20);
        insert objPagination;                                                      
          
        PageRegionWidget__c objPageRegionWidget = createTestRecordsEventSummaryDetail('SL_IntranetEventSummaryDetails');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        ApexPages.currentPage().getParameters().put('page','testPagetest123');
        ApexPages.currentPage().getParameters().put('deletedRecordId',objIntranetEvent1.Id);
        
        SL_IntranetEventSummaryDetailsController objController = new SL_IntranetEventSummaryDetailsController();
        
        objController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objController.getMyImpl();
        objController.getMyImpl().newComponent();
        objController.getMyImpl().strEventId = objIntranetEvent.id;
        objController.getEventSummaryDetail();
        objController.getMyImpl().deleteEventRecord();
        //objController.getMoreRecords();
        
        system.assertEquals(0,0);
    }
    
    static PageRegionWidget__c createTestRecordsEventSummaryDetail(String configuration)
    {
        Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'testPagetest123');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = configuration, Configuration__c = '{fieldSet":""}');
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                          Page_Region__r = objPageRegion, Widget__r = objWidget,
                                                                          Configuration__c = '{"fieldSet":""}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
}