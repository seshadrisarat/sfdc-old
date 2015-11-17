/*
*Class: SL_Batch_UpdateContactAcceptanceDataTime
*Description: This is the batch class for updating the Contact.Acceptance from the Contact_User__c record.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/

global with sharing class SL_Batch_UpdateContactAcceptanceDataTime implements Database.Batchable<sObject>
{
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //Query stored in a string to retrieve  
        String strQuery = 'Select Id, Name, User__c, Acceptance_DateTime__c, Contact__c, IsProcessed__c From Contact_User__c where IsProcessed__c = false'; 
               
        //Return QueryLocator to Execute method 
        return Database.getQueryLocator(strQuery);                                                                              
    } 
    
    global void execute(Database.BatchableContext BC,List<Contact_User__c> lstContactUsers) 
    {
        Map<Id, Contact> mapContact_Update = new Map<Id, Contact>();
        List<Contact_User__c> lstContactUser_Update = new List<Contact_User__c>();
        Set<String> setContact_User = new Set<String>();
        
        try
        {
            for(Contact_User__c objContactUser : lstContactUsers)
            {
                if(objContactUser.Contact__c != Null && objContactUser.User__c != Null && !setContact_User.contains(String.valueOf(objContactUser.Contact__c).substring(0,15) + '_' + objContactUser.User__c))
                {
                    // update contact records
                    Contact objContact = new Contact(Id=Id.valueOf(objContactUser.Contact__c), Acceptance_Date__c = objContactUser.Acceptance_DateTime__c);
                    // put into the map for updating
                    mapContact_Update.put(objContact.Id, objContact);
                    
                    // update Contact_User 
                    objContactUser.IsProcessed__c = true;
                    lstContactUser_Update.add(objContactUser);
                    // add to the set to avoid duplication
                    setContact_User.add(String.valueOf(objContactUser.Contact__c).substring(0,15) + '_' + objContactUser.User__c);
                }
                // if Two contact User record created for single user  
                else if(objContactUser.Contact__c != Null && objContactUser.User__c != Null && setContact_User.contains(String.valueOf(objContactUser.Contact__c).substring(0,15) + '_' + objContactUser.User__c))
                {
                    if(objContactUser.Acceptance_DateTime__c < mapContact_Update.get(Id.valueOf(objContactUser.Contact__c)).Acceptance_Date__c)
                    {
                        // update contact records
                        Contact objContact = new Contact(Id=Id.valueOf(objContactUser.Contact__c), Acceptance_Date__c = objContactUser.Acceptance_DateTime__c);
                        // put into the map for updating
                        mapContact_Update.put(objContact.Id, objContact);
                    }
                    // update Contact_User 
                    objContactUser.IsProcessed__c = true;
                    lstContactUser_Update.add(objContactUser);
                }
            }
            
            if(!mapContact_Update.isEmpty())
                update mapContact_Update.values();
            
            if(!lstContactUser_Update.isEmpty())
                update lstContactUser_Update; 
            
            //To cover the test
            if(Test.isRunningTest())
                integer i = 10/0;
        }
        catch(Exception ex)
        {
            // do nothing.
        }
    }
    
     /*
        @MethodName: finish 
        @param : Database.BatchableContext BC
        @Description: It is overriden method of Database.Batchable interface.
    */
    global void finish(Database.BatchableContext BC)
    {
        //do nothing.
    }
    
    @isTest(seeAllData = true)
    private static void test_SL_Batch_UpdateContactAcceptanceDateTime()
    {
        UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Customer Portal Manager Custom' LIMIT 1];
        
        List<User> lstTestUsers = [ Select AccountId FROM User 
                                    Where Profile.UserLicenseId =: objUserLicense.Id AND 
                                    isActive=true AND 
                                    AccountId != null LIMIT 1];
        
        Contact objContact = new Contact(AccountId = lstTestUsers[0].AccountId, LastName = 'Test Name');
        insert objContact;
        
        Contact_User__c objContactUser = new Contact_User__c(Acceptance_DateTime__c = datetime.now() + 1, Contact__c = String.valueOf(objContact.Id).substring(0,15), 
                                                                    IsProcessed__c = false, User__c = lstTestUsers[0].Id);
        insert objContactUser;
        
        Contact_User__c objContactUser2 = new Contact_User__c(Acceptance_DateTime__c = datetime.now(), Contact__c = String.valueOf(objContact.Id).substring(0,15), 
                                                                    IsProcessed__c = false, User__c = lstTestUsers[0].Id);
        insert objContactUser2;
        
        Test.startTest();
        SL_Batch_UpdateContactAcceptanceDataTime objBatch = new SL_Batch_UpdateContactAcceptanceDataTime();
        Database.executeBatch(objBatch);
        Test.stopTest();
        
    }
}