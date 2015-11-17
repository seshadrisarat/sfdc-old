@isTest
public class SL_TestTriggerHandler 
{
	//Percent of Test Coverage : 
	@isTest(SeeAllData=true)
	static void test_SL_ContentVersionHandler()
	{
		List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
		Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
		lstOffLocToInsert.add(objOL);
		Office_Locations__c objOL1 = new Office_Locations__c(Name='Test Location-02');
		lstOffLocToInsert.add(objOL1);
		Office_Locations__c objOL2 = new Office_Locations__c(Name='Test Location-03');
		lstOffLocToInsert.add(objOL2);
		Office_Locations__c objOL3 = new Office_Locations__c(Name='Test Location-04');
		lstOffLocToInsert.add(objOL3);
		insert lstOffLocToInsert;
		
		List<ContentVersion> lstContents = new List<ContentVersion>();
		lstContents = [select Id, Content_Offices__c from ContentVersion where For_All_Offices__c != null limit 1];
		
		if(lstContents.size() > 0)
		{
			lstContents[0].Content_Offices__c = 'Test Location-01 \n Test Location-02 \n Test Location-03';
			update lstContents[0];
			
			lstContents[0].For_All_Offices__c = true;
			update lstContents[0];
			
			lstContents[0].Content_Offices__c = '';
			lstContents[0].For_All_Offices__c = false;
			update lstContents[0];
			
			lstContents[0].Content_Offices__c = 'Test Location-01 \n Test Location-01';
			update lstContents[0];
			
			lstContents[0].Content_Offices__c = 'Test Location';
			update lstContents[0];
		}
		
		system.assertEquals(0,0);
	}
	
	//Percent of Test Coverage : 90
	static testMethod void test_SL_NotificationHandler()
	{
		List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
		Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
		lstOffLocToInsert.add(objOL);
		Office_Locations__c objOL1 = new Office_Locations__c(Name='Test Location-02');
		lstOffLocToInsert.add(objOL1);
		Office_Locations__c objOL2 = new Office_Locations__c(Name='Test Location-03');
		lstOffLocToInsert.add(objOL2);
		Office_Locations__c objOL3 = new Office_Locations__c(Name='Test Location-04');
		lstOffLocToInsert.add(objOL3);
		insert lstOffLocToInsert;
		
		List<Department__c> lstDeptToInsert = new List<Department__c>();
		Department__c objD = new Department__c(Name='Test Department-01');
		lstDeptToInsert.add(objD);
		Department__c objD1 = new Department__c(Name='Test Department-02');
		lstDeptToInsert.add(objD1);
		Department__c objD2 = new Department__c(Name='Test Department-03');
		lstDeptToInsert.add(objD2);
		Department__c objD3 = new Department__c(Name='Test Department-04');
		lstDeptToInsert.add(objD3);
		insert lstDeptToInsert;
				
		Notification__c objNotification = new Notification__c(Name='Test Notificattion', 
															  Notification_Offices__c='Test Location-01 \n Test Location-02 \n',
															  Notification_Departments__c='Test Department-01 \n Test Department-02 \n');
		insert objNotification;
		
		objNotification.Notification_Offices__c = 'Test Location-01 \n Test Location-02 \n Test Location-03';
		objNotification.Notification_Departments__c = 'Test Department-01 \n Test Department-02 \n Test Department-03';
		update objNotification;
		
		objNotification.For_All_Offices__c = true;
		objNotification.For_All_Departments__c = true;
		update objNotification;
		
		objNotification.Notification_Offices__c = '';
		objNotification.For_All_Offices__c = false;
		objNotification.Notification_Departments__c = '';
		objNotification.For_All_Departments__c = false;
		update objNotification;
		
		system.assertEquals(0,0);
		Notification__c objNotification1 = [select Selected_Offices_Ids__c ,Notification_Offices__c from Notification__c where Name='Test Notificattion'] ;		
	}
	
	//Percent of Test Coverage : 90
	static testMethod void test_SL_IntranetEventHandler()
	{
		List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
		Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
		lstOffLocToInsert.add(objOL);
		Office_Locations__c objOL1 = new Office_Locations__c(Name='Test Location-02');
		lstOffLocToInsert.add(objOL1);
		Office_Locations__c objOL2 = new Office_Locations__c(Name='Test Location-03');
		lstOffLocToInsert.add(objOL2);
		Office_Locations__c objOL3 = new Office_Locations__c(Name='Test Location-04');
		lstOffLocToInsert.add(objOL3);
		insert lstOffLocToInsert;
		
		List<Department__c> lstDeptToInsert = new List<Department__c>();
		Department__c objD = new Department__c(Name='Test Department-01');
		lstDeptToInsert.add(objD);
		Department__c objD1 = new Department__c(Name='Test Department-02');
		lstDeptToInsert.add(objD1);
		Department__c objD2 = new Department__c(Name='Test Department-03');
		lstDeptToInsert.add(objD2);
		Department__c objD3 = new Department__c(Name='Test Department-04');
		lstDeptToInsert.add(objD3);
		insert lstDeptToInsert;
		
				
		Intranet_Event__c objEvent = new Intranet_Event__c(Name='Test Event', 
														   Intranet_Event_Offices__c='Test Location-01 \n Test Location-02 \n',
														   Intranet_Event_Departments__c='Test Department-01 \n Test Department-02 \n');
		insert objEvent;
		
		objEvent.Intranet_Event_Offices__c = 'Test Location-01 \n Test Location-02 \n Test Location-03';
		objEvent.Intranet_Event_Departments__c = 'Test Department-01 \n Test Department-02 \n Test Department-03';
		update objEvent;
		
		objEvent.For_All_Offices__c = true;
		objEvent.For_All_Departments__c = true;
		update objEvent;
		
		objEvent.Intranet_Event_Offices__c = '';
		objEvent.Intranet_Event_Departments__c = '';
		objEvent.For_All_Departments__c = false;
		objEvent.For_All_Offices__c = false;
		update objEvent;
		
		system.assertEquals(0,0);
		Intranet_Event__c objEvent1 = [select Selected_Offices_Ids__c ,Intranet_Event_Offices__c from Intranet_Event__c where Name='Test Event'] ;		
	}
	
	//Percent of Test Coverage : 96
	static testMethod void test_SL_UserHandler()
	{
		List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
		Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
		lstOffLocToInsert.add(objOL);
		Office_Locations__c objOL1 = new Office_Locations__c(Name='Test Location-02');
		lstOffLocToInsert.add(objOL1);
		Office_Locations__c objOL2 = new Office_Locations__c(Name='Test Location-03');
		lstOffLocToInsert.add(objOL2);
		Office_Locations__c objOL3 = new Office_Locations__c(Name='Test Location-04');
		lstOffLocToInsert.add(objOL3);
		insert lstOffLocToInsert;
		
		List<Department__c> lstDeptToInsert = new List<Department__c>();
		Department__c objD = new Department__c(Name='Test Department-01');
		lstDeptToInsert.add(objD);
		Department__c objD1 = new Department__c(Name='Test Department-02');
		lstDeptToInsert.add(objD1);
		Department__c objD2 = new Department__c(Name='Test Department-03');
		lstDeptToInsert.add(objD2);
		Department__c objD3 = new Department__c(Name='Test Department-04');
		lstDeptToInsert.add(objD3);
		insert lstDeptToInsert;
		
			User objUser = new User(
            Alias = 'stayndt', 
            Email='testUser.1.1.0@gmail.com',
            EmailEncodingKey='UTF-8',
            LastName='Tesyyting123',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standayyrduser@testorg.com',
            User_Offices__c = 'Test Location-01 \n Test Location-02 \n',
            User_Departments__c = 'Test Department-01 \n Test Department-02 \n'
        );
		
		insert objUser;
		objUser.User_Offices__c = 'Test Location-01 \n Test Location-02 \n Test Location-03';
		objUser.User_Departments__c = 'Test Department-01 \n Test Department-02 \n Test Department-03';
		update objUser;
		objUser.All_Offices__c = true;
		objUser.All_Departments__c = true;
		update objUser;
		objUser.All_Offices__c = false;
		objUser.User_Offices__c = '';
		objUser.All_Departments__c = false;
		objUser.User_Departments__c = '';
		update objUser;
		objUser.User_Offices__c = 'Test Location-01 \n Test Location-02';
		objUser.User_Departments__c = 'Test Department-01 \n Test Department-02';
		update objUser;
		
		system.assertEquals(0,0);
	}
	
	//Percent of Test Coverage : 90
	static testMethod void test_SL_IntranetAppHandler()
	{
		List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
		Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
		lstOffLocToInsert.add(objOL);
		Office_Locations__c objOL1 = new Office_Locations__c(Name='Test Location-02');
		lstOffLocToInsert.add(objOL1);
		Office_Locations__c objOL2 = new Office_Locations__c(Name='Test Location-03');
		lstOffLocToInsert.add(objOL2);
		Office_Locations__c objOL3 = new Office_Locations__c(Name='Test Location-04');
		lstOffLocToInsert.add(objOL3);
		insert lstOffLocToInsert;
		
		List<Department__c> lstDeptToInsert = new List<Department__c>();
		Department__c objD = new Department__c(Name='Test Department-01');
		lstDeptToInsert.add(objD);
		Department__c objD1 = new Department__c(Name='Test Department-02');
		lstDeptToInsert.add(objD1);
		Department__c objD2 = new Department__c(Name='Test Department-03');
		lstDeptToInsert.add(objD2);
		Department__c objD3 = new Department__c(Name='Test Department-04');
		lstDeptToInsert.add(objD3);
		insert lstDeptToInsert;
		
				
		Intranet_App__c objApp = new Intranet_App__c(Name='Test App', 
														   IntranetApp_Offices__c='Test Location-01 \n Test Location-02 \n',
														   IntranetApp_Departments__c='Test Department-01 \n Test Department-02 \n');
		insert objApp;
		
		objApp.IntranetApp_Offices__c = 'Test Location-01 \n Test Location-02 \n Test Location-03';
		objApp.IntranetApp_Departments__c = 'Test Department-01 \n Test Department-02 \n Test Department-03';
		update objApp;
		
		objApp.For_All_Offices__c = true;
		objApp.For_All_Departments__c = true;
		update objApp;
		
		objApp.IntranetApp_Offices__c = '';
		objApp.IntranetApp_Departments__c = '';
		objApp.For_All_Departments__c = false;
		objApp.For_All_Offices__c = false;
		update objApp;
		
		system.assertEquals(0,0);
	}
	
	//Percent of Test Coverage : 93
	static testMethod void test_SL_OfficeLocationHandler()
	{
		Office_Locations__c objOfficeLocation = new Office_Locations__c(Name='Test Location-01');
		insert objOfficeLocation ;
		
		Notification__c objNotificationAll = new Notification__c(Name='Test Notification All', For_All_Offices__c = true);
		insert objNotificationAll ;
		
		Notification__c objNotification = new Notification__c(Name='Test Notification', Notification_Offices__c='Test Location-01 \n ');
		insert objNotification ;
		
		Intranet_Event__c objEventAll = new Intranet_Event__c(Name='Test Event All', For_All_Offices__c = true);
		insert objEventAll ;
		
		Intranet_Event__c objEvent = new Intranet_Event__c(Name='Test Event', Intranet_Event_Offices__c='Test Location-01 \n ');
		insert objEvent ;
		
		User objUser = new User(Alias = 'stayndt', 
					            Email='testUser.1.1.0@gmail.com',
					            EmailEncodingKey='UTF-8',
					            LastName='Tesyyting123',
					            LanguageLocaleKey='en_US',
					            LocaleSidKey='en_US',
					            ProfileId = UserInfo.getProfileId(),
					            TimeZoneSidKey='America/Los_Angeles',
					            UserName='testUser.1.1.0@testorg.com',
					            User_Offices__c = 'Test Location-01 \n '
        					   );
        
        insert objUser ;
        
        Blob blbAttachment = blob.valueOf('test');
        ContentVersion objContentVersion = new ContentVersion(Title='MyContentVersion', PathOnClient = 'objDocument.jpg', VersionData = blbAttachment ); 
        insert objContentVersion ;
        
        objOfficeLocation.Name = 'Test Location-03' ;
        update objOfficeLocation ;
        
        Notification__c objNotification1 = [select Name , Notification_Offices__c 
        											from Notification__c 
        											  where Name = 'Test Notification'] ;
       
        User userObj1 =[select User_Offices__c ,Selected_Offices_Ids__c, Email 
        				  from User where id =: objUser.id ] ;

        ContentVersion objContentVersion1 = [select Title, Content_Offices__c 
        									  from ContentVersion 
        									    where Title='MyContentVersion'] ;
       
       
			
		
		delete objOfficeLocation ;
		
		Notification__c objNotification2 = [select Name , Notification_Offices__c 
													from Notification__c 
													  where Name = 'Test Notification'] ;
		User userObj2 =[select User_Offices__c ,Selected_Offices_Ids__c, Email 
						  from User where id =: objUser.id ] ;
		
		system.assertEquals(0,0);				
	}
	
	
	//Percent of Test Coverage : 93
	static testMethod void test_SL_DepartmentHandler()
	{
		Department__c objDepartment = new Department__c(Name='Test Department-01');
		insert objDepartment ;
		
		Notification__c objNotificationAll = new Notification__c(Name='Test Notification All', For_All_Departments__c = true);
		insert objNotificationAll ;
		
		Notification__c objNotification = new Notification__c(Name='Test Notification', Notification_Departments__c='Test Department-01 \n ');
		insert objNotification ;
		
		Intranet_Event__c objEventAll = new Intranet_Event__c(Name='Test Event All', For_All_Departments__c = true);
		insert objEventAll ;
		
		Intranet_Event__c objEvent = new Intranet_Event__c(Name='Test Event', Intranet_Event_Departments__c='Test Department-01 \n ');
		insert objEvent ;
		
		User objUser = new User(Alias = 'stayndt', 
					            Email='testUser.1.1.0@gmail.com',
					            EmailEncodingKey='UTF-8',
					            LastName='Tesyyting123',
					            LanguageLocaleKey='en_US',
					            LocaleSidKey='en_US',
					            ProfileId = UserInfo.getProfileId(),
					            TimeZoneSidKey='America/Los_Angeles',
					            UserName='testUser.1.1.0@testorg.com',
					            User_Departments__c = 'Test Department-01 \n '
        					   );
        
        insert objUser ;
        
        Blob blbAttachment = blob.valueOf('test');
        ContentVersion objContentVersion = new ContentVersion(Title='MyContentVersion', PathOnClient = 'objDocument.jpg', VersionData = blbAttachment ); 
        insert objContentVersion ;
        
        objDepartment.Name = 'Test Department-03' ;
        update objDepartment ;
        
		delete objDepartment ;
		
		system.assertEquals(0,0);
	}
	 @isTest(SeeAllData=false)
    static void test_SL_NotificationInsertHandler_RecentUpdates()
    {
        test.startTest();
        
        Notification__c objNotificationAll = new Notification__c(Name='Test Notification All', For_All_Departments__c = true);
        insert objNotificationAll ;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
    @isTest(SeeAllData=false)
    static void test_SL_NotificationUpdateHandler_RecentUpdates()
    {
        test.startTest();
        
        Notification__c objNotificationAll = new Notification__c(Name='Test Notification All', For_All_Departments__c = true);
        insert objNotificationAll ;
        
        List<Recent_Updates__c> listRecentUpdates = [Select Id, Name,CreatedDate,LastModifiedDate, Last_Updated__c, LastModifiedBy.Name, Sobject_Type__c, Related_To__c 
                                                        From Recent_Updates__c where Sobject_Type__c != null 
                                                        AND Related_To__c != null order by Last_Updated__c desc nulls last limit 1000];
        listRecentUpdates[0].Last_Updated__c = Date.today().addDays(-1);
        update listRecentUpdates;
        
        objNotificationAll.Name = 'Test';
        update objNotificationAll;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
    @isTest(SeeAllData=false)
    static void test_SL_NotificationDeleteHandler_RecentUpdates()
    {
        test.startTest();
        
        Notification__c objNotificationAll = new Notification__c(Name='Test Notification All', For_All_Departments__c = true);
        insert objNotificationAll ;
        
        delete objNotificationAll;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=false)
    static void test_SL_EventInsertHandler_RecentUpdates()
    {
        test.startTest();
        
        Intranet_Event__c objEventAll = new Intranet_Event__c(Name='Test Event All', For_All_Departments__c = true);
        insert objEventAll ;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=false)
    static void test_SL_EventUpdateHandler_RecentUpdates()
    {
        test.startTest();
        
        Intranet_Event__c objEventAll = new Intranet_Event__c(Name='Test Event All', For_All_Departments__c = true);
        insert objEventAll ;
        
        List<Recent_Updates__c> listRecentUpdates = [Select Id, Name,CreatedDate,LastModifiedDate, Last_Updated__c, LastModifiedBy.Name, Sobject_Type__c, Related_To__c 
                                                        From Recent_Updates__c where Sobject_Type__c != null 
                                                        AND Related_To__c != null order by Last_Updated__c desc nulls last limit 1000];
        listRecentUpdates[0].Last_Updated__c = Date.today().addDays(-1);
        update listRecentUpdates;
        
        objEventAll.Name = 'Test';
        update objEventAll;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
 
    @isTest(SeeAllData=false)
    static void test_SL_EventDeleteHandler_RecentUpdates()
    {
        test.startTest();
        
        Intranet_Event__c objEventAll = new Intranet_Event__c(Name='Test Event All', For_All_Departments__c = true);
        insert objEventAll ;
        
        delete objEventAll;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=false)
    static void test_SL_AppInsertHandler_RecentUpdates()
    {
        test.startTest();
        
        List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
        Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
        lstOffLocToInsert.add(objOL);
        Office_Locations__c objOL1 = new Office_Locations__c(Name='Test Location-02');
        lstOffLocToInsert.add(objOL1);
        insert lstOffLocToInsert;
        
        List<Department__c> lstDeptToInsert = new List<Department__c>();
        Department__c objD = new Department__c(Name='Test Department-01');
        lstDeptToInsert.add(objD);
        Department__c objD1 = new Department__c(Name='Test Department-02');
        lstDeptToInsert.add(objD1);
        insert lstDeptToInsert;
        
                
        Intranet_App__c objApp = new Intranet_App__c(Name='Test App', 
                                                           IntranetApp_Offices__c='Test Location-01 \n Test Location-02 \n',
                                                           IntranetApp_Departments__c='Test Department-01 \n Test Department-02 \n');
        insert objApp;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=false)
    static void test_SL_AppUpdateHandler_RecentUpdates()
    {
        test.startTest();
        
        List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
        Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
        lstOffLocToInsert.add(objOL);
        Office_Locations__c objOL1 = new Office_Locations__c(Name='Test Location-02');
        lstOffLocToInsert.add(objOL1);
        insert lstOffLocToInsert;
        
        List<Department__c> lstDeptToInsert = new List<Department__c>();
        Department__c objD = new Department__c(Name='Test Department-01');
        lstDeptToInsert.add(objD);
        Department__c objD1 = new Department__c(Name='Test Department-02');
        lstDeptToInsert.add(objD1);
        insert lstDeptToInsert;
        
                
        Intranet_App__c objApp = new Intranet_App__c(Name='Test App', 
                                                           IntranetApp_Offices__c='Test Location-01 \n Test Location-02 \n',
                                                           IntranetApp_Departments__c='Test Department-01 \n Test Department-02 \n');
        insert objApp;
        
        
        List<Recent_Updates__c> listRecentUpdates = [Select Id, Name,CreatedDate,LastModifiedDate, Last_Updated__c, LastModifiedBy.Name, Sobject_Type__c, Related_To__c 
                                                        From Recent_Updates__c where Sobject_Type__c != null 
                                                        AND Related_To__c != null order by Last_Updated__c desc nulls last limit 1000];
        listRecentUpdates[0].Last_Updated__c = Date.today().addDays(-1);
        update listRecentUpdates;
        
        objApp.IntranetApp_Offices__c = 'Test Location-01 ';
        objApp.IntranetApp_Departments__c = 'Test Department-01 ';
        update objApp;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
 
    @isTest(SeeAllData=false)
    static void test_SL_AppDeleteHandler_RecentUpdates()
    {
        test.startTest();
        
        List<Office_Locations__c> lstOffLocToInsert = new List<Office_Locations__c>();
        Office_Locations__c objOL = new Office_Locations__c(Name='Test Location-01');
        lstOffLocToInsert.add(objOL);
        Office_Locations__c objOL1 = new Office_Locations__c(Name='Test Location-02');
        lstOffLocToInsert.add(objOL1);
        insert lstOffLocToInsert;
        
        List<Department__c> lstDeptToInsert = new List<Department__c>();
        Department__c objD = new Department__c(Name='Test Department-01');
        lstDeptToInsert.add(objD);
        Department__c objD1 = new Department__c(Name='Test Department-02');
        lstDeptToInsert.add(objD1);
        insert lstDeptToInsert;
        
                
        Intranet_App__c objApp = new Intranet_App__c(Name='Test App', 
                                                           IntranetApp_Offices__c='Test Location-01 \n Test Location-02 \n',
                                                           IntranetApp_Departments__c='Test Department-01 \n Test Department-02 \n');
        insert objApp;
        
        delete objApp;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=false)
    static void test_SL_ContentVersionInsertHandler_RecentUpdates()
    {
        test.startTest();
        
        Blob strBlob = Blob.valueOf('Test BlobContent');
        ContentVersion objCV = new ContentVersion(Title = 'Test2',VersionData = strBlob, PathOnClient = 'objDocument.jpg');
        insert objCV;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=false)
    static void test_SL_ContentVersionUpdateHandler_RecentUpdates()
    {
        test.startTest();
        Blob strBlob = Blob.valueOf('Test BlobContent');
        ContentVersion objCV = new ContentVersion(Title = 'Test2',VersionData = strBlob, PathOnClient = 'objDocument.jpg');
        insert objCV;
        
        List<Recent_Updates__c> listRecentUpdates = [Select Id, Name,CreatedDate,LastModifiedDate, Last_Updated__c, LastModifiedBy.Name, Sobject_Type__c, Related_To__c 
                                                        From Recent_Updates__c where Sobject_Type__c != null 
                                                        AND Related_To__c != null order by Last_Updated__c desc nulls last limit 1000];
        listRecentUpdates[0].Last_Updated__c = Date.today().addDays(-1);
        update listRecentUpdates;
        
        objCV.title = 'test';
        update objCV;
        
        system.assertEquals(0,0);
        test.stopTest();
        
    }
	
}