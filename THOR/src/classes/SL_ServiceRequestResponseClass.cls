/**
*  Class Name     : SL_MyBuildingIntegration_ResponseClass
*  JIRATicket     : THOR-13
*  CreatedOn      : 4/NOV/2014
*  ModifiedBy     : SANATH
*  Description    : Class used for deserialization of response.
*/
public with sharing class SL_ServiceRequestResponseClass 
{
	//Creating inner class for getting request from My Building.
	public class Requests 
	{
		public String requestId;
		public String unit;
		public String contactName;
		public String contactPhone;
		public String contactEmail;
		public String status;
		public String statusId;
		public String category;
		public String description;     
		public String photoSmallURL;
		public String photoURL;
		public String permissions;
		public String submittedBy;
		public String dateSubmitted;
		public String dateSubmittedFormatted;
	}
	public Response response;

	//Creating inner class for getting response from My Building.
	public class Response 
	{
		public List<Requests> requests;
		public Integer totalItems;
		public Integer pageSize;
		public Integer pageCount;
		public Integer pageNumber;
		public String status;
	}
	
	/*
        @MethodName : parse 
        @param      : String json 
        @Description: This method is used to deserialize the json in to object.
    */
	public static SL_ServiceRequestResponseClass parse(String json) 
	{
		return (SL_ServiceRequestResponseClass) System.JSON.deserialize(json, SL_ServiceRequestResponseClass.class);
	}
}