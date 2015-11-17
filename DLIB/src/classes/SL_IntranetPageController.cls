public with sharing class SL_IntranetPageController extends PageControllerBase {
    
    public String strLayout {get; set;}     //Used to assign Template based on Page layout
    public String logoURL {get; set;}       //Used for displaying custom logo
    public String strCommunityId {get; set;}
    
    private static Map<String, String> mapLayoutToTemplate; //Map of Page Layouts to its related Templates
    static
    {
        mapLayoutToTemplate = new Map<String, String>{
             '3 Column Layout Page' => 'SL_IntranetTemplate_3Col',
             '2 Column Layout Right Main Page' => 'SL_IntranetTemplate_2Col_LM',
             '2 Column Layout Left Main Page' => 'SL_IntranetTemplate_2Col_MR',
             '2 Column Layout Half Page' => 'SL_IntranetTemplate_2Col_LR',
             '1 Column Layout Page' => 'SL_IntranetTemplate_1Col'
        };
    }
    
    private final static String DEFAULT_PAGE = 'Home';
    
    public SL_IntranetPageController() {
        logoURL = '';
        strCommunityId = Network.getNetworkId();

        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');

        //Getting current page name from URL
        String strPageName = Apexpages.currentPage().getParameters().get('page');  
        
        if(String.isEmpty(strPageName)) strPageName = DEFAULT_PAGE; 
        
        //Query Layout for the current page
        for(Page__c objPage : [select Name, LayoutType__c from Page__c where Name =: strPageName and LayoutType__c != null limit 1])
        {
            strLayout = objPage.LayoutType__c;
        }
       
        //Query from custom setting to get logo id and prepare link for custom logo
        logoURL = fetchApplicationLogoURL();
        
        if(logoURL != null && logoURL != '')
            logoURL = '/servlet/servlet.ImageServer?id=' + logoURL + '&oid=' + UserInfo.getOrganizationId();    
        
        //based on Layout, assigning corresponding Template for the page
        if(mapLayoutToTemplate.containsKey(strLayout))      
            strLayout = mapLayoutToTemplate.get(strLayout);
        else
            strLayout = 'SL_IntranetTemplate_3Col';
        
        init(strPageName);
    }
    
    private String fetchApplicationLogoURL()
    {
        Id userId = UserInfo.getUserId();
        Id userProfileId = UserInfo.getProfileId();
        String strLogoURL = '';
        
        Map<Id, SL_CustomizableComponent__c> mapCustomizableComponent = new Map<Id, SL_CustomizableComponent__c>();
        
        //Getting customizable CSS allowed for logged in user from OWD. 
        SL_CustomizableComponent__c owdCustomizableComponent = SL_CustomizableComponent__c.getOrgDefaults();
        
        //Getting customizable CSS allowed for logged in user from User defined or Profile defined hierarchical custom setting and creating a map of them. 
        for(SL_CustomizableComponent__c objCC : [   SELECT Logo__c, SetupOwnerId, Default__c 
                                                    FROM SL_CustomizableComponent__c 
                                                    WHERE SetupOwnerId =: userId OR SetupOwnerId =: userProfileId ])
        {
            mapCustomizableComponent.put(objCC.SetupOwnerId, objCC);
        }
        
        if(mapCustomizableComponent != null && (mapCustomizableComponent.containskey(userId) || mapCustomizableComponent.containskey(userProfileId)))
        {
            if(mapCustomizableComponent.containskey(userId) && mapCustomizableComponent.get(userId).Default__c) 
                return strLogoURL;
            else if(mapCustomizableComponent.containskey(userId) && !mapCustomizableComponent.get(userId).Default__c && mapCustomizableComponent.get(userId).Logo__c != null && mapCustomizableComponent.get(userId).Logo__c != '')
                return mapCustomizableComponent.get(userId).Logo__c;
            else if(mapCustomizableComponent.containskey(userProfileId) && mapCustomizableComponent.get(userProfileId).Default__c)
                return strLogoURL;
            else if(mapCustomizableComponent.containskey(userProfileId) && !mapCustomizableComponent.get(userProfileId).Default__c && mapCustomizableComponent.get(userProfileId).Logo__c != null && mapCustomizableComponent.get(userProfileId).Logo__c != '')
                return mapCustomizableComponent.get(userProfileId).Logo__c; 
        }
        
        if(owdCustomizableComponent != null && owdCustomizableComponent.Logo__c != null && owdCustomizableComponent.Logo__c != '')
            return strLogoURL = (!owdCustomizableComponent.Default__c) ? owdCustomizableComponent.Logo__c : '';
        
        return strLogoURL;
    }
    
    public ApexPages.Component getHeaderUserInfoRegionWidgets() {
        return renderRegionComponents('HeaderUserInfo');
    }
    
    public ApexPages.Component getHeaderLogoRegionWidgets() {
        return renderRegionComponents('HeaderLogoSection');
    }
    
    public ApexPages.Component getHeaderNavigationRegionWidgets() {
        return renderRegionComponents('HeaderNavigationSection');
    }
    
    public ApexPages.Component getBannerRegionWidgets() {
        return renderRegionComponents('BannerRegion');
    }
    
    public ApexPages.Component getLeftSideBarRegionWidgets() {
        return renderRegionComponents('LeftSideBar');
    }
    
    public ApexPages.Component getMainSectionRegionWidgets() {
        return renderRegionComponents('MainSection');
    }
    
    public ApexPages.Component getRightSideBarRegionWidgets() {
        return renderRegionComponents('RightSideBar');
    }
        
    public ApexPages.Component getMobileViewWidgets(){
        return renderRegionComponents('MobileMainSection');
    }
}