public with sharing class SL_ctrl_VendorInactiveTemplate {

	/* Portal Branding defined css */
	public String fontName {get;set;}
	public String fontColor {get;set;}
	public String loginBkgrdColor {get;set;}
	public String loginPrimaryColor {get;set;}
	public String loginBtnColor {get;set;}
	public String loginBtnFontColor {get;set;}
	public String logoName {get;set;}
	public String siteName {get;set;}

	public SL_ctrl_VendorInactiveTemplate() {
		SL_util_VendorCommunity.PortalBrandingWrapper branding;
		if(Apexpages.currentPage().getUrl() != null && Apexpages.currentPage().getUrl().toLowerCase().contains(('ChangePassword').toLowerCase()))
		{
			branding = SL_util_VendorCommunity.getPortalBranding();
		}
		else{
			branding = SL_util_VendorCommunity.getLoginBranding();
		}
		this.siteName = Site.getPathPrefix();
		
		this.fontName = branding.font;
		this.fontColor = branding.fontColor;
		this.loginBkgrdColor = branding.loginPageColor;
		this.loginPrimaryColor = branding.loginPrimaryColor;
		this.loginBtnColor = branding.loginBtnColor;
		this.loginBtnFontColor = branding.loginBtnFontColor;
		this.logoName = branding.logoName;
	}
}