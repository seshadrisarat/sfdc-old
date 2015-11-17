/**
* @ClassName    : SL_IntranetFileUploadController
* @JIRATicket   : Socint-769
* @CreatedOn    : 07/July/14
* @ModifiedBy   : Ritika Bhargava
* @Description  : This is the controller for SL_IntranetFileUploadController page
*/

/**
@ Ritika Bhargava
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 0
No of collections used                  : 0
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 

*/
public with sharing class SL_IntranetFileUploadController {
	
	// Global variables
	public String success 			{	get; set;	} 
	public String wId				{	get; set;	}
	public Attachment objAttachment {	get; set;	}
	

	// Constructor
	public SL_IntranetFileUploadController() 
	{
		success = wId = '';
		objAttachment = new Attachment();
		
		if(ApexPages.currentpage().getParameters().containsKey('Success'))	
			success = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('Success') );
	}
	
	/* Start - Method for uploading file for chatter post.
	   @Name           - insertContent
	   @Parameters     - None 
	   @Return Type    - pagereference
	   @Description    - Function for uploading file for chatter post.
	*/
	public Pagereference insertContent() 
	{
		String widgetId = ApexPages.currentPage().getParameters().get('widgetid');
		try 
		{
			Pagereference objPR;
			List<Content_Chatter__c> lstContentChatter = [SELECT Content_Id__c FROM Content_Chatter__c WHERE Content_Id__c = 'ContentFARecord' limit 1];
			if(lstContentChatter.isEmpty())
    		{
    			Content_Chatter__c objContentChatter = new Content_Chatter__c(Content_Id__c = 'ContentFARecord');
    			insert objContentChatter;
    			objAttachment.ParentId = objContentChatter.Id;
    		}
    		else
    			objAttachment.ParentId = lstContentChatter[0].Id;
        			
            insert objAttachment;
            
			objPR = new Pagereference('/apex/SL_IntranetFileUpload?Success=true&docId=' + objAttachment.Id + '&widgetid=' + widgetId);
			objPR.setredirect(true);
			
			objAttachment = new Attachment();
            return objPR; 
		}
		catch(Exception e)
		{
			objAttachment = new Attachment();
			Pagereference objPR = new Pagereference('/apex/SL_IntranetFileUpload?Success=false&widgetid=' + widgetId);
			objPR.setredirect(true);
			return objPR;
		}
	}
	/* End - insertContent method */
}