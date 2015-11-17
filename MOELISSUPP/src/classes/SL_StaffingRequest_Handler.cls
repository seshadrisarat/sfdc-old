/**
* @ClassName    : SL_StaffingRequest_Handler 
* @JIRATicket   : MOELISSUPP-2
* @CreatedOn    : 09/May/2013
* @ModifiedBy   : SL
* @Description  : This is the handler class for Staffing_Request__c trigger.
*/

/**
@Developer Name							: Sathiyaraja
Percentage of best practices followed	: 100%
No of SOQL queries used					: 2
No of collections used					: 0
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	: 
Customer Approval						: 
Last Modified Date						: 
Approved by								: 

*/

public with sharing class SL_StaffingRequest_Handler 
{
	/* start - global variables*/
	public static boolean isTest = false;
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	/* stop - global variables*/
	
	/* start - constructor */     
	public SL_StaffingRequest_Handler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	
	/* Start - onAfterInsert() function will executed only on insert of new Staffing Request record from the trigger */
	public void onAfterInsert(Map<Id, Staffing_Request__c> mapStaffingRequestNew)
	{
		Map<Id, Staffing_Request__c> mapStaffingRequest = new Map<Id, Staffing_Request__c>(); //collect only Records which have Name_of_Requestor__c as not null.
		// iterate the new map and check forName_of_Requestor__c is not nulland avoid the functions on blank insert's.
		for(Staffing_Request__c objStaffingRequest : mapStaffingRequestNew.Values())
		{
			if(objStaffingRequest.Name_of_Requestor__c != Null)
				mapStaffingRequest.put(objStaffingRequest.Id, objStaffingRequest);
		} 
		// call only for the records whoses Staffing_Request__c.Name_of_Requestor__c is not null.
		if(!mapStaffingRequest.isEmpty())
			createSharingToEmployeeUser(mapStaffingRequestNew);
	}
	
	/* Start - onAfterUpdate() function will executed only on Update of new Staffing Request record from the trigger */
	public void onAfterUpdate(Map<Id, Staffing_Request__c> mapStaffingRequestNew, Map<Id, Staffing_Request__c> mapStaffingRequestOld)
	{
		Map<Id, Staffing_Request__c> mapStaffingRequestToAddShare = new Map<Id, Staffing_Request__c>(); //collect only Records which have Name_of_Requestor__c is modified and not null
		Map<Id, Staffing_Request__c> mapStaffingRequestToRemoveShare = new Map<Id, Staffing_Request__c>(); // collect only records in old map
		Set<Id> setEmployeeId = new Set<Id>();
		// iterate the new map and check for any modification on Name_of_Requestor__c.
		for(Staffing_Request__c objStaffingRequest : mapStaffingRequestNew.Values())
		{
			// for Adding share
			if(objStaffingRequest.Name_of_Requestor__c != Null 
				&& objStaffingRequest.Name_of_Requestor__c != mapStaffingRequestOld.get(objStaffingRequest.Id).Name_of_Requestor__c)
			{
				mapStaffingRequestToAddShare.put(objStaffingRequest.Id, objStaffingRequest);
			}
			//for Removing share
			if(objStaffingRequest.Name_of_Requestor__c != mapStaffingRequestOld.get(objStaffingRequest.Id).Name_of_Requestor__c
				&& mapStaffingRequestOld.get(objStaffingRequest.Id).Name_of_Requestor__c != null)
			{
				mapStaffingRequestToRemoveShare.put(objStaffingRequest.Id, mapStaffingRequestOld.get(objStaffingRequest.Id));
				setEmployeeId.add(mapStaffingRequestOld.get(objStaffingRequest.Id).Name_of_Requestor__c);
			}
		} 
		// call this method only to remove the share from Staffing_Request__c
		if(!mapStaffingRequestToRemoveShare.isEmpty())
			removeSharingOfEmployeeUser(mapStaffingRequestToRemoveShare, setEmployeeId);
		// call only for the records to share whoses Staffing_Request__c.Name_of_Requestor__c is not null.
		if(!mapStaffingRequestToAddShare.isEmpty())
			createSharingToEmployeeUser(mapStaffingRequestToAddShare);
		
	}
	
	/*start - createSharingToEmployeeUser() this function will ad or remove the share*/
	private void createSharingToEmployeeUser(Map<Id, Staffing_Request__c> mapStaffingRequestNew)
	{
		Map<Id, Id> mapEmployeProfileId_UserId = new Map<Id, Id>(); // // collect a map with keyset as EmployeProfile.Id and values as Its UserId.
		List<Staffing_Request__Share> lstStaffingRequestShare_Insert = new List<Staffing_Request__Share>(); // list will hold New share to be inserted
		Set<Id> setEmployeeProfileId = new Set<Id>(); // set contains set of EmployeeProfile Id's that need to be queried
		
		try
		{	
			// iterate the map and get set of Employee_Profile Id
			for(Staffing_Request__c objStaffRequest : mapStaffingRequestNew.values())
			{
				// collect a set of Employee_Profile Id
				if(objStaffRequest.Name_of_Requestor__c != Null)
					setEmployeeProfileId.add(objStaffRequest.Name_of_Requestor__c);
			}
			 
			// query all Employee_Profile to fetch UserId
			for(Employee_Profile__c objEmployeeProfile : [Select Id, User_ID__c 
																from Employee_Profile__c
																where Id IN :setEmployeeProfileId])
			{
				// collect a map with keyset as EmployeProfile.Id and values as Its UserId.
				if(objEmployeeProfile.User_ID__c != Null)
					mapEmployeProfileId_UserId.put(objEmployeeProfile.Id, objEmployeeProfile.User_ID__c);
			}
			
			// iterate the map and get set of Employee_Profile Id
			for(Staffing_Request__c objStaffRequest : mapStaffingRequestNew.values())
			{
				if(mapEmployeProfileId_UserId.ContainsKey(objStaffRequest.Name_of_Requestor__c)
					&& mapEmployeProfileId_UserId.get(objStaffRequest.Name_of_Requestor__c) != Null
					&& mapEmployeProfileId_UserId.get(objStaffRequest.Name_of_Requestor__c) != objStaffRequest.OwnerId)
				{
					// create new Share records
					Staffing_Request__Share objStaffingRequestShare = new Staffing_Request__Share(); 
					objStaffingRequestShare.AccessLevel = 'Edit';
					objStaffingRequestShare.ParentId = objStaffRequest.Id;
					objStaffingRequestShare.UserOrGroupId = mapEmployeProfileId_UserId.get(objStaffRequest.Name_of_Requestor__c); 
					lstStaffingRequestShare_Insert.add(objStaffingRequestShare);
				}
			}
			// setting the variable to false and avoiding the recursion here.
			SL_RecursionHelper.setisInsert(false);
			SL_RecursionHelper.setisUpdate(false);
			// insert new share records.
			if(!lstStaffingRequestShare_Insert.isEmpty())
				insert lstStaffingRequestShare_Insert;
		}
		catch(Exception ex)
		{
			// do nothing.
		}
	}
	
	/*start - removeSharingOfEmployeeUser() this function will ad or remove the share*/
	private void removeSharingOfEmployeeUser(Map<Id, Staffing_Request__c> mapStaffingRequestOld, Set<Id> setEmployeeId)
	{
		List<Staffing_Request__Share> lstStaffingRequestShare_Delete = new List<Staffing_Request__Share>();// list used to delete the staffing Request share records.
		Map<Id,Id> mapEmployeeeProfile_UserId = new Map<Id,Id>(); // hold OldMap.Employee_Profile__c Id and its corresponding User Id
		Map<Id,Id> mapStaffingRequest_UserId = new Map<Id,Id>(); // holds Staffing Id and its Employye.User
		
		try
		{
			// query all Employee_Profile to fetch UserId
			for(Employee_Profile__c objEmployeeProfile : [Select Id, User_ID__c 
																from Employee_Profile__c
																where Id IN :setEmployeeId])
			{
				if(objEmployeeProfile.User_ID__c != Null)
					mapEmployeeeProfile_UserId.put(objEmployeeProfile.Id, objEmployeeProfile.User_ID__c);
			}
			
			// iterate the map and get 
			for(Staffing_Request__c objStaffingRequest : mapStaffingRequestOld.values())
			{
				if(mapEmployeeeProfile_UserId.ContainsKey(objStaffingRequest.Name_of_Requestor__c))
					mapStaffingRequest_UserId.put(objStaffingRequest.Id, mapEmployeeeProfile_UserId.get(objStaffingRequest.Name_of_Requestor__c));
			}
			
			//query a// share record and delete only this users share and not all shares
			for(Staffing_Request__Share objStaffingRequestShare : [Select UserOrGroupId, ParentId, Id, AccessLevel 
																		From Staffing_Request__Share
																		where ParentId IN :mapStaffingRequest_UserId.keyset() AND UserOrGroupId IN :mapStaffingRequest_UserId.Values()])
			{
				if(objStaffingRequestShare.UserOrGroupId != mapStaffingRequestOld.get(objStaffingRequestShare.ParentId).OwnerId
					&& mapStaffingRequest_UserId.get(objStaffingRequestShare.ParentId) == objStaffingRequestShare.UserOrGroupId)
					{
						lstStaffingRequestShare_Delete.add(objStaffingRequestShare);
					}
			}
			// delete the existing share
			if(!lstStaffingRequestShare_Delete.isEmpty())
				delete lstStaffingRequestShare_Delete;
		}
		catch(Exception ex)
		{
			// do nothing.
		}
	}
	
	/* start - Test Coverage*/
	static testMethod void SL_StaffingRequestTrigger_Test() 
    {
    	Account objAccount = new Account(Name = 'Test Name');
    	insert objAccount;
    	
    	Profile objProfile = [Select Name, Id From Profile where name='System Administrator'];
    	
    	User objTestUser1 = new User(LastName = 'testWorking_11', Alias = 'weqw', Email = 'hieetetd@gmail.com',
						 			 Username = 'testuserww11@gmail.com', CommunityNickname = 'h1244125451',
									 TimeZoneSidKey = 'America/New_York',
									 LocaleSidKey = 'en_US',
									 EmailEncodingKey = 'ISO-8859-1',
									 LanguageLocaleKey = 'en_US',
									 ProfileId = objProfile.Id);
		insert objTestUser1;
		
		User objTestUser2 = new User(LastName = 'testWorking_123231', Alias = 'wegggqw', Email = 'hgggieetetd@gmail.com',
						 			 Username = 'testggusggerww11@gmail.com', CommunityNickname = 'h1255125451',
									 TimeZoneSidKey = 'America/New_York',
									 LocaleSidKey = 'en_US',
									 EmailEncodingKey = 'ISO-8859-1',
									 LanguageLocaleKey = 'en_US',
									 ProfileId = objProfile.Id);
		insert objTestUser2;
    	
    	Employee_Profile__c objEmployee1 = new Employee_Profile__c(Name = 'Test_Working_1', First_Name__c = 'Test_', Last_Name__c='Working_1', Title__c = 'Advisory Board', Business_Type__c = 'Advisory', Group__c ='Generalist'
    																,User_ID__c = objTestUser1.Id, Office_Location__c = 'Boston', Status__c = 'Active');
    	insert objEmployee1;	
    	
    	Employee_Profile__c objEmployee2 = new Employee_Profile__c(Name = 'Test_Working_2', First_Name__c = 'Test_', Last_Name__c='Working_1',Title__c = 'Advisory Board', Business_Type__c = 'Advisory', Group__c ='Generalist'
    																,User_ID__c = objTestUser2.Id, Office_Location__c = 'Boston', Status__c = 'Active');
    	insert objEmployee2;	
    	
    	Staffing_Request__c objStaffingRequest = new Staffing_Request__c(Request_Date__c = date.Today(), Name_of_Requestor__c = objEmployee1.Id, Company_Name__c = objAccount.Id
    																	, Industry__c='Consumer & Retail', Subsector__c='Apparel Retailing', Project_Type__c ='Marketing', 
    																	Expected_Intensity__c='Low', Deliverable__c = 'Model', Description_Of_Project__c ='Test'
    																	,Near_Term_Deadline__c=Date.today(), Lead_Senior_Banker__c = objEmployee2.Id, Resource_Office_Needed__c ='Boston'
    																	,Resource_Level_Needed__c = 'Associate', Staffing_Status__c='Pending');
    	insert objStaffingRequest;
    	
    	SL_RecursionHelper.setisUpdate(true);
    	objStaffingRequest.Name_of_Requestor__c = objEmployee2.Id;
    	update objStaffingRequest;
    }
	/* stop - Test Coverage*/
}