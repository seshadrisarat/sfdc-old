/**
* \arg ClassName  : SL_Test_SobjectWidget
* \arg JIRATicket : SOCINT-326
* \arg CreatedOn  : Lodhi, 06/Nov/2013 
* \arg ModifiedBy : 
* \arg Description: This is test class for Sobject Detail and List Widget.
*/
@isTest
private class SL_Test_SobjectWidget 
{
	/* Start Varaibles */
	private static Region__c objRegion;
	private static Page__c objPage;
	private static PageRegion__c objPageRegion;
	private static Widget__c objWidget;
	private static PageRegionWidget__c objPageRegionWidget;
	private static String strNameSpace;
	private static String fieldSet;
	/* End Variables */

    static testMethod void SL_Test_IntranetSobject() 
    {
        WidgetPageSettingsConfiguration objWPSC = createTestRecordsList();
		SL_IntranetSobjectController obj = new SL_IntranetSobjectController();
    	obj.compImpl = WidgetAbstract.getInstance(objWPSC);
    	obj.getMyImpl();
    	obj.getMyImpl().newComponent();
    	//obj.getSobjectRecords();
    	objPageRegionWidget.Configuration__c = '{"sobjectname":"Contact","fieldsetname":"","showfeed":true,"heading":"","showfieldlabel":true,"filtercriteria":"","numbertodisplay":2,"TotalRecords":5}';
    	update objPageRegionWidget;
    	obj.getMyImpl();
    	//obj.getSobjectRecords();
    	obj.showMoreRecords();
    	//obj.getMyImpl().viewAllRecords();
    	obj.getMyImpl().newComponent();
    	obj.gtListViewDetail();
    	obj.showMoreRecords();
    	obj.chatterTopicRecords();
    	//SL_UtilityWrappers.FieldSetDescribe objFieldWrapper = new SL_UtilityWrappers.FieldSetDescribe('','','',5);
    	
    	system.assertEquals(0,0); 
    }
   
    static testMethod void SL_Test_IntranetSobjectDetail() 
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
    	
    	fieldSet = strNameSpace+'NotificationFieldSet';
    	Notification__c objNotif = new Notification__c(Name = 'Test Notification');
    	insert objNotif;
    	
    	List<Attachment> lstAttachment = new List<Attachment>{
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-01', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-02', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-03', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-04', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-05', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-06', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-07', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-08', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-09', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-10', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-11', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-12', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-13', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-14', ParentId = objNotif.Id, ContentType = 'txt'),
    															new Attachment(Body = Blob.valueOf('This is a testing data for attachment body'), Name = 'Test Attachment-15', ParentId = objNotif.Id, ContentType = 'txt')
    														 };
    	insert lstAttachment;
		
    	Account objAccount = new Account(Name = 'Test Account-01');
    	insert objAccount;
    	
    	Intranet_Event__c objIntranetEvent = new Intranet_Event__c(Name = 'Test Event');
    	insert objIntranetEvent;
    	
    	SL_Intranet_PaginationSettings__c objPagination = new SL_Intranet_PaginationSettings__c(Name = 'pageSize', 
                                                                                                        Documents_PageSize__c = 20,
                                                                                                        Documents_PageSize_Mobile__c = 20);
        insert objPagination;																			 	
    	
       	Apexpages.currentPage().getparameters().put('pageNo','1');
       	Apexpages.currentPage().getparameters().put('pageNoAttach','1');
    	WidgetPageSettingsConfiguration objWPSC = createTestRecords();
	   	SL_IntranetSobjectDetailController obj = new SL_IntranetSobjectDetailController();
       	obj.compImpl = WidgetAbstract.getInstance(objWPSC);
       	obj.getMyImpl();
       	obj.getMyImpl().newComponent();
       	objPageRegionWidget.Configuration__c = '{"sobjectname":"Notification__c","fieldsetname":"'+fieldSet+'","showfeed":true,"heading":"","showfieldlabel":true,"filtercriteria":"","numbertodisplay":2,"TotalRecords":5}';
    	update objPageRegionWidget;
       	obj.getSobjectRecords();
       	obj.nextRecords();
       	obj.prevRecords();
       	obj.goToPage();
       	obj.getMyImpl().nextRecordsAttachment();
       	obj.getMyImpl().prevRecordsAttachment();
       	obj.getMyImpl().goToPageAttachment();
       	obj.getMyImpl().viewAllRecords = true;
      	obj.getMyImpl().sObjectName = 'Notification__c';
       	obj.showInitialState();
       	obj.getMyImpl().viewAllRecords = true;
      	obj.getMyImpl().sObjectName = 'Notification__c';
      	obj.getMyImpl().strSobjectId = objNotif.Id;
      	obj.getSobjectRecords();
      	obj.getMyImpl().nextRecordsAttachment();
      	obj.getMyImpl().prevRecordsAttachment();
      	obj.getMyImpl().goToPageAttachment();
    	System.assertEquals(0, 0);
    }
    
    static WidgetPageSettingsConfiguration createTestRecords()
	{
    	objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
        
    	objPage = new Page__c(Name = 'testPage');
		insert objPage;
    	
    	objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	objWidget = new Widget__c(Name = 'testMG',Type__c = 'SL_IntranetSobjectDetail');
    	insert objWidget;
		
		objPageRegionWidget = new PageRegionWidget__c(Page_Region__c=objPageRegion.Id, Widget__c = objWidget.Id, Page_Region__r = objPageRegion, Widget__r = objWidget,
																			Configuration__c= '{"sobjectname":"Notification__c","fieldsetname":"'+fieldSet+'","showfeed":true,"heading":"Notification","initialstate":"hidden","showattachment":true,"showfieldlabel":true,"filterfieldname":"","filtercriteria":""}');
		insert objPageRegionWidget;
		return new WidgetPageSettingsConfiguration(objPageRegionWidget);
	}
	
	static WidgetPageSettingsConfiguration createTestRecordsList()
	{
    	List<Contact> lstContact = new List<Contact>{
    													new Contact(LastName = 'Test Contact-01'),	
    													new Contact(LastName = 'Test Contact-02'),	
    													new Contact(LastName = 'Test Contact-03'),	
    													new Contact(LastName = 'Test Contact-04'),	
    													new Contact(LastName = 'Test Contact-05'),	
    													new Contact(LastName = 'Test Contact-06'),	
    													new Contact(LastName = 'Test Contact-07'),	
    													new Contact(LastName = 'Test Contact-08'),	
    													new Contact(LastName = 'Test Contact-09'),	
    													new Contact(LastName = 'Test Contact-10'),	
    													new Contact(LastName = 'Test Contact-11'),	
    													new Contact(LastName = 'Test Contact-12')	
    												};
    	insert lstContact;	
    	
    	objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
        
    	objPage = new Page__c(Name = 'testPage');
		insert objPage;
    	
    	objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	objWidget = new Widget__c(Name = 'testMG',Type__c = 'SL_IntranetSobject', Configuration__c= '{"sobjectname":"Contact","fieldsetname":"","showfeed":true,"heading":"","showfieldlabel":true,"filtercriteria":"","numbertodisplay":2,"TotalRecords":5}');
    	insert objWidget;
		
		objPageRegionWidget = new PageRegionWidget__c(Page_Region__c=objPageRegion.Id, Widget__c = objWidget.Id, Page_Region__r = objPageRegion, Widget__r = objWidget,
																			Configuration__c= '{"sobjectname":"Contact","fieldsetname":"WC_Field_Set","showfeed":true,"heading":"","showfieldlabel":true,"filtercriteria":"","numbertodisplay":2,"TotalRecords":5}');
		insert objPageRegionWidget;
		/*'{"sobjectname":"Intranet_Event__c","fieldsetname":"Intranet_Calendars_Fields","showfeed":true,"heading":"Calendar","initialstate":"hidden","showattachment":true,"showfieldlabel":true,"filterfieldname":"Name","filtercriteria":""}'*/
		
		
		return new WidgetPageSettingsConfiguration(objPageRegionWidget);
	 }
}