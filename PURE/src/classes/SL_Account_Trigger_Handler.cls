/*
Author: Kyle Lawson
Created on: March 27, 2014
Description: Handles the Account trigger. When an Account is updated, the trigger checks the Account's contact 
information (Email address, Phone number, Mailing address, Billing Address) and checks if a corresponding Contact Info 
record exists for each field with the same information. If it does exist, that record is set as a Primary Contact Info record. If it doesn't exist, a new Contact Info record is created.
*/

public without sharing class SL_Account_Trigger_Handler{

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     
    public SL_Account_Trigger_Handler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnAfterUpdate(map<ID,Account> oldAccountMap, map<ID,Account> newAccountMap){

        handleAccountsContactInfo(getChangedAccounts(oldAccountMap, newAccountMap));
    }

    // Contains functionality around creating and updating Contact Info records when Accounts are updated
    public void handleAccountsContactInfo(map<ID, Account> changedAccounts){ 

        Map<Id, Map<String,List<Contact_Info__c>>> relatedContactInfo = findRelatedContactInfo(changedAccounts);

        upsertContactInfo(relatedContactInfo, changedAccounts);
    }

    /* Checks each Account's related Contact_Info records, if it finds any it will check to see if any 
       data has changed on the Account compared to those Contact_Info records. If any are found, it will
       return a map containing Account, Contact_Info key-pairs.
    */
    @TestVisible
    private Map<Id, Map<String,List<Contact_Info__c>>> findRelatedContactInfo(Map<ID, Account> changedAccounts){

        List<Contact_Info__c> contactInfo = [SELECT ID, Account__r.Id, Type__c, Street__c, Street_2__c, City__c, State__c, Zip__c, Phone__c, Email__c, LastModifiedDate, Date_Last_Updated_By_Trigger__c, Email_Old__c, City_Old__c, Phone_Old__c, State_Old__c, Street_Old__c, Street_2_Old__c, Zip_Old__c, Is_Primary__c
                                             FROM Contact_Info__c 
                                             WHERE Account__r.id IN :changedAccounts.keySet()];

        //Associates each Account with a map containing its contact info records associated with a type
        Map<Id, Map<String,List<Contact_Info__c>>> contactInfoMap = new Map<Id, Map<String,List<Contact_Info__c>>>();
            
        for(Contact_Info__c info : contactInfo){

            // If type is a phone type, change type to just Phone, otherwise use the actual type
            String type = (info.Type__c.equals('Phone-Home') || 
                            info.Type__c.equals('Phone-Mobile') || 
                            info.Type__c.equals('Phone-Work') ? 'Phone' : info.Type__c);

            if(!contactInfoMap.containsKey(info.Account__r.id))
                contactInfoMap.put(info.Account__r.id, new Map<String,List<Contact_Info__c>>());
            
            if(!contactInfoMap.get(info.Account__r.id).containsKey(type))
                contactInfoMap.get(info.Account__r.id).put(type, new List<Contact_Info__c>());
            
            contactInfoMap.get(info.Account__r.id).get(type).add(info);
        }

        return contactInfoMap;
    }

    /* Takes a map of Account and Contact Info pairs which have been changed and determines whether to insert a new contact record for Accounts without any Contact Info, or simply update an existing Contact Info*/
    @TestVisible
    private void upsertContactInfo(Map<Id, Map<String,List<Contact_Info__c>>> contactInfo, Map<ID, Account> changedAccounts){

        if(changedAccounts.size() == 0)
            return;
        
        List<Contact_Info__c> toUpsert = new List<Contact_Info__c>();

        // Loop through each Account and check if a list of Contact_Info records was found
        for(Account acc : changedAccounts.values()){
            
            if(contactInfo.containsKey(acc.Id))
            {
                if(contactInfo.get(acc.Id).containsKey('Email'))
                {
                    List<Contact_Info__c> ciList = contactInfo.get(acc.Id).get('Email');
                    Boolean foundEmail = false;

                    for(Contact_Info__c ci : ciList)
                    {
                        if(emailMatches(ci, acc))
                        {
                            ci.Is_Primary__c = true;
                            foundEmail = true;
                            toUpsert.add(ci);
                        }
                        else // Email address didn't match
                        {
                            // Update Contact Info if it is currently true
                            if(ci.Is_Primary__c){
                                ci.Is_Primary__c = false;
                                toUpsert.add(ci);
                            }
                        }
                    }

                    if(!foundEmail)
                        toUpsert.add(new Contact_Info__c(Email__c=acc.Primary_Email__c,
                                                        Type__c='Email',
                                                        Is_Primary__c=true, 
                                                        Account__c=acc.Id));
                }
                else
                {
                    toUpsert.add(new Contact_Info__c(Email__c=acc.Primary_Email__c,
                                                    Type__c='Email',
                                                    Is_Primary__c=true, 
                                                    Account__c=acc.Id));
                }

                if(contactInfo.get(acc.Id).containsKey('Phone'))
                {
                    List<Contact_Info__c> ciList = contactInfo.get(acc.Id).get('Phone');
                    Boolean foundPhone = false;

                    for(Contact_Info__c ci : ciList)
                    {
                        if(phoneMatches(ci, acc))
                        {
                            ci.Is_Primary__c = true;
                            foundPhone = true;
                            toUpsert.add(ci);
                        }
                        else // Email address didn't match
                        {
                            // Update Contact Info if it is currently true
                            if(ci.Is_Primary__c){
                                ci.Is_Primary__c = false;
                                toUpsert.add(ci);
                            }
                        }
                    }

                    if(!foundPhone){
                        toUpsert.add(new Contact_Info__c(Phone__c=acc.Phone, 
                                                        Is_Primary__c=true, 
                                                        Account__c=acc.Id, 
                                                        Type__c ='Phone-Home'));
                    }
                    
                }
                else
                {
                    toUpsert.add(new Contact_Info__c(Phone__c=acc.Phone, 
                                                    Is_Primary__c=true, 
                                                    Account__c=acc.Id, 
                                                    Type__c = 'Phone-Home'));
                }

                if(contactInfo.get(acc.Id).containsKey('Mailing'))
                {
                    List<Contact_Info__c> ciList = contactInfo.get(acc.Id).get('Mailing');
                    Boolean foundMailing = false;

                    for(Contact_Info__c ci : ciList)
                    {
                        if(mailingMatches(ci, acc))
                        {
                            ci.Is_Primary__c = true;
                            foundMailing = true;
                            toUpsert.add(ci);
                        }
                        else // Email address didn't match
                        {
                            // Update Contact Info if it is currently true
                            if(ci.Is_Primary__c){
                                ci.Is_Primary__c = false;
                                toUpsert.add(ci);
                            }
                        }
                    }

                    if(!foundMailing)
                        toUpsert.add(new Contact_Info__c(Street__c = acc.ShippingStreet,
                                                        City__c = acc.ShippingCity,
                                                        State__c = acc.ShippingState,
                                                        Zip__c = acc.ShippingPostalCode,
                                                        Is_Primary__c=true,
                                                        Type__c = 'Mailing',
                                                        Account__c=acc.Id));
                    
                }
                else
                {
                    toUpsert.add(new Contact_Info__c(Street__c = acc.ShippingStreet,
                                                    City__c = acc.ShippingCity,
                                                    State__c = acc.ShippingState,
                                                    Zip__c = acc.ShippingPostalCode,
                                                    Is_Primary__c=true,
                                                    Type__c = 'Mailing',
                                                    Account__c=acc.Id));
                }

                if(contactInfo.get(acc.Id).containsKey('Billing'))
                {
                    List<Contact_Info__c> ciList = contactInfo.get(acc.Id).get('Billing');
                    Boolean foundBilling = false;

                    for(Contact_Info__c ci : ciList)
                    {
                        if(billingMatches(ci, acc))
                        {
                            ci.Is_Primary__c = true;
                            foundBilling = true;
                            toUpsert.add(ci);
                        }
                        else // Email address didn't match
                        {
                            // Update Contact Info if it is currently true
                            if(ci.Is_Primary__c){
                                ci.Is_Primary__c = false;
                                toUpsert.add(ci);
                            }
                        }
                    }

                    if(!foundBilling)
                        toUpsert.add(new Contact_Info__c(Street__c = acc.BillingStreet,
                                                        City__c = acc.BillingCity,
                                                        State__c = acc.BillingState,
                                                        Zip__c = acc.BillingPostalCode,
                                                        Is_Primary__c=true,
                                                        Type__c = 'Billing',
                                                        Account__c=acc.Id));
                }
                else
                {
                    toUpsert.add(new Contact_Info__c(Street__c = acc.BillingStreet,
                                                    City__c = acc.BillingCity,
                                                    State__c = acc.BillingState,
                                                    Zip__c = acc.BillingPostalCode,
                                                    Is_Primary__c=true,
                                                    Type__c = 'Billing',
                                                    Account__c=acc.Id));
                }
            } else { // The account didn't have any Contact Info records yet, so create all four

                toUpsert.add(new Contact_Info__c(Email__c=acc.Primary_Email__c,
                                                Type__c='Email',
                                                Is_Primary__c=true, 
                                                Account__c=acc.Id));

                toUpsert.add(new Contact_Info__c(Phone__c=acc.Phone, 
                                                Is_Primary__c=true, 
                                                Account__c=acc.Id, 
                                                Type__c ='Phone-Home'));

                toUpsert.add(new Contact_Info__c(Street__c = acc.ShippingStreet,
                                                City__c = acc.ShippingCity,
                                                State__c = acc.ShippingState,
                                                Zip__c = acc.ShippingPostalCode,
                                                Is_Primary__c=true,
                                                Type__c = 'Mailing',
                                                Account__c=acc.Id));

                toUpsert.add(new Contact_Info__c(Street__c = acc.BillingStreet,
                                                City__c = acc.BillingCity,
                                                State__c = acc.BillingState,
                                                Zip__c = acc.BillingPostalCode,
                                                Is_Primary__c=true,
                                                Type__c = 'Billing',
                                                Account__c=acc.Id));
            }
        }

        // Upsert all new records
        if(toUpsert.size() > 0){
            //System.debug('# of records to upsert: ' + toUpsert.size());
            Database.upsert(toUpsert, false);
        }
    }

    // Returns true if all new or all old fields on Contact Info match their Account counterparts
    private Boolean emailMatches(Contact_Info__c ci, Account acc){
        return ci.Email__c == acc.Primary_Email__c || ci.Email_Old__c == acc.Primary_Email__c;
    }
        
    // Returns true if all new or all old fields on Contact Info match their Account counterparts
    private Boolean phoneMatches(Contact_Info__c ci, Account acc){
        return ci.Phone__c == acc.Phone || ci.Phone_Old__c == acc.Phone;
    }

    // Returns true if all new or all old fields on Contact Info match their Account counterparts
    private Boolean mailingMatches(Contact_Info__c ci, Account acc){
        return (ci.Street__c == acc.ShippingStreet && 
                ci.State__c == acc.ShippingState && 
                ci.Zip__c == acc.ShippingPostalCode && 
                ci.City__c == acc.ShippingCity) ||
                (ci.Street_Old__c == acc.ShippingStreet && 
                    ci.State_Old__c == acc.ShippingState && 
                    ci.Zip_Old__c == acc.ShippingPostalCode && 
                    ci.City_Old__c == acc.ShippingCity);
    }

    // Returns true if all new or all old fields on Contact Info match their Account counterparts
    private Boolean billingMatches(Contact_Info__c ci, Account acc){
        return (ci.Street__c == acc.BillingStreet && 
                ci.State__c == acc.BillingState && 
                ci.Zip__c == acc.BillingPostalCode && 
                ci.City__c == acc.BillingCity) ||
                (ci.Street_Old__c == acc.BillingStreet && 
                    ci.State_Old__c == acc.BillingState && 
                    ci.Zip_Old__c == acc.BillingPostalCode && 
                    ci.City_Old__c == acc.BillingCity);
    }

    // Returns list of accounts where old fields != new fields
    private Map<Id, Account> getChangedAccounts(map<ID,Account> oldAccountMap, map<ID,Account> newAccountMap){
        Map<ID, Account> changedAccounts = new Map<ID, Account>();
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();

        for(Id oldId : oldAccountMap.keySet()){

            Account oldAcc = oldAccountMap.get(oldId);
            Account newAcc = newAccountMap.get(oldId);

            if((oldAcc.Phone != newAcc.Phone ||
                oldAcc.Primary_Email__c != newAcc.Primary_Email__c ||
                oldAcc.ShippingStreet != newAcc.ShippingStreet ||
                oldAcc.ShippingCity != newAcc.ShippingCity ||
                oldAcc.ShippingState != newAcc.ShippingState ||
                oldAcc.ShippingPostalCode != newAcc.ShippingPostalCode ||
                oldAcc.BillingStreet != newAcc.BillingStreet ||
                oldAcc.BillingCity != newAcc.BillingCity ||
                oldAcc.BillingState != newAcc.BillingState ||
                oldAcc.BillingPostalCode != newAcc.BillingPostalCode) &&
                (newAcc.Status__c == 'Active' && rtMap.get(newAcc.RecordTypeId).getName() == 'Member')){
                changedAccounts.put(newAcc.Id, newAcc);
            }  
        }

        return changedAccounts;
    }
}