public with sharing class SL_ctrl_VendorReportDetail {

	public String reportId {get;set;}
	public String siteName {get;set;}
	public String brandingId {get;set;}
	public String btnColor 	{get;set;}
	public String btnFontColor {get;set;}
	public String btnHoverColor {get;set;}
	public String btnHoverFontColor {get;set;}
	public String fontName {get;set;}

	public SL_ctrl_VendorReportDetail() {
		this.siteName = Site.getPathPrefix();
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		this.brandingId = branding.uniqueId;		
		String tempId = ApexPages.currentPage().getParameters().get('reportId');
		reportId = tempId.length() == 15 ? Id.valueOf(tempId) : tempId;
		this.btnColor = branding.activeNavColor;
		this.btnFontColor = branding.activeNavFontColor;
		this.btnHoverColor = branding.hoverNavColor;
		this.btnHoverFontColor = branding.hoverNavFontColor;
		this.fontName = branding.font;
	}

	@RemoteAction
	public static string refreshDashboard(String dashboardId){
   		System.debug(LoggingLevel.ERROR, 'remoteaction called');
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
       	
        String urlString = SL_Analytics_Endpoint__c.getInstance('Endpoint').Endpoint__c + dashboardId;

        httpReq.setMethod('PUT');
        httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        httpReq.setEndpoint(urlString);
        httpReq.setBody(urlString);
       
        httpRes = http.send(httpReq);
        return httpRes.getBody();
    }
}