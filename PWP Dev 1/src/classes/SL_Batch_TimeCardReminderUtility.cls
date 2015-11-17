/**
* \arg ClassName      : SL_Batch_TimeCardReminderUtility
* \arg JIRATicket     : PWP-215
* \arg CreatedOn      : 10/SEP/2015
* \arg LastModifiedOn : 11/SEP/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : This class serves as utility class for the SL_Batch_TimeCardAvailabilityReminder and SL_Batch_TimeCardFillingReminder class.
*/
public without sharing class SL_Batch_TimeCardReminderUtility 
{ 
    private static Set<String> setCCEmailAddresses;
    private static Map<String,String> mapFieldAPIToType;// this map is used to hold the field api name and field type of Event object fields.
    private static String strBaseURL = Url.getSalesforceBaseUrl().toExternalForm();
    private static Map<Decimal, String> mapOffsetToTimeZoneKey;
    private static Set<String> setTimeZoneSidKey;
    
    /* Start - Constructor */
    public SL_Batch_TimeCardReminderUtility()
    {
        initialization();
        fetchRequiredData();
    }
    /* End - Constructor */
    
    /**
        @MethodName : initialization
        @Param      : NA
        @Description: This method is used to initializing the variables.
    **/
    private void initialization()
    {
        mapFieldAPIToType = new Map<String,String>();
        mapOffsetToTimeZoneKey = new Map<Decimal, String>();
        setCCEmailAddresses = new Set<String>();
    }
    /* End */
    
    /**
        @MethodName : sendTimeCardEmailReminder
        @Param      : List of Time_Card__c, email body, email subject and batch type 
        @Description: This method is used to send the email reminder to time card users.
    **/
    public static void sendTimeCardEmailReminder(List<Time_Card__c> lstTimeCards, String strHTMLBody, String strSubject, String strBatchType, 
                                                 String strPreferredDay, String strPreferredTime, String strAdditionalRecipients)
    {
        String strEmailHTMLBody = ''; 
        String strEmailSubject = '';
        List<String> lstCCEmails = new List<String>();
        Map<Id, List<Time_Card__c>> mapResourceIdToLstTimeCard = new Map<Id, List<Time_Card__c>>();
        List<Messaging.Singleemailmessage> lstMails = new List<Messaging.Singleemailmessage>();
        Boolean isAvailability = (strBatchType == 'Availability') ? true : false;
         
        //Preparing a map of resource id to list of their time cards
        for(Time_Card__c objTimeCard : lstTimeCards)
        {
            if(!mapResourceIdToLstTimeCard.containsKey(objTimeCard.Resource__c))
                mapResourceIdToLstTimeCard.put(objTimeCard.Resource__c, new List<Time_Card__c>{objTimeCard});
            else    
                mapResourceIdToLstTimeCard.get(objTimeCard.Resource__c).add(objTimeCard);
        }
        
        //Adding other email addresses
        if(!String.isEmpty(strAdditionalRecipients))
        {
            for(String strEmail : strAdditionalRecipients.split(','))
                setCCEmailAddresses.add(strEmail.trim());
        }
        lstCCEmails.addAll(setCCEmailAddresses);
        
        //Offset calculations
        Decimal intOffset = 0.0;
        Decimal decMinute = Datetime.now().minuteGmt();
        decMinute = decMinute / 60;
        decMinute = decMinute.setScale(2);
        intOffset = (Decimal.valueOf(strPreferredTime) - (DateTime.now().hourGmt() + decMinute));    
        String strTimeZone = mapOffsetToTimeZoneKey.containsKey(intOffset) ? mapOffsetToTimeZoneKey.get(intOffset) : '';
        
        //Calculating est hours and minutes to restrict sending email after 11.59 est time
        String strEstTime = DateTime.now().format('MM/dd/yyyy HH:mm:ss', 'America/Panama');
        strEstTime = strEstTime.split(' ')[1];
        Integer estHour = Integer.valueOf(strEstTime.split(':')[0]);
        Integer estMinute = Integer.valueOf(strEstTime.split(':')[1]);
        
        //execute only for test runs
        if(Test.isRunningTest())
        {
            strTimeZone = 'America/Los_Angeles';    
            estHour = 22;
            estMinute = 50;
            isAvailability = false;
        }
        
        //Sending email alerts only once on the preferred time respected to user's timezone
        if(strTimeZone != '' && DateTime.now().format('EEE') == strPreferredDay)
        {
            for(User objUser : [SELECT Id, Email FROM User WHERE Id IN : mapResourceIdToLstTimeCard.keySet() 
                                   AND TimeZoneSidKey =: strTimeZone AND Time_Tracking_User__c = true])
            {
                for(Time_Card__c objTC : mapResourceIdToLstTimeCard.get(objUser.Id))
                {
                    strEmailHTMLBody = strHTMLBody;
                    strEmailSubject = strSubject;
                    Messaging.Singleemailmessage objEmail = new Messaging.Singleemailmessage();
                    objEmail.setSubject(replaceMergeFieldsWithValues(strEmailSubject, objTC));
                    objEmail.setHtmlBody(replaceMergeFieldsWithValues(strEmailHTMLBody, objTC));
                    if(isAvailability)
                    	objEmail.setCcAddresses(lstCCEmails);
                    objEmail.setTargetObjectId(objUser.Id);
                    objEmail.saveAsActivity = false;
                    lstMails.add(objEmail); 
                }    
            }
        }
        
        //Sending email to remind those users whose time card has zero hours/percentage this email goes within defined intervals only.
        if(!isAvailability && (estHour <= 23 && estMinute < 59)) 
        {
            Set<String> setTimeZone = new Set<String>();
            for(String strKey : setTimeZoneSidKey)
            {
                String strTimeZoneTime = DateTime.now().format('MM/dd/yyyy HH:mm:ss', strKey);
                strTimeZoneTime = strTimeZoneTime.split(' ')[1];
                Integer timeZoneHour = Integer.valueOf(strTimeZoneTime.split(':')[0]);
                if(timeZoneHour >= Decimal.valueOf(strPreferredTime))
                {
                    setTimeZone.add(strKey);
                }
            }
            if(!setTimeZone.isEmpty())
            {
                for(User objUser : [SELECT Id, Email FROM User WHERE Id IN : mapResourceIdToLstTimeCard.keySet() 
                                       AND TimeZoneSidKey IN : setTimeZone AND Time_Tracking_User__c = true])
                {
                    for(Time_Card__c objTC : mapResourceIdToLstTimeCard.get(objUser.Id))
                    {
                        strEmailHTMLBody = strHTMLBody;
                        strEmailSubject = strSubject;
                        Messaging.Singleemailmessage objEmail = new Messaging.Singleemailmessage();
                        objEmail.setSubject(replaceMergeFieldsWithValues(strEmailSubject, objTC));
                        objEmail.setHtmlBody(replaceMergeFieldsWithValues(strEmailHTMLBody, objTC));
                        objEmail.setTargetObjectId(objUser.Id);
                        objEmail.saveAsActivity = false;
                        lstMails.add(objEmail); 
                    }    
                }
            }
         }
         
         if(!lstMails.isEmpty())
            Messaging.sendEmail(lstMails);
    }
    /* End */
    
    /**
        @MethodName : fetchTimeZoneOffsetToTimeZoneKey
        @Param      : NA
        @Description: This method is used to a map of timezone offset to timezone key.
    **/
    private void fetchRequiredData()
    {
        setTimeZoneSidKey = new Set<String>();
        
        for(Time_Card_Distribution_Lists__c objTCDL : Time_Card_Distribution_Lists__c.getAll().values())
        {
            for(String strEmail : objTCDL.Email_Ids__c.split(','))
            {
                setCCEmailAddresses.add(strEmail.trim());
            }
        }
        
        //To fill a map of field api name to its type
        for(Schema.Sobjectfield objField: Time_Card__c.getSobjectType().getDescribe().fields.getMap().values())
        {
            Schema.Describefieldresult objFieldResult = objField.getDescribe();
            mapFieldAPIToType.put(objFieldResult.getName(), String.valueOf(objFieldResult.getType()));
        }
        
        //Iterating on user to get the TimeZoneSidKey into set
        for(User objUser : [SELECT Id, Name, Email, Time_Tracking_User__c, TimeZoneSidKey FROM User WHERE Time_Tracking_User__c = true])
        {
            setTimeZoneSidKey.add(objUser.TimeZoneSidKey);
        }
        
        //Iterating on TimeZoneSidKey to fill a map of offset to TimeZoneSidKey
        for(String strTimeZoneKey : setTimeZoneSidKey)
        {
            Timezone objTimeZone = Timezone.getTimeZone(strTimeZoneKey);
            Decimal decOffSet = objTimeZone.getOffset(DateTime.now()) / (60 * 60);
            decOffSet = decOffSet / 1000;
            decOffSet = decOffSet.setScale(2);
            mapOffsetToTimeZoneKey.put(decOffSet, strTimeZoneKey);
        }
    }
    
    /**
        @MethodName : replaceMergeFields
        @Param      : String containing merge fields
        @Description: This method is used to form soql with merge fields contained in the passed string.
    **/
    public static String replaceMergeFields(String mergeFieldString, String strQuery)
    {
        //replacing all merge fields from the string and adding them to the query string 
        while(mergeFieldString.indexOf('{!Time_Card__c.') != -1)
        {
            String strFieldAPIName = String.valueOf(mergeFieldString.subStringBetween('{!Time_Card__c.', '}')).trim();
            if(!strQuery.contains(strFieldAPIName))
                strQuery += ', '+strFieldAPIName;
                
            mergeFieldString = mergeFieldString.replace('{!Time_Card__c.'+strFieldAPIName+'}','');
        }
        return strQuery;
    }
    /* End */
    
    /**
        @MethodName : replaceMergeFieldsWithValues
        @Param      : String containing merge fields, event object and map of Activity owner records.
        @Description: This method is used to replace the merge fields with their values stored in event object.
    **/
    public static String replaceMergeFieldsWithValues(String mergeFieldString, Time_Card__c objTimeCard)
    {
        //Replacing all merge fields with the values
        while(mergeFieldString.indexOf('{!Time_Card__c.') != -1)
        {
            String strFieldAPIName = String.valueOf(mergeFieldString.subStringBetween('{!Time_Card__c.', '}')).trim();
            if(mapFieldAPIToType.containskey(strFieldAPIName) && mapFieldAPIToType.get(strFieldAPIName) == 'DATE')
            {
                Date dtTimeCardDate = Date.valueOf(objTimeCard.get(strFieldAPIName));
                mergeFieldString = mergeFieldString.replace('{!Time_Card__c.'+strFieldAPIName+'}', 
                                    String.join(new List<Integer>{dtTimeCardDate.month(),dtTimeCardDate.day(),dtTimeCardDate.year()},'/'));
                
            }
            else if(mapFieldAPIToType.containskey(strFieldAPIName) && mapFieldAPIToType.get(strFieldAPIName) == 'REFERENCE')
            {
                String strTempFieldAPI = (strFieldAPIName != 'OwnerId') ? strFieldAPIName.replace('__c', '__r') : 'Owner';
                String strValue = objTimeCard.getSobject(strTempFieldAPI) != null ? (String)objTimeCard.getSobject(strTempFieldAPI).get('Name') : '';
                mergeFieldString = mergeFieldString.replace('{!Time_Card__c.'+strFieldAPIName+'}', strValue);
            }
            else if(strFieldAPIName == 'Id')
            {
                mergeFieldString = mergeFieldString.replace('{!Time_Card__c.'+strFieldAPIName+'}', strBaseURL+'/'+objTimeCard.get(strFieldAPIName));
            }
            else
            {
                mergeFieldString = mergeFieldString.replace('{!Time_Card__c.'+strFieldAPIName+'}', 
                                    String.valueOf(objTimeCard.get(strFieldAPIName) != null ? objTimeCard.get(strFieldAPIName) : null));
            }
        }
        return mergeFieldString;
    }
}