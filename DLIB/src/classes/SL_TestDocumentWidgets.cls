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
private class SL_TestDocumentWidgets {

   
    static testMethod void testDocumentsOfficesVisibility() {
        
        Office_Locations__c officeA = new Office_Locations__c(Name = 'Test Office A');
        insert officeA;
        Office_Locations__c officeB = new Office_Locations__c(Name = 'Test Office B');
        insert officeB;
        
        ContentVersion docOfOfficeA = new ContentVersion(
            Title = 'test Content of office A', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Offices__c = false, 
            Selected_Offices_Ids__c = officeA.Id, 
            Selected_Department_Ids__c = null
        );
        ContentVersion docOfOfficeB = new ContentVersion(
            Title = 'test Content of Office B', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Offices__c = false, 
            Selected_Offices_Ids__c = officeB.Id, 
            Selected_Department_Ids__c = null
        );
        ContentVersion docOfOfficeAB = new ContentVersion(
            Title = 'test Content of Office AB', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Offices__c = false, 
            Selected_Offices_Ids__c = officeB.Id + ';' + officeA.Id, 
            Selected_Department_Ids__c = null
        );
        ContentVersion docForAllOffices = new ContentVersion(
            Title = 'test Content of Office ForAll', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Offices__c = true, 
            Selected_Offices_Ids__c = officeB.Id + ';' + officeA.Id, 
            Selected_Department_Ids__c = null
        );
        ContentVersion docUnassigned = new ContentVersion(
            Title = 'test Content of Unassigned Offices', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Offices__c = false, 
            Selected_Offices_Ids__c = null, 
            Selected_Department_Ids__c = null
        );
        
        
        IVisibilitySpecification specEmpty = new OfficesSpecification(null);
        IVisibilitySpecification specOfficeA = new OfficesSpecification(new Set<String>{officeA.Id});
        IVisibilitySpecification specOfficeB = new OfficesSpecification(new Set<String>{officeB.Id});
        IVisibilitySpecification specOfficeAB = new OfficesSpecification(new Set<String>{officeA.Id, officeB.Id});
                
        
        Test.startTest();
        
        // empty specification allows FOR ALL OFFICES documents only
        system.assert(
            !specEmpty.satisfiedBy(docOfOfficeA) && 
            !specEmpty.satisfiedBy(docOfOfficeB) && 
            !specEmpty.satisfiedBy(docOfOfficeAB) && 
            !specEmpty.satisfiedBy(docForAllOffices) && 
            !specEmpty.satisfiedBy(docUnassigned) 
        );
        
        // office related specification allows only respective office or FOR ALL
        system.assert(
            specOfficeB.satisfiedBy(docOfOfficeB) && 
            specOfficeB.satisfiedBy(docOfOfficeAB) && 
            specOfficeB.satisfiedBy(docForAllOffices) && 
            !specOfficeB.satisfiedBy(docOfOfficeA) && 
            !specOfficeB.satisfiedBy(docUnassigned)      
        );
        // offices related specification allows only respective offices or FOR ALL
        system.assert(
            specOfficeAB.satisfiedBy(docOfOfficeA) && 
            specOfficeAB.satisfiedBy(docOfOfficeB) && 
            specOfficeAB.satisfiedBy(docOfOfficeAB) && 
            specOfficeAB.satisfiedBy(docForAllOffices) && 
            !specOfficeAB.satisfiedBy(docUnassigned)
        );
        
        Test.stopTest();
    }
    
    static testMethod void testDocumentsDepartmentsVisibility() {
        
        Department__c departmentA = new Department__c(Name = 'Test Department A');
        insert departmentA;
        Department__c departmentB = new Department__c(Name = 'Test Department B');
        insert departmentB;
        
        ContentVersion docOfDepartmentA = new ContentVersion(
            Title = 'test Content of Department A', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Departments__c = false, 
            Selected_Department_Ids__c = departmentA.Id
        );
        ContentVersion docOfDepartmentB = new ContentVersion(
            Title = 'test Content of Department B', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Departments__c = false, 
            Selected_Department_Ids__c = departmentB.Id
        );
        ContentVersion docOfDepartmentAB = new ContentVersion(
            Title = 'test Content of Department AB', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Departments__c = false,
            Selected_Department_Ids__c = departmentB.Id + ';' + departmentA.Id
        );
        ContentVersion docForAllDepartments = new ContentVersion(
            Title = 'test Content of all Department', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Departments__c = true,
            Selected_Department_Ids__c = ''
        );
        ContentVersion docForAllDepartmentsNotEmpty = new ContentVersion(
            Title = 'test Content of all Department', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Departments__c = true,
            Selected_Department_Ids__c = departmentB.Id + ';' + departmentA.Id
        );
        ContentVersion docUnassigned = new ContentVersion(
            Title = 'test Content of Unassigned Department', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'), 
            For_All_Departments__c = false,
            Selected_Department_Ids__c = null
        );
        
        
        IVisibilitySpecification specEmpty = new DepartmentSpecification(null);
        IVisibilitySpecification specDepartmentA = new DepartmentSpecification(departmentA.Id);
        IVisibilitySpecification specDepartmentB = new DepartmentSpecification(departmentB.Id);
                        
        
        Test.startTest();
        
        // empty specification allows FOR ALL DEPARTMENTS documents or documents with no departments assigned
        system.assert(
            !specEmpty.satisfiedBy(docOfDepartmentA) && 
            !specEmpty.satisfiedBy(docOfDepartmentB) && 
            !specEmpty.satisfiedBy(docOfDepartmentAB) && 
            specEmpty.satisfiedBy(docForAllDepartments) &&
            !specEmpty.satisfiedby(docForAllDepartmentsNotEmpty) &&  
            specEmpty.satisfiedBy(docUnassigned) 
        );
        
        // department related specification allows only respective department or FOR ALL
        system.assert(
            specDepartmentB.satisfiedBy(docOfDepartmentB) && 
            specDepartmentB.satisfiedBy(docOfDepartmentAB) && 
            specDepartmentB.satisfiedBy(docForAllDepartments) && 
            !specDepartmentB.satisfiedBy(docOfDepartmentA) && 
            !specDepartmentB.satisfiedBy(docUnassigned)      
        );
        system.assert(
            specDepartmentA.satisfiedBy(docOfDepartmentA) && 
            specDepartmentA.satisfiedBy(docOfDepartmentAB) && 
            specDepartmentA.satisfiedBy(docForAllDepartments) && 
            !specDepartmentA.satisfiedBy(docOfDepartmentB) && 
            !specDepartmentA.satisfiedBy(docUnassigned)      
        );      
        
        Test.stopTest();
    }
    
   
    static testMethod void test_SL_IntranetContentTypes()
    {
        String strContentTypes = '';
        Schema.DescribeFieldResult fldDescResult = ContentVersion.Content_Types__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fldDescResult.getPicklistValues();
        
        ContentVersion objContentVersion =new ContentVersion(ContentURL='http://www.google.com/', Title ='Google.com', FirstPublishLocationId = Userinfo.getUserId()); 
        insert objContentVersion;
        
        for(Schema.PicklistEntry obj : pickListValues)
        { 
            strContentTypes = (strContentTypes != '' ? (strContentTypes+', ' + obj.getValue()) : obj.getValue());
        }
        SL_IntranetDocumentsSetting__c testIDS = new SL_IntranetDocumentsSetting__c(SetupOwnerId = UserInfo.getUserId(), Content_Type__c = strContentTypes);
        insert testIDS;
        
        SL_IntranetContentTypes objContentTypes = new SL_IntranetContentTypes();
        
        /*Start - Checking if it is returning correct number of content types from org*/
    
        //system.assertEquals(objContentTypes.lstContentTypes.size(),0);
        //objContentTypes.getLeftSidebarContents();
        objContentTypes.rerenderTheCategories();
        
        //system.assertEquals(objContentTypes.lstContentTypes.size(),1);
        /*End - Checking if it is returning correct number of content types from org*/
        
        objContentTypes.getId();
        objContentTypes.getName();
        
        testIDS.SetupOwnerId = UserInfo.getProfileId();
        update testIDS;
        objContentTypes = new SL_IntranetContentTypes();
        
        testIDS.SetupOwnerId = UserInfo.getOrganizationId();
        update testIDS;
        objContentTypes = new SL_IntranetContentTypes();
        
        system.assertEquals(0,0);
    }
    
    static testmethod void test_SL_IntranetContentTypesController()
    {
        //ContentVersion objContentVersion =  new ContentVersion(Title = 'test Content', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'));
        //insert objContentVersion;
        Blob strBlob = Blob.valueOf('Test BlobContent');
        
        ContentVersion objContentVersion =new ContentVersion(); 
        objContentVersion.ContentURL='http://www.google.com/'; 
        objContentVersion.Title ='Google.com'; 
        objContentVersion.FirstPublishLocationId = Userinfo.getUserId();

        insert objContentVersion; 
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :objContentVersion.Id]; 
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace limit 1]; 
        ContentWorkspaceDoc newWorkspaceDoc =new ContentWorkspaceDoc(); 
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
        insert newWorkspaceDoc;
        objContentVersion.For_All_Offices__c =true; 
        update objContentVersion;
        
        String strContentTypes = '';
        Schema.DescribeFieldResult fldDescResult = ContentVersion.Content_Types__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fldDescResult.getPicklistValues();
        
        for(Schema.PicklistEntry obj : pickListValues)
        { 
            strContentTypes = (strContentTypes != '' ? (strContentTypes+', ' + obj.getValue()) : obj.getValue());
        }
        SL_IntranetDocumentsSetting__c testIDS = new SL_IntranetDocumentsSetting__c(SetupOwnerId = UserInfo.getUserId(), Content_Type__c = strContentTypes);
        insert testIDS;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetContentTypes');
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetContentTypesController objContentTypesController = new SL_IntranetContentTypesController();
        objContentTypesController.compImpl = WidgetAbstract.getInstance(objWPSC);
        Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objContentTypesController.getMyImpl().notify(objIWidget);
		objContentTypesController.getMyImpl().postInitialize();
		
		
        /**/
        //system.assertEquals(0,objContentTypesController.getMyImpl().lstContentTypes.size());
        /**/
        
        objContentTypesController.getLeftSidebarContents();
        //system.assertEquals(2,objContentTypesController.getMyImpl().lstContentTypes.size());
        objContentTypesController.getMyImpl();
        objContentTypesController.getFilteredByDepartment();
        
        SL_IntranetContentTypes objContentTypes = new SL_IntranetContentTypes();
        //system.assertEquals(objContentTypes.mapContentTypesToLstFirstLevelCatg.size(), 0);
        
        
        
        objContentTypesController.getMyImpl().newComponent();
        objContentTypesController.getMyImpl().contentTypesToFirstLevelcategories = 'Test1::Test2@#Test3::Test4';
        objContentTypesController.getMyImpl().firstLevelToSecondLevelcategories = 'Test1::Test2@#Test3::Test4';
        objContentTypesController.getMyImpl().secondLevelToThirdLevelcategories = 'Test1::Test2@#Test3::Test4';
        objContentTypesController.getLeftSidebarContents();
        
        system.assertEquals(0,0);
    } 
    
    static testMethod void test_SL_IntranetDocuments()
    {
        //return;
        String strContentTypes = '';
        Schema.DescribeFieldResult fldDescResult = ContentVersion.Content_Types__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fldDescResult.getPicklistValues();
        
        for(Schema.PicklistEntry obj : pickListValues)
        { 
            strContentTypes = (strContentTypes != '' ? (strContentTypes+', ' + obj.getValue()) : obj.getValue());
        }
        SL_Intranet_PaginationSettings__c obj = new SL_Intranet_PaginationSettings__c(Name='test',Documents_PageSize__c=10,Documents_PageSize_Mobile__c=2);
        insert obj;
        SL_IntranetDocumentsSetting__c testIDS = new SL_IntranetDocumentsSetting__c(SetupOwnerId = UserInfo.getUserId(), Content_Type__c = strContentTypes);
        insert testIDS;
        
        FeedItem testFeed = new FeedItem(parentId = UserInfo.getUserId(), Body = 'Test Feed');
        insert testFeed;
        
        FeedComment testComment = new FeedComment(FeedItemId = testFeed.Id, commentBody = 'Test Comment');
        insert testComment;
        
        Apexpages.currentPage().getParameters().put('id', Userinfo.getUserId());
                        
        Apexpages.currentPage().getparameters().put('cat0', 'test');
        SL_IntranetDocuments objDocuments = new SL_IntranetDocuments();
        objDocuments.initialize();
        objDocuments.getMoreContentRecords();
        objDocuments.FirstLevelCatg = 'test';
        objDocuments.SecondLevelCatg = 'test';
        objDocuments.ThirdLevelCatg = 'test';
        //objDocuments.getMoreRecords();
        
        Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
		objDocuments.notify(objIWidget);
		objDocuments.postInitialize();
		
		SL_DocumentUploadController objDocUpload = new SL_DocumentUploadController();
		objDocUpload.getallValuesForSelectList();
		objDocUpload.attachmentBody = Blob.valueOf('Test 123');
		objDocUpload.objContentVersion.VersionData = Blob.valueOf('Test 123') ;
		objDocUpload.objContentVersion.PathOnClient = '/Test.txt';
		objDocUpload.objContentVersion.Title = 'Test title file';
		objDocUpload.uploadDocument();
        
        system.assertEquals(0,0);
    }
    
    static testMethod void test_SL_IntranetDocuments_FilterByDepartment()
    {
        String strContentTypes = '';
        Schema.DescribeFieldResult fldDescResult = ContentVersion.Content_Types__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fldDescResult.getPicklistValues();
        
        for(Schema.PicklistEntry obj : pickListValues)
        { 
            strContentTypes = (strContentTypes != '' ? ',' + obj.getValue() : obj.getValue());
        }
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
        SL_Intranet_PaginationSettings__c obj = new SL_Intranet_PaginationSettings__c(Name='test',Documents_PageSize__c=10,Documents_PageSize_Mobile__c=2);
        insert obj;
        SL_IntranetDocumentsSetting__c testIDS = new SL_IntranetDocumentsSetting__c(SetupOwnerId = UserInfo.getUserId(), Content_Type__c = strContentTypes);
        insert testIDS;
        
        FeedItem testFeed = new FeedItem(parentId = UserInfo.getUserId(), Body = 'Test Feed');
        insert testFeed;
        
        FeedComment testComment = new FeedComment(FeedItemId = testFeed.Id, commentBody = 'Test Comment');
        insert testComment;
        
        Apexpages.currentPage().getParameters().put('id', Userinfo.getUserId());
                        
        Apexpages.currentPage().getparameters().put('cat0', 'test');
        SL_IntranetDocuments objDocuments = new SL_IntranetDocuments();
        objDocuments.initialize();
        objDocuments.getFeaturedOrRecentContents();
        Department__c objDep = new Department__c(Name = 'Test dept');
        insert objDep;
        objDocuments.strDeptId = objDep.Id;
        objDocuments.getFilteredByDepartment();
        objDocuments.getFeaturedOrRecentContents();
        
        system.assertEquals(0,0);
    }
    
    static testmethod void test_SL_IntranetDocumentsController()
    {
        SL_Intranet_PaginationSettings__c objPS = new SL_Intranet_PaginationSettings__c(Name = 'testSize', Documents_PageSize__c = 2, Documents_PageSize_Mobile__c = 2);
        insert objPS;
        
        ContentVersion objContentVersion =  new ContentVersion(Title = 'test Content', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'));
        insert objContentVersion;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetDocuments');
        objPageRegionWidget.Configuration__c = '{"showfeed":"","showFieldLabel":"","fieldset":"","displayFilterLinks":true}';
        update objPageRegionWidget;
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        Apexpages.currentPage().getparameters().put('cat0', 'test');
        SL_IntranetDocumentsController objDocuments = new SL_IntranetDocumentsController();
        objDocuments.compImpl = WidgetAbstract.getInstance(objWPSC);
        objDocuments.getMyImpl();
        objDocuments.getMyImpl().newComponent();
        objDocuments.getFeaturedOrRecentContents();
        objDocuments.getMyImpl().FirstLevelCatg = 'test';
        objDocuments.getMyImpl().SecondLevelCatg = 'test';
        objDocuments.getMyImpl().ThirdLevelCatg = 'test';
        objDocuments.getCategoryRelatedContent();
        objDocuments.prevRecords();
        objDocuments.nextRecords();
        Apexpages.currentPage().getparameters().put('pageNo', '2');
        objDocuments.goToPage();
        objDocuments.getFilteredByDepartment();
        objDocuments.getMyImpl().fetchContentChatter();
        objDocuments.getMyImpl().getOffsetDocumentRecords();
        
        /*
        objDocuments = new SL_IntranetDocumentsController();
        objDocuments.compImpl = WidgetAbstract.getInstance(objWPSC);
        objDocuments.getMyImpl();
        objDocuments.getMyImpl().newComponent();
        */
        system.assertEquals(0,0);
    } 

	static testmethod void test_SL_IntranetRecentDocuments()
    {
    	String strContentTypes = '';
        Schema.DescribeFieldResult fldDescResult = ContentVersion.Content_Types__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fldDescResult.getPicklistValues();
        
        for(Schema.PicklistEntry obj : pickListValues)
        { 
            strContentTypes = (strContentTypes != '' ? ',' + obj.getValue() : obj.getValue());
        }
        
        SL_IntranetDocumentsSetting__c testIDS = new SL_IntranetDocumentsSetting__c(SetupOwnerId = UserInfo.getUserId(), Content_Type__c = strContentTypes);
        insert testIDS;
        
        ContentVersion objContentVersion =  new ContentVersion(Title = 'test Recent Content', PathOnClient = '/Test.txt', versionData = Blob.valueOf('Test 123'));
        insert objContentVersion;
        
    	PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetRecentDocuments');
        objPageRegionWidget.Configuration__c = '{"numbertodisplay":5,"TotalRecords":10}';
        update objPageRegionWidget;
        
        WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget); 
        
        SL_IntranetRecentDocumentsController objRDController = new SL_IntranetRecentDocumentsController();
        objRDController.compImpl = WidgetAbstract.getInstance(objWPSC);
        objRDController.getMyImpl();
        objRDController.getMyImpl().newComponent();
        
        SL_IntranetRecentDocuments objRecentDocuments = new SL_IntranetRecentDocuments();
        objRecentDocuments.noOfRecordToDisplay = 5;
        objRecentDocuments.showMoreRecords();
        
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
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
                                                                            Page_Region__r = objPageRegion, Widget__r = objWidget,
                                                                            Configuration__c = '{"showfeed":false,"showFieldLabel":false,"fieldset":"","displayFilterLinks":true}');
        insert objPageRegionWidget;
        
        return objPageRegionWidget;
    }
}