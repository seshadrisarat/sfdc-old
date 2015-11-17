/**
*ClassName   : SL_MeetingNotesRelatedListController
*JIRATicket  : LIB-155
*CreatedOn   : 14/Apr/2014
*CreatedBy   : Praful
*ModifiedBy  : Praful
*Description : Controller class for the SL_ActivityRelatedList 
**/
global with sharing class SL_MeetingNotesRelatedListController 
{ 

    public String currencyIso {get;set;}
    public String locale {get;set;}
    public String timeFormat {get;set;}
    public Integer timezoneOffset {get;set;}

    public String mnUserOptions {get;set;}

    public String taskTypes {get;set;}
    public String eventTypes {get;set;}

    public String taskFields {get;set;}
    public String eventFields {get;set;}

    public String picklistValues {get;set;}

    public String queryStrOpenTask {get;set;}
    public String queryStrClosedTask {get;set;}
    public String queryStrOpenEvent {get;set;}
    public String queryStrClosedEvent {get;set;}

    public Boolean showFilters {get;set;}

    public String strRelabeledFields {get;set;}
    public String isPersonAccount {get;set;}
    public Boolean queryAllRows {get;set;}

    public String currentRecord {get;set;}

    /*
     * Modified Version of RemoteTKController
     */
    global SL_MeetingNotesRelatedListController()
    {
        //Get the default currency symbol
        currencyIso = getCurrencySymbolFromIso(UserInfo.getDefaultCurrency());
        timezoneOffset = UserInfo.getTimeZone().getOffset(DateTime.now());
        //Get the date format from custom setting or user locale
        locale = getDateFormat();
        timeFormat = getTimeFormat();

        //Intializing variables on page load                 
        initialize();
    }
        
    global class picklistValues
    {
        String label {get; set;}
        String value {get; set;}
    }

    /*
    global class Select2Data 
    {
        String id               {get; set;}
        String name             {get; set;}
        String searchName       {get; set;}
    }
    */

    global class QueryString 
    {
        String selectClause {get; set;}
        String fromClause {get; set;}
    }

    //Function to initialize the variables on load
    private void initialize(){

        Schema.sObjectType sobjectType;
        Boolean hasPersonAccounts;

        //Get the values from UserOptions record to decide the fields to be displayed in grid
        String queryUserOptions = 'SELECT Id, Open_Activities__c, Closed_Activities__c, User__c FROM MN_UserOption__c Where User__c=\''+UserInfo.getUserId()+'\' LIMIT 1';
        List<MN_UserOption__c> lstMNUserOption = Database.query(queryUserOptions);
        
        if(lstMNUserOption.size()>0) {

            mnUserOptions = '{"openActivities":'+lstMNUserOption[0].Open_Activities__c+',"closedActivities":'+lstMNUserOption[0].Closed_Activities__c+',"Id":"'+lstMNUserOption[0].Id+'"}';
        } else {

            mnUserOptions = '{}';
        }
        queryAllRows = SL_MN_Related_List__c.getInstance().Closed_Activities_All_Rows__c;
        // Check if we should display type filters on Meeting Notes related list
        SL_TypeFilterOptions__c filterOptions = SL_TypeFilterOptions__c.getValues(UserInfo.getProfileId());
        System.debug('~~~~ filterOptions: ' + filterOptions);
        if(filterOptions == null){

            SL_TypeFilterOptions__c defaults = SL_TypeFilterOptions__c.getOrgDefaults();
            System.debug('~~~~ defaults: ' + defaults);
            if(defaults == null || defaults.Display__c == true)
                showFilters = true;
            else
                showFilters = false;

        } else{
            if(filterOptions.Display__c == true)
                showFilters = true;
            else
                showFilters = false;
        }

        
        
        System.debug('~~~~ showFilters: ' + showFilters);


        //Get picklist values of 'Type' field of task
        taskTypes = getPicklistValues('Task', 'Type');

        //Get picklist values of 'Type' field of event
        eventTypes = getPicklistValues('Event', 'Type');

        //Get the sobject type of record
        sobjectType = Id.valueOf(ApexPages.currentPage().getParameters().get('Id')).getSObjectType();

        //Get the additional record Id's from current record
        if(Schema.getGlobalDescribe().get(String.valueOf(sobjectType)).getDescribe().fields.getMap().containsKey('SL_Additional_Record_Ids__c')) {

            String queryStr = 'SELECT SL_Additional_Record_Ids__c FROM '+sobjectType+' WHERE Id =\''+ApexPages.currentPage().getParameters().get('id')+'\'';
            currentRecord = JSON.serialize(Database.query(queryStr));

        } else {

            currentRecord = '{}';
        }

        /*
            Describe the field set to get the list of fields, serialize the list and assign to taskFields which will be passed to angular app.
            and then iterate over the list and collect the fields in a comma separated manner in strTaskFields.
            Will be using strTaskFields to query task records. 
        */
        List<Schema.FieldSetMember> lstFieldSetMemberTask = describeFieldSet('Task', 'SL_ActivityRelatedListTaskFieldSet');        
        taskFields = JSON.Serialize(lstFieldSetMemberTask);

        Map<String,Set<String>> mapPicklist = new Map<String,Set<String>>();
        List<String> lstTaskFields = new List<String>();

        for(Schema.FieldSetMember obj:lstFieldSetMemberTask) {

            lstTaskFields.add(obj.fieldPath);

            if(String.valueOf(obj.Type) == 'picklist') {

                //Get the values of picklist field
                mapPicklist.put(obj.fieldPath,getPicklistValuesWithFieldName('Task',obj.fieldPath));
            }
        }

        String strTaskFields = String.join(lstTaskFields,',');

        if(!strTaskFields.contains('ParentId__c')) {

            strTaskFields = strTaskFields + ',ParentId__c';
        }

        if(!strTaskFields.contains('WhoId')) {

            strTaskFields = strTaskFields + ',WhoId';
        }
        
        /*
            Describe the field set to get the list of fields, serialize the list and assign to eventFields which will be passed to angular app.
            and then iterate over the list and collect the fields in a comma separated manner in strEventFields.
            Will be using strEventFields to query event records. 
        */
        List<Schema.FieldSetMember> lstFieldSetMemberEvent = describeFieldSet('Event', 'SL_ActivityRelatedListEventFieldSet');
        eventFields = JSON.Serialize(lstFieldSetMemberEvent);

        List<String> lstEventFields = new List<String>();

        for(Schema.FieldSetMember obj:lstFieldSetMemberEvent) {

            lstEventFields.add(obj.fieldPath);

            if(String.valueOf(obj.Type) == 'picklist') {

                //Get the values of picklist field
                if(mapPicklist.containsKey(obj.fieldPath)) {

                    Set<String> setStr = mapPicklist.get(obj.fieldPath);
                    setStr.addAll(getPicklistValuesWithFieldName('Event',obj.fieldPath));

                    mapPicklist.put(obj.fieldPath,setStr);

                } else {

                    mapPicklist.put(obj.fieldPath,getPicklistValuesWithFieldName('Event',obj.fieldPath));
                }                
            }
        }
        String strEventFields = String.join(lstEventFields,',');

        if(!strEventFields.contains('ParentId__c')) {

            strEventFields = strEventFields + ',ParentId__c';
        }

        if(!strEventFields.contains('WhoId')) {

            strEventFields = strEventFields + ',WhoId';
        }

        //assign the mapPicklist to get set variable to access in component
        picklistValues = JSON.serialize(mapPicklist);

        //Get the current datetime
        DateTime dt = datetime.Now();

        //If sobject type is contact or lead
        if(String.valueOf(sObjectType) == 'Contact' || String.valueOf(sObjectType) == 'Lead') {

            //Get the tasks which are open
            queryStrOpenTask = JSON.serialize('SELECT Id,'+strTaskFields+' FROM Task WHERE Id IN (SELECT taskId FROM taskWhoRelation WHERE RelationId =\''+ApexPages.currentPage().getParameters().get('id')+'\') AND isDeleted = false AND IsClosed=false');

            //Get the tasks which are closed
            queryStrClosedTask = 'SELECT Id,'+strTaskFields+' FROM Task WHERE Id IN (SELECT taskId FROM taskWhoRelation WHERE RelationId =\''+ApexPages.currentPage().getParameters().get('id')+'\') AND isDeleted = false AND IsClosed=true';
            if(queryAllRows) queryStrClosedTask += ' all rows';
            queryStrClosedTask = JSON.serialize(queryStrClosedTask);


            //Get the event which are open
            queryStrOpenEvent = JSON.serialize('SELECT Id,'+strEventFields+' FROM Event WHERE Id IN (SELECT eventId FROM eventWhoRelation WHERE RelationId = \''+ApexPages.currentPage().getParameters().get('id')+'\') AND isDeleted = false AND StartDateTime >: dt');

            //Get the event which are closed
            queryStrClosedEvent = 'SELECT Id,'+strEventFields+' FROM Event WHERE Id IN (SELECT eventId FROM eventWhoRelation WHERE RelationId = \''+ApexPages.currentPage().getParameters().get('id')+'\') AND isDeleted = false AND StartDateTime <: dt';
            if(queryAllRows) queryStrClosedEvent += ' all rows';
            queryStrClosedEvent = JSON.serialize(queryStrClosedEvent);

        } else { //If sobject type is any thing other than contact or lead

            String queryCondition = 'WhatId=\''+ApexPages.currentPage().getParameters().get('id')+'\'';

            if(String.valueOf(sObjectType) == 'Account') {

                queryCondition = '('+ queryCondition + ' OR AccountId=\''+ApexPages.currentPage().getParameters().get('id')+'\')';
            }
            
            //Get the tasks which are open
            queryStrOpenTask = JSON.serialize('SELECT Id,'+strTaskFields+' FROM Task WHERE '+queryCondition+' AND isDeleted = false AND IsClosed=false');

            //Get the tasks which are closed
            queryStrClosedTask = 'SELECT Id,'+strTaskFields+' FROM Task WHERE '+queryCondition+' AND isDeleted = false AND IsClosed=true';
            if(queryAllRows) queryStrClosedTask += ' all rows';
            queryStrClosedTask = JSON.serialize(queryStrClosedTask);

            //Get the event which are open
            queryStrOpenEvent = JSON.serialize('SELECT Id,'+strEventFields+' FROM Event WHERE '+queryCondition+' AND isDeleted = false AND StartDateTime >: dt');

            //Get the event which are closed
            queryStrClosedEvent = 'SELECT Id,'+strEventFields+' FROM Event WHERE '+queryCondition+' AND isDeleted = false AND StartDateTime <: dt';
            if(queryAllRows) queryStrClosedEvent += ' all rows';
            queryStrClosedEvent = JSON.serialize(queryStrClosedEvent);
        }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Task.sObjectType.getDescribe().Fields.getMap();

        List<Object> fields = new List<Object>();

        Set<String> setReLabeledFields = new Set<String>{'OwnerId', 'WhoId', 'WhatId'};

        for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)

            Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
            Map<String, Object> field = new Map<String, Object>();

            if (fd.getType().name().toLowerCase() == 'reference' && setReLabeledFields.contains(fd.getName())){
                field.put('name', fd.getName());
                field.put('label', fd.getLabel());

                fields.add(field);
            }
        } 

        strRelabeledFields = JSON.serialize(fields);

        /* 
            To support person accounts in meeting notes.
            Check to see if person accounts are enabled and check if current account is person account
        */

        /* 
            Describe the Account object to get a map of all fields
            then check to see if the map contains the field 'isPersonAccount'
        */
        Account obj = new Account();

        if(String.valueOf(sObjectType) == 'Account') {

            hasPersonAccounts = Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
        
            if(hasPersonAccounts) {

                String queryStr = 'Select Id, Name, IsPersonAccount from Account Where Id=\''+ApexPages.currentPage().getParameters().get('Id')+'\'';
                obj = Database.query(queryStr);
            }
        }
        isPersonAccount = JSON.serialize(obj);
    }
    
    private static String makeError(String message, String errorCode) 
    {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('message', message);
        gen.writeStringField('errorCode', errorCode);
        gen.writeEndObject();
        gen.writeEndArray();
        
        return gen.getAsString();
    }
    
    private static String writeFields(String objtype, SObject obj, String fields) 
    {
        Map<String, Object> fieldMap = null;
        try 
        {
            fieldMap = (Map<String, Object>)JSON.deserializeUntyped(fields);
            if(Test.isRunningTest())
                makeError('Test Message', 'TEST_ERROR');
        } 
        catch (Exception je) 
        {
            return makeError(je.getMessage(), 'JSON_PARSER_ERROR');
        }
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        
        try {
            for (String key : fieldMap.keySet()) 
            {
                if (targetFields.get(key) == null) 
                {
                    system.debug('[{"message":"Field '+key+' does not exist on object type '+objtype+'","errorCode":"INVALID_FIELD"}]');
                    return '[{"message":"Field '+key+' does not exist on object type '+objtype+'","errorCode":"INVALID_FIELD"}]';
                }
                
                Object value = fieldMap.get(key);
                Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
                
                if (value instanceof String && valueType != Schema.DisplayType.String) 
                {
                    // Coerce an incoming String to the correct type
                    String svalue = (String)value;
                    
                    if (valueType == Schema.DisplayType.Date) 
                    {
                        system.debug('doing ' + key + ' : ' + svalue);
                        obj.put(key, Date.valueOf(svalue));
                    }else if(valueType == Schema.DisplayType.DateTime) 
                    {
                        if(svalue.length()>0)
                        obj.put(key,DateTime.valueOf(svalue));
                        else obj.put(key,null);
                    }else if (valueType == Schema.DisplayType.Percent ||
                           valueType == Schema.DisplayType.Currency) 
                           {
                        obj.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Double) 
                    {
                        obj.put(key, svalue == '' ? null : Double.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Integer) 
                    {
                        obj.put(key, Integer.valueOf(svalue));
                    } else {
                        obj.put(key, svalue);
                    }
                } else {
                    // Just try putting the incoming value on the object
                    obj.put(key, value);
                }
            }
        } 
        catch (SObjectException soe) 
        {
            system.debug(soe.getMessage() + 'INVALID_FIELD');
            return makeError(soe.getMessage(), 'INVALID_FIELD');
        }
        
        return null;
    }
    
    /*@remoteAction
    global static String describeRecordType(String objtype) 
    {
        try{
            Boolean isRecordType;
            List<RecordType> lstRecordType = [SELECT SobjectType FROM RecordType WHERE SobjectType =:objtype AND isActive = true Limit 1];

            if(lstRecordType.size() > 0){
                isRecordType = true;
            }else{
                isRecordType = false;
            }

            Map<String, Object> result = new Map<String, Object>();

            result.put('isRecordType',isRecordType);
            result.put('errors', new List<String>());
            result.put('success', true);
            
            return JSON.serialize(result);
        }
        catch(Exception e){
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }

    }*/

    @remoteAction
    global static String describe(String objtype) 
    {
        // Just enough to make the sample app work!
        Schema.SObjectType targetType;
        try
        {
            targetType = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
            
            Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
            
            List<Object> fields = new List<Object>();
            for (String key : fieldMap.keySet()) 
            {
                Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
                Map<String, Object> field = new Map<String, Object>();
                
                field.put('type', descField.getType().name().toLowerCase());
                field.put('name', descField.getName());
                field.put('label', descField.getLabel());
                List<String> references = new List<String>();
                for (Schema.sObjectType t: descField.getReferenceTo()) 
                {
                    references.add(t.getDescribe().getName());
                }
                if (!references.isEmpty()) 
                {
                    field.put('referenceTo', references);
                }
                
                fields.add(field);
            }
            
            Map<String, Object> result = new Map<String, Object>();
            result.put('fields', fields);
            
            return JSON.serialize(result);
        }
        catch(Exception e)
        {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
    }

    @remoteAction
    global static List<Schema.FieldSetMember> describeFieldSet(String objtype, String fieldSetName) 
    {
        Schema.SObjectType token;
        try
        {
            token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Map<String, Schema.FieldSet> FsMap = dr.fieldSets.getMap();

            List<Schema.FieldSetMember> lstFieldSetMember = FsMap.get(FieldSetName).getFields();
            return lstFieldSetMember;
        }
        catch(Exception e)
        {
            return null;
        }
    }

    @remoteAction
    global static String describeField(String objtype, String fieldName) {
        try
        {
            Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Schema.DescribeFieldResult fieldDescribe=dr.fields.getMap().get(fieldName).getDescribe();
            return JSON.serialize(fieldDescribe);
        }
        catch(Exception e)
        {
            return '[{"message":"Inavalid input","errorCode":"INVALID_INPUT"}]';
        }
    }

    @remoteAction
    global static String soqlFromFieldSet(String objtype, String fieldSetName) {
        Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, Schema.FieldSet> FsMap = dr.fieldSets.getMap();
        String selectClause = 'SELECT Id';
        Set<Schema.FieldSetMember> querySet = new Set<Schema.FieldSetMember>();
        querySet.addAll(FsMap.get(FieldSetName).getFields());
        for(Schema.FieldSetMember f : querySet) {
            selectClause += ', '+ f.getFieldPath();
        }
        String fromClause = ' FROM ' + dr.getName(); 
        QueryString qs = new QueryString();
        qs.selectClause = selectClause;
        qs.fromClause = fromClause;
        return JSON.serialize(qs);
    }

    @remoteAction
    global static String queryFromFieldSet(String id, String fieldSetName){
        Id objId = (id) Id;
        Schema.SObjectType token = objId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, Schema.FieldSet> FsMap = dr.fieldSets.getMap();
        String queryString = 'SELECT Id';
        List<Schema.FieldSetMember> querySet = new List<Schema.FieldSetMember>();
        querySet = FsMap.get(FieldSetName).getFields();
        for(Schema.FieldSetMember f : querySet) {
            queryString += ', '+ f.getFieldPath();
        }
        queryString += ' FROM ' + dr.getName() + ' WHERE id = \''+ objId +'\' LIMIT 1';
        system.debug(queryString);
        return JSON.serialize(database.Query(queryString));
    }
    
    @remoteAction
    global static String getPicklistValues(String objtype, String fieldName) {
        try
        {
            Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
            List<Schema.PicklistEntry> pickListValues = field_map.get(fieldName).getDescribe().getPickListValues();
            List<pickListValues> options = new List<picklistValues>();
            for(Schema.PicklistEntry plv : pickListValues){
                pickListValues pv = new pickListValues();
                pv.label = plv.getLabel();
                pv.value = plv.getValue();
                options.add(pv);
            }
            return JSON.serialize(options);
        }
        catch(Exception e)
        {
            return '[{"message":"Inavalid input","errorCode":"INVALID_INPUT"}]';
        }
    }

    @remoteAction
    global static Set<String> getPicklistValuesWithFieldName(String objtype, String fieldName) {
        try
        {
            Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
            List<Schema.PicklistEntry> pickListValues = field_map.get(fieldName).getDescribe().getPickListValues();

            Set<String> setPicklistValues = new Set<String>();
            
            for(Schema.PicklistEntry plv : pickListValues){

                setPicklistValues.add(plv.getValue());
            }

            return setPicklistValues;
        }
        catch(Exception e)
        {
            return null;
        }
    }

    //@remoteAction
    //global static String getQueryResultsAsSelect2Data(String soql) {
    //    List<sObject> records;
    //    try {
    //        records = Database.query(soql);
    //    } catch (QueryException qe) {
    //        return '[{"message":"'+qe.getMessage()+'","errorCode":"INVALID_QUERY"}]';
    //    }
    //    List<Select2Data> sData = new List<Select2Data>();
    //    for(sObject r : records) {
    //        Select2Data s = new Select2Data();
    //        s.id = r.id;
    //        s.name = (String) r.get('Name');
    //        //s.searchName = (String) r.get('SearchName__c');
    //        sData.add(s);
    //    }
    //    return JSON.serialize(sData);
    //}

    //@remoteAction
    //global static String sObjectKlone(String iId) {
    //    try
    //    {
    //        Id id = (id) iId; 
    //        sObjectType type = id.getSObjectType();
    //        Schema.DescribeSObjectResult dr = type.getDescribe();
    //        map<String, Schema.SObjectField> fieldMap = dr.fields.getMap(); 
    //        String qs = 'SELECT Id';
    //        Set<string> querySet = new Set<string>();
    //        querySet.addAll(fieldMap.keySet());
    //        querySet.remove('id');
    //        for(String f : querySet) {
    //            if(String.valueOf(fieldMap.get(f).getDescribe().getType()) != 'LOCATION')
    //                qs += ', '+ f;
    //        }
    //        qs += ' FROM ' + dr.getName() + ' WHERE id = \'' + id + '\' LIMIT 1';
    //        sObject toClone = Database.query(qs);
    //        sObject cloned = toClone.clone(false,true,false,false);
    //        String results;
    //        upsert cloned;
    //        results = cloned.id;
    //        return JSON.serialize(results);
    //    }
    //    catch(Exception e)
    //    {
    //        return '[{"message":"DML Failed","errorCode":"INVALID_DATA"}]';
    //    }
    //}

    @remoteAction
    global static String getObjType(String Id) {
        try
        {
            Id objId = (id) Id;
            Schema.SObjectType token = objId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            String objName = dr.getName();
            Map<String,String> retObj = new Map<String,String>();
            retObj.put('type', objName);
            return JSON.serialize(retObj);
        }
        catch(Exception e)
        {
            return '[{"message":"Operation failed","errorCode":"INVALID_ID"}]';
        }
    }

    @remoteAction
    global static String create(String objtype, String fields) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        SObject obj = targetType.newSObject();
        
        Map<String, Object> fieldMap = null;
        
        String error = writeFields(objType, obj, fields);
        if (error != null) {
            return error;
        }
        
        try {
            insert obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('id', obj.id);
        result.put('errors', new List<String>());
        result.put('success', true);
        
        return JSON.serialize(result);
    }
    
    /*
    @remoteAction
    global static String bulkCreate(String objtype, String fields) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        List<sObject> objs = new List<sObject>();

        Map<String, Object> incomingFieldJsonObject = null;
        try {
            incomingFieldJsonObject = (Map<String, Object>)JSON.deserializeUntyped(fields);
        } catch (JSONException je) {
            return '[{"message":"'+je.getMessage()+'","errorCode":"JSON_PARSER_ERROR"}]';
        }
        
        try {
            for(String row : incomingFieldJsonObject.keySet()){
                Map<String,Object> current = (Map<String,Object>) incomingFieldJsonObject.get(row);
                SObject obj = targetType.newSObject();
                for(String property : current.keySet()) {
                    if (targetFields.get(property).getDescribe().getType() == Schema.DisplayType.Date) {
                        obj.put(property, Date.valueOf((String)current.get(property)));
                    }else if(targetFields.get(property).getDescribe().getType() == Schema.DisplayType.DateTime){
                        obj.put(property,DateTime.valueOf((String)current.get(property)));
                    }else if (targetFields.get(property).getDescribe().getType() == Schema.DisplayType.Percent ||
                           targetFields.get(property).getDescribe().getType() == Schema.DisplayType.Currency) {
                        obj.put(property, String.valueOf(current.get(property)) == '' ? null : Decimal.valueOf((String)current.get(property)));
                    } else if (targetFields.get(property).getDescribe().getType() == Schema.DisplayType.Double) {
                        obj.put(property, String.valueOf(current.get(property)) == '' ? null : Double.valueOf(current.get(property)));
                    } else if (targetFields.get(property).getDescribe().getType() == Schema.DisplayType.Integer) {
                        obj.put(property, Integer.valueOf(current.get(property)));
                    } else {
                        obj.put(property, current.get(property));
                    }
                }
                objs.add(obj);
            }
        } catch (SObjectException soe) {
            return '[{"message":"'+soe.getMessage()+'","errorCode":"INVALID_FIELD"}]';
        }
        
        try {
            insert objs;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        List<Id> rids = new List<Id>();
        for(sObject o : objs) {
            rids.add(o.Id);
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('id', rids);
        result.put('errors', new List<String>());
        result.put('success', true);
        
        return JSON.serialize(result);
    }
    */

    @remoteAction
    global static String retrieve(String objtype, String id, String fieldlist) {
        // TODO - handle null fieldlist - retrieve all fields
        Boolean containsId = false;
        for (String field : fieldlist.split(',')) {
            if (field.equalsIgnoreCase('id')){
                containsId = true;
                break;
            }
        }
        
        if (!containsId) {
            fieldlist = 'Id,'+fieldlist;
        }
        
        String soql = 'SELECT '+fieldlist+' FROM '+objtype+' WHERE Id = \''+id+'\'';
        List<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return '[{"message":"'+qe.getMessage()+'","errorCode":"INVALID_QUERY"}]';
        }
        
        return JSON.serialize(records[0]);
    }
    
    @remoteAction
    global static String upser(String objtype, String externalIdField, String externalId, String fields) {
        Map<String, Object> result = new Map<String, Object>();
        try
        {
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
            
            SObject obj = targetType.newSObject();
            obj.put(externalIdField, externalId);
            
            Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(fields);
            for (String key : fieldMap.keySet()) {
                obj.put(key, fieldMap.get(key));
            }
            
            Schema.SObjectField sobjField = targetType.getDescribe().fields.getMap().get(externalIdField);
            
            Database.Upsert(obj, sobjField);

            result.put('success', 'true');
            result.put('Id', obj.Id);
            
            return JSON.serialize(result);
        }
        catch(Exception e)
        {
            return '[{"message":"DML Failed","errorCode":"DML_EXCEPTION"}]';
        }
    }

    @RemoteAction
    global static String updat(String objtype, String id, String fields) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
        
        SObject obj = targetType.newSObject(id);
        
        Map<String, Object> fieldMap = null;
        
        String error = writeFields(objType, obj, fields);
        if (error != null) {
            return error;
        }
        
        try {
            update obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            system.debug('[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]');
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        return null;
    }

    @remoteAction
    global static String del(String objtype, String id) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
        
        SObject obj = targetType.newSObject();
        obj.put('Id', id);
        
        try {
            delete obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        return null;
    }

    @remoteAction
    global static String query(String soql) {
        
        DateTime dt = datetime.Now();
        List<sObject> records; 
        try {
            if(soql.contains('PLACEHOLDER-OPENACTIVITY')){
                soql = soql.replace('PLACEHOLDER-OPENACTIVITY', 'AND StartDateTime >: dt');
                
                records = Database.query(soql);   
            }
            else if(soql.contains('PLACEHOLDER-CLOSEDACTIVITY')){
                soql = soql.replace('PLACEHOLDER-CLOSEDACTIVITY', 'AND StartDateTime <: dt');
                records = Database.query(soql);   
            }
            else{
                records = Database.query(soql);    
            }
        } catch (QueryException qe) {
            return '[{"message":"'+qe.getMessage()+'","errorCode":"INVALID_QUERY"}]';
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);
        
        return JSON.serialize(result);
    }

    @remoteAction
    global static String search(String sosl) {
        List<List<SObject>> result;        
        try {
            result = Search.query(sosl);
        } catch (Exception se) {
            return '[{"message":"'+se.getMessage()+'","errorCode":"INVALID_SEARCH"}]';
        }
        
        return JSON.serialize(result);
    }

    /*Functions to get the user currency symbol*/
    /*global static String getCurrencyIsoCode(){
        String currencyIso = UserInfo.getDefaultCurrency();
        return currencyIso;
    }*/

    global static String getCurrencySymbolFromIso(String Iso) {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' : 
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' : 
           ('KRW' == Iso ? '₩' : 
           ('CNY' == Iso ? '元' : 
           Iso)))))));

           return currencySymbol;
    }

    /*@remoteAction
    global static String getCurrencySymbol() {

        String currencySymbol = getCurrencySymbolFromIso(getCurrencyIsoCode());

        Map<String, String> result = new Map<String, String>();
        result.put('currencySymbol', currencySymbol);
        
        return JSON.serialize(result);
    }*/

    //populate a map with locale values and corresponding datetime formats
    private static Map<String, String> dateFormatMap() {
        Map<String, String> dateFormat = new Map<String, String>{'ar' => 'dd/MM/yyyy', 
                                                                'ar_AE' => 'dd/MM/yyyy', 
                                                                'ar_BH' => 'dd/MM/yyyy', 
                                                                'ar_EG' => 'dd/MM/yyyy', 
                                                                'ar_JO' => 'dd/MM/yyyy', 
                                                                'ar_KW' => 'dd/MM/yyyy', 
                                                                'ar_LB' => 'dd/MM/yyyy', 
                                                                'ar_SA' => 'dd/MM/yyyy', 
                                                                'bg' => 'yyyy-M-d', 
                                                                'bg_BG' => 'yyyy-M-d', 
                                                                'ca' => 'dd/MM/yyyy', 
                                                                'ca_ES' => 'dd/MM/yyyy', 
                                                                'ca_ES_EURO' => 'dd/MM/yyyy', 
                                                                'cs' => 'd.M.yyyy', 
                                                                'cs_CZ' => 'd.M.yyyy', 
                                                                'da' => 'dd-MM-yyyy', 
                                                                'da_DK' => 'dd-MM-yyyy', 
                                                                'de' => 'dd.MM.yyyy', 
                                                                'de_AT' => 'dd.MM.yyyy', 
                                                                'de_AT_EURO' => 'dd.MM.yyyy', 
                                                                'de_CH' => 'dd.MM.yyyy', 
                                                                'de_DE' => 'dd.MM.yyyy', 
                                                                'de_DE_EURO' => 'dd.MM.yyyy', 
                                                                'de_LU' => 'dd.MM.yyyy', 
                                                                'el' => 'd/M/yyyy', 
                                                                'el_GR' => 'd/M/yyyy', 
                                                                'en_AU' => 'd/MM/yyyy', 
                                                                'en_BB' => 'M/d/yyyy', 
                                                                'en_BM' => 'M/d/yyyy', 
                                                                'en_CA' => 'dd/MM/yyyy', 
                                                                'en_GB' => 'dd/MM/yyyy', 
                                                                'en_GH' => 'M/d/yyyy', 
                                                                'en_ID' => 'M/d/yyyy', 
                                                                'en_IE' => 'dd/MM/yyyy', 
                                                                'en_IN' => 'd/M/yyyy', 
                                                                'en_MY' => 'd/M/yyyy', 
                                                                'en_NG' => 'm/D/yyyy', 
                                                                'en_NZ' => 'd/MM/yyyy', 
                                                                'en_PH' => 'm/d/yyyy', 
                                                                'en_SG' => 'M/d/yyyy', 
                                                                'en_US' => 'M/d/yyyy', 
                                                                'en_ZA' => 'yyyy/MM/dd', 
                                                                'es' => 'd/MM/yyyy', 
                                                                'es_AR' => 'dd/MM/yyyy', 
                                                                'es_BO' => 'dd-MM-yyyy', 
                                                                'es_CL' => 'dd-MM-yyyy', 
                                                                'es_CO' => 'd/MM/yyyy', 
                                                                'es_CR' => 'dd/MM/yyyy', 
                                                                'es_DO' => 'MM/dd/yyyy', 
                                                                'es_EC' => 'dd/MM/yyyy', 
                                                                'es_ES' => 'd/MM/yyyy', 
                                                                'es_GT' => 'd/MM/yyyy', 
                                                                'es_HN' => 'MM-dd-yyyy', 
                                                                'es_MX' => 'd/MM/yyyy', 
                                                                'es_PA' => 'mm/dd/yyyy', 
                                                                'es_PE' => 'dd/MM/yyyy', 
                                                                'es_PR' => 'MM-dd-yyyy', 
                                                                'es_PY' => 'dd/MM/yyyy', 
                                                                'es_SVUS' => 'MM-dd-yyyy', 
                                                                'es_UY' => 'dd/MM/yyyy', 
                                                                'es_VE' => 'dd/MM/yyyy', 
                                                                'et_EE' => 'd.MM.yyyy', 
                                                                'fi' => 'd.M.yyyy', 
                                                                'fi_FI' => 'd.M.yyyy', 
                                                                'fr' => 'dd/MM/yyyy', 
                                                                'fr_BE' => 'd/MM/yyyy', 
                                                                'fr_CA' => 'yyyy-MM-dd', 
                                                                'fr_CH' => 'dd.MM.yyyy', 
                                                                'fr_FR' => 'dd/MM/yyyy', 
                                                                'fr_LU' => 'dd/MM/yyyy', 
                                                                'fr_MC' => 'dd/MM/yyyy', 
                                                                'ga_IE' => 'dd/MM/yyyy', 
                                                                'hr_HR' => 'yyyy.MM.dd', 
                                                                'hu' => 'yyyy.MM.dd.', 
                                                                'hu_HU' => 'yyyy.MM.dd.', 
                                                                'hy_AM' => 'M/d/yyyy', 
                                                                'in' => 'yyyy/mm/dd', 
                                                                'in_ID' => 'dd/mm/yyyy', 
                                                                'is_IS' => 'd.M.yyyy', 
                                                                'it' => 'dd/MM/yyyy', 
                                                                'it_CH' => 'dd.MM.yyyy', 
                                                                'it_IT' => 'dd/MM/yyyy', 
                                                                'iw' => 'dd/MM/yyyy', 
                                                                'iw_IL' => 'dd/MM/yyyy', 
                                                                'ja' => 'yyyy/MM/dd', 
                                                                'ja_JP' => 'yyyy/MM/dd', 
                                                                'ka' => 'm/d/yyyy', 
                                                                'ka_GE' => 'm/d/yyyy', 
                                                                'kk_KZ' => 'M/d/yyyy', 
                                                                'km_KH' => 'M/d/yyyy', 
                                                                'ko' => 'yyyy. M. d', 
                                                                'ko_KR' => 'yyyy. M. d', 
                                                                'lt_LT' => 'yyyy.M.d', 
                                                                'lv_LV' => 'yyyy.d.M', 
                                                                'ms_MY' => 'dd/MM/yyyy', 
                                                                'nl' => 'd-M-yyyy', 
                                                                'nl_BE' => 'd/MM/yyyy', 
                                                                'nl_NL' => 'd-M-yyyy', 
                                                                'nl_SR' => 'd-M-yyyy', 
                                                                'no' => 'dd.MM.yyyy', 
                                                                'no_NO' => 'dd.MM.yyyy', 
                                                                'pl' => 'yyyy-MM-dd', 
                                                                'pt' => 'dd-MM-yyyy', 
                                                                'pt_AO' => 'dd-MM-yyyy', 
                                                                'pt_BR' => 'dd/MM/yyyy', 
                                                                'pt_PT' => 'dd-MM-yyyy', 
                                                                'ro' => 'dd.MM.yyyy', 
                                                                'ro_RO' => 'dd.MM.yyyy', 
                                                                'ru' => 'dd.MM.yyyy', 
                                                                'ru_RU' => 'dd.MM.yyyy', 
                                                                'sh' => 'dd.MM.yyyy', 
                                                                'sh_BA' => 'dd.MM.yyyy', 
                                                                'sh_CS' => 'dd.MM.yyyy', 
                                                                'sk' => 'd.M.yyyy', 
                                                                'sl_SI' => 'd.M.yy', 
                                                                'sr' => 'd.M.yyyy', 
                                                                'sr_BA' => 'yyyy-MM-DD', 
                                                                'sr_CS' => 'D.m.yyyy', 
                                                                'sk_SK' => 'd.M.yyyy', 
                                                                'sl_SI' => 'd.M.y', 
                                                                'sv' => 'yyyy-MM-dd', 
                                                                'sv_SE' => 'yyyy-MM-dd', 
                                                                'th' => 'M/d/yyyy', 
                                                                'th_TH' => 'd/M/yyyy', 
                                                                'tr' => 'dd.MM.yyyy', 
                                                                'tr_TR' => 'dd.MM.yyyy', 
                                                                'uk' => 'dd.MM.yyyy', 
                                                                'uk_UA' => 'dd.MM.yyyy', 
                                                                'ur_PK' => 'd/M/yyyy', 
                                                                'ur_PK' => 'd/M/yyyy', 
                                                                'ur_PK' => 'M/d/yyyy', 
                                                                'vi' => 'dd/MM/yyyy', 
                                                                'vi_VN' => 'dd/MM/yyyy', 
                                                                'zh' => 'yyyy-M-d', 
                                                                'zh_CN' => 'yyyy-M-d', 
                                                                'zh_HK' => 'yyyy-M-d', 
                                                                'zh_TW' => 'yyyy/M/d'}; //holds the locale to timedate formats
        return dateFormat; //return the map
    }

    private static Map<String, String> timeFormatMap() {
        Map<String, String> timeFormat = new Map<String, String>{'ar' => 'hh:mm a',
                                                                'ar_AE' => 'hh:mm a',
                                                                'ar_BH' => 'hh:mm a',
                                                                'ar_JO' => 'hh:mm a',
                                                                'ar_KW' => 'hh:mm a',
                                                                'ar_LB' => 'hh:mm a',
                                                                'ar_SA' => 'hh:mm a',
                                                                'bg_BG' => 'H:mm',
                                                                'ca' => 'HH:mm',
                                                                'ca_ES' => 'HH:mm',
                                                                'ca_ES_EURO' => 'HH:mm',
                                                                'cs' => 'H:mm',
                                                                'cs_CZ' => 'H:mm',
                                                                'da' => 'HH:mm',
                                                                'da_DK' => 'HH:mm',
                                                                'de' => 'HH:mm',
                                                                'de_AT' => 'HH:mm',
                                                                'de_AT_EURO' => 'HH:mm',
                                                                'de_CH' => 'HH:mm',
                                                                'de_DE' => 'HH:mm',
                                                                'de_DE_EURO' => 'HH:mm',
                                                                'de_LU' => 'HH:mm',
                                                                'de_LU_EURO' => 'HH:mm',
                                                                'el_GR' => 'h:mm a',
                                                                'en_AU' => 'HH:mm',
                                                                'en_B' => 'h:mm a',
                                                                'en_BM' => 'h:mm a',
                                                                'en_CA' => 'h:mm a',
                                                                'en_GB' => 'HH:mm',
                                                                'en_GH' => 'h:mm a',
                                                                'en_ID' => 'h:mm a',
                                                                'en_IE' => 'HH:mm',
                                                                'en_IE_EURO' => 'HH:mm',
                                                                'en_NZ' => 'HH:mm',
                                                                'en_SG' => 'h:mm a',
                                                                'en_US' => 'h:mm a',
                                                                'en_ZA' => 'hh:mm a',
                                                                'es' => 'H:mm',
                                                                'es_AR' => 'HH:mm',
                                                                'es_BO' => 'hh:mm a',
                                                                'es_CL' => 'hh:mm a',
                                                                'es_CO' => 'hh:mm a',
                                                                'es_CR' => 'hh:mm a',
                                                                'es_EC' => 'hh:mm a',
                                                                'es_ES' => 'H:mm',
                                                                'es_ES_EURO' => 'H:mm',
                                                                'es_GT' => 'hh:mm a',
                                                                'es_HN' => 'hh:mm a',
                                                                'es_MX' => 'hh:mm a',
                                                                'es_PE' => 'hh:mm a',
                                                                'es_PR' => 'hh:mm a',
                                                                'es_PY' => 'hh:mm a',
                                                                'es_SV' => 'hh:mm a',
                                                                'es_UY' => 'hh:mm a',
                                                                'es_VE' => 'hh:mm a',
                                                                'et_EE' => 'd.MM.yyyy H:mm',
                                                                'fi' => 'H:mm',
                                                                'fi_FI' => 'H:mm',
                                                                'fi_FI_EURO' => 'H:mm',
                                                                'fr' => 'HH:mm',
                                                                'fr_BE' => 'H:mm',
                                                                'fr_CA' => 'HH:mm',
                                                                'fr_CH' => 'HH:mm',
                                                                'fr_FR' => 'HH:mm',
                                                                'fr_FR_EURO' => 'HH:mm',
                                                                'fr_LU' => 'HH:mm',
                                                                'fr_MC' => 'HH:mm',
                                                                'hr_HR' => 'HH:mm',
                                                                'hu' => 'H:mm',
                                                                'hy_AM' => 'h:mm a',
                                                                'is_IS' => 'HH:mm',
                                                                'it' => 'H.mm',
                                                                'it_CH' => 'HH:mm',
                                                                'it_IT' => 'H.mm',
                                                                'iw' => 'HH:mm ',
                                                                'iw_IL' => 'HH:mm',
                                                                'ja' => 'H:mm',
                                                                'ja_JP' => 'H:mm',
                                                                'kk_KZ' => 'h:mm a',
                                                                'km_KH' => 'h:mm a',
                                                                'ko' => 'a h:mm',
                                                                'ko_KR' => 'a h:mm',
                                                                'lt_LT' => 'HH.mm',
                                                                'lv_LV' => 'HH:mm',
                                                                'ms_MY' => 'h:mm a',
                                                                'nl' => 'H:mm',
                                                                'nl_BE' => 'H:mm',
                                                                'nl_NL' => 'H:mm',
                                                                'nl_SR' => 'H:mm',
                                                                'no' => 'HH:mm',
                                                                'no_NO' => 'HH:mm',
                                                                'pl' => 'HH:mm',
                                                                'pt' => 'H:mm',
                                                                'pt_AO' => 'H:mm',
                                                                'pt_BR' => 'HH:mm',
                                                                'pt_PT' => 'H:mm',
                                                                'ro_RO' => 'HH:mm',
                                                                'ru' => 'H:mm',
                                                                'sk_SK' => 'H:mm',
                                                                'sl_SI' => 'H:mm',
                                                                'sv' => 'HH:mm',
                                                                'sv_SE' => 'HH:mm',
                                                                'th' => 'h:mm a',
                                                                'th_TH' => 'H:mm ?.',
                                                                'tr' => 'HH:mm',
                                                                'ur_PK' => 'h:mm a',
                                                                'vi_VN' => 'HH:mm ',
                                                                'zh' => 'ah:mm',
                                                                'zh_CN' => 'ah:mm',
                                                                'zh_HK' => 'ah:mm',
                                                                'zh_TW' => 'a h:mm'}; //holds the locale to timedate formats
        return timeFormat; //return the map
    }
    /*@remoteAction
    global static String getDateFormat() {

        String dateFormat = dateFormat().containsKey(UserInfo.getLocale()) ? dateFormat().get(UserInfo.getLocale())  : 'dd/MM/yyyy' ;

        Map<String, String> result = new Map<String, String>();

        result.put('dateFormat', dateFormat);
        result.put('userLocale', UserInfo.getLocale());
        
        return JSON.serialize(result);
    }*/

    /*
    Function to get the date format from custom setting 
    If custom setting doesn't have any date format then get the user locale.
    */
    public static String getDateFormat() {

        String dateFormat;
        Date_Format__c csDateFormat = Date_Format__c.getInstance();
        
        if(csDateFormat.Format__c != null) {

            dateFormat = csDateFormat.Format__c;

        } else {

            dateFormat = dateFormatMap().containsKey(UserInfo.getLocale()) ? dateFormatMap().get(UserInfo.getLocale())  : 'dd/MM/yyyy' ;
        }
        
        return dateFormat;
    }

    public static String getTimeFormat() {
        String timeFormat;

        timeFormat = timeFormatMap().containsKey(UserInfo.getLocale()) ? timeFormatMap().get(UserInfo.getLocale())  : 'h:mm a';
        
        return timeFormat;
    }
    
}