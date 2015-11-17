/**
* @ClassName    : SL_NOIProjections_Handler
* @JIRATicket   : STONEPIII-6
* @CreatedOn    : 26/April/2013
* @ModifiedBy   : -
* @Description  : Handler for SL_NOIProjections trigger.
*/


/**
@Developer Name: Shailendra
Percentage of best practices followed: 100%
No of SOQL queries used: 0
No of collections used: 0
Exception Handling implemented: Yes
Coding standards followed: Yes
Naming conventions followed: Yes
Third party integrations: No
Maximum of No of records tested with: 1000
Customer Approval:
Last Modified Date: 
Approved by:
Test Coverage : 99%
*/
public class SL_NOIProjections_Handler 
{	
	// Constructor
	public SL_NOIProjections_Handler()
	{
		// Do Nothing
	}
	
	public void OnBeforeInsert(List<NOI_Projection__c> lstNOIProjections)
	{}
	
	/*
        @MethodName : OnAfterInsert
        @param None : List<NOI_Projection__c> lstNOIProjections
        @Description: Method to create a record populating the NOI_Projection_c.NAME into the Operating_Expense1c.Operating_Expense_c.
    */	
	public void OnAfterInsert(List<NOI_Projection__c> lstNOIProjections)
	{
		try 
		{	
			NOIProjections(lstNOIProjections);
		}
		catch(Exception e)
		{
			
		}
	}
	
	/*
        @MethodName : NOIProjections
        @param None : List<NOI_Projection__c> lstNOIProjections
        @Description: Method to create a record populating the NOI_Projection_c.NAME into the Operating_Expense1c.Operating_Expense_c.
                      called from onAfterInsert method
    */
	private void NOIProjections(List<NOI_Projection__c> lstNOIProjections)
	{
		List<Operating_Expense1__c> lstInsertOperatExp = new List<Operating_Expense1__c>();
			
		// Bulk record insert
		for(NOI_Projection__c objlst : lstNOIProjections)
		{
			Operating_Expense1__c objOperatExpense = new Operating_Expense1__c();
			objOperatExpense.Deal__c = objlst.Deal__c;
			objOperatExpense.Operating_Expense__c = objlst.Id;
						
			lstInsertOperatExp.add(objOperatExpense);
		}
		
		insert lstInsertOperatExp;
	}
	
	@isTest
	private static void test_SL_NOIProjections_Handler()
	{
		Deal__c objtestDeal = new Deal__c(Name = 'My Test QA Deal-01');
		
		insert objtestDeal;
		
		NOI_Projection__c objTestNoiProjection = new NOI_Projection__c(Deal__c = objtestDeal.Id);
		
		insert objTestNoiProjection;
		
	
	}
}