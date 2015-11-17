/**
* \arg ClassName      : SL_Batch_SendEmailReminder
* \arg JIRATicket     : PWP-18, PWP-53
* \arg CreatedOn      : 31/MAR/2015
* \arg LastModifiedOn : 23/Sept/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Lodhi, Pankaj Ganwani
* \arg Description    : This class serves the purpose for sending emails to activity owners if a call report has not been created corresponding to the Activity.
*/
global class SL_Batch_SendEmailReminder implements Database.Batchable<Sobject>
{
    /* Start - Variables */
    private static String strQuery;//variable to hold the dynamic soql framed by email template
    private static final String strHTMLBody;//variable to hold html body of email template
    private static final String strSubject;//variable to hold subject line of email template
    private static final Map<String,String> mapFieldAPIToType;// this map is used to hold the field api name and field type of Event object fields.
    private static final String defaultEmailAddress = Reply_To_Address__c.getInstance('Default')!=null ? Reply_To_Address__c.getInstance('Default').Reply_To_Email__c : NULL;
    private static final Date dynamicDate = Dynamic_Date_for_Email__c.getInstance('Dynamic Date')!=null ? Dynamic_Date_for_Email__c.getInstance('Dynamic Date').Start_Date__c : NULL;
    private static final String strBaseURL = Url.getSalesforceBaseUrl().toExternalForm();
    /* End - Variables */
    
    static
    {
        mapFieldAPIToType = new Map<String,String>();
        for(Schema.Sobjectfield objField: Event.getSobjectType().getDescribe().fields.getMap().values())
        {
            Schema.Describefieldresult objFieldResult = objField.getDescribe();
            mapFieldAPIToType.put(objFieldResult.getName(), String.valueOf(objFieldResult.getType()));
        }
        
        strQuery = 'SELECT Id, Call_Report_Id__c, WhoId, WhatId, What.Name';
        List<EmailTemplate> lstEmailTemplate = [SELECT HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName =: 'Send_Call_Report_Reminder' LIMIT 1];
        if(!lstEmailTemplate.isEmpty())
        {
            EmailTemplate objEmailTemplate = lstEmailTemplate[0];
            strHTMLBody = objEmailTemplate.HtmlValue;
            strSubject = objEmailTemplate.Subject;
            
            if(objEmailTemplate.HtmlValue.contains('{!Event.'))
                replaceMergeFields(objEmailTemplate.HtmlValue);
            
            if(objEmailTemplate.Subject.contains('{!Event.'))
                replaceMergeFields(objEmailTemplate.Subject);
        }
        strQuery += ' FROM Event WHERE Call_Report_Id__c = null AND GroupEventType!=\'2\' AND ActivityDate >: dynamicDate AND ActivityDate < TODAY AND Owner.isActive = true AND WhatId!=NULL AND What.Type = \'Account\' AND Don_t_Send_Call_Report_Reminder__c=false AND isChild = false';
    }
    
    /* Start - Constructor */
    global SL_Batch_SendEmailReminder()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    /**
        @MethodName : start
        @Param      : reference of Database.BatchableContext to track the progress of batch job.
        @Description: This method is used to pass the list of Event records to the execute method of interface.
    **/
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(strQuery);
    }
    
    /**
        @MethodName : execute
        @Param      : reference of Database.BatchableContext to track the progress of batch job and list of event records received from start method
        @Description: This method is used to check for the existing call report corresponding to Event records and sending the email to those Activity owners for which the call report does not exist.
    **/
    global void execute(Database.BatchableContext BC, List<Event> lstEvent)
    {
        String strEmailHTMLBody = '';
        String strSubjectWithoutMergeField = '';
        Set<Id> setOwnerId = new Set<Id>();
        Set<String> setSubject = new Set<String>();
        Set<Id> setEventId = new Set<Id>();
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setIsSendReminderAccId = new Set<Id>();
        Map<Id,Id> mapEventIdToShadowActivityId = new Map<Id,Id>();
        Map<String,Event> mapUniqueCombinationToEvent = new Map<String,Event>();
        List<Messaging.Singleemailmessage> lstMails = new List<Messaging.Singleemailmessage>();
        List<Id> lstTargetObjectId = new List<Id>();
        
        for(Shadow_Activity__c objShadowActivity: [SELECT Id, Original_Activity_ID__c FROM Shadow_Activity__c WHERE Original_Activity_ID__c IN : (new Map<Id,Event>(lstEvent)).keyset()])
        {
            mapEventIdToShadowActivityId.put(objShadowActivity.Original_Activity_ID__c, objShadowActivity.Id);
        }
        
        //Iterating over list of events to hold ownerids, acitivity ids and subjects
        for(Event objEvent : lstEvent)
        {
            setAccountId.add(objEvent.WhatId);
            setOwnerId.add(objEvent.OwnerId);
        }
        
        /* Added by Lodhi for PWP-53 on 7/July/2015 to avoid sending an email to event owner if Send_Call_Report_Reminder__c is false */
        for(Account objAccount : [SELECT Id FROM Account WHERE Id IN : setAccountId AND Send_Call_Report_Reminder__c = true])
        {
            setIsSendReminderAccId.add(objAccount.Id);
        }
        /* Added by Lodhi for PWP-53 on 7/July/2015 to avoid sending an email to event owner if Send_Call_Report_Reminder__c is false */
        
        Map<Id,User> mapIdToUser = new Map<Id,User>([SELECT Id, Name, Username,Call_Report_Reminder_CC__c,Send_Call_Report_Reminder__c, Email FROM User WHERE Id IN:setOwnerId]);
        
        for(Event objEvent : lstEvent)
        {
            if(!setEventId.contains(objEvent.Id) && mapIdToUser.get(objEvent.OwnerId).Send_Call_Report_Reminder__c && setIsSendReminderAccId.contains(objEvent.WhatId))
            {
                String objectId = objEvent.WhatId;
                Id shadowActivityId = mapEventIdToShadowActivityId.get(objEvent.Id);
                strEmailHTMLBody = strHTMLBody;
                strSubjectWithoutMergeField = strSubject;
                Messaging.Singleemailmessage objEmail = new Messaging.Singleemailmessage();
                objEmail.setHtmlBody(replaceMergeFieldsWithValues(strEmailHTMLBody, objEvent, mapIdToUser, objEvent.What.Name) + '\n'+'&nbsp;Create Call Report: <a target = "_blank" href="'+strBaseURL+'/apex/SL_CallReportInlineVF?objId='+objectId+'&ActId='+objEvent.Id+'">New Call Report</a><br/><p>If this meeting does not require a Call Report, please click this link: <a target = "_blank" href="'+strBaseURL+'/apex/SL_EventAutoUpdater?EventId='+ objEvent.Id+'">Cancel Reminder</a></p>');
                objEmail.setSubject(replaceMergeFieldsWithValues(strSubjectWithoutMergeField, objEvent, mapIdToUser, objEvent.What.Name));
                objEmail.setToAddresses(new List<String>{mapIdToUser.get(objEvent.OwnerId).Email});
                
                 /* Added by Nrusingh for PWP-234 on 1st september to send email to All email addresses listed on the user record will be cced on all call report reminder emails sent to that user. */
                if(mapIdToUser.get(objEvent.OwnerId).Call_Report_Reminder_CC__c !=null)
                {
                    objEmail.setCcAddresses(mapIdToUser.get(objEvent.OwnerId).Call_Report_Reminder_CC__c.split('\\;'));
                }
                if(String.isNotEmpty(defaultEmailAddress))
                    objEmail.setReplyTo(defaultEmailAddress);
                lstMails.add(objEmail);    
                
                /* Added by Lodhi as part of PWP-234 to capture the failure reminders */
                lstTargetObjectId.add(objEvent.OwnerId);
                /* Added by Lodhi as part of PWP-234 to capture the failure reminders */
            }
        }
        
        if(!lstMails.isEmpty())
        {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(lstMails,false);
            Set<Id> setTargetObjectIds = new Set<Id>();
            lstMails = new List<Messaging.Singleemailmessage>();
            String strToEmailAddress = Call_Report_Invalid_Emails__c.getOrgDefaults().Email__c;
            setTargetObjectIds.addAll(lstTargetObjectId);
            String strFailureEmailBody = '';
            if(!String.isEmpty(strToEmailAddress))
            {
                for(Integer i = 0; i < results.size(); i++)
                {
                    if(!results[i].isSuccess())
                    {
                        if(setTargetObjectIds.contains(lstTargetObjectId[i]))
                        {
                            strFailureEmailBody += '<br/>'+ mapIdToUser.get(lstTargetObjectId[i]).Name;
                            setTargetObjectIds.remove(lstTargetObjectId[i]); 
                        }
                    }
                }
                if(!String.isEmpty(strFailureEmailBody))
                {
                    Messaging.Singleemailmessage objEmailFailure = new Messaging.Singleemailmessage();
                    objEmailFailure.setSubject('Failed call report reminders');
                    objEmailFailure.setHtmlBody('Below is the list of users whose call reports reminder failed due to invalid cc email address:' + strFailureEmailBody);
                    objEmailFailure.setToAddresses(new List<String>{strToEmailAddress});
                    lstMails.add(objEmailFailure); 
                    if(!lstMails.isEmpty())
                        Messaging.sendEmail(lstMails,false);
                }        
            }    
        }    
    }
    
    /**
        @MethodName : replaceMergeFields
        @Param      : String containing merge fields
        @Description: This method is used to form soql with merge fields contained in the passed string.
    **/
    private static void replaceMergeFields(String mergeFieldString)
    {
        while(mergeFieldString.indexOf('{!Event.')!=-1)
        {
            String strFieldAPIName = String.valueOf(mergeFieldString.subStringBetween('{!Event.', '}')).trim();
            strFieldAPIName = (strFieldAPIName == 'What') ? '' : strFieldAPIName;
            if(!strQuery.contains(strFieldAPIName))
                strQuery += ', '+strFieldAPIName;
            mergeFieldString = (strFieldAPIName == '') ? mergeFieldString.replace('{!Event.What}','') :mergeFieldString.replace('{!Event.'+strFieldAPIName+'}','');
        }
    }
    
    /**
        @MethodName : replaceMergeFieldsWithValues
        @Param      : String containing merge fields, event object and map of Activity owner records.
        @Description: This method is used to replace the merge fields with their values stored in event object.
    **/
    private String replaceMergeFieldsWithValues(String mergeFieldString, Event objEvent, Map<Id, User> mapIdToUser, String strCompanyName)
    {
        while(mergeFieldString.indexOf('{!Event.')!=-1)
        {
            String strFieldAPIName = String.valueOf(mergeFieldString.subStringBetween('{!Event.', '}')).trim();
            if(mapFieldAPIToType.containskey(strFieldAPIName) && mapFieldAPIToType.get(strFieldAPIName) == 'DATE')
            {
                Date dtActivityDate = Date.valueOf(objEvent.get(strFieldAPIName));
                mergeFieldString = mergeFieldString.replace('{!Event.'+strFieldAPIName+'}', String.join(new List<Integer>{dtActivityDate.month(),dtActivityDate.day(),dtActivityDate.year()},'/'));
                
            }
            else if(strFieldAPIName == 'What')
            {
                mergeFieldString = mergeFieldString.replace('{!Event.What}', strCompanyName);
            }
            else
            {
                mergeFieldString = strFieldAPIName!='OwnerId' ? mergeFieldString.replace('{!Event.'+strFieldAPIName+'}',String.valueOf(objEvent.get(strFieldAPIName))) : mergeFieldString.replace('{!Event.'+strFieldAPIName+'}',mapIdToUser.get(objEvent.OwnerId).Username);
            }
        }
        return mergeFieldString;
    }
    
    /**
        @MethodName : finish
        @Param      : reference of Database.BatchableContext to track the progress of batch job
        @Description: finish method of the interface
    **/
    global void finish(Database.BatchableContext BC)
    {
        //Do nothing
    }
}