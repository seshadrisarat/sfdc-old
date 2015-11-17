/*
Name: queryGenerator
Author: Daniel Llewellyn
Date: 4/02/2013
Description: Meant to be invoked by a visualforce page. This class can take url params to query for a list of any kind of
             sObject. Those sObjects can then be used to power user interface elements. By passing in a list of Ids and an
             option field set, this class is able to determine the object type, find a matching field set, run the query, and perform
             automatic translation from relationship ids to the related record names. So instead of seeing accountId on your report, you could
             see the account name without having to create a formula field. Useful for generating lists of sObjects when the type
             of object, and desired fields is not known ahead of time.

URL Params:
name            type         req      description
--------------------------------------------------------------------------------------------------------------------
ids:            csv of ids   true     a list of sObject Ids seperated by commas. The objects to include in the return query
fieldSet:       string       true     the name of a fieldset to use to determine which fields to include.
order_by        string       false    the name of a field on the object to order the results by
return_in_order boolean      false    should the results be returned in the same order they were provided in the URL? Overrides the order_by param if set to true.
force_download  boolean      false    should the PDF file be forced to donwload instead of displayed in the browser window?
filename        string       false    the name to assign to the downloaded file if force_download is set to true. Defaults to object label + ' report.pdf' Do not include .pdf. It is appened automatically.

Gotchas:
Due to the way the query is built (filtering by a list of Ids) you can only get probably about 500 records max before the query length gets too long.
Shouldn't be a big deal though, a report of more than 500 records starts to get kind of meaningless most of the time. It will attempt to gracefully handle
any errors and return them nicely to the user.

*/

public class queryGenerator
{
    //Params. Can be used in your visualforce page to customize report data.
    //gets set by code that figures out the type of object represented by the list of ids
    public Schema.SObjectType OBJECT_SCHEMA_TYPE{get;set;}
    
    //Holds the API name of the object. Defaults to undefined
    //gets set by code that figures out the type of object represented by the list of ids
    public string OBJECT_TYPE_NAME{get {
        if(OBJECT_TYPE_NAME == null)
        {
            OBJECT_TYPE_NAME = 'Undefined';
        }
        return OBJECT_TYPE_NAME;    
    } set;}
    
    //Holds the label of the object. Defaults to undefined
    //gets set by code that figures out the type of object represented by the list of ids
    public string OBJECT_TYPE_LABEL{get {
        if(OBJECT_TYPE_LABEL == null)
        {
            OBJECT_TYPE_LABEL = 'Undefined';
        }
        return OBJECT_TYPE_LABEL;
    } set;}
    
    //Holds the field to order the query result set by. Defaults to Id
    //may be overriden with the order_by url param.
    public string ORDER_BY{get {
        if(ORDER_BY == null)
        {
            ORDER_BY = 'Id';
        }
        return ORDER_BY;
    }set;}
    
    //Holds the boolean flag of whether the result set should be returned in the same order that the ids were passed in.  Defaults to false.
    //may be override with the return_in_order url param.
    public boolean RETURN_IN_ORDER{get {
        if(RETURN_IN_ORDER == null)
        {
            RETURN_IN_ORDER = false;
        }
        return RETURN_IN_ORDER;
    }set;}
    
    //Holds a SOQL ready list of fields to query for. 
    //gets set by the fieldset specified in the url using the fieldset param.
    public list<string> OBJECT_FIELDS{get {
     if(OBJECT_FIELDS == null)
     {
         OBJECT_FIELDS = new list<string>();
     }
     return OBJECT_FIELDS;
    }set;}
    
    //Holds the name of the fieldset provided in the url if one was provided.
    public string FIELD_SET{get{
        if(FIELD_SET == null)
        {
            FIELD_SET = 'PDF_Export';
        }
        return FIELD_SET;
    }set;}
    
    //Holds mapping of field name to field label.
    public map<string,string> OBJECT_FIELD_MAP{get {
        if(OBJECT_FIELD_MAP == null)
        {
            OBJECT_FIELD_MAP = new map<string,string>();   
        }
        return OBJECT_FIELD_MAP;
    }set;}
    
    //Holds mapping of field name to field data type (data type is converted to lower case)
    public map<string,string> FIELD_DATA_TYPES{get {
        if(FIELD_DATA_TYPES == null)
        {
            FIELD_DATA_TYPES = new map<string,string>();
        }
        return FIELD_DATA_TYPES;
    } set;}
    
    //Holds list of object Ids to query for. Set by the url param ids
    public list<id> OBJECT_IDS{get {
        if(OBJECT_IDS == null)
        {
            OBJECT_IDS = new list<id>();
        }
        return OBJECT_IDS;        
    }set;}
    
    //Holds the result of the query once it has been run.
    public list<sobject> OBJECTS{get {
        if(OBJECTS == null)
        {
            OBJECTS = new list<sObject>();
        }
        return OBJECTS;
    }set;}
    
    //Holds a list of field names and a boolean flag that indicates if a field should be hidden or not. This data is then
    //used by the visualforce page to hide those data columns. This feature is used to hide relationship fields
    //since they will just contain a record id which users don't care about. The code automatically handles
    //querying for the associated record name and including that instead. (TODO: turn that feature into an option).
    public map<string,boolean> HIDDEN_FIELD_MAP{get {
        if(HIDDEN_FIELD_MAP == null)
        {
            HIDDEN_FIELD_MAP = new map<string,boolean>();
        }
        return HIDDEN_FIELD_MAP;   
    }set;}
    
    //Holds the SOQL string to be run to query for records to include in the report.
    public string queryString{get;set;}
    
    //Gets the total amount of records returned by the query. Used for the footer of the visualforce page since VF can't call methods on objects (that I am aware of).
    public integer RECORD_COUNT{get { 
        return objects.size();
    }set;}

    public boolean ERROR_OCCURED {get;set;}
    public string ERROR_MESSAGE {get;set;}
    public queryGenerator(){

        try
        {
            //get the list of ids to query for. We expect them to come in a url param called ids, and they should be
            //comma seperated. Since we know that, we can split them based on , to get a list of ids.
            if(ApexPages.currentPage().getParameters().get('ids') == null)
            {
                throw new applicationException('Please include a list of a comma seperated ids to query for in the url by specifying ?ids=id1,id2,id3 etc.');
            }
            OBJECT_IDS = ApexPages.currentPage().getParameters().get('ids').split(',');

            if(OBJECT_IDS.isEmpty() || OBJECT_IDS.size() == 0)
            {
                throw new applicationException('Please include a list of a comma seperated ids to query for in the url by specifying ?ids=id1,id2,id3 etc.');
            }
            
            if(ApexPages.currentPage().getParameters().get('fieldset') == null)
            {
                throw new applicationException('Please provide a fieldSet to use for this report in the url by specifying ?fieldset=fieldSetName.');
            }
            FIELD_SET = ApexPages.currentPage().getParameters().get('fieldset');
            
            //use the ids getSObjecType method to figure out what kind of objects these are we got passed. 
            OBJECT_SCHEMA_TYPE = OBJECT_IDS[0].getSObjectType(); 
            
            //get the name of this object type
            OBJECT_TYPE_NAME = OBJECT_SCHEMA_TYPE.getDescribe().getName();

            //get the label of this object type
            OBJECT_TYPE_LABEL = OBJECT_SCHEMA_TYPE.getDescribe().getLabel();

            //figure out what fields we are querying for by passing the object type, and the desired field set to our getObjectQueryFields method.
            OBJECT_FIELDS = getObjectQueryFields(OBJECT_SCHEMA_TYPE, FIELD_SET);    
            
            //set the order by statment. If no order by is specified, just tell it to order by Id to prevent a syntax error
            if(ApexPages.currentPage().getParameters().get('order_by') != null)
            {
                ORDER_BY = ApexPages.currentPage().getParameters().get('order_by');
            }
            
            //set the return in order param if needed. It defaults to false
            if(ApexPages.currentPage().getParameters().get('return_in_order') != null && ApexPages.currentPage().getParameters().get('return_in_order') == 'true')
            {
                RETURN_IN_ORDER = true;   
            }       

            //run the query to actually get the report rows
            OBJECTS = getSojects();   

            //if the force_download param has been set, then include the header data to force download.
            if(ApexPages.currentPage().getParameters().get('force_download') != null && ApexPages.currentPage().getParameters().get('force_download') == 'true') 
            {
                string fileName = 'Report of '+OBJECT_TYPE_LABEL+'.pdf';
                if(apexPages.currentPage().getParameters().get('filename') != null)
                {
                    fileName = apexPages.currentPage().getParameters().get('filename') +'.pdf';
                }
                Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+fileName);
            }    
        
        }
        catch(exception ex)
        {
            //catch and return errors. Most often will happen from a bad Id of fieldname being passed in.
            system.debug('\n\n\n------Error occured during page init!');
            system.debug(ex.getMessage() + ' on line ' + ex.getLineNumber());
            ERROR_MESSAGE = ex.getMessage() + 'Error occured on line ' + ex.getLineNumber();
            ERROR_OCCURED = true;
        }
        
    } 
    //this method will be invoked by a visualforce page. It will determine the sObject
    //type by examining the Ids passed in the ids param. Once it knows the object type it will
    //then attempt to find a locate the specified fieldset if one was passed in the URL. If no fieldset
    //was provided, then it will query for all sObject fields.

    public list<sobject> getSojects()
    {
        list<sobject> queryResults;

        //lets get a list of fields to query for by using the getObjectQueryFields method. We will pass in the object type
        //and the fieldset url param (which may be null, but that doesnt matter).
        string queryFields = listToCsv(OBJECT_FIELDS);

        //build this query string
        queryString = 'select ' + queryFields + ' from ' + OBJECT_TYPE_NAME + ' where id in :OBJECT_IDS ORDER BY '+ORDER_BY;

        if(queryString.length() > 10000)
        {
            throw new applicationException('Query too long. Length is ('+queryString.length()+') chars. Please reduce the number of ids or reduce the number of fields queried for to get the length under 10,000.');
        }
        //run the query.
        queryResults = database.query(queryString);

        if(RETURN_IN_ORDER)
        {
            queryResults = sortQueryInOrder(OBJECT_IDS, queryResults);
        }

        return queryResults;
    }

    //takes the list of sObjects and sorts them in the order they were passed in the URL. This allows for a custom sorting order to be passed in
    //without having to make use of the SOQL order by clause which may not be robust enough to handle the types of sorts desired.
    //WARNING THIS IS PROBABLY PRETTY DAMN SLOW!
    public list<sObject> sortQueryInOrder(list<id> objectOrder, list<sObject> objects)
    {
        map<id,sObject> objectMap = new map<id,sObject>();
        list<sObject> sortedList = new list<sObject>();
        for(sObject obj : objects)
        {
            objectMap.put((id) obj.get('id'), obj);
        }

        for(id objId : objectOrder)
        {
            sortedList.add(objectMap.get(objId));
        }
        return sortedList;

    }
    //takes an sObject type and optional name of a fieldset for that sObject type (can be null). Returns a list
    //of strings of fields to query for either based on the fieldset, or by finding all sObject fields if no fieldSet
    //is specified, or a matching fieldSet can not be found.
    public list<string> getObjectQueryFields(Schema.SObjectType objectType, string fieldSetName)
    {
        //we need to return a list since lists maintain order and we want to maintain the order of the fields passed in.
        //however we also want to not allow duplicates which having a set allows, so we use both. Dumb I know, but it works.      
        list<string> fields = new list<string>();
        set<string> includedFields = new set<string>();  
        
        Schema.FieldSet thisFieldSet = null;
        
        //first any fieldsets that are defined for this object type. It is possible this might be empty.
        Map<String, Schema.FieldSet> fieldSetMap = objectType.getDescribe().fieldSets.getMap();  

        //check to see if the user passed in a field set, and if so, does it exist? 
        //if so, use that fieldset. Otherwise, use all fields on the object
        if(fieldSetName != null && fieldSetMap.containsKey(fieldSetName))
        {
            thisFieldSet = fieldSetMap.get(fieldSetName);
            
            //now that we know what field set we are using we have to iterate over it and get it feildsetmembers
            //and add each field into the query string.
            for(Schema.FieldSetMember f : thisFieldSet.getFields())
            {
                //some handy reference variables
                string fieldName = f.getFieldPath().toLowerCase();    
                string fieldLabel = f.getLabel();
                string fieldType = f.getType().Name().toLowerCase();
                
                //initially mark this field as not being a relationship field. We will update it later if it is.
                HIDDEN_FIELD_MAP.put(fieldName,false);
                
                if(!includedFields.contains(fieldName))
                {                                  
                    //Add this field to our list of fields if it hasn't been included already. I know using the set and list seems inefficient but we want to maintain order
                    //of fields which a list can do, and we need to not have duplicates which only a set can really do efficiently.
                    fields.add(fieldName);
                    includedFields.add(fieldName);
                    
                    OBJECT_FIELD_MAP.put(fieldName,fieldLabel);
                    FIELD_DATA_TYPES.put(fieldName,fieldType);
                   
                    //here is where things get a little tricky. If a field included is a reference field, if we were to display that as it, would show the user and ID
                    //users generally don't want to see Ids, it would be much nicer if that ID was automatically translated into the name of the record. To do so, we have to figure
                    //out the relationship name (so like accountId = account, or myObject__c = myObject__r)
                    if(fieldType == 'reference')
                    {
                        //okay, so this is a relationship field, so we should update it as being one. So the visualforce page knows not to display it.
                        HIDDEN_FIELD_MAP.put(fieldName,true);
                        
                        //if this is a custom field (which we know by the existance of __c, or lack thereof) then the relationship field is the fieldname with __r replacing __c.
                        //if this is a standard field, the relationship will be the name of the field with the last two chars stripped of (removing the Id from the end of the fieldname,
                        //ex accountId -> account
                        string relationshipFieldName = fieldName.right(3) == '__c' ? fieldName.replace('__c','__r') : fieldName.left(fieldName.length()-2);
                        relationshipFieldName += '.name';
                        
                        //add this relationship field to our map that contains fieldnames and their labels.
                        OBJECT_FIELD_MAP.put(relationshipFieldName,fieldLabel);
                        
                        //so now we add this relationship field to our relationship field map so the visualforce page knows to display it.
                        HIDDEN_FIELD_MAP.put(relationshipFieldName,false);
                        
                        //set the field type as string. Yeah, it would be nice to actually to a describe and figure out the real field type but that would be a lot of work
                        //pretty inefficient and wouldn't provide much value. Most name fields are text anyway, or a number.
                        FIELD_DATA_TYPES.put(relationshipFieldName,'string');
                        
                        //Add this field to our list of fields if it hasn't been included already. I know using the set and list seems inefficient but we want to maintain order
                        //of fields which a list can do, and we need to not have duplicates which only a set can really do efficiently.
                        if(!includedFields.contains(relationshipFieldName))
                        {
                            fields.add(relationshipFieldName);
                            includedFields.add(relationshipFieldName);
                        }                         
                    }                    
                }
            }            
        } 
        else
        {
            throw new applicationException('Could not find provided field set for '+OBJECT_TYPE_NAME+'/'+OBJECT_TYPE_LABEL+'. Provided fieldset name \'' + fieldSetName+ '\'. Please double check that the given fieldset exists for this object.');   
        }                

        return fields;
    }

    //takes a list of strings and returns them in a comma seperated fashion, suitable for feeding into a query.
    public string listToCsv(list<string> stringList)
    {
        string itemList = '';
        for(string thisString : stringList)
        {
            itemList += thisString+',';
        }
        itemList=itemList.substring(0,itemList.length()-1);
        return itemList;
    }

    //Please note for test coverage to pass you will need to have a fieldset called PDF_Export on your account object.
    @isTest(seeAllData=true)
    public static void testQueryGenerator()
    {
        //setup our test account
        Account testAccount = new Account();
        testAccount.name = 'My Test account';
        testAccount.billingStreet = '1234 Test Street';
        testAccount.billingState = 'NY';
        testAccount.billingPostalCode = '55555';
        testAccount.billingCountry = 'USA';

        insert testAccount;

        test.StartTest();

        PageReference pageRef = Page.exportPdf;
        Test.setCurrentPage(pageRef);

        //run it with no ids. It will come back with no records since it will error. Since the error gets caught
        //we don't need to try/catch here though.
        queryGenerator qg = new queryGenerator();

        //run test with nothing but ids specified. This will make it query for all fields
        ApexPages.currentPage().getParameters().put('ids', testAccount.id);  
        ApexPages.currentPage().getParameters().put('fieldset', 'PDF_Export');     
        ApexPages.currentPage().getParameters().put('order_by', 'name'); 
        ApexPages.currentPage().getParameters().put('return_in_order', 'true'); 
        ApexPages.currentPage().getParameters().put('force_download', 'true');
        ApexPages.currentPage().getParameters().put('filename', 'My PDF file');
                 
        qg = new queryGenerator();
    }
    class applicationException extends Exception {}
}