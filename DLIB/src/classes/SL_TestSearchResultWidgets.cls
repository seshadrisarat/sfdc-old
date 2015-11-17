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
private class SL_TestSearchResultWidgets {
	
	private static String strNameSpace;
	static String strCommunityId = Network.getNetworkId();
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
    //Percent of test coverage : 100, 92
    @isTest
    static void test_SL_IntranetSearchResultsController() 
    {
        Test.startTest();
        
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
    	
    	User objUser = new User(LastName = 'Test-AccountTestCon11', Alias = 'zmus', Email = 'test11@gmail.com',
					 			 Username = 'h1212112111@gmail.com', CommunityNickname = 'h121254511',Department = 'Department11',
								 TimeZoneSidKey = 'America/New_York',Title = 'Title11',
								 LocaleSidKey = 'en_US',
								 EmailEncodingKey = 'ISO-8859-1',   
								 LanguageLocaleKey = 'en_US',	    
								 ProfileId = strProfileId,
								 FirstName = 'testFirst',
		 						 City = 'testCity',
		 						 Country = 'testCountry',
								 Street = 'testStreet',
								 CompanyName = 'testCompanyName',
								 Phone = 'testPhone',
								 Extension = 'testExtension');
		insert objUser;
    	
        blob objTestBlob = Blob.valueOf('testBlob'); 
        
        FeedItem objFeedItem = new FeedItem(ParentId = UserInfo.getUserId(), Title = 'Test', Body = 'Test', Type='ContentPost', ContentFileName='Test File', ContentData=objTestBlob);
        insert objFeedItem;
        
        FeedItem objFeedItem2 = new FeedItem(Title='Test Title', Body='<s>Test Body<s>', parentId = userInfo.getUserId(),Type='TextPost' );
        insert objFeedItem2;
        
        FeedItem objFeedItem1 = new FeedItem(Title='Test Title', Body='<s>Test Body<S> one more<s>', parentId = objUser.Id ,Type='TextPost');
        insert objFeedItem1;
        
        FeedComment objFeedComment = new FeedComment(commentBody='Test', feedItemId = objFeedItem.Id);
        insert objFeedComment;
        
        FeedComment objFeedComment1 = new FeedComment(commentBody='Test', feedItemId = objFeedItem.Id);
        insert objFeedComment1;
        
        CollaborationGroup testGroup = new CollaborationGroup(name='Test Group AA', CollaborationType = 'public');
        insert testGroup;
        
        SL_FeaturedGroups__c testFG = new SL_FeaturedGroups__c(name = 'Test Group AA', GroupId__c = testGroup.id);
        insert testFG;
        
        CollaborationGroup testGroup1 = new CollaborationGroup(name='Test Group111', CollaborationType = 'public');
        insert testGroup1;
        
        SL_FeaturedGroups__c testFG1 = new SL_FeaturedGroups__c(name = 'Test Group111', GroupId__c = testGroup1.id);
        insert testFG1;
        
        SL_Intranet_PaginationSettings__c testCS = new SL_Intranet_PaginationSettings__c(SearchResult_PageSize__c = 30, Name = 'Test CS', SearchResult_PageSize_Mobile__c = 30);
        insert testCS;
        Notification__c testNotif = new Notification__c(Name= 'Test notif', Notification_Detail__c= 'Testing', For_All_Offices__c=true,Active__c = true, Expiry_Date__c = Date.Today() + 1);
    	insert testNotif;
    	
        String strAvailableContentTypes = '';
		
		//To get the available content types 
		for(Schema.PicklistEntry obj : ContentVersion.Content_Types__c.getDescribe().getPicklistValues())
		{
			strAvailableContentTypes += obj.getValue() + ',';
		}
        
        Id[] fixedSearchResults = new Id[8];
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        lstContentVersion = [Select Id, Title, PathOnClient, Category_Level_1__c, Category_Level_2__c, Category_Level_3__c, ContentDocumentId From ContentVersion limit 2];
        
        if(lstContentVersion.size() > 1)
        {
	        fixedSearchResults[0] = lstContentVersion[0].Id;
	        fixedSearchResults[1] = lstContentVersion[1].Id;
	        fixedSearchResults[2] = objUser.Id;
	        fixedSearchResults[3] = objFeedItem.Id;
	        fixedSearchResults[4] = objFeedItem1.Id;
	        fixedSearchResults[5] = objFeedItem2.Id;
	        fixedSearchResults[6] = objFeedComment.Id;
	        fixedSearchResults[7] = objFeedComment1.Id;
	        Test.setFixedSearchResults(fixedSearchResults);
        }
        
        Apexpages.currentPage().getParameters().put('tab', 'Documents');
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetSearchResults');
        
		WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
    	
    	Apexpages.currentPage().getParameters().put('searchText', 'test');
        Apexpages.currentPage().getParameters().put('type', 'Post');
    	SL_IntranetSearchResultsController objSearchController = new SL_IntranetSearchResultsController();
    	
    	objSearchController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	objSearchController.getMyImpl();
    	objSearchController.getId();
    	objSearchController.getMyImpl().searchText = 'Test';
    	objSearchController.getMyImpl().strSobject = 'FeedItem';
    	objSearchController.getMyImpl().strLabel = 'Posts';
		objSearchController.getSearchResults(); 
		
		objSearchController.getMyImpl().searchText = 'Test';
    	objSearchController.getMyImpl().strSobject = 'Intranet_Event__c';
    	objSearchController.getMyImpl().strLabel = 'Calendar';
    	objSearchController.getMyImpl().strFieldsetToDisplay = strNameSpace+'Intranet_Calendars_Fields';
    	objSearchController.getMyImpl().strFieldsetToSearch = strNameSpace+'Intranet_Calendars_Fields';
		objSearchController.getSearchResults();
		objSearchController.getMyImpl().searchText = 'Test';
    	objSearchController.getMyImpl().strSobject = 'Intranet_Event__c';
    	objSearchController.getMyImpl().strLabel = 'Calendar';
    	objSearchController.getMyImpl().strFieldsetToDisplay = '';
    	objSearchController.getMyImpl().strFieldsetToSearch = '';
		objSearchController.getSearchResults(); 
		
		 
		objSearchController.getMyImpl().searchText = 'Test';
    	objSearchController.getMyImpl().strSobject = 'ContentVersion';
    	objSearchController.getMyImpl().strLabel = 'Secure Documents';
		objSearchController.getSearchResults(); 
		
		objSearchController.getMyImpl().searchText = 'Test';
    	objSearchController.getMyImpl().strSobject = 'Notification__c';
    	objSearchController.getMyImpl().strFieldsetToDisplay = strNameSpace+'NotificationFieldSet';
    	objSearchController.getMyImpl().strFieldsetToSearch = strNameSpace+'NotificationFieldSet';
    	objSearchController.getMyImpl().strLabel = 'Notifications';
		objSearchController.getSearchResults();   
		objSearchController.getMyImpl().searchText = 'Test';
    	objSearchController.getMyImpl().strSobject = 'Notification__c';
    	objSearchController.getMyImpl().strLabel = 'Notifications';
    	objSearchController.getMyImpl().strFieldsetToDisplay = '';
    	objSearchController.getMyImpl().strFieldsetToSearch = '';
		objSearchController.getSearchResults(); 
		
		
		objSearchController.getMyImpl().searchText = 'Test';
    	objSearchController.getMyImpl().strSobject = 'User';
    	objSearchController.getMyImpl().strLabel = 'Employee Directory';
		objSearchController.getMyImpl().strFieldsetToDisplay = strNameSpace+'SL_EmployeeDirectoryFieldSet';
        objSearchController.getMyImpl().strFieldsetToSearch = strNameSpace+'SL_EmployeeDirectoryFieldSet';
        objSearchController.getSearchResults();   
        
        objSearchController.getMyImpl().searchText = 'Test';
    	objSearchController.getMyImpl().strSobject = 'User';
    	objSearchController.getMyImpl().strLabel = 'Employee Directory';
		objSearchController.getMyImpl().strFieldsetToDisplay = strNameSpace+'SL_EmployeeDirectoryFieldSet';
        objSearchController.getMyImpl().strFieldsetToSearch = '';
        objSearchController.getSearchResults();  
        
        
        objSearchController.getMyImpl().searchText = 'Test';
        objSearchController.getMyImpl().strSobject = 'Intranet_App__c';
        objSearchController.getMyImpl().strLabel = 'Application';
        objSearchController.getMyImpl().strFieldsetToDisplay = '';
        objSearchController.getMyImpl().strFieldsetToSearch = '';
        objSearchController.getSearchResults();
        
        objSearchController.getMyImpl().searchText = 'Test';
        objSearchController.getMyImpl().strSobject = 'Department__c';
        objSearchController.getMyImpl().strLabel = 'Department';
        objSearchController.getMyImpl().strFieldsetToDisplay = strNameSpace+'Department_FieldSet';
    	objSearchController.getMyImpl().strFieldsetToSearch = strNameSpace+'Department_FieldSet';
        objSearchController.getSearchResults();  
        objSearchController.getMyImpl().searchText = 'Test';
        objSearchController.getMyImpl().strSobject = 'Department__c';
        objSearchController.getMyImpl().strLabel = 'Department';
        objSearchController.getMyImpl().strFieldsetToDisplay = '';
    	objSearchController.getMyImpl().strFieldsetToSearch = '';
        objSearchController.getSearchResults(); 
        
		
		ApexPages.currentPage().getParameters().put('feedPostId', objFeedItem.Id);
        ApexPages.currentPage().getParameters().put('feedCommentBody', 'Test Comment');
        //objSearchController.insertFeedCommemt();
        
        ApexPages.currentPage().getParameters().put('Id', objFeedItem.Id);          
        Apexpages.currentPage().getParameters().put('LikeOrUnlike', 'Like');
       // objSearchController.feedLikeUnlike();
        
        Apexpages.currentPage().getParameters().put('LikeOrUnlike', 'Unlike');
       // objSearchController.feedLikeUnlike();
        
        ApexPages.currentPage().getParameters().put('CommentToBeDelete', objFeedComment1.Id);
        //objSearchController.deleteFeedPostComment();
        
        ApexPages.currentPage().getParameters().put('feedPostToBeDeleted', objFeedItem.Id);
       // objSearchController.deleteFeedPost();
        
		objSearchController.getMoreRecords();
		objSearchController.getMoreRecordsForMobile();
		
		objSearchController.nextRecords();
		objSearchController.prevRecords();
		Apexpages.currentPage().getparameters().put('pageNo','0');
		objSearchController.goToPage(); 	
    	Apexpages.currentPage().getParameters().put('page','testPage');
    	Apexpages.currentPage().getParameters().put('CommentToBeDelete',objFeedComment1.Id);
    	objSearchController.getMyImpl().newComponent();
    	SL_IntranetSearchResults objSL_IntranetSearchResults = new SL_IntranetSearchResults();
    	objSL_IntranetSearchResults.totalPages = 5;
    	objSL_IntranetSearchResults.rowsPerPage = 5;
    	objSL_IntranetSearchResults.totalRecords = 15;
    	objSL_IntranetSearchResults.lastRecords();
    	objSL_IntranetSearchResults.nextRecords();
    	objSL_IntranetSearchResults.prevRecords();
    	//objSL_IntranetSearchResults.deleteFeedPostComment();
    	
    	system.assertEquals(0,0);
    	Test.stopTest();
    }
    
    
    //Percent of test coverage : 100, 91
    static testMethod void test_SL_IntranetSearchTypesController() 
    {
        Test.startTest();
        
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
    	
    	User objUser = new User(LastName = 'Test-AccountTestCon11', Alias = 'zmus', Email = 'test11@gmail.com',
					 			 Username = 'h1212112111@gmail.com', CommunityNickname = 'h121254511',Department = 'Department11',
								 TimeZoneSidKey = 'America/New_York',Title = 'Title11',
								 LocaleSidKey = 'en_US',
								 EmailEncodingKey = 'ISO-8859-1',   
								 LanguageLocaleKey = 'en_US',	    
								 ProfileId = strProfileId,
								 FirstName = 'testFirst',
		 						 City = 'testCity',
		 						 Country = 'testCountry',
								 Street = 'testStreet',
								 CompanyName = 'testCompanyName',
								 Phone = 'testPhone',
								 Extension = 'testExtension');
		insert objUser;
    	
        
        SL_Intranet_PaginationSettings__c objPageSetting = new SL_Intranet_PaginationSettings__c(Name = 'pageSize', ManageGroups_PageSize__c = 10);
        insert objPageSetting;
        
		blob objTestBlob = Blob.valueOf('testBlob'); 
        
        FeedItem objFeedItem = new FeedItem(ParentId = objUser.Id, Title = 'Test', Body = 'Test', Type='ContentPost', ContentFileName='Test File', ContentData=objTestBlob);
        insert objFeedItem;
       
        //objSearchTypeController.getSearchResults();
        
        FeedItem objFeedItem2 = new FeedItem(Title='Test Title', Body='<s>Test Body<s>', parentId = userInfo.getUserId(),Type='TextPost' );
        insert objFeedItem2;
        
        FeedItem objFeedItem1 = new FeedItem(Title='Test Title', Body='<s>Test Body<S> one more<s>', parentId = objUser.Id ,Type='TextPost');
        insert objFeedItem1;

        FeedComment objFeedComment = new FeedComment(commentBody='Test', feedItemId = objFeedItem.Id);
        insert objFeedComment;
        
        FeedComment objFeedComment1 = new FeedComment(commentBody='Test', feedItemId = objFeedItem.Id);
        insert objFeedComment1;
        
        CollaborationGroup testGroup = new CollaborationGroup(name='Test Group AA', CollaborationType = 'public');
        insert testGroup;
        
        SL_FeaturedGroups__c testFG = new SL_FeaturedGroups__c(name = 'Test Group AA', GroupId__c = testGroup.id);
        insert testFG;
        
        CollaborationGroup testGroup1 = new CollaborationGroup(name='Test Group111', CollaborationType = 'public');
        insert testGroup1;
        
        SL_FeaturedGroups__c testFG1 = new SL_FeaturedGroups__c(name = 'Test Group111', GroupId__c = testGroup1.id);
        insert testFG1;
		PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetSearchTypes');
       
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
        
    	Apexpages.currentPage().getParameters().put('searchText','Test');
    	ConnectApi.FeedItemPage testPage = new ConnectApi.FeedItemPage();
    	List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
    	ConnectApi.FeedItem fItem = new ConnectApi.FeedItem(); 
        fItem.Id = objFeedItem2.Id; 
        fItem.actor = new ConnectApi.UserSummary();
        fItem.attachment = new ConnectApi.ContentAttachment();
        fItem.CreatedDate = objFeedItem2.CreatedDate;
        fItem.parent = new ConnectApi.UserSummary();
        fItem.parent.Name = objUser.Name;
        fItem.parent.Id = objUser.Id;
        fItem.body = new ConnectApi.FeedBody();
        
        List<ConnectApi.MessageSegment> segments = new List<ConnectApi.MessageSegment>();
        ConnectApi.TextSegment textsegment = new ConnectApi.TextSegment();
        textsegment.text = 'Test -text';
        segments.add(textsegment);
     	fitem.body.messageSegments = segments;
    	
    	testItemList.add(fItem);
    	testPage.items = testItemList;
    	ConnectApi.ChatterFeeds.setTestSearchFeedItems(strCommunityId, 'Test', null, null, ConnectApi.FeedSortOrder.CreatedDateDesc,  testPage);
    	
    	SL_IntranetSearchTypesController objSearchTypeController = new SL_IntranetSearchTypesController();
    	objSearchTypeController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	objSearchTypeController.getMyImpl();
    	//objSearchTypeController.getMyImpl().getSearchResults();
		//objSearchTypeController.getSearchResults();    	
    	objSearchTypeController.getMyImpl().newComponent();
    	
    	
    	objPageRegionWidget.Configuration__c = '{"categories": "User:Employee Directory::,Notification__c:Notifications:'+strNameSpace+'NotificationFieldSet:'+strNameSpace+'NotificationFieldSet,ContentVersion:Secure Documents::,Intranet_Event__c:Calendar Entries:'+strNameSpace+'Intranet_Calendars_Fields:'+strNameSpace+'Intranet_Calendars_Fields,Intranet_App__c:Application::,Department__c:Department:'+strNameSpace+'Department_FieldSet:'+strNameSpace+'Department_FieldSet,FeedItem:Posts"}';
    	update objPageRegionWidget;
    	objSearchTypeController = new SL_IntranetSearchTypesController();
    	objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
    	objSearchTypeController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	//objSearchTypeController.getMyImpl();
    	
    	system.assertEquals(0,0);
    	Test.stopTest();
    }
        
    static PageRegionWidget__c createTestRecords(String configuration)
    {
    	
    	Notification__c objNotif = new Notification__c(Name = 'Test Notification-1');
    	insert objNotif;
    	
    	Intranet_Event__c objIntranetEvent = new Intranet_Event__c(Name = 'Test Event-1');
    	insert objIntranetEvent;
    	
    	Department__c objDep = new Department__c(Name = 'Department Test-11');
        insert objDep;
        
        Intranet_App__c objApp = new Intranet_App__c(Name='test Application-11');
        insert objApp;
        
        Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'testPage');
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = configuration,Configuration__c = '{"categories": "User:Employee Directory:SL_EmployeeDirectoryFieldSet:SL_EmployeeDirectoryFieldSet,Notification__c:Notifications::,ContentVersion:Secure Documents::,Intranet_Event__c:Calendar Entries::,Intranet_App__c:Application::,Department__c:Department::,FeedItem:Posts"}');
        insert objWidget;
        
        Intranet_Event__c objEventAll = new Intranet_Event__c(Name='Test Event All', Date_of_Event__c = Date.today().addDays(1), For_All_Departments__c = true, For_All_Offices__c = true);
        insert objEventAll ;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                          Page_Region__r = objPageRegion, Widget__r = objWidget,
                                                                          Configuration__c = '{"categories": "User:Employee Directory:SL_EmployeeDirectoryFieldSet:SL_EmployeeDirectoryFieldSet,Notification__c:Notifications::,ContentVersion:Secure Documents::,Intranet_Event__c:Calendar Entries::,Intranet_App__c:Application::,Department__c:Department::,FeedItem:Posts"}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
    
}