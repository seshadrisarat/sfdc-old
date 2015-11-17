public with sharing class SL_ctrl_VendorLogout {

	public String logoName {get;set;}
	public String brandingId {get;set;}

	public SL_ctrl_VendorLogout() {
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getLoginBranding();
		this.logoName = branding.logoName;
		this.brandingId = branding.uniqueId;
	}
}