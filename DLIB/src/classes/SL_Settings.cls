/**
 * \author Vladimir Dobrelya
 * \date 16 May 2013
 * \brief Class to retrieve the data from the custom settings
 */
public without sharing class SL_Settings {

    public static ID idStandardUserProfile {
        get {
            if ( idStandardUserProfile == null ) {
                for ( Profile oItem : [ SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1 ] ) {
                    idStandardUserProfile = oItem.Id;
                }
            }
            return idStandardUserProfile;
        } private set;
    }

    public static ID idJiraIntegrationUser {
        get {
            if ( idJiraIntegrationUser == null ) {

                if ( Test.isRunningTest() ) {                
                    User oUser = new User(
                        Alias = 'tiusr',
                        Email = 'testintegration@silverlinecrm.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'TestUserLN',
                        LanguageLocaleKey = 'en_US', 
                        LocaleSidKey = 'en_US',
                        ProfileId = idStandardUserProfile,
                        TimeZoneSidKey = 'America/Los_Angeles',
                        UserName = 'TestIntegrationUser@example.com'
                    );
                    insert oUser;
                    
                    insert new JiraIntegration__c( SFUserName__c = oUser.Email );
                }
				
                for ( User oUser : [ SELECT Id FROM User WHERE UserName = :JiraIntegration__c.getInstance().SFUserName__c limit 1 ] ) {
                    idJiraIntegrationUser = oUser.Id;
                }

                if ( idJiraIntegrationUser == null ) {
                    idJiraIntegrationUser = UserInfo.getUserId();
                }
            }
            return idJiraIntegrationUser;
        } private set;
    }
    
    public static string urlBitbucket {
        get {
            if ( urlBitbucket == null ) {
            	JiraIntegration__c cfg = JiraIntegration__c.getInstance();
                urlBitbucket = cfg.BitbucketURL__c;
            }
            return urlBitbucket;
        } private set;
    }

    public static User ProductSalesUser {
        get {
            if ( ProductSalesUser != null ) {
                return ProductSalesUser;
            }
            
            string testemail = 'ProductSalesUser@example.com';
            
            if ( Test.isRunningTest() ) {                
                User oUser = new User(
                    Alias = 'tuser1',
                    Email = testemail, 
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'TestUserLN',
                    LanguageLocaleKey = 'en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = idStandardUserProfile,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    UserName = 'ProductSalesUser@email.test'
                );
                insert oUser;
                
                insert new ProductSalesUser__c( Name = oUser.LastName, Email__c = oUser.Email, RenewalOpportunityOwner__c = false, GoogleCheckoutOwner__c = false );
            }
            
            for ( ProductSalesUser__c oSettingsItem : ProductSalesUser__c.getAll().values() ) {
            	if ( !oSettingsItem.RenewalOpportunityOwner__c && !oSettingsItem.GoogleCheckoutOwner__c) {
                    if ( Test.isRunningTest() ) { // to avoid selecting an existing custom setting, but only test
                        oSettingsItem.Email__c = testemail;
                    }
	                for ( User oUser : [ SELECT Id FROM User WHERE Email = :oSettingsItem.Email__c limit 1 ] ) {
	                    ProductSalesUser = oUser;
	                }
	                break;
            	}
            }
            
            return ProductSalesUser;
        } private set;
    }
    
    public static User RenewalOpportunityOwner {
        get {
            if ( RenewalOpportunityOwner != null ) {
                return RenewalOpportunityOwner;
            }
            
            string renewalemail = 'RenewOppOwner@email.test';
            
            if ( Test.isRunningTest() ) {                
                User oUser = new User(
                    Alias = 'tusr2',
                    Email = renewalemail, 
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'RenewalOpportunityOwnerLN',
                    LanguageLocaleKey = 'en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = idStandardUserProfile,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    UserName = 'RenewOppOwner@example.com'
                );
                insert oUser;
                
                insert new ProductSalesUser__c( Name = oUser.LastName, Email__c = oUser.Email, RenewalOpportunityOwner__c = true, GoogleCheckoutOwner__c = false );
            }
            
            for ( ProductSalesUser__c oSettingsItem : ProductSalesUser__c.getAll().values() ) {
                if ( oSettingsItem.RenewalOpportunityOwner__c ) {
                    if ( Test.isRunningTest() ) { // to avoid selecting an existing custom setting, but only test
                        oSettingsItem.Email__c = renewalemail;
                    }
                    for ( User oUser : [ SELECT Id FROM User WHERE Email = :oSettingsItem.Email__c limit 1 ] ) {
                        RenewalOpportunityOwner = oUser;
                    }
                    break;
                }
            }
            
            return RenewalOpportunityOwner;
        } private set;
    }
    
    public static User GoogleCheckoutOwner {
        get {
            if ( GoogleCheckoutOwner != null ) {
                return GoogleCheckoutOwner;
            }
            
            string googlecheckoutemail = 'GoogleCheckoutOwner@email.test';
            
            if ( Test.isRunningTest() ) {                
                User oUser = new User(
                    Alias = 'tusr3',
                    Email = googlecheckoutemail, 
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'GoogleCheckoutOwnerLN',
                    LanguageLocaleKey = 'en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = idStandardUserProfile,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    UserName = 'GoogleCheckoutOwner@example.com'
                );
                insert oUser;
                
                insert new ProductSalesUser__c( Name = oUser.LastName, Email__c = oUser.Email, RenewalOpportunityOwner__c = false, GoogleCheckoutOwner__c = true );
            }
            
            for ( ProductSalesUser__c oSettingsItem : ProductSalesUser__c.getAll().values() ) {
            	if ( oSettingsItem.GoogleCheckoutOwner__c) {
                    if ( Test.isRunningTest() ) { // to avoid selecting an existing custom setting, but only test
                        oSettingsItem.Email__c = googlecheckoutemail;
                    }
	                for ( User oUser : [ SELECT Id FROM User WHERE Email = :oSettingsItem.Email__c limit 1 ] ) {
	                    GoogleCheckoutOwner = oUser;
	                }
	                break;
            	}
            }
            
            return GoogleCheckoutOwner;
        } private set;
    }
    
    public static List<String> ErrorMessageRecipients {
        get {
            if ( ErrorMessageRecipients != null ) {
                return ErrorMessageRecipients;
            }
            
            ErrorMessageRecipients = new List<String>();
            
            for ( SendErrorMessagesTo__c oItem : SendErrorMessagesTo__c.getAll().values() ) {
                ErrorMessageRecipients.add( oItem.Name );
            }
            
            if ( ErrorMessageRecipients.isEmpty() ) {
                ErrorMessageRecipients.add( 'scott@silverlinecrm.com' );
            }
            
            return ErrorMessageRecipients;
        } private set;
    }
    
    public static Set<String> DemoEmailDomains {
        get {
            if ( DemoEmailDomains != null ) {
                return DemoEmailDomains;
            }
            
            DemoEmailDomains = new Set<String>();
            for ( DemoEmailDomains__c oItem : DemoEmailDomains__c.getAll().values() ) {
                DemoEmailDomains.add( oItem.Name );
            }
            
            return DemoEmailDomains;
        } private set;
    }
    
    public static Boolean IsDemoEmailDomain( String sEmail ) {
        if ( sEmail != null && sEmail != '' &&
            DemoEmailDomains.contains( sEmail.substring( sEmail.indexOf( '@' ), sEmail.length() ) )
        ) {
            return true;
        }
        
        return false;
    }
    
    public static String StripeTestPublishableKey {
    	get {
            return Stripe_Key__c.getValues( 'test' ).publishable_key__c;
    	}
    }
    
    public static String StripeLivePublishableKey {
    	get {
            return Stripe_Key__c.getValues( 'live' ).publishable_key__c;
    	}
    }

    public static ID idRegionAllSilveline {
        get {
            if ( idRegionAllSilveline == null ) {
                for ( pse__Region__c oItem : [ SELECT Id FROM pse__Region__c WHERE Name = 'All Silverline' limit 1 ] ) {
                    idRegionAllSilveline = oItem.Id;
                }

                if ( Test.isRunningTest() && idRegionAllSilveline == null ) {
                    pse__Region__c oRegion = new pse__Region__c(
                        Name = 'All Silverline',
                        CurrencyIsoCode = 'USD',
                        pse__Action_Update_Current_Time_Period__c = false, 
                        pse__Current_Time_Period__c = null
                    );
                    insert oRegion;

                    insert new pse__Permission_Control__c(
                        pse__User__c = UserInfo.getUserId(),
                        pse__Region__c = oRegion.Id,
                        pse__Billing__c = true,
                        pse__Timecard_Entry__c = true,
                        pse__Timecard_Ops_Edit__c = true,
                        pse__Staffing__c = true,
                        pse__Resource_Request_Entry__c = true,
                        pse__Skills_And_Certifications_View__c = true,
                        pse__Skills_And_Certifications_Entry__c = true,
                        pse__Forecast_View__c = true,
                        pse__Forecast_Edit__c = true,
                        pse__View_Task_Manager__c = true,
                        pse__Expense_Entry__c = true,
                        pse__Expense_Ops_Edit__c = true,
                        pse__Invoicing__c = true,
                        pse__Cascading_Permission__c = true
                    );

                    idRegionAllSilveline = oRegion.Id;
                }
                
                if ( idRegionAllSilveline == null ) {
                    throw new RequiredObjectNotFoundException( 'Couldn\'t find All Silverline Region.' );
                }
            }
            return idRegionAllSilveline;
        } set;
    }

    public static ID idPracticeLicenses {
        get {
            if ( idPracticeLicenses == null ) {
                for ( pse__Practice__c oItem : [ SELECT Id FROM pse__Practice__c WHERE Name = 'Licenses' limit 1 ] ) {
                    idPracticeLicenses = oItem.Id;
                }

                if ( Test.isRunningTest() && idPracticeLicenses == null ) {
                    pse__Practice__c oPractice = new pse__Practice__c( Name = 'Licenses' );
                    insert oPractice;
                    idPracticeLicenses = oPractice.Id;
                }

                if ( idPracticeLicenses == null ) {
                    throw new RequiredObjectNotFoundException( 'Couldn\'t find Licenses Practice object.' );
                }
            }
            return idPracticeLicenses;
        } set;
    }

    public static ID idStandardPricebook {
        get {
            if ( idStandardPricebook == null ) {
                for ( Pricebook2 oItem : [ SELECT Id FROM Pricebook2 WHERE IsStandard = true AND IsActive = true ] ) {
                    idStandardPricebook = oItem.Id;
                }
            }
            return idStandardPricebook;
        } private set;
    }

    private class RequiredObjectNotFoundException extends Exception { }
}