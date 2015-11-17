@isTest
private class SL_Test_ProjectAssetHandler 
{
    static testMethod void unitTest() 
    {
    	Project__c objSLProject = new Project__c(Name = 'SL-Project', Classification__c = 'Sales Cloud;Service Cloud', Estimated_Start_Date__c = date.today());
		insert objSLProject;
		
		objSLProject = new Project__c(Id = objSLProject.Id, Classification__c = 'Force.com');
		update objSLProject;
		
		Project__c objSLProject1 = new Project__c(Name = 'SL-Project1', Classification__c = '', Estimated_Start_Date__c = date.today());
		insert objSLProject1;
		
		objSLProject1 = new Project__c(Id = objSLProject1.Id, Classification__c = 'Force.com;Service Cloud');
		update objSLProject1;

		Project__c objSLProject2 = new Project__c(Name = 'SL-Project2', Classification__c = 'Service Cloud', Estimated_Start_Date__c = date.today());
		insert objSLProject2;
		
		objSLProject2 = new Project__c(Id = objSLProject1.Id, Classification__c = '');
		update objSLProject2;
		
		delete objSLProject1;
		undelete objSLProject1;
    	
		List<Topic> lstTopic = new List<Topic>();
		for(Integer i = 0; i <= 15; i++)
		{
			lstTopic.add(new Topic(Name = 'Topic - ' +i));   
		}       
		insert lstTopic;
		
		List<Library_Topic__c> lstLibraryTopic = new List<Library_Topic__c>{new Library_Topic__c(Name = 'Visualforce Pages', Topic_ID__c = lstTopic[0].Id),
																			new Library_Topic__c(Name = 'Boomi', Topic_ID__c = lstTopic[1].Id),
																			new Library_Topic__c(Name = 'CalendarAnything', Topic_ID__c = lstTopic[2].Id),
																			new Library_Topic__c(Name = 'Professional Edition', Topic_ID__c = lstTopic[3].Id),
																			new Library_Topic__c(Name = 'Email Integration - LinkPoint', Topic_ID__c = lstTopic[4].Id),
																			new Library_Topic__c(Name = 'Batch Updates', Topic_ID__c = lstTopic[5].Id),
																			new Library_Topic__c(Name = 'Customer Community', Topic_ID__c = lstTopic[6].Id),
																			new Library_Topic__c(Name = 'Accounts and Contacts', Topic_ID__c = lstTopic[7].Id),
													 						new Library_Topic__c(Name = 'Microsoft Dynamics', Topic_ID__c = lstTopic[8].Id),
																			new Library_Topic__c(Name = 'Dashboards', Topic_ID__c = lstTopic[9].Id),
																			new Library_Topic__c(Name = 'Cases', Topic_ID__c = lstTopic[10].Id),
																			new Library_Topic__c(Name = 'Saleslogix', Topic_ID__c = lstTopic[11].Id),
																			new Library_Topic__c(Name = 'Force.com', Topic_ID__c = lstTopic[12].Id),
																			new Library_Topic__c(Name = 'Service Cloud', Topic_ID__c = lstTopic[13].Id),
																			new Library_Topic__c(Name = 'Sales Cloud', Topic_ID__c = lstTopic[14].Id)};
		insert lstLibraryTopic;
		
		Project_Asset__c objProjectAsset = new Project_Asset__c(SL_Project__c = objSLProject.Id, Custom_Dev_Type__c = 'Visualforce Pages;Batch Updates', Integration_Tools__c = 'Boomi;Cast Iron',
																Legacy_Systems__c = 'Microsoft Dynamics', Silverline_Product__c = 'CalendarAnything', Vendor__c = 'Email Integration - LinkPoint;Email Integration - Riva',
																Salesforce_Product__c = 'Customer Community', Salesforce_Features__c = 'Accounts and Contacts', Miscellaneous__c = 'Dashboards;Reports');
		insert objProjectAsset;	
		
		Project_Asset__c objProjectAsset1 = new Project_Asset__c(SL_Project__c = objSLProject.Id, Integration_Tools__c = 'Cast Iron',
																Legacy_Systems__c = 'Saleslogix', Silverline_Product__c = 'CalendarAnything', Vendor__c = 'Email Integration - Riva',
																Salesforce_Features__c = 'Accounts and Contacts', Miscellaneous__c = 'Reports', Salesforce_License_Type__c = 'Chatter Free');
		insert objProjectAsset1;
		
		Project_Asset__c objProjectAsset2 = new Project_Asset__c(SL_Project__c = objSLProject.Id, Custom_Dev_Type__c = 'Batch Updates', 
																Silverline_Product__c = 'CalendarAnything', Vendor__c = 'Email Integration - Riva',
																Salesforce_Product__c = 'Customer Community', Salesforce_Features__c = 'Accounts and Contacts', Salesforce_License_Type__c = 'Chatter Free');
		insert objProjectAsset2;														
		
		objProjectAsset = new Project_Asset__c(Id = objProjectAsset.Id, Custom_Dev_Type__c = 'Batch Updates', Integration_Tools__c = '', Legacy_Systems__c = 'Saleslogix;Microsoft Dynamics',
											   Silverline_Product__c = 'The WaterCooler', Salesforce_Features__c = 'Accounts and Contacts;Chatter; Cases', Salesforce_License_Type__c = 'Professional Edition', Miscellaneous__c = '');
		update objProjectAsset;

		objProjectAsset1 = new Project_Asset__c(Id = objProjectAsset1.Id, Custom_Dev_Type__c = 'Batch Updates', Integration_Tools__c = 'Boomi;Cast Iron', Legacy_Systems__c = 'Microsoft Dynamics',
											   Silverline_Product__c = '', Salesforce_Features__c = 'Chatter', Salesforce_License_Type__c = 'Professional Edition',Vendor__c = '',
											   Salesforce_Product__c = 'Customer Community',Miscellaneous__c = 'Dashboards');
		update objProjectAsset1;
		   
		objProjectAsset2 = new Project_Asset__c(Id = objProjectAsset2.Id, Custom_Dev_Type__c = '', Integration_Tools__c = 'Boomi', Legacy_Systems__c = '',
											   Silverline_Product__c = '', Salesforce_Features__c = '', Salesforce_License_Type__c = 'Professional Edition',Vendor__c = '',
											   Salesforce_Product__c = '', Miscellaneous__c = 'Dashboards');
		update objProjectAsset2;

		AggregateResult objAgr = [Select Count(Id) total From TopicAssignment];
		/*Start - Updated By Pankaj Ganwani on 19/JUNE/2015 as per DLIB-29 */
		system.assertEquals(17,objAgr.get('total'));
		/*End - Updated By Pankaj Ganwani on 19/JUNE/2015 as per DLIB-29 */
		
		delete objProjectAsset;   
		undelete objProjectAsset;
    }
}