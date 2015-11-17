/*
    * Name         : OLE_Register
    * JIRA Ticket  : 
    * Author       : F8 Dev Team
    * Description  : Controller for Register Page   
*/
public class OLE_Register 
{
    public Contact contact  {   get;set;    }            // Contact object
    public String strResult {   get;set;    }           // string for register status
    
    private static string secret = 'Copy your private key here.';
    public string publicKey { get { return 'Copy your public key here.' ; }}
    private static string baseUrl = 'https://www.google.com/recaptcha/api/verify';
    public string challenge {get; set;} { challenge = null; }
    public string response {get; set; } { response = null; }
    public Boolean correctResponse { get; private set; } { correctResponse = false; }
    
    
    
    private Account objAccount;
    private Set<String> setCommunityUserEmails;         // set of existing user's email
    
    /* Start constructor */
    public OLE_Register()
    {
        initialization();
    }
    /* End constructor */
    
    /* start - initialization */
    public void initialization()
    {
        contact = new Contact();
        objAccount = new Account();
        setCommunityUserEmails = new Set<String>();
        strResult = Apexpages.currentPage().getParameters().get('result');
        fetchAllCurrentCommunityUsers();
    }
    /* End - initialization */
    
    /* start - redirectAuthenticatedUser */
    public Pagereference redirectAuthenticatedUser()
    {
        return OLE_CommonShare.redirectAuthenticatedUser('');
    }
    /* End - redirectAuthenticatedUser */
    
    /* start - fetchAllCurrentCommunityUsers */
    private void fetchAllCurrentCommunityUsers()
    {
        if(!Test.isRunningTest()) { 
            for(NetworkMember objMember :[Select    MemberId, 
                                                    Member.Email
                                          From      NetworkMember
                                          Where     NetworkId = :Network.getNetworkID()])
                setCommunityUserEmails.add(objMember.Member.Email);
        }
        else
        {
         String strUserAccountId = [Select Id, AccountId 
                                    From   User 
                                    where  Id=: UserInfo.getUserId()].AccountId;
                            
                            
          for(User objUser : [Select AccountId, Email 
                              from User 
                              where AccountId =: strUserAccountId])
            setCommunityUserEmails.add(objUser.Email);
        }
        
    }
    /* End - fetchAllCurrentCommunityUsers */
    
    /* start - validateAndSave */
    public pageReference validateAndSave() 
    {
        list<Contact> lstExistingContact = new list<Contact>();
        System.debug('======Contact'+contact+'======Email'+contact.Email);
        List<RecordType> lstRecordTypeOfContact= OLE_CommonShare.getSobjectRecords(OLE_CommonShare.prepareQuery('RecordType', 'Id, SobjectType, Name', '', '', 'SobjectType = \'Contact\' AND Name = \'Admin Contact Record Type\'', '','','')); 
        if(setCommunityUserEmails.contains(contact.Email))
            return new PageReference(Site.getBaseUrl()+'/Register?result=EXISTING_USER');     // Already a community member exists with same email.
        else
        {
            lstExistingContact = [Select    Id, 
                                            Email
                                  From      Contact 
                                  Where     Email = :contact.Email
                                  Limit     1];
           System.debug('======lstExistingContact'+lstExistingContact);
            if(!lstExistingContact.isEmpty())
                return new PageReference(Site.getBaseUrl()+'/Register?result=EXISTING_USER');
            else
            {
                objAccount = [Select Id,Name From Account Where Name like 'Ole Digital Community' Limit 1];
                contact.AccountId = objAccount.Id;
                contact.Community_Status__c = 'Requested';
                 if(!lstRecordTypeOfContact.isEmpty())
                    contact.RecordTypeId = lstRecordTypeOfContact[0].Id;
                try
                {
                    //insert contact;
                    
                    
                    if ( challenge == null || response == null ) {
                        return null;
                    }
                    HttpResponse r = makeRequest( baseUrl ,'privatekey='+ secret +
                                                  '&remoteip=' + remoteHost +
                                                  '&challenge=' + challenge +
                                                  '&response=' + response +
                                                  '&error=incorrect-captcha-sol'
                                     );
                    if ( r != null ) {
                        correctResponse = ( r.getBody().contains('true') );
                        if( correctResponse == true ) {
                            System.debug('========correct captcha');
                            insert contact;
                        }else{
                            System.debug('========incorrectcaptcha');
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill the                                                                   CAPTCHA properly.');
                            ApexPages.addMessage(myMsg);
                            return NULL;
                        }
                    }
                    return new PageReference(Site.getBaseUrl()+'/Register?result=SUCCESS');
                }
                catch(Exception ex){}
            } 
        }
        return null;
    }
    /* End - validateAndSave */
    
    /* Start - cancel */
    public pageReference cancel()
    {
         return new PageReference(Site.getBaseUrl()+'/signIn'); 
    }
    /* End - cancel */
    
    
    
    /*public pageReference verifyAndSubmit() {
        if ( challenge == null || response == null ) {
            return null;
        }
        HttpResponse r = makeRequest( baseUrl ,'privatekey='+ secret +
                                      '&remoteip=' + remoteHost +
                                      '&challenge=' + challenge +
                                      '&response=' + response +
                                      '&error=incorrect-captcha-sol'
                         );
        if ( r != null ) {
            correctResponse = ( r.getBody().contains('true') );
            if( correctResponse == true ) {
                insert enquiryObj;
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill the value in                                                                   CAPTCHA properly.');
                ApexPages.addMessage(myMsg);
                return NULL;
            }
        }
        return null;
    }*/
 
    public static HttpResponse makeRequest(string url, string body) {
        HttpRequest req = new HttpRequest();
        HttpResponse response = null;
        req.setEndpoint( url );
        req.setMethod('POST');
        req.setBody ( body);
        try {
            Http http = new Http();
            response = http.send(req);
        }catch( System.Exception e) {
            System.debug('ERROR: '+ e);
        }
        return response;
    }
 
    public string remoteHost {
        get{
            string ret = '127.0.0.1';
            // also could use x-original-remote-host
            map<string , string> hdrs = ApexPages.currentPage().getHeaders();
            if ( hdrs.get('x-original-remote-addr') != null)
                ret = hdrs.get('x-original-remote-addr');
            else if ( hdrs.get('X-Salesforce-SIP') != null)
                ret = hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
}