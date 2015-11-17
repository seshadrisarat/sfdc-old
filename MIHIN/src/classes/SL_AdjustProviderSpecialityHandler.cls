/*
*Class: SL_AdjustProviderSpecialityHandler
*Description: This is handler class for SL_AdjustRelatedProviderSpeciality.trigger.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_AdjustProviderSpecialityHandler 
{
    Map<Id, Set<String>> mapContactIdToSetOfSpecialityCodes; // Will store the Contact Id to Set of valid Specialty Codes entered by user in the Contact.Specialty_Codes__c field
    Set<String> setStrAllSpecialityCodes; // Set of all SpecialtyCodes. Will be used later to query all Specialty records
        
    // We need to send two values from "checkIfSpecialityCodeFieldIsModified" method. So, making use of this inner class
    public class Node
    {
        Map<Id, Set<String>> mapContactIdToSetOfSpecialityCodes; // Will store the Contact Id to Set of valid Specialty Codes entered by user in the Contact.Specialty_Codes__c field
        Set<String> setStrAllSpecialityCodes; // Will store all Speciality codes. Will be required to query the Speciality records based on their SpoecialtyCode
        
        // Inner class Constructor
        public Node(Map<Id, Set<String>> mapContactIdToSetOfSpecialityCodes, Set<String> setStrAllSpecialityCodes)
        {
            this.mapContactIdToSetOfSpecialityCodes = mapContactIdToSetOfSpecialityCodes;
            this.setStrAllSpecialityCodes = setStrAllSpecialityCodes;
        }
    }
    
    // Outer class Constructor
    public SL_AdjustProviderSpecialityHandler()
    {
        initialize();
    }
    
    private void initialize()
    {
        mapContactIdToSetOfSpecialityCodes = new Map<Id, Set<String>>();
        setStrAllSpecialityCodes           = new Set<String>();
    }
    
    // Method called on after insert of trigger(SL_AdjustRelatedProviderSpeciality) on Contact
    public void onAfterInsert(List<Contact> lstNewContacts)
    {
        // 1. Call the "checkIfSpecialtyCodeFieldIsNotNull" and get all the Contacts inserted with Speciality_Code specified.
        // 2. Send this list of Contacts to "updateRelatedProviderSpecialityRecordsOfContact" method and perform the necessary actions.
        try{
            updateRelatedProviderSpecialityRecordsOfContact(checkIfSpecialtyCodeFieldIsNotNull(lstNewContacts));
        }
        catch(Exception ex)
        {}
    }
    
    // Method called on after update of trigger(SL_AdjustRelatedProviderSpeciality) on Contact
    public void onAfterUpdate(List<Contact> lstNewContacts, Map<Id, Contact> mapOldContacts)
    {
        // 1. Call the "checkIfSpecialityCodeFieldIsModified" and get all the Contacts whose Speciality_Code is modified and is in the correct format
        // 2. Send this list of Contacts to "updateRelatedProviderSpecialityRecordsOfContact" method and perform the necessary actions.
        try{
            updateRelatedProviderSpecialityRecordsOfContact(checkIfSpecialityCodeFieldIsModified(lstNewContacts, mapOldContacts));
        }
        catch(Exception ex)
        {}
    }
    
    
    /* 
       Method Name  : checkIfSpecialtyCodeFieldIsNotNull
       Arguments    : trigger.new (List<Contact>)
       Access       : PRIVATE
       Return Type  : Node
       Purpose      : This method is used to collect all the Contact Ids whose Specialities Code field has been modified
                      Next, create a map of these ContactIds to a set of SpecialityCodes that has been specified as comma separated values in the Contact.Specialities_Code__c field
    */
    private Node checkIfSpecialtyCodeFieldIsNotNull(List<Contact> lstNewContacts)
    {
        for(Contact objNewContact : lstNewContacts)
        {
            if(objNewContact.Specialities_Code__c != null)
            {
                Set<String> setStrSpecialityCode = new Set<String>(); // Local temporary Set
                
                // Separate out the individual Specialty Codes from the Contact.Specialty_Codes__c field
                for(String s : objNewContact.Specialities_Code__c.split(','))
                {
                    setStrSpecialityCode.add(s.trim());
                    setStrAllSpecialityCodes.add(s.trim());
                }
                
                // Put Contact.Id to Set of SpecialtyCode into map
                mapContactIdToSetOfSpecialityCodes.put(objNewContact.Id, setStrSpecialityCode);
            }
        }
        
        return new Node(mapContactIdToSetOfSpecialityCodes, setStrAllSpecialityCodes);
    }
    
    
    /* 
       Method Name  : checkIfSpecialityCodeFieldIsModified
       Arguments    : trigger.new (List<Contact>)
       Access       : PRIVATE
       Return Type  : Node
       Purpose      : This method is used to collect all the Contact Ids whose Specialities Code field has been modified
                      Next, create a map of these ContactIds to a set of SpecialityCodes that has been specified as comma separated values in the Contact.Specialities_Code__c field
    */
    private Node checkIfSpecialityCodeFieldIsModified(List<Contact> lstNewContacts, Map<Id, Contact> mapOldContacts)
    {
        // Iterate over all the Contacts in trigger.new
        for(Contact objNewContact : lstNewContacts)
        {
            // If Specialities_Code__c field has been modified (Filter criteria to avoid performing actions on blank updates)
            if((objNewContact.Specialities_Code__c != null && mapOldContacts.get(objNewContact.Id).Specialities_Code__c != null && objNewContact.Specialities_Code__c != mapOldContacts.get(objNewContact.Id).Specialities_Code__c) || 
                (objNewContact.Specialities_Code__c == null && mapOldContacts.get(objNewContact.Id).Specialities_Code__c != null ) ||
                 objNewContact.Specialities_Code__c != null && mapOldContacts.get(objNewContact.Id).Specialities_Code__c == null) 
            {
                
                Set<String> setStrSpecialityCode = new Set<String>(); // Local temporary Set
                
                // Separate out the individual Specialty Codes from the Contact.Specialty_Codes__c field
                if(objNewContact.Specialities_Code__c != null)
                {
                    for(String s : objNewContact.Specialities_Code__c.split(','))
                    {
                        setStrSpecialityCode.add(s.trim());
                        setStrAllSpecialityCodes.add(s.trim());
                    }
                }
                
                // Put Contact.Id to Set of SpecialtyCode into map
                mapContactIdToSetOfSpecialityCodes.put(objNewContact.Id, setStrSpecialityCode);
            }
        }
        
        return new Node(mapContactIdToSetOfSpecialityCodes, setStrAllSpecialityCodes);
    }
    
    
    /* 
       Method Name  : updateRelatedProviderSpecialityRecordsOfContact
       Arguments    : Node objNode
       Access       : PRIVATE
       Return Type  : void
       Purpose      : Perform the necessary functionality as mentioned in MIHIN-33
    */
    private void updateRelatedProviderSpecialityRecordsOfContact(Node objNode)
    {
        if (objNode.mapContactIdToSetOfSpecialityCodes.isEmpty()) return;
        
        Map<String, Specialty__c> mapSpecialtyCodeToSpecialty     = new Map<String, Specialty__c>();
        List<Provider_Specialty__c> lstProviderSpecialtyForInsert = new List<Provider_Specialty__c>();
        List<Provider_Specialty__c> lstProviderSpecialtyForDelete = new List<Provider_Specialty__c>();
        
        // Query the Specialty Records by their SpecialtyCodes. These record Ids are necessary to create the ProviderSpecialty records
        for(Specialty__c objSpecialty : [Select Id, Specialty_Code__c From Specialty__c WHERE Specialty_Code__c IN: objNode.setStrAllSpecialityCodes])
        {
            mapSpecialtyCodeToSpecialty.put(objSpecialty.Specialty_Code__c, objSpecialty);
        }
        
        for(Contact objContact : [Select Id,  
                                  (Select Name, Specialty__r.Specialty_Code__c, Unique_ID__c From Provider_Specialties__r) 
                                  From Contact 
                                  WHERE Id IN: objNode.mapContactIdToSetOfSpecialityCodes.keyset()])
        {
            // If Contact has no related provider Specialty records
            if(objContact.Provider_Specialties__r.isEmpty())
            {
                // Check for the Contact.Specialty Code to see if any ProviderSpecialty needs to be added.
                if(!objNode.mapContactIdToSetOfSpecialityCodes.get(objContact.Id).isEmpty())
                {
                    for(String s : objNode.mapContactIdToSetOfSpecialityCodes.get(objContact.Id))
                    {
                        if(mapSpecialtyCodeToSpecialty.containsKey(s))
                        {
                            Provider_Specialty__c objProviderSpecialtyToinsert = new Provider_Specialty__c(Specialty__c = mapSpecialtyCodeToSpecialty.get(s).Id, 
                                                                                                           Provider__c = objContact.Id);
                            lstProviderSpecialtyForInsert.add(objProviderSpecialtyToinsert);                                                                               
                        }
                    }
                }
            }
            else // Implies that Contact has child Provider Specialty. Now, system will decide which Provider Specialty to be created or deleted 
            {
                // Copy the Contact.SpecialtyCode field's codes into this set.
                Set<String> setStrSpecialtyCodesToCheckWith = new Set<String>();
                setStrSpecialtyCodesToCheckWith.addAll(objNode.mapContactIdToSetOfSpecialityCodes.get(objContact.Id));
                
                // Iterate over related ProviderSpeciality records of this Contact
                for(Provider_Specialty__c objProvider : objContact.Provider_Specialties__r)
                {
                    // If Contact has children and the Contact.SpecialtyCode field also has values. So system will need to decide which child to keep, which child to create and which one to delete
                    if(!objNode.mapContactIdToSetOfSpecialityCodes.get(objContact.Id).isEmpty())
                    {
                        /* main critical logic starts here */
                        
                        // Get a mechanism to check if any related ProviderSpeciality record is not present but the specialty code has newly been added to the Contact.SpecialtyCode field. 
                        // System needs to insert this Provider Specialty. This is handled in line #180
                        // Remove the specialty code from the temporary set. Remaining will be used to insert new records.
                        if(setStrSpecialtyCodesToCheckWith.contains(objProvider.Specialty__r.Specialty_Code__c))
                        {
                            setStrSpecialtyCodesToCheckWith.remove(objProvider.Specialty__r.Specialty_Code__c); 
                        }
                        
                        
                        // This means this particular related ProviderSpeciality record is already present. So, no need to do anything
                        if(objNode.mapContactIdToSetOfSpecialityCodes.get(objContact.Id).contains(objProvider.Specialty__r.Specialty_Code__c))
                        {
                        }
                        // If this child is present but not present in Contact.SpecialtyCode. Then delete this child
                        else if(!objNode.mapContactIdToSetOfSpecialityCodes.get(objContact.Id).contains(objProvider.Specialty__r.Specialty_Code__c))
                        {
                            lstProviderSpecialtyForDelete.add(objProvider);
                        }
                        /* main critical logic ends here */
                    }
                    else // Implies that Contact has related ProviderSpeciality records. But Contact.SpecialtyCode is Empty. So delete all the related ProviderSpeciality records
                    {
                        lstProviderSpecialtyForDelete.add(objProvider);
                    }
                }
                
                // Check with the left over in temporary set. Insert all those provider specialities.
                if(!setStrSpecialtyCodesToCheckWith.isEmpty())
                {
                    for(String s : setStrSpecialtyCodesToCheckWith)
                    {
                        if(mapSpecialtyCodeToSpecialty.containsKey(s))
                        {
                            Provider_Specialty__c objProviderSpecialtyToinsert = new Provider_Specialty__c(Specialty__c = mapSpecialtyCodeToSpecialty.get(s).Id, 
                                                                                                           Provider__c = objContact.Id);
                            lstProviderSpecialtyForInsert.add(objProviderSpecialtyToinsert);                                                                               
                        }
                    }
                }
            }
        }
        
        if(!lstProviderSpecialtyForInsert.isEmpty())    insert lstProviderSpecialtyForInsert;
        if(!lstProviderSpecialtyForDelete.isEmpty())    delete lstProviderSpecialtyForDelete;
    }
    
    @IsTest(SeeAllData=true)
    public static void testMyController()
    {
        Account objAccount = new Account(Name = 'Test Account');
        insert objAccount;
        
        Specialty__c objSpeciality = new Specialty__c( Name ='Test Speciality',Specialty_Code__c='17');
        insert objSpeciality;
        
        Specialty__c objSpeciality1 = new Specialty__c( Name ='Test Speciality1',Specialty_Code__c='18');
        insert objSpeciality1;
        
        Contact objContact = new Contact(LastName = 'TestContact' , AccountID=objAccount.id,Specialities_Code__c='21' );
        insert objContact;
        
        list<Provider_Specialty__c> lstProviderSpeciality = [ select Specialty__c,Provider__c 
                                                       from Provider_Specialty__c where Specialty__c =:objSpeciality.id and Provider__c =: objContact.id];
                                                       
        system.assert(lstProviderSpeciality.size() == 0 );                                                     
        
        objContact.Specialities_Code__c = '21,17';
        update objContact;
        
        
        list<Provider_Specialty__c> lstProviderSpeciality1 = [ select Specialty__c,Provider__c 
                                                       from Provider_Specialty__c where Specialty__c =:objSpeciality.id and Provider__c =: objContact.id];
        
        
        objContact.Specialities_Code__c = '21';
        update objContact;  
        
        list<Provider_Specialty__c> lstProviderSpeciality2 = [ select Specialty__c,Provider__c 
                                                       from Provider_Specialty__c where Specialty__c =:objSpeciality.id and Provider__c =: objContact.id];
                                                       
        system.assert(lstProviderSpeciality2.size() == 0 );        
    }
}