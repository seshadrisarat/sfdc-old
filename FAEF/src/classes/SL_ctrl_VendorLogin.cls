global with sharing class SL_ctrl_VendorLogin {

	/* Portal Branding defined css */
	public String fontName {get;set;}
	public String fontColor {get;set;}
	public String loginBkgrdColor {get;set;}
	public String loginPrimaryColor {get;set;}
	public String loginBtnColor {get;set;}
	public String loginBtnFontColor {get;set;}
	public String logoName {get;set;}
	public String siteName {get;set;}
	public String brandingId {get;set;}

	global String username {get; set;}
    global String password {get; set;}
    private static final String LANDIING_PAGE = '/SL_VendorHome';
	
	global SL_ctrl_VendorLogin () {
		this.siteName = Site.getPathPrefix();
		setSiteBranding();
	}

	/*
	 * Query the Portal Branding record associated with the current user
	 * Use the data to set the css properties
	 *
	 */
	private void setSiteBranding(){
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getLoginBranding();
		this.fontName = branding.font;
		this.fontColor = branding.fontColor;
		this.loginBkgrdColor = branding.loginPageColor;
		this.loginPrimaryColor = branding.loginPrimaryColor;
		this.loginBtnColor = branding.loginBtnColor;
		this.loginBtnFontColor = branding.loginBtnFontColor;
		this.logoName = branding.logoName;
		this.brandingId = branding.uniqueId;
	}

    /*
        * MethodName        : login
        * param             : None
        * Description       : This function will be called on click of site login button and it will validate the username and password from database.
    */
    global PageReference login() 
    {
    	String startUrl = Site.getPathPrefix() + LANDIING_PAGE; 
    	return Site.login(username, password, startUrl);
    }

}