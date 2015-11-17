/**
 * \author Vika Osmak 
 * \date 03/29/12
 * \see https://silverline.jira.com/browse/MBS-3
 * \brief Test Class for class SL_SeniorBankerScorecard_Dashboard 
 */
public with sharing class SL_BankerActivitySummary_Dashboard 
{
    public SL_TmpObjects__c tmpObj {get; set;}
    
	public SL_BankerActivitySummary_Dashboard()
	{
		tmpObj = new SL_TmpObjects__c(Start_Date__c = Date.today(),End_Date__c = Date.today());
	}

	public PageReference run()
	{
		Boolean isError = false;
		
		Date todayDate = Date.today();
        if(	!(	tmpObj.Start_Date__c != null && 
        		tmpObj.End_Date__c != null &&
        		tmpObj.Start_Date__c <= todayDate &&
        		tmpObj.End_Date__c <= todayDate &&
        		tmpObj.Start_Date__c < tmpObj.End_Date__c) 	)
		{
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'End Date must be later than Start Date. Both End Date and Start Date must be <= TODAY.'));
           isError = true;
        }
        
        if(!isError)
        {
			PageReference pageRef = new PageReference('/apex/SL_BankerDashboard_Report?sdate='+String.valueOf(tmpObj.Start_Date__c)+'&edate='+String.valueOf(tmpObj.End_Date__c));
			pageRef.setRedirect(true);
	        return pageRef;
        }
		return null;
	}
}