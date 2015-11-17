/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public Boolean isNewUser {get; set;}
    
    public PageReference changePassword() {
    	
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }

    // If return URL has the isRegistered=true parameter, we arrived from the
	// registration page, otherwise the user forgot their password
    public void isNewUser(){
    	String returnURL = apexPages.currentPage().getParameters().get('retURL');
    	isNewUser = false;

    	System.debug('returnURL: ' + returnURL);

    	if(returnURL != null){
    		returnURL = EncodingUtil.urlDecode(returnURL, 'ASCII');
    		System.debug('Decoded return URL: ' + returnURL);

    		String[] splitReturnURL = returnURL.split('\\?');
    		System.debug('Split return URL: ' + splitReturnURL);

    		if(splitReturnURL.size() == 2 && splitReturnURL[1] == 'isRegistered=true'){
    			isNewUser = true;
    		}
    	}

    	System.debug('isNewUser: ' + isNewUser);
    }
    
   	public ChangePasswordController() {
   		isNewUser();
   	}
}