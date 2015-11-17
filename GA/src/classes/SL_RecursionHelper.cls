/**
*  ClassName      : SL_RecursionHelper
*  JIRATicket     : GA-6
*  CreatedOn      : 23/JAN/2015
*  ModifiedBy     : Pradeep
*  Description    : This is the recursion helper class for Connection trigger(SL_Connection) and it's handler class.
*/

public class SL_RecursionHelper 
{
    public static boolean isAfterInsert = true;
	public static boolean isAfterUpdate = true;
	public static boolean isAfterDelete = true;
	
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
	@MethodName	: getisAfterDelete
	@param 		: none
	@Description: method will return true on calling
    **/
	// for before update
	public static boolean getisAfterDelete()
	{
		return isAfterDelete;
	}
	
	/**
	@MethodName	: setisAfterDelete
	@param 		: boolean t
	@Description: method will assign the param true/false on setting value
    **/
	public static void setisAfterDelete(boolean t)
	{
		isAfterDelete = t;
	}
}