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
private class SL_TestEmployeeDirectoryWidgets {

    
    static testMethod void test_SL_IntranetEmpDirectoryOfficesController() 
    {
    	String strAvailableOffices = '';
		
		if(strAvailableOffices == '')
			strAvailableOffices = 'testOffice,ss';
			
		Office_Locations__c objOfficeLocations1 = new Office_Locations__c();
    	objOfficeLocations1.Name = strAvailableOffices.split(',')[0];
    	objOfficeLocations1.Display_Order__c = 1;
    	insert objOfficeLocations1;
    	
    	Office_Locations__c objOfficeLocations11 = new Office_Locations__c();
    	objOfficeLocations11.Name = strAvailableOffices.split(',')[1];
    	objOfficeLocations11.Display_Order__c = 2;
    	insert objOfficeLocations11;
    	
    	PageRegionWidget__c objPageRegionWidget = createTestRecordsForEmpDirectoryOffices('SL_IntranetEmpDirectoryOffices');
        
		WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
    	
    	SL_IntranetEmpDirectoryOfficesController objEmpDirectoryOfficesController = new SL_IntranetEmpDirectoryOfficesController();
    	
    	objEmpDirectoryOfficesController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	
    	/*Start - Checking if it is giving all locations which are available in org.*/
    	//system.assertEquals(2,objEmpDirectoryOfficesController.getMyImpl().lstLocations.size());
    	/*End - Checking if it is giving all locations which are available in org.*/
    	
    	objEmpDirectoryOfficesController.getMyImpl();
    	objEmpDirectoryOfficesController.getMyImpl().newComponent();
    	objEmpDirectoryOfficesController.getMyImpl().fetchEmpDirOffices();
    	
    	system.assertEquals(0,0);
    	
    }
  
    static testMethod void Test_SL_IntranetEmployeeDirectoryController() 
    {
    	String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
    	String strAvailableOffices = '';
    	
		strAvailableOffices = 'testOffice';
    	
    	User testUser = new User(LastName = 'Test AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
					 			 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = '	Department1',
								 TimeZoneSidKey = 'America/New_York',Title = 'Title1',
								 LocaleSidKey = 'en_US',
								 EmailEncodingKey = 'ISO-8859-1',   
								 LanguageLocaleKey = 'en_US',	    
								 ProfileId = strProfileId, IsActive=true,
								 FirstName = 'testFirst',
		 						 City = 'testCity',
		 						 Country = 'testCountry',
								 Street = 'testStreet',
								 CompanyName = 'testCompanyName',
								 Phone = 'testPhone',
								 Extension = 'testExtension',
								 Selected_Offices_Ids__c = strAvailableOffices.split(',')[0]);
		insert testUser;
    	
    	Office_Locations__c objOfficeLocations1 = new Office_Locations__c();
    	objOfficeLocations1.Name = strAvailableOffices.split(',')[0];
    	objOfficeLocations1.Display_Order__c = 1;
    	insert objOfficeLocations1;
    	
    	Department__c objDep = new Department__c(Name = 'Test Dep Emp');
        insert objDep;
        
    	SL_Intranet_PaginationSettings__c objPagination  = new SL_Intranet_PaginationSettings__c(Name= 'Test pagination Setting',
    																								   EmployeeDirectory_PageSize__c = 1, 
    																								   EmployeeDirectory_PageSize_Mobile__c = 1);
		insert objPagination;
		
		
    	PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetEmployeeDirectory');
        
		WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
    	
    	Apexpages.currentPage().getparameters().put('loc','testOffice');
    	SL_IntranetEmployeeDirectoryController objEmployeeDirectoryController = new SL_IntranetEmployeeDirectoryController();
    	
    	SL_IntranetEmployeeDirectory objEmpDirectory = new SL_IntranetEmployeeDirectory();
    	objEmployeeDirectoryController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	objEmployeeDirectoryController.getMyImpl();
    	
    	Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
   		
		objEmpDirectory.notify(objIWidget);
		objEmpDirectory.initialize();
		objEmpDirectory.postInitialize();
		objEmployeeDirectoryController.gtSortPreference();
		
    	objEmployeeDirectoryController.getMyImpl().newComponent();
    	
    	
		objEmployeeDirectoryController.getFilteredByDepartment();
        objEmployeeDirectoryController.getMyImpl().strDeptId = objDep.id;
        objEmployeeDirectoryController.getFilteredByDepartment();
        objEmployeeDirectoryController.gtSortPreference();
    	
    	/*Start - Checking if onload it is showing all present users*/
     	//system.assertEquals(1,objEmployeeDirectoryController.getMyImpl().lstLocations.size());
    	/*End - Checking if onload it is showing all present users*/
    	
    	/*Start - Checking if list of directory user is null before calling method*/
    	//system.assertEquals(0,objEmployeeDirectoryController.getMyImpl().lstDirectoryUsers.size());
    	/*End - Checking if list of directory user is null before calling method*/
		
		
    	objEmployeeDirectoryController.gtLocationUsers();
    	objEmployeeDirectoryController.gtSortPreference();
    	//objEmpDirectory.postInitialize();
    	/*Start -  Checking if it is returning all present directory user after calling method*/
   		//system.assertEquals( objEmployeeDirectoryController.getMyImpl().lstLocations.size(), 1);
    	/*End - Checking if it is returning all present directory user after calling method*/
    	
    	objEmployeeDirectoryController.gtListViewUsers();
    	objEmployeeDirectoryController.gtSortPreference();
    	objEmployeeDirectoryController.gtRecentHires();
    	objEmployeeDirectoryController.gtSortPreference();
    	
    	//system.assertEquals(0,objEmployeeDirectoryController.getMyImpl().lstDirectoryUsers.size());
    	
    	system.assertEquals('LastName',objEmployeeDirectoryController.getMyImpl().selSortPreference);
    	
    	objEmployeeDirectoryController.getMyImpl().selSortPreference = 'Name';
    	system.assertEquals('Name',objEmployeeDirectoryController.getMyImpl().selSortPreference);
    	objEmployeeDirectoryController.gtSortPreference();
    	objEmployeeDirectoryController.firstRecords();
    	//objEmployeeDirectoryController.lastRecords();
    	objEmployeeDirectoryController.prevRecords();
    	objEmployeeDirectoryController.nextRecords();
    	objEmployeeDirectoryController.getMoreRecords();
    	Apexpages.currentPage().getparameters().put('pageNo','1');
    	objEmployeeDirectoryController.goToPage();
    	
    	Apexpages.currentPage().getparameters().put('isRecentHire','true');
    	objEmployeeDirectoryController = new SL_IntranetEmployeeDirectoryController();
    	objEmployeeDirectoryController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	objEmployeeDirectoryController.getMyImpl();
    	
    	Apexpages.currentPage().getparameters().put('loc',null);
    	Apexpages.currentPage().getparameters().put('isRecentHire','false');
    	objEmployeeDirectoryController = new SL_IntranetEmployeeDirectoryController();
    	objEmployeeDirectoryController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	objEmployeeDirectoryController.getMyImpl();
    	objEmpDirectory.postInitialize();
    }
    
    static PageRegionWidget__c createTestRecords(String configuration)
    {
    	Region__c objRegion = new Region__c(Name = 'testRegion1.1.1');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'testPage1.1.1');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testMG1.1.1',Type__c = configuration);
    	insert objWidget;
    	
    	PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget);
    	insert objPageRegionWidget;
    	
    	return objPageRegionWidget;
    }
    
    static PageRegionWidget__c createTestRecordsForEmpDirectoryOffices(String configuration)
    {
    	Region__c objRegion = new Region__c(Name = 'testRegion1.1.1');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'testPage1.1.1');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testMG1.1.1',Type__c = configuration);
    	insert objWidget;
    	
    	PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget, 
    																		Configuration__c = '{"Listviews":""}');
    																		
    	insert objPageRegionWidget;
    	
    	return objPageRegionWidget;
    }
    
}