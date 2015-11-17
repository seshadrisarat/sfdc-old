global with sharing class SL_MeetingNoteMainHandler extends ngForceController {

    //needed in case no record types exist
    public Boolean hasRecordTypes = true;
    public String defaultRecordType {get;set;}
    public String currencyIso {get;set;}
    //public String dateFormat {get;set;} 
    public String locale {get;set;}
    public Integer timezoneOffset {get;set;}
    
    public String activityRecordType {get;set;}
    public String activityRecordTypeId {get;set;}
    public String parentId {get;set;}

    public Boolean isActivityAvailable {get;set;}    

    public Boolean queryAllRows {get; private set;}

    public String strJoinerJSON {get;set;}
    public String detailSectionFields {get;set;}

    public String activityCreateableUpdateableSOQL {get;set;} 

    public String userRecordAccessDetails {get;set;}
    public String activeUsers {get;set;}
    public Schema.sObjectType currentObjectType {get;set;}

    public String personAccount {get;set;}
    public Boolean hasPersonAccounts {get;set;}

    public String strRelabeledFields {get;set;}

    private static final set<String> CHATTER_USER_LICENSE = new set<String>{'CSN_User','CSN_External_User','PID_CHATTER'};

    public static Map<String, Object> mapPLToValue  = new  Map<String, Object>();

    global SL_MeetingNoteMainHandler(){ 

        //Get the default currency symbol
        currencyIso = getCurrencySymbolFromIso(UserInfo.getDefaultCurrency());
        timezoneOffset = UserInfo.getTimeZone().getOffset(DateTime.now());

        //Get the date format from custom setting or user locale
        //dateFormat = getDateFormat();
        locale = UserInfo.getLocale()
                         .replace('_EURO', '')
                         .replace('_PINYIN', '')
                         .replace('_STROKE','')
                         .replace('_', '-')
                         .toLowerCase();

        //Intializing variables on page load                 
        initialize();
    } 

    /*public class picklistValues {
        Boolean isDefaultValue        { get; set; }
        String label                  { get; set; }
        String value                  { get; set; }
    }*/  

    //Function to initialize the variables on load
    private void initialize(){

        String activityType; 
        String defaultMNPageLayoutName;
        isActivityAvailable = true;

        queryAllRows = SL_Meeting_Notes_Settings__c.getInstance().Closed_Activities_All_Rows__c;

        //Get the type of activity 
        if(ApexPages.currentPage().getUrl().contains('SL_MeetingNoteTask')) {

            activityType = 'Task';
            defaultMNPageLayoutName = 'Master_Task';

        } else if(ApexPages.currentPage().getUrl().contains('SL_MeetingNoteEvent')) {

            activityType = 'Event';
            defaultMNPageLayoutName = 'Master_Event';
        }

        //Get the current activity id
        if(ApexPages.currentPage().getParameters().containsKey('id'))
            parentId = (Id)ApexPages.currentPage().getParameters().get('id');

        defaultRecordType = getDefaultRecordType(activityType);
        //Get the current activity RecordType
        if(ApexPages.currentPage().getParameters().containsKey('RecordType'))
            activityRecordType = ApexPages.currentPage().getParameters().get('RecordType');    

        //If activity already exists(not new)
        if(parentId != null) {
            String queryString;
            
            String[] columns = new String[]{'Id', 'Subject', 'ParentId__c', 'Owner.Name'};
            
            if(hasRecordTypes) {
                columns.add('RecordTypeID');    
            }
            
            queryString = 'SELECT ' + String.join(columns, ',') + ' FROM ' + activityType + ' WHERE Id =: parentId';            
            
            if(queryAllRows) {
                queryString += ' ALL ROWS';
            }

            List<sObject> lstActivity = Database.query(queryString);

            if(lstActivity.size() > 0) {
                if(hasRecordTypes&&lstActivity[0].get('RecordTypeId') != null) {

                    activityRecordType = String.valueOf(lstActivity[0].get('RecordTypeId'));
                }

                if(lstActivity[0].get('ParentId__c') != null) {

                    parentId = String.valueOf(lstActivity[0].get('ParentId__c'));
                } 

            } else {

                //If query gives zero results
                isActivityAvailable = false;
            }
        }

        //Get the default record type id
        if(activityRecordType == null && parentId == null) { 
            activityRecordType = defaultRecordType;
        } 

        /*  Get the Developer name for the record type id
            
            RecordType Developer name can be retreived in query of task/event as well. But if any organization doesn't contain RecordType then query will result in error saying that RecordType field doesn't exist on task/event.
            This is reason we are opting for query to get the Developer Name.
        */
        if(activityRecordType != null) {

            //Store the recordtype id
            activityRecordTypeId = Id.valueOf(activityRecordType);

            String queryStr = 'Select Id, DeveloperName from RecordType where id=\''+activityRecordType+'\'';
            List<RecordType> lstRecordType = Database.query(queryStr);

            if(lstRecordType.size()>0)
                activityRecordType = lstRecordType[0].DeveloperName;
            else
                activityRecordType = '';
        }        

        //Get the current user profile name
        List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];

        //Form a querycondition for retrieving appropriate results from MN_Joiner__c
        String queryCondition = 'MN_Page_Layout__r.Profile__c = \'' + lstProfile[0].Name + '\' AND MN_Page_Layout__r.Activity_Type__c = \'' + activityType+ '\'';

        if(activityRecordType != null && activityRecordType != '') {

            queryCondition = queryCondition + ' AND MN_Page_Layout__r.RecordType__c = \'' + activityRecordType + '\'';
        }

        //Query to get the records of MN_RelatedList and MN_PageLayout and MN_Joiner
        String queryStrJoiner= 'Select MN_Page_Layout__r.Name,MN_Page_Layout__r.Activity_Type__c,MN_Page_Layout__r.FieldSetName__c, MN_Page_Layout__r.RecordType__c, MN_Page_Layout__r.Profile__c, MN_Page_Layout__r.Email_Prefill__c, MN_Page_Layout__r.SendEmail_SOSL__c, MN_Page_Layout__r.Send_Email__c, MN_Page_Layout__r.Email_Template__c, MN_Related_List__r.DisplayName__c, MN_Related_List__r.FieldSetName__c, MN_Related_List__r.ObjectName__c, MN_Related_List__r.RecordType__c, MN_Related_List__r.Record_Types_To_Be_Excluded__c, MN_Related_List__r.SearchResultsCSV__c, MN_Related_List__r.Rollup_API_Name__c, MN_Related_List__r.Order__c, MN_Related_List__r.Default_Sort__c From MN_Joiner__c where (' + queryCondition + ') OR (MN_Page_Layout__r.Name = \'' + defaultMNPageLayoutName + '\')';

        strJoinerJSON = JSON.Serialize(Database.query(queryStrJoiner));

        String fieldSetName;
        String defaultFieldsetName;
        List<MN_Related_List__c> lstRelatedList = new List<MN_Related_List__c>();

        //Get the appropriate fieldset name to display fields on detail section
        for(MN_Joiner__c obj:Database.query(queryStrJoiner)) {

            if ((activityRecordType != null && activityRecordType != '') && hasRecordTypes) {

                if (obj.MN_Page_Layout__r.Profile__c == lstProfile[0].Name && obj.MN_Page_Layout__r.RecordType__c == activityRecordType) {

                    fieldSetName = obj.MN_Page_Layout__r.FieldSetName__c;
                    lstRelatedList.add(obj.MN_Related_List__r);
                }

            } else {

                if (obj.MN_Page_Layout__r.Profile__c == lstProfile[0].Name) {

                    fieldSetName = obj.MN_Page_Layout__r.FieldSetName__c;
                    lstRelatedList.add(obj.MN_Related_List__r);                    
                }
            }

            if (obj.MN_Page_Layout__r.Name == defaultMNPageLayoutName) {

                defaultFieldsetName = obj.MN_Page_Layout__r.FieldSetName__c;
            }
        }

        if(lstRelatedList.isEmpty()) {

            fieldSetName = defaultFieldsetName;
        }

        //Describe the fieldset to get the detail section fields
        detailSectionFields = customDescribeFieldSet(activityType, fieldSetName, activityRecordTypeId);

        //Get the createable and updateable fields of activity
        activityCreateableUpdateableSOQL = getCreatableFieldsSOQL(activityType);

        //Get the user record access details
        String queryStrRecordAccess = 'Select HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess, HasTransferAccess, MaxAccessLevel, RecordId from UserRecordAccess where UserId =\''+UserInfo.getUserId()+'\' AND RecordId =:parentId';

        userRecordAccessDetails = JSON.Serialize(Database.query(queryStrRecordAccess));

        //Get the active user excluding chatter free users
        String qureyUsers = 'SELECT Id,Name  FROM User WHERE User.Profile.UserLicense.LicenseDefinitionKey NOT IN :CHATTER_USER_LICENSE AND IsActive = true';

        activeUsers = JSON.Serialize(Database.query(qureyUsers));

        //Get the object type of record from where page is launched
        String currentObjId;

        if(ApexPages.currentPage().getParameters().containsKey('what_id'))
            currentObjId = ApexPages.currentPage().getParameters().get('what_id');
        else if(ApexPages.currentPage().getParameters().containsKey('who_id'))
            currentObjId = ApexPages.currentPage().getParameters().get('who_id');
            
        if(currentObjId != null && (currentObjId.length() == 15 || currentObjId.length() == 18)) 
            currentObjectType = Id.valueOf(currentObjId).getSObjectType();

        /* 
            To support person accounts in meeting notes.
            Check to see if person accounts are enabled and check if current account is person account
        */

        /* 
            Describe the Account object to get a map of all fields
            then check to see if the map contains the field 'isPersonAccount'
        */
        Account obj = new Account();
        hasPersonAccounts = Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );

        if(String.valueOf(currentObjectType) == 'Account') {
        
            if(hasPersonAccounts) {

                String queryStr = 'Select Id, Name, IsPersonAccount,PersonContactId from Account Where Id=\''+currentObjId+'\'';
                obj = Database.query(queryStr);
            }
        }  
        personAccount = JSON.serialize(obj);

        /*
            To get the renamed labels for Who, What, Account, AssignedTo relations
        */
        Map<String, Schema.SObjectField> fMap = Task.sObjectType.getDescribe().Fields.getMap();

        Map<String,String> fields = new Map<String,String>();

        Set<String> setRequiredFields = new Set<String>{'OwnerId', 'WhoId', 'WhatId', 'AccountId'};

        for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)

            Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
            Map<String, Object> field = new Map<String, Object>();

            if (fd.getType().name().toLowerCase() == 'reference' && setRequiredFields.contains(fd.getName())){

                fields.put(fd.getName(),fd.getLabel());
            }
        } 

        strRelabeledFields = JSON.serialize(fields);

    }

    @remoteAction
    global static String getEmail(String Name)
    {
        map<String,Object> result = new map<String,Object>();
        try 
        {           
            List<emailTemplate> et = [SELECT HtmlValue,Body,Subject FROM emailTemplate WHERE DeveloperName=:Name];
            if(et.size()==0)
            {
                result.put('error','No emailTemplate with developerName: '+Name+' found.');
            }
            else
            { 
                result.put('records',et);
            }
            return JSON.serialize(result);
        } 
        catch (Exception e) 
        {
            map<String,String> response = new map<String,String>();
            response.put('message',e.getMessage()+'. Error thrown at line number: '+e.getLineNumber()+' of SL_MeetingNoteMaingHandler.cls');
            response.put('errorCode','NOT_FOUND');
            return '['+JSON.serialize(response)+']';
        }
    } 
    
    @remoteAction
    global static String sendEmail(String userId, String subject, String body, List<String> tos, List<String> ccs, List<Id> lstContactAndUserIds, Boolean isLogActivity, Id whatId)
    {

        Messaging.SendEmailResult[] results = new List<Messaging.SendEmailResult>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        try 
        { 
            if(isLogActivity){

                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();

                for(Id objId : lstContactAndUserIds)
                {

                    message = new Messaging.SingleEmailMessage();   

                    if(String.valueOf(objId) != '') 
                        message.setTargetObjectId(objId);

                    if(String.valueOf(objId).subString(0,3) == '003') {
                        message.setSaveAsActivity(true);
                        if(String.valueOf(whatId) != '') message.setWhatId(whatId);
                    }
                    else {
                        message.setSaveAsActivity(false); 
                    }

                    if(ccs.size() > 0) message.setCCAddresses(ccs);

                    message.setHtmlBody(body); 
                    message.setSubject(subject);
                    messages.add(message); 
                }

                results = Messaging.sendEmail(messages);

            }
            else{

                message.setToAddresses(tos);

                if(ccs.size() > 0) message.setCCAddresses(ccs);

                if(userId.length() > 0) message.setTargetObjectId(userID);

                message.setHtmlBody(body); 
                message.setSubject(subject);
                //message.setBccSender(true);
                message.setSaveAsActivity(false);

                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
                messages.add(message);

                results = Messaging.sendEmail(messages);    
            }
            
            if (results[0].isSuccess()) {
                return '{ \"success\": true, \"message\": \"The email was sent successfully.\" }';
            } else {
                return '{ \"success\": false, \"message\": \"' + results[0].getErrors()[0].getMessage() + '"\" }';
            }

        } 
        catch (Exception e) 
        {
            map<String,String> response = new map<String,String>();
            response.put('message',e.getMessage()+'. Error thrown at line number: '+e.getLineNumber()+' of SL_MeetingNoteMaingHandler.cls');
            response.put('errorCode','NOT_FOUND');
            return '['+JSON.serialize(response)+']';
        } 
    }
    
    //overriden method from ngForce to account for known issues with salesforce datetime serializations and timezones. Also returns field set info!
    /*class recordsAndFS{
        public map<String,Schema.FieldSetMember> mapfsm = new map<String,Schema.FieldSetMember>();
        public List<sObject> records = new List<sObject>();

        public void setRecords(List<sObject> sos){
            for(sObject so:sos)
            {
                for(String fieldName: mapfsm.keySet())
                {
                    if(mapfsm.get(fieldName).type==Schema.DisplayType.datetime)
                    {
                        Datetime dt = (datetime)so.get(fieldName);
                        so.put(fieldName,DateTime.newInstance(dt.Date(), dt.Time()));
                    }
                }
                records.add(so);
            }
        }
    }
    class sObjectWrapper{
        sObject record;

    }
    @remoteAction
    public static String mnQuery(String objtype, String fieldSetName, String whereClause) {
        recordsAndFS result = new recordsAndFS();
        
        //do the field set part
        Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, Schema.FieldSet> fsMap = dr.fieldSets.getMap();
        List<Schema.FieldSetMember> fsMembers = FsMap.get(FieldSetName).getFields();

        if(!FsMap.get(FieldSetName).getFields().isEmpty()) {
            for(Schema.FieldSetMember fsm: fsMembers)
            {
                result.mapfsm.put(fsm.getFieldPath(),fsm);
            }

        } else { 

            return '[{"message":"There is no fields present in provided fieldset. Please add some fields","errorCode":"NO_FIELDS_EXIST"}]';
        }
        //construct and run query
        String selectClause = 'SELECT Id';

        for(Schema.FieldSetMember f : fsMembers) 
        {
            selectClause += ', '+ f.getFieldPath();
        }
        String fromClause = ' FROM ' + objtype + ' WHERE '+ whereClause; 
        String query = selectClause + fromClause;
        system.debug(query);

        try {
            result.setRecords(Database.query(query));

        } 
        catch (QueryException qe) 
        {
            return '[{"message":"'+qe.getMessage()+'",line: "'+qe.getLineNumber()+'"errorCode":"INVALID_QUERY"}]';
        }
        system.debug(result);
        return JSON.serialize(result);
    }*/

    /*@RemoteAction 
    public static String uploadAttachment(String parentId, String attachmentBody, String attachmentName, String ownerId, String attachmentId) {

        Map<String, Object> result = new Map<String, Object>();

        try{
            if(parentId != null) {
                if(attachmentBody != null) {
                    Attachment objAttachment = getAttachment(attachmentId);
                
                    objAttachment.ownerId = ownerId;
                    
                    String newBody = '';
                    if(objAttachment.Body != null) {
                        newBody = EncodingUtil.base64Encode(objAttachment.Body);
                    }
                    newBody += attachmentBody;
        
                    objAttachment.Body = EncodingUtil.base64Decode(newBody);
        
                    if(attachmentId == null || attachmentId == '') {
                        objAttachment.Name = attachmentName;
                        objAttachment.parentId = parentId;
                    }
                    
                    Upsert objAttachment;    
                    
                    result.put('success', 'true');
                    result.put('Id', objAttachment.Id);
                } else {
                    result.put('error', 'Attachment Body was null');
                }
            } else {
                result.put('error', 'parentId could not be found');
            }
            
            return JSON.serialize(result);    
        }
        catch(Exception e){
            map<String,String> response = new map<String,String>();
            response.put('message',e.getMessage()+'. Error thrown at line number: '+e.getLineNumber()+' of SL_MeetingNoteMaingHandler.cls');
            response.put('errorCode','NOT_FOUND');
            return '['+JSON.serialize(response)+']';
        }
    }
         
    private static Attachment getAttachment(String attId) {
        List<Attachment> lstAttachments = [SELECT Id, Body
                                           FROM Attachment 
                                           WHERE Id =: attId];
        if(lstAttachments.isEmpty()) {
            Attachment objAttachment = new Attachment();
            return objAttachment;
        } else {
            return lstAttachments[0];
        }
    }*/

    /*@remoteAction
    public static String getPicklistValuesCustom(String objtype, String fieldName) {
        Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
        List<Schema.PicklistEntry> pickListValues = field_map.get(fieldName).getDescribe().getPickListValues();
        List<pickListValues> options = new List<picklistValues>();
        for(Schema.PicklistEntry plv : pickListValues){
            pickListValues pv = new pickListValues();

            pv.isDefaultValue = plv.isDefaultValue();
            pv.label = plv.getLabel();
            pv.value = plv.getValue();
            options.add(pv);
        }
        return JSON.serialize(options); 
    }*/

    @remoteAction
    global static String getExistingRecords(String dynamicSoql, String createSobject, String recordTypesTobeIncluded, String recordTypesTobeExcluded, String queryFields, String searchSobject, Boolean hasPersonAccounts, String defaultOrderByField) {

        List<sObject> records;
        Map<String,sObject> map_ActivityId_SobjectId = new Map<String,sObject>();
        List<String> lstSobjectIds = new List<String>();
        List<String> lstRecordTypes = new List<String>();
        
        String queryString='';
        List<sObject> lstExistingRecords = new List<sObject>();

        List<ActivitySobjectInnerClass> lstInnerClass = new List<ActivitySobjectInnerClass>();

        try {
            //Qurey the dynamic soql passed as parameter, which will give all the activities related to parent activity
            records = Database.query(dynamicSoql);

            //If createSobject is EventRelation or TaskRelation then collect the RelationId and activity id
            if(createSobject == 'EventRelation' || createSobject == 'TaskRelation') {
                
                for(sObject obj:records){

                    map_ActivityId_SobjectId.put(String.valueOf(obj.get('RelationId')),obj);
                    lstSobjectIds.add(String.valueOf(obj.get('RelationId')));
                }    

            } else if(createSobject == 'Event' || createSobject == 'Task') { 
            //If createSobject is Event or Task then collect the WhatId and activity id

                for(sObject obj:records){

                    map_ActivityId_SobjectId.put(String.valueOf(obj.get('WhatId')),obj);
                    lstSobjectIds.add(String.valueOf(obj.get('WhatId'))); 
                }
            }
            
            //Form a query string to get the details of RelationId's or WhatId's based on condition
            if(map_ActivityId_SobjectId.size() > 0 && ((recordTypesTobeIncluded != '' && recordTypesTobeIncluded != null) || (recordTypesTobeExcluded != '' && recordTypesTobeExcluded != null))) {

                if(recordTypesTobeIncluded != '' && recordTypesTobeIncluded != null) {
                    
                    lstRecordTypes = recordTypesTobeIncluded.split(',');

                    queryString = 'Select '+queryFields+' From '+searchSobject+' where Id IN: lstSobjectIds AND RecordType.DeveloperName IN: lstRecordTypes';

                } else if(recordTypesTobeExcluded != '' && recordTypesTobeExcluded != null) {

                    lstRecordTypes = recordTypesTobeExcluded.split(',');

                    queryString = 'Select '+queryFields+' From '+searchSobject+' where Id IN: lstSobjectIds AND RecordType.DeveloperName NOT IN: lstRecordTypes';
                }
            
            } else if(map_ActivityId_SobjectId.size() > 0) {
                
                queryString = 'Select '+queryFields+' From '+searchSobject+' where Id IN: lstSobjectIds';
            }

            //To avoid listing person account related contacts in related list
            if(searchSobject == 'Contact' && hasPersonAccounts == true && queryString.length() > 0) {

                queryString = queryString + ' AND IsPersonAccount = false ORDER BY '+defaultOrderByField;

            } else if(queryString.length() > 0) {

                queryString = queryString + ' ORDER BY '+defaultOrderByField;
            }

            if(queryString.length() > 0) { 

                lstExistingRecords = Database.query(queryString);
                
                /* 
                    Iterate over the list of results and form required output
                    Used inner class to combine the results of Relation/whatid records and ActivityId
                */
                for(sObject obj:lstExistingRecords) {

                    ActivitySobjectInnerClass objInnerClass = new ActivitySobjectInnerClass(obj,map_ActivityId_SobjectId.get(String.valueOf(obj.get('Id'))));
                    lstInnerClass.add(objInnerClass);
                }
            }

        } catch (Exception e) {
            map<String,String> response = new map<String,String>();
            response.put('message',e.getMessage()+'. Error thrown at line number: '+e.getLineNumber()+' of SL_MeetingNoteMaingHandler.cls');
            response.put('errorCode','NOT_FOUND');
            return '['+JSON.serialize(response)+']'; 
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('records', lstInnerClass);
        
        return JSON.serialize(result);
    }

    public class ActivitySobjectInnerClass {

        public sObject objSobject;
        public sObject activity;
  
        public ActivitySobjectInnerClass(sObject objSobject1,sObject activity1) {
            
            objSobject=objSobject1;
            activity=activity1;
        } 
    }

    private String getDefaultRecordType(String objtype) {

        Map<String, Schema.SObjectType> mapSchema = Schema.getGlobalDescribe();
        Schema.SObjectType stdObject = mapSchema.get(objtype);
        Schema.DescribeSObjectResult sObjectResult = stdObject.getDescribe();

        List<Schema.RecordTypeInfo> infos = sObjectResult.getRecordTypeInfos();
        Id defaultRecordTypeId;

        //check each one
        for (Schema.RecordTypeInfo info : infos) {
          if (info.DefaultRecordTypeMapping) {
            defaultRecordTypeId = info.RecordTypeId;
          }
        }
        
        if(defaultRecordTypeId == '012000000000000AAA')
        {
            hasRecordTypes = false;
        }
        system.debug(defaultRecordTypeId);
        system.debug(hasRecordTypes);
        return defaultRecordTypeId;
    }

    public String getCreatableFieldsSOQL(String objectName) {

        Schema.SObjectType oType = (objectName == 'Event')? Event.sObjectType: Task.sObjectType;
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = oType.getDescribe().Fields.getMap();

        Map<String, Boolean> mapFieldToEditable = new Map<String, Boolean>();
         
        if (fMap != null){

            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)

                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                
                if (fd.isCreateable() && !fd.isUnique() && fd.isUpdateable()) // field is creatable
                    mapFieldToEditable.put(fd.getName(), true);
                else
                    mapFieldToEditable.put(fd.getName(), false);
            }
        }
        return JSON.serialize(mapFieldToEditable);
    } 

    /*Functions to get the user currency symbol*/
    //public static String getCurrencyIsoCode(){
    //    String currencyIso = UserInfo.getDefaultCurrency();
    //    return currencyIso;
    //}

    //Function to map the currency Iso code and it's symbol
    public static String getCurrencySymbolFromIso(String Iso) {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? 'Ã¢â€šÂ¬' : 
           ('GBP' == Iso ? 'Ã‚Â£' : 
           ('JPY' == Iso ? 'Ã‚Â¥' : 
           ('KRW' == Iso ? 'Ã¢â€šÂ©' : 
           ('CNY' == Iso ? 'Ã¥â€¦Æ’' : 
           Iso)))))));

           return currencySymbol;
    }


    //public static String getCurrencySymbol() {

    //    String currencySymbol = getCurrencySymbolFromIso(getCurrencyIsoCode());

    //    Map<String, String> result = new Map<String, String>();
    //    result.put('currencySymbol', currencySymbol);
        
    //    return JSON.serialize(result);
    //}

    //populate a map with locale values and corresponding datetime formats
    //private static Map<String, String> MapValues() {
    //    Map<String, String> locale_map = new Map<String, String>{'ar' => 'dd/MM/yyyy', 
    //                                                            'ar_AE' => 'dd/MM/yyyy', 
    //                                                            'ar_BH' => 'dd/MM/yyyy', 
    //                                                            'ar_EG' => 'dd/MM/yyyy', 
    //                                                            'ar_JO' => 'dd/MM/yyyy', 
    //                                                            'ar_KW' => 'dd/MM/yyyy', 
    //                                                            'ar_LB' => 'dd/MM/yyyy', 
    //                                                            'ar_SA' => 'dd/MM/yyyy', 
    //                                                            'bg' => 'yyyy-M-d', 
    //                                                            'bg_BG' => 'yyyy-M-d', 
    //                                                            'ca' => 'dd/MM/yyyy', 
    //                                                            'ca_ES' => 'dd/MM/yyyy', 
    //                                                            'ca_ES_EURO' => 'dd/MM/yyyy', 
    //                                                            'cs' => 'd.M.yyyy', 
    //                                                            'cs_CZ' => 'd.M.yyyy', 
    //                                                            'da' => 'dd-MM-yyyy', 
    //                                                            'da_DK' => 'dd-MM-yyyy', 
    //                                                            'de' => 'dd.MM.yyyy', 
    //                                                            'de_AT' => 'dd.MM.yyyy', 
    //                                                            'de_AT_EURO' => 'dd.MM.yyyy', 
    //                                                            'de_CH' => 'dd.MM.yyyy', 
    //                                                            'de_DE' => 'dd.MM.yyyy', 
    //                                                            'de_DE_EURO' => 'dd.MM.yyyy', 
    //                                                            'de_LU' => 'dd.MM.yyyy', 
    //                                                            'el' => 'd/M/yyyy', 
    //                                                            'el_GR' => 'd/M/yyyy', 
    //                                                            'en_AU' => 'd/MM/yyyy', 
    //                                                            'en_BB' => 'M/d/yyyy', 
    //                                                            'en_BM' => 'M/d/yyyy', 
    //                                                            'en_CA' => 'dd/MM/yyyy', 
    //                                                            'en_GB' => 'dd/MM/yyyy', 
    //                                                            'en_GH' => 'M/d/yyyy', 
    //                                                            'en_ID' => 'M/d/yyyy', 
    //                                                            'en_IE' => 'dd/MM/yyyy', 
    //                                                            'en_IN' => 'd/M/yyyy', 
    //                                                            'en_MY' => 'd/M/yyyy', 
    //                                                            'en_NG' => 'm/D/yyyy', 
    //                                                            'en_NZ' => 'd/MM/yyyy', 
    //                                                            'en_PH' => 'm/d/yyyy', 
    //                                                            'en_SG' => 'M/d/yyyy', 
    //                                                            'en_US' => 'M/d/yyyy', 
    //                                                            'en_ZA' => 'yyyy/MM/dd', 
    //                                                            'es' => 'd/MM/yyyy', 
    //                                                            'es_AR' => 'dd/MM/yyyy', 
    //                                                            'es_BO' => 'dd-MM-yyyy', 
    //                                                            'es_CL' => 'dd-MM-yyyy', 
    //                                                            'es_CO' => 'd/MM/yyyy', 
    //                                                            'es_CR' => 'dd/MM/yyyy', 
    //                                                            'es_DO' => 'MM/dd/yyyy', 
    //                                                            'es_EC' => 'dd/MM/yyyy', 
    //                                                            'es_ES' => 'd/MM/yyyy', 
    //                                                            'es_GT' => 'd/MM/yyyy', 
    //                                                            'es_HN' => 'MM-dd-yyyy', 
    //                                                            'es_MX' => 'd/MM/yyyy', 
    //                                                            'es_PA' => 'mm/dd/yyyy', 
    //                                                            'es_PE' => 'dd/MM/yyyy', 
    //                                                            'es_PR' => 'MM-dd-yyyy', 
    //                                                            'es_PY' => 'dd/MM/yyyy', 
    //                                                            'es_SVUS' => 'MM-dd-yyyy', 
    //                                                            'es_UY' => 'dd/MM/yyyy', 
    //                                                            'es_VE' => 'dd/MM/yyyy', 
    //                                                            'et_EE' => 'd.MM.yyyy', 
    //                                                            'fi' => 'd.M.yyyy', 
    //                                                            'fi_FI' => 'd.M.yyyy', 
    //                                                            'fr' => 'dd/MM/yyyy', 
    //                                                            'fr_BE' => 'd/MM/yyyy', 
    //                                                            'fr_CA' => 'yyyy-MM-dd', 
    //                                                            'fr_CH' => 'dd.MM.yyyy', 
    //                                                            'fr_FR' => 'dd/MM/yyyy', 
    //                                                            'fr_LU' => 'dd/MM/yyyy', 
    //                                                            'fr_MC' => 'dd/MM/yyyy', 
    //                                                            'ga_IE' => 'dd/MM/yyyy', 
    //                                                            'hr_HR' => 'yyyy.MM.dd', 
    //                                                            'hu' => 'yyyy.MM.dd.', 
    //                                                            'hu_HU' => 'yyyy.MM.dd.', 
    //                                                            'hy_AM' => 'M/d/yyyy', 
    //                                                            'in' => 'yyyy/mm/dd', 
    //                                                            'in_ID' => 'dd/mm/yyyy', 
    //                                                            'is_IS' => 'd.M.yyyy', 
    //                                                            'it' => 'dd/MM/yyyy', 
    //                                                            'it_CH' => 'dd.MM.yyyy', 
    //                                                            'it_IT' => 'dd/MM/yyyy', 
    //                                                            'iw' => 'dd/MM/yyyy', 
    //                                                            'iw_IL' => 'dd/MM/yyyy', 
    //                                                            'ja' => 'yyyy/MM/dd', 
    //                                                            'ja_JP' => 'yyyy/MM/dd', 
    //                                                            'ka' => 'm/d/yyyy', 
    //                                                            'ka_GE' => 'm/d/yyyy', 
    //                                                            'kk_KZ' => 'M/d/yyyy', 
    //                                                            'km_KH' => 'M/d/yyyy', 
    //                                                            'ko' => 'yyyy. M. d', 
    //                                                            'ko_KR' => 'yyyy. M. d', 
    //                                                            'lt_LT' => 'yyyy.M.d', 
    //                                                            'lv_LV' => 'yyyy.d.M', 
    //                                                            'ms_MY' => 'dd/MM/yyyy', 
    //                                                            'nl' => 'd-M-yyyy', 
    //                                                            'nl_BE' => 'd/MM/yyyy', 
    //                                                            'nl_NL' => 'd-M-yyyy', 
    //                                                            'nl_SR' => 'd-M-yyyy', 
    //                                                            'no' => 'dd.MM.yyyy', 
    //                                                            'no_NO' => 'dd.MM.yyyy', 
    //                                                            'pl' => 'yyyy-MM-dd', 
    //                                                            'pt' => 'dd-MM-yyyy', 
    //                                                            'pt_AO' => 'dd-MM-yyyy', 
    //                                                            'pt_BR' => 'dd/MM/yyyy', 
    //                                                            'pt_PT' => 'dd-MM-yyyy', 
    //                                                            'ro' => 'dd.MM.yyyy', 
    //                                                            'ro_RO' => 'dd.MM.yyyy', 
    //                                                            'ru' => 'dd.MM.yyyy', 
    //                                                            'ru_RU' => 'dd.MM.yyyy', 
    //                                                            'sh' => 'dd.MM.yyyy', 
    //                                                            'sh_BA' => 'dd.MM.yyyy', 
    //                                                            'sh_CS' => 'dd.MM.yyyy', 
    //                                                            'sk' => 'd.M.yyyy', 
    //                                                            'sl_SI' => 'd.M.yy', 
    //                                                            'sr' => 'd.M.yyyy', 
    //                                                            'sr_BA' => 'yyyy-MM-DD', 
    //                                                            'sr_CS' => 'D.m.yyyy', 
    //                                                            'sk_SK' => 'd.M.yyyy', 
    //                                                            'sl_SI' => 'd.M.y', 
    //                                                            'sv' => 'yyyy-MM-dd', 
    //                                                            'sv_SE' => 'yyyy-MM-dd', 
    //                                                            'th' => 'M/d/yyyy', 
    //                                                            'th_TH' => 'd/M/yyyy', 
    //                                                            'tr' => 'dd.MM.yyyy', 
    //                                                            'tr_TR' => 'dd.MM.yyyy', 
    //                                                            'uk' => 'dd.MM.yyyy', 
    //                                                            'uk_UA' => 'dd.MM.yyyy', 
    //                                                            'ur_PK' => 'd/M/yyyy', 
    //                                                            'ur_PK' => 'd/M/yyyy', 
    //                                                            'ur_PK' => 'M/d/yyyy', 
    //                                                            'vi' => 'dd/MM/yyyy', 
    //                                                            'vi_VN' => 'dd/MM/yyyy', 
    //                                                            'zh' => 'yyyy-M-d', 
    //                                                            'zh_CN' => 'yyyy-M-d', 
    //                                                            'zh_HK' => 'yyyy-M-d', 
    //                                                            'zh_TW' => 'yyyy/M/d'}; //holds the locale to timedate formats
        //return locale_map; //return the map
    //}

    /*
    Function to get the date format from custom setting 
    If custom setting doesn't have any date format then get the user locale.
    */
    //public static String getDateFormat() {

    //    String dateFormat;
    //    Date_Format__c csDateFormat = Date_Format__c.getInstance();
        
    //    if(csDateFormat.Format__c != null) {

    //        dateFormat = csDateFormat.Format__c;

    //    } else {

    //        dateFormat = MapValues().containsKey(UserInfo.getLocale()) ? MapValues().get(UserInfo.getLocale())  : 'dd/MM/yyyy' ;
    //    }
        
    //    return dateFormat;
    //}

    @remoteAction
    global static String customDescribeFieldSet(String objtype, String fieldSetName, String activityRecordTypeId) {

        try{

            Map<String, Object> result = new Map<String, Object>();
            Map<String,Integer> mapFieldToScale = new Map<String,Integer>();
            List<FieldSetMember> fieldSetFields = new List<FieldSetMember>();

            //Listing down all the fields, whose values doesn't change based on record type and will be same for all
            set<String> setFieldPathWithoutRecordType = new set<String>{'ShowAs','GroupEventType','CallType','RecurrenceType','RecurrenceTimeZoneSidKey','RecurrenceMonthOfYear','RecurrenceInstance'};
            
            Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Map<String, Schema.FieldSet> FsMap = dr.fieldSets.getMap();

            Schema.DescribeFieldResult dfr;

            if(objtype == 'Task' || objtype == 'Event'){ 

                Map<String, String> mapFieldToHelpText = new Map<String, String>(); 

                String strPicklistFieldNameToGetValues = '';

                if(!FsMap.get(fieldSetName).getFields().isEmpty()) {

                    for(FieldSetMember objFieldSetMember:FsMap.get(fieldSetName).getFields()) {

                        if(!String.valueOf(objFieldSetMember.getFieldPath()).contains('.'))
                            dfr = dr.fields.getMap().get(objFieldSetMember.getFieldPath()).getDescribe();
                        else
                            fieldSetFields.add(objFieldSetMember);

                        if(String.valueOf(objFieldSetMember.getFieldPath()) != 'RecurrenceRegeneratedType' && !objFieldSetMember.getFieldPath().contains('.')){

                            if( String.valueOf(objFieldSetMember.getType()) == 'percent' || 
                                String.valueOf(objFieldSetMember.getType()) == 'currency'|| 
                                String.valueOf(objFieldSetMember.getType()) == 'double') {

                                mapFieldToScale.put(objFieldSetMember.getFieldPath(),dfr.getScale());
                            }

                            fieldSetFields.add(objFieldSetMember);
                            mapFieldToHelpText.put(objFieldSetMember.getFieldPath(), dfr.getInlineHelpText());
                        }

                    }                                   

                    result.put('mapFieldToHelpText', mapFieldToHelpText);

                } else {

                    return '[{"message":"There is no fields present in provided fieldset. Please add some fields","errorCode":"NO_FIELDS_EXIST"}]';
                }
            }
            else{

                fieldSetFields = new List<FieldSetMember>();
                mapFieldToScale = new Map<String,Integer>();

                if(!FsMap.get(fieldSetName).getFields().isEmpty()) {

                    for(FieldSetMember objFieldSetMember : FsMap.get(fieldSetName).getFields()) {

                        if(!String.valueOf(objFieldSetMember.getFieldPath()).contains('.'))
                            dfr = dr.fields.getMap().get(objFieldSetMember.getFieldPath()).getDescribe();

                        if( String.valueOf(objFieldSetMember.getType()) == 'percent' || 
                            String.valueOf(objFieldSetMember.getType()) == 'currency'|| 
                            String.valueOf(objFieldSetMember.getType()) == 'double' ) {

                            mapFieldToScale.put(objFieldSetMember.getFieldPath(), dfr.getScale());
                        }   

                        fieldSetFields.add(objFieldSetMember); 
                    }

                }else{

                    return '[{"message":"There is no fields present in provided fieldset. Please add some fields","errorCode":"NO_FIELDS_EXIST"}]';

                }

            }

            result.put('fieldSetFields', fieldSetFields);
            result.put('fieldToScale', mapFieldToScale);
           
            return JSON.serialize(result); 

        }
        catch(Exception e){
            map<String,String> response = new map<String,String>();
            response.put('message',e.getMessage()+'. Error thrown at line number: '+e.getLineNumber()+' of SL_MeetingNoteMaingHandler.cls');
            response.put('errorCode','NOT_FOUND');
            return '['+JSON.serialize(response)+']';
        }
    }

    private static String makeError(String message, String errorCode) {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('message', message);
        gen.writeStringField('errorCode', errorCode);
        gen.writeEndObject();
        gen.writeEndArray();
        
        return gen.getAsString();
    }

    @remoteAction
    global static String insertWithDMLOption(String existingInvitees, String addedInvitees) {

        try{
            /* 
                Adding DMLOptions to insert
                This will allow us to send the emails to invitees
            */
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail  = true;
            dlo.EmailHeader.triggerOtherEmail  = true;
            dlo.EmailHeader.triggerAutoResponseEmail = false;

            /* 
                code to delete the existing invitees 
            */
            Type listType = Type.forName('List<EventRelation>');
            if (listType == null) {
                return makeError('The requested resource does not exist in bulkDelete', 'NOT_FOUND');
            }
     
            List<SObject> objsToDelete;
            try {
                objsToDelete = (List<SObject>)JSON.deserialize(existingInvitees, listType);
            } catch (JSONException je) {
                return makeError('Unable to deserialize the JSON data array', 'INVALID_JSON');
            }
     
            try {
                delete objsToDelete;
            } catch (DMLException dmle) {
                return '[{"data":' + existingInvitees + 
                        ',"message":"'+dmle.getDmlMessage(0)+
                        '","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
            }
            
            /* 
                code to insert the added invitees 
            */
            List<SObject> objsToInsert;
            try {
                objsToInsert = (List<SObject>)JSON.deserialize(addedInvitees, listType);
            } catch (JSONException je) {
                return makeError('Unable to deserialize the JSON data array', 'INVALID_JSON');
            }        

            try {
                Database.insert(objsToInsert,dlo);
            } catch (DMLException dmle) {
                return '[{"data":' + addedInvitees + 
                        ',"message":"'+dmle.getDmlMessage(0)+
                        '","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
            }
     
            List<Id> rids = new List<Id>();
            for(sObject o : objsToInsert) {
                rids.add(o.Id);
            }
     
            Map<String, Object> result = new Map<String, Object>();
            result.put('id', objsToInsert);
            result.put('errors', new List<String>());
            result.put('success', true);
             
            return JSON.serialize(result);    
        }
        catch(Exception e){
            map<String,String> response = new map<String,String>();
            response.put('message',e.getMessage()+'. Error thrown at line number: '+e.getLineNumber()+' of SL_MeetingNoteMaingHandler.cls');
            response.put('errorCode','NOT_FOUND');
            return '['+JSON.serialize(response)+']';
        }
        
    }

    @remoteAction
    global static String describeSearchFields(String objtype, List<String> lstFieldName) {

        try{

            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);

            if (targetType == null) {
                return '[{"message":"The requested resource does not exist in describe","errorCode":"NOT_FOUND"}]';
            }
            
            Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
            
            Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
            
            List<Object> fields = new List<Object>();

            for (String key : lstFieldName) {

                if(key != null && key != '' && !key.contains('.')){
                    Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
                    Map<String, Object> field = new Map<String, Object>();
                    
                    field.put('type', descField.getType().name().toLowerCase());
                    field.put('name', descField.getName());
                    field.put('label', descField.getLabel());
                    if( descField.getType().name().toLowerCase() == 'percent'  || 
                        descField.getType().name().toLowerCase() == 'currency' ||
                        descField.getType().name().toLowerCase() == 'double' )
                    {
                        field.put('scale', descField.getScale());
                    }
                    
                    List<String> references = new List<String>();
                    
                    for (Schema.sObjectType t: descField.getReferenceTo()) {
                        references.add(t.getDescribe().getName());
                    }
                    
                    if (!references.isEmpty()) {
                        field.put('referenceTo', references);
                    }
                    
                    fields.add(field);    
                }
                
            }
            
            Map<String, Object> result = new Map<String, Object>();
            result.put('fields', fields);
            
            return JSON.serialize(result);

        }
        catch(Exception e){
            map<String,String> response = new map<String,String>();
            response.put('message',e.getMessage()+'. Error thrown at line number: '+e.getLineNumber()+' of SL_MeetingNoteMaingHandler.cls');
            response.put('errorCode','NOT_FOUND');
            return '['+JSON.serialize(response)+']';
        }
        
    }   

}