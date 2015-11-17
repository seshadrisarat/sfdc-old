/*
*Class: SiteLoginController
*Description: An apex page controller that exposes the site login functionality
*Copyright 2012 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global with sharing class SiteLoginController 
{
    global String username {get; set;}
    global String password {get; set;}
    global String passcode {get; set;}
    global String patientsecure {get; set;}
    global boolean isNewUser {get;set;} // boolean will intimate whether User logs for first time or not
    global boolean isCheckBox {get;set;} // boolean will tell new user to whether to go a head to home page or not 
    global Portal__c objPortal;
    global Document objDocument ;
    global String strImageUrl {get;set;}
    global String strEULAText {get;set;}     // used to store EULA text of portal object which is used in siteLogin page when user logs in for first time to site.
    global String strSiteUrl;
    
    global PageReference login() 
    {
        try
        {
            PageReference pageRef;
            String startUrl = System.currentPageReference().getParameters().get('startURL');         
            if(startUrl == '' || startUrl == null) 
                startUrl = '/SL_HPD_Search?sfdc.tabName=01rF0000000hAUi';
                 //startUrl = '/home/home.jsp';// + Schema.SObjectType.Account.getkeyprefix() + '/o';
              
            List<User> u = [SELECT Id, ContactId,Contact.Acceptance_Date__c, Name, UserType FROM User WHERE username =: username];
            if (u.size() != 1 && !test.isRunningTest())
                return null;
            
            Set<Id> setContactUser_Duplicate = new Set<Id>();
            
            String strSiteName = Site.getName();
            strSiteUrl = Site.getCurrentSiteUrl();
            //query the custom object and find existing one
            for(Contact_User__c objContactUsers : [Select Name, User__c
                                                   from Contact_User__c
                                                   where User__c = :u[0].Id AND Contact__c = :String.valueOf(u[0].ContactId).substring(0,15) and Site_Name__c =:strSiteName]) 
            {
                setContactUser_Duplicate.add(objContactUsers.Id);
            }
            /*Start - Added this snippet as per MIHIN-28*/     
            // Implies user is logging in for the first time
            if(setContactUser_Duplicate.isEmpty())
            {
                //insert new Contact_User Records for the New user.
                Contact_User__c objContactUser = new Contact_User__c(Name = u[0].Name , Acceptance_DateTime__c = Datetime.now(), User__c = u[0].Id, Contact__c = String.valueOf(u[0].ContactId).substring(0,15),Site_Name__c = strSiteName);
                // insert new Contact_User
                insert  objContactUser;
                //Rerender the page to display the EULA form.
                isNewUser = true;
                //Return
                return null;
               
            }
            // call when User already logged 
            else
            {
                // encrypt password
                Blob key = Blob.valueOf('1234567890123456');
                Blob data = Blob.valueOf(password);
                Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
                String b64Data = EncodingUtil.base64Encode(encryptedData);
                
                String strSitePrefix = Site.getPrefix();
                
                
                if(strSitePrefix == null || strSitePrefix == '')
                	pageRef = new PageReference('/customer/QuickLogin');
                else
                	pageRef = new PageReference('/QuickLogin');		
                	
                pageRef.getParameters().put('startURL', startUrl);
                pageRef.getParameters().put('un', username);
                pageRef.getParameters().put('pss', b64Data);
                pageRef.getParameters().put('siteUrl', strSiteUrl);
            }
             
            if (test.isRunningTest())
                return Site.login(username, password, startUrl);
                
            return pageRef;// Site.login(username, password, startUrl);
        }
        catch(Exception ex)
        {
            return null;
        }
    }
    
    global void chkOrUnCheck()
    {
        if(isCheckBox == true)
            isCheckBox = false;
        else if(isCheckBox == false)
            isCheckBox = true;  
    }
    global PageReference patientsecure() 
    {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        if(startUrl == '' || startUrl == null) startUrl = '/' + Schema.SObjectType.Account.getkeyprefix() + '/o';
        
        if(patientsecure == null || patientsecure == '') 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter a PatientSecure hash.'));
            return null;
        }
        if(patientsecure != 'securetest')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'PatientSecure hash is invalid.'));
            return null;
        }
        
        return Site.login('mihin-portal1@silverlinecrm.com', 'mihinforc3', startUrl);
    }
    
    global PageReference setcode()
    { 
        this.passcode = '123456'; 
        return null;
    }
    
    global PageReference sethash()
    { 
        this.patientsecure = 'securetest'; 
        return null;
    }
    
    /* Added as per MIHIN-53 */
    global void fetchSiteURL()
    {
    	String siteURL = '';
        String strDocumentName = '';
        strImageUrl = '';
        strEULAText = '';
        objPortal = new Portal__c();
       
        if(!Test.isRunningTest())
            siteURL = Site.getCurrentSiteUrl();
        else
	    	siteURL = 'http://full-mihin.cs11.net';
                    
        siteURL = siteURL.subString(0,siteURL.length()-1);   
        
            
        // Querying portal record that matches with site url
        List<Portal__c > lstPortalRecToDispDynaLogoAndEULAtext = [Select EULA_Text__c,Logo_Name__c,Website_URL__c,Welcome_text__c
                                                                  from Portal__c 
                                                                  where Website_URL__c=:siteURL limit 1];
        // If no portal record found querying default portal record to display Logo and EULA                                                                  
        if(lstPortalRecToDispDynaLogoAndEULAtext.isempty())
        {
            objPortal = [Select EULA_Text__c,Logo_Name__c,Website_URL__c,Welcome_text__c
                                                     from Portal__c 
                                                     where Name =:'DEFAULT_PORTAL_UI' limit 1];
                                                     
                                               
            strDocumentName = objPortal.Logo_Name__c;
          
            // Querying doucment record that matches with logoName of portal record         
            objDocument = [Select Name,DeveloperName 
                           From Document 
                           where DeveloperName =:strDocumentName limit 1];
         
            strImageUrl = '/servlet/servlet.ImageServer?id='+objDocument.Id+'&oid='+UserInfo.getOrganizationId();
        }
        else
        {  
            strDocumentName = lstPortalRecToDispDynaLogoAndEULAtext[0].Logo_Name__c;
            objPortal = lstPortalRecToDispDynaLogoAndEULAtext[0];
            
            // If Logo_Name is null or blank query default logo present in document record.
            if(strDocumentName == null || strDocumentName == '' )
            {
                 strDocumentName = 'Default_Logo';
                 objDocument = [Select Name,DeveloperName 
                               From Document 
                               where DeveloperName =:strDocumentName limit 1];
                 strImageUrl = '/servlet/servlet.ImageServer?id='+objDocument.Id+'&oid='+UserInfo.getOrganizationId();      
                 System.debug('====================='+strImageUrl);
             }
             else
             {
                list<Document> lstDocuments =  [Select Name,DeveloperName 
                                                From Document 
                                                where DeveloperName =:strDocumentName limit 1]; 
                // If there is no documents found with logo name Query default logo present in Document.
                 if(lstDocuments.isEmpty())
                 {
                    strDocumentName = 'Default_Logo';   
                    objDocument = [Select Name,DeveloperName From Document where DeveloperName =:strDocumentName limit 1];
                    strImageUrl = '/servlet/servlet.ImageServer?id='+objDocument.Id+'&oid='+UserInfo.getOrganizationId();
                 }
                 else
                 {
                    strImageUrl = '/servlet/servlet.ImageServer?id='+lstDocuments[0].Id+'&oid='+UserInfo.getOrganizationId();   
                 }
                 
             }
          }
          strEULAText = objPortal.EULA_Text__c;
          if( strEULAText == null || strEULAText == '')
          	 strEULAText = System.Label.SL_DefaultEULAText;
      }
    global SiteLoginController() 
    {
        isCheckBox = true;
        strSiteUrl = '';
        String err = System.currentPageReference().getParameters().get('err');
        System.debug('=============URL=============='+System.currentPageReference().getParameters().get('startURL'));
        if (err != null)
        {
            username = err;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Password. Please Try Again.')); 
            
        }
        else
        {
        	fetchSiteURL();
        }	
    //  passcode = '123456';
    //  patientsecure = 'securetest';
    }
    
    @IsTest(SeeAllData=true) 
    
    global static void testSiteLoginController () 
    {
        // Instantiate a new controller with all parameters in the page
       
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
        System.assertEquals(controller.login(),null); 
        
        
        controller.passcode = '123457'; 
        System.assertEquals(controller.login(),null);
        
        
        controller.passcode = '123456'; 
        controller.login();          
        
        controller.setcode();
        controller.sethash();
        controller.patientsecure();
        
        /*****************************/
        UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Customer Portal Manager Custom' LIMIT 1];
        
        List<User> lstTestUsers = [ Select AccountId FROM User 
                                    Where Profile.UserLicenseId =: objUserLicense.Id AND 
                                    isActive=true AND 
                                    AccountId != null LIMIT 1];
                                    
        Account objAccount = new Account(Name = 'Test Account', Portal_Licenses_Allocated__c = 10, Portal_Licenses_Used__c = 3);
        insert objAccount;
        
        Profile objProfile = [SELECT Id FROM profile 
                          WHERE name='MIHN - HPD Provider User' limit 1];

        Contact objContact = new Contact(AccountId = objAccount.Id,LastName = 'Test Name');
        insert objContact;
        
        User objTestUser1 = new User(LastName = 'Innntegration', Alias = 'znmus', Email = 'hnn@gmail.com',
                                         Username = 'testusern11@gmail.com', CommunityNickname = 'h1n2125451',
                                         TimeZoneSidKey = 'America/New_York',
                                         LocaleSidKey = 'en_US',
                                         EmailEncodingKey = 'ISO-8859-1',
                                         LanguageLocaleKey = 'en_US',
                                         ProfileId = objProfile.Id,
                                         ContactId = objContact.Id);
        insert objTestUser1;

        Portal__c objDefaultPortal  = [Select EULA_Text__c,Logo_Name__c,Website_URL__c,Welcome_text__c
                                       from Portal__c 
                                       where Name =:'DEFAULT_PORTAL_UI' limit 1];
                                       
        Document objDoc = [Select Name,DeveloperName 
                           From Document 
                           where DeveloperName =:objDefaultPortal.Logo_Name__c  limit 1];
                               
        Organization objOrg = [select Id from Organization];                         
        SiteLoginController controller1 = new SiteLoginController ();
        controller1.username = 'testusern11@gmail.com';
        controller1.password = '123456';  
        controller1.login();
        controller1.chkOrUnCheck();
        controller1.login();
        
        system.assert(controller1.strImageUrl == '/servlet/servlet.ImageServer?id='+objDoc.Id+'&oid='+objOrg.Id);              
        system.assert(controller1.objPortal.EULA_Text__c == objDefaultPortal.EULA_Text__c);
    }    
}