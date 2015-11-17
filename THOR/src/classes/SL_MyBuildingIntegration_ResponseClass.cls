/**
*  Class Name     : SL_MyBuildingIntegration_ResponseClass
*  JIRATicket     : THOR-29
*  CreatedOn      : 28/SEP/2014
*  ModifiedBy     : SANATH
*  Description    : Class used for deserialization of response.
*/

public class SL_MyBuildingIntegration_ResponseClass
{
    public String title;
    public String text;
    public String e_date;
    public Response response;
    public String status;

    public class Response {
        public string message; 
        public String eventId;
        public String communityId;
        public Object eventCategoryId;
        public Object recurringEventId;
        public Object createdByUserId;
        public String groupId;
        public Object maxGuests;
        public String title;
        public String text;
        public String fileName;
        public String fileType;
        public String allowedSignups;
        public String allowedLoginPage;
        public String isAllDayEvent;
        public String towers;
        public String hasAttachments;
        public String dateStart;
        public String dateEnd;
        public String dateInserted;
        public String dateUpdated;
        public String id;
        public String startDatePickerValue;
        public String evedate;
        public String fromTimeValue;
        public String toTimeValue;
        public Integer recurringEventsCount;
        public String startDateIso;
        public String endDateIso;
        public String eventTime;
        public String eventDate;
        public Boolean categoryTitle;
        public Boolean isSpotsAvailable;
        public Boolean attendeesCount;
    }
}