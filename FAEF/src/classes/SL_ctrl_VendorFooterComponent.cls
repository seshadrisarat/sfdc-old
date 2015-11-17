public with sharing class SL_ctrl_VendorFooterComponent {

	/* Portal Branding defined css */
	public String footer {get;set;}
	
	public SL_ctrl_VendorFooterComponent() {
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		this.footer = branding.footer;
	}
		
}