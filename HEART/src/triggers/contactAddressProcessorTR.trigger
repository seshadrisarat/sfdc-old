trigger contactAddressProcessorTR on Contact_Address__c (after insert, after update, before delete) {
    System.debug('contactAddressProcessorTR (-Method Entry');

    // Create a List for contacts with address
    List<Contact> contactsToUpdate = new List<Contact>();
    
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
    List<Contact> contactsWithAddress = new List<Contact>{};

    // This will hold the unique set of Address Ids that are being affected by the trigger
    Set<Id> addressIds = new Set<Id>{};
    
    // In order to avoid replicating business logic, retrieve the list of records we need to work on upfront
    if( Trigger.isDelete ) {
       addressIds = Trigger.oldMap.keySet();
    } else {
       addressIds = Trigger.newMap.keySet();
    }

    // Create a Set to hold the unique Account/Contact ids
    Set<Id> contactIds = new Set<Id>{};

    // From the Communication Channel Ids, get the unique Client Ids (Account.Ids) or Contact Ids
    for(Contact_Address__c currentAddress : [SELECT Contact__c FROM Contact_Address__c WHERE Id IN :addressIds] ){
        contactIds.add(currentAddress.Contact__c);
    }

    // If we're deleting, omit the deleted Addresses/Comm Channels
    if( Trigger.isDelete ) {
      contactsWithAddress = [SELECT MailingCity, MailingCountry, MailingState, MailingStreet, 
                              ( SELECT City__c, Contact__c, Country__c, Ext_Id__c, Primary__c, State__c, Street_Address_1__c, Street_Address_2__c, Street_Address_3__c, Street_Address_4__c, Zip__c, LastModifiedDate
                                 FROM Contact_Address__r
                                WHERE Id NOT IN :addressIds
                                 ORDER BY Primary__c DESC, Ext_Id__c DESC NULLS LAST, LastModifiedDate ASC )
                              FROM Contact
                              WHERE Id IN :contactIds];
   } else {
      contactsWithAddress = [SELECT MailingCity, MailingCountry, MailingState, MailingStreet, 
                              ( SELECT City__c, Contact__c, Country__c, Ext_Id__c, Primary__c, State__c, Street_Address_1__c, Street_Address_2__c, Street_Address_3__c, Street_Address_4__c, Zip__c, LastModifiedDate
                                 FROM Contact_Address__r
                                 ORDER BY Primary__c DESC, Ext_Id__c DESC NULLS LAST, LastModifiedDate ASC )
                              FROM Contact
                              WHERE Id IN :contactIds];
   }      

    System.debug('contactsWithAddress size=' + contactsWithAddress.size());

    // Check all of the Addresses
    for(Contact contactToProcess:contactsWithAddress){
      System.debug('Processing address...');
      System.debug('Contact is: ' + contactToProcess );

      if(contactToProcess.Contact_Address__r.size() > 0 ) {
          System.debug('Address to process is: ' + contactToProcess.Contact_Address__r[0]);

         // Populate the first record off the list, this will be the latest updated record
         contactToProcess.MailingCity = contactToProcess.Contact_Address__r[0].City__c;
         contactToProcess.MailingCountry = contactToProcess.Contact_Address__r[0].Country__c;
         contactToProcess.MailingState = contactToProcess.Contact_Address__r[0].State__c;
         contactToProcess.MailingStreet = contactToProcess.Contact_Address__r[0].Street_Address_1__c;
         if( contactToProcess.Contact_Address__r[0].Street_Address_2__c != null ) {
         contactToProcess.MailingStreet = contactToProcess.MailingStreet + '\n' + contactToProcess.Contact_Address__r[0].Street_Address_2__c;
         }
         if( contactToProcess.Contact_Address__r[0].Street_Address_3__c != null ) {
         contactToProcess.MailingStreet = contactToProcess.MailingStreet + '\n' + contactToProcess.Contact_Address__r[0].Street_Address_3__c;
         }
         if( contactToProcess.Contact_Address__r[0].Street_Address_4__c != null ) {
         contactToProcess.MailingStreet = contactToProcess.MailingStreet + '\n' + contactToProcess.Contact_Address__r[0].Street_Address_4__c;
         }
         
         contactToProcess.MailingPostalCode = contactToProcess.Contact_Address__r[0].Zip__c;
          

          // If the External Id is populated, we need to check if there are any with 'APX'... these are prioritized higher
          if(contactToProcess.Contact_Address__r[0].Ext_Id__c != null) {
              System.debug('External id populated... checking for APX records...');              

              // Check all the communication channels External Ids
              for(Contact_Address__c addressCurrent: contactToProcess.Contact_Address__r ){

                  // Only concerned with records where the External Id is populated
                  if(addressCurrent.Ext_Id__c != null){
                     
                     // Find the first Ext_Id__c that contains APX... which will be the last updated
                     if(addressCurrent.Ext_Id__c.contains('APX')){
                         contactToProcess.MailingCity = addressCurrent.City__c;
                         contactToProcess.MailingCountry = addressCurrent.Country__c;
                         contactToProcess.MailingState = addressCurrent.State__c;
                         contactToProcess.MailingStreet = addressCurrent.Street_Address_1__c;
                         if( addressCurrent.Street_Address_2__c != null ) {
                           contactToProcess.MailingStreet = contactToProcess.MailingStreet + '\n' + addressCurrent.Street_Address_2__c;
                         }
                         if( addressCurrent.Street_Address_3__c != null ) {
                           contactToProcess.MailingStreet = contactToProcess.MailingStreet + '\n' + addressCurrent.Street_Address_3__c;
                         }
                         if( addressCurrent.Street_Address_4__c != null ) {
                           contactToProcess.MailingStreet = contactToProcess.MailingStreet + '\n' + addressCurrent.Street_Address_4__c;
                         }
                           
                         contactToProcess.MailingPostalCode = addressCurrent.Zip__c;
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
          contactToProcess.MailingCity = null;
          contactToProcess.MailingCountry = null;
          contactToProcess.MailingState = null;
          contactToProcess.MailingStreet = null;
          contactToProcess.MailingPostalCode = null;
      }
      // Add this record to the list to update
      contactsToUpdate.add(contactToProcess);
   }
   // Process all of the records we need to update
   update contactsToUpdate; 
   System.debug('contactAddressProcessorTR (-Method Exit');   
}