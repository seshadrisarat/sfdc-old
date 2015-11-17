/*
*Class: SL_Provider_Address_Handler
*Description: This class serves as handler for Provider_Address_Trigger and is used to keep only one primary address for each type corresponding to each contact and updating the corresponding Contact record with primary Mailing and Practice Address.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public without sharing class SL_Provider_Address_Handler
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static map<String, Provider_Address_Settings__c> providerAddressMappings;
    private static final list<String> addressFields = new list<String>{'Street','City','State','PostalCode','Country'};
    private static boolean isChildUpdate = FALSE;
     
    /* Start - Constructor */
    public SL_Provider_Address_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    /* End - Constructor */
    
     
    public void OnBeforeInsert(list<Provider_Address__c> lstNewProviderAddress)
    { 
        validateSupportedTypesForPrimaryAddresses(lstNewProviderAddress);

        list<Contact> contactsToUpdate;
        map<Id,Contact> idToContact = getContactsToUpdate(lstNewProviderAddress);
        contactsToUpdate = idToContact.values();

        if(contactsToUpdate.size() > 0){
            Update contactsToUpdate;

            list<Provider_Address__c> formerPrimaryAddresses = getFormerPrimaryAddresses(lstNewProviderAddress, idToContact);
            if(formerPrimaryAddresses.size() > 0){
                isChildUpdate = TRUE;
                Update formerPrimaryAddresses;
            }
        }
    }
     
    public void OnBeforeUpdate(map<ID,Provider_Address__c> oldProviderAddressMap, map<ID,Provider_Address__c> newProviderAddressMap)
    {
        if(!isChildUpdate){
            if(providerAddressMappings == null){
                providerAddressMappings = Provider_Address_Settings__c.getAll();
            }

            validateSupportedTypesForPrimaryAddresses(newProviderAddressMap.values());

            list<Provider_Address__c> providerAddressesForNullifyingContact = new list<Provider_Address__c>();

            for(Provider_Address__c paNew : newProviderAddressMap.values()){

                if( (oldProviderAddressMap.get(paNew.Id).Type__c != paNew.Type__c
                    && providerAddressMappings.containsKey(oldProviderAddressMap.get(paNew.Id).Type__c)
                    && paNew.Primary__c == true
                    )
                  ||(paNew.Primary__c == false 
                    && oldProviderAddressMap.get(paNew.Id).Primary__c == true
                    )
                  )
                {
                    providerAddressesForNullifyingContact.add(oldProviderAddressMap.get(paNew.Id));
                }
            }

            map<Id,Contact> idToContact;
            if(providerAddressesForNullifyingContact.size() > 0){
                idToContact = getContactsToNullify(providerAddressesForNullifyingContact);
            }
            else{
                idToContact = new map<Id,Contact>();
            }

            list<Provider_Address__c> providerAddressesForUpdatingContact = new list<Provider_Address__c>();

            for(Provider_Address__c paNew : newProviderAddressMap.values()){
                if(paNew.Primary__c == true
                  &&(  oldProviderAddressMap.get(paNew.Id).Street_Address_1__c!=paNew.Street_Address_1__c
                    || oldProviderAddressMap.get(paNew.Id).Street_Address_2__c!=paNew.Street_Address_2__c
                    || oldProviderAddressMap.get(paNew.Id).Street_Address_3__c!=paNew.Street_Address_3__c
                    || oldProviderAddressMap.get(paNew.Id).City__c!=paNew.City__c
                    || oldProviderAddressMap.get(paNew.Id).State__c!=paNew.State__c
                    || oldProviderAddressMap.get(paNew.Id).Postal_Code__c!=paNew.Postal_Code__c
                    || oldProviderAddressMap.get(paNew.Id).Country__c!=paNew.Country__c
                    || oldProviderAddressMap.get(paNew.Id).Type__c != paNew.Type__c
                    || oldProviderAddressMap.get(paNew.Id).Primary__c == false
                    )
                  )
                {
                    providerAddressesForUpdatingContact.add(paNew);
                }
            }
            map<Id,Contact> idToUpdatedContact;

            if(providerAddressesForUpdatingContact.size() > 0){
                idToUpdatedContact = getContactsToUpdate(providerAddressesForUpdatingContact, idToContact);
                if(idToUpdatedContact.size() > 0){
                    idToContact.putAll(idToUpdatedContact);
                }
            }

            if(idToContact.size() > 0){
                list<Contact> contactsToUpdate = idToContact.values();
                Update contactsToUpdate;
            }

            if(idToUpdatedContact != null && idToUpdatedContact.size() > 0){
                list<Provider_Address__c> formerPrimaryAddresses = getFormerPrimaryAddresses(newProviderAddressMap.values(), idToUpdatedContact);
                if(formerPrimaryAddresses.size() > 0){
                    isChildUpdate = TRUE;
                    Update formerPrimaryAddresses;
                }
            }
        }
    }
    
    public void OnAfterDelete(list<Provider_Address__c> lstOldProviderAddresses){
        if(providerAddressMappings == null){
            providerAddressMappings = Provider_Address_Settings__c.getAll();
        }

        list<Provider_Address__c> providerAddressesForNullifyingContact = new list<Provider_Address__c>();

        for(Provider_Address__c oldPA : lstOldProviderAddresses){
            if(oldPA.Primary__c == TRUE && providerAddressMappings.containsKey(oldPa.Type__c)){
                providerAddressesForNullifyingContact.add(oldPA);
            }
        }

        if(providerAddressesForNullifyingContact.size() > 0){
            list<Contact> contactsToUpdate = getContactsToNullify(providerAddressesForNullifyingContact).values();
            if(contactsToUpdate.size() > 0){
                Update contactsToUpdate;
            }
        }
    }


    private map<Id,Contact> getContactsToUpdate(list<Provider_Address__c> providerAddresses){
        return getContactsToUpdate(providerAddresses, new map<Id,Contact>());
    }


    private map<Id,Contact> getContactsToUpdate(list<Provider_Address__c> providerAddresses, map<Id,Contact> idToContact){
        if(providerAddressMappings == null){
            providerAddressMappings = Provider_Address_Settings__c.getAll();
        }
        Map<String,Map<Id,list<Provider_Address__c>>> typesToContactsAndProviderAddresses = new Map<String,Map<Id,list<Provider_Address__c>>>();

        for(Provider_Address__c pa : providerAddresses){
            if(providerAddressMappings.containsKey(pa.Type__c) && pa.Primary__c == TRUE){
                if(typesToContactsAndProviderAddresses.containsKey(pa.Type__c)){
                    if(typesToContactsAndProviderAddresses.get(pa.Type__c).containsKey(pa.Provider__c)){
                        typesToContactsAndProviderAddresses.get(pa.Type__c).get(pa.Provider__c).add(pa);
                    }
                    else{
                        typesToContactsAndProviderAddresses.get(pa.Type__c).put(pa.Provider__c, new list<Provider_Address__c>{pa});
                    }
                }
                else{
                    typesToContactsAndProviderAddresses.put(pa.Type__c, new map<Id,list<Provider_Address__c>>{pa.Provider__c => new list<Provider_Address__c>{pa}});
                }
            }
        }

        for(String type : typesToContactsAndProviderAddresses.keySet()){
            Provider_Address_Settings__c mapping = providerAddressMappings.get(type);

            map<String,String> addressFieldsToUpdate = getAddressFieldsToUpdateMapping(type);

            for(Id contactId : typesToContactsAndProviderAddresses.get(type).keySet()){
                Provider_Address__c pa = typesToContactsAndProviderAddresses.get(type).get(contactId).get(0);
                Contact con;
                if(idToContact.containsKey(contactId)){
                    con = idToContact.get(contactId);
                }
                else{
                    con = new Contact(Id = contactId);
                }
                if(mapping.Geocoding_Required__c == TRUE){
                    con.Geocoding_Required__c = true;
                }
                String streetAddress = concatenateAddress(pa.Street_Address_1__c, pa.Street_Address_2__c, pa.Street_Address_3__c);
                con.put(addressFieldsToUpdate.get('Street'), streetAddress);
                con.put(addressFieldsToUpdate.get('City'), pa.City__c);
                con.put(addressFieldsToUpdate.get('State'), pa.State__c);
                con.put(addressFieldsToUpdate.get('PostalCode'), pa.Postal_Code__c);
                con.put(addressFieldsToUpdate.get('Country'), pa.Country__c);
                idToContact.put(contactId, con);

                if(typesToContactsAndProviderAddresses.get(type).get(contactId).size() > 0){
                    for(Integer i = 1; i < typesToContactsAndProviderAddresses.get(type).get(contactId).size(); i++){
                        typesToContactsAndProviderAddresses.get(type).get(contactId).get(i).Primary__c = false;
                    }
                }
            }
        }
        return idToContact;
    }

    private map<Id,Contact> getContactsToNullify(list<Provider_Address__c> providerAddresses){
        if(providerAddressMappings == null){
            providerAddressMappings = Provider_Address_Settings__c.getAll();
        }
        map<Id,Contact> idToContact = new map<Id,Contact>();

        Map<String,set<id>> typesToContactsToNullify = new Map<String,set<id>>();

        for(Provider_Address__c pa : providerAddresses){
            if(providerAddressMappings.containsKey(pa.Type__c)){
                if(typesToContactsToNullify.containsKey(pa.Type__c)){
                    typesToContactsToNullify.get(pa.Type__c).add(pa.Provider__c);
                }
                else{
                    typesToContactsToNullify.put(pa.Type__c, new set<id>{pa.Provider__c});
                }
            }
        }

        for(String type : typesToContactsToNullify.keyset()){
            Provider_Address_Settings__c mapping = providerAddressMappings.get(type);
            map<String,String> addressFieldsToUpdate = getAddressFieldsToUpdateMapping(type);

            for(Id contactId : typesToContactsToNullify.get(type)){
                Contact con;
                if(idToContact.containsKey(contactId)){
                    con = idToContact.get(contactId);
                }
                else{
                    con = new Contact(Id = contactId);
                }
                con.put(addressFieldsToUpdate.get('Street'), null);
                con.put(addressFieldsToUpdate.get('City'), null);
                con.put(addressFieldsToUpdate.get('State'), null);
                con.put(addressFieldsToUpdate.get('PostalCode'), null);
                con.put(addressFieldsToUpdate.get('Country'), null);
                idToContact.put(contactId, con);

            }
        }
        return idToContact;
    }

    private list<Provider_Address__c> getFormerPrimaryAddresses(list<Provider_Address__c> newList, map<Id,Contact> updatedContacts)
    {
        set<Id> primaryAddressId = new set<Id>();
        map<Id,set<String>> contactIdToPrimaryTypes = new map<Id,set<String>>();
        list<Provider_Address__c> formerPrimaryAddresses = new list<Provider_Address__c>();

        for(Provider_Address__c pa : newList){
            if(pa.Id != Null){
                primaryAddressId.add(pa.Id);
            }
            if(pa.Primary__c == TRUE){
                if(contactIdToPrimaryTypes.containsKey(pa.Provider__c)){
                    contactIdToPrimaryTypes.get(pa.Provider__c).add(pa.Type__c);
                }
                else{
                    contactIdToPrimaryTypes.put(pa.Provider__c, new set<String>{pa.Type__c});
                }
            }
        }

        for(Provider_Address__c pa : [SELECT Id, Provider__c, Type__c, Primary__c FROM Provider_Address__c WHERE Provider__c = :updatedContacts.keySet() AND Primary__c = TRUE AND Id != :primaryAddressId]){
            if(contactIdToPrimaryTypes.containsKey(pa.Provider__c) && contactIdToPrimaryTypes.get(pa.Provider__c).contains(pa.Type__c)){
                pa.Primary__c = FALSE;
                formerPrimaryAddresses.add(pa);
            }
        }
        return formerPrimaryAddresses;
    }

    private map<String,String> getAddressFieldsToUpdateMapping(String Type){
        if(providerAddressMappings == null){
            providerAddressMappings = Provider_Address_Settings__c.getAll();
        }

        Provider_Address_Settings__c mapping = providerAddressMappings.get(type);

        map<String,String> addressFieldsToUpdate = new map<String, String>();
        for(integer i = 0; i < addressFields.size(); i++){
            string finalAddressField = mapping.Prefix__c + addressFields.get(i);
            if(!String.isBlank(mapping.Suffix__c)){
                finalAddressField += mapping.Suffix__c;
            }
            addressFieldsToUpdate.put(addressFields.get(i), finalAddressField);
        }

        return addressFieldsToUpdate;
    }
             
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
    
    private String concatenateAddress(String strStreetAddress1, String strStreetAddress2, String strStreetAddress3)
    {
    	if(!String.isBlank(strStreetAddress2)){
    		strStreetAddress1+='\n'+strStreetAddress2;
        }
    	if(!String.isBlank(strStreetAddress3)){
    		strStreetAddress1+='\n'+strStreetAddress3;
        }
    	
    	return strStreetAddress1;
    }

    private void validateSupportedTypesForPrimaryAddresses(list<Provider_Address__c> newList){
        if(providerAddressMappings == null){
            providerAddressMappings = Provider_Address_Settings__c.getAll();
        }
        for(Provider_Address__c pa : newList){
            If(pa.Primary__c == TRUE && !(providerAddressMappings.containsKey(pa.Type__c))){
                String errorMessage = 'INVALID ADDRESS TYPE: ' + pa.Type__c + '. A Provider Address can only be be primary if it is mapped ';
                errorMessage += 'in the Provider_Address_Settings__c Custom Setting.';

                throw new NonSupportedTypeForPrimaryAddressException(errorMessage);
            }
        }
    }

    public class NonSupportedTypeForPrimaryAddressException extends Exception {}
}