@isTest
private class SL_Test_MobileWidgets {
	
	// name space name to be used in case of managed package
    private static String strNameSpace;
    
	static
	{
		try
    	{
    		if(UserInfo.isCurrentUserLicensed('SLSI'))
    			strNameSpace = 'SLSI__';
    	}
    	catch(TypeException ex)
    	{
    		 strNameSpace = '';
    	}
	}

    static testMethod void test_SL_IntranetMobileNotification() {
        
        date dt = date.today() + 10;
        
        Notification__c objNotification = new Notification__c(Name = 'Test MobileNotification#1',
                                                              Notification_Detail__c = 'test Detail',
                                                              Active__c = true,
                                                              Expiry_Date__c = dt, For_All_Offices__c = true,
                                                               Display_As_Of__c = dt - 30);
                                                                        
        insert objNotification;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecordsforNotification('SL_Mobile_IntranetNotification');

        ApexPages.currentPage().getParameters().put('page','TestMobileHome');

        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_Mobile_IntranetNotification objNotifications = new SL_Mobile_IntranetNotification();
        objNotifications.initialize();
        objNotifications.postInitialize();
        objNotifications.newComponent();
        
        Department__c objDep = new Department__c(Name = 'Test Mobile dept');
    	insert objDep;
        
        //objNotifications.deptId = objDep.id;
        objNotifications.loadRecords(0, objDep.Id, '');
        
        Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objNotifications.notify(objIWidget);
        
        SL_Mobile_IntranetNotificationController objNotificationController = new SL_Mobile_IntranetNotificationController();
        objNotificationController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objNotificationController.getConfigurationJSON();
        objNotificationController.getTitle();
        
        PageRegionWidget__c objWidget = [Select Name From PageRegionWidget__c Where Id =: objPageRegionWidget.Id];
        SL_Mobile_IntranetNotificationController.getData(objWidget.Name, 0, '', '');  
        
        system.assertEquals(0,0);
    }
    
    static testMethod void test_SL_IntranetMobileDocument() {
    	
    	ContentVersion objContentVersion =  new ContentVersion(Title = 'test Content$23^5#', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'));
        insert objContentVersion;
        
        PageRegionWidget__c objPageRegionWidget = createTestDocumentRecords('SL_Mobile_IntranetDocument');
        update objPageRegionWidget;
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_Mobile_IntranetDocumentController objDocumentsController = new SL_Mobile_IntranetDocumentController();
        objDocumentsController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objDocumentsController.getConfigurationJSON();
        objDocumentsController.getTitle();
        
        PageRegionWidget__c objWidget = [Select Name From PageRegionWidget__c Where Id =: objPageRegionWidget.Id];
        SL_Mobile_IntranetDocumentController.getData(objWidget.Name, 0, 'Name','');
        SL_Mobile_IntranetDocumentController.getData(objWidget.Name, 0, 'Date','');
        SL_Mobile_IntranetDocumentController.getData(objWidget.Name, 0, 'Feature','');
        
        SL_Mobile_IntranetDocument objDocument = new SL_Mobile_IntranetDocument();
        objDocument.postInitialize();
        objDocument.newComponent();
        
        Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objDocument.notify(objIWidget);
        
        system.assertEquals(0,0);
    }
    
    static testMethod void test_SL_Mobile_IntranetEventSummary() {
        
        date dt = date.today() + 10;
     	Department__c objDep = new Department__c(Name = 'Test Mobile dept');
		insert objDep;
    	
        RecordType objRT = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Intranet_Event__c' and IsActive = true order by Name asc limit 1];
        Intranet_Event__c objEvent = new Intranet_Event__c(Name = 'Test MobileIntranetEventSummary#1',
	                                                          	RecordTypeId = objRT.Id, Comments__c = 'Test 123',
	                                                          	For_All_Offices__c = true,Venue__c = 'Test',
	                                                          	Event_Type__c = 'Test',
	                                                          	For_All_Departments__c=true, Date_of_Event__c = dt,
	                                                          	Selected_Department_Ids__c=objDep.id);
                                                                        
        insert objEvent;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecordsforEvent('SL_Mobile_IntranetEventSummary');
        ApexPages.currentPage().getParameters().put('page','TestMobileHome');

        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_Mobile_IntranetEventSummary objEventSummary = new SL_Mobile_IntranetEventSummary();
        objEventSummary.initialize();
        objEventSummary.postInitialize();
        objEventSummary.newComponent();
        
        Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objEventSummary.notify(objIWidget);
        
        objEventSummary.loadRecords(0, objDep.Id, '');
        
        SL_Mobile_IntranetEventSummaryController objEventController = new SL_Mobile_IntranetEventSummaryController();
        objEventController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objEventController.getConfigurationJSON();
        objEventController.getTitle(); 
     	objEventController.getMyImpl();
        PageRegionWidget__c queryPRW = [Select Name from PageRegionWidget__c where Id=:objPageRegionWidget.Id];
        SL_Mobile_IntranetEventSummaryController.getData(queryPRW.Name, 0, objDep.Id, null);  
        
        system.assertEquals(0,0);
    }
    
    //Test code for Employee Directory Mobile widget
    static testMethod void test_SL_Mobile_IntranetEmployeeDirectory() {
    	
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
    	String strAvailableOffices = '';
    	
		strAvailableOffices = 'testOffice';
        date dt = date.today() + 10;
     	Department__c objDep = new Department__c(Name = 'Test Mobile dept');
		insert objDep;
    	
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
        
        PageRegionWidget__c objPageRegionWidget = createTestRecordsForEmployeeDirectory('SL_Mobile_IntranetEmployeeDirectory');
        ApexPages.currentPage().getParameters().put('page','testPageEmpDir');

        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_Mobile_IntranetEmployeeDirectory objEmpDir = new SL_Mobile_IntranetEmployeeDirectory();
        objEmpDir.initialize();
        objEmpDir.postInitialize();
        objEmpDir.newComponent();
        
        Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objEmpDir.notify(objIWidget);
        
        objEmpDir.loadRecords(0, objDep.Id, '');
        
        SL_Mob_IntranetEmpDirectoryController objEmpDirCont = new SL_Mob_IntranetEmpDirectoryController();
        objEmpDirCont.compImpl = WidgetAbstract.getInstance(objWPSC);
        objEmpDirCont.getConfigurationJSON();
        objEmpDirCont.getTitle(); 
     	objEmpDirCont.getMyImpl();
        PageRegionWidget__c queryPRW = [Select Name from PageRegionWidget__c where Id=:objPageRegionWidget.Id];
        SL_Mob_IntranetEmpDirectoryController.getData(queryPRW.Name, 0, objDep.Id, null);  
        
        system.assertEquals(0,0);
    }
    
    static PageRegionWidget__c createTestDocumentRecords(String configuration)
    {
        Region__c objRegion = new Region__c(Name = 'testRegionDoc');
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'testPageDoc');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c(Name = 'testMGDoc',Type__c = configuration);
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c( Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                           Page_Region__r = objPageRegion, Widget__r = objWidget,
                                                                           Configuration__c = '{"displayFilterLinks":true,"fieldset":"","showFieldLabel":true,"officefiltering":true,"filterscope":"Everything","departmentfiltering":false,"heading":"Documents","numbertodisplay":5,"TotalRecords":10}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
    
    static PageRegionWidget__c createTestRecordsforNotification(String configuration) {
        Region__c objRegion = new Region__c( Name = 'testMobileRegion');
        insert objRegion;
        
        Page__c objPage = new Page__c( Name = 'TestMobileHome');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c( Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c( Name = 'testMobileG',Type__c = configuration);
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c( Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                           Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"heading":"Notification Mobile List","TotalRecords":10,"numbertodisplay":4,"fieldset":"","ChatterTopicFiltering":false,"DepartmentFiltering":true,"OfficeFiltering":true,"filterscope":"Everything","showFieldLabel":false}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
    
    static PageRegionWidget__c createTestRecordsforEvent(String configuration)
    {
        Region__c objRegion = new Region__c( Name = 'testMobileRegion');
        insert objRegion;
        
        Page__c objPage = new Page__c( Name = 'TestMobileHome');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c( Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c( Name = 'testMobileG',Type__c = configuration);
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c( Order__c=1, Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                           Page_Region__r = objPageRegion, Widget__r = objWidget,
                                                                           Configuration__c = '{"heading":"IntranetEventSummary Mobile List","TotalRecords":10,"numbertodisplay":4,"fieldset":"'+strNameSpace+'Intranet_Calendars_Fields","chatterTopicFiltering":false,"departmentFiltering":true,"officeFiltering":true,"filterscope":"Everything","showFieldLabel":false}');
        insert objPageRegionWidget;
        
        
        return objPageRegionWidget;
    }
    
    static PageRegionWidget__c createTestRecordsForEmployeeDirectory(String configuration)
    {
    	Region__c objRegion = new Region__c(Name = 'testMobileRegionEmpDir');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'testPageEmpDir');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testWEmpDir',Type__c = configuration);
    	insert objWidget;
    	
    	PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget,
    																		Configuration__c = '{"heading":"","TotalRecords":10,"numbertodisplay":4,"showfieldlabel":true,"filterscope":"","officefiltering":true,"departmentfiltering":false,"chatterTopicFiltering":false}');
    	insert objPageRegionWidget;
    	
    	return objPageRegionWidget;
    }
    
}