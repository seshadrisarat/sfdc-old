public with sharing class SL_ctrl_VendorForgotPassword {
	
	public String logoName {get;set;}
	public String username {get;set;}
	public String brandingId {get;set;}
	private SL_util_VendorCommunity.PortalBrandingWrapper branding;

	public SL_ctrl_VendorForgotPassword() {
		this.branding = SL_util_VendorCommunity.getLoginBranding();
		this.logoName = branding.logoName;
		this.brandingId = branding.uniqueId;
	}

	@RemoteAction
	public static Boolean sendPasswordEmail(String username){
		Site.forgotPassword(username);
		return true;
	}

}