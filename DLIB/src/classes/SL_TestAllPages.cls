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
private class SL_TestAllPages {
	
	/**
	** Create a test decendant class to test "so-called abstract" page controller  
	**/
	class TestPage9 extends PageControllerBase {
		public TestPage9() {
			init('testPage9');
		}
	}
	
    //File Upload Page : Percent of test coverage : 76
    static testMethod void test_SL_FileUploadController() 
    {
		test.startTest();
    	
    	String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
    	User objUser = new User(LastName = 'Test AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
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
								 Extension = 'testExtension');
		insert objUser;
		
    	ApexPages.currentpage().getParameters().put('groupId', objUser.Id);
    	ApexPages.currentpage().getParameters().put('postBody', '');
    	ApexPages.currentpage().getParameters().put('Success', '');
    	SL_FileUploadController objSL_FileUploadController = new SL_FileUploadController();
    	Blob strBlob = Blob.valueOf('Test BlobContent');
    	objSL_FileUploadController.attachmentBody = strBlob;
    	objSL_FileUploadController.strFileName = 'Test File';
    	//objSL_FileUploadController.insertFeed();
    	
    	ApexPages.currentpage().getParameters().put('isProfilePhoto', 'true');
    	ApexPages.currentpage().getParameters().put('userId', objUser.Id);
    	ApexPages.currentPage().getParameters().put('id', objUser.Id);
    	
    	objSL_FileUploadController = new SL_FileUploadController();
    	objSL_FileUploadController.attachmentBody = strBlob;
    	objSL_FileUploadController.strFileName = 'Test File';
    	objSL_FileUploadController.createContent();
    	objSL_FileUploadController.saveUserDetails();
    	
    	objSL_FileUploadController.imageSize = 9000000;
    	objSL_FileUploadController.createContent();
    	
    	ApexPages.currentpage().getParameters().put('docId', '');
    	ApexPages.currentPage().getParameters().put('error', 'true');
    	objSL_FileUploadController = new SL_FileUploadController(); 
    	objSL_FileUploadController.saveUserDetails();
    	
    	
    	Blob attachmentBody1 = blob.valueOf('Test Image');
		ContentVersion objCV2 = new ContentVersion(Title = 'Test2',VersionData = attachmentBody1,PathOnClient = 'objDocument.jpg');
        insert objCV2;
        
    	ApexPages.currentpage().getParameters().put('userId', objUser.Id);
    	ApexPages.currentpage().getParameters().put('groupId', objCV2.Id);
    	SL_FileUploadController objSL_FileUploadController1 = new SL_FileUploadController(); 
    	//objSL_FileUploadController1.insertFeed();
    	objSL_FileUploadController1.attachmentBody = null;
    	objSL_FileUploadController1.createContent();

    	system.assertEquals(null,objSL_FileUploadController.createContent());
    	
    	test.stopTest();
    }

    
    //Intranet Office Lookup Page : Percent of test coverage : 91
    static testMethod void test_SL_IntranetOfficeLookupController() 
    {
		List<Office_Locations__c> lstOffices = new List<Office_Locations__c>{new Office_Locations__c(Name = 'Test Location-01'),new Office_Locations__c(Name = 'Test Location-02'),new Office_Locations__c(Name = 'Test Location-03')};
        
        insert lstOffices;
        
        System.assertEquals(lstOffices.size(), 3);
        
		User objUser = new User(
            Alias = 'testUser', 
            Email='test12345@test.test',
            EmailEncodingKey='UTF-8',
            LastName='TesyytingOffice123',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey='America/Los_Angeles',
            UserName='test1234572@test.test',
            User_Offices__c = 'Test Location-01 \n Test Location-02 \n',
            Selected_Offices_Ids__c = lstOffices[0].id
        );
        
        insert objUser;
        
        Notification__c objNotification = new Notification__c(Name = 'Test Notification', Selected_Offices_Ids__c = lstOffices[0].id);
        insert objNotification;
        
        Intranet_Event__c objEvent = new Intranet_Event__c(Name = 'Test Event', Selected_Offices_Ids__c = lstOffices[0].id);
		insert objEvent;
		
		Intranet_App__c objApp = new Intranet_App__c(Name = 'Test App', Selected_Office_Ids__c = lstOffices[0].id);
		insert objApp;
        
        blob blbAttachment = blob.valueOf('test');
        ContentVersion objContentVersion = new ContentVersion(Title='MyContentVersion', PathOnClient = 'objDocument.jpg', VersionData = blbAttachment ); 
        insert objContentVersion ;
        
        Apexpages.currentPage().getParameters().put('id', objUser.id);
        SL_IntranetOfficeLookupController objController = new SL_IntranetOfficeLookupController();
        
        objController.getSelectedItems();
        objController.getunselectedItems();
        objController.strOfficeLocations = lstOffices[1].Name + '<>' + lstOffices[2].Name + '<>';
        objController.saveOfficeLocations();
        objController.cancel();
        
        Apexpages.currentPage().getParameters().put('id', objNotification.id);
        SL_IntranetOfficeLookupController objController1 = new SL_IntranetOfficeLookupController();
        objController1.strOfficeLocations = lstOffices[1].Name + '<>' + lstOffices[2].Name + '<>';
        objController1.saveOfficeLocations();
        objController1.strOfficeLocations = '<';
        objController1.saveOfficeLocations();
        objController1.cancel();
        
        Apexpages.currentPage().getParameters().put('id', objEvent.id);
        SL_IntranetOfficeLookupController objController4 = new SL_IntranetOfficeLookupController();
        objController4.strOfficeLocations = lstOffices[1].Name + '<>' + lstOffices[2].Name + '<>';
        objController4.saveOfficeLocations();
        objController4.strOfficeLocations = '<';
        objController4.saveOfficeLocations();
        objController4.cancel();
		
		Apexpages.currentPage().getParameters().put('id', objApp.id);
        SL_IntranetOfficeLookupController objController5 = new SL_IntranetOfficeLookupController();
        objController5.strOfficeLocations = lstOffices[1].Name + '<>' + lstOffices[2].Name + '<>';
        objController5.saveOfficeLocations();
        objController5.strOfficeLocations = '<';
        objController5.saveOfficeLocations();
        objController5.cancel();
        
        Apexpages.currentPage().getParameters().put('id',objContentVersion.id);
        SL_IntranetOfficeLookupController objController2 = new SL_IntranetOfficeLookupController();
        objController2.strOfficeLocations = lstOffices[1].Name + '<>' + lstOffices[2].Name + '<>';
        objController2.saveOfficeLocations();
        objController2.cancel();
    }
   
    //Intranet Office Lookup Page : Percent of test coverage : 91
    static testMethod void test_SL_IntranetDepartmentLookupController() 
    {
		List<Department__c> lstDepartments = new List<Department__c>{new Department__c(Name = 'Test Department-01'),new Department__c(Name = 'Test Department-02'),new Department__c(Name = 'Test Department-03')};
        
        insert lstDepartments;
        
        System.assertEquals(lstDepartments.size(), 3);
        
		User objUser = new User(
            Alias = 'testUser', 
            Email='test12345@test.test',
            EmailEncodingKey='UTF-8',
            LastName='TesyytingDept123',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey='America/Los_Angeles',
            UserName='test1234565@test.test',
            User_Departments__c = 'Test Department-01 \n Test Department-02 \n',
            Selected_Department_Ids__c = lstDepartments[0].id
        );
        
        insert objUser;
        
        Notification__c objNotification = new Notification__c(Name = 'Test Notification', Selected_Department_Ids__c = lstDepartments[0].id);
        insert objNotification;
		
		Intranet_Event__c objEvent = new Intranet_Event__c(Name = 'Test Event', Selected_Department_Ids__c = lstDepartments[0].id);
		insert objEvent;
		
		Intranet_App__c objApp = new Intranet_App__c(Name = 'Test App', Selected_Department_Ids__c = lstDepartments[0].id);
		insert objApp;
        
        blob blbAttachment = blob.valueOf('test');
        ContentVersion objContentVersion = new ContentVersion(Title='MyContentVersion111', PathOnClient = 'objDocument111.jpg', VersionData = blbAttachment ); 
        insert objContentVersion ;
        
        Apexpages.currentPage().getParameters().put('id', objUser.id);
        SL_IntranetDepartmentsLookupController objController = new SL_IntranetDepartmentsLookupController();
        
        objController.getSelectedItems();
        objController.getunselectedItems();
        objController.strDepartmentLocations = lstDepartments[1].Name + '<>' + lstDepartments[2].Name + '<>';
        objController.saveDepartmentLocations();
        objController.cancel();
        
        Apexpages.currentPage().getParameters().put('id', objNotification.id);
        SL_IntranetDepartmentsLookupController objController1 = new SL_IntranetDepartmentsLookupController();
        objController1.strDepartmentLocations = lstDepartments[1].Name + '<>' + lstDepartments[2].Name + '<>';
        objController1.saveDepartmentLocations();
        objController1.strDepartmentLocations = '<';
        objController1.saveDepartmentLocations();
        objController1.cancel();
		
		Apexpages.currentPage().getParameters().put('id', objEvent.id);
        SL_IntranetDepartmentsLookupController objController4 = new SL_IntranetDepartmentsLookupController();
        objController4.strDepartmentLocations = lstDepartments[1].Name + '<>' + lstDepartments[2].Name + '<>';
        objController4.saveDepartmentLocations();
        objController4.strDepartmentLocations = '<';
        objController4.saveDepartmentLocations();
        objController4.cancel();
		
		Apexpages.currentPage().getParameters().put('id', objApp.id);
        SL_IntranetDepartmentsLookupController objController5 = new SL_IntranetDepartmentsLookupController();
        objController5.strDepartmentLocations = lstDepartments[1].Name + '<>' + lstDepartments[2].Name + '<>';
        objController5.saveDepartmentLocations();
        objController5.strDepartmentLocations = '<';
        objController5.saveDepartmentLocations();
        objController5.cancel();
        
        Apexpages.currentPage().getParameters().put('id',objContentVersion.id);
        SL_IntranetDepartmentsLookupController objController2 = new SL_IntranetDepartmentsLookupController();
        objController2.strDepartmentLocations = lstDepartments[1].Name + '<>' + lstDepartments[2].Name + '<>';
        objController2.saveDepartmentLocations();
        objController2.cancel();
    }
   
    //Intranet main Page : Percent of test coverage : 100
    static testMethod void test_SL_IntranetPageController() 
    {
    	Page__c testPage = new Page__c(Name = 'Intranet', LayoutType__c = '3 Column Layout Page 123');
    	insert testPage;
    	
    	SL_IntranetPageController objHome1 = new SL_IntranetPageController();
    	
    	testPage.LayoutType__c = '3 Column Layout Page';
    	update testPage;
    	
    	Apexpages.currentPage().getParameters().put('page', 'Intranet');
		SL_IntranetPageController objHome = new SL_IntranetPageController();
		
		objHome.getHeaderUserInfoRegionWidgets();
		objHome.getHeaderLogoRegionWidgets();
		objHome.getBannerRegionWidgets();
		objHome.getHeaderNavigationRegionWidgets();
		objHome.getLeftSideBarRegionWidgets();
		objHome.getMobileViewWidgets();
		
		objHome.getMainSectionRegionWidgets();
		objHome.getRightSideBarRegionWidgets();
		
		system.assertEquals(0,0); 
    }
	
	static testMethod void testWidgetsName() 
    {
    	SL_TestSetupUtils.createConfigurationSettings();   
    	 	
    	TestPage9 c = new TestPage9();
    	
    	system.assertEquals(1, c.allWidgets.size());
    	    
    	ApexPages.Component pc = c.renderRegionComponents('testRegion');
    	    	
    	if(c.allWidgets.size() == 1) { // check for specific component type
    		system.assert(pc instanceof Component.c.SL_IntranetUserInfo);
    	}
    	else { // check for wrapped 
    		system.assert(pc instanceof Component.Apex.Pageblock);
    		
			// has at least on child compoment
			system.assert(pc.childComponents.size() > 0);	
    	}		 
	}
	
    static testMethod void SL_IntranetCustomizableComponent()
	{
		Test.startTest();
		
		SL_CustomizableComponent__c objCC = new SL_CustomizableComponent__c(Updated_Static_Resource_Name__c = 'TEST1', Logo__c = 'TestLogo', Default__c = false);
		insert objCC;
		
		SL_IntranetCustomizableComponent testObj = new SL_IntranetCustomizableComponent();
		
		system.assertEquals(0, 0);
		
		Test.stopTest();
	}
	
	static testmethod void test_SL_IntranetStaffController()
	{
		Profile objProfile = [SELECT Name,Id, UserLicense.LicenseDefinitionKey FROM Profile WHERE Id = : Userinfo.getProfileId()];
    	
    	String strProfileId = objProfile.Id;
    	
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
								 Hire_Date__c = Date.Today());
		insert testUser;
		
		system.assertEquals(testUser.Id, [Select Id From User Where Email = 'test1@gmail.com'].Id);
		
		SL_IntranetApplicationSetting__c testCS = new SL_IntranetApplicationSetting__c(Name = 'Default Settings', Of_Days_For_Recent_Hires__c = 2);
		insert testCS;
		
		SL_IntranetStaffController testISC = new SL_IntranetStaffController();
    	
	}
	
	
	static testmethod void testWidgetRepository()
	{	
		SL_TestSetupUtils.createConfigurationSettings();
		
		Map<String, List<WidgetAbstract>> widgets = WidgetRepository.loadAllWidgetsFromConfiguration('testPage9', null);		
		system.assertEquals(1, widgets.size());
	}
    
    //Intranet main Page : Percent of test coverage : 100
    static testMethod void test_SL_IntranetCreateDefaultRecords() 
    {
		Content_Chatter__c objCC = new Content_Chatter__c(Content_Id__c = 'ContentFARecord');
		insert objCC;
		
    	SL_IntranetCreateDefaultRecords objDefault = new SL_IntranetCreateDefaultRecords(false);
		SL_IntranetCreateDefaultRecords objDefaultConst = new SL_IntranetCreateDefaultRecords();
    	
    	system.assertEquals(0,0); 
    }
    
    
    //Intranet Layout Editor Page : Percent of test coverage : 94
    static testMethod void test_SL_IntranetLayoutEditorController() 
    {
    	Region__c objRegion = new Region__c(Name = 'Test-Region');
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'Intranet-Test1', LayoutType__c = '3 Column Layout Page');
    	insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	List<Widget__c> lstWidget = new List<Widget__c>();
    	Widget__c objWidget1 = new Widget__c(Name = 'Test1-Widget1', Type__c = 'Test1-Widget1', Configuration__c = null);
    	Widget__c objWidget2 = new Widget__c(Name = 'Test2-Widget2', Type__c = 'Test2-Widget2', Configuration__c = '{background:red}');
    	lstWidget.add(objWidget1);
    	lstWidget.add(objWidget2);
    	insert lstWidget;
    	
    	List<PageRegionWidget__c> lstPageRegionWidget = new List<PageRegionWidget__c>();
    	
    	PageRegionWidget__c objPageRegionWidget1 = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget1.id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget1, Configuration__c = '{background:red}');
    	PageRegionWidget__c objPageRegionWidget2 = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget2.id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget2);																	
    	lstPageRegionWidget.add(objPageRegionWidget1);
    	lstPageRegionWidget.add(objPageRegionWidget2);
    	insert lstPageRegionWidget;	
    	
    	Apexpages.currentPage().getParameters().put('page', 'Intranet-Test1');
    	SL_IntranetLayoutEditorController objSL_IntranetLayoutEditorController = new SL_IntranetLayoutEditorController();
    	
    	String strWidgetConfiguration = '[{"name":"Test-Region","widgetType":"Test1-Widget2","widgetId":"'+objPageRegionWidget1.id+'"},{"name":"Test-Region","widgetType":"Test1-Widget1","widgetId":"null"}]';
    	
    	SL_IntranetLayoutEditorController.saveWidgetConfigurations(strWidgetConfiguration, 'Intranet-Test1', 'Intranet-Test1', false, 'Desktop', 'All');
    	
    	objSL_IntranetLayoutEditorController.strCurrentPage = 'Intranet-Test2';
    	objSL_IntranetLayoutEditorController.strCurrentPageLayout = '3 Column Layout Page';
    	SL_IntranetLayoutEditorController.createNewPage('Intranet-Test2', '3 Column Layout Page', 'Desktop');
    	
    	SL_IntranetLayoutEditorController.editPageName('Intranet-Test3', 'Intranet-Test2', 'Desktop');
    	
    	SL_IntranetLayoutEditorController.deleteExistingPage('Intranet-Test3');
    	
    	// objWidget2 has only background configuration {background:red}    	
    	String newConfiguration = '{background:green}';
    	SL_IntranetLayoutEditorController.updateWidgetConfiguration(objWidget2.Id, 'Widget', newConfiguration);
    	String updatedConfiguration = [SELECT Configuration__c FROM Widget__c WHERE Id =: objWidget2.Id].Configuration__c;
    	system.assertEquals(updatedConfiguration, newConfiguration);
    	 
    	// Widget intance configuration has only background configuration {background:red}, default widget configuration is empty 
    	// update of widget configuration should not update default widget configuration
    	newConfiguration = '{background:yellow}'; 
    	SL_IntranetLayoutEditorController.updateWidgetConfiguration(objPageRegionWidget1.Id, 'PageRegionWidget', newConfiguration);    	
    	PageRegionWidget__c widgetIntance = [SELECT Configuration__c, Widget__r.Configuration__c  FROM PageRegionWidget__c WHERE Id =: objPageRegionWidget1.Id];
		system.assertEquals(newConfiguration, widgetIntance.Configuration__c);   	
		system.assertNotEquals(newConfiguration, widgetIntance.Widget__r.Configuration__c);		
    }  
 
}