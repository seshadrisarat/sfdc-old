public with sharing class SL_ctrl_VendorDirectory {
		
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
	public String accountId {get;set;}
	public List<Account_Portal__c> vendors {get;set;}

	public SL_ctrl_VendorDirectory() {
		ApexPages.currentPage().getCookies().remove('brandingCookie');
		ApexPages.currentPage().getCookies().remove('accountCookie');
		this.siteName = Site.getPathPrefix();
		setSiteBranding();
		vendors = [SELECT Account_Portal__r.Id, Account_Portal__r.Name, Portal__r.Unique_Id__c FROM Account_Portal__c];
	}

	/*
	 * Query the Portal Branding record associated with the current user
	 * Use the data to set the css properties
	 *
	 */
	private void setSiteBranding(){
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		this.fontName = branding.font;
		this.fontColor = branding.fontColor;
		this.loginBkgrdColor = branding.loginPageColor;
		this.loginPrimaryColor = branding.loginPrimaryColor;
		this.loginBtnColor = branding.loginBtnColor;
		this.loginBtnFontColor = branding.loginBtnFontColor;
		this.logoName = branding.logoName;
	}

	public PageReference redirect(){
		Cookie accountCookie = new Cookie('accountCookie',accountId,null,-1,false);
		Cookie brandingCookie = new Cookie('brandingCookie',brandingId,null,-1,false);
   		ApexPages.currentPage().setCookies(new Cookie[] {accountCookie, brandingCookie});

   		return new PageReference(siteName + '/SL_VendorHome');
	}
}