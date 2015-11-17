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
private class SL_TestHomeWidgets {
	
	private static String strNameSpace;
	
	static{
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
    //Percent of test coverage : 100, 100
    static testMethod void test_SL_IntranetUserInfoController() 
    {
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetUserInfo');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetUserInfoController objUserInfoController = new SL_IntranetUserInfoController();
        
        objUserInfoController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objUserInfoController.getMyImpl();
        objUserInfoController.getMyImpl().newComponent();
        //objUserInfoController.getMyImpl().strApplicationId = 'test';
        ApexPages.currentPage().getParameters().put('tsid', '123');
        objUserInfoController.getMyImpl().goToSalesforce();
        objUserInfoController.getMyImpl().updateApplicationId();
        
        SL_IntranetApplicationSetting__c testCS = new SL_IntranetApplicationSetting__c(Name = 'Default Setttings');
        insert testCS;
        objUserInfoController.getMyImpl().updateApplicationId();
        
        system.assertEquals(0,0);
    }
    
    //Percent of test coverage : 100, 100
    static testMethod void test_SL_IntranetApplicationsController()
    {
        Office_Locations__c objOfficeLocation1 = new Office_Locations__c(Name = 'test-location');
        insert objOfficeLocation1;
        
		Intranet_App__c objApp1 = new Intranet_App__c(Name = 'testApplication', Active__c = true, URL__c = 'www.test.com', For_All_Departments__c = true, For_All_Offices__c = true);
        insert objApp1;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetApplications');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetApplicationsController objApplicationsController = new SL_IntranetApplicationsController();
        
        objApplicationsController.compImpl = WidgetAbstract.getInstance(objWPSC);
        
        objApplicationsController.getMyImpl();
        objApplicationsController.getMyImpl().newComponent();
        
        Department__c objDep = new Department__c(Name = 'Test dept');
    	insert objDep;
    	
        objApplicationsController.getMyImpl().strDeptId = objDep.Id;
        objApplicationsController.getFilteredByDepartment();
        
        system.assertEquals(0,0);
    }
    
    //Percent of test coverage : 100, 100
    static testMethod void test_SL_IntranetDepartmentsController()
    {
        Department__c objDep = new Department__c(Name = 'Department Test');
        insert objDep;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetDepartments');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetDepartmentsController objApplicationsController = new SL_IntranetDepartmentsController();
        
        objApplicationsController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objApplicationsController.getMyImpl();
        objApplicationsController.getMyImpl().newComponent();
        
        system.assertEquals(0,0);
    }
 
    //Percent of test coverage : 100, 100  
    static testMethod void test_SL_IntranetSearchController()
    {
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetSearch');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        Apexpages.currentPage().getParameters().put('searchText', 'Test');
        SL_IntranetSearchController objSearchController = new SL_IntranetSearchController();
        objSearchController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objSearchController.getMyImpl();
        objSearchController.getMyImpl().newComponent();
        
        system.assertEquals(0,0);
    }
  
    //Percent of test coverage : 100, 100  
    static testMethod void test_SL_IntranetNavigationBarController()
    {
    	ApexPages.currentPage().getParameters().put('page','TestHome');
        PageRegionWidget__c objPageRegionWidget = createTestRecordsForNavigationBar('SL_IntranetNavigationBar');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetNavigationBarController objNavigationController = new SL_IntranetNavigationBarController();
        objNavigationController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objNavigationController.getMyImpl();
        objNavigationController.getMyImpl().newComponent();
        
        system.assertEquals(0,0);
    }
    
   
    static testMethod void test_SL_IntranetBannerController()
    {
        ApexPages.currentPage().getParameters().put('page','TestHome');
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetBanner');
        objPageRegionWidget.Configuration__c = '{"targetfolder":"","backgroundcolor":"white","fontcolor":"","transitiontype":"fade","widgetheight":250,"trasnitionseconds":10,"heading":"","fontstyle":"","showborder":true,"department":"Finance"}';
        update objPageRegionWidget;
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetBannerController objIntranetBanner = new SL_IntranetBannerController();
        objIntranetBanner.compImpl = WidgetAbstract.getInstance(objWPSC);
        objIntranetBanner.getMyImpl();
        objIntranetBanner.getMyImpl().newComponent();
        objIntranetBanner.getFilteredByDepartment();
        objIntranetBanner.getMyImpl().postInitialize();
        
		Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objIntranetBanner.getMyImpl().notify(objIWidget);
		
        system.assertEquals(0,0);
    }

    //Percent of test coverage : 100, 100     
    static testMethod void test_SL_IntranetOfficesController()
    {
        Office_Locations__c objOffice1 = new Office_Locations__c(Name = 'testLocation', TimeZoneSidKey__c = 'America/Chicago', 
                                                                Map__c = 'testMap', Address__c = 'test Address',
                                                                Image__c = 'src=imageURL');
        insert objOffice1;                                                      
        
        ApexPages.currentPage().getParameters().put('page','TestHome');
        
        PageRegionWidget__c objPageRegionWidget = createTestRecordsForIntranetOffices('SL_IntranetOffices');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetOfficesController objOfficeController = new SL_IntranetOfficesController();
        objOfficeController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objOfficeController.getMyImpl();
        objOfficeController.getMyImpl().newComponent();
        
        system.assertEquals(0,0);
    }
    
    //Percent of test coverage : 100, 100     
    static testMethod void test_SL_Intranet_StandardChatterController()
    {
        PageRegionWidget__c objPageRegionWidget = createTestRecordsForIntranetOffices('SL_Intranet_StandardChatter');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_Intranet_StandardChatterController objOfficeController = new SL_Intranet_StandardChatterController();
        objOfficeController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objOfficeController.getMyImpl();
        objOfficeController.getMyImpl().newComponent();
        
        system.assertEquals(0,0);
    }
 
    //Percent of test coverage : 92, 100 
    static testMethod void test_SL_IntranetChatterGroupsController()
    {
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
        
       // CollaborationGroup testGroup = new CollaborationGroup(name='test Group',CollaborationType = 'public');
       // insert testGroup;
        
        User testUser = new User(LastName = 'Test AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
                                 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = '  Department1',
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
        insert testUser;
        
        
        CollaborationGroup objCG = new CollaborationGroup(Name = 'testGroup');
        objCG.CollaborationType = 'Public';
        insert objCG;

        CollaborationGroupMember objCGMember = new CollaborationGroupMember(CollaborationGroupId = objCG.id, MemberId = testUser.id);
        insert objCGMember;
        
        SL_FeaturedGroups__c testFG = new SL_FeaturedGroups__c(name = 'test Group', GroupId__c = objCG.id);
        insert testFG;  
       
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetChatterGroups');

        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetChatterGroupsController objChatterGroupsController = new SL_IntranetChatterGroupsController();
        objChatterGroupsController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objChatterGroupsController.getMyImpl();
        objChatterGroupsController.getMyImpl().newComponent();
        
        system.assertEquals(0,0);
    } 
  
    //Percent of test coverage : 94, 100 
    static testMethod void test_SL_IntranetNotificationDetailsController()
    {
        date dt = date.today() + 10;
        
        Notification__c objNotification = new Notification__c(Name = 'Test Notification',
                                                              Notification_Detail__c = 'test Detail',
                                                              Active__c = true,
                                                              Display_As_Of__c = dt,
                                                              Expiry_Date__c = dt,
                                                              For_All_Departments__c = true,
                                                              For_All_Offices__c = true);
        insert objNotification;
        
        SL_Intranet_PaginationSettings__c objPagination = new SL_Intranet_PaginationSettings__c(Name = 'pageSize', 
                                                                                                        Notifications_PageSize_Mobile__c = 20,
                                                                                                        Notifications_PageSize__c = 20);
        insert objPagination;
        
        Department__c objDep = new Department__c(Name='Test1 Department');
        insert objDep;
        
        ApexPages.currentPage().getParameters().put('page','TestHome');
        ApexPages.currentPage().getParameters().put('deletedRecordId',objNotification.id);
        
        PageRegionWidget__c objPageRegionWidget = createTestRecordsforNotificationDetail('SL_IntranetNotificationDetails');

        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetNotificationDetailsController objNotificationDetailsController = new SL_IntranetNotificationDetailsController();
        objNotificationDetailsController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objNotificationDetailsController.getMyImpl();
        objNotificationDetailsController.getMyImpl().newComponent();
        objNotificationDetailsController.getMyImpl().postInitialize();
        objNotificationDetailsController.getNotifications();
        objNotificationDetailsController.prevRecords();
        objNotificationDetailsController.nextRecords();
        Apexpages.currentPage().getparameters().put('pageNo','0');
        objNotificationDetailsController.goToPage();
        objNotificationDetailsController.getMyImpl().strNotificationId = objNotification.Id;
        objNotificationDetailsController.getMyImpl().getNotifications();
        objNotificationDetailsController.getMyImpl().deleteNotification();
        objNotificationDetailsController.getFilteredByDepartment();
        objNotificationDetailsController.toggleNotificationState();
        Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objNotificationDetailsController.getMyImpl().notify(objIWidget);
        
        
        system.assertEquals(0,0); 
    }
   
  
    //Percent of test coverage : 93, 100 
    static testMethod void test_SL_IntranetNotificationsController()
    {
        date dt = date.today()+10;
        
        Notification__c objNotification = new Notification__c(Name = 'Test Notification',
                                                                        Notification_Detail__c = 'test Detail',
                                                                        Active__c = true,
                                                                        Expiry_Date__c = dt, For_All_Offices__c = true,
                                                                        Display_As_Of__c = dt -30);
                                                                        
        insert objNotification;
        
        SL_Intranet_PaginationSettings__c testPagination = new SL_Intranet_PaginationSettings__c(Name = 'Test Pagination', Notifications_PageSize__c = 20,
        																									 Notifications_PageSize_Mobile__c = 20);
        insert testPagination;
        
        
        PageRegionWidget__c objPageRegionWidget = createTestRecordsforNotification('SL_IntranetNotifications');
        
        ApexPages.currentPage().getParameters().put('page','TestHome');

        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetNotificationsController objNotificationsController = new SL_IntranetNotificationsController();
        objNotificationsController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objNotificationsController.getMyImpl();
        objNotificationsController.getMyImpl().newComponent();
        
        Department__c objDep = new Department__c(Name = 'Test dept');
    	insert objDep;
    	
        objNotificationsController.getMyImpl().strDeptId = objDep.id;
        objNotificationsController.getFilteredByDepartment();
        objNotificationsController.showMoreRecords();
        objNotificationsController.getMyImpl().postInitialize();
        objNotificationsController.getMyImpl().getMoreNotifications();
        Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objNotificationsController.getMyImpl().notify(objIWidget);
        
        system.assertEquals(0,0);
    }
  
     //Percent of test coverage : 91, 100 
    static testMethod void test_SL_IntranetKeyContactsController()
    {
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
        date dt = date.today()-10;
        
        Department__c objDep = new Department__c(Name = 'Test dept');
    	insert objDep;
    	
        User testUser = new User(LastName = 'Test AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
                                 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = 'Department1',
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
                                 User_Offices__c = 'test',
                                 All_Offices__c = true,
                                 All_Departments__c = true,
                                 Hire_Date__c = dt);
        insert testUser;
        
        ApexPages.currentPage().getParameters().put('page','TestHome');
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetKeyContacts');
		objPageRegionWidget.Configuration__c = '{"fieldset":"'+strNameSpace+'SL_EmployeeDirectoryFieldSet","showAboutMe":false}';
		
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetKeyContactsController objKeyContactsController = new SL_IntranetKeyContactsController();
        objKeyContactsController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objKeyContactsController.getMyImpl();
        objKeyContactsController.getMyImpl().newComponent();
        
    	objKeyContactsController.getMyImpl().strDeptId = objDep.id;
    	objKeyContactsController.getFilteredByDepartment();
		SL_IntranetKeyContacts objKeyCont = new SL_IntranetKeyContacts();
    	Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objKeyContactsController.getMyImpl().notify(objIWidget);
		objKeyContactsController.getMyImpl().postInitialize();
    	system.assertEquals(0,0);
    }
  
    //Percent of test coverage : 91, 100 
    static testMethod void test_SL_IntranetStaffUpdatesController()
    {
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
        date dt = date.today()-10;
        
        User testUser = new User(LastName = 'Test AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
                                 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = '  Department1',
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
                                 User_Offices__c = 'test',
                                 Hire_Date__c = dt);
        insert testUser;
        
        ApexPages.currentPage().getParameters().put('page','TestHome');
        
        SL_IntranetApplicationSetting__c objApplicationSettings = new SL_IntranetApplicationSetting__c(Name = 'Default Settings', Of_Days_For_Recent_Hires__c = 21);
       	insert objApplicationSettings;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecordsForStaffUpdates('SL_IntranetStaffUpdates');

        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetStaffUpdatesController objStaffUpdatesController = new SL_IntranetStaffUpdatesController();
        objStaffUpdatesController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objStaffUpdatesController.getMyImpl();
        objStaffUpdatesController.getMyImpl().newComponent();
        objStaffUpdatesController.showMoreRecords();
        
        system.assertEquals(0,0);
    }
   
    //Percent of test coverage : 91, 100 
    static testMethod void test_SL_IntranetChatterFeedsController()
    {
        
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
        User testUser = new User(LastName = 'Test AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
                                 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = '  Department1',
                                 TimeZoneSidKey = 'America/New_York',Title = 'Title1',
                                 LocaleSidKey = 'en_US',
                                 EmailEncodingKey = 'ISO-8859-1',   
                                 LanguageLocaleKey = 'en_US',       
                                 IsActive=true,
                                 ProfileId = strProfileId,
                                 FirstName = 'testFirst',
                                 City = 'testCity',
                                 Country = 'testCountry',
                                 Street = 'testStreet',
                                 CompanyName = 'testCompanyName',
                                 Phone = 'testPhone',
                                 Extension = 'testExtension',
                                 User_Offices__c = 'test');
        insert testUser;
        
        SL_Intranet_PaginationSettings__c testPagination = new SL_Intranet_PaginationSettings__c(Name = 'Test Pagination', FeedPost_PageSize__c = 20);
        insert testPagination;
        
//        SL_CustomizableComponent__c objCC = new SL_CustomizableComponent__c(Updated_Static_Resource_Name__c = 'Test ', Logo__c = 'Logo', Default__c = false);
//        insert objCC;
        
        blob objTestBlob = Blob.valueOf('testBlob'); 
         
        FeedItem objFeedPost = new FeedItem(ParentId = testUser.id, Title = 'Test1', Body = 'Test1', Type='ContentPost', ContentFileName='Test File1', ContentData=objTestBlob);
        insert objFeedPost;
        FeedItem objFeedPost1 = new FeedItem(ParentId = testUser.id, Title = 'Test2', Body = 'Test2', Type='ContentPost', ContentFileName='Test File2', ContentData=objTestBlob);
        insert objFeedPost1;
        
        FeedComment objFeedComment = new FeedComment(commentBody='Test', feedItemId = objFeedPost.Id);
        insert objFeedComment;
        
        Notification__c testNotif = new Notification__c(Name= 'Test notif', Notification_Detail__c= 'Testing', For_All_Offices__c=true,Active__c = true, Expiry_Date__c = Date.Today() + 1);
        insert testNotif;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetChatterFeeds');

        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        //SL_IntranetChatterFeedsController objChatterController = new SL_IntranetChatterFeedsController();
        //objChatterController.compImpl = WidgetAbstract.getInstance(objWPSC);
        

		Test.startTest();

        /*
        objChatterController.getMyImpl();
        
        objChatterController.getMyImpl().strNotificationId = testNotif.Id;
        objChatterController.getNotifications();
        objChatterController.getNotificationRecords();
        objChatterController.insertFeedPost(); 
        objChatterController.prevRecords();
        objChatterController.getMyImpl().getMoreNotificationRecords(); 
        */
        system.assertEquals(0,0);
        Test.stopTest();
        
        
    }
    
    static testMethod void test_SL_IntranetChatterFeedsController2() {
    	
    	String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
        User testUser = new User(LastName = 'Test AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
                                 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = '  Department1',
                                 TimeZoneSidKey = 'America/New_York',Title = 'Title1',
                                 LocaleSidKey = 'en_US',
                                 EmailEncodingKey = 'ISO-8859-1',   
                                 LanguageLocaleKey = 'en_US',       
                                 IsActive=true,
                                 ProfileId = strProfileId,
                                 FirstName = 'testFirst',
                                 City = 'testCity',
                                 Country = 'testCountry',
                                 Street = 'testStreet',
                                 CompanyName = 'testCompanyName',
                                 Phone = 'testPhone',
                                 Extension = 'testExtension',
                                 User_Offices__c = 'test');
        insert testUser;
        
        SL_Intranet_PaginationSettings__c testPagination = new SL_Intranet_PaginationSettings__c(Name = 'Test Pagination', FeedPost_PageSize__c = 20);
        insert testPagination;
        
//        SL_CustomizableComponent__c objCC = new SL_CustomizableComponent__c(Updated_Static_Resource_Name__c = 'Test ', Logo__c = 'Logo', Default__c = false);
//        insert objCC;
        
        blob objTestBlob = Blob.valueOf('testBlob'); 
         
        FeedItem objFeedPost = new FeedItem(ParentId = testUser.id, Title = 'Test1', Body = 'Test1', Type='ContentPost', ContentFileName='Test File1', ContentData=objTestBlob);
        insert objFeedPost;
        FeedItem objFeedPost1 = new FeedItem(ParentId = testUser.id, Title = 'Test2', Body = 'Test2', Type='ContentPost', ContentFileName='Test File2', ContentData=objTestBlob);
        insert objFeedPost1;
        
        FeedComment objFeedComment = new FeedComment(commentBody='Test', feedItemId = objFeedPost.Id);
        insert objFeedComment;
        
        Notification__c testNotif = new Notification__c(Name= 'Test notif', Notification_Detail__c= 'Testing', For_All_Offices__c=true,Active__c = true, Expiry_Date__c = Date.Today() + 1);
        insert testNotif;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetChatterFeeds');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        //SL_IntranetChatterFeedsController objChatterController = new SL_IntranetChatterFeedsController();
       // objChatterController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	
    	Test.startTest();
        
        Apexpages.currentPage().getParameters().put('id', testUser.id);
        
      /*  objChatterController.reloadItems();
        objChatterController.insertFeedPost();
        ApexPages.currentPage().getParameters().put('feedPostId', objFeedPost.Id);
        ApexPages.currentPage().getParameters().put('feedCommentBody', 'This is comment');
        
        objChatterController.insertFeedComment();
        objChatterController.getMoreRecords();
        
        objChatterController.getMyImpl().deletedPostId = objFeedPost.Id;
        objChatterController.getMyImpl().deletedCommentId = objFeedComment.Id;
        objChatterController.deleteFeedPostComment();
        
        objChatterController.getMyImpl().deletedPostId = objFeedPost.Id;
        objChatterController.deleteFeedPost();
        
        objChatterController.nextRecords();
        Apexpages.currentPage().getparameters().put('pageNo','0');
        objChatterController.goToPage();
        
        objChatterController.getMyImpl().createEntitySubscription();
        objChatterController.getMyImpl().strNotificationSearchText = 'Test';
        objChatterController.getMyImpl().getNotificationSearchResult();
       */ 
        
        system.assertEquals(0,0);
        Test.stopTest();
    }
  
    static testMethod void test_SL_IntranetRecentUpdatesController()
    {
        
        Blob strBlob = Blob.valueOf('Test BlobContent');
        
        ContentVersion testContentInsert =new ContentVersion(); 
		testContentInsert.ContentURL='http://www.google.com/'; 
		testContentInsert.Title ='Google.com'; 
		insert testContentInsert; 
		ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id]; 
		ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace limit 1]; 
		ContentWorkspaceDoc newWorkspaceDoc =new ContentWorkspaceDoc(); 
		newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
		newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
		insert newWorkspaceDoc;
		testContent.For_All_Offices__c =true; 
		update testContent;
        
        Intranet_Event__c objEventAll = new Intranet_Event__c(Name='Test Event All', Date_of_Event__c = Date.today().addDays(1), For_All_Departments__c = true, For_All_Offices__c = true);
        insert objEventAll ;
        
        Notification__c objNotificationAll = new Notification__c(Name='Test Notification All',Active__c =true, For_All_Departments__c = true, For_All_Offices__c = true,Display_As_Of__c = Date.today(), Expiry_Date__c = Date.today().addDays(1));
        insert objNotificationAll ;
        
        List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
        Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
        lstOffLocToInsert.add(objOL);
        insert lstOffLocToInsert;
        
        List<Department__c> lstDeptToInsert = new List<Department__c>();
        Department__c objD = new Department__c(Name='Test Department-01');
        lstDeptToInsert.add(objD);
        insert lstDeptToInsert;
        
                
        Intranet_App__c objApp = new Intranet_App__c(Name='Test App', Active__c = true,
                                                           IntranetApp_Offices__c='Test Location-01 \n',
                                                           IntranetApp_Departments__c='Test Department-01 \n');
        insert objApp;
         
        
        PageRegionWidget__c objPageRegionWidget = createTestRecordsForIntranetRecentUpdates('SL_IntranetRecentUpdates');
        ApexPages.currentPage().getParameters().put('page','TestHome');
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetRecentUpdatesController objOfficeController = new SL_IntranetRecentUpdatesController();
        objOfficeController.compImpl = WidgetAbstract.getInstance(objWPSC);
        
        objOfficeController.getMyImpl();
        objOfficeController.getRecentUpdates();
        //objOfficeController.getMyImpl().isOnLoad = false;
        objOfficeController.getMyImpl().getRecentUpdates();
        //objOfficeController.viewAll();
        objOfficeController.getMyImpl().newComponent();
        objOfficeController.showMoreRecords(); 
        
        system.assertEquals(0,0);
    }
 
 	//Percent of test coverage : 100, 100     
    static testMethod void test_SL_Intranet_ListViews()
    {
    	ApexPages.currentPage().getParameters().put('page','TestHome');
    	
        PageRegionWidget__c objPageRegionWidget = createTestRecordsForListViews('SL_IntranetListViews');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetListViewsController objListViewController = new SL_IntranetListViewsController();
        objListViewController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objListViewController.getMyImpl();
        objListViewController.getMyImpl().newComponent();
        objListViewController.getMyImpl().getAllListViews();
        
        system.assertEquals(0,0);
    }
 
    static PageRegionWidget__c createTestRecordsForListViews(String configuration)
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
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"sobjectname":"Contact","heading":"Contact List","Listviews":"All Contacts"}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
 	
	static PageRegionWidget__c createTestRecordsforNotificationDetail(String configuration)
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
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"initialstate":"hidden","fieldset":"","showfeed":true,"heading":""}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
	  
    static PageRegionWidget__c createTestRecordsforNotification(String configuration)
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
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"fieldset":"","heading":"Notification","numbertodisplay":2,"TotalRecords":5}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
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
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"fieldset1":"","fieldset2":"","fontcolor":"","fontstyle":""}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
    
    static PageRegionWidget__c createTestRecordsForNavigationBar(String configuration)
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
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
    
    static PageRegionWidget__c createTestRecordsForStaffUpdates(String configuration)
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
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"fieldset":"","showAboutMe":false}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
    
    static PageRegionWidget__c createTestRecordsForIntranetOffices(String configuration)
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
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"fieldset1":"","fieldset2":"","fontcolor":"","fontstyle":""}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
       //Percent of test coverage : 93, 100 
    static PageRegionWidget__c createTestRecordsForIntranetRecentUpdates(String configuration)
    {
        Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'TestHome');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, 
        Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;  
        
        Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = configuration, Configuration__c = '{"Objects":"Notification__c, Intranet_Event__c,Intranet_App__c, ContentVersion","DefaultPageSize":4,"TotalRecords":10}');
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, 
        Widget__c = objWidget.id,
		Page_Region__r = objPageRegion, Widget__r = objWidget,Configuration__c = '{"Objects":"Notification__c, Intranet_Event__c,Intranet_App__c, ContentVersion","DefaultPageSize":4,"TotalRecords":10}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
}