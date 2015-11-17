public with sharing class SL_ctrl_VendorReports {
		
	public List<Report> reports {get;set;}
	public List<String> dashboardComponents {get;set;}
	public String font {get;set;}
	public String fontColor {get;set;}
	public String dashboardId {get;set;}
	public String siteName {get;set;}
	public String reportFolder;
	public String defaultDashboard;
	public String brandingId {get;set;}
	public String btnColor 	{get;set;}
	public String btnFontColor {get;set;}
	public String btnHoverColor {get;set;}
	public String btnHoverFontColor {get;set;}
	public String fontName {get;set;}

	public SL_ctrl_VendorReports() {
		this.siteName = Site.getPathPrefix();
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		this.font = branding.font;
		this.fontColor = branding.fontColor;
		this.reportFolder = branding.reportFolder;
		this.defaultDashboard = branding.defaultDashboard;
		this.brandingId = branding.uniqueId;
		this.btnColor = branding.activeNavColor;
		this.btnFontColor = branding.activeNavFontColor;
		this.btnHoverColor = branding.hoverNavColor;
		this.btnHoverFontColor = branding.hoverNavFontColor;
		this.fontName = branding.font;
		getVendorReports();
	}

	private void getVendorReports() {
		List<Folder> folders = [SELECT Id FROM Folder WHERE developername = : this.reportFolder];
		Id folderId = (folders.isEmpty()) ? null : folders.get(0).id;
		this.reports = [SELECT Id, Name, Description FROM Report WHERE OwnerId = : folderId and ownerid != null ORDER BY Name];

		List<Dashboard> dashboards = [SELECT Id FROM Dashboard WHERE DeveloperName =: this.defaultDashboard];
		if(dashboards.size() > 0){
			this.dashboardId = dashboards.get(0).Id;
		}
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