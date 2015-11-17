public without sharing class SROC_CommunityLoginController {

    public String userPassword {get;set;}
    public User objUser {get;set;}
    public String username{get;set;}
    public String password{get;set;}
    public String hullNumber {get;set;}
    public String error {get;set;}
    public Boolean showRegistrationPage {get;set;}
    public Boolean showMessageAfterActivation {get;set;}
    public List<Boat__c> lstBoat {get;set;}
    public Boolean rememberMe {get;set;}
    
    
    private CORECONNECT__CC_System_Settings__c setting; 
    private SROC_System_Settings__c objSS;
    private static Integer userCount = 11591;
    private String redirectUrl;
    private String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';
    private String secret;														// The keys you get by signing up for reCAPTCHA for your domain
    private String sessionId = UserInfo.getSessionId();
    
    public String sitekey {
        get { return objSS.Captcha_Public_Key__c; }
    }
    public String response  { 
        get { return ApexPages.currentPage().getParameters().get('g-recaptcha-response'); }
    }
    
    public PageReference login() {
        
        if(rememberMe) {
            Cookie c = new Cookie('usernameCookie'+sessionId, username, null, -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{c});
        } else {
            Cookie c = new Cookie('usernameCookie'+sessionId, null, null, -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{c});
        }
        return Site.login(username, password, redirectUrl);
    }

    public SROC_CommunityLoginController (){
        //rememberLogin = 'usernameCookie' + UserInfo.getUserId();
        
        COOKIE cookieInfo = ApexPages.currentPage().getCookies().get('usernameCookie'+sessionId);
        if(cookieInfo != null) {
            rememberMe = true;
            username = cookieInfo.getValue();
        }
    	
        userPassword = redirectUrl = hullNumber = error = '';
        showRegistrationPage = showMessageAfterActivation = false;
        objUser = new User();
        lstBoat = new List<Boat__c>(); 
        objSS = SROC_System_Settings__c.getInstance(Site.GetName());
        setting = CORECONNECT__CC_System_Settings__c.getInstance(Site.GetName());
        
    	secret = objSS.Captcha_Private_Key__c;
        redirectUrl = setting.CORECONNECT__Community_Path_Name__c + '/' + setting.CORECONNECT__Community_Home__c;
        
        String startUrl = ApexPages.currentPage().getParameters().get('startUrl');   
        
        if(startUrl != null && startUrl.trim() != '')
        {
            redirectUrl = startUrl.trim();
        }
    }

    public PageReference validateHIN(){
       // hullNumber
	    String responseBody = makeRequest(baseUrl,
	            'secret=' + secret +
	            '&response='+ response
	    );
	    String success = getValueFromJson(responseBody, 'success');
	    system.debug('---success--'+success);
	    if(success.equalsIgnoreCase('true')){
	        String hin = hullNumber.toUpperCase();
	        
	        lstBoat = [SELECT Id,Name, Brand_del__c, Model_Description__c, Model_Year__c FROM Boat__c WHERE Name =: hin AND Brand_del__c = 'SR'];
	        
	        if(lstBoat.isEmpty()){
	            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Invalid HIN!'));
	            error = 'Invalid HIN!';
	            return null;
	        }
	        else {
	
	            List<Owner_Boat_Relationship__c> lstOBRelation = [ SELECT Boat_Brand__c, HIN_Number__c, SROC_Community_Status__c, Status__c 
	                                                               FROM Owner_Boat_Relationship__c
	                                                               WHERE HIN_Number__c =: lstBoat[0].Id
	                                                               AND Boat_Brand__c = 'SR' 
	                                                               AND SROC_Community_Status__c = 'Claimed'
	                                                               AND Status__c = 'Active'];
	            if(!lstOBRelation.isEmpty()){
	                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Boat is already being Registered!'));
	                error = 'Boat is already being Registered!';
	                return null; 
	            }
	            else {
	                showRegistrationPage = true;
	                return null;
	            }

        }
	    }else{
	        error = 'Please verify the captcha';
	        return null;
	    }
       
       
    }

    public PageReference registerAndUpdateUser(){
        Boolean bPostalCodeValidate = validatePostalCode(objUser.PostalCode);
        system.debug('--bPostalCodeValidate--'+bPostalCodeValidate);
        if(!bPostalCodeValidate){
            //ApexPages.Message successMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'PostalCode is Invalid!');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PostalCode is Invalid!'));
            return null;
            
        }
        
        String boatNumber = hullNumber;//ApexPages.currentPage().getParameters().get('boatNumber')
      
        
        String userInfo = unclaimedHIN(boatNumber);
      
        if(!String.isBlank(userInfo) && userInfo != 'ActiveCommunityUser'){
            system.debug('---If-----');
            return Site.login(userInfo.split(':/:')[0], userInfo.split(':/:')[1], redirectUrl);
        }
        else if(userInfo == 'ActiveCommunityUser'){
            system.debug('--else if---');
        	showRegistrationPage = false;
        	showMessageAfterActivation = true;  
        	return null;
        }
        else {
            system.debug('----else');
            return null;
    
        }        
    }
    
    public PageReference loginRegisteredUser() {
        
        String homeUrl = setting.CORECONNECT__Community_Path_Name__c + '/' + setting.CORECONNECT__Community_Home__c;
        return Site.login(objUser.Email, userPassword, homeUrl);
        
    }
    
    public Boolean isError{
        get
        {
            if(ApexPages.getMessages().size() > 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
    
    public String unclaimedHIN(String hinNumber){

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        List<Account> lstAccount = [    SELECT LastName, Email__c, HIN_Number__c, Brand__c 
                                        FROM Account 
                                        WHERE Brand__c = 'SR'
                                        AND HIN_Number__c =: hinNumber
                                        AND LastName =: objUser.LastName
                                        AND PersonEmail =: objUser.Email
                                        AND RecordTypeId =: devRecordTypeId
                                   ];
        
        if(!lstAccount.isEmpty())
            return personAccountMatchFound(lstAccount[0].Id, hinNumber);
        else
            return personAccountMatchNotFound(hinNumber);
            
    }

    public String personAccountMatchFound(Id accountId, String hinNumber){
        List<User> lstUserInfo = [ SELECT Id, AccountId FROM User Where AccountId =: accountId];

        if(!lstUserInfo.isEmpty())
            return communityUserRecordFound(lstUserInfo[0].Id, hinNumber, accountId);
        else
            return communityUserRecordNotFound(accountId, hinNumber);
            
    }

    public String communityUserRecordFound(Id userId, String hinNumber, Id accountId){
        // create Owner Boat Relationship
        //  activate existing User Record
        // Change pwd passed in Registration
        // Update Community user with Registration
        system.debug('-------communityUserRecordFound-------');
        Savepoint spCUR = Database.setSavepoint();  
        try{
            createOwnerBoatRelationship(hinNumber, accountId);
            system.debug('-------updateUser---Before----');
            updateUser(userId, JSON.serialize(objUser));
            
            //System.setPassword(objUser.Id, userPassword);

            //String siteLoginInfo = formString(objUser,userPassword);
            system.debug('-------updateUser---after----');
            return 'ActiveCommunityUser';
            //return Site.login([Select username FROM User WHERE Id=: objUser.Id].username, userPassword, redirectUrl);
        }
        catch(Exception ce){
            system.debug('-------Exceptionce-------'+ce+ce.getLineNumber());
        	Database.rollback(spCUR);
        	
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ce.getMessage()));
            return '';
        }
    }
    
    @future
    public static void updateUser(Id userId, String strUser){
        
            try{
                User userToUpdate = (User)JSON.deserialize(strUser, User.class);
                
        		userToUpdate.Id = userId;
                userToUpdate.IsActive = true; 
                update userToUpdate;
                system.debug('-------userToUpdate--Future-----');
            }
            catch(DMLException dme){
                system.debug('-------DMLException-------'+dme);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dme.getMessage()));
            }
    }

    public String communityUserRecordNotFound(Id accountId, String hinNumber){
        // Create COmmunity user with existing matched Account
        User commUser = createCommunityUser(accountId);
        Id boatId = fetchBoat(hinNumber);
        List<Owner_Boat_Relationship__c> lstOWR = [SELECT id FROM Owner_Boat_Relationship__c WHERE HIN_Number__c =: boatId AND Owner__c =: accountId];
		Savepoint spCURNF = Database.setSavepoint(); 
        try{
            insert commUser;
            System.setPassword(commUser.Id, userPassword);
            if(!lstOWR.isEmpty())
                update new Owner_Boat_Relationship__c(id = lstOWR[0].id, SROC_Community_Status__c = 'Claimed', Status__c = 'Active');
            else
                createOwnerBoatRelationship(hinNumber, accountId);
            
            String siteLoginInfo = formString(commUser,userPassword);
            return siteLoginInfo;           
        }
        catch(Exception ex){
        	Database.rollback(spCURNF);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return '';
        }
        
        
    }

    public String personAccountMatchNotFound(String hinNumber){
        // Create community user and Person Account
        Account account = createPersonAccount(hinNumber);
        User objCommUser = createCommunityUser(account.Id);
        Savepoint sp = Database.setSavepoint();
        
        try{
            insert objCommUser;
            System.setPassword(objCommUser.Id, userPassword);
            createOwnerBoatRelationship(hinNumber, account.Id);

            system.debug('---userPassword--'+userPassword);
            //system.debug('---Email--'+[Select username FROM User WHERE Id=: objCommUser.Id].Email);
            system.debug('---redirectUrl--'+redirectUrl);
            String siteLoginInfo = formString(objCommUser,userPassword);
            return siteLoginInfo;
        }
        catch(Exception e){
        	Database.rollback(sp);
            system.debug('--Exception-'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return '';
        }
        
        //return null;
    }

    public Account createPersonAccount(String hinNumber){
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance(Site.GetName());
        Account personAccount = new Account(RecordTypeId = devRecordTypeId, LastName = objUser.FirstName+' '+objUser.LastName, Brand__c = 'SR', HIN_Number__c = hinNumber, ownerId= setting.Default_Person_Account_Owner_Id__c);
        insert personAccount;

        return personAccount;
    }

    public User createCommunityUser(Id accountId){
        userCount++;
        String orgSuffix = UserInfo.getOrganizationId();        
        Contact objContId = [SELECT id FROM Contact Where AccountId =: accountId];

        User u = new User(
            FirstName = objUser.FirstName,
            LastName = objUser.LastName, 
            Email = objUser.Email,
            Username = objUser.Email,
            Alias = 'tu' + String.valueOf(userCount),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1', 
            LanguageLocaleKey = 'en_US',
            ProfileId = objSS.Owner_CCL_Profile_Id__c,
            CommunityNickname = objUser.CommunityNickname, 
            Title = 'Title11',
            City = objUser.City,
            State = objUser.State,
            Street = objUser.Street,
            Country = objUser.Country,
            CompanyName = 'testCompanyName',
            Phone = objUser.Phone,
            Extension = 'testExtension',
            PostalCode = objUser.PostalCode,
            ContactId = objContId.Id
            
        );
        return u;
    }
    
    public PageReference forwardToHome(){
        
        if(CORECONNECT.CC_CommunityUtil.isPageAuthenticated())
        {
            return new PageReference(redirectUrl);
        }
        else
        {
            return null;
        }
        
    }
    
    private void createOwnerBoatRelationship(String hinNumber, Id personAccId){

        Id boat = fetchBoat(hinNumber);

        insert new Owner_Boat_Relationship__c(HIN_Number__c = boat, SROC_Community_Status__c = 'Claimed', Status__c = 'Active', Owner__c = personAccId);
        
    }
    
    private Id fetchBoat(String hinNumber){
        return [SELECT id FROM Boat__c WHERE Name =: hinNumber LIMIT 1].id;
    }

    private String formString(User objUser, String userPassword)
    {
        String username = [Select username From User WHERE id =: objUser.Id LIMIT 1].username;
        String finalString = username + ':/:' + userPassword;    
        return finalString;
    }
    
    @RemoteAction
    public static void forgotPassword(String userEmailAddress){
        system.debug('--userEmailAddress---'+userEmailAddress);
        Site.forgotPassword(userEmailAddress);
    }

    
    public Boolean validatePostalCode(String postalCode){

       Geocode_Data_Row__c geocode = SROCUtilities.postalCodeToGeocodeData(postalCode);

        if(geocode == null)
            return false;
        else
            return true;
    }
    
    // this method is called when the button is clicked
    /*public PageReference doVerify () {
        String responseBody = makeRequest(baseUrl,
                'secret=' + secret +
                '&response='+ response
        );
        String success = getValueFromJson(responseBody, 'success');
        if(success.equalsIgnoreCase('true')){
            ApexPages.Message successMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'You are really a human!');
            ApexPages.addMessage(successMsg);
        }else{
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please verify the captcha');
            ApexPages.addMessage(errorMsg);
        }
        return null;
    }*/
    
    /**
     * Make request to verify captcha
     * @return      response message from google
     */
    private static String makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        
        try {
            Http http = new Http();
            response = http.send(req);
            return response.getBody();
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return '{"success":false}';
    }   
    
    /**
     * to get value of the given json string
     * @params      
     *  - strJson       json string given
     *  - field         json key to get the value from
     * @return          string value
     */
    public static string getValueFromJson ( String strJson, String field ){
        JSONParser parser = JSON.createParser(strJson);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                if(parser.getText() == field){
                    // Get the value.
                    parser.nextToken();
                    return parser.getText();
                }
            }
        }
        return null;
    }
}