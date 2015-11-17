/**
*  ClassName      : SL_RecursionHandler
*  JIRATicket     : PWP-212
*  CreatedOn      : 02/SEPT/2015
*  ModifiedBy     : Nrusingh
*  Description    : This is the recursion handler class for SL_AffiliationHandler.
*/

public class SL_RecursionHandler 
{
    public static boolean isAfterInsert = true;
	public static boolean isAfterUpdate = true;
	public static boolean isAfterDelete = true;
	public static boolean isAfterUnDelete = true;
	
	
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
	public static void setIsAfterUpdate(boolean t)
	{
		isAfterUpdate = t;
	}
	
	/**
	@MethodName	: isAfterDelete
	@param 		: none
	@Description: method will return true on calling
    **/
	// for before update
	public static boolean getIsAfterDelete()
	{
		return isAfterDelete;
	}
	
	/**
	@MethodName	: setisAfterDelete
	@param 		: boolean t
	@Description: method will assign the param true/false on setting value
    **/
	public static void setIsAfterDelete(boolean t)
	{
		isAfterDelete = t;
	}
	
	
	/**
	@MethodName	: getisAfterUnDelete
	@param 		: none
	@Description: method will return true on calling
    **/
	// for before update
	public static boolean getIsAfterUnDelete()
	{
		return isAfterUnDelete;
	}
	
	/**
	@MethodName	: setisAfterUnDelete
	@param 		: boolean t
	@Description: method will assign the param true/false on setting value
    **/
	public static void setIsAfterUnDelete(boolean t)
	{
		isAfterUnDelete = t;
	}
}