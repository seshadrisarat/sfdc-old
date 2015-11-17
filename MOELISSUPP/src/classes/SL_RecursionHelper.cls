/**
* @ClassName    : SL_RecursionHelper 
* @JIRATicket   : MOELISSUPP-2
* @CreatedOn    : 10/May/2013
* @ModifiedBy   : SL
* @Description  : This is the recursion helper handler class for Staffing_Request__c trigger.
*/

/**
@Developer Name							: Sathiyaraja
Percentage of best practices followed	: 100%
No of SOQL queries used					: 
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

public with sharing class SL_RecursionHelper 
{
	/*start - global variable declaration*/
	public static boolean isInsert = true;
	public static boolean isUpdate = true;
	/*stop - global variable declaration*/
	
	public static boolean getisInsert()
	{
		return isInsert;
	}
	public static void setisInsert(boolean t)
	{
		isInsert = t;
	}
	
	public static boolean getisUpdate()
	{
		return isUpdate;
	}
	public static void setisUpdate(boolean t)
	{
		isUpdate = t;
	}
	
	/*test mothod for this class*/
	static testMethod void SL_RecursionHelper_Test()
	{
		SL_RecursionHelper.setisUpdate(true);
		SL_RecursionHelper.setisInsert(true);
		boolean blnDelete = SL_RecursionHelper.getisUpdate();
		boolean blnInsert = SL_RecursionHelper.getisInsert();
	}

}