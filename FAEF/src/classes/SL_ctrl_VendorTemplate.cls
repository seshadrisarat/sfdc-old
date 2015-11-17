public with sharing class SL_ctrl_VendorTemplate {
	
	/* Portal Branding defined css */
	public String siteBkgrdColor {get;set;}
	public String fontName {get;set;}
	public String fontColor {get;set;}
	public String primaryColor {get;set;}
	public String dashboardId {get;set;}
	public String siteName {get;set;}

	public SL_ctrl_VendorTemplate() {
		this.siteName = Site.getPathPrefix();
		setSiteBranding();
	}

	/*
	 * Query the Portal Branding record associated with the current user
	 * Use the data to set the css properties
	 *
	 */
	private void setSiteBranding(){
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		this.siteBkgrdColor = branding.pageBackgroundColor;
		this.fontName = branding.font;
		this.fontColor = branding.fontColor;
		this.primaryColor = branding.primaryColor;
	}

    public PageReference forwardToCustomAuthPage(){
    	Internal_Community_Access__c access = Internal_Community_Access__c.getInstance(UserInfo.getProfileId());
    	String brandingId = ApexPages.currentPage().getParameters().get('bid');
    	if(UserInfo.getUserType() == 'Guest'){
            return new PageReference(Site.getPathPrefix() + '/SL_VendorLogin');
        }
        else if(access.Id != null && brandingId == null){
        	if(ApexPages.currentPage().getCookies().containsKey('brandingCookie')){
        		return null;
        	}
        	return new PageReference(Site.getPathPrefix() + '/SL_VendorDirectory');
        }
	    else{	
        	return null;
        }
    }
}