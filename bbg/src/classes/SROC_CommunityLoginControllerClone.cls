public without sharing class SROC_CommunityLoginControllerClone {

    private CORECONNECT__CC_System_Settings__c setting; 
    private CORECONNECT__CC_Header_Footer_Settings__c footerHeader; 
    private SROC_System_Settings__c objSS;
    private static final string CUSTOM_SETTING_INSTANCE_NAME = 'SROC';
    private static Integer userCount = 11591;
    private String redirectUrl;
  
  public String forgotUsername {get;set;}
    public String userPassword {get;set;}
    public User objUser {get;set;}
    public String boatNumber {get;set;}
    public String username{get;set;}
    public String password{get;set;}
    
    public PageReference login() {
      
        return Site.login(username, password, redirectUrl);
    }

    public SROC_CommunityLoginControllerClone(){ 
        userPassword = boatNumber = forgotUsername = redirectUrl = '';
        
        objUser = new User();
        objSS = SROC_System_Settings__c.getValues(CUSTOM_SETTING_INSTANCE_NAME);
        setting = CORECONNECT__CC_System_Settings__c.getInstance(Site.GetName());
        footerHeader = CORECONNECT__CC_Header_Footer_Settings__c.getInstance(Site.GetName());
        
        redirectUrl = setting.CORECONNECT__Community_Path_Name__c + '/' + setting.CORECONNECT__Community_Home__c;
      
      String startUrl = ApexPages.currentPage().getParameters().get('startUrl');
      
      if(startUrl != null && startUrl.trim() != '')
      {
        redirectUrl = startUrl.trim();
      }
    }

    String defaultValue = 'default';
    public String HeaderLogoImageURL {
        get{    
            
            if(setting==null)
                return defaultValue;
            
            return footerHeader.CORECONNECT__Header_Logo_Image_URL__c ;
        }
    }

    // Method to show Registration Page based on Valid HIN number
    @RemoteAction
    public static string validHIN(String hinNumber){
        //List<Boat__c> lstBoat = ;
        List<Boat__c> lstBoat = [SELECT Id,Name, Brand_del__c, Model_Description__c, Model_Year__c FROM Boat__c WHERE Name =: hinNumber AND Brand_del__c = 'SR'];
        if(lstBoat.isEmpty()){
            return 'Invalid';
        }
        else {

        List<Owner_Boat_Relationship__c> lstOBRelation = [ SELECT Boat_Brand__c, HIN_Number__c, SROC_Community_Status__c, Status__c 
                                                           FROM Owner_Boat_Relationship__c
                                                           WHERE HIN_Number__c =: lstBoat[0].Id
                                                           AND Boat_Brand__c = 'SR' 
                                                           AND SROC_Community_Status__c = 'Claimed'
                                                           AND Status__c = 'Active'];
        if(!lstOBRelation.isEmpty())
            return 'Claimed'; 
        else 
            return String.isNotEmpty(String.ValueOf(lstBoat[0].Model_Year__c)) ? (String.isNotEmpty(lstBoat[0].Model_Description__c) ? String.ValueOf(lstBoat[0].Model_Year__c)+' '+lstBoat[0].Model_Description__c +' <br/> HIN :' +lstBoat[0].Name : String.ValueOf(lstBoat[0].Model_Year__c) +'<br/> HIN :' +lstBoat[0].Name) : (String.isNotEmpty(lstBoat[0].Model_Description__c) ? lstBoat[0].Model_Description__c +'<br/> HIN :' +lstBoat[0].Name : 'HIN :' +lstBoat[0].Name);

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
  
    public PageReference unclaimedHIN(){
        
        String hinNumber = ApexPages.currentPage().getParameters().get('boatNumber');
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
            personAccountMatchFound(lstAccount[0].Id, hinNumber);
        else
            personAccountMatchNotFound(hinNumber);
            
        return null;

    }

    public PageReference personAccountMatchFound(Id accountId, String hinNumber){
        List<User> lstUserInfo = [ SELECT Id, AccountId FROM User Where AccountId =: accountId];

        if(!lstUserInfo.isEmpty())
            communityUserRecordFound(lstUserInfo[0].Id, hinNumber, accountId);
        else
            communityUserRecordNotFound(accountId, hinNumber);
            
        return null;

    }

    public PageReference communityUserRecordFound(Id userId, String hinNumber, Id accountId){
        // create Owner Boat Relationship
        //  activate existing User Record
        // Change pwd passed in Registration
        // Update Community user with Registration  
    try{
      createOwnerBoatRelationship(hinNumber, accountId);
          
          objUser.Id = userId;
          objUser.IsActive = true; 
          update objUser;
          
          System.setPassword(objUser.Id, userPassword);
          
          //return Site.login([Select username FROM User WHERE Id=: objUser.Id].username, userPassword, redirectUrl);
    }
    catch(Exception ce){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ce.getMessage()));
    }
     
    return null;
    }

    public PageReference communityUserRecordNotFound(Id accountId, String hinNumber){
        // Create COmmunity user with existing matched Account
        User commUser = createCommunityUser(accountId);
        Id boatId = fetchBoat(hinNumber);
        List<Owner_Boat_Relationship__c> lstOWR = [SELECT id FROM Owner_Boat_Relationship__c WHERE HIN_Number__c =: boatId AND Owner__c =: accountId];

        try{
          insert commUser;
          System.setPassword(commUser.Id, userPassword);
          if(!lstOWR.isEmpty())
            update new Owner_Boat_Relationship__c(id = lstOWR[0].id, SROC_Community_Status__c = 'Claimed', Status__c = 'Active');
          else
            createOwnerBoatRelationship(hinNumber, accountId);
                 
           //return Site.login([Select username FROM User WHERE Id=: commUser.Id].username, userPassword, redirectUrl);
        }
        catch(Exception ex){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
        return null;
    }

    public PageReference personAccountMatchNotFound(String hinNumber){
        // Create community user and Person Account
        Account account = createPersonAccount(hinNumber);
        User objCommUser = createCommunityUser(account.Id);
    
    try{
          insert objCommUser;
          System.setPassword(objCommUser.Id, userPassword);
          createOwnerBoatRelationship(hinNumber, account.Id);

            system.debug('---userPassword--'+userPassword);
            system.debug('---Email--'+[Select Email FROM User WHERE Id=: objCommUser.Id].Email);
            system.debug('---redirectUrl--'+redirectUrl);
          //return Site.login([Select Email FROM User WHERE Id=: objCommUser.Id].Email, userPassword, redirectUrl);
          //login();
    }
    catch(Exception e){
      system.debug('--Exception-'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
    
    return null;
    }

    public PageReference claimedHIN(){   

      objUser = new User();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Boat is already registered in the Community!'));
        
        return null;
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
        //Integer userCounter = Integer.valueOf(math.rint(math.random()*100));

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
            ProfileId = objSS.Owner_CCU_Profile_Id__c,
            CommunityNickname = objUser.CommunityNickname, 
            Title = 'Title11',
            City = objUser.City,
            State = objUser.State,
            Street = objUser.Street,
            CompanyName = 'testCompanyName',
            Phone = objUser.Phone,
            Extension = 'testExtension',
            PostalCode = objUser.PostalCode,
            ContactId = objContId.Id
            
        );
        return u;
    }
    
    private void createOwnerBoatRelationship(String hinNumber, Id personAccId){

      Id boat = fetchBoat(hinNumber);

      insert new Owner_Boat_Relationship__c(HIN_Number__c = boat, SROC_Community_Status__c = 'Claimed', Status__c = 'Active', Owner__c = personAccId);
      
    }
    
    private Id fetchBoat(String hinNumber){
      return [SELECT id FROM Boat__c WHERE Name =: hinNumber LIMIT 1].id;
    }
    
    @RemoteAction
    public static void forgotPassword(String userEmailAddress){

    Site.forgotPassword(userEmailAddress);
    }
}