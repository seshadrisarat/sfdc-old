/**
* @ClassName    : SL_IntranetChatterGroupsQuery 
* @JIRATicket   : 
* @CreatedOn    : 03/June/14
* @ModifiedBy   : Ritika
* @Description  : Class to query Chatter Groups where isArchived is false. 
				  This class has updated metadata version which cant be done for Chatter Feeds class as we are querying on UserProfileFeeds there 
				  (this object doesnt support version 27 and above).
*/

/**
@ Roshan Pillai 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 
No of collections used                  : 
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetChatterGroupsQuery {
	
	// Constructor
	public SL_IntranetChatterGroupsQuery()
	{
		// Do nothing
	}
	
	// Method to identify if a particular group is Archived or not
	public Boolean getIsArchived(Id groupId)
	{
		Boolean isArchivedGroup;
		
		for(CollaborationGroup objCG : [  Select Id, Name, isArchived
	                                      From CollaborationGroup
	                                      Where Id = :groupId])
		{	                                      
			isArchivedGroup = objCG.isArchived;
		}
		
		return isArchivedGroup;
	}
}