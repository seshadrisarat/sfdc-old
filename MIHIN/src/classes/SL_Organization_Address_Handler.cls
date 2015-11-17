/*
*Class: SL_Organization_Address_Handler
*Description: This class serves as handler class for Organization_Address_Trigger and is used to keep only one primary address for each type corresponding to each Organization and updating the corresponding Organization record with primary Mailing and Practice Address.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public without sharing class SL_Organization_Address_Handler
{
  private boolean m_isExecuting = false;
  private static boolean isrecursiveupdate = false;
    private integer BatchSize = 0;
    private static set<String> validAddressTypes = new set<String>{'Billing', 'Practice'};
     
    public SL_Organization_Address_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnBeforeInsert(list<Organization_Address__c> lstNewOrganizationAddress)
    {
        System.debug('OnBeforeInsert'); 
        list<Account> acctsToUpdate = new list<Account>();
        set<Id> practiceUpdated = new set<Id>();
        set<Id> billingUpdated = new set <Id>();
        map<Id,UpdatedAccount> updateAccountClass = UpdateAccountAddressWithPrimary(lstNewOrganizationAddress);
        for(UpdatedAccount ua : updateAccountClass.values()){
          acctsToUpdate.add(ua.acct);
          if(ua.practiceUpdated){
            practiceUpdated.add(ua.acct.Id);
          }
          if(ua.billingUpdated){
            billingUpdated.add(ua.acct.Id);
          }
        }
        
        if(acctsToUpdate.size() > 0){
          Update acctsToUpdate;
        }

        List<Organization_Address__c> lstOldOrganizationAddresses = new  List<Organization_Address__c>();
          
        List<Organization_Address__c> lstOldBillingOrganizationAddresses = [SELECT Id, Organization__c, Type__c FROM Organization_Address__c 
                                     WHERE Primary__c = true AND Type__c = 'Billing' AND Organization__c = :practiceUpdated AND Id != null];
        lstOldOrganizationAddresses.addAll(lstOldBillingOrganizationAddresses);
        List<Organization_Address__c> lstOldPracticeOrganizationAddresses = [SELECT Id, Organization__c, Type__c FROM Organization_Address__c 
                                     WHERE Primary__c = true AND Type__c = 'Practice' AND Organization__c = :billingUpdated and Id != null];
        lstOldOrganizationAddresses.addAll(lstOldPracticeOrganizationAddresses);

        system.debug('lstOldOrganizationAddresses (insert): ' + lstOldOrganizationAddresses);
                                     
        
        if(lstOldOrganizationAddresses.size() > 0){
          isrecursiveupdate = true;
          //Calling function to set non primary to all old Organization addresses
          updatePreviousAddresses(lstOldOrganizationAddresses);
        }

         
    }
     
    public void OnAfterInsert(map<ID,Organization_Address__c> newOrganizationAddressMap){ }
     
    @future public static void OnAfterInsertAsync(Set<ID> newOrganizationAddressIDs){ }
     
    public void OnBeforeUpdate(map<ID,Organization_Address__c> oldOrganizationAddressMap, map<ID,Organization_Address__c> newOrganizationAddressMap)
    {
      if(!isrecursiveupdate){
        isrecursiveupdate = true;

        set<Id> incomingOAs = new set<Id>();
        set<Id> updatedPrimaryOrgs = new set<Id>();
        list<Organization_Address__c> lstOrganizationAddress = new list<Organization_Address__c>();
        map<Id,UpdatedAccount> acctsToUpdate;
        list<Account> acctUpdateList = new list<Account>();
        //Iterating over Organization Address object in order to fetch the modified records only that can be passed to function
        for(Organization_Address__c objOrganizationAddress : newOrganizationAddressMap.values())
        {
          incomingOAs.add(objOrganizationAddress.Id);
        //checking the values of new map with old map in order to avoid the condition of recursion
          if( objOrganizationAddress.Primary__c == true
          &&(  oldOrganizationAddressMap.get(objOrganizationAddress.Id).Street_Address_1__c!=objOrganizationAddress.Street_Address_1__c
            || oldOrganizationAddressMap.get(objOrganizationAddress.Id).Street_Address_2__c!=objOrganizationAddress.Street_Address_2__c
            || oldOrganizationAddressMap.get(objOrganizationAddress.Id).Street_Address_3__c!=objOrganizationAddress.Street_Address_3__c
            || oldOrganizationAddressMap.get(objOrganizationAddress.Id).City__c!=objOrganizationAddress.City__c
            || oldOrganizationAddressMap.get(objOrganizationAddress.Id).State__c!=objOrganizationAddress.State__c
            || oldOrganizationAddressMap.get(objOrganizationAddress.Id).Postal_Code__c!=objOrganizationAddress.Postal_Code__c
            || oldOrganizationAddressMap.get(objOrganizationAddress.Id).County__c!=objOrganizationAddress.County__c
            || oldOrganizationAddressMap.get(objOrganizationAddress.Id).Type__c != objOrganizationAddress.Type__c
            || oldOrganizationAddressMap.get(objOrganizationAddress.Id).Primary__c == false
            )
          )
          {
             lstOrganizationAddress.add(objOrganizationAddress);          
          }
        }
        if(lstOrganizationAddress.size() > 0){
          acctsToUpdate = UpdateAccountAddressWithPrimary(lstOrganizationAddress);
          for(UpdatedAccount a : acctsToUpdate.values()){
            updatedPrimaryOrgs.add(a.acct.Id);
          }
        }
        

        for(Organization_Address__c objOrganizationAddress : newOrganizationAddressMap.values()){
        UpdatedAccount objAccount;
        if( (oldOrganizationAddressMap.get(objOrganizationAddress.Id).Type__c != objOrganizationAddress.Type__c
            && validAddressTypes.contains(oldOrganizationAddressMap.get(objOrganizationAddress.Id).Type__c)
            && objOrganizationAddress.Primary__c == true
            )
          ||(objOrganizationAddress.Primary__c == false 
            && oldOrganizationAddressMap.get(objOrganizationAddress.Id).Primary__c == true
            )
          ){
            
            if(acctsToUpdate == null){
              System.debug('!#! acctsToUpdate is null');
              acctsToUpdate = new map<Id,UpdatedAccount>();
              objAccount = new UpdatedAccount(new Account(Id = objOrganizationAddress.Organization__c),false,false);
            }
            else if(acctsToUpdate.containsKey(objOrganizationAddress.Organization__c)){
              objAccount = acctsToUpdate.get(objOrganizationAddress.Organization__c);
              System.debug('!#! acctsToUpdate contains org: ' + objAccount);
            }
            else{
              objAccount = new UpdatedAccount(new Account(Id = objOrganizationAddress.Organization__c),false,false);
              System.debug('!#! acctsToUpdate is not null, does not contain org');
            }

            if(oldOrganizationAddressMap.get(objOrganizationAddress.Id).Type__c == 'Practice' 
            && !objAccount.practiceUpdated){
              objAccount.acct.ShippingStreet = null;
              objAccount.acct.ShippingCity = null;
              objAccount.acct.ShippingState = null;
              objAccount.acct.ShippingPostalCode = null;
              objAccount.acct.ShippingCountry = null;
              objAccount.acct.Geocoding_Required__c = false;
              acctsToUpdate.put(objAccount.acct.Id, objAccount); 
            }
            else if(oldOrganizationAddressMap.get(objOrganizationAddress.Id).Type__c == 'Billing'
            && !objAccount.billingUpdated){
              objAccount.acct.BillingStreet = null;
              objAccount.acct.BillingCity = null;
              objAccount.acct.BillingState = null;
              objAccount.acct.BillingPostalCode = null;
              objAccount.acct.BillingCountry = null;
              acctsToUpdate.put(objAccount.acct.Id, objAccount); 
            }
          }
        }



        if(acctsToUpdate!= null && acctsToUpdate.size() > 0){
          set<id> practiceUpdated = new set<Id>();
          set<id> billingUpdated = new set<Id>();
          for(UpdatedAccount ua : acctsToUpdate.values()){
            acctUpdateList.add(ua.acct);
            if(ua.billingUpdated){
              billingUpdated.add(ua.acct.Id);
            }
            if(ua.practiceUpdated){
              practiceUpdated.add(ua.acct.Id);
            }
          }
          Update acctUpdateList;

                    
          List<Organization_Address__c> lstOldOrganizationAddresses = new  List<Organization_Address__c>();
          
          List<Organization_Address__c> lstOldBillingOrganizationAddresses = [SELECT Id, Organization__c, Type__c FROM Organization_Address__c 
                                     WHERE Primary__c = true AND Organization__c =: billingUpdated AND Type__c = 'Billing' 
                                     AND Id != :incomingOAs];
          lstOldOrganizationAddresses.addAll(lstOldBillingOrganizationAddresses);
          List<Organization_Address__c> lstOldPracticeOrganizationAddresses = [SELECT Id, Organization__c, Type__c FROM Organization_Address__c 
                                     WHERE Primary__c = true AND Organization__c =: practiceUpdated AND Type__c = 'Practice'
                                     AND Id != :incomingOAs];
          lstOldOrganizationAddresses.addAll(lstOldPracticeOrganizationAddresses);

          system.debug('lstOldOrganizationAddresses: ' + lstOldOrganizationAddresses);
                                     
        
          if(lstOldOrganizationAddresses.size() > 0){
            //Calling function to set non primary to all old Organization addresses
            updatePreviousAddresses(lstOldOrganizationAddresses);
          }

        }
      }
    }

    private map<Id,UpdatedAccount> UpdateAccountAddressWithPrimary(list<Organization_Address__c> lstNewOrganizationAddress){
      set<Id> incomingOAs = new set<Id>();
      Set<Id> setOrganization = new Set<Id>();//Set of all the Organization ids
      Set<Organization_Address__c> setorganizationAddress = new Set<Organization_Address__c>();//Set of all the Organization address records
      map<Id, Organization_Address__c> orgToPracticeAddress = new map<Id, Organization_Address__c>();
      map<Id, Organization_Address__c> orgToBillingAddress = new map<Id, Organization_Address__c>();
      map<Id,UpdatedAccount> acctsToUpdate = new map<Id,UpdatedAccount>();//List of the updated Accounts
      
      //Iterating over list of primary Organization addresses to fill the sets
      for(Organization_Address__c objOrganizationAddress : lstNewOrganizationAddress)
      {
        System.debug('objOrganizationAddress.Id: ' + objOrganizationAddress.Id);
        if(objOrganizationAddress.Id != null){
          incomingOAs.add(objOrganizationAddress.Id);
        }
        //Checking if it is primary
        if(objOrganizationAddress.Primary__c)
        {
          if(objOrganizationAddress.Type__c == 'Practice'){
            System.debug('is primary practice!');
            System.debug('orgToPracticeAddress: ' + orgToPracticeAddress);
            System.debug('objOrganizationAddress: ' + objOrganizationAddress);
            if(!orgToPracticeAddress.containsKey(objOrganizationAddress.Organization__c)){
              orgToPracticeAddress.put(objOrganizationAddress.Organization__c, objOrganizationAddress); 
            }
            else{
              objOrganizationAddress.Primary__c = false;
            }
          } 
          else if(objOrganizationAddress.Type__c == 'Billing'){
            if(!orgToBillingAddress.containsKey(objOrganizationAddress.Organization__c)){
                orgToBillingAddress.put(objOrganizationAddress.Organization__c, objOrganizationAddress); 
            }
            else{
              objOrganizationAddress.Primary__c = false;
            }
          }
        }
      }
      setOrganization.addAll(orgToPracticeAddress.keyset());
      setOrganization.addAll(orgToBillingAddress.keyset());

      System.debug('setOrganization: ' + setOrganization);

      
      //Checking if set of Organization addresses is empty
      if(!setOrganization.isEmpty())
      {
        
        //Iterating over list of Organization addresses that are to be inserted to update corresponding Organization record.
        for(Id acctId : orgToPracticeAddress.keyset())
        {
          Account objAccount = new Account(id = acctId);
          Organization_Address__c objOrganizationAddress = orgToPracticeAddress.get(acctId);

          objAccount.ShippingStreet = concatenateAddress(objOrganizationAddress.Street_Address_1__c, objOrganizationAddress.Street_Address_2__c, objOrganizationAddress.Street_Address_3__c);
          objAccount.ShippingCity = objOrganizationAddress.City__c;
          objAccount.ShippingState = objOrganizationAddress.State__c;
          objAccount.ShippingPostalCode = objOrganizationAddress.Postal_Code__c;
          objAccount.ShippingCountry = objOrganizationAddress.County__c;
          objAccount.Geocoding_Required__c = true;
          acctsToUpdate.put(objAccount.Id, new UpdatedAccount(objAccount,false, true));         
        }
        for(Id acctId : orgToBillingAddress.keyset()){
          UpdatedAccount objAccount;
          if(acctsToUpdate.containsKey(acctId)){
            objAccount = acctsToUpdate.get(acctId);
            objAccount.billingUpdated = true;
          }
          else{
            objAccount = new UpdatedAccount(new Account(id = acctId), true, false);
          }
          Organization_Address__c objOrganizationAddress = orgToBillingAddress.get(acctId);

          objAccount.acct.BillingStreet = concatenateAddress(objOrganizationAddress.Street_Address_1__c, objOrganizationAddress.Street_Address_2__c, objOrganizationAddress.Street_Address_3__c);
          objAccount.acct.BillingCity = objOrganizationAddress.City__c;
          objAccount.acct.BillingState = objOrganizationAddress.State__c;
          objAccount.acct.BillingPostalCode = objOrganizationAddress.Postal_Code__c;
          objAccount.acct.BillingCountry = objOrganizationAddress.County__c;
          acctsToUpdate.put(objAccount.acct.Id, objAccount); 
        }
      }
      return acctsToUpdate;
    }
     
    public void OnAfterUpdate(map<ID,Organization_Address__c> oldOrganizationAddressMap, map<ID,Organization_Address__c> newOrganizationAddressMap)
    {
    }
     
    @future public static void OnAfterUpdateAsync(Set<ID> updatedOrganizationAddressIDs){ }
     
    public void OnBeforeDelete(map<ID,Organization_Address__c> oldOrganizationAddressMap){ }
     
    public void OnAfterDelete(map<ID,Organization_Address__c> oldOrganizationAddressMap){ 
      set<Id> acctsToUpdatePractice = new set<Id>();
      set<Id> acctsToUpdateBilling = new set<Id>();
      map<Id,Account> acctsToUpdate = new map<Id, Account>();
      list<Account> acctUpdateList;

      for(Organization_Address__c oa : oldOrganizationAddressMap.values()){
        if(oa.Primary__c && oa.Organization__c != null && oa.Type__c == 'Practice'){
          acctsToUpdatePractice.add(oa.Organization__c);
        }
      }
      for(Organization_Address__c oa : oldOrganizationAddressMap.values()){
        if(oa.Primary__c && oa.Organization__c != null && oa.Type__c == 'Billing'){
          acctsToUpdateBilling.add(oa.Organization__c);
        }
      }

      for(Id acctId : acctsToUpdatePractice){
        acctsToUpdate.put(acctId, 
          new Account(Id = acctId,
            ShippingStreet = null,
            ShippingCity = null,
            ShippingState = null,
            ShippingPostalCode = null,
            ShippingCountry = null,
            Geocoding_Required__c = false
          )
        );
      }

      for(Id acctId : acctsToUpdateBilling){
        Account acct;
        if(acctsToUpdate.containsKey(acctId)){
          acct = acctsToUpdate.get(acctId);
        }
        else{
          acct = new Account(Id = acctId);
        }
        acct.BillingStreet = null;
        acct.BillingCity = null;
        acct.BillingState = null;
        acct.BillingPostalCode = null;
        acct.BillingCountry = null;
        acctsToUpdate.put(acctId, acct);
      }

      if(acctsToUpdate.size() > 0){
        acctUpdateList = acctsToUpdate.values();
        update acctUpdateList;
      }
    }
     
    @future public static void OnAfterDeleteAsync(Set<ID> deletedOrganizationAddressIDs){ }
     
    public void OnBeforeUndelete(list<Organization_Address__c> restoredOrganizationAddress){ }
 
    public void OnAfterUndelete(list<Organization_Address__c> restoredOrganizationAddress){ }
             
    public boolean IsTriggerContext
    {
        get{ return m_isExecuting;}
    }
     
    public boolean IsVisualforcePageContext
    {
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsWebServiceContext
    {
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsExecuteAnonymousContext
    {
        get{ return !IsTriggerContext;}
    }
    
    /*private void updateAccountAndAddress(List<Organization_Address__c> newOrganizationAddresses)
    {
         List<String> Organizations = new List<String>();
         Set<Id> setOrganizationAddressIds = new Set<Id>();
         Set<Organization_Address__c> OrganizationAddress = new Set<Organization_Address__c>();
         for(Organization_Address__c pa : newOrganizationAddresses)
         {
            if(pa.Primary__c)
            {
                OrganizationAddress.add(pa);
                Organizations.add(pa.Organization__c);
                setOrganizationAddressIds.add(pa.Id);//collecting ids of Organization Addresses in case of update
            }
        }
        
        //check if trigger needs to actually do anything
        if(OrganizationAddress.size() !=0)
        {
          List<Organization_Address__c> oldOrganizationAddresses = [SELECT Id, Organization__c, Type__c FROM Organization_Address__c 
                                    WHERE Primary__c = true AND Id NOT IN:setOrganizationAddressIds AND Organization__c =: Organizations];
            List<Account> Accounts = new List<Account>();
            //use "static" variable to keep place in loop to reduce number of script statements (linear better than exponential)
            integer previouslyFoundOrganization = 0;
            for(Organization_Address__c pa : newOrganizationAddresses)
            {
                if(OrganizationAddress.contains(pa))
                {
                    Account c = new Account(id = pa.Organization__c);
                    for(integer j = previouslyFoundOrganization; j < oldOrganizationAddresses.size(); j++)
                    {
                        if((oldOrganizationAddresses[j].Organization__c == pa.Organization__c) && (oldOrganizationAddresses[j].Type__c == pa.Type__c))
                        {
                            oldOrganizationAddresses[j].Primary__c = false;
                            previouslyFoundOrganization = j;
                        }
                    }
                    if(pa.Type__c == 'Practice')
                    {
                        c.ShippingStreet = pa.Street_Address_1__c;
                        c.ShippingCity = pa.City__c;
                        c.ShippingState = pa.State__c;
                        c.ShippingPostalCode = pa.Postal_Code__c;
                        c.Geocoding_Required__c = true;
                    }
                    else if(pa.Type__c == 'Billing')
                    { 
                        c.BillingStreet = pa.Street_Address_1__c;
                        c.BillingCity = pa.City__c;
                        c.BillingState = pa.State__c;
                        c.BillingPostalCode = pa.Postal_Code__c;
                    }
                    Accounts.add(c);
                }
            }
            UPDATE Accounts;
            UPDATE oldOrganizationAddresses;
      }
    }*/
    
    private void updatePreviousAddresses(List<Organization_Address__c> lstOldOrganizationAddress)
    {
      //Iterating over list of updated or to be inserted Organization addresses 
      for(Organization_Address__c objOrganizationAddress : lstOldOrganizationAddress){
        objOrganizationAddress.Primary__c = false;
      }
      update lstOldOrganizationAddress;
    }
    
     /* Start - Method
       Method Name: concatenateAddress
       Arguments: street 1, street 2 and street 3
       Access: private 
       Return Type: String
       Purpose: To concatenate the addresses of street 2 and street 3 with street 1 if 2 and 3 are not blank
    */  
    private String concatenateAddress(String strStreetAddress1, String strStreetAddress2, String strStreetAddress3)
    {
    	if(strStreetAddress2!=null && strStreetAddress2!='')
    		strStreetAddress1+='\n'+strStreetAddress2;
    	if(strStreetAddress3!=null && strStreetAddress3!='')
    		strStreetAddress1+='\n'+strStreetAddress3;
    	
    	return strStreetAddress1;
    }

    private class UpdatedAccount{
      public Account acct;
      public boolean billingUpdated;
      public boolean practiceUpdated;

      public UpdatedAccount(Account a, boolean b, boolean p){
        acct = a;
        billingUpdated = b;
        practiceUpdated = p;
      }
    }
}