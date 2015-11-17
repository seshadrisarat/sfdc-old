public with sharing class SL_ctrl_VendorHeaderComponent {

	/* Portal Branding defined css */
	public String vendorLogo {get;set;}
	public String headerBkgrdColor {get;set;}
	public String brandingId {get;set;}
	public Boolean isInternal {get;set;}

	/* Main constructor
	 *
	 * Get the portal branding object associated with the current user
	 * Set header CSS properties using the portal branding object
	 *
	 */
	public SL_ctrl_VendorHeaderComponent() {
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		this.vendorLogo = branding.logoName;
		this.headerBkgrdColor = branding.headerBackgroundColor;
		this.brandingId = branding.uniqueId;

		Internal_Community_Access__c access = Internal_Community_Access__c.getInstance(UserInfo.getProfileId()); 
		this.isInternal = access.Id == null ? false : true;
	}
}