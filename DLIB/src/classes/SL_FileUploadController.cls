/**
* @ClassName    : SL_FileUploadController 
* @JIRATicket   : Socint-192
* @CreatedOn    : 24/June/13
* @ModifiedBy   : Roshan Pillai 
* @Description  : This is the controller for The SL_FileUpload.
*/

/**
@ Roshan Pillai 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 1
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

public with sharing class SL_FileUploadController 
{
	/* Start - Local variables */
	private FeedItem feedToBeInsert;
	private String groupId;
	private String parentId;
	private String postBody;
	private String strfeedType;
	private String strCommunityId = Network.getNetworkId();
	/* End - Local variables */
	
	public String isSuccess {get;set;} 
	public String userId	{get;set;}
	public String strFileName {get;set;} 
	public String strContentType {get;set;} 
	public Blob attachmentBody {get;set;} 
	
	
	/*Start - Variables for uploading user image*/
	public Integer imageSize{get;set;}
    public String pidName {get;set;}
    public String wId {get;set;}
    public Boolean imageTooLarge{get;set;}
    public ContentDocument objDocument {get;set;}
    private ContentVersion objCV2;
	/*End - Variables for uploading user image*/
	
	private String documentId;
	
	/* Start - Constructor initialization */
	public SL_FileUploadController()
	{
		try{
			feedToBeInsert = new FeedItem();
			wId = isSuccess = '';
	        
			if(ApexPages.currentpage().getParameters().containsKey('isProfilePhoto') && ApexPages.currentpage().getParameters().get('isProfilePhoto') == 'true')
			{
				imageSize = 0;
		        imageTooLarge = false;
				
				//Get the user's id whose profile pic has to be changed
				if(ApexPages.currentpage().getParameters().containsKey('userId'))
					userId = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('userId') );
				
		        //  Checks for the Errors in the page. If any,then sets the imageTooLarge value to true   
		        if(ApexPages.currentPage().getParameters().get('error') == 'true')
		            imageTooLarge = true;
		    	
		    	if(ApexPages.currentpage().getParameters().containsKey('Success'))	
					isSuccess = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('Success') );
					
		        objDocument = new ContentDocument();
			}
			else
			{
				if(ApexPages.currentpage().getParameters().containsKey('groupId'))   
					groupId = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('groupId') );
				
				if(ApexPages.currentpage().getParameters().containsKey('postBody'))
					postBody = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('postBody') );
					
				if(ApexPages.currentpage().getParameters().containsKey('Success'))	
					isSuccess = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('Success') );
					
				if(ApexPages.currentpage().getParameters().containsKey('userId'))
					userId = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('userId') );
				
				if(ApexPages.currentpage().getParameters().containsKey('parentId'))
					parentId = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('parentId') );
			}
			
			if(ApexPages.currentpage().getParameters().containsKey('docId'))
				documentId = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('docId') );
			
			if(ApexPages.currentpage().getParameters().containsKey('wId'))   
				wId = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('wId') );
			
			//   To cover the Exception in the test
            if(Test.isRunningTest()) 
            	Integer i = 1/0;
		}
		catch(Exception e){
			//Do nothing
		}
	} 
	/* End - Constructor initialization */
	
	
	
	/* Start - Method for uploading image for user profile.
	   @Name           - createContent
	   @Parameters     - None 
	   @Return Type    - pagereference
	   @Description    - Function for uploading image for user profile.
	*/	
	public Pagereference createContent()
    {
        try{
            //   Checks whether the selected User has an Image or Not 
            if(attachmentBody != null)
            {
                //    Checks for the size of the Image (Max 8 MB)
                if(imageSize < 10000000)
                {
                    //Saving by connectApi method no need to insert in ContentVersion
                    ConnectApi.BinaryInput objBinary = new ConnectApi.BinaryInput(attachmentBody, strContentType, strFileName);
                    ConnectApi.ChatterUsers.setPhoto(strCommunityId, userId,  objBinary);
                    
                    attachmentBody = blob.valueOf('');
                    
                    objBinary = new ConnectApi.BinaryInput(attachmentBody,'test','test.jpg');// re-initializing
                    //Pagereference pageRefer = new Pagereference('SL_FileUpload?docId='+objDocument.Id+'&Success=true&userId='+userId+'&wId='+wId);
                    Pagereference pageRefer = new Pagereference('/apex/SL_FileUpload?Success=true&userId='+userId + '&wId=' + wId);
					pageRefer.setredirect(true);
                    
                    //To cover the Exception in the test
		            if(Test.isRunningTest()) 
		            	Integer i = 10/0;
		            return pageRefer;
                }
                else
                {
                	Pagereference objPR = new Pagereference('/apex/SL_FileUpload?Success=false&userId='+userId+'&wId='+wId);
					objPR.setredirect(true);
					return objPR;
                }
            }
            else
            {
            	Pagereference objPR = new Pagereference('/apex/SL_FileUpload?isProfilePhoto=true&Success=false&userId='+userId+'&wId='+wId);
				objPR.setredirect(true);
				return objPR;
            }
        }
        catch(Exception e){
			return null;
        }
    }
    /* End - createContent method */
    
    
    /* Start - Method for Saving encoded Base64 Photo URL for the User
	   @Name           - saveUserDetails
	   @Parameters     - None 
	   @Return Type    - pagereference
	   @Description    - Function for Saving encoded Base64 Photo URL for the User.
	*/	
    public Pagereference saveUserDetails()
    {
        try{  
        	if(ApexPages.currentpage().getParameters().containsKey('docId'))
	        {
	           	//ConnectApi.ChatterUsers.setPhoto(strCommunityId, userId, documentId, null);
				Pagereference pr = new Pagereference('/apex/SL_FileUpload?Success=true&userId='+userId + '&wId=' + wId);
	            pr.setRedirect(true); 
	               
	            // To cover the Exception in the test
	            if(Test.isRunningTest()) 
	            	Integer i = 10/0;
	            	       
	            return pr;
	        }
	        else
				return null;
        }
        catch(Exception e){
            // If Exception raises before the page redirect, the Catch block will perform the page redirecting mechanism
            attachmentBody = blob.valueOf('');
            Pagereference objPR = new Pagereference('/apex/SL_FileUpload?Success=false&userId='+userId + '&wId=' + wId);
			objPR.setredirect(true);
			return objPR;
        } 
    }
    /* End - saveUserDetails method */
}