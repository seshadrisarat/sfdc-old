public with sharing class SL_ctrl_VendorNavComponent {

	/* Defines current active nav */
	public String strNavClicked {get;set;}

	/* Portal Branding defined css */
	public String primaryColor {get;set;}
	public String activeNavColor {get;set;}
	public String activeNavFontColor {get;set;}
	public String inactiveNavColor {get;set;}
	public String inactiveNavFontColor {get;set;}
	public String hoverNavColor {get;set;}
	public String hoverNavFontColor {get;set;}
	public String siteName {get;set;}
	public String brandingId {get;set;}
	public String queryString {get;set;}

	public SL_ctrl_VendorNavComponent() {
		this.siteName = Site.getPathPrefix();
		setActiveNav();
		setNavBranding();
		if(Apexpages.currentPage().getParameters().get('query') != null){
			queryString = Apexpages.currentPage().getParameters().get('query');
		}
	}

	/*
	 * Sets the string defining the current active nav
	 *
	 */
	private void setActiveNav(){
		strNavClicked = '';
		
		/* If clicked nav link is profilelink*/
		if(Apexpages.currentPage().getUrl() != null && Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorHome').toLowerCase()))
		{
			strNavClicked = 'home';
		}
		/* If clicked nav link is your policy link */
		else if(Apexpages.currentPage().getUrl() != null && 
			(Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorCalculator').toLowerCase()) || Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorLeasePaymentResult').toLowerCase())))
		{
			strNavClicked = 'calculator';
		}
		else if(Apexpages.currentPage().getUrl()!= null && 
			(Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorOpportunities').toLowerCase()) || Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorOpportunityDetail').toLowerCase())))
		{
			strNavClicked = 'opportunities';
		}
		/* If clicked nav link is Billing summary link*/
		else if(Apexpages.currentPage().getUrl()!= null && 
			(Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorSchedules').toLowerCase()) || Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorScheduleDetail').toLowerCase())))
		{
			strNavClicked = 'schedules';
		}
		/* If clicked nav link is claimstracker link*/
		else if(Apexpages.currentPage().getUrl()!= null && 
			(Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorReports').toLowerCase()) || Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorReportDetail').toLowerCase())))
		{
			strNavClicked = 'reports';
		}else if(Apexpages.currentPage().getUrl()!= null && Apexpages.currentPage().getUrl().toLowerCase().contains(('SL_VendorAttachment').toLowerCase())){
			System.debug(LoggingLevel.ERROR, 'attachemnt page');
			System.debug(LoggingLevel.ERROR, ApexPages.currentPage().getHeaders().get('Referer'));
			if(ApexPages.currentPage().getHeaders().get('Referer').toLowerCase().contains(('SL_VendorOpportunityDetail').toLowerCase())){
				strNavClicked = 'opportunities';
			}else{
				strNavClicked = 'home';
			}
		}
	}

	/*
	 * Query the Portal Branding record associated to the current user
	 * Set the css properties based on information stored in the record
	 *
	 */
	private void setNavBranding(){
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		this.primaryColor = branding.primaryColor;
		this.activeNavColor = branding.activeNavColor;
		this.activeNavFontColor = branding.activeNavFontColor;
		this.inactiveNavColor = branding.inactiveNavColor;
		this.inactiveNavFontColor = branding.inactiveNavFontColor;
		this.hoverNavColor = branding.hoverNavColor;
		this.hoverNavFontColor = branding.hoverNavFontColor;
		this.brandingId = branding.uniqueId;
	}

	public PageReference submitSearch(){
		PageReference pageRef = new PageReference(Site.getPathPrefix() + '/SL_VendorSearch?query=' + EncodingUtil.urlEncode(queryString, 'UTF-8'));
		pageRef.setRedirect(true);
		return pageRef;
	}
}