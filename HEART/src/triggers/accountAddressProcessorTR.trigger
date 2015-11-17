trigger accountAddressProcessorTR on Address__c (after insert, after update, before delete) {
    System.debug('addressProcessorTR(-Method Entry');
          
    // Create a List for accounts with address
    List<Account> accountsToUpdate = new List<Account>();
    
    /*
     * In order to correctly bulkify the trigger and avoid running into all sorts of governor limits
     * 
     *
     * Data structure will be a one-to-many between Account/Contact and Address. 
     * Our object that we will use to process all of the data will look like this:
     * Account/Contact 1 - Address 1
     *                   - Address N
     * Account/Contact 2 - Address 1
     *                   - Address N
     */

    // This object will hold the Account/Contact data we need, along with the Address objects
    List<Account> accountsWithAddress = new List<Account>{};

    // This will hold the unique set of Address Ids that are being affected by the trigger
    Set<Id> addressIds = new Set<Id>{};
    
    // In order to avoid replicating business logic, retrieve the list of records we need to work on upfront
    if( Trigger.isDelete ) {
       addressIds = Trigger.oldMap.keySet();
    } else {
       addressIds = Trigger.newMap.keySet();
    }

    // Create a Set to hold the unique Account/Contact ids
    Set<Id> accountIds = new Set<Id>{};

    // From the Communication Channel Ids, get the unique Client Ids (Account.Ids) or Contact Ids
    for(Address__c currentAddress : [SELECT Client__c FROM Address__c WHERE Id IN :addressIds] ){
        accountIds.add(currentAddress.Client__c);
    }

    // If we're deleting, omit the deleted Addresses/Comm Channels
    if( Trigger.isDelete ) {
      accountsWithAddress = [SELECT BillingCity, BillingCountry, BillingState, BillingStreet, PersonMailingCity, PersonMailingCountry, PersonMailingState, PersonMailingStreet, isPersonAccount, 
                              ( SELECT City__c, Client__c, Country__c, Ext_Id__c, Primary__c, State__c, Street_Address_1__c, Street_Address_2__c, Street_Address_3__c, Street_Address_4__c, Zip_Code__c, LastModifiedDate
                                 FROM Client_Address__r 
                                WHERE Id NOT IN :addressIds
                                 ORDER BY Primary__c DESC, Ext_Id__c DESC NULLS LAST, LastModifiedDate ASC )
                              FROM Account
                              WHERE Id IN :accountIds];
   } else {
      accountsWithAddress = [SELECT BillingCity, BillingCountry, BillingState, BillingStreet, PersonMailingCity, PersonMailingCountry, PersonMailingState, PersonMailingStreet, isPersonAccount,
                              ( SELECT City__c, Client__c, Country__c, Ext_Id__c, Primary__c, State__c, Street_Address_1__c, Street_Address_2__c, Street_Address_3__c, Street_Address_4__c, Zip_Code__c, LastModifiedDate
                                 FROM Client_Address__r 
                                 ORDER BY Primary__c DESC, Ext_Id__c DESC NULLS LAST, LastModifiedDate ASC )
                              FROM Account
                              WHERE Id IN :accountIds];
   }      

    System.debug('accountsWithAddress size=' + accountsWithAddress.size());

    // Check all of the Addresses
    for(Account accountToProcess:accountsWithAddress){
      System.debug('Processing address...');
      System.debug('Account is: ' + accountToProcess );

      if(accountToProcess.Client_Address__r.size() > 0 ) {
          System.debug('Address to process is: ' + accountToProcess.Client_Address__r[0]);

         // Populate the first record off the list, this will be the latest updated record
         if( accountToProcess.isPersonAccount ) {
            accountToProcess.PersonMailingCity = accountToProcess.Client_Address__r[0].City__c;
            accountToProcess.PersonMailingCountry = accountToProcess.Client_Address__r[0].Country__c;
            accountToProcess.PersonMailingState = accountToProcess.Client_Address__r[0].State__c;
            accountToProcess.PersonMailingStreet = accountToProcess.Client_Address__r[0].Street_Address_1__c;
            if( accountToProcess.Client_Address__r[0].Street_Address_2__c != null ) {
            accountToProcess.PersonMailingStreet = accountToProcess.PersonMailingStreet + '\n' + accountToProcess.Client_Address__r[0].Street_Address_2__c;
            }
            if( accountToProcess.Client_Address__r[0].Street_Address_3__c != null ) {
            accountToProcess.PersonMailingStreet = accountToProcess.PersonMailingStreet + '\n' + accountToProcess.Client_Address__r[0].Street_Address_3__c;
            }
            if( accountToProcess.Client_Address__r[0].Street_Address_4__c != null ) {
            accountToProcess.PersonMailingStreet = accountToProcess.PersonMailingStreet + '\n' + accountToProcess.Client_Address__r[0].Street_Address_4__c;
            }
            
            accountToProcess.PersonMailingPostalCode = accountToProcess.Client_Address__r[0].Zip_Code__c;

         } else {
            accountToProcess.BillingCity = accountToProcess.Client_Address__r[0].City__c;
            accountToProcess.BillingCountry = accountToProcess.Client_Address__r[0].Country__c;
            accountToProcess.BillingState = accountToProcess.Client_Address__r[0].State__c;
            accountToProcess.BillingStreet = accountToProcess.Client_Address__r[0].Street_Address_1__c;
            if( accountToProcess.Client_Address__r[0].Street_Address_2__c != null ) {
            accountToProcess.BillingStreet = accountToProcess.BillingStreet + '\n' + accountToProcess.Client_Address__r[0].Street_Address_2__c;
            }
            if( accountToProcess.Client_Address__r[0].Street_Address_3__c != null ) {
            accountToProcess.BillingStreet = accountToProcess.BillingStreet + '\n' + accountToProcess.Client_Address__r[0].Street_Address_3__c;
            }
            if( accountToProcess.Client_Address__r[0].Street_Address_4__c != null ) {
            accountToProcess.BillingStreet = accountToProcess.BillingStreet + '\n' + accountToProcess.Client_Address__r[0].Street_Address_4__c;
            }
            
            accountToProcess.BillingPostalCode = accountToProcess.Client_Address__r[0].Zip_Code__c;
         }
          

          // If the External Id is populated, we need to check if there are any with 'APX'... these are prioritized higher
          if(accountToProcess.Client_Address__r[0].Ext_Id__c != null) {
              System.debug('External id populated... checking for APX records...');              

              // Check all the communication channels External Ids
              for(Address__c addressCurrent: accountToProcess.Client_Address__r ){

                  // Only concerned with records where the External Id is populated
                  if(addressCurrent.Ext_Id__c != null){
                     
                     // Find the first Ext_Id__c that contains APX... which will be the last updated
                     if(addressCurrent.Ext_Id__c.contains('APX')){
                         if( accountToProcess.isPersonAccount ) {
                           accountToProcess.PersonMailingCity = addressCurrent.City__c;
                           accountToProcess.PersonMailingCountry = addressCurrent.Country__c;
                           accountToProcess.PersonMailingState = addressCurrent.State__c;
                           accountToProcess.PersonMailingStreet = addressCurrent.Street_Address_1__c;
                           if( addressCurrent.Street_Address_2__c != null ) {
                              accountToProcess.PersonMailingStreet = accountToProcess.PersonMailingStreet + '\n' + addressCurrent.Street_Address_2__c;
                           }
                           if( addressCurrent.Street_Address_3__c != null ) {
                              accountToProcess.PersonMailingStreet = accountToProcess.PersonMailingStreet + '\n' + addressCurrent.Street_Address_3__c;
                           }
                           if( addressCurrent.Street_Address_4__c != null ) {
                              accountToProcess.PersonMailingStreet = accountToProcess.PersonMailingStreet + '\n' + addressCurrent.Street_Address_4__c;
                           }
                              
                           accountToProcess.PersonMailingPostalCode = addressCurrent.Zip_Code__c;
                         } else {
                           accountToProcess.BillingCity = addressCurrent.City__c;
                           accountToProcess.BillingCountry = addressCurrent.Country__c;
                           accountToProcess.BillingState = addressCurrent.State__c;
                           accountToProcess.BillingStreet = addressCurrent.Street_Address_1__c;
                           if( addressCurrent.Street_Address_2__c != null ) {
                              accountToProcess.BillingStreet = accountToProcess.BillingStreet + '\n' + addressCurrent.Street_Address_2__c;
                           }
                           if( addressCurrent.Street_Address_3__c != null ) {
                              accountToProcess.BillingStreet = accountToProcess.BillingStreet + '\n' + addressCurrent.Street_Address_3__c;
                           }
                           if( addressCurrent.Street_Address_4__c != null ) {
                              accountToProcess.BillingStreet = accountToProcess.BillingStreet + '\n' + addressCurrent.Street_Address_4__c;
                           }
                              
                           accountToProcess.BillingPostalCode = addressCurrent.Zip_Code__c;
                         }
                         break;
                     }   
                  } else {
                      // No External Ids populated. Simply go by the last updated record
                      break;
                  }
              }    
          }
      } else {
          // Didn't find any Addresses. NULL the field on the parent
          System.debug('Nulling Address on Account');
          if( accountToProcess.isPersonAccount ) {
            accountToProcess.PersonMailingCity = null;
            accountToProcess.PersonMailingCountry = null;
            accountToProcess.PersonMailingState = null;
            accountToProcess.PersonMailingStreet = null;
            accountToProcess.PersonMailingPostalCode = null;
          } else {
            accountToProcess.BillingCity = null;
            accountToProcess.BillingCountry = null;
            accountToProcess.BillingState = null;
            accountToProcess.BillingStreet = null;
            accountToProcess.BillingPostalCode = null;
         }
      }
      // Add this record to the list to update
      accountsToUpdate.add(accountToProcess);
   }
   // Process all of the records we need to update
   update accountsToUpdate; 

   System.debug('addressProcessorTR(-Method Exit');   
}