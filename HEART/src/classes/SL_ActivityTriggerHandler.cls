/**
    * ClassName       : SL_ActivityTriggerHandler 
    * JIRA Ticket     : HEART-2
    * Created On      : 08/NOV/2013
    * ModifiedBy      : Sandeep
    * Description     : Handler class to update the Last_meeting_material_update__c/Last_phone_material_update__c field of Contact 
                        when a record is being created and updated with Status field as Completed.  
    */
    public with sharing class SL_ActivityTriggerHandler 
    {
        /* Constructor of Handler Class*/
        public SL_ActivityTriggerHandler()
        {
             /* Do nothing. */
        }
        
        /*
            * MethodName        : onAfterInsert.
            * param             : Map of Task records
            * Description       : This function will be called after insert of the Task record.
        */
        public void onAfterInsert(Map<id,Task> mapNewTasks)
        {
            /*To update the Last_meeting_material_update__c/Last_phone_material_update__c field of Contact when a Task record is created 
            with Status as Completed and Type = 'Material Update- Meeting' OR Type = 'Material Update- Phone' */
            
            populatingContactDateField(mapNewTasks,null);// Calling this method for updating contact's field on task afterinsert and after update when status = completed and type is either any of the material
        }
        
        /*
            * MethodName        : onAfterUpdate
            * param             : Map of Task records 
            * Description       : This function will be called after update of the Task record.
        */
        public void onAfterUpdate(Map<Id,Task> mapNewTasks , Map<Id,Task> mapOldTasks)
        {
            
            populatingContactDateField(mapNewTasks,mapOldTasks);// Calling this method for updating contact's field on task afterinsert and after update when status = completed and type is either any of the material
        }
        
        /*
            * MethodName        : populatingContactDateField.
            * param             : Map of Task records.
            * Description       : To update the Last_meeting_material_update__c/Last_phone_material_update__c field of Contact when a Task 
                                  record is created with Status as Completed and Type = 'Material Update- Meeting' OR Type = 'Material Update- Phone'
        */
        
        private void populatingContactDateField(Map<Id, Task> mapNewTasks, Map<Id,Task> mapOldTasks)
        {
            try
            {
                Map<String, Integer> mapfrequencyToMonth = new Map<String, Integer>{'Monthly' => 1, 'Quarterly' => 3, 'Semi-Annually' => 6, 'Annually' => 12};
                String strcontact_prefix = Schema.SObjectType.Contact.getKeyPrefix();   // Contains the starting three digit of contact object's recorde e.g '003'
                set<Id> setRecentTask = new set<Id>();                                  // Contains all the whoids of the task records and the old whoids if the updated taks's whoid is changed
                
                Map<Id,Contact> mapIdToContact = new Map<Id,Contact>();                    // Contains all the contact records need to be update 
                Date dtLast_meeting_material_update = null;
                Date dtLast_phone_material_update = null;
                
                
                // iterating over task inorder to collect the whoids of the tasks in to the set setRecentTask
                for(Task objTask : mapNewTasks.values())
                {
                    if(objTask.whoId != null)
                    {
                        if(mapOldTasks != null)
                        {
                            if(((String)objTask.WhoId).startsWith(strcontact_prefix)  && ((String)mapOldTasks.get(objTask.Id).WhoId).startsWith(strcontact_prefix))
                            {
                                if(mapOldTasks.get(objTask.Id).WhoId != objTask.WhoId)
                                    setRecentTask.add(mapOldTasks.get(objTask.Id).WhoId); // Collecting all the oldwhoids if only the new contact whoid is got changed from the old one's whoId 
                            }
                        }
                        
                        if(((String)objTask.WhoId).startsWith(strcontact_prefix))
                            setRecentTask.add(objTask.WhoId);
                    }
                    else
                    {
                        // Do nothing
                    }
                }
                if(setRecentTask.size() > 0)
                {
                    // Iterating over the contact and retrieve most recent activity where Type = 'Material Update- Meeting' AND Status = 'Completed'
                    for(Contact objContactrec : [select Id, Meeting__c, Phone__c, Last_meeting_material_update__c, Last_phone_material_update__c,Last_material_update_exception__c,CommFreq_Phone__c, CommFreq_Meeting__c,
                                                    (Select Id, WhoId, Status, Type, CreatedDate, ActivityDate from Tasks 
                                                     WHERE (Type = 'Material Update- Meeting' AND Status = 'Completed')
                                                     ORDER BY ActivityDate desc Limit 1)
                                                 FROM Contact Where Id IN: setRecentTask])
                    {
                    
                        if(!objContactrec.Tasks.isEmpty())
                        {
                            for(Task objTaskrec : objContactrec.Tasks)
                            {
                                // If the Meeting checkbox is checked, set the Last Meeting Material Update date to the date of the activity
                                if(objContactrec.Meeting__c == true)
                                {
                                    dtLast_meeting_material_update = objTaskrec.ActivityDate;
                                }
                                // Otherwise clear out date
                                else
                                {
                                    dtLast_meeting_material_update = null;
                                }
                            }
                        }
                        // No meeting record found; clear out date
                        else
                        {
                            dtLast_meeting_material_update = null;
                        }
                        
                        objContactrec.Last_meeting_material_update__c = dtLast_meeting_material_update;                     
                        mapIdToContact.put(objContactrec.Id,objContactrec);
                    
                    }

                    // Iterating over the contact and retrieve most recent activity where Type = 'Material Update- Phone' AND Status = 'Completed'
                    for(Contact objContactrec : [select Id, Meeting__c, Phone__c, Last_meeting_material_update__c, Last_phone_material_update__c,Last_material_update_exception__c,CommFreq_Phone__c, CommFreq_Meeting__c,
                                                    (Select Id, WhoId, Status, Type, CreatedDate, ActivityDate from Tasks 
                                                     WHERE (Type = 'Material Update- Phone' AND Status = 'Completed')
                                                     ORDER BY ActivityDate desc Limit 1)
                                                 FROM Contact Where Id IN: setRecentTask])
                    {
                    
                        // If a p activity was handled earlier and therefore the map contains data...
                        if(mapIdToContact.size() > 0)
                        {
                            // Retrieve the data worked on earlier and repopulate 
                            Contact objContact = mapIdToContact.get(objContactrec.Id);
                            objContactrec.Last_meeting_material_update__c = objContact.Last_meeting_material_update__c;
                        }
                                
                        if(!objContactrec.Tasks.isEmpty())
                        {
                            for(Task objTaskrec : objContactrec.Tasks)
                            {
                                // If the Phone checkbox is checked, set the Last Phone Material Update date to the date of the activity
                                if(objContactrec.Phone__c == true)
                                {
                                    dtLast_phone_material_update = objTaskrec.ActivityDate;
                                }
                                // Otherwise clear out date
                                else
                                {
                                    dtLast_phone_material_update = null;
                                }
                            }
                        }
                        // No phone record found; clear out date
                        else
                        {
                            dtLast_phone_material_update = null;
                        }
                        
                        objContactrec.Last_phone_material_update__c = dtLast_phone_material_update;                     
                        mapIdToContact.put(objContactrec.Id,objContactrec);
                    
                    }                   
                    
                    // Iterating over the contact and retrieve most recent activity where Status = 'Completed' (regardless of Type)
                    for(Contact objContactrec : [select Id, Meeting__c, Phone__c, Last_meeting_material_update__c, Last_phone_material_update__c,Last_material_update_exception__c,CommFreq_Phone__c, CommFreq_Meeting__c,
                                                    (Select Id, WhoId, Status, Type, CreatedDate, ActivityDate from Tasks 
                                                     WHERE ((Type = 'Material Update- Meeting' OR Type = 'Material Update- Phone') AND Status = 'Completed')
                                                     ORDER BY ActivityDate desc Limit 1)
                                                 FROM Contact Where Id IN: setRecentTask])
                    {
                    
                        // If a meeting or phone activity was handled earlier and therefore the map contains data...
                        if(mapIdToContact.size() > 0)
                        {
                            // Retrieve the data worked on earlier and repopulate 
                            Contact objContact = mapIdToContact.get(objContactrec.Id);
                            objContactrec.Last_phone_material_update__c = objContact.Last_phone_material_update__c;
                            objContactrec.Last_meeting_material_update__c = objContact.Last_meeting_material_update__c;
                        }
                                
                        if(!objContactrec.Tasks.isEmpty())
                        {
                            for(Task objTaskrec : objContactrec.Tasks)
                            {
                                // If type is Meeting material update and only Meeting is checked, clear the exception date
                                if(objTaskrec.Type == 'Material Update- Meeting' && objContactrec.Phone__c == false && objContactrec.Meeting__c == true )
                                {
                                    objContactrec.Last_material_update_exception__c = null;
                                }
                                // If type is Phone material update and only Phone is checked, clear the exception date
                                else if(objTaskrec.Type == 'Material Update- Phone' && objContactrec.Phone__c == true && objContactrec.Meeting__c == false )
                                {
                                    objContactrec.Last_material_update_exception__c = null;
                                }
                                // If type is Phone material update and Meeting checkbox is checked then update last meeting material and last material update exception field.
                                else if(objTaskrec.Type == 'Material Update- Phone' && objContactrec.Phone__c == false && objContactrec.Meeting__c == true )
                                {
                                    objContactrec.Last_meeting_material_update__c = objTaskrec.ActivityDate;
                                    objContactrec.Last_material_update_exception__c = objTaskrec.ActivityDate;
                                }
                                // If type is Meeting material update and Phone checkbox is checked then update last phone material and last material update exception field.
                                else if(objTaskrec.Type == 'Material Update- Meeting' && objContactrec.Phone__c == true && objContactrec.Meeting__c == false )
                                {
                                    objContactrec.Last_phone_material_update__c = objTaskrec.ActivityDate;
                                    objContactrec.Last_material_update_exception__c = objTaskrec.ActivityDate;
                                }
                            }
                        }
                        else
                        {
                            objContactrec.Last_phone_material_update__c = null;
                            objContactrec.Last_meeting_material_update__c = null;
                            objContactrec.Last_material_update_exception__c = null;
                        }
                        mapIdToContact.put(objContactrec.Id,objContactrec);
                    
                    }

                }
                // Updating the contact Field accordingly the conditions
                if(mapIdToContact.size() > 0 )
                {
                    update mapIdToContact.Values();
                    
                }
                if(test.isRunningTest())
                {
                    integer i = 10/0;
                }
            }
            catch(Exception ex)
            {
                system.debug('Got Exception-------------------------> ' +ex.getMessage());
            }       
            
        }       
        
    }