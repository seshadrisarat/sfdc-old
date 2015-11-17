public class ActivityRelatedListController {
    /*
        Modified By: Jay, Tiago
        Date: 5/16/2014
        Changes : As a Brand Rep I would like to see only activities that correspond to my brand
                     when I view an Account or Contact
    */
    
    public Id recordId {
        get; 
        set;
    }
    
    String recordClass {
        get {
            if (recordClass == null && recordId != null){
                recordClass=recordId.getSObjectType().getDescribe().getName();
            }
            return recordClass;
        }
        set;
    }
    
    String linkToId {
        get{
            if (linkToId == null){
                if (recordClass == 'Contact'){
                    linkToId = 'who_id';
                }
                else {
                    linkToId = 'what_id';
                }
            }
            return linkToId;
        }
        set;
    }
    
    public Boolean showWhatIdButtons {
        get {
            if (showWhatIdButtons == null){
                showWhatIdButtons = (recordClass == 'Account');
            }
            return showWhatIdButtons; 
        }
        set;
    }
    
    public Boolean showWhoIdButtons {
        get {
            if (showWhoIdButtons == null){
                showWhoIdButtons = (recordClass == 'Contact');
            }
            return showWhoIdButtons; 
        }
        set;
    }
    
    public PageReference cancelAndReturn(){
        PageReference pref = new PageReference(customRetUrl);
        pref.setRedirect(true);
        return pref;
    }
    
    public String defaultLogACallStatus {
        get {
            return 'Completed';
        }
        set;
    }
    public String customRetUrl {
        get {
            return '/'+recordId;
        }
        set;
    }
    public String customSaveNewEventUrl {
        get {
            Schema.DescribeSObjectResult describeSObjectResult = Event.sObjectType.getDescribe();
            return '/' + describeSObjectResult.getKeyPrefix() + '/e?'+linkToId+'='+recordId+'&retURL=%2F'+recordId;
        }
        set;
    }
    public String customSaveNewTaskUrl {
        get {
            Schema.DescribeSObjectResult describeSObjectResult = Task.sObjectType.getDescribe();
            return '/' + describeSObjectResult.getKeyPrefix() + '/e?'+linkToId+'='+recordId+'&retURL=%2F'+recordId;
        }
        set;
    }
    
    public String customLogACallUrl {
        get {
            Schema.DescribeSObjectResult describeSObjectResult = Task.sObjectType.getDescribe();
            return '/' + describeSObjectResult.getKeyPrefix() + '/e?title=Call&'+linkToId+'='+recordId+'&followup=1&tsk5=Call&tsk12=Completed&retURL=%2F'+recordId;
        }
        set;
    }
    
    public Boolean showViewAllButton {
        get {
            return getActivityHistory != null && getActivityHistory.size() > 0;
        }
        set;
    }
    
    
    
    public ActivityRelatedListController() {
        buildActivityFieldSets();   
        recordId = ApexPages.currentPage().getParameters().get('id');
    }

    
    Map<String, Set<String>> devNames {
        get{
            if(devNames==null){
                devNames=new Map<String, Set<String>>();
                devNames.put('Task', new Set<String>());
                devNames.put('Event', new Set<String>());
                UserProfileActivityRecordTypes__c devNamesCustomSetting = UserProfileActivityRecordTypes__c.getInstance();
                if(devNamesCustomSetting != null){
                    if (!String.isBlank(devNamesCustomSetting.Task_Record_Types__c)){
                        devNames.get('Task').addAll(devNamesCustomSetting.Task_Record_Types__c.replaceAll(' ','').split(';'));
                    }
                    if (!String.isBlank(devNamesCustomSetting.Event_Record_Types__c)){
                        devNames.get('Event').addAll(devNamesCustomSetting.Event_Record_Types__c.replaceAll(' ','').split(';'));
                    }
                }
            }
            return devNames;
        }
        set;
    }
    
    void buildActivityFieldSets(){
        
        openActivityFieldSet = new List<String>();
        activityHistoryFieldSet = new List<String>();
        
        List<Activity_List_Field_Set__c> fieldSetCustomSettings = Activity_List_Field_Set__c.getAll().values();
        
        BluewolfDevUtils bwutil = new BluewolfDevUtils();
        List<Activity_List_Field_Set__c> orderedFieldSetCustomSettings = bwutil.standardSortBy((List<SObject>)fieldSetCustomSettings, 'Order__c', 'ASC');
        
        for (Activity_List_Field_Set__c fieldSetCustomSetting : orderedFieldSetCustomSettings){
            
            if (fieldSetCustomSetting.IsOpenActivity__c){
                openActivityFieldSet.add(fieldSetCustomSetting.Activity_Field_API_Name__c);
            }
            else{
                activityHistoryFieldSet.add(fieldSetCustomSetting.Activity_Field_API_Name__c);
            }
        }
        
    }
    
    public List<String> openActivityFieldSet {
        get;
        set;
    }
    
    public List<String> activityHistoryFieldSet {
        get;
        set;
    }
    
    public List<String> viewAllActivityHistoryFieldSet {
        get {
            if (viewAllActivityHistoryFieldSet == null){
                viewAllActivityHistoryFieldSet = new List<String>{
                    'Subject', 'ActivityType', 'IsTask', 'ActivityDate',
                    'OwnerId', 'Status', 'LastModifiedDate'};
            }
            return viewAllActivityHistoryFieldSet;
        }
        set;
    }
    
    public List<String> allActivityHistoryFieldSet {
        get {
            if (activityHistoryFieldSet != null && viewAllActivityHistoryFieldSet != null){
                
                Set<String> tempList = new Set<String>(activityHistoryFieldSet.clone());
                tempList.addAll(viewAllActivityHistoryFieldSet);
                allActivityHistoryFieldSet = new List<String>(tempList);
            }
            return allActivityHistoryFieldSet;
        }
        set;
    }

    public List<OpenActivity> getOpenActivities {
        
        get {
            if (getOpenActivities == null){
                
                if (!String.isBlank(recordClass)){
                    
                    String query ='SELECT ID, (Select '+String.join(openActivityFieldSet, ',')+' from OpenActivities) from '+ recordClass 
                                + ' Where Id = \''+recordId+'\'';
                    List<SObject> dbResult = Database.query(query);
                    
                    if (!dbResult.isEmpty()){
                        List<OpenActivity> allOpenActivitiesList = (List<OpenActivity>)dbResult[0].getSObjects('OpenActivities');
                        if (allOpenActivitiesList != null){
                            Set<OpenActivity> allOpenActivities = new Set<OpenActivity>(allOpenActivitiesList);
                            Set<Id> allOpenActivityIds = Pluck.ids(allOpenActivitiesList);
                            
                            List<SObject> eventActivities = [Select Id From Event Where Id in :allOpenActivityIds AND RecordType.DeveloperName in :devNames.get('Event') ];
                            List<SObject> taskActivities = [Select Id From Task Where Id in :allOpenActivityIds AND RecordType.DeveloperName in :devNames.get('Task')];
                            
                            Set<Id> allowedOpenActivities = new Set<Id>();
                            allowedOpenActivities.addAll(Pluck.ids(eventActivities));
                            allowedOpenActivities.addAll(Pluck.ids(taskActivities));
                            
                            for (OpenActivity openAct : allOpenActivities){
                                if (!allowedOpenActivities.contains(openAct.Id)){
                                    allOpenActivities.remove(openAct);
                                }   
                            }
                            getOpenActivities = new List<OpenActivity>(allOpenActivities);
                        }
                        else {
                            getOpenActivities = new List<OpenActivity>();
                        }
                    }
                }
            }
            return getOpenActivities;
        }
        set;
    }

    public List<ActivityHistory> getActivityHistory {
        get {
            if (getActivityHistory == null){
            
                if (!String.isBlank(recordClass)){
                    String query ='SELECT ID, (Select '+String.join(allActivityHistoryFieldSet, ',')+' from ActivityHistories) from '+ recordClass 
                                + ' Where Id = \''+recordId+'\'';
                    List<SObject> dbResult = Database.query(query);
                
                    if (!dbResult.isEmpty()){
                        List<ActivityHistory> allActivityHistoryList = (List<ActivityHistory>)dbResult[0].getSObjects('ActivityHistories');
                        if (allActivityHistoryList != null){
                            Set<ActivityHistory> allActivityHistory = new Set<ActivityHistory>(allActivityHistoryList);
                            Set<Id> allActivityHistoryIds = Pluck.ids(allActivityHistoryList);
                            
                            List<SObject> eventActivities = [Select Id From Event Where Id in :allActivityHistoryIds AND RecordType.DeveloperName in :devNames.get('Event') ];
                            List<SObject> taskActivities = [Select Id From Task Where Id in :allActivityHistoryIds AND RecordType.DeveloperName in :devNames.get('Task')];
                            
                            Set<Id> allowedActivityHistory = new Set<Id>();
                            allowedActivityHistory.addAll(Pluck.ids(eventActivities));
                            allowedActivityHistory.addAll(Pluck.ids(taskActivities));
                            
                            for (ActivityHistory activityHistory : allActivityHistory){
                                if (!allowedActivityHistory.contains(activityHistory.Id)){
                                    allActivityHistory.remove(activityHistory);
                                }   
                            }
                            
                            getActivityHistory = new List<ActivityHistory>(allActivityHistory);
                        }
                        else {
                            getActivityHistory = new List<ActivityHistory>();
                        }
                    }
                }
            }
            return getActivityHistory;
        }
        set;
    }


}