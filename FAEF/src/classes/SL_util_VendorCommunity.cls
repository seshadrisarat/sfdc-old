global without sharing class SL_util_VendorCommunity {

    private static PortalBrandingWrapper currentPortalBrand;
    private static PortalBrandingWrapper currentLoginBrand;
    private static PortalMessage currentPortalMessage;
    private static List<PortalContact> currentPortalContacts;

    /*
     * Get the Portal Branding record associated with the current user
     * 
     */
    public static PortalBrandingWrapper getPortalBranding(){
        if(currentPortalBrand == null){
            Id currentUser = UserInfo.getUserId();
            String profileId = UserInfo.getProfileId();

            Internal_Community_Access__c access = Internal_Community_Access__c.getInstance(profileId); 
            
            if(access.Id != null){
                String uniqueId = ApexPages.currentPage().getParameters().get('bid');
                if(uniqueId == null && ApexPages.currentPage().getCookies().containsKey('brandingCookie')){
                    Cookie brandingCookie = ApexPages.currentPage().getCookies().get('brandingCookie');
                    uniqueId = brandingCookie.getValue();
                }

                if(uniqueId != null){
                    Portal_Branding__c branding = 
                    [SELECT Id, Name, Font__c, Font_Color__c, 
                            Header_Background_Color__c, Login_Page_Color__c, 
                            Logo_Name__c, Page_Background_Color__C, Default_Dashboard__c,
                            Primary_Color__c, Reports_Folder__c, Unique_Id__c,
                            Active_Nav_Color__c, Active_Nav_Font_Color__c,
                            Inactive_Nav_Color__c, Inactive_Nav_Font_Color__c,
                            Hover_Nav_Color__c, Hover_Nav_Font_Color__c, Footer__c,
                            Login_Primary_Color__c, Login_Button_Color__c, Login_Button_Font_Color__c,
                            Schedule_Listview__c, Opportunity_Listview__c
                    FROM Portal_Branding__c
                    WHERE Unique_Id__c =: uniqueId]; 

                    currentPortalBrand = new PortalBrandingWrapper(branding);
                }
                else{
                    Portal_Branding__c branding = 
                    [SELECT Id, Name, Font__c, Font_Color__c, 
                            Header_Background_Color__c, Login_Page_Color__c, 
                            Logo_Name__c, Page_Background_Color__C, Default_Dashboard__c,
                            Primary_Color__c, Reports_Folder__c, Unique_Id__c,
                            Active_Nav_Color__c, Active_Nav_Font_Color__c,
                            Inactive_Nav_Color__c, Inactive_Nav_Font_Color__c,
                            Hover_Nav_Color__c, Hover_Nav_Font_Color__c, Footer__c,
                            Login_Primary_Color__c, Login_Button_Color__c, Login_Button_Font_Color__c,
                            Schedule_Listview__c, Opportunity_Listview__c
                    FROM Portal_Branding__c
                    WHERE Name = 'Default Branding']; 
        
                    currentPortalBrand = new PortalBrandingWrapper(branding);
                }
            }
            else{
                List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =: currentUser)];
                Set<Id> accountIds = new Set<Id>();
                for(Contact c : contacts){
                    accountIds.add(c.AccountId);
                }

                Account_Portal__c branding = 
                [SELECT Portal__r.Id, Portal__r.Name, Portal__r.Font__c, Portal__r.Font_Color__c, 
                        Portal__r.Header_Background_Color__c, Portal__r.Login_Page_Color__c, 
                        Portal__r.Logo_Name__c, Portal__r.Page_Background_Color__C, Portal__r.Default_Dashboard__c,
                        Portal__r.Primary_Color__c, Portal__r.Reports_Folder__c, Portal__r.Unique_Id__c,
                        Portal__r.Active_Nav_Color__c, Portal__r.Active_Nav_Font_Color__c,
                        Portal__r.Inactive_Nav_Color__c, Portal__r.Inactive_Nav_Font_Color__c,
                        Portal__r.Hover_Nav_Color__c, Portal__r.Hover_Nav_Font_Color__c, Portal__r.Footer__c,
                        Portal__r.Login_Primary_Color__c, Portal__r.Login_Button_Color__c, Portal__r.Login_Button_Font_Color__c,
                        Portal__r.Schedule_Listview__c, Portal__r.Opportunity_Listview__c
                FROM Account_Portal__c
                WHERE Account_Portal__r.Id IN : accountIds]; 
    
                currentPortalBrand = new PortalBrandingWrapper(branding);
            }   
        }
        return currentPortalBrand;
    }

    public static PortalBrandingWrapper getLoginBranding(){
        if(currentLoginBrand == null){
            String uniqueId = ApexPages.currentPage().getParameters().get('bid');
            String userId = ApexPages.currentPage().getParameters().get('s1uid');
            System.debug(LoggingLevel.ERROR, userId);
            if(uniqueId != null){
                List<Portal_Branding__c> branding = 
                [SELECT Id, Name, Font__c, Font_Color__c, 
                        Header_Background_Color__c, Login_Page_Color__c, 
                        Logo_Name__c, Page_Background_Color__C, Default_Dashboard__c,
                        Primary_Color__c, Reports_Folder__c, Unique_Id__c,
                        Active_Nav_Color__c, Active_Nav_Font_Color__c,
                        Inactive_Nav_Color__c, Inactive_Nav_Font_Color__c,
                        Hover_Nav_Color__c, Hover_Nav_Font_Color__c, Footer__c,
                        Login_Primary_Color__c, Login_Button_Color__c, Login_Button_Font_Color__c,
                        Schedule_Listview__c, Opportunity_Listview__c
                FROM Portal_Branding__c
                WHERE Unique_Id__c =: uniqueId]; 

                currentLoginBrand = new PortalBrandingWrapper(branding.get(0));
            }
            else if(userId != null){
                List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =: userId)];
                Set<Id> accountIds = new Set<Id>();
                for(Contact c : contacts){
                    accountIds.add(c.AccountId);
                }

                Account_Portal__c branding = 
                [SELECT Portal__r.Id, Portal__r.Name, Portal__r.Font__c, Portal__r.Font_Color__c, 
                        Portal__r.Header_Background_Color__c, Portal__r.Login_Page_Color__c, 
                        Portal__r.Logo_Name__c, Portal__r.Page_Background_Color__C, Portal__r.Default_Dashboard__c,
                        Portal__r.Primary_Color__c, Portal__r.Reports_Folder__c, Portal__r.Unique_Id__c,
                        Portal__r.Active_Nav_Color__c, Portal__r.Active_Nav_Font_Color__c,
                        Portal__r.Inactive_Nav_Color__c, Portal__r.Inactive_Nav_Font_Color__c,
                        Portal__r.Hover_Nav_Color__c, Portal__r.Hover_Nav_Font_Color__c, Portal__r.Footer__c,
                        Portal__r.Login_Primary_Color__c, Portal__r.Login_Button_Color__c, Portal__r.Login_Button_Font_Color__c,
                        Portal__r.Schedule_Listview__c, Portal__r.Opportunity_Listview__c
                FROM Account_Portal__c
                WHERE Account_Portal__r.Id IN : accountIds]; 
    
                currentLoginBrand = new PortalBrandingWrapper(branding);
            }
            else{
                List<Portal_Branding__c> branding = 
                [SELECT Id, Name, Font__c, Font_Color__c, 
                        Header_Background_Color__c, Login_Page_Color__c, 
                        Logo_Name__c, Page_Background_Color__C, Default_Dashboard__c,
                        Primary_Color__c, Reports_Folder__c, Unique_Id__c,
                        Active_Nav_Color__c, Active_Nav_Font_Color__c,
                        Inactive_Nav_Color__c, Inactive_Nav_Font_Color__c,
                        Hover_Nav_Color__c, Hover_Nav_Font_Color__c, Footer__c,
                        Login_Primary_Color__c, Login_Button_Color__c, Login_Button_Font_Color__c,
                        Schedule_Listview__c, Opportunity_Listview__c
                FROM Portal_Branding__c
                WHERE Name =: 'Default Branding']; 

                currentLoginBrand = new PortalBrandingWrapper(branding.get(0));
            }
        }

        return currentLoginBrand;
    }

    public static PortalMessage getPortalMessage(){
        if(currentPortalMessage == null){
            if(currentPortalBrand == null){
                getPortalBranding();
            }
        
            List<Portal_Message__c> messages = 
            [SELECT Message__c, Publish_Date__c, End_Publish_Date__c
            FROM Portal_Message__c
            WHERE Portal__r.Id =: currentPortalBrand.id
            AND Publish_Date__c <= TODAY
            AND (End_Publish_Date__c > TODAY OR End_Publish_Date__c = null)
            ORDER BY Publish_Date__c DESC];
            
            currentPortalMessage = messages.size() > 0 ? new PortalMessage(messages.get(0)) : new PortalMessage(null);
        }
        return currentPortalMessage;
    }

    public static List<PortalContact> getPortalContacts(){
        if(currentPortalContacts == null){
            if(currentPortalBrand == null){
                getPortalBranding();
            }
        
            List<Portal_Contact__c> contacts = 
            [SELECT Role_Name__c, Display_Name__c, External_Portal_Image__c, Id, Contact_Email__c, Contact_Phone__c
            FROM Portal_Contact__c
            WHERE Portal_Branding__r.Id =: currentPortalBrand.id
            AND Active__c = true
            ORDER BY Order__c ASC];

            currentPortalContacts = new List<PortalContact>();
            for(Portal_Contact__c contact : contacts){
                currentPortalContacts.add(new PortalContact(contact));
            }
            
        }
        return currentPortalContacts;
    }

    public static String getCurrentAccount(){
        Id currentUser = UserInfo.getUserId();
        String profileId = UserInfo.getProfileId();

        Internal_Community_Access__c access = Internal_Community_Access__c.getInstance(profileId); 
        
        if(access.Id != null){
            System.debug(LoggingLevel.ERROR, ApexPages.currentPage().getCookies().containsKey('accountCookie'));
            return ApexPages.currentPage().getCookies().get('accountCookie').getValue();
        }
        else{
            List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =: currentUser)];
            return contacts.get(0).AccountId;
        }
    }

    public static String getChatterGroupId(){
        String acctId = getCurrentAccount();
        List<Account_Portal__c> acctPortals = [SELECT Chatter_Group_Id__c FROM Account_Portal__c WHERE Account_Portal__c =: acctId];
        return acctPortals.get(0).Chatter_Group_Id__c;
    }

    public class PortalBrandingWrapper{
        public String font;
        public String fontColor;
        public String headerBackgroundColor;
        public String logoName;
        public String pageBackgroundColor;
        public String primaryColor;
        public String reportFolder;
        public String activeNavColor;
        public String activeNavFontColor;
        public String inactiveNavColor;
        public String inactiveNavFontColor;
        public String hoverNavColor;
        public String hoverNavFontColor;
        public String footer;
        public String defaultDashboard;
        public String id;
        public String loginPageColor;
        public String loginPrimaryColor;
        public String loginBtnColor;
        public String loginBtnFontColor;
        public String uniqueId;
        public String name; 
        public String scheduleListview;
        public String opportunityListview;

        public PortalBrandingWrapper(Account_Portal__c portal){
            this.id = portal.Portal__r.Id;
            this.font = portal.Portal__r.Font__c;
            this.fontColor = portal.Portal__r.Font_Color__c;
            this.headerBackgroundColor = portal.Portal__r.Header_Background_Color__c;
            this.loginPageColor = portal.Portal__r.Login_Page_Color__c; 
            this.logoName = portal.Portal__r.Logo_Name__c;
            this.pageBackgroundColor = portal.Portal__r.Page_Background_Color__C;
            this.primaryColor = portal.Portal__r.Primary_Color__c;
            this.reportFolder = portal.Portal__r.Reports_Folder__c;
            this.activeNavColor = portal.Portal__r.Active_Nav_Color__c;
            this.activeNavFontColor = portal.Portal__r.Active_Nav_Font_Color__c;
            this.inactiveNavColor = portal.Portal__r.Inactive_Nav_Color__c;
            this.inactiveNavFontColor = portal.Portal__r.Inactive_Nav_Font_Color__c;
            this.hoverNavColor = portal.Portal__r.Hover_Nav_Color__c;
            this.hoverNavFontColor = portal.Portal__r.Hover_Nav_Font_Color__c;
            this.footer = portal.Portal__r.Footer__c;
            this.defaultDashboard = portal.Portal__r.Default_Dashboard__c;
            this.uniqueId = portal.Portal__r.Unique_Id__c;
            this.loginPrimaryColor = portal.Portal__r.Login_Primary_Color__c;
            this.loginBtnColor = portal.Portal__r.Login_Button_Color__c;
            this.loginBtnFontColor = portal.Portal__r.Login_Button_Font_Color__c;
            this.name = portal.Portal__r.Name;
            this.scheduleListview = portal.Portal__r.Schedule_Listview__c;
            this.opportunityListview = portal.Portal__r.Opportunity_Listview__c;
        }

        public PortalBrandingWrapper(Portal_Branding__c portal){
            this.id = portal.Id;
            this.font = portal.Font__c;
            this.fontColor = portal.Font_Color__c;
            this.headerBackgroundColor = portal.Header_Background_Color__c;
            this.loginPageColor = portal.Login_Page_Color__c; 
            this.logoName = portal.Logo_Name__c;
            this.pageBackgroundColor = portal.Page_Background_Color__C;
            this.primaryColor = portal.Primary_Color__c;
            this.reportFolder = portal.Reports_Folder__c;
            this.activeNavColor = portal.Active_Nav_Color__c;
            this.activeNavFontColor = portal.Active_Nav_Font_Color__c;
            this.inactiveNavColor = portal.Inactive_Nav_Color__c;
            this.inactiveNavFontColor = portal.Inactive_Nav_Font_Color__c;
            this.hoverNavColor = portal.Hover_Nav_Color__c;
            this.hoverNavFontColor = portal.Hover_Nav_Font_Color__c;
            this.footer = portal.Footer__c;
            this.defaultDashboard = portal.Default_Dashboard__c;
            this.uniqueId = portal.Unique_Id__c;
            this.loginPrimaryColor = portal.Login_Primary_Color__c;
            this.loginBtnColor = portal.Login_Button_Color__c;
            this.loginBtnFontColor = portal.Login_Button_Font_Color__c;
            this.name = portal.Name;
            this.scheduleListview = portal.Schedule_Listview__c;
            this.opportunityListview = portal.Opportunity_Listview__c;
        }
    }

    public class PortalMessage{
        public String message {get;set;}

        public PortalMessage(Portal_Message__c portalMessage){
            this.message = portalMessage == null ? ' ' : portalMessage.Message__c; 
        }
    }

    public class PortalContact{
        public String role {get;set;}
        public String name {get;set;}
        public String photo {get;set;}
        public String id {get;set;}
        public String email {get;set;}
        public String phone {get;set;}

        public PortalContact(Portal_Contact__c contact){
            this.role = contact.Role_Name__c;
            this.name = contact.Display_Name__c;
            this.photo = contact.External_Portal_Image__c;
            this.id = contact.Id;
            this.email = contact.Contact_Email__c;
            this.phone = contact.Contact_Phone__c;
        }
    }
}