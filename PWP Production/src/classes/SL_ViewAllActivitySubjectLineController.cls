/**
* \arg ClassName      : SL_ViewAllActivitySubjectLineController
* \arg JIRATicket     : PWP-16
* \arg CreatedOn      : 4/FEB/2015
* \arg LastModifiedOn : 12/MAR/2015
* \arg CreatededBy    : Pradeep 
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : This class is the controller for SL_ViewAllActivitySubjectLine. 
*/
public with sharing class SL_ViewAllActivitySubjectLineController 
{
	/* Start - Page Variables */
   	public List<ActivityHistoryWrapper> lstActivityHistory {get;set;}// list for conatins all the ActivityHistory record for current account id
   	public List<OpenActivityWrapper> lstOpenActivity {get;set;}// list for conatins all the OpenActivity record for current account id
   	public Boolean isNativeSubject = false;

   	/* End - Page Variables */
	
	/* Start - Class Variables*/
    private Id accountId;// id store the current account which is present in url
    /* End - Class Variables*/
    
	/* Start - Constructor */
	public SL_ViewAllActivitySubjectLineController()
	{
		accountId = ApexPages.currentPage().getParameters().get('Id');//get the account id from the page and store into the accountid variable
		//calling method to initialize the page , class variables and for AccountHistory list
		initialize();
	}
	/* End - Constructor */
	
	/*
        * MethodName   : initialize
        * Param        : 
        * Description  : This method is used for intialize the variable and query the Account and its related Activity histories.
    */
	public void initialize()
	{
		lstActivityHistory = new List<ActivityHistoryWrapper>();
		lstOpenActivity = new List<OpenActivityWrapper>();
		//Query Account and subquery on Account history based on the Account id and add all Account history to the list 
		
		//checking whether current logged in user is present in coverage team member then only we displaying the actual subject 
		if([SELECT Id FROM Coverage_Team_Members__c WHERE Company__c =:accountId  AND PWP_Employee__c=:Userinfo.getUserId()].size()>0)
		{
			isNativeSubject = true;
		}

		for(Account objAccount : [SELECT Id,(Select Id, AccountId, Subject, ActivityDate, Who.Name, Account.Name, StartDateTime, IsTask, OwnerId, Owner.Name, LastModifiedDate, Create_Call_Report__c, Description  From ActivityHistories ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 500), (Select Id, AccountId, Subject, ActivityDate, Who.Name, Account.Name, StartDateTime, IsTask, OwnerId, Owner.Name, LastModifiedDate, Create_Call_Report__c, Description From OpenActivities ORDER BY ActivityDate ASC, LastModifiedDate DESC LIMIT 500) FROM Account WHERE Id =: accountId])
		{
			if(!objAccount.ActivityHistories.isEmpty()) {
				for (ActivityHistory activity : objAccount.ActivityHistories){
					lstActivityHistory.add(new ActivityHistoryWrapper(activity, isNativeSubject || activity.OwnerId == Userinfo.getUserId()));
				}
			}
			if(!objAccount.OpenActivities.isEmpty()){
				for (OpenActivity activity : objAccount.OpenActivities){
					lstOpenActivity.add(new OpenActivityWrapper(activity, isNativeSubject || activity.OwnerId == Userinfo.getUserId()));
				}
			}
			if (objAccount.ActivityHistories.isEmpty() && objAccount.OpenActivities.isEmpty()) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No Activity found !'));
			}
		}
		
	}
	
	/*
        * MethodName   : Cancel
        * Param        : 
        * Description  : This method is used for returning back on Company detail page.
    */
	public Pagereference cancel()
    {
    	return new Pagereference('/'+accountId);
    }

    public class ActivityHistoryWrapper {
    	public ActivityHistory activity {get;set;}
    	public Boolean isNativeSubject {get;set;}
    	public ActivityHistoryWrapper(ActivityHistory activity, Boolean isNativeSubject){
    		this.activity = activity;
    		this.isNativeSubject = isNativeSubject;
    	}
    }
    public class OpenActivityWrapper {
    	public OpenActivity activity {get;set;}
    	public Boolean isNativeSubject {get;set;}
    	public OpenActivityWrapper(OpenActivity activity, Boolean isNativeSubject){
    		this.activity = activity;
    		this.isNativeSubject = isNativeSubject;
    	}
    }
}