/**
* @TriggerName    	:	QuickResetPasswordController
* @JIRATicket		:	MIHIN-23
* @CreatedOn    	:	11/FEB/13
* @ModifiedBy   	:	Hemant Shukla
* @Developer Name	:	Hemant Shukla
* @Description  	:	Need to allow the user to reset their portal password from http://mihin.force.com/ (from Site) 
						using the same work around as used for the double portal login.
**/


/**
@Developer Name                         :	Hemant Shukla
Percentage of best practices followed   :	100%
No of SOQL queries used                 :	0
No of collections used                  :	0
Exception Handling implemented          :	Yes
Coding standards followed               :	Yes
Naming conventions followed             :	Yes
Third party integrations                :	No
Maximum of No of records tested with    :	15
Customer Approval                       :	
Last Modified Date                      :	11/FEB/13
Approved by                             :	

*/

public with sharing class  QuickResetPasswordController{
	
	public String username {get; set;}   
       
    public QuickResetPasswordController() {}
	
  	public PageReference forgotPassword() {
  		try
  		{
  			username = System.currentPageReference().getParameters().get('un');
	  		boolean success = Site.forgotPassword(username);
	  		PageReference pr = Page.ForgotPasswordConfirm;
	  		pr.setRedirect(true);
	  		
	  		if (success) {  			
	  			return pr;
	  		}
	  		return null;
  		}
	  	catch(Exception e)
	  	{
	  		System.debug('### Exception : ' + e);
	  		return null;
	  	}
  	}
  	
  	 @IsTest(SeeAllData=true) public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	QuickResetPasswordController controller = new QuickResetPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
	
}