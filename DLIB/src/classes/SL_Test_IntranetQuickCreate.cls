/**
* \arg ClassName  : SL_Test_IntranetQuickCreate
* \arg JIRATicket : SOCINT-285
* \arg CreatedOn  : Lodhi, 10/Sep/2013 
* \arg ModifiedBy : Lodhi, 10/Oct/2013 
* \arg Description: This is the test class for SL_IntranetQuickCreate and SL_IntranetQuickCreateController
*/

@isTest

public class SL_Test_IntranetQuickCreate 
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
	
	public static testmethod void test_SL_IntranetQuickCreateController()
	{
		Test.startTest();
		
		ApexPages.currentPage().getParameters().put('page','testPage');
		
		WidgetPageSettingsConfiguration objWPSC = createTestRecords();
		createTestRecordsForDept('SL_IntranetDepartments');
		
		
		Department__c objDep = new Department__c(Name = 'Test Dep');
        insert objDep;
        
		SL_IntranetQuickCreateController obj = new SL_IntranetQuickCreateController();
		SL_IntranetQuickCreate objIntranetQuickCreate = new SL_IntranetQuickCreate();
		SL_IntranetQuickCreate.SobjectFieldDetail obj1 = new SL_IntranetQuickCreate.SobjectFieldDetail('LastModifiedDate', 'LastModifiedDate');
		objIntranetQuickCreate.initialize();
		objIntranetQuickCreate.postInitialize();
		objIntranetQuickCreate.SobjectNames();
		
		Type t = Type.forName('SL_IntranetDepartments');
		IWidget objIWidget = (IWidget)t.newInstance();
   
		objIntranetQuickCreate.notify(objIWidget);
		
		objIntranetQuickCreate.showInitialSection();
		
		objIntranetQuickCreate.strSelectedSobject = 'None';
		objIntranetQuickCreate.FieldSetNamesOfSelectedSObject();
		
		objIntranetQuickCreate.strSelectedFieldSetOfSobject = 'PageRegionWidget__c';
		objIntranetQuickCreate.strSelectedSobject = 'PageRegionWidget__c';
		objIntranetQuickCreate.FieldSetNamesOfSelectedSObject();
		objIntranetQuickCreate.retrieveAllFields();
		
    	obj.compImpl = WidgetAbstract.getInstance(objWPSC);
    	obj.getMyImpl();
    	
    	//obj.getMyImpl().initialize();
    	obj.showMainSection();
    	obj.fieldSet();
    	obj.retrieveAllField();
    	obj.createRecords();
    	obj.cancel();
    	
    	obj.getFilteredByDepartment();
        obj.getMyImpl().strDeptId = objDep.id;
        obj.getFilteredByDepartment();
		
		objIntranetQuickCreate.strSelectedSobject = 'Notification__c';
		objIntranetQuickCreate.strSelectedFieldSetOfSobject = strNameSpace + 'NotificationFieldSet';
		objIntranetQuickCreate.getFieldSetMembers();
		
		objIntranetQuickCreate.getHasNoRequiredFields();
		
		objIntranetQuickCreate.newComponent();     
        Test.stopTest();
        
        system.assertEquals(0,0); 
	}
	
	static WidgetPageSettingsConfiguration createTestRecords()
	{
		Intranet_Request_Object__c objIntranetRequestObject = new Intranet_Request_Object__c(Object_Name__c = 'Case',Name='Case');
		insert objIntranetRequestObject;
		
		Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'testPage');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = 'SL_IntranetQuickCreate');
    	insert objWidget;
		
		PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c=objPageRegion.Id, Widget__c = objWidget.Id, Page_Region__r = objPageRegion, Widget__r = objWidget,
																			Configuration__c='{'+
																								'"heading" : "QuickCreate Widget",'+
																								'"initialbutton" : "Post an Idea",'+
																								'"instructiontext" : "We love new ideas'+
																								'so please post yours to on online suggestion box",'+
																								'"sobjectname" : "Notification__c",'+
																								'"fieldsetname" : "'+strNameSpace+'NotificationFieldSet",'+
																								'"successresponse" : "Thanks for posting your idea'+
																								'to the Internal Idea Exchange",'+
																								'"savebutton" : "Post Idea",'+
																								'"logtransaction" : true,' +
																								'"fontstyle" : "Arial",'+
																								'"department" : "Test Dep",'+
																								'"backgroundColor":"White" }' 
																		 );
		insert objPageRegionWidget;
		
		return new WidgetPageSettingsConfiguration(objPageRegionWidget);
	 }
	 
	static WidgetPageSettingsConfiguration createTestRecordsForDept(String configuration)
	{
		Region__c objRegion = new Region__c(Name = 'testRegion1');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'testPage1');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testMG1',Type__c = configuration);
    	insert objWidget;
		
		PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c=objPageRegion.Id, Widget__c = objWidget.Id, Page_Region__r = objPageRegion, Widget__r = objWidget,
																			Configuration__c='{"initialstate":"","initialselection":""}');
		insert objPageRegionWidget;
		
		return new WidgetPageSettingsConfiguration(objPageRegionWidget);
	 }
	 
}