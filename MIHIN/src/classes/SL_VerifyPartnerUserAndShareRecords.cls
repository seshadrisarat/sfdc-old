/*
*Class: SL_VerifyPartnerUserAndShareRecords
*Description: Class to enable sharing of Account and Contact for Gold Partner users on creation of Users
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public class SL_VerifyPartnerUserAndShareRecords
{
    // Constructor
    public SL_VerifyPartnerUserAndShareRecords()
    {
        // Do nothing
    }

    /*
    @MethodName : verifyPartnerUSerAndShareAccountContactRecords
    @param      : Map<Id, User> mapNewUsers
    @Description: Method to verify License of user and share Account/Contact records of User.AccountId
    */
   /* public void verifyPartnerUSerAndShareAccountContactRecords(Map<Id, User> mapNewUsers)
    {
        try
        {
            Map<Id, List<Id>> mapAccountIdToUserId  = new Map<Id, List<Id>>();
            List<AccountShare> lstAccountShare  = new List<AccountShare>();
            List<ContactShare> lstContactShare  = new List<ContactShare>();

            // Fetch the UserLicenseId of Gold Partner User
            UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Gold Partner' LIMIT 1];

            // Query User records to filter by only "Gold Partner" license
            for(User objUser : [Select AccountId, Profile.UserLicenseId
                                FROM User Where Id IN : mapNewUsers.keyset() AND
                                isActive = true AND
                                Profile.UserLicenseId =: objUserLicense.Id])
            {
                if(mapAccountIdToUserId.containsKey(objUser.AccountId))
                {
                    mapAccountIdToUserId.get(objUser.AccountId).add(objUser.Id);
                }
                else
                {
                    mapAccountIdToUserId.put(objUser.AccountId, new List<Id>{objUser.Id});
                }
            }

            for(Id userAccountId : mapAccountIdToUserId.keyset())
            {
                for(Id userId : mapAccountIdToUserId.get(userAccountId))
                {
                    AccountShare objAS = new AccountShare(AccountId = userAccountId,
                                                          UserOrGroupId = userId,
                                                          AccountAccessLevel = 'Read',
                                                          OpportunityAccessLevel = 'Edit'
                                                          );
                    lstAccountShare.add(objAS);
                }
            }

            for(Contact objContact : [Select Id, AccountId FROM Contact Where AccountId IN : mapAccountIdToUserId.keyset()])
            {
                if(mapAccountIdToUserId.containsKey(objContact.AccountId))
                {
                    for(Id userId : mapAccountIdToUserId.get(objContact.AccountId))
                    {
                        ContactShare objCS = new ContactShare( ContactId = objContact.Id,
                                                               UserOrGroupId = userId,
                                                               ContactAccessLevel = 'Edit');
                        lstContactShare.add(objCS);
                    }
                }
            }

            if(!lstAccountShare.isEmpty())  insert lstAccountShare;
            if(!lstContactShare.isEmpty())  insert lstContactShare;
        }
        catch(Exception e)
        {
        }
    }*/

  /*  @isTest(seeAllData = true)
    private static void test_SL_VerifyPartnerUserAndShareRecords()
    {
        Profile profile = [Select Id From Profile where Name = 'System Administrator' LIMIT 1];

        Account objAccount = new Account(Name = 'Test 1');
        insert objAccount;

        Contact objContact = new Contact(AccountId = objAccount.Id, LastName = 'Test Name 1');
        insert objContact;

        User objTestUser = new User(
                                        Username = 'fji3hfs93@fubn9.com',
                                        Email = 'username@email.com',
                                        LastName = 'lastName',
                                        Alias = 'alias',
                                        ProfileID = profile.Id,
                                        LocaleSidKey = 'en_US',
                                        LanguageLocaleKey = 'en_US',
                                        TimeZoneSidKey = 'America/Los_Angeles',
                                        EmailEncodingKey='UTF-8'
                                    );

        insert objTestUser;

    }*/
}