public class LastNextActivityTask {
    
//Clear last/next dates for contacts
    public void ClearLastNextDates(Set<ID> whoIdSet) {
        List<List<String>> ConditionalValues = FieldConditionMapping();
        string sSoqlQuery = ContactSQLString(ConditionalValues, whoIdSet);
        Map<ID, Contact> contactMap = new Map<ID, Contact>((List<Contact>)Database.query(sSoqlQuery));
        for (contact c1: contactMap.values()){
            for(integer i = 0; i< ConditionalValues.size(); i++){
                string sFieldOut = ConditionalValues[i][1]; //Field to write output to 
                c1.put(sFieldOut, null);
            }
            contactMap.put(c1.id, c1);
        }
        update contactMap.values();
    }
    
//Start: Last/Next Update code - After Update/Insert
    public void LastTasksUpdate(list<Task> TaskEventList) {
        Set<ID> whoIdSet = new Set<ID>();
        for(Task e: TaskEventList){
            if(e.whoId != null){
                whoIdSet.add(e.WhoId);
            }
        }
        List<List<String>> ConditionalValues = FieldConditionMapping();
        
        string sSoqlQuery = ContactSQLString(ConditionalValues, whoIdSet);
        System.debug('sSoqlQuery ' + sSoqlQuery);
        //Map<ID, Contact> contactMap = new Map<ID, Contact>([select id, Last_Office_Visit_Date__c, Last_QU_Date__c, Last_ES_Date__c, Next_QU_Date__c from contact where id in :whoIdSet]);
        Map<ID, Contact> contactMap = new Map<ID, Contact>((List<Contact>)Database.query(sSoqlQuery));
        Map<ID, Contact> updContactList = new Map<ID, Contact>();
        
        
        for(Task e: TaskEventList) {
            if(e.whoId != null && e.ActivityDate != null && contactMap.containsKey(e.whoId) ){
                Contact c1 = contactMap.get(e.whoId); // Assigns the contact object
                boolean isPast = (e.ActivityDate > Date.today()) ? false : true; //Checks if activity is in the past or future
                Date eventdate = Date.newInstance( e.ActivityDate.year(), e.ActivityDate.month(), e.ActivityDate.day());  //gives a formatted date
                boolean bUpdated = false; //Sets the default update flag to false for each itteration of the TaskEventList
                for(integer i = 0; i< ConditionalValues.size(); i++){
                    string sFieldOut = ConditionalValues[i][1]; //Field to write output to 
                    string sLastNext = ConditionalValues[i][2];
                    string sValuetoCheck = ConditionalValues[i][0]; //Value to check for
                    string sFieldtoCheck = ConditionalValues[i][3]; //Field to check in
                    Date dFieldVal = date.valueof(c1.get(sFieldOut));
                    string sFieldtoCheckValue = string.valueOf(e.get(sFieldtoCheck));  //This is to check the value in the array against the requested field
                    
                    //Clears existing next date if next date is less than today
                    If (sLastNext == 'Next' && dFieldVal < Date.today() && dFieldVal != null){
                        c1.put(sFieldOut, null);
                        bUpdated = true; //Flags the contact as updated
                    }
                    if (sLastNext == 'Last' && !isPast) { //Exits loop instance if activity is in future and this is a 'last' instance
                        continue;
                    }
                    if (sLastNext == 'Last' && !e.Status.equals('Completed')) { //Exits loop instance if activity is in past but not completed
                        continue;
                    }
                    if (sLastNext == 'Next' && isPast) {  //Exits loop instance if activity is in past and this is a 'next' instance
                        continue;
                    }
                    if (sFieldOut == 'Last_Email__c'){
                        string sSubject = e.subject;
                        if (sSubject != null){
                            if (sSubject.contains('Email:')){
                                sFieldtoCheckValue = 'Email';
                            }
                        }
                        
                    }
                    //Updates values, since invalid options are eliminated above
                    //Will always update on existing value being null
                    //Will update past activity if the event date is newer (but still in past)
                    //Updates future activity if existing date is farther in the future, so activity next week will display instead of an activity next year
                    if (sFieldtoCheckValue == sValuetoCheck){
                        if((dFieldVal == null) || 
                           ((sLastNext =='Last') && (eventdate > dFieldVal)) ||
                           ((sLastNext =='Next') && (eventdate < dFieldVal)) ){
                            c1.put(sFieldOut, eventdate);
                            bUpdated = true; //Flags the contact as updated
                        }
                    }
                    
                }
                if (bUpdated == true){ //Only adds updated contacts to the final output
                    updContactList.put(e.whoId, c1); //Writes only updated items to the output list to reduce apex calls
                    contactMap.put(e.whoId, c1);  //For bulkifying - If multiple changes happen the source list needs to be updated
                }
            }
        }
        if(updContactList.size()>0){
            update updContactList.values();
        }
    }
    
    //Copy of LastTasksUpdate
    //Kinda cludgey, basically make all updates to the LastTasksUpdate group
    //Then delete LastEventUpdate and recreate it from the above just updating task to event
    //Also remove the full condition containing !e.Status.equals('Completed')
    public void LastEventsUpdate(list<Event> EventEventList) {
        Set<ID> whoIdSet = new Set<ID>();
        for(Event e: EventEventList){
            if(e.whoId != null){
                whoIdSet.add(e.WhoId);
            }
        }
        
        List<List<String>> ConditionalValues = FieldConditionMapping();
        
        string sSoqlQuery = ContactSQLString(ConditionalValues, whoIdSet);
        System.debug('sSoqlQuery ' + sSoqlQuery);
        //Map<ID, Contact> contactMap = new Map<ID, Contact>([select id, Last_Office_Visit_Date__c, Last_QU_Date__c, Last_ES_Date__c, Next_QU_Date__c from contact where id in :whoIdSet]);
        Map<ID, Contact> contactMap = new Map<ID, Contact>((List<Contact>)Database.query(sSoqlQuery));
        Map<ID, Contact> updContactList = new Map<ID, Contact>();
        
        
        for(Event e: EventEventList) {
            if(e.whoId != null && e.ActivityDate != null && contactMap.containsKey(e.whoId) ){

                Contact c1 = contactMap.get(e.whoId); // Assigns the contact object
                boolean isPast = (e.ActivityDate > Date.today()) ? false : true; //Checks if activity is in the past or future
                Date eventdate = Date.newInstance( e.ActivityDate.year(), e.ActivityDate.month(), e.ActivityDate.day());  //gives a formatted date
                boolean bUpdated = false; //Sets the default update flag to false for each itteration of the EventEventList
                for(integer i = 0; i< ConditionalValues.size(); i++){
                    string sFieldOut = ConditionalValues[i][1]; //Field to write output to 
                    string sLastNext = ConditionalValues[i][2];
                    string sValuetoCheck = ConditionalValues[i][0]; //Value to check for
                    string sFieldtoCheck = ConditionalValues[i][3]; //Field to check in
                    Date dFieldVal = date.valueof(c1.get(sFieldOut));
                    string sFieldtoCheckValue = string.valueOf(e.get(sFieldtoCheck));  //This is to check the value in the array against the requested field
                    
                    //Clears existing next date if next date is less than today
                    If (sLastNext == 'Next' && dFieldVal < Date.today() && dFieldVal != null){
                        c1.put(sFieldOut, null);
                        bUpdated = true; //Flags the contact as updated
                    }
                    if (sLastNext == 'Last' && !isPast) { //Exits loop instance if activity is in future and this is a 'last' instance
                        continue;
                    }
                    if (sLastNext == 'Next' && isPast) {  //Exits loop instance if activity is in past and this is a 'next' instance
                        continue;
                    }
                    //Updates values, since invalid options are eliminated above
                    //Will always update on existing value being null
                    //Will update past activity if the event date is newer (but still in past)
                    //Updates future activity if existing date is farther in the future, so activity next week will display instead of an activity next year
                    if (sFieldtoCheckValue == sValuetoCheck){
                        if((dFieldVal == null) || 
                           ((sLastNext =='Last') && (eventdate > dFieldVal)) || 
                           ((sLastNext =='Next') && (eventdate < dFieldVal)) ){
                            c1.put(sFieldOut, eventdate);
                            bUpdated = true; //Flags the contact as updated
                        }
                    }
                    
                }
                if (bUpdated == true){ //Only adds updated contacts to the final output
                    updContactList.put(e.whoId, c1); //Writes only updated items to the output list to reduce apex calls
                    contactMap.put(e.whoId, c1);  //For bulkifying - If multiple changes happen the source list needs to be updated
                }
            }
        }
        if(updContactList.size()>0){
            update updContactList.values();
        }
    }
    
    //Creates a dynamic "select" part of SQL statement
    //:whosetid needs to equal the name of the whoset in the calling class
    //It doesn't process as a variable until it is excuted in the container class
    Private string ContactSQLString(List<List<String>> SelectVar, Set<ID> whoIdSet){
        List<List<String>> ConditionalValues = FieldConditionMapping();
        set<string> selectItems = new set<string>();
        //Because there can be multiple conditions for the same column
        //To keep the select statement unique we populate a set then feed that set into a string
        for(integer i = 0; i< ConditionalValues.size(); i++){
            selectItems.add(ConditionalValues[i][1]);
        }
        string SelectString = ''; 
        for(String s:selectItems) {
           SelectString += s + ' ';
        }
        SelectString = SelectString.trim();
        SelectString = SelectString.replace(' ', ', ');
        System.debug('Select  -  ' + SelectString);
        String templateSOQL = 'select id, ' +  SelectString + '  from contact'; 
        templateSOQL += ' where id in :whoIdSet';
        Return templateSOQL;
    }
    
    //Easy to update list of items
    private List<List<String>> FieldConditionMapping(){
        List<List<String>> FieldsandValues = new List<List<String>>{
            //Layout{Type Condition, field name to update, before/after today condition, Subject Condition, field to check against, **}
            //** = Corresponding last field, this is for the bulk update, when a 'next' field has a date before today
            //it's in there to move the next date to the last date and wipe the next date
            new List<String>{'Office Visit', 'Last_Office_Visit__c', 'Last', 'type__c', ''},
            new List<String>{'ES', 'Last_ES__c', 'Last', 'type__c', ''},
            new List<String>{'QU', 'Next_QU__c', 'Next', 'type__c', ''},
            //untested
            //new List<String>{'Email', 'Last_Email__c', 'last', 'subject', ''},
            new List<String>{'Last Client Meeting', 'LAST_CLIENT_MEETING__c', 'Last', 'type__c', ''},
            new List<String>{'Conference', 'LAST_CONFERENCE__c', 'Last', 'type__c', ''},
            new List<String>{'Client Seminar', 'LAST_CLIENT_SEMINAR__c', 'Last', 'type__c', ''},
            new List<String>{'Executive Office Visit', 'LAST_EXEC_OV__c', 'Last', 'type__c', ''},
            new List<String>{'Conference Call', 'LAST_CONFERENCE_CALL__c', 'Last', 'type__c', ''},
            new List<String>{'QU Attempt', 'LAST_QU_ATTEMPT__c', 'Last', 'type__c', ''},
            new List<String>{'QU', 'LAST_QU__c', 'Last', 'type__c', ''},
            new List<String>{'OVFU', 'LAST_OVFU__c', 'Last', 'type__c', ''},
            new List<String>{'Scheduled Phone Call', 'LAST_SCHEDULED_CALL__c', 'Last', 'type__c', ''},
            new List<String>{'IPCC ES Attempt', 'LAST_IPCC_ES_ATTEMPT__c', 'Last', 'type__c', ''},
            new List<String>{'ESFU', 'LAST_ESFU__c', 'Last', 'type__c', ''},
            new List<String>{'IPCC ES', 'LAST_IPCC_ES__c', 'Last', 'type__c', ''},
            new List<String>{'ESFU Attempt', 'LAST_ESFU_ATTEMPT__c', 'Last', 'type__c', ''},
            new List<String>{'OVFU Attempt', 'LAST_OVFU_ATTEMPT__c', 'Last', 'type__c', ''},
            new List<String>{'OV Attempt', 'LAST_OFFICE_VISIT_ATTEMPT__c', 'Last', 'type__c', ''}, //Two different selection items for OV attempt into same summary
            new List<String>{'Office Visit Attempt', 'LAST_OFFICE_VISIT_ATTEMPT__c', 'Last', 'type__c', ''},  //Two different selection items for OV attempt into same summary
            new List<String>{'IPCC FU Attempt', 'LAST_IPCC_FU_ATTEMPT__c', 'Last', 'type__c', ''},
            new List<String>{'IPCC FU', 'LAST_IPCC_FU__c', 'Last', 'type__c', ''},
            new List<String>{'ES Attempt', 'LAST_ES_ATTEMPT__c', 'Last', 'type__c', ''},
            new List<String>{'Scheduled OV', 'LAST_SCHEDULED_OV__c', 'Last', 'type__c', ''},
            //Subject Section 
            //Next Call, Activity, Meeting
            new List<String>{'Call', 'NEXT_ACTIVITY__c', 'Next', 'subject', ''},
            new List<String>{'Call', 'NEXT_CALL__c', 'Next', 'subject', ''},
            new List<String>{'Meeting', 'NEXT_ACTIVITY__c', 'Next', 'subject', ''},
            new List<String>{'Meeting', 'NEXT_MEETING__c', 'Next', 'subject', ''},
            //Last Call, Activity, Meeting
            new List<String>{'Meeting', 'LAST_ACTIVITY__c', 'Last', 'subject', ''},
            new List<String>{'Call', 'LAST_ACTIVITY__c', 'Last', 'subject', ''},
            new List<String>{'Meeting', 'LAST_MEETING__c', 'Last', 'subject', ''},
            new List<String>{'Call', 'LAST_CALL__c', 'Last', 'subject', ''}
        };
        return FieldsandValues;
    }
//End: Last/Next Update code 

//Start: Concatination Elements - Before update/Insert
    //Tasks 
    public void CalendarConcatTasks(list<Task> TaskEventList) {
        Set<ID> whoIdSet = new Set<ID>();
        for(Task e: TaskEventList){
            if(e.whoId != null){
                whoIdSet.add(e.WhoId);
            }
        }
        //System.Debug('>>>>>>> the value of:' + whoIdSet);
        Map<ID, Contact> contactMap = new Map<ID, Contact>([select id, TGC__c, name from contact where id in :whoIdSet]);
        Map<ID, Task> updatedTaskMap = new Map<ID, Task>();
        for (Task t: TaskEventList)
        {
            Contact c1 = contactMap.get(t.whoId); // Assigns the contact object            
            if (t == null) {continue;}          
            if (c1 == null) {continue;}
            String combinedField = '';
            if (c1.Name != null) {combinedField += c1.Name + '-';}
            if (t.Type__c != null) {combinedField += t.Type__c + '-';}
            if (t.Subject != null) {combinedField += t.Subject + '-';}
            if (t.Type__c != 'Travel'){
                if (c1.TGC__c != null) {combinedField += c1.TGC__c + '-';}
            }
            combinedField = combinedField.removeEnd('-');
            t.Combined_Name_Subject_Type__c = combinedField;
        }
    }    
    //Event Copy
    public void CalendarConcatEvents(list<Event> EventEventList) {
        Set<ID> whoIdSet = new Set<ID>();
        for(Event e: EventEventList){
            if(e.whoId != null){
                whoIdSet.add(e.WhoId);
            }
        }
        //System.Debug('>>>>>>> the value of:' + whoIdSet);
        Map<ID, Contact> contactMap = new Map<ID, Contact>([select id, TGC__c, name from contact where id in :whoIdSet]);
        Map<ID, Event> updatedEventMap = new Map<ID, Event>();
        for (Event t: EventEventList)
        {
            Contact c1 = contactMap.get(t.whoId); // Assigns the contact object            
            if (t == null) {continue;}          
            if (c1 == null) {continue;}
            String combinedField = '';
            if (c1.Name != null) {combinedField += c1.Name + '-';}
            if (t.location != null) {combinedField += ' (' + t.location + ') -';}
            if (t.Type__c != null) {combinedField += t.Type__c + '-';}
            if (t.Subject != null) {combinedField += t.Subject + '-';}
            if (t.Type__c != 'Travel'){
                if (c1.TGC__c != null) {combinedField += c1.TGC__c + '-';}
            }
            combinedField = combinedField.removeEnd('-');
            t.Combined_Name_Subject_Type__c = combinedField;
        }
    }
//End: Concatination Elements

//Start: Pipeline Update
   public void updateAllPipelines(){
        set<id> listPL = new set<id>();
        for(pipeline_ticket__c pl : [SELECT id FROM pipeline_ticket__c]){
            listPL.add(pl.id);       
        }
        NextPipelineUpdate(listPL);
    }
    public void NextPipelineUpdate(set<id> pipelineIDs){
        List<pipeline_ticket__c> ptl = [SELECT id, Next_Activity__c,
                                         (SELECT ActivityDate, Description 
                                         FROM OpenActivities
                                         Order by ActivityDate Desc) 
                                        FROM pipeline_ticket__c
                                       where id in :pipelineIDs];
        
        Map<ID, pipeline_ticket__c> UpdatedTickets = new Map<ID, pipeline_ticket__c>();
        
        for (pipeline_ticket__c pt : ptl){
            //Clears pipeline value
            pt.Next_Activity__c = null;
            UpdatedTickets.put(pt.id, pt);
            
            for(OpenActivity act : pt.OpenActivities){
                if ((act.ActivityDate < pt.Next_Activity__c || pt.Next_Activity__c == null)) {
                    pt.Next_Activity__c = act.ActivityDate;
                    UpdatedTickets.put(pt.id, pt);
                }
            }
        }      
        update UpdatedTickets.values();
    }
}