/*
*  PageName       : SL_PoratalRegisterController
*  JIRATicket     : PURE-4
*  CreatedOn      : 12/26/2013
*  ModifiedBy     : Hemant
*  Description    : A custom registration page for allow the member to register for portal access.  
*/
public with sharing class SL_PortalRegisterController 
{
    // User entered details
    public String memberId {get; set{memberId = value == null ? value : value.trim(); } }
    public String zip {get; set{zip = value == null ? value : value.trim(); } }
    public String email {get; set{email = value == null ? value : value.trim(); } }
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String errorMessage {get; set;}
    public String pureTermsLinks {get;set;}
    
    // Constructor 
    public SL_PortalRegisterController()
    {
        pureTermsLinks = '';
        PortalURLMap__c oPureTerms = new PortalURLMap__c();
        oPureTerms = PortalURLMap__c.getInstance('PureTerms');
        pureTermsLinks = (oPureTerms != null) ? oPureTerms.URL__c : '#';
        password = '';  
    }
    
    public Pagereference register()
    {
        System.debug('----------------------------');
        errorMessage = '';
        
        if(zip.length() < 5)
        {
            errorMessage = 'Please Enter at least first 5 digit of your billing zip code';
            return null;
        }
        else
        {
            zip = zip.substring(0,5);
            zip = zip+'%';
        }
        
        // first look for a member that has the input member Id.
        List<Account> acc = [SELECT Id, Member_Key_EDW__c, 
                            (SELECT Id, Primary__c, FirstName, LastName 
                               FROM Contacts 
                               WHERE Primary__c = true LIMIT 1) 
                            FROM Account 
                            WHERE Member_Key_EDW__c =:memberId 
                              AND BillingPostalCode like:zip 
                              AND Id IN (SELECT Member__c 
                                       FROM Policy__c 
                                       WHERE Policy_Status__c = 'In-Force' 
                                        OR Policy_Status__c = 'Not Yet Effective')
                            LIMIT 1];
                            
        if(!acc.isEmpty())
        {

            String createUserSuccess = '';
            
            if(acc[0].Contacts != null && !acc[0].Contacts.isEmpty())
            {
                Contact primaryContact = acc[0].Contacts[0];
                String communityNickname = (primaryContact.FirstName !=null? primaryContact.Firstname.mid(0,1):'') + 
                                            primaryContact.Lastname.mid(0,5) + 
                                            acc[0].Member_Key_EDW__c;

                createUserSuccess = createPortalUser(primaryContact, acc[0].Id, communityNickname, true);
            }
            else
            {
                errorMessage = 'No Primary Household Member is associated with your Account. Please contact PURE.';
            }

            if (createUserSuccess == '') { 
                    return Site.login(email, password, '/ProfileSettingPage?isRegistered=true');
            }
            else
            {
                errorMessage = createUserSuccess;
            }
        }
        else
        {
            // need to do the lookup by the policy # instead.
            List<Policy__c> objPolicy = [Select Id,Member__c, Member__r.Member_Key_EDW__c
                                         From Policy__c 
                                         Where Policy_Number__c =: memberId 
                                          AND (Member__r.Member_Key_EDW__c != null AND Member__r.Member_Key_EDW__c != '') 
                                          AND Member__r.BillingPostalCode like :zip 
                                          AND (Policy_Status__c = 'In-Force' 
                                            OR Policy_Status__c = 'Not Yet Effective')
                                        limit 1];
            if(!objPolicy.isEmpty()) 
            {
                List<Contact> cont = [SELECT Id, FirstName, Primary__c, LastName, Account.Member_Key_EDW__c
                                    FROM Contact
                                    WHERE AccountId =: objPolicy[0].Member__c AND Primary__c = true limit 1]; 

                String createUserSuccess = '';

                if(!cont.isEmpty())
                {
                    String communityNickname = (cont[0].FirstName !=null? cont[0].Firstname.mid(0,1):'') + 
                                                cont[0].Lastname.mid(0,5)  + 
                                                cont[0].Account.Member_Key_EDW__c;

                    createUserSuccess = createPortalUser(cont[0], objPolicy[0].Member__c, communityNickname, true);
                }
                else
                {
                    errorMessage = 'No Primary Household Member is associated with your Account. Please contact PURE.';
                }

                if (createUserSuccess == '') { 
                    if (password != null && password.length() > 1) {
                        return Site.login(email, password, '/ProfileSettingPage?isRegistered=true');
                    }
                    else {
                        errorMessage = 'An error occurred while creating your account. Please contact PURE. ';
                    }
                }
                else
                {
                    errorMessage = 'An error occurred while creating your account. Please contact PURE. ';
                }
            }   
            else
            {
                // Determine if the zip code was wrong by looking for the member key or policy number
                List<Account> account = [SELECT Id
                                         FROM Account 
                                         WHERE Member_Key_EDW__c =:memberId
                                           AND Id IN (SELECT Member__c 
                                                      FROM Policy__c 
                                                      WHERE Policy_Status__c = 'In-Force' 
                                                        OR Policy_Status__c = 'Not Yet Effective')
                                         LIMIT 1];

                          if(account.size() == 0){

                            List<Policy__c> policy = [Select Id
                                                     From Policy__c 
                                                     Where Policy_Number__c =: memberId 
                                                       AND (Member__r.Member_Key_EDW__c != null 
                                                         AND Member__r.Member_Key_EDW__c != '')
                                                       AND (Policy_Status__c = 'In-Force' 
                                                         OR Policy_Status__c = 'Not Yet Effective') 
                                                     limit 1];
                                                

                                if(policy.size() == 0){
                                    errorMessage = 'The Member Id or Policy Number entered doesn\'t match any active records.';
                                } else {
                                    errorMessage = 'The zip code entered doesn\'t match the policy number on any active records.';
                                }

                          } else {
                            errorMessage = 'The zip code entered doesn\'t match the Member Id on any active records.';
                          }
            }
        }
        System.debug(errorMessage);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        return null;
    }

    public String createPortalUser(Contact primaryContact, Id acctId, String communityNickname, Boolean sendEmail){
        User newUser = new User();
        newUser.Alias = primaryContact.firstName.mid(0,1) + primaryContact.lastName.mid(0,6);
        newUser.CommunityNickname = communityNickname;
        newUser.ContactId = primaryContact.Id;
        newUser.DefaultGroupNotificationFrequency = 'N';
        newUser.DigestFrequency = 'N';
        newUser.Email = email;
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.FirstName = primaryContact.FirstName;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LastName = primaryContact.LastName;
        newUser.LocaleSidKey = 'en_US';

        List<Profile> memberProfile = [SELECT Id 
                                       FROM Profile 
                                       WHERE Name = 'Pure Customer Community Login User' LIMIT 1];
        if(memberProfile.size() == 0){
            newUser.ProfileId = '00ed0000000WxDy'; // Pure Broker View Partner Login User
        } else {
            newUser.ProfileId = memberProfile[0].Id;
        }

        newUser.TimeZoneSidKey = 'GMT';
        newUser.Username = email;
        newUser.UserPermissionsChatterAnswersUser = false;

        List<User> matchingUsers = [SELECT Id, CommunityNickname, Username, ContactId 
                                    FROM User 
                                    WHERE ContactId = :newUser.ContactId 
                                       OR CommunityNickname = :newUser.CommunityNickname 
                                       OR Username = :newUser.Username];
        if(!matchingUsers.isEmpty()){
            for(User u : matchingUsers){
                if(u.ContactId == newUser.ContactId){
                    errorMessage = 'A user already exists for the Primary Contact ' + 
                                   'associated with this Member ID or Policy Number.';
                } else if(u.Username == newUser.Username){
                    errorMessage = 'A user already exists for this email address.';
                } else if(u.CommunityNickname == newUser.CommunityNickname){
                    errorMessage = 'A user already exists with the Community Nickname ' + newUser.CommunityNickname + 
                    '. Please contact PURE. Usually this happens if an old contact\'s username changes ' + 
                    'but the community nickname wasn\'t changed.';
                }

                return errorMessage;
            }
        }

        try {
            insert newUser;
        } catch (DmlException e){
            System.debug('Failed to insert new user, received error message: ' + e.getMessage());
            errorMessage = 'There was a problem creating a new user: ' + e.getDmlMessage(0) + '. Please contact PURE.';
            return errorMessage;
        } catch (Exception e){
            System.debug('Failed to insert new user, received error message: ' + e.getMessage());
            errorMessage = 'There was a problem creating a new user: ' + e.getMessage() + '. Please contact PURE.';
            return errorMessage;
        }
        
        // Causes the user to be redirected to the change password screen on login, 
        // so they can change their password from the auto-generated salesforce password
        password = System.resetPassword(newUser.Id, false).getPassword();

        return '';
    }
}