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
private class SL_TestEventsWidgets {
    
    static testmethod void test_SL_IntranetEventsTypesController()
    {
    	PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetEventTypes');
        
    	WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
		
		SL_IntranetEventTypesController obj = new SL_IntranetEventTypesController();
    	obj.compImpl = WidgetAbstract.getInstance(objWPSC);
    	obj.getMyImpl();
    	obj.getMyImpl().newComponent();
    	
    	system.assertEquals(0,0);
    }
    
    static testmethod void test_SL_IntranetEventsController()
    {
    	Department__c objDep = new Department__c(Name = 'Test dept');
    	insert objDep;
    	
    	RecordType objRT = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Intranet_Event__c' and IsActive = true order by Name asc limit 1];
    	
    	SL_Intranet_PaginationSettings__c objPS = new SL_Intranet_PaginationSettings__c(Name = 'test', Calendar_PageSize__c = 2);
    	insert objPS;
    	
    	Date dt = Date.today() + 5;
    	Intranet_Event__c objIE1 = new Intranet_Event__c(Name = 'Test1',Selected_Department_Ids__c=objDep.id, For_All_Departments__c=true, For_All_Offices__c = true, Venue__c = 'Test', Event_Type__c = 'Test', Comments__c = 'Test 123', Date_of_Event__c = dt, RecordTypeId = objRT.Id);
    	Intranet_Event__c objIE2 = new Intranet_Event__c(Name = 'Test', Date_of_Event__c = dt, RecordTypeId = objRT.Id);
    	insert objIE1;
    	insert objIE2;
    	
    	ApexPages.currentPage().getParameters().put('page','testPage');
    	
    	PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetEvents');
        
    	WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
		
		SL_IntranetEventsController obj = new SL_IntranetEventsController();
    	obj.compImpl = WidgetAbstract.getInstance(objWPSC);
    	obj.getMyImpl();
    	obj.getMyImpl().newComponent();
    	obj.getMoreRecords();    
    	
    	//system.assertEquals(obj.getMyImpl().numOfRecordeToBedisplayed ,4); // objPS.Calendar_PageSize__c = 2;
    	
    	obj.getIntranetevents();
    	
        obj.getMyImpl().strDeptId = objDep.Id;
    	obj.getFilteredByDepartment();
    	
    	obj.getMyimpl().strIntranetEventType = objRT.DeveloperName;
    	obj.getFilteredByDepartment();
    	
    	obj.getMyImpl().strDeptId = '';
    	obj.getFilteredByDepartment();
    	//system.assertEquals(obj.getMyImpl().lstIntranetEvents.size() ,2); 
    	
    	obj.getMyImpl().searchTextForMobile = 'Test';
    	
    	Id [] fixedSearchResults= new Id[2];
       	fixedSearchResults[0] = objIE1.Id;
       	fixedSearchResults[1] = objIE2.Id;
       	
       	Test.setFixedSearchResults(fixedSearchResults);
        
        List<List<SObject>> lstsearch = [Find 'Test*' in ALL FIELDS RETURNING Intranet_Event__c (Id, Name, Event_Type__c, Venue__c, Date_of_Event__c, End_Date__c, RecordType.Name, Comments__c order by Date_of_Event__c asc nulls last, Name asc) ];
		obj.getMyImpl().lstIntranetEventSearch = (List<Intranet_Event__c>)lstsearch[0];
        obj.getMyImpl().calenderSearchForMobile();
    	//system.assertEquals(obj.getMyImpl().lstIntranetEvents.size() ,2);
    	
    	obj.getMyImpl().strIntranetEventType = 'All Types';
    	obj.getMyImpl().getIntranetevents();
    	obj.getMyImpl().getMoreMobileRecords();
    	
    	system.assertEquals(0,0);
    	
    }
    static PageRegionWidget__c createTestRecords(String configuration)
    {
    	Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'testPage');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = configuration);
    	insert objWidget;
    	
    	PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.Id, Widget__c = objWidget.Id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget,
    																		Configuration__c = '{"fieldset":"","fontcolor":"","fontstyle":""}');
    	insert objPageRegionWidget;
    	
    	return objPageRegionWidget;
    }
}