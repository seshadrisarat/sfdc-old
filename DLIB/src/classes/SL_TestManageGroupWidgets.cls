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
private class SL_TestManageGroupWidgets {

    //Percent of test coverage : 100, 100
    
    //Percent of test coverage : 100, 100
    static testMethod void test_SL_IntranetManageGroupsController() 
    {
        String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
    	
    	User objUser1 = new User(LastName = 'Test-AccountTestCon11', Alias = 'zmus', Email = 'test11@gmail.com',
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
		insert objUser1;
    	
    	List<CollaborationGroup> lstCollaborationGroup = new List<CollaborationGroup>();
    	
    	CollaborationGroup testGroup = new CollaborationGroup(name='Test__&Manage&__Group', CollaborationType = 'public');
        lstCollaborationGroup.add(testGroup);
        
        CollaborationGroup testGroup1 = new CollaborationGroup(name='Test_&Manage&_Group1', CollaborationType = 'public', OwnerId = objUser1.id);
        lstCollaborationGroup.add(testGroup1);
        
        insert lstCollaborationGroup;
        
        SL_Intranet_PaginationSettings__c objPageSetting = new SL_Intranet_PaginationSettings__c(Name = 'pageSize', ManageGroups_PageSize__c = 10);
        insert objPageSetting;
        
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetManageGroups');
        
		WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
    	
    	SL_IntranetManageGroupsController objMGController = new SL_IntranetManageGroupsController();
    	
    	objMGController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	
    	SL_IntranetManageGroups objSL_IntranetManageGroups = new SL_IntranetManageGroups();
    	
    	objMGController.getMyImpl();
    	
    	/*Start - Checking if it is displaying all groups which we have inserted.*/
       
    	system.assertEquals(objSL_IntranetManageGroups.lstManageGroup.size(),0);
    	system.assertNotEquals(objSL_IntranetManageGroups.lstManageGroup.size(),1);
    	
    	/*End - Checking if it is displaying all groups which we have inserted.*/
    	
    	objMGController.getMyImpl().strGroupId = testGroup1.id;
    	
    	List<CollaborationGroupMember> lstCGMember2 = [select Id from CollaborationGroupMember where CollaborationGroupId =: testGroup1.Id and MemberId = :UserInfo.getUserId()];
    	system.assertEquals(0, lstCGMember2.size());
    	
    	/*Start - Checking if after joining it will return the correct groups*/
    	objMGController.joinNewGroupMember();
    	List<CollaborationGroupMember> lstCGMember = [select Id from CollaborationGroupMember where CollaborationGroupId =: testGroup1.Id and MemberId = :UserInfo.getUserId()];
    	system.assertEquals(1, lstCGMember.size());
    	/*End - Checking if after joining it will return the correct groups*/
    	
    	/*Start - Checking if after leaving the group it will not return any group*/
    	objMGController.leaveTheGroup();
    	List<CollaborationGroupMember> lstCGMember1 = [select Id from CollaborationGroupMember where CollaborationGroupId =: testGroup1.Id and MemberId = :UserInfo.getUserId()];
    	system.assertEquals(0, lstCGMember1.size());
    	/*End - Checking if after leaving the group it will not return any group*/
    	
    	objMGController.nextRecords();
    	objMGController.prevRecords();
    	
    	Apexpages.currentPage().getParameters().put('pageNo', '0');
    	objMGController.goToPage();
    	objMGController.getMyImpl().newComponent();
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
    																		Page_Region__r = objPageRegion, Widget__r = objWidget);
    	insert objPageRegionWidget;
    	
    	return objPageRegionWidget;
    }
}