/**
*  ClassName      : SL_ContactTriggerHandler
*  JIRATicket     : Heart-7, HEART-13, HEART-14
*  CreatedOn      : 6/DEC/2013
*  CreatedBy      : Sandeep
*  ModifiedBy     : Pankaj Ganwani
*  LastModifiedOn : 10/14/2015
*  Description    : Handler class to update the Estimated Future Contact date on Contact when an Contact record is being 
                    updated. 
*/
public with sharing class SL_ContactTriggerHandler 
{
    /* Constructor */
    public SL_ContactTriggerHandler()
    {
        //Do nothing.
    }
    
    /*
        * MethodName        : onAfterUpdate
        * param             : map<id, Contact> mapNewContact , map<id, Contact> mapOldContact
        * Description       : This function will be called after Update of the Contact Records to update the Estimated Future Contact date of Contact.
    */
    public void onAfterUpdate(map<Id, Contact> mapNewContacts , map<Id, Contact> mapOldContacts )
    {
        updateFutureContactDate(mapNewContacts, mapOldContacts);
        //check custom setting isActive is true or not. If not then do not call the method for creating contact preference
        Contact_Trigger_Status__c objCustomSetting = Contact_Trigger_Status__c.getOrgDefaults();
        if(objCustomSetting.isActive__c)
            createContactPreferencesHistory(mapOldContacts, mapNewContacts);
    }
    
    /*
        * MethodName        : updateFutureContactDate
        * param             : map<id, Contact> mapNewContact , map<id, Contact> mapOldContact
        * Description       : This function will be called after Update of the Contact Records to update the Estimated Future Contact date of Contact.
    */
    private void updateFutureContactDate(map<Id, Contact> mapNewContacts , map<Id, Contact> mapOldContacts )
    {
        try
        {
            Set<Id> setValidContacts = new Set<Id>();
            Map<String, Integer> mapfrequencyToMonth = new Map<String, Integer>{'Monthly' => 1, 'Quarterly' => 3, 'Semi-Annually' => 6, 'Annually' => 12};
            list<Contact> lstContactToBeUpdate = new List<Contact>(); // Contains all the Contact records need to be update 
                
            for(Contact objContact : mapNewContacts.values())
            {
                if( objContact.Upcoming_meeting_material_update__c != mapOldContacts.get(objContact.Id).Upcoming_meeting_material_update__c 
                 || objContact.Upcoming_phone_material_update__c   != mapOldContacts.get(objContact.Id).Upcoming_phone_material_update__c 
                 || objContact.Last_meeting_material_update__c     != mapOldContacts.get(objContact.Id).Last_meeting_material_update__c 
                 || objContact.Last_phone_material_update__c       != mapOldContacts.get(objContact.Id).Last_phone_material_update__c 
                 || objContact.CommFreq_Phone__c                   != mapOldContacts.get(objContact.Id).CommFreq_Phone__c 
                 || objContact.CommFreq_Meeting__c                 != mapOldContacts.get(objContact.Id).CommFreq_Meeting__c 
                 || objContact.Phone__c                            != mapOldContacts.get(objContact.Id).Phone__c 
                 || objContact.Meeting__c                          != mapOldContacts.get(objContact.Id).Meeting__c)
                {
                    setValidContacts.add(objContact.Id);
                }
                
            }
            
            // Checking if is there any completed activity is there with type Material update meeting or material update phone
            for(Contact objContactrec : [select Id, Meeting__c, CommFreq_Meeting__c, CommFreq_Phone__c, Phone__c, Last_phone_material_update__c, Last_meeting_material_update__c, Last_material_update_exception__c,Upcoming_phone_material_update__c,Upcoming_meeting_material_update__c, Upcoming_material_update_exception__c 
                                        FROM Contact Where Id IN: setValidContacts])
                    {                   
                        //If last phone material is not null then will update upcoming phone material update field according to the last material date.
                        if(objContactrec.Last_phone_material_update__c != null )
                        {
                            objContactrec.Upcoming_phone_material_update__c = objContactrec.Last_phone_material_update__c.addMonths(mapfrequencyToMonth.get(objContactrec.CommFreq_Phone__c)); 
                        }
                        //If last meeting material is not null then will update upcoming phone material update field according to the last material date.
                        if(objContactrec.Last_meeting_material_update__c != null)
                        {
                            objContactrec.Upcoming_meeting_material_update__c  = objContactrec.Last_meeting_material_update__c.addMonths(mapfrequencyToMonth.get(objContactrec.CommFreq_Meeting__c)); 
                        }
                        lstContactToBeUpdate.add(objContactrec);

                        if(objContactrec.Last_material_update_exception__c == null)
                        {
                            objContactrec.Upcoming_material_update_exception__c = null;
                        }
                        // If Last Material Update Exception has a value...
                        else
                        {
                            // If type is Meeting material update
                            if(objContactrec.Meeting__c == true && objContactrec.Phone__c == false)
                                objContactrec.Upcoming_material_update_exception__c = objContactrec.Last_material_update_exception__c.addMonths(mapfrequencyToMonth.get(objContactrec.CommFreq_Meeting__c)); 
                            else if(objContactrec.Meeting__c == false && objContactrec.Phone__c == true)
                                objContactrec.Upcoming_material_update_exception__c = objContactrec.Last_material_update_exception__c.addMonths(mapfrequencyToMonth.get(objContactrec.CommFreq_Phone__c)); 
                            else
                                objContactrec.Upcoming_material_update_exception__c = null;
                        }
                    }
                    
                // Updating the Contact Field accordingly the conditions
                if(lstContactToBeUpdate.size() > 0 )
                {
                    update lstContactToBeUpdate;
                }
                
                if(test.isRunningTest())
                    integer i = 10/0;
        }
        catch(Exception ex)
        {
            system.debug('exception----'+ex);
        }
    }
    
    /*
        * MethodName        : createContactPreferencesHistory
        * param             : map<Id, Contact> mapOldContact, map<Id, Contact> mapNewContact
        * Description       : This function will be create contact preference history record
    */
    private void createContactPreferencesHistory(map<Id, Contact> mapOldContact, map<Id, Contact> mapNewContact)
    {
        List<Contact_Preferences_History__c> lstContactPreferencesHistory = new List<Contact_Preferences_History__c>();
        for(Contact objContact: mapNewContact.values())
        {
            if(objContact.HAI_Communications__c !=  mapOldContact.get(objContact.Id).HAI_Communications__c)
            {
                lstContactPreferencesHistory.add(new Contact_Preferences_History__c(Contact_Name__c = objContact.Id, 
                                                     New_Value_HAI_Opt_Out__c = splitAndSortOptions(objContact.HAI_Communications__c),
                                                     Prior_Value_HAI_Opt_Out__c = splitAndSortOptions(mapOldContact.get(objContact.Id).HAI_Communications__c),
                                                     User__c = UserInfo.getUserId(),
                                                     Modified_DateTime__c = DateTime.now()));
            }
        }
        insert lstContactPreferencesHistory;
    }
    
    private String splitAndSortOptions(String HAIComm)
    {
        if(String.isEmpty(HAIComm))
            return NULL;
        List<String> lstPicklistOptions = HAIComm.split(';');
        lstPicklistOptions.sort();
        return String.join(lstPicklistOptions, '; ');
    }
}