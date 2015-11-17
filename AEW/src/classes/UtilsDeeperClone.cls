global with sharing class UtilsDeeperClone {
    
    //** Deeply clones a list of original records, and all related/requested children
    //** Original list must include the Id field
    global static List<Id> clone(List<sObject> originalObjects, Boolean chatterPost) {
        //** Method variables
        Map<Id, Id> mapIdOldNew = new Map<Id, Id>();
        Map<String, List<Id>> mapObjectIds = new Map<String, List<Id>>();
        Map<String, String> mapRelationshipFields = new Map<String, String>();
        Map<String, Map<Id, sObject>> mapObjectQueries = new Map<String, Map<Id, sObject>>();
        Map<Integer, Map<String, List<sObject>>> mapObject = new Map<Integer, Map<String, List<sObject>>>();
        List<sObjectChildRelationship> myChildRelationships = new List<sObjectChildRelationship>();
        //** Add Level 0 (originalObjects)
        Map<String, List<sObject>> mapObjectCurrent = new Map<String, List<sObject>>();
        List<sObjectChildRelationshipRow> myChildRelationshipRows = new List<sObjectChildRelationshipRow>();
        //** Process input sObjects by sObjectType
        Set<String> origObjectTypeNames = new Set<String>();
        for (sObject originalObject : originalObjects) {
            if (!origObjectTypeNames.contains(originalObject.getSObjectType().getDescribe().getName())) {
                origObjectTypeNames.add(originalObject.getSObjectType().getDescribe().getName());
            }
        }
        for (String origObjectTypeName : origObjectTypeNames) {
            for (sObject originalObject : originalObjects) {
                if (origObjectTypeName == originalObject.getSObjectType().getDescribe().getName()) {
                    //** Add sObject to myChildRelationshipRows
                    myChildRelationshipRows.add(new sObjectChildRelationshipRow(originalObject));
                    //** Populate Map<String, List<Id>> mapIdObjectTypeCurrent
                    if (mapObjectCurrent.containsKey(origObjectTypeName)) {
                        mapObjectCurrent.get(origObjectTypeName).add(originalObject);
                    } else {
                        mapObjectCurrent.put(origObjectTypeName, new List<sObject>{originalObject});
                    }
                }
            }
            //** Add myChildRelationshipRows to a myChildRelationships record with relationship information
            if (!myChildRelationshipRows.isEmpty()) {
                myChildRelationships.add(new sObjectChildRelationship(0, origObjectTypeName, null, myChildRelationshipRows));
            }
        }
        //** Populate Map<Integer, Map<String, List<Id>>> mapObject
        mapObject.put(0, mapObjectCurrent);
        //** Loop through levels 1-n (children)
        for (Integer currentLevel = 1 ; currentLevel < 20 ; currentLevel++) {
            mapObjectCurrent = new Map<String, List<sObject>>();
            if (mapObject.size() == currentLevel) {
                //** Loop through all tables
                for (String objType : mapObject.get(currentLevel-1).keySet()) {
                    List<sObject> sObjectOriginals = mapObject.get(currentLevel-1).get(objType);
                    //** Get complete list of all child relationships for the given table 'objType'
                    List<Schema.ChildRelationship> childRelationships =
                        sObjectOriginals.get(0).getSObjectType().getDescribe().getChildRelationships();
                    //** Exit loop once there are no more childRelationships
                    if (!childRelationships.isEmpty()) {
                        //** Loop through all child relationships
                        for (Schema.ChildRelationship childRelationship : childRelationships) {
                            //** Only run script when the child relationships is acceptable (Custom Setting)
                            if (UtilsVariables.getChildRelationships(objType).contains(
                                    childRelationship.getRelationshipName())) {
                                myChildRelationshipRows = new List<sObjectChildRelationshipRow>();
                                //** Name of the Child Table
                                String childObjectTypeName = childRelationship.getChildSObject().getDescribe().getName();
                                //** Name of the Child Field which stores the Parent sObject Id
                                String childObjectFieldName = childRelationship.getField().getDescribe().getName();
                                //** Build query to return all children in this relationship
                                String childRelationshipQuery = 'SELECT ID';
                                childRelationshipQuery += ' FROM ' + childObjectTypeName;
                                childRelationshipQuery += ' WHERE ' + childObjectFieldName;
                                childRelationshipQuery += ' IN (\'' + sObjectOriginals.get(0).Id + '\'';
                                for (Integer i = 1 ; i < sObjectOriginals.size() ; i++) {
                                    childRelationshipQuery += ', \'' + sObjectOriginals.get(i).Id + '\'';
                                }
                                childRelationshipQuery += ')';
                                //** Executive query to return all children in this relationship
                                List<sObject> childRelationshipQueryResults = Database.query(childRelationshipQuery);
                                //** Loop through all queried children
                                for (sObject childObject : childRelationshipQueryResults) {
                                    //** Add sObject to myChildRelationshipRows
                                    myChildRelationshipRows.add(new sObjectChildRelationshipRow(childObject));
                                    //** Populate Map<String, List<Id>> mapIdObjectTypeCurrent
                                    if (mapObjectCurrent.containsKey(childObjectTypeName)) {
                                        mapObjectCurrent.get(childObjectTypeName).add(childObject);
                                    } else {
                                        mapObjectCurrent.put(childObjectTypeName, new List<sObject>{childObject});
                                    }
                                }
                                //** Add myChildRelationshipRows to a myChildRelationships record with relationship information
                                if (!myChildRelationshipRows.isEmpty()) {
                                    myChildRelationships.add(new sObjectChildRelationship(currentLevel,
                                        childObjectTypeName,
                                        childObjectFieldName,
                                        myChildRelationshipRows));
                                }
                            }
                        }
                    }
                }
            }
            //** Populate Map<Integer, Map<String, List<Id>>> mapObject
            if (!mapObjectCurrent.isEmpty()) {
                mapObject.put(currentLevel, mapObjectCurrent);
            }
        }
        //** Establish a list of Ids per each sObjectType for the result queries
        for (sObjectChildRelationship rel : myChildRelationships) {
            for (sObjectChildRelationshipRow row : rel.myChildRelationshipRowList) {
                if (!mapObjectIds.containsKey(rel.relationshipName)) {
                    mapObjectIds.put(rel.relationshipName, new List<Id>());
                }
                mapObjectIds.get(rel.relationshipName).add(row.sObjectOriginal.Id);
                if (!mapRelationshipFields.containsKey(rel.relationshipName)) {
                    mapRelationshipFields.put(rel.relationshipName, rel.relationshipFieldName);
                }
            }
        }
        //** Loop through each sObjectType to query the results for use later
        for (String objName : mapObjectIds.keySet()) {
            //** List of all Ids for the records to be cloned
            List<Id> sObjectIds = new List<Id>();
            sObjectIds = mapObjectIds.get(objName);
            //** List of all fields for the records to be cloned 
            List<String> sObjectFields = new List<String>();
            //** sObjectType
            Schema.SObjectType sObjectType = sObjectIds.get(0).getSObjectType();
            //** Get all current fields from the object
            if (sObjectType != null) {
                Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
                for (String fieldName : fieldMap.keySet()) {
                    if (fieldMap.get(fieldName).getDescribe().isCreateable()) {
                        sObjectFields.add(fieldName);
                    }
                }
            }
            for (Integer i = 0; i < sObjectFields.size(); i++) {
                if (UtilsVariables.getFieldExclusions(sObjectType.getDescribe().getName()).contains(sObjectFields.get(i))) {
                    sObjectFields.remove(i);
                }
            }
            //** If there are no records sent into the method, then return an empty list
            if (sObjectIds != null && !sObjectIds.isEmpty() && !sObjectFields.isEmpty()) {
                //** Construct a SOQL query to get all field values of all records (sort Id ascending)
                String sObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0);
                for (Integer i = 1; i < sObjectFields.size(); i++) {
                    sObjectFieldsQuery += ', ' + sObjectFields.get(i);
                }
                sObjectFieldsQuery += ' FROM ' + sObjectType.getDescribe().getName();
                sObjectFieldsQuery += ' WHERE Id IN (\'' + sObjectIds.get(0) + '\'';
                for (Integer i = 1 ; i < sObjectIds.size() ; i++) {
                    sObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
                }
                sObjectFieldsQuery += ')';
                System.debug('##### sObjectFieldsQuery: ' + sObjectFieldsQuery);
                List<sObject> sObjectFieldsQueryResults = Database.query(sObjectFieldsQuery);
                Map<Id, sObject> mapObjectFieldsQueryResults = new Map<Id, sObject>();
                for (sObject obj : sObjectFieldsQueryResults) {
                    mapObjectFieldsQueryResults.put(obj.Id, obj);
                }
                mapObjectQueries.put(objName, mapObjectFieldsQueryResults);
            }
        }
        //** Loop through each level to insert while adding the correct parent identification
        for (Integer currentLevel = 0 ; currentLevel < 20 ; currentLevel++) {
            List<sObject> sObjectsToClone = new List<sObject>();
            List<Id> listIdOld = new List<Id>();
            List<Id> listIdNew = new List<Id>();
            for (sObjectChildRelationship cloneChildRelationship : myChildRelationships) {
                if (cloneChildRelationship.relationshipLevel == currentLevel) {
                    sObjectsToClone = new List<sObject>();
                    for (sObjectChildRelationshipRow cloneChildRelationshipRow :
                            cloneChildRelationship.myChildRelationshipRowList) {
                        listIdOld.add(cloneChildRelationshipRow.sObjectOriginal.Id);
                        sObject orig = mapObjectQueries.get(cloneChildRelationship.relationshipName).get(
                            cloneChildRelationshipRow.sObjectOriginal.Id);
                        sObject clone = UtilsGeneral.newBlankSObject(orig);
                        Map<String, Schema.SObjectField> fieldMap = clone.getSObjectType().getDescribe().fields.getMap();
                        System.debug('##### Clone: Before = ' + clone);
                        for (String fieldName : fieldMap.keySet()) {
                            if (fieldName != 'Id' && fieldMap.get(fieldName).getDescribe().isCreateable() &&
                                    !UtilsVariables.getFieldExclusions(clone.getSObjectType().getDescribe().getName()).contains(
                                    fieldName)) {
                                clone.put(fieldName, orig.get(fieldName));
                                System.debug('##### Clone: Field Clone = ' + fieldName + ': ' + orig.get(fieldName));
                            }
                            if (fieldName != 'Id' && fieldMap.get(fieldName).getDescribe().isCreateable() &&
                                    UtilsVariables.getFieldDefaults(clone.getSObjectType().getDescribe().getName()).contains(
                                    fieldName)) {
                                clone.put(fieldName,
                                    UtilsVariables.getFieldDefault(clone.getSObjectType().getDescribe().getName(), fieldName));
                                System.debug('##### Clone: Field Default = ' + fieldName + ': ' + UtilsVariables.getFieldDefault(
                                    clone.getSObjectType().getDescribe().getName(), fieldName));
                            }
                        }
                        if (cloneChildRelationship.relationshipFieldName != null) {
                            clone.put(cloneChildRelationship.relationshipFieldName, mapIdOldNew.get((Id) mapObjectQueries.get(
                                cloneChildRelationship.relationshipName).get(cloneChildRelationshipRow.sObjectOriginal.Id).get(
                                cloneChildRelationship.relationshipFieldName)));
                            System.debug('##### Clone: Field Relationship = ' + cloneChildRelationship.relationshipFieldName +
                                ': ' + mapIdOldNew.get((Id) mapObjectQueries.get(cloneChildRelationship.relationshipName).get(
                                cloneChildRelationshipRow.sObjectOriginal.Id).get(
                                cloneChildRelationship.relationshipFieldName)));
                        }
                        System.debug('##### Clone: After = ' + clone);
                        sObject cloned = clone.clone(false, true);
                        sObjectsToClone.add(cloned);
                        System.debug('##### Clone: Cloned = ' + cloned);
                    }
                    //** Insert cloned records
                    insert sObjectsToClone;
                    //** Populate list with cloned (new) Ids [assumption is it's the same order as listIdOld]
                    for (sObject newObject : sObjectsToClone) {
                        listIdNew.add(newObject.Id);
                    }
                    //** Fail gracefully if listOldId.size() != listNewId.size()
                    System.assertEquals(listIdNew.size(), listIdOld.size());
                    //** Map the original (old) Ids to the cloned (new) Ids
                    for (Integer i = 0 ; i < listIdOld.size() ; i++) {
                        mapIdOldNew.put(listIdOld.get(i), listIdNew.get(i));
                        if (chatterPost && currentLevel == 0) {
                            UtilsChatter.postChatterFeedItem(ConnectApi.FeedType.Record,
                                listIdNew.get(i),
                                UtilsVariables.getAPEXMessage('CloneChatterMessage') + listIdOld.get(i));
                        }
                    }
                }
            }
        }
        List<Id> clonedObjectIds = new List<Id>();
        for (sObject originalObject : originalObjects) {
            clonedObjectIds.add(mapIdOldNew.get(originalObject.Id));
        }
        return clonedObjectIds;
    }
    
    //** Allow pages and external services to trigger a clone from a single object with or without a Chatter post
    webService static Id clone(Id originalId, Boolean chatterPost) {
        //** Build query to return the full object from an Id
        String originalObjectQuery = 'SELECT ID';
        originalObjectQuery += ' FROM ' + originalId.getSObjectType().getDescribe().getName();
        originalObjectQuery += ' WHERE Id = \'' + originalId + '\'';
        //** Executive query to return the full object from an Id
        List<sObject> originalObject = Database.query(originalObjectQuery);
        //** Execute clone()
        List<Id> clonedIds = clone(originalObject, chatterPost);
        return clonedIds[0];
    }
    
    //** Houses the relationship information with the list of related records
    public class sObjectChildRelationship {
        //** What level of child is it?  0=Parent 1=Child 2=Grand-Child 3=Great-Grand-Child etc...
        public Integer relationshipLevel {get; set;}
        //** What table are the related records stored in?
        public String relationshipName {get; set;}
        //** What is the field name that stores the parent-child relationship?
        public String relationshipFieldName {get; set;}
        //** Houses the list of actual records
        public List<sObjectChildRelationshipRow> myChildRelationshipRowList {get; set;}
        //** Initialize
        public sObjectChildRelationship(Integer relationshipLevel,
                String relationshipName,
                String relationshipFieldName,
                List<sObjectChildRelationshipRow> myChildRelationshipRowList) {
            this.relationshipLevel = relationshipLevel;
            this.relationshipName = relationshipName;
            this.relationshipFieldName = relationshipFieldName;
            this.myChildRelationshipRowList = myChildRelationshipRowList;
        }
    }
    
    //** Houses the actual record
    public class sObjectChildRelationshipRow {
        //** What record am I cloning?
        public sObject sObjectOriginal {get; set;}
        //** Initialize
        public sObjectChildRelationshipRow(sObject sObjectOriginal) {
            this.sObjectOriginal = sObjectOriginal;
        }
    }
    
}