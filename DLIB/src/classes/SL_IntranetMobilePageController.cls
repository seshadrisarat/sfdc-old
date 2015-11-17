public with sharing class SL_IntranetMobilePageController extends PageControllerBase {
	private final static String DEFAULT_PAGE = 'Home';
	
	public SL_IntranetMobilePageController() {
		String page = Apexpages.currentPage().getParameters().get('page');
		
		if(String.isEmpty(page)) page = DEFAULT_PAGE; 
		
		init(page, PageContext.Mobile);
	}
	
	public ApexPages.Component getMobileViewWidgets(){
        return renderRegionComponents('MobileMainSection');
    }
}