public with sharing class SL_Test_CreateAccess {
    public static map<Schema.sObjectType, set<String>> objectToFields = getObjectToFields();
    //public map<Schema.sObjectType, list<Id>> objectTypesToIDs; 
    public map<Id,sObject> idToSObject;

    public static map<Schema.sObjectType, set<String>> getObjectToFields()
    {
        return new map<Schema.sObjectType, set<String>>{
            Affiliation__c.sObjectType => getFields(Affiliation__c.sObjectType, true, true),
            Account.sObjectType => getFields(Account.sObjectType, true, true),
            Contact.SObjectType => getFields(Contact.sObjectType, true, true),
            Organization_Name__c.sObjectType => getFields(Organization_Name__c.sObjectType, true, true),
            Organization_Address__c.sObjectType => getFields(Organization_Address__c.sObjectType, true, true),
            Organization_Credential__c.sObjectType => getFields(Organization_Credential__c.sObjectType, true, true),
            Organization_Specialty__c.sObjectType => getFields(Organization_Specialty__c.sObjectType, true, true),
            Organization_Service__c.sObjectType => getFields(Organization_Service__c.sObjectType, true, true),
            Care_Team__c.sObjectType => getFields(Care_Team__c.sObjectType, true, true),
            Organization_Affiliation__c.sObjectType => getFields(Organization_Affiliation__c.sObjectType, true, true),
            Affiliation_Service__c.sObjectType => getFields(Affiliation_Service__c.sObjectType, true, true),
            Provider_Address__c.sObjectType => getFields(Provider_Address__c.sObjectType, true, true),
            Provider_Specialty__c.sObjectType => getFields(Provider_Specialty__c.sObjectType, true, true),
            Provider_Credential__c.sObjectType => getFields(Provider_Credential__c.sObjectType, true, true),
            Provider_Care_Team__c.sObjectType => getFields(Provider_Care_Team__c.sObjectType, true, true),
            Electronic_Service__c.sObjectType => getFields(Electronic_Service__c.sObjectType, true, true),
            Case.sObjectType => getFields(Case.sObjectType, true, true)
        };
    }

    /*
        Returns a set of fields belonging to an object, with options to filter out fields
        that aren't updateable or must be unique.
    */
    public static set<string> getFields(Schema.SObjectType objectType, boolean filterNonCreateable, 
                                        boolean filterUnique)
    {
        Map<String, Schema.SObjectField> fMap = objectType.getDescribe().Fields.getMap();
        set<string> validFields = new set<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if ((!filterNonCreateable || fd.isCreateable()) &&
                    (!filterUnique || !fd.isUnique())){ // field is creatable
                    validFields.add(fd.getName());
                }
            }
        }
        return validFields;
    }

    
    public void testCreateAccess(Schema.sObjectType type, Map<ID,SecurityTestConfig__c[]> userToRecords, Map<ID,SecurityTestConfig__c> recordToConfig) {
        this.idToSObject = getidToSObject(type, recordToConfig.keySet());
        map<Id,list<sObject>> usersToRecordsWithCreateAccess = new map<Id,list<sObject>>();
        map<Id,list<sObject>> usersToRecordsWITHOUTCreateAccess = new map<Id,list<sObject>>();

        for(Id userId : userToRecords.keyset()){
            for(Integer i=0; i<userToRecords.get(userId).size(); i++){
                if(userToRecords.get(userId).get(i).has_create_access__c){
                    if(usersToRecordsWithCreateAccess.containsKey(userId) && usersToRecordsWithCreateAccess.get(userId) != null){
                        usersToRecordsWithCreateAccess.get(userId).add(idToSObject.get(userToRecords.get(userId).get(i).Record_ID_For_Test__c));
                    }
                    else{
                        usersToRecordsWithCreateAccess.put(userId, new list<sObject>{idToSObject.get(userToRecords.get(userId).get(i).Record_ID_For_Test__c)});
                    }
                }
                else{
                    if(usersToRecordsWITHOUTCreateAccess.containsKey(userId) && usersToRecordsWITHOUTCreateAccess.get(userId) != null){
                        usersToRecordsWITHOUTCreateAccess.get(userId).add(idToSObject.get(userToRecords.get(userId).get(i).Record_ID_For_Test__c));
                    }
                    else{
                        usersToRecordsWITHOUTCreateAccess.put(userId, new list<sObject>{idToSObject.get(userToRecords.get(userId).get(i).Record_ID_For_Test__c)});
                    }
                }
            }
        }

        //Clone sObject records and set id to null
        map<Id,list<SObject>> usersToRecordsWithCreateAccessCopy = new map<Id,list<SObject>>();
        for(Id userId : usersToRecordsWithCreateAccess.keySet()){
            usersToRecordsWithCreateAccessCopy.put(userId, usersToRecordsWithCreateAccess.get(userId).deepClone());
        }
        map<Id,list<sObject>> usersToRecordsWITHOUTCreateAccessCopy = new map<Id,list<SObject>>();
        for(Id userId : usersToRecordsWITHOUTCreateAccess.keySet()){
            usersToRecordsWITHOUTCreateAccessCopy.put(userId, usersToRecordsWITHOUTCreateAccess.get(userId).deepClone());
        }

        map<Id,User> runAsUsers = new map<Id,User>([Select Id From User Where Id = :userToRecords.keySet() ]);

        boolean throwTestError = false;
        //Insert cloned sObject records as appropriate user
        try{
        for(Id userId: usersToRecordsWithCreateAccessCopy.keySet()){
            system.runAs(runAsUsers.get(userId)){
                if(usersToRecordsWithCreateAccessCopy.get(userId).size() > 0){
                    list<Database.SaveResult> withAccessResults = DataBase.Insert(usersToRecordsWithCreateAccessCopy.get(userId), FALSE);
                    for(Integer i=0; i<withAccessResults.size(); i++){
                        if(!withAccessResults.get(i).isSuccess()){
                            throwTestError = true;
                            System.debug('Insert wrongfully failed on cloned record with original id ' + usersToRecordsWithCreateAccess.get(userId).get(i).Id);
                            System.debug('Config Id: ' +recordToConfig.get(usersToRecordsWithCreateAccess.get(userId).get(i).Id).Id);
                            for(Database.Error e : withAccessResults.get(i).getErrors()){
                                System.debug(e);
                            }
                        }
                    }
                }

            }
        }
        
        for(Id userId: usersToRecordsWITHOUTCreateAccessCopy.keySet()){
            system.runAs(runAsUsers.get(userId)){
                if(usersToRecordsWITHOUTCreateAccessCopy.get(userId).size() > 0){
                    list<Database.SaveResult> noAccessResults = DataBase.Insert(usersToRecordsWITHOUTCreateAccessCopy.get(userId), FALSE);
                    for(Integer i=0; i<noAccessResults.size(); i++){
                        if(noAccessResults.get(i).isSuccess()){
                            throwTestError = true;
                            System.debug('Insert wrongfully succeeded on cloned record with original id ' + usersToRecordsWITHOUTCreateAccess.get(userId).get(i).Id);
                            System.debug('Config Id: ' +recordToConfig.get(usersToRecordsWITHOUTCreateAccess.get(userId).get(i).Id).Id);
                        }
                    }
                }
                
            }
        }
        }
        catch(Exception ex)
        {
            system.debug('====================='+ex);
        }
        if(throwTestError){
            System.assert(FALSE,'One or more inserts wrongfully succeeded or failed. See Debug log.');
        }

        
    }

    public static map<Id,sObject> getidToSObject(Schema.sObjectType type, set<Id> ids){
        map<Id,sObject> output = new map<Id,sObject>();
        String query = 'Select Id, ' + String.Join(new list<String>(objectToFields.get(type)),', ') + ' FROM ' + String.valueof(type) + ' WHERE Id = :ids';
        for(sObject obj: Database.query(query)){
            output.put((Id)obj.get('Id'), obj);
        }
        return output;
    }
}