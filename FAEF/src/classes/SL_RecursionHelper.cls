/**
* @ClassName    : SL_RecursionHelper 
* @JIRATicket   : FAEF-14
* @CreatedOn    : Sruti, 12/Aug/2013
* @ModifiedBy   : Sruti, 16/Aug/2013
* @Description  : This is recursion class used in equipment trigger to avoid recursion in before and after triggers
*/

/**
@Developer Name							: Sruti
Percentage of best practices followed	: 100%
No of SOQL queries used					: 0
No of collections used					: 0
Exception Handling implemented			: No
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
	///This boolean will be set to true by default
	public static boolean isRecursive = true;
	
	/*
		@MethodName : getisRecursive
		@param      : NA
		@Description: This method is used to get the value of the isRecursive variable from the calling method.
	*/
	public static boolean getisRecursive()
	{
		///return the isRecursive variable to the calling method.
		return isRecursive; 
	}
	
	/*
		@MethodName : setisRecursive
		@param      : Boolean
		@Description: This method is used to set the isRecursive variable value to handle the recursion condition, 
					  so on the basis of this variable particular functionality should be executed or no.
	*/
	public static void setisRecursive(boolean t)
	{
		///setting the isRecursive variable value.
		isRecursive = t;
	}
	
	
	/* start - Test Coverage*/
	static testMethod void SL_RecursionHelper_Test()
	{
		SL_RecursionHelper.setisRecursive(true);
		boolean blnDelete = SL_RecursionHelper.getisRecursive();
	}
	/* sTOP - Test Coverage*/
}