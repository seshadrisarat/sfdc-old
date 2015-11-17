/****************************************************************************************
Name            : psaTestUtils
Author          : CLD
Created Date    : January 22, 2014
Description     : Utils for test coverage
******************************************************************************************/
@isTest (seeAllData=true)
public class psaTestUtils 
{
    public static pse__Practice__c defaultPractice;
    public static pse__Region__c defaultRegion;
    public static pse__Grp__c defaultGroup;
    public static Contact defaultResource;
    public static pse__Work_Calendar__c defaultWorkCalendar;
    
    public static final String DEFAULT_PRACTICE_NAME = 'psaTestPractice';
    public static final String DEFAULT_REGION_NAME = 'psaTestRegion';
    public static final String DEFAULT_GROUP_NAME = 'psaTestGroup';
    public static final String DEFAULT_RESOURCE_NAME = 'PSA Test Resource';
    public static final String DEFAULT_GROUP_INVOICE_DESCRIPTION = 'TC Web App Dev';

    public static final String PROJECT_STAGE_DRAFT = 'Draft';
    public static final String PROJECT_STAGE_UNSIGNED = 'Unsigned';
    public static final String PROJECT_STAGE_ACTIVE = 'Active';
    public static final String PROJECT_STAGE_ONHOLD = 'On Hold';
    public static final String PROJECT_STAGE_COMPLETED = 'Completed';
    public static final String PROJECT_STAGE_CANCELED = 'Canceled';
    public static final String PROJECT_STAGE_MISSINGPAPERWORK = 'Missing Paperwork';
   
    public static final String MILESTONE_STATUS_PLANNED = 'Planned';
    public static final String MILESTONE_STATUS_OPEN = 'Open';
    public static final String MILESTONE_STATUS_SUBMITTED = 'Submitted';
    public static final String MILESTONE_STATUS_APPROVED = 'Approved';
    public static final String MILESTONE_STATUS_CANCELED = 'Canceled';
    public static final String MILESTONE_REVENUE_TYPE_BIDD = 'BIDD';
    
    public static final String RESOURCE_ROLE_PROJECTLEADER = 'Project Leader';
    public static final String RESOURCE_ROLE_FACILITATOR = 'Facilitator';
    public static final String RESOURCE_ROLE_PM = 'Project Manager';
    public static final String RESOURCE_ROLE_CONSULTANT = 'Consultant';

   /*************************************************************
    * Creates a Region with the name provided
    *
    **************************************************************/
    public static pse__Region__c createTestRegion(String regionName)
    {
        pse__Region__c testRegion = new pse__Region__c(Name=regionName, pse__Action_Update_Current_Time_Period__c=false, pse__Current_Time_Period__c = null);
        insert testRegion;
        return testRegion;
    }
    
    /*************************************************************
    * Creates a Practice with the name provided
    *
    **************************************************************/
    public static pse__Practice__c createTestPractice(String practiceName)
    {
        pse__Practice__c testPractice = new pse__Practice__c(Name=practiceName, pse__Action_Update_Current_Time_Period__c=false, pse__Current_Time_Period__c = null);
        insert testPractice;
        return testPractice;
    }
    
    /*************************************************************
    * Creates a Group with the name provided
    *
    **************************************************************/
    public static pse__Grp__c createTestGroup(String groupName)
    {
        pse__Grp__c testGroup = new pse__Grp__c(Name=groupName); 

        insert testGroup;
        return testGroup;
    }

    /*************************************************************
    * Creates a Project with parameters provided for:
    * - Name
    * - Region
    * - Practice
    * - Group
    * - Project Stage
    * - Opportunity (optional)
    * - Project Type (optional, default = Customer Project)
    * - Billing Type (optional, default = Fixed Fee)
    * - Fixed Fee Billing Method (optional, default = Start-Mid-End)
    * Automatically sets the project to Active, Billable
    * Allow timecards and expenses without assignment 
    **************************************************************/
    public static pse__Proj__c createTestProject(String projectName, pse__Region__c region, pse__Practice__c practice, pse__Grp__c projGroup, String projectStage, Opportunity opp)
    {
        initDefaultRPG();
        pse__Proj__c testProject = new pse__Proj__c(  Name=projectName,
                                        pse__Is_Active__c=true,
                                        pse__Is_Billable__c=true,
                                        pse__Allow_Timecards_Without_Assignment__c=true,
                                        pse__Allow_Expenses_Without_Assignment__c=true);
        
        testProject.pse__Region__c = region.Id;
        testProject.pse__Practice__c = practice.Id;
        testProject.pse__Group__c = projGroup.Id;
        testProject.pse__Stage__c = projectStage;
        if(opp != null)
        {
            testProject.pse__Opportunity__c = opp.Id;
        }

        insert testProject;
        return testProject;
    }

    public static pse__Proj__c createTestProject(String projectName, pse__Region__c region, pse__Practice__c practice, pse__Grp__c projGroup, String projectStage, Account acc)
    {
        initDefaultRPG();
        pse__Proj__c testProject = new pse__Proj__c(  Name=projectName,
                                        pse__Is_Active__c=true,
                                        pse__Is_Billable__c=true,
                                        pse__Allow_Timecards_Without_Assignment__c=true,
                                        pse__Allow_Expenses_Without_Assignment__c=true);
        
        testProject.pse__Region__c = region.Id;
        testProject.pse__Practice__c = practice.Id;
        testProject.pse__Group__c = projGroup.Id;
        testProject.pse__Stage__c = projectStage;
        if (acc != null)
        {
            testProject.pse__Account__c = acc.Id; 
        }

        insert testProject;
        return testProject;
    }

    /**************************************************************************************************
    * Creates a test opportunity
    ***************************************************************************************************/
    public static Opportunity createTestOpportunity(String opptyName, String stage, Account account)
    {
        initDefaultRPG();
        Opportunity testOpportunity = new Opportunity(Name=opptyName, StageName=stage, Amount=25000);
        testOpportunity.CloseDate = date.newInstance(2011, 7, 11);
        testOpportunity.AccountId = account.Id;
        insert testOpportunity;
        return testOpportunity;
    }
    
    /**************************************************************************************************
    * Creates a test account
    ***************************************************************************************************/
    public static Account createTestAccount(String accountName, String accountNumber, String arNumber)
    {
        Account testAccount = new Account(Name=accountName, AccountNumber=accountNumber, CurrencyIsoCode='USD', BillingCountry='US',BillingState='VA', BillingStreet='1 Main', BillingCity='Springfield',
            Type='Customer', BillingPostalCode='22102');
        insert testAccount;
        return testAccount;
    }
    
    /**************************************************************************************************
    * Creates a test Milestone
    ***************************************************************************************************/
    public static pse__Milestone__c createTestMilestone(String milestoneName, pse__Proj__c project, String milestoneCategory, String milestoneType, Date targetDate)
    {
        pse__Milestone__c testMilestone = new pse__Milestone__c(Name=milestoneName);
        testMilestone.pse__Project__c = project.Id;
        testMilestone.pse__Closed_for_Expense_Entry__c = true;
        testMilestone.pse__Closed_for_Time_Entry__c = false;
        testMilestone.pse__Status__c = MILESTONE_STATUS_PLANNED;
        testMilestone.pse__Target_Date__c = targetDate;
        insert testMilestone;
        return testMilestone;
    }
    
    /**************************************************************************************************
    * Creates a test PSA Resource
    ***************************************************************************************************/
    public static Contact createTestResource(User salesforceUser, pse__Region__c region, pse__Practice__c practice, pse__Grp__c resourceGroup)
    {
        initDefaultWorkCalendar();

        Contact testResource = new Contact(LastName=DEFAULT_RESOURCE_NAME, pse__Resource_Role__c='Systems Engineering',
            pse__Is_Resource__c=true,pse__Is_Resource_Active__c=true, MailingStreet='222 Oak St', MailingCity='Arlington', MailingState='VA', MailingCountry='US', MailingPostalCode='22102');
        
        testResource.pse__Region__c = region.Id;
        testResource.pse__Practice__c = practice.Id;
        testResource.pse__Group__c = resourceGroup.Id;
        testResource.pse__Work_Calendar__c=defaultWorkCalendar.Id;
        testResource.pse__Action_Update_Current_Time_Period__c=false;
        testResource.pse__Current_Time_Period__c = null;
        
        if(salesforceUser!=null)
        {
            testResource.pse__Salesforce_User__c=salesforceUser.Id;
        }
        
        insert testResource;
        //insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Resource__c=defaultResource.Id, pse__Timecard_Entry__c=true, pse__Staffing__c = true);
        return testResource;
    }

    /**************************************************************************************************
    * Creates a test Contact (Not a PSA Resource)
    ***************************************************************************************************/
    public static Contact createTestContact(String firstName, String lastName, String contactEmail)
    {
        initDefaultWorkCalendar();

        Contact testContact = new Contact(LastName=lastName, FirstName=firstName, MailingStreet='222 Oak St', MailingCity='Arlington', MailingState='VA', MailingCountry='US', MailingPostalCode='22102', Email=contactEmail);
                
        insert testContact;
        return testContact;
    }
	
	/**************************************************************************************************
	* Creates a test Assignment
	*
	*
	*
	***************************************************************************************************/
	public static pse__Assignment__c createTestAssignment(pse__Proj__c proj, Contact resource, String resourceRole)
	{
	  	// Create an initial assignment schedule, 30 days out
    	pse__Schedule__c schedule = new pse__Schedule__c();
    	schedule.pse__Start_Date__c = System.Today() + 30;
    	schedule.pse__End_Date__c = System.Today() + 34;
    	schedule.pse__Monday_Hours__c = 8;
    	schedule.pse__Tuesday_Hours__c = 8;
    	schedule.pse__Wednesday_Hours__c = 8;
    	schedule.pse__Thursday_Hours__c = 8;
    	schedule.pse__Friday_Hours__c = 8;
    	insert schedule;

	// Get top most Region for the Permission Control
	id regionId = [select id from pse__Region__c where pse__Hierarchy_Depth__c = 0 limit 1].id;
	//system.Assert(regionId!=null, "No Regions configured.   Please contact your PSA Admin");
    	
    	// Create a permission control that will allow us to staff the resource
        insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Resource__c=resource.Id, pse__Staffing__c=true);
		insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Region__c= regionId, pse__Staffing__c=true);
		
    	// Create the assignment and associate it with the project
    	pse__Assignment__c assignment = new pse__Assignment__c(Name='Test Assignment');
    	assignment.pse__Is_Billable__c = true;
    	assignment.pse__Project__c = proj.Id;
    	assignment.pse__Resource__c = resource.Id;
    	assignment.pse__Schedule__c = schedule.Id;
    	assignment.pse__Bill_Rate__c = 85;
    	assignment.pse__Role__c = resourceRole;
    	insert assignment;
    	
    	return assignment;
	}
	
	/*************************************************************
	* Initializes an instance-level work calendar that can be reused
	*
	*
	*
	**************************************************************/
	private static void initDefaultWorkCalendar()
	{
		if(defaultWorkCalendar==null)
		{
			defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
			insert defaultWorkCalendar;
		}
	}
	
	/*************************************************************
	* Initializes instance-level Region, Pratice, and Group
	*
	*
	**************************************************************/
	public static void initDefaultRPG()
	{
		if(defaultRegion==null)
		{
			defaultRegion = createTestRegion(DEFAULT_REGION_NAME);
		}
		
		if(defaultPractice==null)
		{
			defaultPractice = createTestPractice(DEFAULT_PRACTICE_NAME);
		}
		
		if(defaultGroup==null)
		{
			defaultGroup = createTestGroup(DEFAULT_GROUP_NAME);
		}
	}
	
	/*************************************************************
	* Initializes an instance-level Resource that can be reused
	*
	*
	*
	**************************************************************/
	public static Contact initDefaultResource()
	{
		initDefaultRPG();
		initDefaultWorkCalendar();
		
        User defaultResourceUser = psaTestUtils.createTestUser('PMgr', 'pm@abc.com', 'PM', 'PM', 'pm@abc.com', 'PM', 'DEFRSRC');
        
        defaultResource = new Contact(LastName=DEFAULT_RESOURCE_NAME, pse__Resource_Role__c=RESOURCE_ROLE_CONSULTANT,
			pse__Is_Resource__c=true,pse__Is_Resource_Active__c=true, MailingStreet='222 Oak St', MailingCity='Arlington', 
			MailingState='VA', MailingCountry='US', MailingPostalCode='22102', pse__Salesforce_User__c=defaultResourceUser.Id);
		
		defaultResource.pse__Region__c = defaultRegion.Id;
		defaultResource.pse__Practice__c = defaultPractice.Id;
		defaultResource.pse__Group__c = defaultGroup.Id;
		defaultResource.pse__Work_Calendar__c=defaultWorkCalendar.Id;
		defaultResource.pse__Action_Update_Current_Time_Period__c=false;
		defaultResource.pse__Current_Time_Period__c = null;

		insert defaultResource;
		return defaultResource;
	}
	
	/*************************************************************
	* Creates a User with System Administrator profile
	*
	*
	*
	**************************************************************/
	public static User createTestUser(String userAlias, String userLogin, String userLastName, String userFirstName, String userEmail, String userNickname, String codaSupplierCode)
	{
		Profile prof = [select Name from Profile where Name = 'System Administrator'];
		User testUser = new User(alias=userAlias, username=userLogin, lastname=userLastName, firstname=userFirstName, email=userEmail, communitynickname=userNickname, timezonesidkey='America/New_York', LocaleSidKey='en_US', ProfileId=prof.Id, LanguageLocaleKey='en_US', EmailEncodingKey='UTF-8');
		insert testUser;
		return testUser;
	}
}