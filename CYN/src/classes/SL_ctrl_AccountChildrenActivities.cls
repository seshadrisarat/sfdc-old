public class SL_ctrl_AccountChildrenActivities {
    
    private static final String SCULPSURE_LASER = 'SculpSure';
    
    private List<sObject> activityRecords;
    public String activityRecordsJSON {get;set;}
    public List<Schema.FieldSetMember> listViewFieldSet {get;set;}
    public String listViewFieldSetJSON {get;set;}
    public String idMapJSON {get;set;}
    public String curRecordID {get;set;}
    public String curRecordName {get;set;}
    private String runningUser {get;set;}
    /*Added by Sanath*/
    public String strFilterOpt {get;set;}
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All Activities','All Activities'));
        options.add(new SelectOption('AMPS Activities','AMPS Activities'));
        options.add(new SelectOption('Sculpsure Activities','Sculpsure Activities')); 
        return options;
    }

    /*Added by Sanath*/
    public  SL_ctrl_AccountChildrenActivities(ApexPages.StandardController controller)
    {   
        strFilterOpt = 'All Activities';
        sObject inRecord = (sObject)controller.getRecord();
        curRecordID = inRecord.ID;
        Account a = [Select Name From Account Where Id =: curRecordID];
        curRecordName = a.Name;
        runningUser = UserInfo.getUserId();
        initialize();
    } 

    private void initialize()
    {
        String fieldsetName = 'Amps_Tasks';
        listViewFieldSet = SObjectType.Task.FieldSets.getMap().get(fieldsetName).getFields();
        listViewFieldSetJSON = JSON.serializePretty(listViewFieldSet);
        
        List<Id> lasersOwned = new List<Id>();
        for(Laser_Owned__c lo : [SELECT Id FROM Laser_Owned__c WHERE Practice__c =: curRecordID]){
        	lasersOwned.add(lo.Id);  
        }
        
        String query1 = 'SELECT ';
        String query2 = 'SELECT ';
        Boolean useWhatId = false;
        Boolean useWhoId = false;
        //what should be done here is check if a field is a reference via fieldsetmember.gettype
        //if it is, add it to a map<string,list<id>> as a key. then when iterating over the tasks and 
        //events, the value list should be populated with the matching field value
        //next, for each key, a query should be ran to get records where Id is in the value list
        //in order to do that, you'll need to check the object type w/ myId.getSObjectType().getDescribe().getName()
        //using the result, place the id and name of the returned records into a map <id, string>
        //and the front end can utilize this to make links to those records
        for(Schema.FieldSetMember f : listViewFieldSet) {
            if(f.getFieldPath() != 'Id' && f.getFieldPath() != 'Subject' && f.getFieldPath() != 'Description'){
                query1 += f.getFieldPath() + ', ';
	            query2 += f.getFieldPath() + ', ';
            }
            
            if(f.getFieldPath() != 'WhatId'){
                useWhatId = true;
            }
            if(f.getFieldPath() != 'WhoId'){
                useWhoId = true;
            }
        }
        query1 += 'Id, Subject, Description FROM Task WHERE WhatId IN :lasersOwned OR WhatId =: curRecordID';
        query2 += 'Id, Subject, Description FROM Event WHERE WhatId IN :lasersOwned OR WhatId =: curRecordID';
        
        List<sObject> activityRecords = new List<sObject>();
        List<Id> whatIds = new List<Id>();
        List<Id> whoIds = new List<Id>();
        for(sObject so : (List<sObject>)Database.query(query1)){
            activityRecords.add((sObject) so);
            if(useWhatId){
            	whatIds.add((Id)so.get('WhatId'));
            }
            if(useWhoId){
	            whoIds.add((Id)so.get('WhoId'));            
            }
        }
        for(sObject so : (List<sObject>)Database.query(query2)){
            activityRecords.add((sObject) so);
            if(useWhatId){
            	whatIds.add((Id)so.get('WhatId'));
            }
            if(useWhoId){
	            whoIds.add((Id)so.get('WhoId'));            
            }
        }
        
        Map<Id, String> idMap = new Map<Id, String>();
        //idMap.put(curRecordId, curRecordName);
        
        for(Laser_Owned__c lo : [SELECT Id, Name, Laser__r.Name FROM Laser_Owned__c WHERE Id IN: whatIds]){
            /*Conditions Added for CYN-6*/
            if(strFilterOpt.trim() == 'AMPS Activities')
            {
                if(!lo.Name.toLowercase().contains(SCULPSURE_LASER.toLowercase()))
                {
                    idMap.put(lo.Id, lo.Name);
                    //idMap.put(curRecordId, curRecordName);
                }
            }  
            if(strFilterOpt.trim() == 'Sculpsure Activities')
            {
                if(lo.Name.toLowercase().contains(SCULPSURE_LASER.toLowercase()))
                {
                    idMap.put(lo.Id, lo.Name);
                }
            }
            if(strFilterOpt.trim() == 'All Activities')
            {
                idMap.put(lo.Id, lo.Name);
            }
            /*Conditions Added for CYN-6*/
        }
        
        /*Added for CYN-6*/
        List<sObject> lstClonedFinalLst = new List<sObject>();
        for(sObject sObj:activityRecords)
        {
            if(idMap.containsKey((Id)sObj.get('WhatId')))
            {
                lstClonedFinalLst.add(sObj);
            }
        }
        activityRecords.clear();
        activityRecords.addAll(lstClonedFinalLst);
        /*Added for CYN-6*/
        
        for(Contact c : [SELECT Name FROM Contact WHERE Id IN: whoIds]){
            idMap.put(c.Id, c.Name);
        }
        
        idMapJSON = JSON.serializePretty(idMap);
        activityRecordsJSON = JSON.serializePretty(activityRecords);
    }
    
    public String getLasersOwned() {
        Map<Id, String> options = new Map<Id, String>();
        for(Laser_Owned__c lo : [SELECT ID, Name FROM Laser_Owned__c WHERE Practice__c =: curRecordID]){
            options.put(lo.Id, lo.Name);
        }
        options.put(curRecordId, curRecordName);
        
        return JSON.serializePretty(options);
    }
    /*Added for CYN-6*/
    public void updatePage()
    {
        initialize();
    }
    /*Added for CYN-6*/
}