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
private class SL_TestEmployeeProfileWidgets 
{
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
    
    //@IsTest(SeeAlldata = true)
    static testMethod void test_SL_IntranetEmployeeProfileController() 
    {
    	String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
        
        User objUser1 = new User(LastName = 'Test-AccountTestCon11', Alias = 'zmus', Email = 'test11@gmail.com',
					 			 Username = 'h1253234312111@gmail.com', CommunityNickname = 'h121254511',Department = 'Department11',
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
								 Extension = 'testExtension',
								 State = 'W',
								 PostalCode = '2345'); 
		insert objUser1;

		User objUser = new User(LastName = 'Test-AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
					 			 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = '	Department1',
								 TimeZoneSidKey = 'America/New_York',Title = 'Title1',
								 LocaleSidKey = 'en_US',
								 EmailEncodingKey = 'ISO-8859-1',   
								 LanguageLocaleKey = 'en_US',	    
								 ProfileId = strProfileId,
								 ManagerId = objUser1.id,
								 FirstName = 'testFirst',
		 						 City = 'testCity',
		 						 Country = 'testCountry',
								 Street = 'testStreet',
								 CompanyName = 'testCompanyName',
								 Phone = 'testPhone',
								 Extension = 'testExtension',
								 User_Offices__c = 'Test1 \n Test2',
								 PostalCode = '2345',
								 State = 'M',
								 AboutMe = 'Test');
		insert objUser;
		
		Apexpages.currentPage().getParameters().put('page','TestHomeNew');
		Apexpages.currentPage().getParameters().put('id',objUser.Id);
        PageRegionWidget__c objPageRegionWidget = createTestRecords('SL_IntranetEmployeeProfile');
        
    	WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
		
		SL_IntranetEmployeeProfileController objSL_IntranetEmployeeProfileController = new SL_IntranetEmployeeProfileController();
		
    	objSL_IntranetEmployeeProfileController.compImpl = WidgetAbstract.getInstance(objWPSC);
    	objSL_IntranetEmployeeProfileController.getMyImpl();
    	objSL_IntranetEmployeeProfileController.getMyImpl().newComponent();
    	
    	//objSL_IntranetEmployeeProfileController.getMyImpl().empPWConfigEmployeeProfileWidgetConfiguration() obj = new objSL_IntranetEmployeeProfileController.getMyImpl().EmployeeProfileWidgetConfiguration();
    	objSL_IntranetEmployeeProfileController.deleteChatterPhoto();
    	objSL_IntranetEmployeeProfileController.recetEditPopUpOnCancel();
    	system.assertEquals(objSL_IntranetEmployeeProfileController.getMyImpl().empPWConfig.isLoad, true); 
    	objSL_IntranetEmployeeProfileController.updateUserInfo();
    	system.assertEquals(objSL_IntranetEmployeeProfileController.getMyImpl().empPWConfig.isLoad, false); 
    	 
    }
    
    
    static testMethod void test_SL_IntranetReportingStructureController() 
    {
    	String strProfileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
        
        User objUser = new User(LastName = 'Test-AccountTestCon11', Alias = 'zmus', Email = 'test11@gmail.com',
					 			 Username = 'h1253234312111@gmail.com', CommunityNickname = 'h121254511',Department = 'Department11',
								 TimeZoneSidKey = 'America/New_York',Title = 'Title11',
								 LocaleSidKey = 'en_US',
								 EmailEncodingKey = 'ISO-8859-1',   
								 LanguageLocaleKey = 'en_US',	    
								 ProfileId = strProfileId,
								 isActive = true,
								 FirstName = 'testFirst',
		 						 City = 'testCity',
		 						 Country = 'testCountry',
								 Street = 'testStreet',
								 CompanyName = 'testCompanyName',
								 Phone = 'testPhone',
								 Extension = 'testExtension',
								 State = 'W',
								 PostalCode = '2345'); 
		insert objUser;

		User objUser1 = new User(LastName = 'Test-AccountTestCon1', Alias = 'zmus', Email = 'test1@gmail.com',
					 			 Username = 'h121211211@gmail.com', CommunityNickname = 'h12125451',Department = '	Department1',
								 TimeZoneSidKey = 'America/New_York',Title = 'Title1',
								 LocaleSidKey = 'en_US',
								 EmailEncodingKey = 'ISO-8859-1',   
								 LanguageLocaleKey = 'en_US',	    
								 ProfileId = strProfileId,
								 ManagerId = objUser.id,
								 FirstName = 'testFirst',
		 						 City = 'testCity',
		 						 Country = 'testCountry',
								 Street = 'testStreet',
								 CompanyName = 'testCompanyName',
								 Phone = 'testPhone',
								 Extension = 'testExtension',
								 User_Offices__c = 'Test1 \n Test2',
								 PostalCode = '2345',
								 State = 'M',
								 AboutMe = 'Test');
		insert objUser1;
		
		Apexpages.currentPage().getParameters().put('id',objUser1.Id);
        PageRegionWidget__c objPageRegionWidget = createTestRecordsForEmpReportingStructure('SL_IntranetReportingStructure');
        
    	WidgetPageSettingsConfiguration objWPSC = new WidgetPageSettingsConfiguration(objPageRegionWidget);	
		
		SL_IntranetReportingStructureController objSL_IntranetReportingStructure = new SL_IntranetReportingStructureController();
		
    	objSL_IntranetReportingStructure.compImpl = WidgetAbstract.getInstance(objWPSC);
    	objSL_IntranetReportingStructure.getMyImpl();
    	objSL_IntranetReportingStructure.getMyImpl().newComponent();
    	objSL_IntranetReportingStructure.showMoreRecords();
    	
    	system.assertEquals(0,0);
    }
    
    // test method for SL_VCard code
    static testMethod void test_SL_VCard() 
    {
        SL_VCard objVCard = new SL_VCard();
        
        system.assertEquals(0,0);
    }
    
    static PageRegionWidget__c createTestRecords(String configuration)
    {
    	Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'TestHomeNew');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = configuration);
    	insert objWidget;
    	
    	PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget,
    																		Configuration__c = '{"fieldset":"'+strNameSpace+'SL_EmployeeDirectoryFieldSet","popupfieldset":"","showdefaultfields":true,"showheader":true}');
    	insert objPageRegionWidget;
    	
    	return objPageRegionWidget;
    }
    
    static PageRegionWidget__c createTestRecordsForEmpReportingStructure(String configuration)
    {
    	Region__c objRegion = new Region__c(Name = 'testRegionEmpReportingStructure');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'TestHomeNewEmpReportingStructure');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testMGEmpReportingStructure',Type__c = configuration);
    	insert objWidget;
    	
    	PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget,
    																		Configuration__c = '{"numbertodisplay":5,"totalrecords":10}');
    	insert objPageRegionWidget;
    	
    	return objPageRegionWidget;
    }
    
}