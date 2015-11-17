/*
*Class: SL_EnableAccessToPartnerUsersHandler
*Description: Class to enable sharing of record of Gold Partner users on insert/update of Contact record.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public class SL_EnableAccessToPartnerUsersHandler 
{
    // Constructor
    public SL_EnableAccessToPartnerUsersHandler()
    {
        // Do nothing
    }
    
    /*  
    @MethodName : onAfterInsert
    @param      : List<Contact> lstNewContact
    @Description: Method called on event: After Insert
    */
   /* public void onAfterInsert(List<Contact> lstNewContact)
    {
        try
        {
            List<Id> lstAccountId = new List<Id>();
            List<Id> lstContactId = new List<Id>();
            List<AccountShare> lstAccountShare  = new List<AccountShare>();
            List<ContactShare> lstContactShare  = new List<ContactShare>();
            Map<Id, List<Id>> mapAccountIdToUserId  = new Map<Id, List<Id>>();
            
            // Collect AccountIds of inserted Contact records
            for(Contact objContact : lstNewContact)
            {
                if(objContact.AccountId != null)
                {
                    lstAccountId.add(objContact.AccountId);
                }
            }
            
            if(lstAccountId.isEmpty())  return;
            
            // Query users with lookups to these Account Ids 
            List<User> lstUsers = new List<User>();
            // Fetch the UserLicenseId of Gold Partner User
            UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Gold Partner' LIMIT 1];
            
            lstUsers = [Select Id, AccountId FROM User Where AccountId IN : lstAccountId AND 
                        Profile.UserLicenseId =: objUserLicense.Id AND IsActive = true];
            
            for(User objUser : lstUsers)
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
            
            for(Id accountId : mapAccountIdToUserId.keyset())
            {
                for(Id userId : mapAccountIdToUserId.get(accountId))
                {
                    AccountShare objAS = new AccountShare(AccountId = accountId,
                                                          UserOrGroupId = userId,
                                                          OpportunityAccessLevel = 'Read',
                                                          AccountAccessLevel = 'Edit');
                    lstAccountShare.add(objAS);
                }
            }
            
            for(Contact objContact : [Select Id, AccountId FROM Contact Where AccountId IN : lstAccountId])
            {
                if(mapAccountIdToUserId.containsKey(objContact.AccountId))
                {
                    for(Id userId : mapAccountIdToUserId.get(objContact.AccountId))
                    {
                        ContactShare objCS = new ContactShare( ContactId  = objContact.Id,
                                                               UserOrGroupId = userId,
                                                               ContactAccessLevel = 'Edit');
                        lstContactShare.add(objCS);
                    }
                    
                }
            }
            
            if(!lstAccountShare.isEmpty())  upsert lstAccountShare;
            if(!lstContactShare.isEmpty())  upsert lstContactShare;
        }
        catch(Exception e)
        {
        }
        
    }*/
    
    /*  
    @MethodName : onBeforeUpdate
    @param      : List<Contact> lstNewContact, Map<Id, Contact> mapOldContact
    @Description: Method called on event: Before Update
    */
   /* public void onAfterUpdate(List<Contact> lstNewContact, Map<Id, Contact> mapOldContact)
    {
        try
        {
            List<Id> lstNewAccountIdToEnableSharing = new List<Id>();
            List<Id> lstOldAccountIdToRemoveSharing = new List<Id>();
            Set<Id> setContactIds = new Set<Id>();
            
            for(Contact objContact : lstNewContact)
            {
                setContactIds.add(objContact.Id);
                if(objContact.AccountId !=  mapOldContact.get(objContact.Id).AccountId)
                {
                    lstOldAccountIdToRemoveSharing.add(mapOldContact.get(objContact.Id).AccountId);
                    lstNewAccountIdToEnableSharing.add(objContact.AccountId);
                }
            }
            
            UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Gold Partner' LIMIT 1];
            
            if(!lstNewAccountIdToEnableSharing.isEmpty())
            {
                List<AccountShare> lstAccountShare  = new List<AccountShare>();
                List<ContactShare> lstContactShare  = new List<ContactShare>();
                Map<Id, List<Id>> mapAccountIdToUserId  = new Map<Id, List<Id>>();
            
                // Query users with lookups to these Account Ids 
                List<User> lstUsers = new List<User>();
                
                // Fetch the UserLicenseId of Gold Partner User
                lstUsers = [Select Id, AccountId FROM User Where ContactId IN : setContactIds AND 
                            Profile.UserLicenseId =: objUserLicense.Id AND isActive = true];
                            
                for(User objUser : lstUsers)
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
                
                for(Id accountId : mapAccountIdToUserId.keyset())
                {
                    for(Id userId : mapAccountIdToUserId.get(accountId))
                    {
                        AccountShare objAS = new AccountShare(AccountId = accountId,
                                                              UserOrGroupId = userId,
                                                              OpportunityAccessLevel = 'Read',
                                                              AccountAccessLevel = 'Edit');
                        lstAccountShare.add(objAS);
                    }
                }
                
                for(Contact objContact : [Select Id, AccountId FROM Contact Where AccountId IN : lstNewAccountIdToEnableSharing])
                {
                    if(mapAccountIdToUserId.containsKey(objContact.AccountId))
                    {
                        for(Id userId : mapAccountIdToUserId.get(objContact.AccountId))
                        {
                            ContactShare objCS = new ContactShare( ContactId  = objContact.Id,
                                                                   UserOrGroupId = userId,
                                                                   ContactAccessLevel = 'Edit');
                            lstContactShare.add(objCS);
                        }
                    }
                }
                
                if(!lstAccountShare.isEmpty())  upsert lstAccountShare;
                if(!lstContactShare.isEmpty())  upsert lstContactShare;
            }
        }
        catch(Exception e)
        {
        }
    }*/
  
  /*
    @isTest(seeAllData = true)
    private static void test_SL_EnableAccessToPartnerUsersHandler()
    {
        UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Gold Partner' LIMIT 1];
        
        List<User> lstTestUsers = [ Select AccountId FROM User 
                                    Where Profile.UserLicenseId =: objUserLicense.Id AND 
                                    isActive=true AND 
                                    AccountId != null LIMIT 2];
        
        Contact objContact = new Contact(AccountId = lstTestUsers[0].AccountId, LastName = 'Test Name');
        insert objContact;
        
        Contact objNewContact = new Contact(Id = objContact.Id, AccountId =lstTestUsers[1].AccountId);
        update objNewContact;
        
    }*/

}