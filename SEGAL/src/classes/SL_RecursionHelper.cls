/**
* @ClassName    : SL_RecursionHelper 
* @JIRATicket   : SEGAL-6
* @CreatedOn    : 19/Jan/2015
* @ModifiedBy   : Pradeep
* @Description  : This is the recursion helper class for Contact Address trigger(SL_ContactAddressAssociation) and it's handler class.
*/

public with sharing class SL_RecursionHelper 
{
	public static boolean isAfterInsert = true;
	public static boolean isAfterUpdate = true;
	public static boolean isMergeDelete = false;
	
	/**
	@MethodName	: getisAfterInsert
	@param 		: none
	@Description: method will return true on calling
    **/
	// for before update
	public static boolean getisAfterInsert()
	{
		return isAfterInsert;
	}
	
	/**
	@MethodName	: setisAfterInsert
	@param 		: boolean t
	@Description: method will assign the param true/false on setting value
    **/
	public static void setisAfterInsert(boolean t)
	{
		isAfterInsert = t;
	}
	
	/**
	@MethodName	: isAfterUpdate
	@param 		: none
	@Description: method will return true on calling
    **/
	// for before update
	public static boolean getisAfterUpdate()
	{
		return isAfterUpdate;
	}
	
	/**
	@MethodName	: setisAfterUpdate
	@param 		: boolean t
	@Description: method will assign the param true/false on setting value
    **/
	public static void setisAfterUpdate(boolean t)
	{
		isAfterUpdate = t;
	}
	
	/**
	@MethodName	: getisAfterInsert
	@param 		: none
	@Description: method will return true on calling
    **/
	// for before update
	public static boolean getisMergeDelete()
	{
		return isMergeDelete;
	}
	
	/**
	@MethodName	: setisAfterInsert
	@param 		: boolean t
	@Description: method will assign the param true/false on setting value
    **/
	public static void setisMergeDelete(boolean t)
	{
		isMergeDelete = t;
	}
}