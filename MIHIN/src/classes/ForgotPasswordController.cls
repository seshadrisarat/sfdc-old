//Copyright 2012 – Michigan Health Information Network – MiHIN – All rights reserved.
/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController 
{
    public String username 		   {	get;set;	}   
    public Boolean isUserNameExist {	get;set;	} //this variable is used to check whether the username is valid or not 
    
    public ForgotPasswordController() 
    {
    	isUserNameExist = false;
    }
	
  	public PageReference forgotPassword() 
  	{  		
  		/* fetching user details based on username */
        List<User> u = [SELECT UserType FROM User WHERE username =: username];        
        
        if (u.size() != 1 )/* && !test.isRunningTest()*/
        { 
            isUserNameExist = true;
            return null;
        }
        
        String type;
        PageReference pageRef;
        
        /* determining where to redirect user based on userType 
        if (test.isRunningTest())
            type = 'test';*/
            
        if (u[0].UserType == 'PowerPartner')
        {
            type = 'partner';
            pageRef = new PageReference('/'+type+'/QuickResetPassword');
        }
        else if (u[0].UserType == 'CspLitePortal') /* || u[0].UserType == 'PowerCustomerSuccess' */
        {
            type = 'customer';
            pageRef = new PageReference('/'+type+'/QuickResetPassword');
        }
        else
        {
        	pageRef = new PageReference('/QuickResetPassword');/* return null;*/
        }        
        
        /*if(test.isRunningTest())
    		return Null;*/
        
        pageRef.getParameters().put('un', username);
        
        return pageRef;
  	}
  	
  	 @IsTest() 
  	 public static void testForgotPasswordController() 
  	 {
    	Account objAccount = new Account(Name = 'Test Account');
    	insert objAccount;
    	
    	Contact objContact = new Contact(LastName = 'Test Contact',AccountId = objAccount.Id);
    	insert objContact;
    	
    	Id ProfileId = [SELECT id FROM Profile WHERE Name='MIHN - HPD Provider User'].Id;
    	
    	User objUser = new User(Alias = 'test', 
				                Email='Test1@salesforce.com',
				                EmailEncodingKey='UTF-8', 
				                LastName='Test1',   
				                LanguageLocaleKey='en_US',
				                LocaleSidKey='en_US', 
				                ProfileId = ProfileId, 
				                TimeZoneSidKey='America/Los_Angeles',
				                ContactId = objContact.Id,
				                PortalRole = 'Manager',
				                isActive = true,
				                UserName='Test1@salesforce.com'); 
    	insert objUser;
    	
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'Test1@salesforce.com';     	
    	controller.forgotPassword();
    	ForgotPasswordController objcontroller = new ForgotPasswordController();
    	objcontroller.username = 'Test@salesforce.com';
    	System.assertEquals(objcontroller.forgotPassword(),null); 
    }
}
//Copyright 2012 – Michigan Health Information Network – MiHIN – All rights reserved.