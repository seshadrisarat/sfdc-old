/*
*  PageName       : SL_VendorChangePassword
*  JIRATicket     : 
*  CreatedOn      : 12/17/2014
*  ModifiedBy     : Jared
*  Description    : A custom controller which  will provides branding information to the change password page and exposes
*  					a remote function to change the user's password and log them in upon a successful password change  
*/
public with sharing class SL_ctrl_VendorChangePassword {

	public String logoName {get;set;}

	public SL_ctrl_VendorChangePassword() {
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		this.logoName = branding.logoName;		
	}

	@RemoteAction
	public static RemoteResponse changePassword(String newPassword, String verifyNewPassword){
		try{
			PageReference redirect = Site.changePassword(newPassword, verifyNewPassword);
			System.debug(LoggingLevel.ERROR, 'new password : ' + newPassword + '    ' + verifyNewPassword);
			System.debug(LoggingLevel.ERROR, 'page ref ' + redirect);
			if(redirect != null){
				return new RemoteResponse(true, Site.getPathPrefix() + redirect.getUrl());
			}else{
				return new RemoteResponse(false, 'There was an error changing your password.');
			}
		}catch(Exception e){
			System.debug(LoggingLevel.ERROR, '#####Exception####->'+e.getMessage());
			return new RemoteResponse(false, 'Cannot use old password');
		}
	}

	public class RemoteResponse{
		public Boolean success;
		public String message;

		public RemoteResponse(Boolean success, String message){
			this.success = success;
			this.message = message;
		}
	}
}