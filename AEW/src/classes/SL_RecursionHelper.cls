/**
* @ClassName    : SL_RecursionHelper 
* @JIRATicket   :  
* @CreatedOn    : 02/July/2015
* @ModifiedBy   : Sandeep
* @Description  : This is the recursion helper class.
*/

public with sharing class SL_RecursionHelper 
{
	public static boolean isInsert = true;
	public static boolean isUpdate = true;
	
	/**
	@MethodName	: getisInsert
	@param 		: none
	@Description: method will return true on calling
    **/
	public static boolean getisInsert()
	{
		return isInsert;
	}
	/**
	@MethodName	: setisInsert
	@param 		: booelan t
	@Description: method will assign the param true/false on setting value
    **/
	public static void setisInsert(boolean t)
	{
		isInsert = t;
	}
	/**
	@MethodName	: isUpdate
	@param 		: none
	@Description: method will return true on calling
    **/
	// for After Insert
	public static boolean getisUpdate()
	{
		return isUpdate;
	}
	/**
	@MethodName	: setisAfterInsert
	@param 		: boolean t
	@Description: method will assign the param true/false on setting value
    **/
	public static void setisUpdate(boolean t)
	{
		isUpdate = t;
	}
}